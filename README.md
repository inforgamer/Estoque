# 📦 ESTOQUE - Sincronização Híbrida & Automação

![Build Status](https://github.com/SEU_USUARIO/SEU_REPOSITORIO/actions/workflows/build.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-00000F?style=for-the-badge&logo=mysql&logoColor=white)

Sistema de gerenciamento de estoque profissional desenvolvido com foco em **redundância de dados** e **experiência do usuário**. O projeto utiliza uma arquitetura híbrida para garantir que o estoque nunca pare, mesmo sem internet.

---

## 🚀 Diferenciais do Projeto

* **🛡️ Redundância "Cofre":** Sincronização automática entre banco local (**SQLite**) no notebook e banco central (**MySQL**) no servidor Linux (Zorin OS).
* **⚙️ Automação Total (CI/CD):** Builds automáticos para Windows via GitHub Actions. O código é compilado na nuvem e entregue pronto para uso.
* **🔍 Multifiltros Inteligentes:** Pesquisa avançada por Data (Calendário), Número de Nota, Cliente ou Código de Produto.
* **🚫 Blindagem contra Erros:** * Bloqueio de estoque negativo.
    * Prevenção de duplicidade em Notas Fiscais.
    * Validação de soma total de itens.

---

## 🛠️ Stack Tecnológica

* **Front-end:** [Flutter](https://flutter.dev/) (Interface Desktop moderna e fluida).
* **Back-end:** [FastAPI](https://fastapi.tiangolo.com/) (Motor Python de alta performance).
* **Bancos de Dados:** SQLAlchemy (ORM) gerenciando SQLite e MySQL simultaneamente.
* **DevOps:** GitHub Actions para compilação cruzada (Cross-compilation).

---

> [!IMPORTANT]
> **Arquitetura de Sincronização:**
> O sistema opera em modo "Offline-First". Toda nota é salva localmente e, se houver conexão, espelhada instantaneamente para o servidor central.

---

## 📥 Como rodar o projeto

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/SEU_USUARIO/EstoquePro.git](https://github.com/inforgamer/Estoque)
    ```
2.  **Configure o arquivo `.env`:**
    Crie um arquivo `.env` na raiz com o IP do seu servidor MySQL:
    ```env
    MYSQL_IP
    DB_USER=seu_usuario
    DB_PASS=sua_senha
    ```
3.  **Acesse os binários:**
    Vá na aba **Actions** deste repositório e baixe o artefato mais recente do Windows.

---

## ✒️ Autor

* **Infor** - ** - [Meu GitHub](https://github.com/inforgamer)
