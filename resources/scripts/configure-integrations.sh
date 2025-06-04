#!/bin/bash

# Integration Configuration Script for Red Hat Developer Hub
# Configures GitHub OAuth, catalog imports, and other integrations
# Usage: ./configure-integrations.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NAMESPACE="rhdh"
DEVHUB_URL=""
GITHUB_ORG=""
GITHUB_TOKEN=""
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""

print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Get Developer Hub URL
get_devhub_url() {
    print_header "Getting Developer Hub URL"
    
    # Try to get from ingress
    local ingress_host=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[0].spec.rules[0].host}' 2>/dev/null || echo "")
    
    if [[ -n "$ingress_host" ]]; then
        DEVHUB_URL="https://$ingress_host"
        print_success "Developer Hub URL: $DEVHUB_URL"
    else
        # Try to get from service
        local service_ip=$(kubectl get svc -n "$NAMESPACE" -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [[ -n "$service_ip" ]]; then
            DEVHUB_URL="http://$service_ip"
            print_warning "Using service IP (no ingress found): $DEVHUB_URL"
        else
            print_error "Could not determine Developer Hub URL"
        fi
    fi
}

# Configure GitHub OAuth
configure_github_oauth() {
    print_header "Configuring GitHub OAuth"
    
    echo "To configure GitHub OAuth, you need to:"
    echo ""
    echo "1. Go to GitHub Settings > Developer settings > OAuth Apps"
    echo "2. Click 'New OAuth App' or 'Register a new application'"
    echo "3. Fill in the following details:"
    echo ""
    echo "   Application name: Three Horizons Developer Hub"
    echo "   Homepage URL: $DEVHUB_URL"
    echo "   Authorization callback URL: $DEVHUB_URL/api/auth/github/handler/frame"
    echo ""
    echo "4. After creating the app, you'll get a Client ID and Client Secret"
    echo ""
    
    # Prompt for GitHub OAuth credentials
    read -p "Enter GitHub OAuth Client ID: " GITHUB_CLIENT_ID
    read -s -p "Enter GitHub OAuth Client Secret: " GITHUB_CLIENT_SECRET
    echo ""
    
    # Create secret
    kubectl create secret generic github-oauth \
        --from-literal=clientId="$GITHUB_CLIENT_ID" \
        --from-literal=clientSecret="$GITHUB_CLIENT_SECRET" \
        --namespace "$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "GitHub OAuth credentials configured"
}

# Configure GitHub integration token
configure_github_token() {
    print_header "Configuring GitHub Integration Token"
    
    echo "A GitHub Personal Access Token is needed for:"
    echo "- Reading repositories"
    echo "- Creating pull requests"
    echo "- Managing workflows"
    echo ""
    echo "Required scopes: repo, workflow, read:org, read:user"
    echo ""
    
    read -s -p "Enter GitHub Personal Access Token: " GITHUB_TOKEN
    echo ""
    
    # Update secret
    kubectl create secret generic github-credentials \
        --from-literal=token="$GITHUB_TOKEN" \
        --namespace "$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "GitHub token configured"
}

# Import software catalog
import_catalog() {
    print_header "Importing Software Catalog"
    
    read -p "Enter your GitHub organization/username: " GITHUB_ORG
    
    # Create catalog locations ConfigMap
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: catalog-locations
  namespace: $NAMESPACE
data:
  locations.yaml: |
    catalog:
      locations:
        - type: url
          target: https://github.com/${GITHUB_ORG}/Three-Horizons-Playbook/blob/main/catalog-info.yaml
          rules:
            - allow: [Component, System, API, Resource, Location, Template]
        
        - type: url
          target: https://github.com/${GITHUB_ORG}/Three-Horizons-Playbook/blob/main/resources/applications/*/template.yaml
          rules:
            - allow: [Template]
        
        - type: github-discovery
          target: https://github.com/${GITHUB_ORG}
          rules:
            - allow: [Component, System, API, Resource]
EOF
    
    print_success "Catalog locations configured"
    
    # Restart Developer Hub to pick up changes
    kubectl rollout restart deployment -n "$NAMESPACE"
    print_success "Developer Hub restarted to apply configuration"
}

