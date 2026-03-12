from sqlalchemy import create_engine, Column, Integer, String, ForiognKey, DateTime, Boolean
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import func

Base = declarative_base()

class Nota(base):
    __tablename__ = 'notas'

    id = Column(Integer, primary_key = True, autoincrement = True)
    numero_nf = Column(Integer)
    tipo = Column(String(20))
    cliente = Column(String(100))
    data = Column(DateTime, default = func.now())
    quantidade = Column(Integer)
    sincronizado = Column(Boolean, default=False)

class produto(Base):
    __tablename__ = 'produtos'

    codigo = Column(Integer, primary_key = True)
    quantidade = Column(Integer)

class Movimentacao(Base):
    __tablename__ = 'movimentacoes'

    id = Column(Integer, primary_key = True, autoincrement = True)
    nota_id = Column(Integer, ForeignKey('notas.id'))
    produto_codigo = Column(Integer, ForeignKey('produtos.codigo'))
    quantidade = Column(Integer)

