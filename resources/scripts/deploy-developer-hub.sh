#!/bin/bash

# Red Hat Developer Hub Deployment Script
# Deploys the complete Three Horizons Platform with Developer Hub on AKS or ARO
# Usage: ./deploy-developer-hub.sh [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
PLATFORM="aks" # aks or aro
LOCATION="centralus"
SECONDARY_LOCATION="eastus2"
BASE_NAME="threehorizons"
SKIP_INFRA=false
SKIP_VALIDATION=false
DRY_RUN=false

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV      Environment (dev/test/prod) [default: dev]"
    echo "  -p, --platform PLATFORM    Platform (aks/aro) [default: aks]"
    echo "  -l, --location LOCATION    Primary location [default: centralus]"
    echo "  -n, --name NAME           Base name for resources [default: threehorizons]"
    echo "  --skip-infra              Skip infrastructure deployment"
    echo "  --skip-validation         Skip prerequisite validation"
    echo "  --dry-run                 Show what would be deployed without executing"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -p aks                    # Deploy to dev environment on AKS"
    echo "  $0 -e prod -p aro -l eastus         # Deploy to prod on ARO in East US"
    echo "  $0 --skip-infra                     # Deploy only Developer Hub"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -n|--name)
            BASE_NAME="$2"
            shift 2
            ;;
        --skip-infra)
            SKIP_INFRA=true
            shift
            ;;
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
    echo ""
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to print error messages and exit
print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate Azure CLI version
validate_azure_cli() {
    local required_version="2.50.0"
    local current_version=$(az version --query '"azure-cli"' -o tsv)
    
    if [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" != "$required_version" ]]; then
        print_error "Azure CLI version $current_version is less than required $required_version"
    fi
}

# Function to validate location and availability zones
validate_location() {
    local location=$1
    
    echo "Validating location: $location"
    
    # Check if location exists
    if ! az account list-locations --query "[?name=='$location']" -o tsv | grep -q "$location"; then
        print_error "Location '$location' is not valid"
    fi
    
    # Check availability zones for AKS
    if [[ "$PLATFORM" == "aks" ]]; then
        local zones=$(az aks get-versions --location "$location" --query "orchestrators[0].upgrades[0].isPreview" -o tsv 2>/dev/null || echo "")
        if [[ -z "$zones" ]]; then
            print_warning "Could not verify availability zones for AKS in $location"
        else
            print_success "Location $location supports AKS"
        fi
    fi
    
    # Check ARO availability
    if [[ "$PLATFORM" == "aro" ]]; then
        # ARO is available in specific regions
        local aro_regions=("eastus" "eastus2" "westus" "westus2" "westus3" "centralus" "southcentralus" "northcentralus" "canadacentral" "northeurope" "westeurope" "uksouth" "ukwest" "francecentral" "switzerlandnorth" "germanywestcentral" "norwayeast" "eastasia" "southeastasia" "japaneast" "japanwest" "koreacentral" "australiaeast" "australiasoutheast" "brazilsouth" "southafricanorth" "uaenorth" "centralindia")
        
        if [[ ! " ${aro_regions[@]} " =~ " ${location} " ]]; then
            print_error "ARO is not available in location '$location'. Available regions: ${aro_regions[*]}"
        else
            print_success "Location $location supports ARO"
        fi
    fi
}

# Function to validate prerequisites
validate_prerequisites() {
    print_header "Validating Prerequisites"
    
    # Check required commands
    local required_commands=("az" "kubectl" "helm" "jq")
    for cmd in "${required_commands[@]}"; do
        if command_exists "$cmd"; then
            print_success "$cmd is installed"
        else
            print_error "$cmd is not installed"
        fi
    done
    
    # Validate Azure CLI
    validate_azure_cli
    
    # Check Azure login
    if ! az account show >/dev/null 2>&1; then
        print_error "Not logged into Azure. Run 'az login' first"
    else
        local account=$(az account show --query name -o tsv)
        print_success "Logged into Azure account: $account"
    fi
    
    # Validate location
    validate_location "$LOCATION"
    
    # Check resource providers
    local providers=("Microsoft.ContainerService" "Microsoft.ContainerRegistry" "Microsoft.KeyVault" "Microsoft.Network" "Microsoft.OperationalInsights")
    if [[ "$PLATFORM" == "aro" ]]; then
        providers+=("Microsoft.RedHatOpenShift")
    fi
    
    for provider in "${providers[@]}"; do
        local state=$(az provider show -n "$provider" --query "registrationState" -o tsv)
        if [[ "$state" == "Registered" ]]; then
            print_success "Resource provider $provider is registered"
        else
            print_warning "Registering resource provider $provider..."
            az provider register -n "$provider" --wait
        fi
    done
}

# Function to generate secure passwords
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_header "Deploying Infrastructure"
    
    local deployment_name="${BASE_NAME}-${ENVIRONMENT}-$(date +%Y%m%d%H%M%S)"
    local template_file="resources/bicep/main/complete-infrastructure.bicep"
    local parameters_file="resources/bicep/parameters/${ENVIRONMENT}.parameters.json"
    
    # Generate passwords if not set
    if [[ -z "${POSTGRES_PASSWORD:-}" ]]; then
        POSTGRES_PASSWORD=$(generate_password)
        print_warning "Generated PostgreSQL password (save this): $POSTGRES_PASSWORD"
    fi
    
    # Build deployment parameters
    local deploy_aks="false"
    local deploy_aro="false"
    
    if [[ "$PLATFORM" == "aks" ]]; then
        deploy_aks="true"
    else
        deploy_aro="true"
    fi
    
    echo "Deployment configuration:"
    echo "  Name: $deployment_name"
    echo "  Environment: $ENVIRONMENT"
    echo "  Location: $LOCATION"
    echo "  Platform: $PLATFORM"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - Would deploy with these parameters"
        return
    fi
    
    # Deploy infrastructure
    az deployment sub create \
        --name "$deployment_name" \
        --location "$LOCATION" \
        --template-file "$template_file" \
        --parameters "$parameters_file" \
        --parameters baseName="$BASE_NAME" \
        --parameters environment="$ENVIRONMENT" \
        --parameters location="$LOCATION" \
        --parameters secondaryLocation="$SECONDARY_LOCATION" \
        --parameters deployAKS="$deploy_aks" \
        --parameters deployARO="$deploy_aro" \
        --parameters postgresAdminPassword="$POSTGRES_PASSWORD" \
        --output table
    
    # Store outputs
    DEPLOYMENT_OUTPUTS=$(az deployment sub show -n "$deployment_name" --query properties.outputs -o json)
    
    # Export important values
    export RESOURCE_GROUP="${BASE_NAME}-platform-${ENVIRONMENT}"
    export SHARED_RESOURCE_GROUP="${BASE_NAME}-shared-${ENVIRONMENT}"
    export CLUSTER_NAME="${BASE_NAME}-${PLATFORM}"
    export ACR_NAME=$(echo "$DEPLOYMENT_OUTPUTS" | jq -r '.acrLoginServer.value' | cut -d'.' -f1)
    export KEYVAULT_NAME=$(echo "$DEPLOYMENT_OUTPUTS" | jq -r '.keyVaultName.value')
    export POSTGRES_HOST=$(echo "$DEPLOYMENT_OUTPUTS" | jq -r '.postgresServerFqdn.value')
    
    print_success "Infrastructure deployed successfully"
}