# Configure Azure integration
configure_azure() {
    print_header "Configuring Azure Integration"
    
    echo "Azure integration allows Developer Hub to:"
    echo "- Provision Azure resources"
    echo "- Manage AKS clusters"
    echo "- Access Key Vault secrets"
    echo ""
    
    read -p "Do you want to configure Azure integration? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping Azure integration"
        return
    fi
    
    # Get Azure credentials
    local tenant_id=$(az account show --query tenantId -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    
    echo "Creating Azure Service Principal for Developer Hub..."
    
    local sp_name="devhub-azure-integration-$(date +%s)"
    local sp_output=$(az ad sp create-for-rbac --name "$sp_name" --role Contributor --scopes "/subscriptions/$subscription_id" -o json)
    
    local client_id=$(echo "$sp_output" | jq -r '.appId')
    local client_secret=$(echo "$sp_output" | jq -r '.password')
    
    # Create secret
    kubectl create secret generic azure-credentials \
        --from-literal=tenantId="$tenant_id" \
        --from-literal=subscriptionId="$subscription_id" \
        --from-literal=clientId="$client_id" \
        --from-literal=clientSecret="$client_secret" \
        --namespace "$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "Azure integration configured"
    echo ""
    echo "Service Principal created: $sp_name"
    echo "Client ID: $client_id"
}

# Configure templates
configure_templates() {
    print_header "Configuring Software Templates"
    
    # Create template configuration
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: template-config
  namespace: $NAMESPACE
data:
  templates.yaml: |
    scaffolder:
      defaultAuthor:
        name: Three Horizons Platform
        email: platform@threehorizons.com
      defaultCommitMessage: "Initial commit from Developer Hub template"
      
    integrations:
      github:
        - host: github.com
          token: \${GITHUB_TOKEN}
          
    catalog:
      locations:
        - type: url
          target: https://github.com/three-horizon-platform/Three-Horizons-Playbook/blob/main/resources/applications/web-application/template.yaml
        - type: url
          target: https://github.com/three-horizon-platform/Three-Horizons-Playbook/blob/main/resources/applications/kubernetes-application/template.yaml
EOF
    
    print_success "Templates configured"
}

# Configure TechDocs
configure_techdocs() {
    print_header "Configuring TechDocs"
    
    # Check if storage account exists
    local storage_account=$(kubectl get secret -n "$NAMESPACE" techdocs-storage -o jsonpath='{.data.accountName}' 2>/dev/null | base64 -d || echo "")
    
    if [[ -z "$storage_account" ]]; then
        echo "TechDocs requires a storage account for documentation"
        read -p "Enter Azure Storage Account name (or press Enter to skip): " storage_account
        
        if [[ -n "$storage_account" ]]; then
            read -s -p "Enter Storage Account key: " storage_key
            echo ""
            
            kubectl create secret generic techdocs-storage \
                --from-literal=accountName="$storage_account" \
                --from-literal=accountKey="$storage_key" \
                --namespace "$NAMESPACE" \
                --dry-run=client -o yaml | kubectl apply -f -
            
            print_success "TechDocs storage configured"
        else
            print_warning "Skipping TechDocs storage configuration"
        fi
    else
        print_success "TechDocs storage already configured"
    fi
}

# Verify configuration
verify_configuration() {
    print_header "Verifying Configuration"
    
    # Check secrets
    local secrets=("github-credentials" "github-oauth")
    for secret in "${secrets[@]}"; do
        if kubectl get secret "$secret" -n "$NAMESPACE" >/dev/null 2>&1; then
            print_success "Secret $secret exists"
        else
            print_warning "Secret $secret not found"
        fi
    done
    
    # Check Developer Hub pods
    local pod_status=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "")
    if [[ "$pod_status" == "Running" ]]; then
        print_success "Developer Hub is running"
    else
        print_warning "Developer Hub pod status: $pod_status"
    fi
    
    # Test Developer Hub access
    if command -v curl >/dev/null 2>&1; then
        if curl -sk "$DEVHUB_URL/api/health" | grep -q "ok"; then
            print_success "Developer Hub API is healthy"
        else
            print_warning "Could not verify Developer Hub API health"
        fi
    fi
}

# Generate post-configuration report
generate_report() {
    print_header "Configuration Summary"
    
    cat > "devhub-config-summary.txt" <<EOF
Three Horizons Developer Hub Configuration Summary
================================================

Developer Hub URL: $DEVHUB_URL

Configured Integrations:
- GitHub OAuth: Configured
- GitHub Token: Configured
- Software Catalog: Imported from $GITHUB_ORG
- Azure Integration: $(kubectl get secret azure-credentials -n "$NAMESPACE" >/dev/null 2>&1 && echo "Configured" || echo "Not configured")
- TechDocs Storage: $(kubectl get secret techdocs-storage -n "$NAMESPACE" >/dev/null 2>&1 && echo "Configured" || echo "Not configured")

Next Steps:
1. Access Developer Hub at: $DEVHUB_URL
2. Log in with your GitHub account
3. Browse the software catalog
4. Create new components from templates
5. View component documentation in TechDocs

Troubleshooting:
- Logs: kubectl logs -n $NAMESPACE -l app=developer-hub
- Events: kubectl get events -n $NAMESPACE
- Secrets: kubectl get secrets -n $NAMESPACE

For more information, see:
- https://developers.redhat.com/products/red-hat-developer-hub
- https://backstage.io/docs
EOF
    
    print_success "Configuration summary saved to: devhub-config-summary.txt"
}

# Main execution
main() {
    echo -e "${BLUE}Three Horizons Developer Hub - Integration Configuration${NC}"
    echo "===================================================="
    echo ""
    
    # Check if kubectl is configured
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "kubectl not configured. Please run 'az aks get-credentials' first"
    fi
    
    # Get Developer Hub URL
    get_devhub_url
    
    # Configure integrations
    configure_github_oauth
    configure_github_token
    import_catalog
    configure_azure
    configure_templates
    configure_techdocs
    
    # Verify and report
    verify_configuration
    generate_report
    
    print_header "Configuration Complete!"
    echo ""
    echo "Developer Hub is ready at: $DEVHUB_URL"
    echo ""
    echo "Default login: Use your GitHub account"
    echo "Software catalog will sync within a few minutes"
    echo ""
    print_success "All integrations configured successfully!"
}

# Run main
main 