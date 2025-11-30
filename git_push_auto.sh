#!/data/data/com.termux/files/usr/bin/bash

# ==========================================================
# Script de Automação Git: Envio Completo Interativo V31 (FINAL)
# ==========================================================
# 🧠 AUTORIA: Paulo Hernani
# 🛠️ DESENVOLVIMENTO: Paulo Hernani com a ajuda de Gemini
# 📷 INSTAGRAM: @eu_paulo_ti
# ----------------------------------------------------------

# Definições de Cores (ANSI Escape Codes)
NC='\033[0m'       # Sem Cor
RED='\033[0;31m'   # Vermelho (Erros/Alertas de Segurança)
GREEN='\033[0;32m' # Verde (Sucesso)
YELLOW='\033[1;33m' # Amarelo (Avisos/Entradas)
BLUE='\033[0;34m'  # Azul (Processos)
CYAN='\033[0;36m'  # Ciano (Links/Informações)

# Variáveis
BRANCH_NAME="main"
LARGE_FILE_SIZE_MB=50

# VARIÁVEIS PARA ARMAZENAMENTO TEMPORÁRIO DE CREDENCIAIS
GIT_USERNAME_STORE=""
GIT_PASSWORD_STORE=""

echo -e "${YELLOW}=========================================================="
echo -e "          INÍCIO DO ENVIO SIMPLIFICADO AO GITHUB          "
echo -e "      ${CYAN}Autor: Paulo Hernani | Assistência: Gemini${NC}"
echo -e "${YELLOW}=========================================================="
echo -e "${NC}"

sleep 2

# PRÉ-VERIFICAÇÃO: Git Instalado
# ----------------------------------------------------------
echo -e "${BLUE}🔍 VERIFICANDO AMBIENTE...${NC}"
if ! command -v git &> /dev/null
then
    echo -e "${RED}❌ ERRO FATAL: O comando 'git' não foi encontrado.${NC}"
    echo -e "${RED}   O que está atrapalhando: O software Git precisa estar instalado no seu sistema para continuar.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ O Git está instalado.${NC}"

# 0. VERIFICAÇÃO DE PASTA OBRIGATÓRIA
# ----------------------------------------------------------
echo -e "\n${YELLOW}🚨 IMPORTANTE: Você deve estar DENTRO da pasta raiz do seu projeto."
echo -e "   Diretório atual: ${CYAN}$(pwd)${NC}"
echo ""
read -r -p "$(echo -e "${YELLOW}CONFIRMA que você está na pasta do projeto? (S/n): ${NC}")" CONFIRMATION

if [[ ! "$CONFIRMATION" =~ ^[Ss]$ && ! -z "$CONFIRMATION" ]]; then
    echo -e "${RED}❌ Operação cancelada. Motivo: Confirmação de diretório negada.${NC}"
    exit 1
fi
# Se CONFIRMATION for vazio, ele passa pela condição e segue.

echo -e "${GREEN}✅ Confirmação de diretório recebida. Prosseguindo...${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
sleep 2

# 1. INICIALIZAÇÃO E BRANCH (COM SOLUÇÃO DE PERMISSÃO AUTOMÁTICA)
# ----------------------------------------------------------
if [ ! -d ".git" ]; then
    echo -e "${BLUE}⚙️ Tentando inicializar repositório Git (git init)...${NC}"
    git init
    INIT_STATUS=$?

    if [ $INIT_STATUS -ne 0 ]; then
        echo -e "${RED}❌ ERRO NA INICIALIZAÇÃO (git init).${NC}"
        echo -e "${RED}   O que está atrapalhando: Problema de permissão de escrita no diretório atual.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Repositório Git inicializado.${NC}"
else
    echo -e "${YELLOW}⚠️ Git já inicializado. Pulando 'git init'.${NC}"
fi

# Tenta definir a branch principal. Se falhar, tenta aplicar a correção de propriedade.
echo -e "${BLUE}⚙️ Tentando definir a branch principal como '$BRANCH_NAME' (git branch -M)...${NC}"
git branch -M $BRANCH_NAME 2>/dev/null
BRANCH_STATUS=$?

if [ $BRANCH_STATUS -ne 0 ]; then
    # Verifica se o erro é o 'dubious ownership' (problema de permissão em Android/redes)
    if git status 2>&1 | grep -q "dubious ownership"; then
        CURRENT_DIR=$(pwd)
        echo -e "${RED}\n❌ ERRO DETECTADO: Dubious ownership (Problema de propriedade/permissão).${NC}"
        echo -e "${RED}   O que está atrapalhando: O Git desconfia de permissões em caminhos externos (como Termux/Android/redes).${NC}"
        echo -e "${BLUE}   APLICANDO SOLUÇÃO: Adicionando diretório atual à lista de segurança global...${NC}"
        git config --global --add safe.directory "$CURRENT_DIR"
        
        # Tenta o comando novamente
        echo -e "${BLUE}⚙️ Tentando definir a branch principal NOVAMENTE...${NC}"
        git branch -M $BRANCH_NAME
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ ERRO FATAL: Falha ao definir a branch mesmo após a correção de permissão. O script será encerrado.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Branch definida com sucesso após correção de propriedade.${NC}"
    else
        echo -e "${RED}❌ ERRO FATAL ao definir a branch principal.${NC}"
        echo -e "${RED}   O que está atrapalhando: Algum problema interno do Git não reconhecido. Tente rodar 'git status' manualmente.${NC}"
        exit 1
    fi
