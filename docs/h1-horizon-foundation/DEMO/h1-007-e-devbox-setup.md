# 💻 H1-007-E: Guia Completo de Configuração do DevBox

## 📋 Índice

1. [🎯 Visão Geral](#visao-geral)
2. [🏗️ Arquitetura do DevBox](#arquitetura-devbox)
3. [📦 Criação da Imagem Base](#criacao-imagem)
4. [🔧 Configuração do VS Code](#configuracao-vscode)
5. [🚀 Provisionamento Automatizado](#provisionamento-automatizado)
6. [🛠️ Ferramentas e SDKs](#ferramentas-sdks)
7. [🔐 Segurança e Acesso](#seguranca-acesso)
8. [📊 Integração com Developer Hub](#integracao-hub)
9. [🧪 Validação e Testes](#validacao-testes)
10. [📚 Documentação para Desenvolvedores](#documentacao-devs)

## 🎯 Visão Geral {#visao-geral}

O DevBox é um ambiente de desenvolvimento padronizado na nuvem que garante que todos os desenvolvedores tenham as mesmas ferramentas, configurações e acesso aos recursos necessários.

### 🌟 Benefícios do DevBox

- **Consistência**: Mesmo ambiente para todos os desenvolvedores
- **Velocidade**: Novo desenvolvedor produtivo em < 30 minutos
- **Segurança**: Código e dados permanecem na nuvem
- **Escalabilidade**: Recursos ajustáveis conforme necessidade
- **Colaboração**: Compartilhamento fácil de ambientes

### 📊 Componentes

- **Azure Dev Box**: Estações de trabalho Windows na nuvem
- **GitHub Codespaces**: Ambientes Linux para desenvolvimento
- **VS Code Server**: IDE acessível via browser
- **Docker-in-Docker**: Desenvolvimento containerizado

## 🏗️ Arquitetura do DevBox {#arquitetura-devbox}

### Diagrama de Arquitetura

```mermaid
graph TB
    subgraph "Developer Access"
        Browser[🌐 Web Browser]
        VSCode[💻 VS Code Desktop]
        CLI[🖥️ Terminal/CLI]
    end
    
    subgraph "DevBox Infrastructure"
        DevBoxSvc[Azure Dev Box Service]
        Codespaces[GitHub Codespaces]
        
        subgraph "DevBox Instance"
            OS[Windows 11 / Ubuntu 22.04]
            Tools[Development Tools]
            Docker[Docker Engine]
            SDKs[Language SDKs]
        end
    end
    
    subgraph "Connected Services"
        AKS[AKS Cluster]
        ACR[Container Registry]
        KeyVault[Key Vault]
        GitHub[GitHub Repos]
    end
    
    Browser --> DevBoxSvc
    VSCode --> Codespaces
    CLI --> DevBoxSvc
    
    DevBox Instance --> GitHub
    DevBox Instance --> AKS
    DevBox Instance --> ACR
    DevBox Instance --> KeyVault
```

## 📦 Criação da Imagem Base {#criacao-imagem}

### Dockerfile para DevBox Linux

```dockerfile
# devbox/Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Metadados
LABEL maintainer="Three Horizons Platform Team"
LABEL description="Three Horizons DevBox - Complete Development Environment"

# Argumentos de build
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Criar usuário não-root
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Instalar ferramentas base
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        # Utilities
        curl wget git vim nano htop \
        build-essential pkg-config \
        zip unzip gnupg lsb-release \
        ca-certificates apt-transport-https \
        software-properties-common \
        # Network tools
        net-tools iputils-ping dnsutils \
        # Development
        jq yq httpie bat exa fd-find ripgrep \
        tmux zsh fish neovim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Docker
RUN curl -fsSL https://get.docker.com | sh \
    && usermod -aG docker $USERNAME

# Instalar Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Instalar GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Instalar Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Instalar Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt update && apt install terraform

# Node.js e npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn pnpm typescript @nestjs/cli @angular/cli next create-react-app

# Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz \
    && rm go1.21.5.linux-amd64.tar.gz

# Python
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    && pip3 install --upgrade pip \
    && pip3 install poetry pipenv black flake8 pytest django flask fastapi

# Java
RUN apt-get install -y openjdk-17-jdk maven gradle

# .NET
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Configurar ambiente
ENV PATH="/usr/local/go/bin:/home/${USERNAME}/.cargo/bin:${PATH}"
ENV GOPATH="/home/${USERNAME}/go"

# Instalar extensões globais do VS Code Server
RUN code-server --install-extension ms-vscode.vscode-typescript-next \
    --install-extension ms-python.python \
    --install-extension golang.go \
    --install-extension ms-dotnettools.csharp \
    --install-extension rust-lang.rust-analyzer \
    --install-extension ms-azuretools.vscode-docker \
    --install-extension ms-kubernetes-tools.vscode-kubernetes-tools \
    --install-extension github.copilot \
    --install-extension github.copilot-chat \
    --install-extension redhat.vscode-yaml \
    --install-extension hashicorp.terraform \
    --install-extension ms-vscode.azure-account \
    --install-extension github.vscode-pull-request-github

# Copiar scripts de configuração
COPY scripts/setup-devbox.sh /usr/local/bin/
COPY scripts/configure-git.sh /usr/local/bin/
COPY scripts/setup-cloud-access.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Configurar shell padrão
USER $USERNAME
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copiar configurações dotfiles
COPY --chown=$USERNAME:$USERNAME dotfiles/.zshrc /home/$USERNAME/
COPY --chown=$USERNAME:$USERNAME dotfiles/.gitconfig /home/$USERNAME/
COPY --chown=$USERNAME:$USERNAME dotfiles/.tmux.conf /home/$USERNAME/

# Volume para código
VOLUME /workspace

# Diretório de trabalho
WORKDIR /workspace

# Entrypoint
ENTRYPOINT ["/usr/local/bin/setup-devbox.sh"]
CMD ["zsh"]
```

### Script de Setup

```bash
#!/bin/bash
# scripts/setup-devbox.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up Three Horizons DevBox...${NC}"

# Configurar Git
if [ -f /usr/local/bin/configure-git.sh ]; then
    /usr/local/bin/configure-git.sh
fi

# Configurar acesso cloud
if [ -f /usr/local/bin/setup-cloud-access.sh ]; then
    /usr/local/bin/setup-cloud-access.sh
fi

# Clonar repositórios principais
if [ ! -d "/workspace/Three-Horizons-AI-Developer-Platform" ]; then
    echo -e "${BLUE}📁 Cloning main repository...${NC}"
    git clone https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform.git /workspace/Three-Horizons-AI-Developer-Platform
fi

# Instalar dependências do projeto
if [ -d "/workspace/Three-Horizons-AI-Developer-Platform" ]; then
    cd /workspace/Three-Horizons-AI-Developer-Platform
    if [ -f "package.json" ]; then
        echo -e "${BLUE}📦 Installing dependencies...${NC}"
        npm install
    fi
fi

# Configurar kubectl
if command -v kubectl &> /dev/null; then
    echo -e "${BLUE}☸️ Configuring kubectl...${NC}"
    mkdir -p ~/.kube
    # Context será configurado via Azure CLI ou montagem de volume
fi

# Mensagem de boas-vindas
cat << 'EOF'

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🎉 Three Horizons DevBox Ready!                          ║
║                                                              ║
║    Your development environment is configured with:          ║
║    • All required SDKs and tools                           ║
║    • Cloud access configured                                ║
║    • VS Code extensions installed                           ║
║    • Git configured                                         ║
║                                                              ║
║    Happy coding! 🚀                                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF

echo -e "${GREEN}✅ DevBox setup complete!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "  1. Run 'az login' to authenticate with Azure"
echo -e "  2. Run 'gh auth login' to authenticate with GitHub"
echo -e "  3. Start coding!"

# Manter container rodando
exec "$@"
```

## 🔧 Configuração do VS Code {#configuracao-vscode}

### devcontainer.json

```json
{
  "name": "Three Horizons DevBox",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".",
    "args": {
      "USERNAME": "developer"
    }
  },
  
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true,
      "installOhMyZsh": true,
      "upgradePackages": true
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "version": "latest",
      "enableNonRootDocker": true
    },
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
      "version": "latest",
      "helm": "latest",
      "minikube": "none"
    }
  },
  
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "terminal.integrated.profiles.linux": {
          "zsh": {
            "path": "/bin/zsh"
          }
        },
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.codeActionsOnSave": {
          "source.organizeImports": true,
          "source.fixAll.eslint": true
        },
        "typescript.updateImportsOnFileMove.enabled": "always",
        "typescript.preferences.importModuleSpecifier": "relative",
        "git.autofetch": true,
        "git.confirmSync": false,
        "github.copilot.enable": {
          "*": true
        }
      },
      
      "extensions": [
        // General
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "usernamehw.errorlens",
        "christian-kohler.path-intellisense",
        "aaron-bond.better-comments",
        "streetsidesoftware.code-spell-checker",
        
        // Git & GitHub
        "github.vscode-pull-request-github",
        "github.copilot",
        "github.copilot-chat",
        "eamodio.gitlens",
        
        // Languages
        "ms-python.python",
        "ms-python.vscode-pylance",
        "golang.go",
        "ms-dotnettools.csharp",
        "rust-lang.rust-analyzer",
        "ms-vscode.vscode-typescript-next",
        
        // Cloud & DevOps
        "ms-azuretools.vscode-docker",
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "hashicorp.terraform",
        "ms-vscode.azure-account",
        "ms-azuretools.vscode-azureresourcegroups",
        
        // Data & Config
        "redhat.vscode-yaml",
        "zainchen.json",
        "mtxr.sqltools",
        "mongodb.mongodb-vscode",
        
        // Productivity
        "wayou.vscode-todo-highlight",
        "gruntfuggly.todo-tree",
        "oderwat.indent-rainbow",
        "shardulm94.trailing-spaces",
        "formulahendry.auto-rename-tag",
        "naumovs.color-highlight"
      ]
    }
  },
  
  "forwardPorts": [3000, 3001, 8080, 5432, 27017, 6379],
  
  "postCreateCommand": "/usr/local/bin/setup-devbox.sh",
  
  "remoteUser": "developer",
  
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.ssh,target=/home/developer/.ssh,type=bind,consistency=cached",
    "source=devbox-extensions,target=/home/developer/.vscode-server/extensions,type=volume"
  ],
  
  "runArgs": [
    "--cap-add=SYS_PTRACE",
    "--security-opt",
    "seccomp=unconfined",
    "--privileged",
    "--init"
  ],
  
  "remoteEnv": {
    "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}",
    "AZURE_SUBSCRIPTION_ID": "aca2dc4a-9d62-4b64-82d4-11e152d98f02",
    "THREE_HORIZONS_ENV": "development"
  }
}
```

### Configurações do Workspace

```json
// .vscode/settings.json
{
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/node_modules": true,
    "**/.next": true,
    "**/dist": true,
    "**/build": true
  },
  
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true
  },
  
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  },
  
  "files.associations": {
    "*.yaml": "yaml",
    "*.yml": "yaml",
    ".env*": "properties"
  },
  
  "yaml.schemas": {
    "kubernetes": "k8s/**/*.yaml",
    "https://json.schemastore.org/github-workflow.json": ".github/workflows/*.yml"
  }
}
```

## 🚀 Provisionamento Automatizado {#provisionamento-automatizado}

### Terraform para Azure Dev Box

```hcl
# infrastructure/terraform/modules/devbox/main.tf
resource "azurerm_dev_center" "main" {
  name                = "devcenter-${var.project_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dev_center_project" "main" {
  name                = "project-${var.project_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  dev_center_id       = azurerm_dev_center.main.id
  
  description = "Development environment for Three Horizons platform"
}

resource "azurerm_dev_center_dev_box_definition" "main" {
  name               = "devbox-definition-${var.project_name}"
  location           = var.location
  dev_center_id      = azurerm_dev_center.main.id
  image_reference_id = data.azurerm_dev_center_gallery_image.windows11.id
  compute_size       = var.devbox_compute_size
  storage_type       = "ssd_256gb"
}

resource "azurerm_dev_center_network_connection" "main" {
  name                = "nc-${var.project_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  domain_join_type    = "AzureADJoin"
  subnet_id           = var.subnet_id
}

resource "azurerm_dev_center_attached_network" "main" {
  name                  = "an-${var.project_name}"
  dev_center_id         = azurerm_dev_center.main.id
  network_connection_id = azurerm_dev_center_network_connection.main.id
}

resource "azurerm_dev_center_dev_box_pool" "main" {
  name                   = "pool-${var.project_name}"
  location               = var.location
  dev_center_project_id  = azurerm_dev_center_project.main.id
  dev_box_definition_id  = azurerm_dev_center_dev_box_definition.main.id
  network_connection_id  = azurerm_dev_center_network_connection.main.id
  
  local_administrator_enabled = true
  
  auto_stop_schedule {
    enabled  = true
    timezone = "America/Sao_Paulo"
    time     = "18:00"
  }
}

# GitHub Codespaces configuration
resource "github_repository_file" "devcontainer" {
  repository = var.github_repository
  branch     = var.github_branch
  file       = ".devcontainer/devcontainer.json"
  content    = file("${path.module}/files/devcontainer.json")
  
  commit_message = "feat: Add DevContainer configuration"
  commit_author  = "Three Horizons Bot"
  commit_email   = "bot@threehorizons.ai"
}
```

### Script de Provisionamento

```bash
#!/bin/bash
# scripts/provision-devbox.sh

set -euo pipefail

# Configuração
PROJECT_NAME="threehorizons"
ENVIRONMENT="dev"
LOCATION="centralus"
DEVELOPER_EMAIL="${1:-developer@threehorizons.ai}"

echo "🚀 Provisioning DevBox for $DEVELOPER_EMAIL..."

# Criar Dev Box via Azure CLI
az devcenter dev-box create \
    --name "devbox-$(echo $DEVELOPER_EMAIL | cut -d@ -f1)" \
    --pool-name "pool-${PROJECT_NAME}" \
    --project-name "project-${PROJECT_NAME}" \
    --dev-center-name "devcenter-${PROJECT_NAME}"

# Aguardar provisionamento
echo "⏳ Waiting for DevBox provisioning..."
sleep 30

# Obter URL de acesso
DEVBOX_URL=$(az devcenter dev-box show \
    --name "devbox-$(echo $DEVELOPER_EMAIL | cut -d@ -f1)" \
    --pool-name "pool-${PROJECT_NAME}" \
    --project-name "project-${PROJECT_NAME}" \
    --dev-center-name "devcenter-${PROJECT_NAME}" \
    --query "webUrl" -o tsv)

echo "✅ DevBox provisioned successfully!"
echo "🔗 Access URL: $DEVBOX_URL"
echo ""
echo "📝 Next steps:"
echo "1. Access your DevBox via browser"
echo "2. VS Code will open automatically"
echo "3. Run 'setup-devbox.sh' in terminal"
```

## 🛠️ Ferramentas e SDKs {#ferramentas-sdks}

### Script de Instalação de Ferramentas

```bash
#!/bin/bash
# scripts/install-tools.sh

# Função para instalar ferramentas específicas do projeto
install_project_tools() {
    echo "📦 Installing project-specific tools..."
    
    # CLI da Three Horizons
    npm install -g @three-horizons/cli
    
    # Backstage CLI
    npm install -g @backstage/cli
    
    # Ferramentas de qualidade de código
    npm install -g \
        commitizen \
        cz-conventional-changelog \
        @commitlint/cli \
        @commitlint/config-conventional
    
    # Ferramentas de teste
    npm install -g \
        jest \
        cypress \
        @testing-library/react
    
    # Ferramentas Go
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    
    # Ferramentas Python
    pip install --user \
        pre-commit \
        pylint \
        mypy \
        bandit
    
    # Ferramentas .NET
    dotnet tool install --global dotnet-ef
    dotnet tool install --global dotnet-format
    
    echo "✅ Project tools installed!"
}

# Configurar aliases úteis
setup_aliases() {
    cat >> ~/.zshrc << 'EOF'

# Three Horizons Aliases
alias th="three-horizons"
alias thdev="cd /workspace/Three-Horizons-AI-Developer-Platform"
alias thlogs="kubectl logs -f -n threehorizons"
alias thpods="kubectl get pods -n threehorizons"

# Git aliases
alias gs="git status"
alias gp="git pull"
alias gc="git commit"
alias gco="git checkout"
alias gb="git branch"

# Docker aliases
alias dps="docker ps"
alias dil="docker image ls"
alias dex="docker exec -it"

# Kubernetes aliases
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kaf="kubectl apply -f"
alias kdel="kubectl delete"
alias klog="kubectl logs -f"

# Development shortcuts
alias dev="npm run dev"
alias build="npm run build"
alias test="npm test"
alias lint="npm run lint"
EOF

    echo "✅ Aliases configured!"
}
```

## 🔐 Segurança e Acesso {#seguranca-acesso}

### Configuração de Credenciais

```bash
#!/bin/bash
# scripts/setup-credentials.sh

# Configurar Azure
setup_azure_access() {
    echo "☁️ Configuring Azure access..."
    
    # Login interativo
    az login
    
    # Definir subscription padrão
    az account set --subscription "aca2dc4a-9d62-4b64-82d4-11e152d98f02"
    
    # Obter credenciais do AKS
    az aks get-credentials \
        --resource-group "rg-threehorizons-dev" \
        --name "aks-threehorizons-dev" \
        --overwrite-existing
    
    echo "✅ Azure access configured!"
}

# Configurar GitHub
setup_github_access() {
    echo "🐙 Configuring GitHub access..."
    
    # Verificar se token existe
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "📝 Please create a GitHub Personal Access Token with these scopes:"
        echo "   - repo (full control)"
        echo "   - workflow"
        echo "   - admin:org (read)"
        echo ""
        echo "Then run: export GITHUB_TOKEN=your_token_here"
        return 1
    fi
    
    # Configurar gh CLI
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    
    # Configurar Git
    git config --global user.name "$(gh api user --jq .name)"
    git config --global user.email "$(gh api user --jq .email)"
    
    echo "✅ GitHub access configured!"
}

# Configurar acesso ao Key Vault
setup_keyvault_access() {
    echo "🔐 Configuring Key Vault access..."
    
    # Instalar extensão
    az extension add --name keyvault-secrets
    
    # Listar Key Vaults disponíveis
    az keyvault list --query "[].name" -o tsv
    
    echo "✅ Key Vault access configured!"
}
```

### Políticas de Segurança

```yaml
# devbox/security-policy.yaml
apiVersion: security.microsoft.com/v1
kind: DevBoxSecurityPolicy
metadata:
  name: threehorizons-devbox-policy
spec:
  # Controle de acesso
  access:
    allowedUsers:
      - group: developers@threehorizons.ai
      - group: platform-team@threehorizons.ai
    
    requireMFA: true
    sessionTimeout: 8h
  
  # Restrições de rede
  network:
    allowedDestinations:
      - "*.threehorizons.io"
      - "*.github.com"
      - "*.githubusercontent.com"
      - "*.azure.com"
      - "*.microsoft.com"
      - "registry.npmjs.org"
      - "pypi.org"
      - "repo.maven.apache.org"
      - "packages.nuget.org"
    
    blockedPorts:
      - 25  # SMTP
      - 135 # RPC
      - 139 # NetBIOS
      - 445 # SMB
  
  # Controle de dados
  dataProtection:
    preventCopyToLocal: true
    allowedClipboardDomains:
      - "*.threehorizons.io"
      - "github.com"
    
    encryptAtRest: true
    
  # Auditoria
  audit:
    logAllCommands: true
    logFileAccess: true
    retentionDays: 90
```

## 📊 Integração com Developer Hub {#integracao-hub}

### Template do DevBox

```yaml
# templates/devbox/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: developer-devbox
  title: 💻 Developer DevBox
  description: Provisiona um ambiente de desenvolvimento completo na nuvem
  tags:
    - devbox
    - environment
    - developer-tools
spec:
  owner: platform-team
  type: environment
  
  parameters:
    - title: Informações do Desenvolvedor
      required:
        - developerEmail
        - projectName
      properties:
        developerEmail:
          title: Email do Desenvolvedor
          type: string
          format: email
          ui:autofocus: true
        
        projectName:
          title: Projeto
          type: string
          default: threehorizons-demo
          enum:
            - threehorizons-demo
            - threehorizons-prod
          enumNames:
            - 'Demo Environment'
            - 'Production Environment'
    
    - title: Configuração do DevBox
      properties:
        devboxType:
          title: Tipo de DevBox
          type: string
          default: standard
          enum:
            - standard
            - performance
            - gpu
          enumNames:
            - 'Standard (8 vCPU, 32GB RAM)'
            - 'Performance (16 vCPU, 64GB RAM)'
            - 'GPU Enabled (16 vCPU, 64GB RAM, GPU)'
        
        operatingSystem:
          title: Sistema Operacional
          type: string
          default: ubuntu
          enum:
            - ubuntu
            - windows
          enumNames:
            - 'Ubuntu 22.04 LTS'
            - 'Windows 11 Pro'
        
        additionalTools:
          title: Ferramentas Adicionais
          type: array
          items:
            type: string
            enum:
              - datagrip
              - postman
              - insomnia
              - dbeaver
          default: []

  steps:
    - id: provision
      name: Provisionar DevBox
      action: http:backstage:request
      input:
        method: POST
        path: /api/devbox/provision
        headers:
          Content-Type: application/json
        body:
          email: ${{ parameters.developerEmail }}
          project: ${{ parameters.projectName }}
          type: ${{ parameters.devboxType }}
          os: ${{ parameters.operatingSystem }}
          tools: ${{ parameters.additionalTools }}
    
    - id: wait
      name: Aguardar Provisionamento
      action: http:backstage:request
      input:
        method: GET
        path: /api/devbox/status/${{ steps.provision.output.devboxId }}
        
    - id: register
      name: Registrar no Catálogo
      action: catalog:register
      input:
        repoContentsUrl: https://github.com/three-horizon-ai/devbox-configs
        catalogInfoContent: |
          apiVersion: backstage.io/v1alpha1
          kind: Resource
          metadata:
            name: devbox-${{ parameters.developerEmail | replace("@", "-") | replace(".", "-") }}
            description: DevBox for ${{ parameters.developerEmail }}
            annotations:
              azure.com/devbox-id: ${{ steps.provision.output.devboxId }}
          spec:
            type: devbox
            owner: user:${{ parameters.developerEmail }}
            system: developer-experience

  output:
    links:
      - title: Acessar DevBox
        url: ${{ steps.provision.output.accessUrl }}
      - title: Documentação
        url: https://docs.threehorizons.io/devbox
    text:
      - title: DevBox Provisionado!
        content: |
          Seu ambiente de desenvolvimento está pronto!
          
          **Informações de Acesso:**
          - URL: ${{ steps.provision.output.accessUrl }}
          - Método: Browser ou VS Code Remote
          
          **Próximos Passos:**
          1. Acesse o DevBox via browser
          2. Execute `/usr/local/bin/setup-devbox.sh`
          3. Configure suas credenciais cloud
          4. Comece a desenvolver!
```

## 🧪 Validação e Testes {#validacao-testes}

### Script de Validação

```bash
#!/bin/bash
# scripts/validate-devbox.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Função de teste
test_command() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -n "Testing $name... "
    
    if eval "$command" > /dev/null 2>&1; then
        if [ -n "$expected" ]; then
            result=$(eval "$command" 2>/dev/null)
            if [[ "$result" == *"$expected"* ]]; then
                echo -e "${GREEN}✓${NC}"
                ((TESTS_PASSED++))
            else
                echo -e "${RED}✗ (unexpected output)${NC}"
                ((TESTS_FAILED++))
            fi
        else
            echo -e "${GREEN}✓${NC}"
            ((TESTS_PASSED++))
        fi
    else
        echo -e "${RED}✗${NC}"
        ((TESTS_FAILED++))
    fi
}

echo "🧪 Validating DevBox Environment..."
echo "=================================="

# Testar ferramentas básicas
echo "📦 Basic Tools:"
test_command "Git" "git --version" "git version"
test_command "Docker" "docker --version" "Docker version"
test_command "Node.js" "node --version" "v20"
test_command "npm" "npm --version" ""
test_command "Python" "python3 --version" "Python 3"
test_command "Go" "go version" "go version"
test_command "Java" "java --version" "17"
test_command ".NET" "dotnet --version" "8.0"

echo ""
echo "☁️ Cloud Tools:"
test_command "Azure CLI" "az --version" "azure-cli"
test_command "kubectl" "kubectl version --client" "Client Version"
test_command "Helm" "helm version" "version"
test_command "Terraform" "terraform --version" "Terraform"
test_command "GitHub CLI" "gh --version" "gh version"

echo ""
echo "🔧 Development Tools:"
test_command "VS Code Server" "code-server --version" ""
test_command "TypeScript" "tsc --version" "Version"
test_command "ESLint" "eslint --version" ""
test_command "Prettier" "prettier --version" ""

echo ""
echo "🔌 Connectivity:"
test_command "GitHub" "gh api user" ""
test_command "Azure" "az account show" ""
test_command "NPM Registry" "curl -s https://registry.npmjs.org" ""

echo ""
echo "=================================="
echo "Results: ${GREEN}$TESTS_PASSED passed${NC}, ${RED}$TESTS_FAILED failed${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
fi
```

## 📚 Documentação para Desenvolvedores {#documentacao-devs}

### README do DevBox

```markdown
# 💻 Three Horizons DevBox

Bem-vindo ao seu ambiente de desenvolvimento Three Horizons!

## 🚀 Quick Start

### 1. Primeiro Acesso

```bash
# Acessar via browser
https://devbox.threehorizons.io

# Ou via VS Code
code --folder-uri vscode-remote://dev-container+devbox/workspace
```

### 2. Configuração Inicial

```bash
# Executar script de setup
/usr/local/bin/setup-devbox.sh

# Configurar credenciais
az login
gh auth login
```

### 3. Clonar Repositórios

```bash
# Repositório principal
git clone https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform.git

# Navegar para o projeto
cd Three-Horizons-AI-Developer-Platform
```

## 🛠️ Ferramentas Disponíveis

### IDEs e Editores
- VS Code (com extensões pré-configuradas)
- Neovim (com configuração moderna)
- JetBrains Gateway (opcional)

### Linguagens e Runtimes
- **Node.js 20.x** - JavaScript/TypeScript
- **Python 3.11** - Com Poetry e pipenv
- **Go 1.21** - Com módulos configurados
- **Java 17** - OpenJDK com Maven/Gradle
- **.NET 8** - SDK completo
- **Rust** - Com cargo configurado

### Ferramentas Cloud
- Azure CLI
- AWS CLI
- Google Cloud SDK
- kubectl & Helm
- Terraform
- Ansible

### Desenvolvimento
- Docker & Docker Compose
- Git & GitHub CLI
- Postman/Insomnia
- Redis CLI
- MongoDB Shell
- PostgreSQL Client

## 📁 Estrutura de Diretórios

```
/workspace/
├── Three-Horizons-AI-Developer-Platform/   # Repositório principal
├── projects/                               # Seus projetos
├── scripts/                               # Scripts úteis
└── .devbox/                              # Configurações do DevBox
```

## 🔧 Configurações

### Git
```bash
# Já configurado com seu nome e email do GitHub
git config --global user.name
git config --global user.email
```

### Docker
```bash
# Docker-in-Docker habilitado
docker run hello-world
```

### Kubernetes
```bash
# Contextos disponíveis
kubectl config get-contexts

# Mudar contexto
kubectl config use-context aks-threehorizons-dev
```

## 🎯 Workflows Comuns

### Criar novo projeto
```bash
# Via Developer Hub
open https://backstage-rhdh.apps.threehorizons.io/create

# Via CLI
th create project --template=ecommerce-portal
```

### Executar aplicação localmente
```bash
# Frontend
cd frontend/portal
npm install
npm run dev

# Backend
docker-compose up -d
```

### Deploy para Kubernetes
```bash
# Build e push
docker build -t app:latest .
docker push registry.threehorizons.io/app:latest

# Deploy
kubectl apply -k k8s/overlays/dev
```

## 🐛 Troubleshooting

### Problema: Sem acesso ao Azure
```bash
# Re-autenticar
az login --use-device-code
```

### Problema: Docker não funciona
```bash
# Reiniciar Docker
sudo service docker restart
```

### Problema: Falta de permissões
```bash
# Verificar grupos
groups

# Adicionar ao grupo docker
sudo usermod -aG docker $USER
```

## 📚 Recursos

- [Documentação Three Horizons](https://docs.threehorizons.io)
- [Guias de Desenvolvimento](https://github.com/three-horizon-ai/guides)
- [Canal Slack](https://threehorizons.slack.com)
- [Office Hours](https://calendar.threehorizons.io/office-hours)

## 🆘 Suporte

- **Email**: devbox-support@threehorizons.io
- **Slack**: #devbox-help
- **Issues**: [GitHub Issues](https://github.com/three-horizon-ai/devbox/issues)

---

Happy Coding! 🚀
```

---

## 🎯 Próximos Passos

Com o DevBox configurado:

1. **[H1-007-F: CI/CD Pipeline](./H1-007-F-cicd-pipeline.md)** - Configurar pipelines
2. **[H1-007-G: GitOps Deployment](./H1-007-G-gitops-deployment.md)** - Implementar GitOps
3. **[H1-007-H: Monitoring Setup](./H1-007-H-monitoring-setup.md)** - Configurar monitoramento

---

**📝 Checklist do DevBox**

- [ ] Imagem Docker criada
- [ ] VS Code configurado
- [ ] Ferramentas instaladas
- [ ] Scripts de automação
- [ ] Credenciais configuradas
- [ ] Template no Developer Hub
- [ ] Validação completa
- [ ] Documentação pronta