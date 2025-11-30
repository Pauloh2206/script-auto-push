# 🚀 Git Push Automático (git_push_auto.sh)

## 🌟 Visão Geral

O `git_push_auto.sh` é um script de automação em Bash projetado para simplificar e tornar mais seguro o fluxo de trabalho de envio de código para o GitHub (ou qualquer repositório Git). Ele encapsula as etapas de `git add`, `git commit` e `git push` em um processo interativo, adicionando verificações de segurança, eficiência e soluções automáticas para erros comuns.

Este script é especialmente útil para desenvolvedores que buscam um processo de deploy rápido e robusto, com foco na prevenção de problemas como envio de credenciais e falhas de objeto/desempacotamento.

---

## 📋 Índice

1.  [Funcionalidades Principais](#-funcionalidades-principais)
2.  [Pré-requisitos](#-pré-requisitos)
3.  [Como Usar](#-como-usar)
4.  [Fluxo de Execução](#-fluxo-de-execução)
5.  [Tratamento de Erros e Soluções](#-tratamento-de-erros-e-soluções)

---

## ✨ Funcionalidades Principais

| Categoria | Funcionalidade | Descrição |
| :--- | :--- | :--- |
| **Setup** | **Verificação de Ambiente** | Garante que o Git está instalado e que o usuário está no diretório raiz do projeto. |
| | **Correção de Permissão** | Solução automática para o erro de "dubious ownership" (comum em ambientes como Termux/Android). |
| **Segurança** | **Alerta de Credenciais** | Verifica a presença de arquivos potencialmente sensíveis (`.env`, `.key`, `.pem`) e alerta o usuário antes do commit. |
| | **Proteção contra `node_modules`** | Detecta a pasta `node_modules` e oferece a opção de adicioná-la ao `.gitignore` e removê-la do rastreamento do Git. |
| **Eficiência** | **Alerta de Arquivos Grandes** | Avisa sobre arquivos maiores que 50MB e sugere o uso do Git LFS (Large File Storage). |
| **Commit** | **Seleção de Commit Interativa** | Oferece um menu de prefixos de commit (ex: `feat`, `fix`, `chore`) seguindo o padrão Conventional Commits. |
| **Push** | **Autenticação Segura** | Pede o Nome de Usuário e o Personal Access Token (PAT) do GitHub e oferece a opção de salvar as credenciais temporariamente. |
| **Resolução de Problemas** | **Tratamento de Erros Pós-Push** | Inclui menus interativos para solucionar falhas de push, como erros de objeto/desempacotamento e falhas de autenticação. |
| | **Bloqueio de Segredo (GH013)** | Diagnostica e oferece opções para contornar o bloqueio de segurança do GitHub que impede o envio de segredos no histórico. |

---

## 🛠️ Pré-requisitos

Para executar este script, você precisa ter:

1.  **Git:** O sistema de controle de versão deve estar instalado e acessível no seu PATH.
2.  **Bash:** O script é escrito em Bash e deve ser executado em um ambiente compatível (Linux, macOS, WSL ou Termux).

---

## 💻 Como Usar

### 1. Baixar o Script

Baixe o script diretamente do repositório usando `curl` e salve-o como `git_push_auto.sh`:

```bash
curl -o git_push_auto.sh https://raw.githubusercontent.com/Pauloh2206/script-auto-push/refs/heads/main/git_push_auto.sh
```

### 2. Dar Permissão de Execução

Antes de usar, você deve conceder permissão de execução ao arquivo:

```bash
chmod +x git_push_auto.sh
```

> **⚠️ AVISO IMPORTANTE:** O script **DEVE** ser executado dentro da pasta raiz do projeto Git que você deseja fazer o `push`. Ele não funcionará corretamente se for executado de um diretório diferente.

### 3. Executar o Script

Navegue até a pasta raiz do seu projeto Git e execute o script:

```bash
bash git_push_auto.sh
```

O script irá guiá-lo passo a passo através do processo.

---

## ⚙️ Fluxo de Execução

O script segue esta sequência lógica, com intervenção do usuário em cada etapa:

1.  **Início:** Exibe a saudação e verifica se o Git está instalado.
2.  **Confirmação de Diretório:** Pede confirmação de que você está na pasta correta do projeto.
3.  **Inicialização:** Se a pasta não for um repositório Git, ele executa `git init`.
4.  **Verificações de Segurança:** Alerta sobre arquivos sensíveis, arquivos grandes e a ausência de `.gitignore`.
5.  **Tratamento de `node_modules`:** Se a pasta existir e não estiver ignorada, o script pergunta se deve corrigi-la.
6.  **Adicionar Arquivos:** Executa `git add .` para preparar todos os arquivos.
7.  **Commit:** Pede a mensagem de commit, oferecendo um menu de prefixos.
8.  **Configuração Remota:** Se não houver um repositório remoto configurado, ele solicita a URL.
9.  **Autenticação:** Solicita o nome de usuário e o PAT do GitHub para realizar o `git push` via HTTPS.
10. **Push:** Executa o `git push`.
11. **Tratamento de Erros:** Se o push falhar, o script entra em um modo de diagnóstico interativo para tentar corrigir o problema.
12. **Fim:** Em caso de sucesso, exibe uma mensagem de conclusão.

---

## ⚠️ Tratamento de Erros e Soluções

Um dos maiores diferenciais deste script é sua capacidade de diagnosticar e oferecer soluções para falhas comuns do Git:

### 1. Erro de Objeto/Desempacotamento (`remote unpack failed`)

Este erro geralmente indica corrupção de dados local ou problemas com arquivos muito grandes. O script oferece um menu de correção:

*   **Opção 1 (Padrão):** Executa `git gc --prune=now` para otimizar o repositório.
*   **Opção 2 (Agressiva):** Remove pacotes de objeto corrompidos e força a recriação (`rm -rf .git/objects/pack/*` e `git repack -a -d`).
*   **Opção 3 (Último Recurso):** Fornece instruções para um `git push --force` manual.

### 2. Erro de Autenticação (`Authentication failed`)

Se o PAT (Personal Access Token) ou o nome de usuário estiverem incorretos, o script limpa as credenciais armazenadas e permite que o usuário tente novamente.

### 3. Bloqueio de Segredo (GH013)

Se o GitHub detectar uma chave de API ou outro segredo no seu histórico de commits, o script:

*   Tenta identificar o arquivo problemático.
*   Oferece a opção de **Autorizar Temporariamente** (fornecendo o link de desbloqueio do GitHub) ou **Remover Permanentemente** (fornecendo instruções para o `git filter-repo`).

---

## 👨‍💻 Autor

*   **Autor:** Paulo Hernani Costa 🍥
*   **Assistência no Desenvolvimento:** Gemini
*   **Instagram:** @eu_paulo_ti

## 📄 Licença

Este projeto é de código aberto. Consulte o próprio script para detalhes de licenciamento.