fi

# Se não houve erro de branch, ou se foi corrigido
echo -e "${GREEN}✅ Branch principal definida como '$BRANCH_NAME'.${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
sleep 2

### BLOCO DE VERIFICAÇÕES DE SEGURANÇA E EFICIÊNCIA ###
# ----------------------------------------------------------
echo -e "${BLUE}🔍 EXECUTANDO VERIFICAÇÕES DE SEGURANÇA E EFICIÊNCIA...${NC}"
sleep 1

# Check 1: Arquivos Potencialmente Sensíveis (Comprometedor)
SENSITIVE_FILES=$(git ls-files -o --exclude-standard | grep -E "\.(env|key|pem)$|^credentials\." | sed 's/^/  - /')
SECURITY_ISSUE=0

if [ -n "$SENSITIVE_FILES" ]; then
    SECURITY_ISSUE=1
    echo -e "${RED}\n🚨 ALERTA DE SEGURANÇA: Arquivos potencialmente COMPROMETEDORES detectados!${NC}"
    echo -e "${RED}   O que está atrapalhando: Credenciais (chaves privadas, tokens) que seriam enviadas publicamente.${NC}"
    echo -e "   Arquivos encontrados:\n${CYAN}${SENSITIVE_FILES}${NC}"

    # Permite que Enter continue (Ignorar)
    read -p "$(echo -e "${RED}Ação necessária:${NC} Deseja ${YELLOW}CONTINUAR (Enter/I)${NC} (ignorando o aviso) ou ${RED}INTERROMPER (N/n)${NC} para revisar .gitignore? ${NC}")" SECURITY_CONFIRMATION

    if [[ "$SECURITY_CONFIRMATION" =~ ^[Nn]$ ]]; then
        echo -e "${RED}❌ Operação cancelada por motivo de segurança. Revise seu .gitignore.${NC}"
        exit 1
    elif [ -z "$SECURITY_CONFIRMATION" ]; then
        echo -e "${YELLOW}⚠️ Nenhuma opção selecionada. Assumindo 'Continuar/Ignorar'. Prossiga com cautela!${NC}"
    else
        # Se digitar 'I', 'i' ou qualquer outra coisa que não seja 'N' ou vazio, ele prossegue
        echo -e "${YELLOW}⚠️ Aviso de segurança ignorado. Prossiga com cautela!${NC}"
    fi
fi

# Check 2: Arquivos Muito Grandes (Atrapalhando) - 50 MB como threshold
LARGE_FILES=$(find . -type f -size +${LARGE_FILE_SIZE_MB}M -print -exec du -h {} + 2>/dev/null | grep -E "\.${LARGE_FILE_SIZE_MB}M" | awk '{print $2 " (" $1 ")"}' | head -n 3)

if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}\n⚠️ ALERTA DE EFICIÊNCIA: Arquivos muito grandes (>${LARGE_FILE_SIZE_MB}MB) detectados!${NC}"
    echo -e "   O que está atrapalhando: Arquivos binários grandes que degradam a performance do seu repositório Git.${NC}"
    echo -e "   Sugestão: Use o ${CYAN}Git LFS (Large File Storage)${NC}."
    echo -e "   Arquivos encontrados (Top 3):\n${CYAN}${LARGE_FILES}${NC}"
fi

# Check 3: Arquivo .gitignore ausente (Prática recomendada)
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}\n💡 SUGESTÃO: Arquivo '.gitignore' não encontrado.${NC}"
    echo -e "   O que está atrapalhando: Nada impede o push, mas arquivos temporários (ex: node_modules) podem ser enviados, inchando o repositório.${NC}"
fi

echo -e "${GREEN}\n✅ Verificações de segurança e eficiência concluídas.${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
sleep 2

# 2. ADICIONAR ARQUIVOS E CRIAR COMMIT (COM OPÇÕES)
# ----------------------------------------------------------

# --- BLOCO DE VERIFICAÇÃO DE NODE_MODULES ---
if [ -d "node_modules" ]; then
    if ! grep -q "node_modules" .gitignore 2>/dev/null; then
        echo -e "\n${RED}🚨 ALERTA: Pasta 'node_modules' detectada e NÃO está sendo ignorada!${NC}"
        echo -e "${YELLOW}O que está atrapalhando: Esta pasta pode causar o erro de Objeto/Desempacotamento que você encontrou, além de inchar seu repositório.${NC}"
        
        read -r -p "$(echo -e "${YELLOW}Deseja adicionar 'node_modules/' ao seu .gitignore AGORA? (S/n) [S por padrão]: ${NC}")" ADD_NODE_MODULES
        ADD_NODE_MODULES=${ADD_NODE_MODULES:-S}

        if [[ "$ADD_NODE_MODULES" =~ ^[Ss]$ ]]; then
            # Cria .gitignore se não existir, ou adiciona ao final
            if [ ! -f ".gitignore" ]; then
                echo -e "${BLUE}⚙️ Criando .gitignore...${NC}"
            fi
            echo -e "\n# Diretórios gerados automaticamente, geralmente grandes" >> .gitignore
            echo "node_modules/" >> .gitignore
            echo -e "${GREEN}✅ 'node_modules/' adicionado ao .gitignore.${NC}"
            
            # Remove a pasta do rastreamento se já estiver no index
            echo -e "${BLUE}⚙️ Revertendo quaisquer rastreamentos anteriores da pasta...${NC}"
            git rm -r --cached node_modules 2>/dev/null
            echo -e "${GREEN}✅ Pronta para o commit sem node_modules.${NC}"
        else
            echo -e "${YELLOW}⚠️ Você optou por NÃO ignorar 'node_modules'. Se o erro de Objeto/Desempacotamento persistir, adicione-a manualmente.${NC}"
        fi
    else
        echo -e "${GREEN}✅ Pasta 'node_modules' detectada, mas JÁ está sendo ignorada (OK).${NC}"
    fi
    echo -e "${YELLOW}----------------------------------------------------------${NC}"
