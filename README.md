# 🚀 Git Push Automático (git_push_auto.sh)

## 🌟 Visão Geral

O `git_push_auto.sh` é um script de automação em Bash projetado para simplificar e tornar mais seguro o fluxo de trabalho de envio de código para o GitHub (ou qualquer repositório Git). Ele encapsula as etapas de `git add`, `git commit` e `git push` em um processo interativo, adicionando verificações de segurança, eficiência e soluções automáticas para erros comuns.

Este script é especialmente útil para desenvolvedores que buscam um processo de deploy rápido e robusto, com foco na **autenticação segura via GitHub CLI**, **limpeza proativa do Git** e **prevenção de problemas** como envio de credenciais e falhas de objeto/desempacotamento.

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
| **Setup** | **Verificação de Atualização** | Verifica automaticamente se há uma nova versão do script disponível no repositório. |
| | **Criação de Repositório** | Oferece a opção de criar um novo repositório no GitHub de forma interativa antes do primeiro push. |
| **Segurança** | **Autenticação via GitHub CLI** | Utiliza o `gh auth login` para um processo de autenticação mais seguro e persistente, obtendo o PAT automaticamente. |
| | **Limpeza Interativa de Credenciais** | Após o sucesso ou falha, oferece a opção de limpar o PAT da memória temporária do script e deslogar do GitHub CLI. |
| | **Alerta de Credenciais** | Verifica a presença de arquivos potencialmente sensíveis (`.env`, `.key`, `.pem`) e alerta o usuário antes do commit. |
| **Eficiência** | **Limpeza Proativa do Git** | Executa `git gc --prune=now` e aborta merges/rebases pendentes antes do push para evitar falhas de objeto/desempacotamento. |
| | **Alerta de Arquivos Grandes** | Avisa sobre arquivos maiores que 50MB e sugere o uso do Git LFS (Large File Storage). |
| **Commit** | **Seleção de Commit Interativa** | Oferece um menu de prefixos de commit (ex: `feat`, `fix`, `chore`) seguindo o padrão Conventional Commits. |
| **Resolução de Problemas** | **Tratamento de Erros Pós-Push** | Inclui diagnóstico e soluções para falhas de push, como erros de objeto/desempacotamento e falhas de autenticação. |

---

## 🛠️ Pré-requisitos

Para executar este script, você precisa ter os seguintes utilitários instalados e acessíveis no seu PATH:

1.  **Git:** O sistema de controle de versão.
2.  **Bash:** O script é escrito em Bash.
3.  **GitHub CLI (`gh`):** Necessário para o processo de autenticação segura e obtenção do Personal Access Token (PAT).
4.  **`jq`:** Processador JSON de linha de comando, usado para analisar respostas da API do GitHub.
5.  **`curl`** e **`cmp`** (geralmente parte do `coreutils`): Para comunicação de rede e comparação de arquivos.

**Instalação (Termux/Linux):**
```bash
pkg install git curl coreutils jq gh
```

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

> **⚠️ AVISO IMPORTANTE:** O script **DEVE** ser executado dentro da pasta raiz do projeto Git que você deseja fazer o `push`.

### 3. Executar o Script

Navegue até a pasta raiz do seu projeto Git e execute o script:

```bash
bash git_push_auto.sh
```

O script irá guiá-lo passo a passo através do processo.

---

## ⚙️ Fluxo de Execução

O script segue esta sequência lógica, com intervenção do usuário em cada etapa:

1.  **Início:** Exibe a saudação e verifica as dependências (`git`, `gh`, `jq`, etc.).
2.  **Verificação de Atualização:** Checa se a versão local é a mais recente.
3.  **Autenticação:** Inicia o processo de login interativo via **GitHub CLI (`gh`)** se não estiver logado, e obtém o PAT e o nome de usuário.
4.  **Confirmação de Diretório:** Pede confirmação de que você está na pasta correta do projeto.
5.  **Inicialização:** Se a pasta não for um repositório Git, ele executa `git init`.
6.  **Configuração Remota:** Se não houver um repositório remoto configurado, ele solicita a URL ou oferece a opção de **Criar um Novo Repositório** no GitHub.
7.  **Verificações de Segurança:** Alerta sobre arquivos sensíveis, arquivos grandes e a ausência de `.gitignore`.
8.  **Tratamento de `node_modules`:** Se a pasta existir e não estiver ignorada, o script corrige automaticamente o `.gitignore`.
9.  **Limpeza Proativa do Git:** Executa `git gc --prune=now` e aborta operações pendentes.
10. **Adicionar Arquivos:** Executa `git add .` para preparar todos os arquivos.
11. **Commit:** Pede a mensagem de commit, oferecendo um menu de prefixos.
12. **Push:** Executa o `git push` usando o PAT obtido.
13. **Tratamento de Erros:** Se o push falhar, o script entra em um modo de diagnóstico interativo para tentar corrigir o problema.
14. **Limpeza Final:** Em caso de sucesso, chama a função de **Limpeza Interativa de Credenciais**.
15. **Fim:** Exibe uma mensagem de conclusão.

---

## ⚠️ Tratamento de Erros e Soluções

O script possui mecanismos robustos para lidar com falhas comuns:

### 1. Erro de Objeto/Desempacotamento (`remote unpack failed`)

Este erro geralmente indica corrupção de dados local ou problemas com arquivos muito grandes. O script agora executa uma **Limpeza Proativa do Git** (`git gc --prune=now`) antes do push. Se o erro persistir, ele oferece uma opção de **tentar novamente após uma nova limpeza**.

### 2. Erro de Autenticação (`Authentication failed`)

Se o PAT (Personal Access Token) ou o nome de usuário estiverem incorretos, o script encerra a execução, mas antes chama a **Limpeza Interativa de Credenciais** para garantir que nenhuma informação sensível permaneça na memória.

### 3. Bloqueio de Segredo (GH013)

Se o GitHub detectar uma chave de API ou outro segredo no seu histórico de commits, o script diagnostica o erro e encerra a execução com uma mensagem de erro fatal, incentivando o usuário a resolver o problema de segurança antes de tentar novamente.

---

## 👨‍💻 Autor

*   **Autor:** Paulo Hernani Costa 🍥
*   **Assistência no Desenvolvimento:** Gemini AI
*   **Instagram:** @eu_paulo_ti

## 📄 Licença

Este projeto é de código aberto. Consulte o próprio script para detalhes de licenciamento.