# Function to configure kubectl context
configure_kubectl() {
    print_header "Configuring kubectl"
    
    if [[ "$PLATFORM" == "aks" ]]; then
        az aks get-credentials \
            --resource-group "$RESOURCE_GROUP" \
            --name "$CLUSTER_NAME" \
            --overwrite-existing
    else
        # For ARO, get the kubeconfig
        az aro get-credentials \
            --resource-group "$RESOURCE_GROUP" \
            --name "$CLUSTER_NAME"
    fi
    
    # Test connection
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "Connected to cluster $CLUSTER_NAME"
    else
        print_error "Failed to connect to cluster"
    fi
}

# Function to install cert-manager
install_cert_manager() {
    print_header "Installing cert-manager"
    
    # Check if already installed
    if kubectl get namespace cert-manager >/dev/null 2>&1; then
        print_warning "cert-manager already installed, skipping"
        return
    fi
    
    # Install cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
    
    # Wait for cert-manager to be ready
    echo "Waiting for cert-manager to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
    kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
    
    print_success "cert-manager installed"
}

# Function to install NGINX ingress controller
install_nginx_ingress() {
    print_header "Installing NGINX Ingress Controller"
    
    # Check if already installed
    if kubectl get namespace ingress-nginx >/dev/null 2>&1; then
        print_warning "NGINX ingress already installed, skipping"
        return
    fi
    
    # Add NGINX helm repo
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    # Install NGINX ingress
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --create-namespace \
        --namespace ingress-nginx \
        --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
        --wait
    
    # Get the external IP
    echo "Waiting for ingress external IP..."
    INGRESS_IP=""
    for i in {1..60}; do
        INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [[ -n "$INGRESS_IP" ]]; then
            break
        fi
        sleep 5
    done
    
    if [[ -z "$INGRESS_IP" ]]; then
        print_error "Failed to get ingress external IP"
    fi
    
    print_success "NGINX ingress installed with IP: $INGRESS_IP"
}

