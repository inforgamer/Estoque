from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class NotaFiscal(BaseModel):
    chave_acesso: str

@app.post("/receber-nota")
async def receber_nota(nota: NotaFiscal):
    print(f"NOTA DETECTADA. CHAVE: {nota.chave_acesso}")
    produtos = [
        {"id": 1, "nome": "TECLADO MECANICO RGB", "qtd": 2, "preco": 250.0},
        {"id": 2, "nome": "MOUSE PAD GAMER XL", "qtd": 5, "preco": 80.0},
        {"id": 3, "nome": "CABO HDMI 2.1 2M", "qtd": 10, "preco": 45.0},
    ]
    
    return {
        "status": "sucesso",
        "fornecedor": "DISTRIBUIDORA INFOR LTDA",
        "itens": produtos
    }