# 🚀 H1-007: Scripts de Automação Completos

## 📋 Índice de Scripts

1. [🔧 Setup Completo](#setup-completo)
2. [☁️ Azure Resources](#azure-resources)
3. [🐙 GitHub Configuration](#github-configuration)
4. [📦 Application Deployment](#application-deployment)
5. [🔄 GitOps Setup](#gitops-setup)
6. [📊 Monitoring Installation](#monitoring-installation)
7. [🧪 Validation Scripts](#validation-scripts)
8. [🧹 Cleanup Scripts](#cleanup-scripts)

## 🔧 Setup Completo {#setup-completo}

### Master Setup Script

```bash
#!/bin/bash
# scripts/master-setup.sh
# Script principal para configurar toda a demonstração Three Horizons

set -euo pipefail

# Configurações Globais
export SUBSCRIPTION_ID="aca2dc4a-9d62-4b64-82d4-11e152d98f02"
export RESOURCE_GROUP="rg-threehorizons-demo"
export LOCATION="centralus"
export PROJECT_NAME="threehorizons"
export ENVIRONMENT="demo"
export DOMAIN="demo.threehorizons.io"
export GITHUB_ORG="three-horizon-ai"
export GITHUB_REPO="Three-Horizons-AI-Developer-Platform"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }

# Verificar pré-requisitos
check_prerequisites() {
    log "🔍 Verificando pré-requisitos..."
    
    local missing_tools=()
    
    # Ferramentas necessárias
    command -v az >/dev/null 2>&1 || missing_tools+=("az")
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    command -v helm >/dev/null 2>&1 || missing_tools+=("helm")
    command -v gh >/dev/null 2>&1 || missing_tools+=("gh")
    command -v jq >/dev/null 2>&1 || missing_tools+=("jq")
    command -v yq >/dev/null 2>&1 || missing_tools+=("yq")
    command -v argocd >/dev/null 2>&1 || missing_tools+=("argocd")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "As seguintes ferramentas estão faltando: ${missing_tools[*]}"
        error "Por favor, instale-as antes de continuar."
        exit 1
    fi
    
    success "Todos os pré-requisitos verificados!"
}

# Login no Azure
azure_login() {
    log "☁️ Fazendo login no Azure..."
    
    if ! az account show &>/dev/null; then
        az login
    fi
    
    az account set --subscription "$SUBSCRIPTION_ID"
    success "Login no Azure realizado!"
}

# Configurar GitHub
github_setup() {
    log "🐙 Configurando GitHub..."
    
    if ! gh auth status &>/dev/null; then
        gh auth login
    fi
    
    # Verificar acesso à organização
    if ! gh api "/orgs/${GITHUB_ORG}" &>/dev/null; then
        error "Sem acesso à organização ${GITHUB_ORG}"
        exit 1
    fi
    
    success "GitHub configurado!"
}

# Menu principal
show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Three Horizons AI Platform - Setup Master             ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1. 🚀 Setup Completo (Recomendado)"
    echo "2. ☁️  Configurar apenas Azure"
    echo "3. 🐙 Configurar apenas GitHub e Developer Hub"
    echo "4. 📦 Deploy apenas aplicações"
    echo "5. 🔄 Configurar apenas GitOps"
    echo "6. 📊 Configurar apenas Monitoramento"
    echo "7. 🧪 Validar instalação"
    echo "8. 🧹 Limpar tudo"
    echo "9. 🚪 Sair"
    echo ""
    read -p "Selecione uma opção [1-9]: " choice
}

# Setup completo
full_setup() {
    log "🚀 Iniciando setup completo..."
    
    # 1. Azure Infrastructure
    log "☁️ Configurando infraestrutura Azure..."
    ./azure-setup.sh
    
    # 2. GitHub e Developer Hub
    log "🐙 Configurando GitHub e Developer Hub..."
    ./github-devhub-setup.sh
    
    # 3. Deploy Applications
    log "📦 Fazendo deploy das aplicações..."
    ./deploy-applications.sh
    
    # 4. GitOps Setup
    log "🔄 Configurando GitOps..."
    ./gitops-setup.sh
    
    # 5. Monitoring Setup
    log "📊 Configurando monitoramento..."
    ./monitoring-setup.sh
    
    # 6. Validation
    log "🧪 Validando instalação..."
    ./validate-setup.sh
    
    success "✅ Setup completo finalizado!"
    show_urls
}

# Mostrar URLs de acesso
show_urls() {
    echo ""
    echo -e "${GREEN}🎉 Three Horizons Platform está pronto!${NC}"
    echo ""
    echo "📍 URLs de Acesso:"
    echo "  Developer Hub: https://backstage-rhdh.apps.${DOMAIN}"
    echo "  Portal E-commerce: https://portal.${DOMAIN}"
    echo "  Admin Dashboard: https://admin.${DOMAIN}"
    echo "  API Gateway: https://api.${DOMAIN}"
    echo "  ArgoCD: https://argocd.${DOMAIN}"
    echo "  Grafana: https://grafana.${DOMAIN}"
    echo "  Status Page: https://status.${DOMAIN}"
    echo ""
    echo "🔑 Credenciais:"
    echo "  ArgoCD: admin / $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
    echo "  Grafana: admin / ThreeHorizons2024!"
    echo ""
}

# Main
main() {
    check_prerequisites
    azure_login
    github_setup
    
    while true; do
        show_menu
        
        case $choice in
            1) full_setup ;;
            2) ./azure-setup.sh ;;
            3) ./github-devhub-setup.sh ;;
            4) ./deploy-applications.sh ;;
            5) ./gitops-setup.sh ;;
            6) ./monitoring-setup.sh ;;
            7) ./validate-setup.sh ;;
            8) ./cleanup-all.sh ;;
            9) exit 0 ;;
            *) error "Opção inválida!" ;;
        esac
        
        echo ""
        read -p "Pressione Enter para continuar..."
    done
}

# Executar
main "$@"
```

## ☁️ Azure Resources {#azure-resources}

### Azure Setup Script

```bash
#!/bin/bash
# scripts/azure-setup.sh
# Configura todos os recursos Azure necessários

set -euo pipefail

source ./common-functions.sh

# Variáveis
AKS_NAME="aks-${PROJECT_NAME}-${ENVIRONMENT}"
ACR_NAME="acr${PROJECT_NAME}${ENVIRONMENT}"
KEYVAULT_NAME="kv-${PROJECT_NAME}-${ENVIRONMENT}"

# Criar Resource Group
create_resource_group() {
    log "📁 Criando Resource Group..."
    
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags "Project=${PROJECT_NAME}" "Environment=${ENVIRONMENT}" "ManagedBy=Script"
    
    success "Resource Group criado!"
}

# Criar AKS Cluster
create_aks_cluster() {
    log "☸️ Criando AKS Cluster..."
    
    # Criar cluster
    az aks create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$AKS_NAME" \
        --location "$LOCATION" \
        --node-count 3 \
        --node-vm-size Standard_D4s_v3 \
        --kubernetes-version 1.28.3 \
        --enable-addons monitoring,azure-keyvault-secrets-provider \
        --enable-workload-identity \
        --enable-oidc-issuer \
        --network-plugin azure \
        --network-policy calico \
        --generate-ssh-keys \
        --enable-cluster-autoscaler \
        --min-count 3 \
        --max-count 10 \
        --tags "Project=${PROJECT_NAME}" "Environment=${ENVIRONMENT}"
    
    # Obter credenciais
    az aks get-credentials \
        --resource-group "$RESOURCE_GROUP" \
        --name "$AKS_NAME" \
        --overwrite-existing
    
    success "AKS Cluster criado!"
}

# Criar Container Registry
create_container_registry() {
    log "📦 Criando Container Registry..."
    
    az acr create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$ACR_NAME" \
        --sku Premium \
        --location "$LOCATION" \
        --admin-enabled false
    
    # Attach ACR to AKS
    az aks update \
        --resource-group "$RESOURCE_GROUP" \
        --name "$AKS_NAME" \
        --attach-acr "$ACR_NAME"
    
    success "Container Registry criado!"
}

# Criar Key Vault
create_key_vault() {
    log "🔐 Criando Key Vault..."
    
    az keyvault create \
        --name "$KEYVAULT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --enable-rbac-authorization \
        --enable-purge-protection \
        --retention-days 90
    
    # Adicionar secrets básicos
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "jwt-secret" \
        --value "$(openssl rand -base64 32)"
    
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "database-password" \
        --value "$(openssl rand -base64 24)"
    
    success "Key Vault criado!"
}

# Criar PostgreSQL
create_postgresql() {
    log "🐘 Criando PostgreSQL..."
    
    local admin_password=$(openssl rand -base64 24)
    
    az postgres flexible-server create \
        --resource-group "$RESOURCE_GROUP" \
        --name "psql-${PROJECT_NAME}-${ENVIRONMENT}" \
        --location "$LOCATION" \
        --admin-user "psqladmin" \
        --admin-password "$admin_password" \
        --sku-name "Standard_D4s_v3" \
        --tier "GeneralPurpose" \
        --storage-size 128 \
        --version 15 \
        --high-availability "ZoneRedundant" \
        --zone 1 \
        --standby-zone 2
    
    # Salvar senha no Key Vault
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "postgres-admin-password" \
        --value "$admin_password"
    
    # Criar databases
    for db in users orders catalog payments notifications; do
        az postgres flexible-server db create \
            --resource-group "$RESOURCE_GROUP" \
            --server-name "psql-${PROJECT_NAME}-${ENVIRONMENT}" \
            --database-name "${PROJECT_NAME}_${db}"
    done
    
    success "PostgreSQL criado!"
}

# Criar Redis Cache
create_redis() {
    log "⚡ Criando Redis Cache..."
    
    az redis create \
        --resource-group "$RESOURCE_GROUP" \
        --name "redis-${PROJECT_NAME}-${ENVIRONMENT}" \
        --location "$LOCATION" \
        --sku Premium \
        --vm-size P1 \
        --redis-version 6 \
        --zones 1 2 \
        --replicas-per-master 1
    
    # Obter chave de acesso
    local redis_key=$(az redis list-keys \
        --resource-group "$RESOURCE_GROUP" \
        --name "redis-${PROJECT_NAME}-${ENVIRONMENT}" \
        --query primaryKey -o tsv)
    
    # Salvar no Key Vault
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "redis-key" \
        --value "$redis_key"
    
    success "Redis Cache criado!"
}

# Criar Application Gateway
create_app_gateway() {
    log "🌐 Criando Application Gateway..."
    
    # Criar IP público
    az network public-ip create \
        --resource-group "$RESOURCE_GROUP" \
        --name "pip-agw-${PROJECT_NAME}-${ENVIRONMENT}" \
        --sku Standard \
        --allocation-method Static \
        --zone 1 2 3
    
    # Criar VNET e Subnet
    az network vnet create \
        --resource-group "$RESOURCE_GROUP" \
        --name "vnet-${PROJECT_NAME}-${ENVIRONMENT}" \
        --address-prefix 10.0.0.0/16 \
        --subnet-name agw-subnet \
        --subnet-prefix 10.0.1.0/24
    
    # Criar Application Gateway
    az network application-gateway create \
        --resource-group "$RESOURCE_GROUP" \
        --name "agw-${PROJECT_NAME}-${ENVIRONMENT}" \
        --location "$LOCATION" \
        --sku WAF_v2 \
        --public-ip-address "pip-agw-${PROJECT_NAME}-${ENVIRONMENT}" \
        --vnet-name "vnet-${PROJECT_NAME}-${ENVIRONMENT}" \
        --subnet agw-subnet \
        --priority 100 \
        --http-settings-port 80 \
        --http-settings-protocol Http \
        --frontend-port 80 \
        --routing-rule-type Basic \
        --servers "$AKS_NAME-dns.hcp.${LOCATION}.azmk8s.io" \
        --zones 1 2 3 \
        --min-capacity 2 \
        --max-capacity 10
    
    success "Application Gateway criado!"
}

# Configurar DNS
configure_dns() {
    log "🌐 Configurando DNS..."
    
    # Obter IP do Application Gateway
    local agw_ip=$(az network public-ip show \
        --resource-group "$RESOURCE_GROUP" \
        --name "pip-agw-${PROJECT_NAME}-${ENVIRONMENT}" \
        --query ipAddress -o tsv)
    
    log "Application Gateway IP: $agw_ip"
    log "Configure os seguintes registros DNS:"
    echo "  *.${DOMAIN} -> $agw_ip"
    
    warn "Por favor, configure manualmente os registros DNS no seu provedor."
}

# Main
main() {
    log "☁️ Iniciando configuração da infraestrutura Azure..."
    
    create_resource_group
    create_aks_cluster
    create_container_registry
    create_key_vault
    create_postgresql
    create_redis
    create_app_gateway
    configure_dns
    
    # Instalar componentes básicos no Kubernetes
    log "📦 Instalando componentes Kubernetes..."
    kubectl create namespace ingress-nginx || true
    kubectl create namespace cert-manager || true
    kubectl create namespace monitoring || true
    kubectl create namespace argocd || true
    
    # Instalar NGINX Ingress
    helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx \
        --set controller.service.loadBalancerIP="$agw_ip" \
        --wait
    
    # Instalar cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
    
    success "✅ Infraestrutura Azure configurada com sucesso!"
    
    # Salvar configurações
    cat > azure-config.env << EOF
RESOURCE_GROUP=$RESOURCE_GROUP
AKS_NAME=$AKS_NAME
ACR_NAME=$ACR_NAME
KEYVAULT_NAME=$KEYVAULT_NAME
POSTGRES_SERVER=psql-${PROJECT_NAME}-${ENVIRONMENT}
REDIS_NAME=redis-${PROJECT_NAME}-${ENVIRONMENT}
APP_GATEWAY_NAME=agw-${PROJECT_NAME}-${ENVIRONMENT}
VNET_NAME=vnet-${PROJECT_NAME}-${ENVIRONMENT}
EOF
    
    log "Configurações salvas em azure-config.env"
}

# Executar
main "$@"
```

## 🐙 GitHub Configuration {#github-configuration}

### GitHub e Developer Hub Setup

```bash
#!/bin/bash
# scripts/github-devhub-setup.sh
# Configura GitHub e Red Hat Developer Hub

set -euo pipefail

source ./common-functions.sh

# Variáveis
GITHUB_APP_NAME="Three-Horizons-Developer-Hub"
BACKSTAGE_NAMESPACE="rhdh-operator"
BACKSTAGE_URL="https://backstage-rhdh.apps.${DOMAIN}"

# Criar GitHub App
create_github_app() {
    log "🐙 Criando GitHub App..."
    
    # Gerar webhook secret
    local webhook_secret=$(openssl rand -base64 32)
    
    # Criar app manifest
    cat > github-app-manifest.json << EOF
{
  "name": "${GITHUB_APP_NAME}",
  "url": "${BACKSTAGE_URL}",
  "hook_attributes": {
    "url": "${BACKSTAGE_URL}/api/github/webhook",
    "active": true
  },
  "redirect_url": "${BACKSTAGE_URL}/api/auth/github/handler/frame",
  "callback_urls": [
    "${BACKSTAGE_URL}/api/auth/github/handler/frame"
  ],
  "setup_url": "${BACKSTAGE_URL}/api/github/setup",
  "setup_on_update": true,
  "public": false,
  "default_permissions": {
    "actions": "read",
    "administration": "write",
    "contents": "write",
    "issues": "write",
    "metadata": "read",
    "pull_requests": "write",
    "repository_hooks": "write",
    "repository_projects": "write",
    "statuses": "write",
    "members": "read",
    "emails": "read"
  },
  "default_events": [
    "create",
    "delete",
    "fork",
    "issues",
    "issue_comment",
    "push",
    "pull_request",
    "pull_request_review",
    "pull_request_review_comment",
    "release",
    "repository"
  ]
}
EOF

    # Criar app via API
    local app_response=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/orgs/${GITHUB_ORG}/app-manifests" \
        --input github-app-manifest.json)
    
    local app_id=$(echo "$app_response" | jq -r '.id')
    local client_id=$(echo "$app_response" | jq -r '.client_id')
    local client_secret=$(echo "$app_response" | jq -r '.client_secret')
    local private_key=$(echo "$app_response" | jq -r '.pem')
    
    # Salvar credenciais
    cat > github-app-credentials.env << EOF
GITHUB_APP_ID=$app_id
GITHUB_CLIENT_ID=$client_id
GITHUB_CLIENT_SECRET=$client_secret
GITHUB_WEBHOOK_SECRET=$webhook_secret
EOF
    
    echo "$private_key" > github-app-private-key.pem
    
    success "GitHub App criado!"
}

# Instalar Red Hat Developer Hub
install_developer_hub() {
    log "📚 Instalando Red Hat Developer Hub..."
    
    # Criar namespace
    kubectl create namespace $BACKSTAGE_NAMESPACE || true
    
    # Criar secret com credenciais do GitHub
    kubectl create secret generic github-app-credentials \
        --from-env-file=github-app-credentials.env \
        --from-file=GITHUB_APP_PRIVATE_KEY=github-app-private-key.pem \
        -n $BACKSTAGE_NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Instalar operator
    cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: rhdh-operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: rhdh-operator-group
  namespace: rhdh-operator
spec:
  targetNamespaces:
  - rhdh-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: rhdh-operator
spec:
  channel: stable
  name: rhdh-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Aguardar operator ficar pronto
    log "⏳ Aguardando operator..."
    kubectl wait --for=condition=ready pod -l name=rhdh-operator -n rhdh-operator --timeout=300s
    
    # Criar instância do Developer Hub
    cat << EOF | kubectl apply -f -
apiVersion: backstage.redhat.com/v1
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh-operator
spec:
  application:
    appConfig:
      configMaps:
        - name: app-config
      secrets:
        - name: github-app-credentials
    extraEnvs:
      - name: NODE_ENV
        value: production
    replicas: 2
    route:
      enabled: true
      host: backstage-rhdh.apps.${DOMAIN}
      tls:
        enabled: true
        termination: edge
  database:
    enableLocalDb: false
    postgresqlService:
      name: postgresql
      port: 5432
      secret: postgres-secret
EOF
    
    success "Developer Hub instalado!"
}

# Configurar Developer Hub
configure_developer_hub() {
    log "🔧 Configurando Developer Hub..."
    
    # Criar ConfigMap com configuração
    cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: rhdh-operator
data:
  app-config.yaml: |
    app:
      title: Three Horizons AI Platform
      baseUrl: ${BACKSTAGE_URL}
    
    organization:
      name: Three Horizons AI
    
    backend:
      baseUrl: ${BACKSTAGE_URL}
      listen:
        port: 7007
      cors:
        origin: ${BACKSTAGE_URL}
        methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
        credentials: true
      database:
        client: pg
        connection:
          host: \${POSTGRES_HOST}
          port: \${POSTGRES_PORT}
          user: \${POSTGRES_USER}
          password: \${POSTGRES_PASSWORD}
          database: backstage
    
    integrations:
      github:
        - host: github.com
          apps:
            - appId: \${GITHUB_APP_ID}
              clientId: \${GITHUB_CLIENT_ID}
              clientSecret: \${GITHUB_CLIENT_SECRET}
              privateKey: |
                \${GITHUB_APP_PRIVATE_KEY}
              webhookSecret: \${GITHUB_WEBHOOK_SECRET}
    
    auth:
      environment: production
      providers:
        github:
          production:
            clientId: \${GITHUB_CLIENT_ID}
            clientSecret: \${GITHUB_CLIENT_SECRET}
    
    catalog:
      import:
        entityFilename: catalog-info.yaml
        pullRequestBranchName: backstage-integration
      rules:
        - allow: [Component, System, API, Resource, Location, Template]
      locations:
        - type: url
          target: https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/blob/main/catalog-info.yaml
          rules:
            - allow: [Location, Component, System, API, Resource, Template]
    
    scaffolder:
      defaultAuthor:
        name: Three Horizons Bot
        email: bot@threehorizons.ai
      defaultCommitMessage: "feat: Created \${projectName} from template"
    
    techdocs:
      builder: external
      publisher:
        type: awsS3
        awsS3:
          bucketName: threehorizons-techdocs
          region: us-east-1
    
    kubernetes:
      serviceLocatorMethod:
        type: multiTenant
      clusterLocatorMethods:
        - type: config
          clusters:
            - name: ${AKS_NAME}
              authProvider: azure
              skipTLSVerify: false
              skipMetricsLookup: false
EOF
    
    # Criar database secret
    kubectl create secret generic postgres-secret \
        --from-literal=POSTGRES_HOST="psql-${PROJECT_NAME}-${ENVIRONMENT}.postgres.database.azure.com" \
        --from-literal=POSTGRES_PORT="5432" \
        --from-literal=POSTGRES_USER="backstage@psql-${PROJECT_NAME}-${ENVIRONMENT}" \
        --from-literal=POSTGRES_PASSWORD="$(az keyvault secret show --vault-name $KEYVAULT_NAME --name postgres-admin-password --query value -o tsv)" \
        -n rhdh-operator \
        --dry-run=client -o yaml | kubectl apply -f -
    
    success "Developer Hub configurado!"
}

# Registrar templates
register_templates() {
    log "📝 Registrando templates..."
    
    # Aguardar Developer Hub ficar pronto
    kubectl wait --for=condition=ready pod -l app=backstage -n rhdh-operator --timeout=300s
    
    # Obter token de acesso
    local token=$(kubectl exec -n rhdh-operator deployment/backstage -- \
        curl -s -X POST http://localhost:7007/api/auth/guest/refresh | jq -r '.token')
    
    # Registrar catalog locations
    local locations=(
        "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/blob/main/demos/ecommerce-showcase/templates/catalog-info.yaml"
        "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/blob/main/demos/ecommerce-showcase/catalog-info.yaml"
    )
    
    for location in "${locations[@]}"; do
        curl -X POST "${BACKSTAGE_URL}/api/catalog/locations" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" \
            -d "{\"type\": \"url\", \"target\": \"$location\"}"
    done
    
    success "Templates registrados!"
}

# Main
main() {
    log "🐙 Configurando GitHub e Developer Hub..."
    
    create_github_app
    install_developer_hub
    configure_developer_hub
    register_templates
    
    success "✅ GitHub e Developer Hub configurados!"
    
    log ""
    log "📍 Acesse o Developer Hub em: ${BACKSTAGE_URL}"
    log "🔑 Use suas credenciais GitHub para login"
}

# Executar
main "$@"
```

## 📦 Application Deployment {#application-deployment}

### Deploy Applications Script

```bash
#!/bin/bash
# scripts/deploy-applications.sh
# Deploy de todas as aplicações

set -euo pipefail

source ./common-functions.sh
source ./azure-config.env

# Criar namespaces
create_namespaces() {
    log "📁 Criando namespaces..."
    
    local namespaces=("ecommerce-dev" "ecommerce-staging" "ecommerce-prod")
    
    for ns in "${namespaces[@]}"; do
        kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
        
        # Label namespace
        kubectl label namespace "$ns" \
            environment="${ns#ecommerce-}" \
            istio-injection=enabled \
            --overwrite
    done
    
    success "Namespaces criados!"
}

# Build e push de imagens
build_and_push_images() {
    log "🐳 Building e pushing imagens..."
    
    # Login no ACR
    az acr login --name "$ACR_NAME"
    
    # Lista de serviços
    local services=(
        "frontend/portal"
        "frontend/admin"
        "backend/api-gateway"
        "backend/catalog-service"
        "backend/cart-service"
        "backend/order-service"
        "backend/payment-service"
        "backend/user-service"
        "backend/notification-service"
    )
    
    for service in "${services[@]}"; do
        log "Building $service..."
        
        local service_name=$(basename "$service")
        local image_tag="${ACR_NAME}.azurecr.io/${service_name}:latest"
        
        # Build
        docker build -t "$image_tag" "$service"
        
        # Push
        docker push "$image_tag"
        
        # Tag com versão
        docker tag "$image_tag" "${ACR_NAME}.azurecr.io/${service_name}:v1.0.0"
        docker push "${ACR_NAME}.azurecr.io/${service_name}:v1.0.0"
    done
    
    success "Imagens construídas e enviadas!"
}

# Deploy com Helm
deploy_with_helm() {
    log "⚓ Deploying aplicações com Helm..."
    
    # Deploy frontend
    helm upgrade --install frontend-portal ./charts/frontend \
        --namespace ecommerce-dev \
        --values ./charts/frontend/values-portal.yaml \
        --values ./charts/frontend/values-dev.yaml \
        --set image.repository="${ACR_NAME}.azurecr.io/frontend-portal" \
        --set image.tag="v1.0.0" \
        --set ingress.hostname="portal-dev.${DOMAIN}" \
        --wait
    
    helm upgrade --install frontend-admin ./charts/frontend \
        --namespace ecommerce-dev \
        --values ./charts/frontend/values-admin.yaml \
        --values ./charts/frontend/values-dev.yaml \
        --set image.repository="${ACR_NAME}.azurecr.io/frontend-admin" \
        --set image.tag="v1.0.0" \
        --set ingress.hostname="admin-dev.${DOMAIN}" \
        --wait
    
    # Deploy backend services
    local backend_services=(
        "api-gateway"
        "catalog-service"
        "cart-service"
        "order-service"
        "payment-service"
        "user-service"
        "notification-service"
    )
    
    for service in "${backend_services[@]}"; do
        helm upgrade --install "$service" ./charts/microservice \
            --namespace ecommerce-dev \
            --values ./charts/microservice/values.yaml \
            --values ./charts/microservice/values-dev.yaml \
            --set nameOverride="$service" \
            --set image.repository="${ACR_NAME}.azurecr.io/${service}" \
            --set image.tag="v1.0.0" \
            --wait
    done
    
    success "Aplicações deployed!"
}

# Configurar secrets
configure_secrets() {
    log "🔐 Configurando secrets..."
    
    # Database credentials
    kubectl create secret generic database-credentials \
        --from-literal=DATABASE_URL="postgresql://appuser:$(az keyvault secret show --vault-name $KEYVAULT_NAME --name database-password --query value -o tsv)@psql-${PROJECT_NAME}-${ENVIRONMENT}.postgres.database.azure.com:5432/ecommerce" \
        -n ecommerce-dev \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Redis credentials
    kubectl create secret generic redis-credentials \
        --from-literal=REDIS_URL="redis://:$(az keyvault secret show --vault-name $KEYVAULT_NAME --name redis-key --query value -o tsv)@redis-${PROJECT_NAME}-${ENVIRONMENT}.redis.cache.windows.net:6379" \
        -n ecommerce-dev \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # JWT secret
    kubectl create secret generic jwt-secret \
        --from-literal=JWT_SECRET="$(az keyvault secret show --vault-name $KEYVAULT_NAME --name jwt-secret --query value -o tsv)" \
        -n ecommerce-dev \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # External API keys (mock)
    kubectl create secret generic external-apis \
        --from-literal=STRIPE_SECRET_KEY="sk_test_mock123" \
        --from-literal=SENDGRID_API_KEY="SG.mock123" \
        -n ecommerce-dev \
        --dry-run=client -o yaml | kubectl apply -f -
    
    success "Secrets configurados!"
}

# Seed databases
seed_databases() {
    log "🌱 Populando databases..."
    
    # Job para seed
    cat << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: database-seed
  namespace: ecommerce-dev
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: seed
        image: ${ACR_NAME}.azurecr.io/database-seed:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: DATABASE_URL
        command: ["/bin/sh", "-c"]
        args:
          - |
            echo "Seeding database..."
            psql \$DATABASE_URL < /seed/schema.sql
            psql \$DATABASE_URL < /seed/data.sql
            echo "Database seeded!"
EOF
    
    # Aguardar conclusão
    kubectl wait --for=condition=complete job/database-seed -n ecommerce-dev --timeout=300s
    
    success "Databases populados!"
}

# Verificar deployment
verify_deployment() {
    log "🔍 Verificando deployment..."
    
    # Verificar pods
    kubectl get pods -n ecommerce-dev
    
    # Verificar services
    kubectl get svc -n ecommerce-dev
    
    # Verificar ingress
    kubectl get ingress -n ecommerce-dev
    
    # Testar endpoints
    local endpoints=(
        "https://portal-dev.${DOMAIN}"
        "https://admin-dev.${DOMAIN}"
        "https://api-dev.${DOMAIN}/health"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s -o /dev/null -w "%{http_code}" "$endpoint" | grep -q "200\|301\|302"; then
            success "✅ $endpoint está acessível"
        else
            error "❌ $endpoint não está acessível"
        fi
    done
}

# Main
main() {
    log "📦 Iniciando deploy das aplicações..."
    
    create_namespaces
    configure_secrets
    build_and_push_images
    deploy_with_helm
    seed_databases
    verify_deployment
    
    success "✅ Aplicações deployed com sucesso!"
    
    log ""
    log "📍 URLs das aplicações:"
    log "  Portal: https://portal-dev.${DOMAIN}"
    log "  Admin: https://admin-dev.${DOMAIN}"
    log "  API: https://api-dev.${DOMAIN}"
}

# Executar
main "$@"
```

## 🔄 GitOps Setup {#gitops-setup}

### ArgoCD e GitOps Configuration

```bash
#!/bin/bash
# scripts/gitops-setup.sh
# Configura ArgoCD e GitOps

set -euo pipefail

source ./common-functions.sh

ARGOCD_VERSION="v2.9.3"
ARGOCD_NAMESPACE="argocd"

# Instalar ArgoCD
install_argocd() {
    log "🔄 Instalando ArgoCD..."
    
    # Criar namespace
    kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Instalar ArgoCD
    kubectl apply -n $ARGOCD_NAMESPACE -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
    
    # Aguardar pods
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $ARGOCD_NAMESPACE --timeout=300s
    
    # Patch service para LoadBalancer
    kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
    
    success "ArgoCD instalado!"
}

# Configurar ArgoCD
configure_argocd() {
    log "🔧 Configurando ArgoCD..."
    
    # Obter senha inicial
    local initial_password=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    log "Senha inicial do ArgoCD: $initial_password"
    
    # Instalar ArgoCD CLI
    if ! command -v argocd &> /dev/null; then
        curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
        chmod +x /usr/local/bin/argocd
    fi
    
    # Login
    argocd login "argocd.${DOMAIN}" \
        --username admin \
        --password "$initial_password" \
        --insecure
    
    # Mudar senha
    argocd account update-password \
        --current-password "$initial_password" \
        --new-password "ThreeHorizons2024!"
    
    # Adicionar repositório
    argocd repo add "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git" \
        --name three-horizons \
        --type git
    
    success "ArgoCD configurado!"
}

# Criar aplicações ArgoCD
create_argocd_apps() {
    log "📱 Criando aplicações ArgoCD..."
    
    # App of Apps
    cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/${GITHUB_REPO}
    targetRevision: main
    path: gitops/apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

    # Frontend applications
    cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/${GITHUB_REPO}
    targetRevision: main
    path: k8s/overlays/dev/frontend
  destination:
    server: https://kubernetes.default.svc
    namespace: ecommerce-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

    # Backend services
    cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: backend-services
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/${GITHUB_REPO}
    targetRevision: main
    path: k8s/overlays/dev/backend
  destination:
    server: https://kubernetes.default.svc
    namespace: ecommerce-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

    success "Aplicações ArgoCD criadas!"
}

# Configurar webhooks
configure_webhooks() {
    log "🔗 Configurando webhooks..."
    
    # Obter URL do webhook
    local webhook_url="https://argocd.${DOMAIN}/api/webhook"
    local webhook_secret=$(openssl rand -base64 32)
    
    # Criar webhook no GitHub
    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/${GITHUB_ORG}/${GITHUB_REPO}/hooks" \
        -f name='web' \
        -f active=true \
        -f events='["push","pull_request"]' \
        -f config[url]="$webhook_url" \
        -f config[content_type]='json' \
        -f config[secret]="$webhook_secret" \
        -f config[insecure_ssl]='0'
    
    # Configurar secret no ArgoCD
    kubectl create secret generic argocd-webhook-secret \
        --from-literal=webhook.github.secret="$webhook_secret" \
        -n $ARGOCD_NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    success "Webhooks configurados!"
}

# Criar estrutura GitOps
create_gitops_structure() {
    log "📁 Criando estrutura GitOps..."
    
    # Clone do repositório
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    gh repo clone "${GITHUB_ORG}/${GITHUB_REPO}"
    cd "${GITHUB_REPO}"
    
    # Criar estrutura
    mkdir -p gitops/{apps,clusters,environments}
    mkdir -p k8s/{base,overlays/{dev,staging,prod}}
    
    # Criar kustomization base
    cat > k8s/base/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../charts/frontend
  - ../../../charts/microservice
EOF

    # Criar overlay dev
    cat > k8s/overlays/dev/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: ecommerce-dev

resources:
  - ../../base

patchesStrategicMerge:
  - patches/deployment-patch.yaml
  - patches/service-patch.yaml

configMapGenerator:
  - name: app-config
    literals:
      - ENVIRONMENT=dev
      - API_URL=https://api-dev.${DOMAIN}

images:
  - name: frontend-portal
    newName: ${ACR_NAME}.azurecr.io/frontend-portal
    newTag: latest
  - name: frontend-admin
    newName: ${ACR_NAME}.azurecr.io/frontend-admin
    newTag: latest
EOF

    # Commit e push
    git add .
    git commit -m "feat: Add GitOps structure"
    git push
    
    cd -
    rm -rf "$temp_dir"
    
    success "Estrutura GitOps criada!"
}

# Main
main() {
    log "🔄 Configurando GitOps com ArgoCD..."
    
    install_argocd
    configure_argocd
    create_argocd_apps
    configure_webhooks
    create_gitops_structure
    
    success "✅ GitOps configurado com sucesso!"
    
    log ""
    log "📍 Acesse o ArgoCD em: https://argocd.${DOMAIN}"
    log "👤 Usuário: admin"
    log "🔑 Senha: ThreeHorizons2024!"
}

# Executar
main "$@"
```

## 📊 Monitoring Installation {#monitoring-installation}

### Complete Monitoring Stack Setup

```bash
#!/bin/bash
# scripts/monitoring-setup.sh
# Instala stack completo de monitoramento

set -euo pipefail

source ./common-functions.sh

MONITORING_NAMESPACE="monitoring"

# Instalar Prometheus Stack
install_prometheus_stack() {
    log "📈 Instalando Prometheus Stack..."
    
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Criar values file
    cat > prometheus-values.yaml << EOF
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false

grafana:
  enabled: true
  adminPassword: ThreeHorizons2024!
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - grafana.${DOMAIN}
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.${DOMAIN}
  
  sidecar:
    dashboards:
      enabled: true
      searchNamespace: ALL
    datasources:
      enabled: true
      defaultDatasourceEnabled: true

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'default'
    receivers:
    - name: 'default'
      webhook_configs:
      - url: 'http://alertmanager-webhook:9093/webhook'
EOF

    helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace $MONITORING_NAMESPACE \
        --create-namespace \
        --values prometheus-values.yaml \
        --wait
    
    success "Prometheus Stack instalado!"
}

# Instalar Loki
install_loki() {
    log "📝 Instalando Loki para logs..."
    
    helm repo add grafana https://grafana.github.io/helm-charts
    
    helm upgrade --install loki grafana/loki-stack \
        --namespace $MONITORING_NAMESPACE \
        --set loki.persistence.enabled=true \
        --set loki.persistence.size=50Gi \
        --set promtail.enabled=true \
        --wait
    
    success "Loki instalado!"
}

# Configurar Application Insights
configure_app_insights() {
    log "📊 Configurando Application Insights..."
    
    # Criar Application Insights
    local ai_name="ai-${PROJECT_NAME}-${ENVIRONMENT}"
    
    az monitor app-insights component create \
        --app "$ai_name" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP" \
        --application-type web \
        --kind web
    
    # Obter instrumentation key
    local instrumentation_key=$(az monitor app-insights component show \
        --app "$ai_name" \
        --resource-group "$RESOURCE_GROUP" \
        --query instrumentationKey -o tsv)
    
    # Criar secret
    kubectl create secret generic app-insights \
        --from-literal=INSTRUMENTATION_KEY="$instrumentation_key" \
        -n ecommerce-dev \
        --dry-run=client -o yaml | kubectl apply -f -
    
    success "Application Insights configurado!"
}

# Criar dashboards
create_dashboards() {
    log "📊 Criando dashboards..."
    
    # Dashboard principal
    cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-main
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  main-dashboard.json: |
    {
      "dashboard": {
        "title": "Three Horizons Platform Overview",
        "panels": [
          {
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
            "id": 1,
            "title": "Request Rate",
            "targets": [
              {
                "expr": "sum(rate(http_requests_total[5m])) by (service)",
                "legendFormat": "{{service}}"
              }
            ],
            "type": "graph"
          },
          {
            "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
            "id": 2,
            "title": "Error Rate",
            "targets": [
              {
                "expr": "sum(rate(http_requests_total{status_code=~\"5..\"}[5m])) by (service)",
                "legendFormat": "{{service}}"
              }
            ],
            "type": "graph"
          },
          {
            "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8},
            "id": 3,
            "title": "Response Time P95",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le))",
                "legendFormat": "{{service}}"
              }
            ],
            "type": "graph"
          }
        ]
      }
    }
EOF
    
    success "Dashboards criados!"
}

# Configurar alertas
configure_alerts() {
    log "🚨 Configurando alertas..."
    
    cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: platform-alerts
  namespace: monitoring
spec:
  groups:
  - name: platform
    interval: 30s
    rules:
    - alert: HighErrorRate
      expr: |
        sum(rate(http_requests_total{status_code=~"5.."}[5m])) by (service)
        /
        sum(rate(http_requests_total[5m])) by (service)
        > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate on {{ \$labels.service }}"
        description: "Service {{ \$labels.service }} has error rate of {{ \$value }}"
    
    - alert: HighLatency
      expr: |
        histogram_quantile(0.95, 
          sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le)
        ) > 1
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High latency on {{ \$labels.service }}"
        description: "P95 latency for {{ \$labels.service }} is {{ \$value }}s"
EOF
    
    success "Alertas configurados!"
}

# Configurar service monitors
configure_service_monitors() {
    log "📡 Configurando service monitors..."
    
    cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: application-metrics
  namespace: monitoring
spec:
  namespaceSelector:
    matchNames:
    - ecommerce-dev
    - ecommerce-staging
    - ecommerce-prod
  selector:
    matchLabels:
      metrics: "true"
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF
    
    success "Service monitors configurados!"
}

# Main
main() {
    log "📊 Instalando stack de monitoramento..."
    
    install_prometheus_stack
    install_loki
    configure_app_insights
    create_dashboards
    configure_alerts
    configure_service_monitors
    
    success "✅ Stack de monitoramento instalado!"
    
    log ""
    log "📍 URLs de acesso:"
    log "  Grafana: https://grafana.${DOMAIN}"
    log "  Prometheus: https://prometheus.${DOMAIN}"
    log "  AlertManager: https://alertmanager.${DOMAIN}"
    log ""
    log "🔑 Credenciais Grafana:"
    log "  Usuário: admin"
    log "  Senha: ThreeHorizons2024!"
}

# Executar
main "$@"
```

## 🧪 Validation Scripts {#validation-scripts}

### Complete Validation Script

```bash
#!/bin/bash
# scripts/validate-setup.sh
# Valida toda a instalação

set -euo pipefail

source ./common-functions.sh

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0

# Função de teste
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -n "🧪 $test_name... "
    
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Testar Azure Resources
test_azure_resources() {
    log "☁️ Testando recursos Azure..."
    
    run_test "Resource Group" "az group show -n $RESOURCE_GROUP"
    run_test "AKS Cluster" "az aks show -n $AKS_NAME -g $RESOURCE_GROUP"
    run_test "Container Registry" "az acr show -n $ACR_NAME -g $RESOURCE_GROUP"
    run_test "Key Vault" "az keyvault show -n $KEYVAULT_NAME -g $RESOURCE_GROUP"
    run_test "PostgreSQL" "az postgres flexible-server show -n psql-${PROJECT_NAME}-${ENVIRONMENT} -g $RESOURCE_GROUP"
    run_test "Redis Cache" "az redis show -n redis-${PROJECT_NAME}-${ENVIRONMENT} -g $RESOURCE_GROUP"
}

# Testar Kubernetes
test_kubernetes() {
    log "☸️ Testando Kubernetes..."
    
    run_test "Kubectl connection" "kubectl cluster-info"
    run_test "Namespaces" "kubectl get namespace ecommerce-dev"
    run_test "Ingress controller" "kubectl get pods -n ingress-nginx --no-headers | grep Running"
    run_test "Cert-manager" "kubectl get pods -n cert-manager --no-headers | grep Running"
}

# Testar aplicações
test_applications() {
    log "📦 Testando aplicações..."
    
    run_test "Frontend Portal pod" "kubectl get pods -n ecommerce-dev -l app=frontend-portal --no-headers | grep Running"
    run_test "Frontend Admin pod" "kubectl get pods -n ecommerce-dev -l app=frontend-admin --no-headers | grep Running"
    run_test "API Gateway pod" "kubectl get pods -n ecommerce-dev -l app=api-gateway --no-headers | grep Running"
    
    # Testar endpoints
    run_test "Portal endpoint" "curl -s -o /dev/null -w '%{http_code}' https://portal-dev.${DOMAIN} | grep -E '200|301|302'"
    run_test "Admin endpoint" "curl -s -o /dev/null -w '%{http_code}' https://admin-dev.${DOMAIN} | grep -E '200|301|302'"
    run_test "API endpoint" "curl -s https://api-dev.${DOMAIN}/health | jq -r .status | grep -q healthy"
}

# Testar GitOps
test_gitops() {
    log "🔄 Testando GitOps..."
    
    run_test "ArgoCD namespace" "kubectl get namespace argocd"
    run_test "ArgoCD server" "kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers | grep Running"
    run_test "ArgoCD applications" "argocd app list | grep -q Synced"
}

# Testar monitoramento
test_monitoring() {
    log "📊 Testando monitoramento..."
    
    run_test "Prometheus" "kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --no-headers | grep Running"
    run_test "Grafana" "kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers | grep Running"
    run_test "Loki" "kubectl get pods -n monitoring -l app=loki --no-headers | grep Running"
    
    run_test "Grafana endpoint" "curl -s -o /dev/null -w '%{http_code}' https://grafana.${DOMAIN} | grep -E '200|301|302'"
}

# Testar Developer Hub
test_developer_hub() {
    log "📚 Testando Developer Hub..."
    
    run_test "Developer Hub namespace" "kubectl get namespace rhdh-operator"
    run_test "Developer Hub pod" "kubectl get pods -n rhdh-operator -l app=backstage --no-headers | grep Running"
    run_test "Developer Hub endpoint" "curl -s -o /dev/null -w '%{http_code}' https://backstage-rhdh.apps.${DOMAIN} | grep -E '200|301|302'"
}

# Relatório final
generate_report() {
    log ""
    log "📋 RELATÓRIO DE VALIDAÇÃO"
    log "========================"
    log "✅ Testes passados: $TESTS_PASSED"
    log "❌ Testes falhados: $TESTS_FAILED"
    log ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        success "🎉 Todos os testes passaram! A plataforma está pronta!"
    else
        error "⚠️ Alguns testes falharam. Verifique os componentes acima."
        exit 1
    fi
}

# Main
main() {
    log "🧪 Iniciando validação da plataforma..."
    
    test_azure_resources
    test_kubernetes
    test_applications
    test_gitops
    test_monitoring
    test_developer_hub
    
    generate_report
}

# Executar
main "$@"
```

## 🧹 Cleanup Scripts {#cleanup-scripts}

### Complete Cleanup Script

```bash
#!/bin/bash
# scripts/cleanup-all.sh
# Remove todos os recursos criados

set -euo pipefail

source ./common-functions.sh

# Confirmar limpeza
confirm_cleanup() {
    warn "⚠️ ATENÇÃO: Este script removerá TODOS os recursos criados!"
    warn "Isso inclui:"
    warn "  - Todos os recursos Azure"
    warn "  - Configurações do GitHub"
    warn "  - Dados e configurações"
    echo ""
    read -p "Tem certeza que deseja continuar? (digite 'yes' para confirmar): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        log "Operação cancelada."
        exit 0
    fi
}

# Limpar Kubernetes
cleanup_kubernetes() {
    log "☸️ Limpando recursos Kubernetes..."
    
    # Deletar namespaces
    kubectl delete namespace ecommerce-dev ecommerce-staging ecommerce-prod --ignore-not-found
    kubectl delete namespace argocd monitoring rhdh-operator --ignore-not-found
    
    success "Recursos Kubernetes removidos!"
}

# Limpar recursos Azure
cleanup_azure() {
    log "☁️ Limpando recursos Azure..."
    
    # Deletar resource group (remove tudo)
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    
    log "Remoção do resource group iniciada. Isso pode levar alguns minutos..."
    
    success "Recursos Azure sendo removidos!"
}

# Limpar GitHub
cleanup_github() {
    log "🐙 Limpando configurações GitHub..."
    
    # Remover webhooks
    local webhooks=$(gh api "/repos/${GITHUB_ORG}/${GITHUB_REPO}/hooks" --jq '.[].id')
    
    for webhook_id in $webhooks; do
        gh api --method DELETE "/repos/${GITHUB_ORG}/${GITHUB_REPO}/hooks/$webhook_id"
    done
    
    # Remover GitHub App (manual)
    warn "Por favor, remova manualmente o GitHub App em: https://github.com/organizations/${GITHUB_ORG}/settings/apps"
    
    success "Configurações GitHub limpas!"
}

# Limpar arquivos locais
cleanup_local_files() {
    log "📁 Limpando arquivos locais..."
    
    rm -f azure-config.env
    rm -f github-app-credentials.env
    rm -f github-app-private-key.pem
    rm -f prometheus-values.yaml
    rm -f github-app-manifest.json
    
    success "Arquivos locais removidos!"
}

# Main
main() {
    log "🧹 Iniciando limpeza completa..."
    
    confirm_cleanup
    
    cleanup_kubernetes
    cleanup_azure
    cleanup_github
    cleanup_local_files
    
    success "✅ Limpeza concluída!"
    warn "Nota: O resource group Azure ainda está sendo removido em background."
}

# Executar
main "$@"
```

## 🔧 Common Functions {#common-functions}

### Arquivo de Funções Comuns

```bash
#!/bin/bash
# scripts/common-functions.sh
# Funções comuns para todos os scripts

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Verificar comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Aguardar recurso ficar pronto
wait_for_resource() {
    local resource_type=$1
    local resource_name=$2
    local namespace=$3
    local timeout=${4:-300}
    
    log "⏳ Aguardando $resource_type/$resource_name ficar pronto..."
    
    kubectl wait --for=condition=ready "$resource_type/$resource_name" \
        -n "$namespace" \
        --timeout="${timeout}s"
}

# Verificar se namespace existe
namespace_exists() {
    kubectl get namespace "$1" &>/dev/null
}

# Criar namespace se não existir
ensure_namespace() {
    local namespace=$1
    
    if ! namespace_exists "$namespace"; then
        kubectl create namespace "$namespace"
    fi
}

# Gerar senha aleatória
generate_password() {
    local length=${1:-24}
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# Verificar se recurso Azure existe
azure_resource_exists() {
    local resource_type=$1
    local resource_name=$2
    local resource_group=$3
    
    az "$resource_type" show -n "$resource_name" -g "$resource_group" &>/dev/null
}

# Aguardar URL ficar acessível
wait_for_url() {
    local url=$1
    local timeout=${2:-300}
    local interval=${3:-5}
    local elapsed=0
    
    log "⏳ Aguardando $url ficar acessível..."
    
    while [ $elapsed -lt $timeout ]; do
        if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -E "200|301|302" &>/dev/null; then
            success "URL acessível!"
            return 0
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    error "Timeout aguardando URL"
    return 1
}

# Export variáveis padrão
export SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-aca2dc4a-9d62-4b64-82d4-11e152d98f02}"
export RESOURCE_GROUP="${RESOURCE_GROUP:-rg-threehorizons-demo}"
export LOCATION="${LOCATION:-centralus}"
export PROJECT_NAME="${PROJECT_NAME:-threehorizons}"
export ENVIRONMENT="${ENVIRONMENT:-demo}"
export DOMAIN="${DOMAIN:-demo.threehorizons.io}"
export GITHUB_ORG="${GITHUB_ORG:-three-horizon-ai}"
export GITHUB_REPO="${GITHUB_REPO:-Three-Horizons-AI-Developer-Platform}"
```

---

## 🎯 Próximos Passos

Com todos os scripts prontos:

1. Execute `./master-setup.sh` para configurar tudo
2. Valide com `./validate-setup.sh`
3. Acesse as URLs fornecidas
4. Execute a demonstração!

---

**📝 Checklist de Scripts**

- [ ] Master setup script criado
- [ ] Scripts Azure prontos
- [ ] Scripts GitHub/DevHub prontos
- [ ] Scripts de deployment prontos
- [ ] Scripts GitOps prontos
- [ ] Scripts de monitoramento prontos
- [ ] Scripts de validação prontos
- [ ] Scripts de limpeza prontos