fi
# --- FIM DO BLOCO ---


echo -e "${BLUE}⏳ Aguardando sua ação para continuar...${NC}"
sleep 1
read -p "$(echo -e "${YELLOW}✅ Pressione [Enter] para adicionar todos os arquivos do projeto (git add .)...${NC}")"
git add .
echo -e "${GREEN}✅ Todos os arquivos prontos para o commit.${NC}"

# Verifica se há algo para commitar antes de pedir a mensagem
if git status --porcelain | grep -q '^\(M\|A\|D\|R\|C\|U\|\?\?\)' ; then
    echo -e "\n${YELLOW}📝 SELEÇÃO DA MENSAGEM DO COMMIT (Pressione o número ou [Enter] para customizar):${NC}"
    
    # Define as opções do menu
    COMMIT_OPTIONS=("feat: Nova Funcionalidade" "fix: Correção de Bug" "chore: Tarefa de Rotina/Build" "refactor: Melhoria de Código (sem mudança funcional)" "docs: Atualização de Documentação" "custom: Escrever Mensagem Completa")

    # Menu de seleção
    select COMMIT_TYPE_CHOICE in "${COMMIT_OPTIONS[@]}"; do
        case "$COMMIT_TYPE_CHOICE" in
            "feat: Nova Funcionalidade") 
                COMMIT_PREFIX="feat"
                break
                ;;
            "fix: Correção de Bug") 
                COMMIT_PREFIX="fix"
                break
                ;;
            "chore: Tarefa de Rotina/Build") 
                COMMIT_PREFIX="chore"
                break
                ;;
            "refactor: Melhoria de Código (sem mudança funcional)") 
                COMMIT_PREFIX="refactor"
                break
                ;;
            "docs: Atualização de Documentação") 
                COMMIT_PREFIX="docs"
                break
                ;;
            "custom: Escrever Mensagem Completa")
                COMMIT_PREFIX=""
                break
                ;;
            *)
                # Caso o usuário pressione Enter sem selecionar uma opção válida
                COMMIT_PREFIX=""
                break
                ;;
        esac
    done

    # Coleta a descrição ou a mensagem customizada
    if [ -n "$COMMIT_PREFIX" ]; then
        # Opção baseada em prefixo
        while true; do
            read -r -p "$(echo -e "${YELLOW}➡️ Digite a descrição detalhada (ex: Adicionada validação de formulário): ${NC}")" COMMIT_DESCRIPTION
            if [[ -n "$COMMIT_DESCRIPTION" ]]; then
                COMMIT_MESSAGE="$COMMIT_PREFIX: $COMMIT_DESCRIPTION"
                break
            else
                echo -e "${RED}🚨 A descrição não pode ser vazia.${NC}"
            fi
        done
    else
        # Opção Customizada
        while true; do
            read -r -p "$(echo -e "${YELLOW}➡️ Digite a MENSAGEM DO COMMIT completa: ${NC}")" COMMIT_MESSAGE
            if [[ -n "$COMMIT_MESSAGE" ]]; then
                break
            else
                echo -e "${RED}🚨 A mensagem não pode ser vazia.${NC}"
            fi
        done
    fi

    echo -e "${BLUE}⚙️ Executando commit com mensagem: ${CYAN}${COMMIT_MESSAGE}${NC}"
    git commit -m "$COMMIT_MESSAGE"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro ao criar o commit. O script será encerrado.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Commit criado com sucesso.${NC}"
else
    echo -e "${YELLOW}⚠️ Não há novas alterações para commitar. Pulando o commit.${NC}"
fi
echo -e "${YELLOW}----------------------------------------------------------${NC}"
sleep 2

