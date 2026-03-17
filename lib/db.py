import os
import sys
from dotenv import load_dotenv
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import declarative_base
from sqlalchemy.sql import func

if getattr(sys, 'frozen', False):
    BASE_DIR = os.path.dirname(sys.executable)
else:
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

load_dotenv(os.path.join(BASE_DIR, '.env'))

Base = declarative_base()

class Nota(Base):
    __tablename__ = 'notas'
    id = Column(Integer, primary_key=True, autoincrement=True)
    numero_nf = Column(Integer)
    tipo = Column(String(20))
    cliente = Column(String(100))
    data = Column(DateTime, default=func.now())
    quantidade = Column(Integer)
    sincronizado = Column(Boolean, default=False)

class Produto(Base): 
    __tablename__ = 'produtos'
    codigo = Column(Integer, primary_key=True)
    quantidade = Column(Integer)

class Movimentacao(Base):
    __tablename__ = 'movimentacoes'
    id = Column(Integer, primary_key=True, autoincrement=True)
    nota_id = Column(Integer, ForeignKey('notas.id'))
    produto_codigo = Column(Integer, ForeignKey('produtos.codigo'))
    quantidade = Column(Integer)

url_sqlite = os.getenv('URL_SQLITE')
if not url_sqlite or not url_sqlite.startswith("sqlite"):
    caminho_db = os.path.join(BASE_DIR, "notas.db")
    url_sqlite = f"sqlite:///{caminho_db}"

motor_sqlite = create_engine(url_sqlite, echo=False)

url_mysql = os.getenv('URL_MYSQL')
mysql_connected = False
motor_mysql = None

if url_mysql and url_mysql.startswith("mysql"):
    try:
        motor_mysql = create_engine(url_mysql, echo=False)
        connection = motor_mysql.connect()
        connection.close()
        mysql_connected = True
        print("🟢 Conexão estabelecida com o MySQL.")
    except Exception as e:
        print("🔴 Falha ao conectar ao MySQL. Usando SQLite como fallback.")
        print(f"Erro: {e}")
else:
    print("🟡 URL_MYSQL inválida ou vazia no .env. Rodando apenas com SQLite.")

print("Criando tabelas no SQLite...")
Base.metadata.create_all(motor_sqlite)

if mysql_connected:
    print("Criando tabelas no MySQL...")
    Base.metadata.create_all(motor_mysql)

print("✅ Configuração do banco de dados concluída.")