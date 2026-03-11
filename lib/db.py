from sqlalchemy import create_engine, Column, Integer, String, ForiognKey
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class NotaEntrada(Base):
    __tablename__ = 'nota_entrada'
    id = Column(Integer, primary_key=True)
    numero_nota = Column(String, nullable=False)
    data_emissao = Column(String, nullable=False)
    fornecedor = Column(String, nullable=False)