# 3. CONFIGURAR O REPOSITÓRIO REMOTO (URL)
# ----------------------------------------------------------
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo -e "${CYAN}📌 PASSO MANUAL NECESSÁRIO:${NC}"
    echo -e "   1. Vá ao GitHub e crie um repositório NOVO e VAZIO."
    echo -e "   2. COPIE a URL HTTPS fornecida por eles."
    echo ""
    while true; do
        read -r -p "$(echo -e "${CYAN}🔗 COLE A URL HTTPS DO SEU REPOSITÓRIO NO GITHUB AQUI: ${NC}")" NEW_REPO_URL
        if [[ "$NEW_REPO_URL" =~ ^https://github.com/.*\.git$ ]]; then
            REMOTE_URL=$NEW_REPO_URL
            break
        else
            echo -e "${RED}🚨 URL inválida. O link deve ser HTTPS e terminar em .git.${NC}"
        fi
    done

    echo -e "${BLUE}⏳ Aguardando sua ação para conectar ao remoto...${NC}"
    sleep 1
    read -p "$(echo -e "${YELLOW}✅ Pressione [Enter] para conectar seu repositório local ao remoto...${NC}")"
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}✅ Repositório remoto configurado.${NC}"
else
    # --- BLOCO DE INTERAÇÃO PARA MUDAR URL ---
    echo -e "${YELLOW}⚠️ O repositório remoto (Origin) já está configurado com a URL:${NC}"
    echo -e "   ${CYAN}$REMOTE_URL${NC}"

    while true; do
        read -r -p "$(echo -e "${YELLOW}Deseja [C]ontinuar com esta URL ou [M]udar o link do repositório? (C/m): ${NC}")" CHANGE_REMOTE_CHOICE
        CHANGE_REMOTE_CHOICE=${CHANGE_REMOTE_CHOICE:-C} # Default to Continue

        if [[ "$CHANGE_REMOTE_CHOICE" =~ ^[Cc]$ ]]; then
            echo -e "${GREEN}✅ Mantendo a URL existente. Prosseguindo...${NC}"
            break
        elif [[ "$CHANGE_REMOTE_CHOICE" =~ ^[Mm]$ ]]; then
            echo -e "\n${CYAN}📌 PROCESSO DE MUDANÇA DE LINK:${NC}"
            while true; do
                read -r -p "$(echo -e "${CYAN}🔗 COLE A NOVA URL HTTPS DO SEU REPOSITÓRIO NO GITHUB AQUI: ${NC}")" NEW_REPO_URL
                if [[ "$NEW_REPO_URL" =~ ^https://github.com/.*\.git$ ]]; then
                    # Atualiza a URL
                    git remote set-url origin "$NEW_REPO_URL"
                    if [ $? -eq 0 ]; then
                        REMOTE_URL="$NEW_REPO_URL"
                        echo -e "${GREEN}✅ URL do repositório remoto atualizada para: ${CYAN}$REMOTE_URL${NC}"
                        break 2 # Sai dos dois loops (da URL e da escolha)
                    else
                        echo -e "${RED}❌ ERRO ao tentar definir a nova URL. Tente novamente.${NC}"
                        # Continua o loop interno para pedir a URL novamente
                    fi
                else
                    echo -e "${RED}🚨 URL inválida. O link deve ser HTTPS e terminar em .git.${NC}"
                fi
            done
        else
            echo -e "${RED}❌ Opção inválida. Escolha 'C' para Continuar ou 'M' para Mudar.${NC}"
        fi
    done
fi
echo -e "${YELLOW}----------------------------------------------------------${NC}"
sleep 2

# 4. ENVIAR PARA O GITHUB (Push) - COM LOOP DE TENTATIVA E TRATAMENTO DE ERRO
# ----------------------------------------------------------
while true; do
    echo -e "${BLUE}🔥 Preparando para enviar o código para o GitHub...${NC}"
    echo ""
    PUSH_COMMAND=""

    # Loop interno para a escolha do método de autenticação
    if [ -z "$GIT_USERNAME_STORE" ] || [ -z "$GIT_PASSWORD_STORE" ]; then
        # SE AS CREDENCIAIS NÃO EXISTEM, PEDE AO USUÁRIO
        while true; do
            echo -e "Para o envio, você DEVE se autenticar usando um Personal Access Token (PAT):"
            echo -e "1 - Digitar as credenciais (Nome de Usuário e Token)."
            echo -e "2 - ${CYAN}AJUDA: Como obter meu Personal Access Token (PAT)?${NC}"
            read -r -p "$(echo -e "${YELLOW}Escolha a opção (1 ou 2): ${NC}")" AUTH_CHOICE
            
            if [ "$AUTH_CHOICE" == "1" ]; then
                # Método TOKEN (PAT) com input VISÍVEL
                echo -e "${RED}\n⚠️ ATENÇÃO: O token será visível enquanto você digita ou cola!${NC}"
                read -r -p "$(echo -e "${YELLOW}👤 Digite seu Nome de Usuário do GitHub: ${NC}")" GIT_USERNAME
                
                # Usando read -r -p para que o input seja visível, conforme solicitado
                read -r -p "$(echo -e "${YELLOW}🔑 Digite seu Personal Access Token (PAT): ${NC}")" GIT_PASSWORD
                echo "" 
                
                # ARMAZENA AS CREDENCIAIS TEMPORARIAMENTE
                GIT_USERNAME_STORE="$GIT_USERNAME"
                GIT_PASSWORD_STORE="$GIT_PASSWORD"
                
                PUSH_COMMAND="git push -u https://${GIT_USERNAME_STORE}:${GIT_PASSWORD_STORE}@${REMOTE_URL#https://} $BRANCH_NAME"
                echo -e "${BLUE}⚙️ PUSH configurado para usar o Token automaticamente.${NC}"
                break
                
            elif [ "$AUTH_CHOICE" == "2" ]; then
                # Opção de Ajuda (Link para o guia oficial)
                echo -e "\n${CYAN}🔗 GUIA OFICIAL DO GITHUB:${NC}"
                echo -e "   Para gerar seu PAT (Personal Access Token), siga este link:"
                echo -e "   ${CYAN}[Guia para criar um Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)${NC}"
                echo -e "   Você precisará dar, no mínimo, as permissões 'repo' e 'workflow'."
                read -p "$(echo -e "${YELLOW}Pressione [Enter] para retornar ao menu de autenticação...${NC}")"
                continue # Volta para o loop interno de escolha
                
            else
                echo -e "${RED}Opção inválida. Escolha 1 ou 2.${NC}"
            fi
        done
    else
        # SE AS CREDENCIAIS JÁ EXISTEM, REUTILIZA
        echo -e "${BLUE}⚙️ Reutilizando credenciais armazenadas para o PUSH...${NC}"
        PUSH_COMMAND="git push -u https://${GIT_USERNAME_STORE}:${GIT_PASSWORD_STORE}@${REMOTE_URL#https://} $BRANCH_NAME"
    fi

    echo -e "${BLUE}⏳ Aguardando sua ação para executar o push...${NC}"
    sleep 1
    read -p "$(echo -e "${GREEN}✅ Pressione [Enter] para executar o comando PUSH...${NC}")"
    
    # MENSAGENS DE CARREGAMENTO/PROGRESSO ADICIONADAS AQUI
    echo -e "${BLUE}📡 Iniciando o envio dos dados (git push)...${NC}"
    echo -e "${BLUE}   Isso pode levar alguns instantes, dependendo do tamanho do seu projeto e da sua conexão. ${YELLOW}Por favor, aguarde o resultado...${NC}"

    # Captura a saída do comando push
    PUSH_OUTPUT=$(eval "$PUSH_COMMAND" 2>&1)
    PUSH_EXIT_CODE=$?

    if [ $PUSH_EXIT_CODE -eq 0 ]; then
        echo ""
        echo -e "${GREEN}==========================================================${NC}"
        echo -e "${GREEN}🚀 SUCESSO! SEU PROJETO ESTÁ ONLINE NO GITHUB. 🎉${NC}"
        echo -e "${GREEN}==========================================================${NC}"
        break # Sai do loop de push, encerrando o script
    else
        
        # Exibe a saída completa do Git para referência antes de perguntar sobre a nova tentativa
        echo -e "\n${YELLOW}----------------------------------------------------------${NC}"
        echo -e "${CYAN}Saída Completa do Git (para diagnóstico):${NC}"
        echo -e "${PUSH_OUTPUT}"
        echo -e "${YELLOW}----------------------------------------------------------${NC}"

        # -----------------------------------------------------
        # Tratamento de Erro de Objeto Faltante / Remote Unpack Failed
        # -----------------------------------------------------
        if echo "$PUSH_OUTPUT" | grep -q "remote unpack failed" || echo "$PUSH_OUTPUT" | grep -q "did not receive expected object"; then
            echo -e "${RED}❌ FALHA NO PUSH: ERRO DE OBJETO / DESEMPACOTAMENTO (CORRUPÇÃO DE DADOS OU REDE).${NC}"
            echo -e "${YELLOW}O que aconteceu: Houve uma falha na transferência ou desempacotamento de dados (objetos Git). Isso é comum em caso de corrupção de dados local ou problemas de rede/arquivos muito grandes.${NC}"
            
            while true; do
                echo -e "\n${YELLOW}ESCOLHA A AÇÃO RECOMENDADA PARA RESOLVER:${NC}"
                echo -e "${CYAN}1) Tentar Correção Padrão (git gc):${NC} Limpa e otimiza (Compacta/Repara), mas é menos agressiva. (Recomendado se o erro for leve)."
                echo -e "${GREEN}2) Tentar Correção Agressiva (Recriação de Pacotes):${NC} Remove e recria todos os arquivos de objeto. A solução manual que deu certo para você. (Recomendado se a Opção 1 falhar)."
                echo -e "${RED}3) Tentar PUSH FORÇADO (--force):${NC} Sobrescreve o histórico remoto. ${RED}Alto Risco!${NC} (Use APENAS como último recurso)."
                echo -e "${YELLOW}4) Tentar Novamente o PUSH (para problemas de rede temporários).${NC}"
                echo -e "5) Sair para diagnóstico manual."
                
                read -r -p "$(echo -e "${YELLOW}Escolha a opção (1, 2, 3, 4 ou 5) [1 por padrão]: ${NC}")" OBJECT_ERROR_CHOICE
                OBJECT_ERROR_CHOICE=${OBJECT_ERROR_CHOICE:-1} 
                
                if [ "$OBJECT_ERROR_CHOICE" == "1" ]; then
                    echo -e "\n${BLUE}⚙️ Executando 'git gc --prune=now' para limpar e otimizar o repositório local...${NC}"
                    git gc --prune=now
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✅ Limpeza padrão concluída. Retornando para nova tentativa de PUSH...${NC}"
                        break # Saia do loop de opções de correção e volte ao loop de push principal
                    else
                        echo -e "${RED}❌ ERRO ao executar 'git gc'. Tente a Opção 2 ou Sair.${NC}"
                        continue # Volta para o menu de escolha (1, 2, 3, 4, 5)
                    fi
                elif [ "$OBJECT_ERROR_CHOICE" == "2" ]; then
                    # --- NOVO BLOCO DE CORREÇÃO AGRESSIVA (SUA SOLUÇÃO) ---
                    echo -e "\n${BLUE}⚙️ Executando Correção Agressiva (Recriação de Pacotes)...${NC}"
                    echo -e "${BLUE}   1. Removendo pacotes de objeto corrompidos (.git/objects/pack)...${NC}"
                    rm -rf .git/objects/pack/*
                    echo -e "${BLUE}   2. Forçando a recriação de novos pacotes (git repack -a -d)...${NC}"
                    git repack -a -d
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✅ Recriação concluída. Retornando para nova tentativa de PUSH...${NC}"
                        break # Saia do loop de opções de correção e volte ao loop de push principal
                    else
                        echo -e "${RED}❌ ERRO ao executar 'git repack'. Tente a Opção 3 ou Sair.${NC}"
                        continue # Volta para o menu de escolha
                    fi
                    # -----------------------------------------------------

                elif [ "$OBJECT_ERROR_CHOICE" == "3" ]; then
                    echo -e "${RED}\n🚨 ATENÇÃO: PUSH FORÇADO (--force) SELECIONADO!${NC}"
                    echo -e "   Esta operação pode apagar commits remotos. Use com extrema cautela."
                    read -r -p "$(echo -e "${RED}CONFIRMA o PUSH FORÇADO? Digite 'SIM' em caixa alta para prosseguir e encerrar o script com a instrução: ${NC}")" FORCE_CONFIRMATION
                    
                    if [ "$FORCE_CONFIRMATION" == "SIM" ]; then
                        echo -e "\n${BLUE}PASSO MANUAL PARA PUSH FORÇADO:${NC}"
                        echo -e "   1. Execute o comando abaixo no seu terminal (você terá que autenticar novamente com seu PAT):"
                        echo -e "      ${CYAN}git push --force origin $BRANCH_NAME${NC}"
                        echo -e "${RED}❌ Operação encerrada para intervenção manual (Push Forçado).${NC}"
                        exit 1
                    else
                        echo -e "${YELLOW}❌ Push forçado não confirmado. Retornando ao menu de opções de correção.${NC}"
                        continue # Volta para o menu de escolha (1, 2, 3, 4, 5)
                    fi

                elif [ "$OBJECT_ERROR_CHOICE" == "4" ]; then
                    echo -e "${BLUE}Retornando para nova tentativa de PUSH...${NC}"
                    break # Saia do loop de opções de correção e volte ao loop de push principal
                
                elif [ "$OBJECT_ERROR_CHOICE" == "5" ]; then
                    echo -e "${RED}❌ Operação cancelada. O script será encerrado para diagnóstico manual.${NC}"
                    exit 1
                else
                    echo -e "${RED}❌ Opção inválida ('$OBJECT_ERROR_CHOICE'). Escolha apenas 1, 2, 3, 4 ou 5.${NC}"
                fi
            done
            
        # -----------------------------------------------------
        # Tratamento de Erro de Autenticação (Token Inválido)
        # -----------------------------------------------------
        elif echo "$PUSH_OUTPUT" | grep -q "fatal: Authentication failed" || echo "$PUSH_OUTPUT" | grep -q "Invalid username or token"; then
            echo -e "${RED}❌ FALHA NO PUSH: ERRO DE AUTENTICAÇÃO (TOKEN INVÁLIDO).${NC}"
            echo -e "${RED}O que aconteceu: O GitHub rejeitou o envio. O ${CYAN}Nome de Usuário${NC} ou o ${CYAN}Personal Access Token (PAT)${NC} está INCORRETO, ou o Token expirou.${NC}"
            
            # Limpa as credenciais salvas para forçar a redigitação
            GIT_USERNAME_STORE=""
            GIT_PASSWORD_STORE=""
            
            while true; do
                read -r -p "$(echo -e "${YELLOW}Deseja TENTAR NOVAMENTE as credenciais? (S/n) [S por padrão]: ${NC}")" RETRY_AUTH
                RETRY_AUTH=${RETRY_AUTH:-S} # Define 'S' como padrão se Enter for pressionado.
                
                if [[ "$RETRY_AUTH" =~ ^[Ss]$ ]]; then
                    echo -e "${BLUE}As credenciais foram limpas. Retornando para pedir a autenticação novamente...${NC}"
                    break 2 # Volta para o loop principal (push)
                elif [[ "$RETRY_AUTH" =~ ^[Nn]$ ]]; then
                    echo -e "${RED}❌ Operação cancelada pelo usuário.${NC}"
                    exit 1
                else
                    echo -e "${RED}❌ Opção inválida. Escolha 'S' ou 'n'.${NC}"
                fi
            done
            
        # -----------------------------------------------------
        # Tratamento de Erro de Push Protection (GH013)
        # -----------------------------------------------------
        elif echo "$PUSH_OUTPUT" | grep -q "GH013: Repository rule violations found"; then
            echo -e "${RED}❌ FALHA NO PUSH: REJEITADO POR CONTER SEGREDO (GH013).${NC}"
            echo -e "${YELLOW}O GitHub detectou uma Chave de API em seu histórico de commits, o que impediu o envio.${NC}"
            
            # Tenta extrair o BLOB_ID
            BLOB_ID=$(echo "$PUSH_OUTPUT" | grep 'blob id:' | awk '{print $4}' | head -n 1)
            BLOB_FILENAME=""

            if [ -n "$BLOB_ID" ]; then
                # Executa o comando de diagnóstico para descobrir o nome do arquivo
                DIAGNOSTIC_OUTPUT=$(git rev-list --objects --all 2>/dev/null | grep "$BLOB_ID")
                BLOB_FILENAME=$(echo "$DIAGNOSTIC_OUTPUT" | awk '{print $2}' | head -n 1)
            fi
            
            # APRESENTAÇÃO DO DIAGNÓSTICO (IMEDIATO)
            if [ -n "$BLOB_FILENAME" ]; then
                echo -e "\n${BLUE}🔎 DIAGNÓSTICO AUTOMÁTICO: O segredo foi encontrado no arquivo:${NC}"
                echo -e "   ${RED}>> ${CYAN}$BLOB_FILENAME${NC}"
                echo -e "   (Blob ID: ${CYAN}$BLOB_ID${NC})"
            elif [ -n "$BLOB_ID" ]; then
                echo -e "\n${BLUE}🔎 DIAGNÓSTICO: O segredo foi encontrado no histórico de commits (Blob ID: ${CYAN}$BLOB_ID${BLUE}).${NC}"
                echo -e "   ⚠️ Não foi possível determinar o nome do arquivo automaticamente. Tente o comando manual em outro terminal:"
                echo -e "   ${CYAN}git rev-list --objects --all | grep $BLOB_ID${NC}"
            else
                echo -e "\n${BLUE}🔎 DIAGNÓSTICO: Não foi possível extrair o Blob ID para identificar o arquivo.${NC}"
            fi

            # Loop para a escolha de ação (1, 2 ou 3)
            while true; do
                
                # Tenta extrair a URL de desbloqueio da saída
                UNBLOCK_URL=$(echo "$PUSH_OUTPUT" | grep -o 'https://github.com/[^ ]*/unblock-secret/[^ ]*' | head -n 1)
                
                echo -e "\n${YELLOW}ESCOLHA A AÇÃO PARA RESOLVER O BLOQUEIO DE SEGURANÇA:${NC}"
                echo -e "${CYAN}1) AUTORIZAR TEMPORARIAMENTE (Mais rápido, mas o segredo continua no histórico).${NC}"
                echo -e "${RED}2) REMOVER PERMANENTEMENTE (Mais seguro, exige reescrita do histórico e ${CYAN}git filter-repo${NC}).${NC}"
                echo -e "${YELLOW}3) CORRIGIR MANUALMENTE (Apagar o arquivo/dado, fazer novo commit e TENTAR NOVAMENTE).${NC}"
                
                read -r -p "$(echo -e "${YELLOW}Escolha a opção (1, 2 ou 3): ${NC}")" SECRET_CHOICE
                
                if [ "$SECRET_CHOICE" == "1" ]; then
                    echo -e "\n${GREEN}✅ AÇÃO ESCOLHIDA: AUTORIZAR TEMPORARIAMENTE${NC}"
                    
                    if [ -n "$UNBLOCK_URL" ]; then
                        echo -e "  1. Copie e cole este link em seu navegador para autorizar a exposição da chave APENAS para este push:"
                        echo -e "     ${CYAN}$UNBLOCK_URL${NC}"
                    else
                        echo -e "  1. Copie o link de desbloqueio que apareceu na mensagem de erro (o que começa com 'https://github.com/.../unblock-secret/...')."
                    fi
                    echo -e "  2. Após autorizar no navegador, **rode o comando 'git push' manualmente** no seu terminal para finalizar o envio."
                    exit 1 # Encerra para a intervenção manual
                    
                elif [ "$SECRET_CHOICE" == "2" ]; then
                    # Ação de remoção permanente - script encerra e guia o usuário
                    echo -e "\n${RED}⚠️ AÇÃO ESCOLHIDA: REMOVER PERMANENTEMENTE${NC}"
                    echo -e "   O script será encerrado. Siga os passos abaixo, e depois execute o script novamente:"
                    
                    echo -e "\n${BLUE}PASSO DE LIMPEZA: Instalar e rodar a ferramenta de limpeza (Substitua NOME_DO_ARQUIVO_SECRETO):${NC}"
                    echo -e "   1. Instale o ${CYAN}git filter-repo${NC} (via pip, brew ou apt)."
                    echo -e "   2. Execute o comando de limpeza (Use o nome do arquivo que apareceu no diagnóstico ou o que você descobriu manualmente):"
                    echo -e "      ${CYAN}git filter-repo --forget-paths NOME_DO_ARQUIVO_SECRETO --force${NC}"
                    echo -e "   3. Depois, você precisará forçar o envio da história limpa: ${CYAN}git push --force origin $BRANCH_NAME${NC}"

                    exit 1 # Encerra para a intervenção manual
                
                elif [ "$SECRET_CHOICE" == "3" ]; then
                    echo -e "\n${YELLOW}⚠️ AÇÃO ESCOLHIDA: CORREÇÃO MANUAL E NOVA TENTATIVA${NC}"
                    
                    if [ -n "$BLOB_FILENAME" ]; then
                        echo -e "   1. Por favor, abra outro terminal e ${RED}remova${NC} ou ${RED}edite${NC} o arquivo sensível: ${CYAN}$BLOB_FILENAME${NC}"
                    else
                        echo -e "   1. Por favor, use o comando de diagnóstico acima para encontrar o arquivo e, em seguida, ${RED}remova${NC} ou ${RED}edite${NC} o dado sensível."
                    fi
                    
                    echo -e "   2. Em seguida, rode: ${CYAN}git add . && git commit -m 'Remoção de segredo'${NC}"
                    echo -e "   🚨 ATENÇÃO: Se o segredo estiver em commits antigos, apenas a Opção 2 irá funcionar permanentemente. Sua nova tentativa pode falhar novamente."
                    
                    # INÍCIO DA CORREÇÃO 
                    while true; do
                        read -r -p "$(echo -e "${YELLOW}Você já realizou a correção manual? Deseja TENTAR O PUSH NOVAMENTE? (S/n) [S por padrão]: ${NC}")" RETRY_PUSH
                        RETRY_PUSH=${RETRY_PUSH:-S} # Define 'S' como padrão se Enter for pressionado.
                        
                        if [[ "$RETRY_PUSH" =~ ^[Ss]$ ]]; then
                            echo -e "${BLUE}Retornando para nova tentativa de PUSH...${NC}"
                            break 2 # Sai do loop interno e continua o loop de PUSH
                        elif [[ "$RETRY_PUSH" =~ ^[Nn]$ ]]; then
                            echo -e "${RED}❌ Operação cancelada. O script será encerrado para que você possa completar a correção.${NC}"
                            exit 1
                        else
                            echo -e "${RED}❌ Opção inválida. Escolha 'S' ou 'n'.${NC}"
                        fi
                    done
                    # FIM DA CORREÇÃO
                else
                    echo -e "${RED}❌ Opção inválida ('$SECRET_CHOICE'). Escolha apenas 1, 2 ou 3.${NC}"
                    # Volta ao início do loop para pedir a opção novamente.
                fi
            done
            
        # -----------------------------------------------------
        # Tratamento de Erro de Autenticação (Token Inválido)
        # -----------------------------------------------------
        elif echo "$PUSH_OUTPUT" | grep -q "fatal: Authentication failed" || echo "$PUSH_OUTPUT" | grep -q "Invalid username or token"; then
            echo -e "${RED}❌ FALHA NO PUSH: ERRO DE AUTENTICAÇÃO (TOKEN INVÁLIDO).${NC}"
            echo -e "${RED}O que aconteceu: O GitHub rejeitou o envio. O ${CYAN}Nome de Usuário${NC} ou o ${CYAN}Personal Access Token (PAT)${NC} está INCORRETO, ou o Token expirou.${NC}"
            
            # Limpa as credenciais salvas para forçar a redigitação
            GIT_USERNAME_STORE=""
            GIT_PASSWORD_STORE=""
            
            while true; do
                read -r -p "$(echo -e "${YELLOW}Deseja TENTAR NOVAMENTE as credenciais? (S/n) [S por padrão]: ${NC}")" RETRY_AUTH
                RETRY_AUTH=${RETRY_AUTH:-S} # Define 'S' como padrão se Enter for pressionado.
                
                if [[ "$RETRY_AUTH" =~ ^[Ss]$ ]]; then
                    echo -e "${BLUE}As credenciais foram limpas. Retornando para pedir a autenticação novamente...${NC}"
                    break 2 # Volta para o loop principal (push)
                elif [[ "$RETRY_AUTH" =~ ^[Nn]$ ]]; then
                    echo -e "${RED}❌ Operação cancelada pelo usuário.${NC}"
                    exit 1
                else
                    echo -e "${RED}❌ Opção inválida. Escolha 'S' ou 'n'.${NC}"
                fi
            done
            
        # -----------------------------------------------------
        # Falha genérica (Loop)
        # -----------------------------------------------------
        else
            echo -e "${RED}❌ FALHA NO PUSH! Erro genérico do Git. ${NC}"
            echo -e "${CYAN}Ação Necessária: ${NC}Verifique a seção de diagnóstico acima (Saída Completa do Git) para mais detalhes."
            
            while true; do
                read -r -p "$(echo -e "${YELLOW}Deseja TENTAR NOVAMENTE a autenticação? (S/n) [S por padrão]: ${NC}")" RETRY_GENERIC
                RETRY_GENERIC=${RETRY_GENERIC:-S} # Define 'S' como padrão se Enter for pressionado.
                
                if [[ "$RETRY_GENERIC" =~ ^[Ss]$ ]]; then
                    echo -e "${BLUE}Retornando para nova tentativa de PUSH...${NC}"
                    break 2 # Volta para o início do loop (while true)
                elif [[ "$RETRY_GENERIC" =~ ^[Nn]$ ]]; then
                    echo -e "${RED}❌ Operação cancelada pelo usuário.${NC}"
                    exit 1
                else
                    echo -e "${RED}❌ Opção inválida. Escolha 'S' ou 'n'.${NC}"
                fi
            done
        fi
    fi
done

# ==========================================================
# CRÉDITOS FINAIS
# ==========================================================
echo -e "\n${YELLOW}=========================================================="
echo -e "         FIM DO PROCESSO GIT INTERATIVO (V31)         "
echo -e "=========================================================="
echo -e "${GREEN}✅ AUTOR: Paulo Hernani${NC}"
echo -e "${GREEN}🤝 ASSISTÊNCIA NO SCRIPT: Gemini${NC}"
echo -e "${CYAN}📷 Siga no Instagram: @eu_paulo_ti${NC}"
echo -e "${YELLOW}==========================================================${NC}"

exit 0