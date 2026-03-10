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
    
    resposta = {
        "status": "sucesso", 
        "mensagem": f"Nota com chave {nota.chave_acesso} recebida com sucesso!"
    }
    
    return resposta