# Function to create Developer Hub namespace and secrets
create_devhub_namespace() {
    print_header "Creating Developer Hub Namespace"
    
    # Create namespace
    kubectl create namespace rhdh --dry-run=client -o yaml | kubectl apply -f -
    
    # Create pull secret for Red Hat registry
    if [[ -n "${REDHAT_PULL_SECRET:-}" ]]; then
        kubectl create secret generic redhat-pull-secret \
            --from-file=.dockerconfigjson="$REDHAT_PULL_SECRET" \
            --type=kubernetes.io/dockerconfigjson \
            --namespace rhdh \
            --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Create GitHub integration secret
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        kubectl create secret generic github-credentials \
            --from-literal=token="$GITHUB_TOKEN" \
            --namespace rhdh \
            --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Create PostgreSQL secret
    kubectl create secret generic postgres-credentials \
        --from-literal=postgres-user="backstage" \
        --from-literal=postgres-password="$POSTGRES_PASSWORD" \
        --namespace rhdh \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "Developer Hub namespace configured"
}

# Function to deploy Developer Hub
deploy_developer_hub() {
    print_header "Deploying Red Hat Developer Hub"
    
    # Add Red Hat helm repository
    helm repo add openshift-helm-charts https://charts.openshift.io/
    helm repo update
    
    # Create values file
    cat > /tmp/devhub-values.yaml <<EOF
global:
  clusterRouterBase: devhub.${INGRESS_IP}.nip.io
  
upstream:
  backstage:
    appConfig:
      app:
        title: Three Horizons Developer Platform
        baseUrl: https://devhub.${INGRESS_IP}.nip.io
      
      backend:
        auth:
          keys:
            - secret: \${BACKEND_SECRET}
        baseUrl: https://devhub.${INGRESS_IP}.nip.io
        cors:
          origin: https://devhub.${INGRESS_IP}.nip.io
        database:
          client: pg
          connection:
            host: ${POSTGRES_HOST}
            port: 5432
            user: backstage
            password: \${POSTGRES_PASSWORD}
            database: backstage
            ssl:
              require: true
              rejectUnauthorized: false
      
      integrations:
        github:
          - host: github.com
            token: \${GITHUB_TOKEN}
      
      catalog:
        import:
          entityFilename: catalog-info.yaml
          pullRequestBranchName: backstage-integration
        rules:
          - allow: [Component, System, API, Resource, Location, Template]
        locations:
          - type: url
            target: https://github.com/three-horizon-platform/Three-Horizons-Playbook/blob/main/catalog-info.yaml
      
      auth:
        environment: ${ENVIRONMENT}
        providers:
          github:
            ${ENVIRONMENT}:
              clientId: \${GITHUB_CLIENT_ID}
              clientSecret: \${GITHUB_CLIENT_SECRET}
      
      techdocs:
        builder: 'local'
        generator:
          runIn: 'docker'
        publisher:
          type: 'local'

    extraEnvVars:
      - name: BACKEND_SECRET
        valueFrom:
          secretKeyRef:
            name: backend-secret
            key: backend-secret
      - name: POSTGRES_PASSWORD
        valueFrom:
          secretKeyRef:
            name: postgres-credentials
            key: postgres-password
      - name: GITHUB_TOKEN
        valueFrom:
          secretKeyRef:
            name: github-credentials
            key: token

route:
  enabled: false

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  host: devhub.${INGRESS_IP}.nip.io
  tls:
    enabled: true
    secretName: devhub-tls

resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
EOF
    
    # Generate backend secret
    BACKEND_SECRET=$(openssl rand -base64 32)
    kubectl create secret generic backend-secret \
        --from-literal=backend-secret="$BACKEND_SECRET" \
        --namespace rhdh \
        --dry-run=client -o yaml | kubectl apply -f -
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - Would deploy Developer Hub with generated values"
        cat /tmp/devhub-values.yaml
        return
    fi
    
    # Deploy Developer Hub
    helm upgrade --install developer-hub \
        openshift-helm-charts/redhat-developer-hub \
        --namespace rhdh \
        --values /tmp/devhub-values.yaml \
        --wait \
        --timeout 10m
    
    print_success "Developer Hub deployed"
    echo ""
    echo "Access Developer Hub at: https://devhub.${INGRESS_IP}.nip.io"
}

