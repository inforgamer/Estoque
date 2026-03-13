import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
from sqlalchemy.orm import sessionmaker
from datetime import datetime
from lib.db import Nota, Produto, Movimentacao, motor_sqlite, mysql_connected, motor_mysql

load_dotenv()
app = FastAPI(title="Estoque Pro API")
SessaoSQLite = sessionmaker(bind=motor_sqlite)
SessaoMySQL = sessionmaker(bind=motor_mysql) if mysql_connected else None

class Item(BaseModel):
    codigo: int
    quantidade: int

class Nota_Recebida(BaseModel):
    tipo: str
    numero_nf: int
    cliente: str
    quantidade: int
    itens: List[Item]

@app.post("/api/notas")
def receber_nota(Dados: Nota_Recebida):
    db = SessaoSQLite()
    try:
        if Dados.tipo == "saida":
            for item in Dados.itens:
                p = db.query(Produto).filter_by(codigo=item.codigo).first()
                if not p or p.quantidade < item.quantidade:
                    raise HTTPException(status_code=400, detail=f"Sem estoque para o código {item.codigo}")

        nova_nota = Nota(numero_nf=Dados.numero_nf, tipo=Dados.tipo, cliente=Dados.cliente, quantidade=Dados.quantidade, sincronizado=mysql_connected)
        db.add(nova_nota)
        db.flush()

        for item in Dados.itens:
            prod = db.query(Produto).filter_by(codigo=item.codigo).first()
            if not prod:
                prod = Produto(codigo=item.codigo, quantidade=0)
                db.add(prod)
                db.flush()
            if Dados.tipo == "entrada": prod.quantidade += item.quantidade
            else: prod.quantidade -= item.quantidade
            db.add(Movimentacao(nota_id=nova_nota.id, produto_codigo=item.codigo, quantidade=item.quantidade))
        
        db.commit()
        return {"status": "sucesso"}
    except HTTPException as e: raise e
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally: db.close()

@app.get("/api/estoque")
def listar_estoque():
    db = SessaoSQLite()
    prods = db.query(Produto).all()
    db.close()
    return [{"codigo": p.codigo, "quantidade": p.quantidade} for p in prods]

@app.post("/api/estoque/editar")
def editar_estoque(item: Item):
    db = SessaoSQLite()
    p = db.query(Produto).filter_by(codigo=item.codigo).first()
    if p: p.quantidade = item.quantidade
    db.commit()
    db.close()
    return {"status": "ok"}

@app.get("/api/historico")
def ver_historico():
    db = SessaoSQLite()
    notas = db.query(Nota).order_by(Nota.id.desc()).all()
    res = []
    for n in notas:
        movs = db.query(Movimentacao).filter_by(nota_id=n.id).all()
        res.append({
            "numero_nf": n.numero_nf, "tipo": n.tipo, "cliente": n.cliente,
            "data": n.data.strftime("%d/%m/%Y %H:%M"),
            "itens": [{"codigo": m.produto_codigo, "quantidade": m.quantidade} for m in movs]
        })
    db.close()
    return res

@app.post("/api/ajuste")
def ajustar(item: Item):
    db = SessaoSQLite()
    p = db.query(Produto).filter_by(codigo=item.codigo).first()
    if not p: db.add(Produto(codigo=item.codigo, quantidade=item.quantidade))
    else: p.quantidade += item.quantidade
    db.commit()
    db.close()
    return {"status": "ok"}

@app.delete("/api/reset")
def reset():
    db = SessaoSQLite()
    db.query(Movimentacao).delete()
    db.query(Nota).delete()
    db.query(Produto).delete()
    db.commit()
    db.close()
    return {"status": "limpo"}