# 🚀 Git Push Automático (git_push_auto.sh)

## 🌟 Visão Geral

O `git_push_auto.sh` é um script de automação em Bash que simplifica e torna mais seguro o fluxo de `git add`, `git commit` e `git push`. Ele foca em:

*   **Autenticação Segura:** Usa o **GitHub CLI (`gh`)** para login e obtenção do Personal Access Token (PAT).
*   **Eficiência:** Executa **Limpeza Proativa do Git** (`git gc --prune=now`) para prevenir erros de objeto/desempacotamento.
*   **Segurança:** Alerta sobre arquivos sensíveis e oferece **Limpeza Interativa de Credenciais** após o uso.
*   **Interatividade:** Guia o usuário passo a passo, incluindo um menu para seleção de prefixos de commit.

[![Gemini-Generated-Image-p6l708p6l708p6l7.png](https://i.postimg.cc/7YMMfS01/Gemini-Generated-Image-p6l708p6l708p6l7.png)](https://postimg.cc/vcT6KgPD)

---

## 🛠️ Pré-requisitos

Você precisa ter os seguintes utilitários instalados:

1.  **Git**
2.  **Bash**
3.  **GitHub CLI (`gh`)**
4.  **`jq`** (para análise de JSON)
5.  **`curl`** e **`cmp`**

**Instalação (Termux/Linux):**
```bash
pkg install git curl coreutils jq gh
```

---

## 💻 Como Usar

### 1. Baixar o Script

```bash
curl -o git_push_auto.sh https://raw.githubusercontent.com/Pauloh2206/script-auto-push/refs/heads/main/git_push_auto.sh
```

### 2. Dar Permissão de Execução

```bash
chmod +x git_push_auto.sh
```

> **⚠️ IMPORTANTE:** O script **DEVE** ser executado dentro da pasta raiz do seu projeto Git.

### 3. Executar o Script

```bash
bash git_push_auto.sh
```

O script irá guiar você através da autenticação, commit e push, oferecendo soluções interativas para erros comuns.

Durante autenticação ⬇️
1 - "Github.com"
2 - "HTTPS (PAT) ou SSH (KEY)"
3 - "Paste an authentication token (PAT)"
---

## 👨‍💻 Autor

*   **Autor:** Paulo Hernani Costa 🍥
*   **Assistência no Desenvolvimento:** Gemini AI
*   **Instagram:** @eu_paulo_ti

## 📄 Licença

Este projeto é de código aberto. Consulte o próprio script para detalhes de licenciamento.