# Function to create ClusterIssuer for Let's Encrypt
create_cluster_issuer() {
    print_header "Creating Let's Encrypt ClusterIssuer"
    
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@${BASE_NAME}.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
    
    print_success "ClusterIssuer created"
}

# Function to configure DNS (instructions)
configure_dns_instructions() {
    print_header "DNS Configuration Instructions"
    
    echo "To use a custom domain instead of nip.io:"
    echo ""
    echo "1. Create a DNS A record pointing to: $INGRESS_IP"
    echo "   Example: devhub.${BASE_NAME}.com -> $INGRESS_IP"
    echo ""
    echo "2. Update the Developer Hub values to use your domain:"
    echo "   helm upgrade developer-hub ... --set global.clusterRouterBase=devhub.${BASE_NAME}.com"
    echo ""
    echo "3. The Let's Encrypt certificate will be automatically issued"
}

# Function to save deployment information
save_deployment_info() {
    print_header "Saving Deployment Information"
    
    local info_file="${BASE_NAME}-${ENVIRONMENT}-deployment-info.json"
    
    cat > "$info_file" <<EOF
{
  "deployment": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "environment": "$ENVIRONMENT",
    "platform": "$PLATFORM",
    "location": "$LOCATION"
  },
  "resources": {
    "resourceGroup": "$RESOURCE_GROUP",
    "sharedResourceGroup": "$SHARED_RESOURCE_GROUP",
    "clusterName": "$CLUSTER_NAME",
    "acrName": "$ACR_NAME",
    "keyVaultName": "$KEYVAULT_NAME",
    "postgresHost": "$POSTGRES_HOST"
  },
  "access": {
    "developerHubUrl": "https://devhub.${INGRESS_IP}.nip.io",
    "ingressIP": "$INGRESS_IP"
  },
  "notes": {
    "postgresPassword": "Stored separately for security",
    "githubToken": "Configure in Key Vault",
    "customDomain": "See DNS configuration instructions"
  }
}
EOF
    
    print_success "Deployment information saved to: $info_file"
}

# Main execution
main() {
    echo -e "${BLUE}Three Horizons Platform - Developer Hub Deployment${NC}"
    echo "=================================================="
    echo ""
    
    # Validate prerequisites
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_prerequisites
    fi
    
    # Deploy infrastructure
    if [[ "$SKIP_INFRA" != "true" ]]; then
        deploy_infrastructure
    else
        # If skipping infra, we need these values
        if [[ -z "${RESOURCE_GROUP:-}" ]] || [[ -z "${CLUSTER_NAME:-}" ]]; then
            print_error "When using --skip-infra, you must set RESOURCE_GROUP and CLUSTER_NAME environment variables"
        fi
    fi
    
    # Configure kubectl
    configure_kubectl
    
    # Install prerequisites
    install_cert_manager
    install_nginx_ingress
    create_cluster_issuer
    
    # Deploy Developer Hub
    create_devhub_namespace
    deploy_developer_hub
    
    # Save deployment information
    save_deployment_info
    
    # Show DNS configuration instructions
    configure_dns_instructions
    
    print_header "Deployment Complete!"
    echo ""
    echo "Developer Hub URL: https://devhub.${INGRESS_IP}.nip.io"
    echo ""
    echo "Next steps:"
    echo "1. Configure GitHub OAuth App with the callback URL"
    echo "2. Update Developer Hub with GitHub OAuth credentials"
    echo "3. Import your software catalog"
    echo "4. Configure additional integrations"
    echo ""
    print_success "Deployment completed successfully!"
}

# Run main function
main 