#!/bin/bash

# Deployment Validation Script
# Validates Azure environment and prerequisites for Three Horizons Platform deployment
# Usage: ./validate-deployment.sh [location]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default location
LOCATION="${1:-centralus}"

# Results tracking
VALIDATION_PASSED=true
WARNINGS=()
ERRORS=()

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
    WARNINGS+=("$1")
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ERRORS+=("$1")
    VALIDATION_PASSED=false
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate tools
validate_tools() {
    print_header "Validating Required Tools"
    
    # Azure CLI
    if command_exists az; then
        local az_version=$(az version --query '"azure-cli"' -o tsv)
        print_success "Azure CLI installed (version: $az_version)"
        
        # Check minimum version
        local min_version="2.50.0"
        if [[ "$(printf '%s\n' "$min_version" "$az_version" | sort -V | head -n1)" != "$min_version" ]]; then
            print_warning "Azure CLI version $az_version is older than recommended $min_version"
        fi
    else
        print_error "Azure CLI not installed"
    fi
    
    # kubectl
    if command_exists kubectl; then
        local kubectl_version=$(kubectl version --client --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        print_success "kubectl installed (version: $kubectl_version)"
    else
        print_error "kubectl not installed"
    fi
    
    # Helm
    if command_exists helm; then
        local helm_version=$(helm version --short 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        print_success "Helm installed (version: $helm_version)"
        
        # Check minimum version
        if [[ "$helm_version" != "unknown" ]]; then
            local min_helm="v3.10.0"
            if [[ "$(printf '%s\n' "$min_helm" "$helm_version" | sort -V | head -n1)" != "$min_helm" ]]; then
                print_warning "Helm version $helm_version is older than recommended $min_helm"
            fi
        fi
    else
        print_error "Helm not installed"
    fi
    
    # jq
    if command_exists jq; then
        print_success "jq installed"
    else
        print_error "jq not installed"
    fi
    
    # openssl (for password generation)
    if command_exists openssl; then
        print_success "openssl installed"
    else
        print_warning "openssl not installed (needed for password generation)"
    fi
}

# Validate Azure authentication
validate_azure_auth() {
    print_header "Validating Azure Authentication"
    
    if ! az account show >/dev/null 2>&1; then
        print_error "Not logged into Azure. Run 'az login' first"
        return
    fi
    
    local account_name=$(az account show --query name -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    local tenant_id=$(az account show --query tenantId -o tsv)
    
    print_success "Logged into Azure"
    echo "  Account: $account_name"
    echo "  Subscription: $subscription_id"
    echo "  Tenant: $tenant_id"
    
    # Check if user has required permissions
    local user_id=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "")
    if [[ -n "$user_id" ]]; then
        # Check for Contributor role
        local has_contributor=$(az role assignment list --assignee "$user_id" --query "[?roleDefinitionName=='Contributor'].roleDefinitionName" -o tsv | head -n1)
        if [[ -n "$has_contributor" ]]; then
            print_success "User has Contributor role"
        else
            print_warning "User may not have sufficient permissions (Contributor role recommended)"
        fi
    fi
}

# Validate location
validate_location() {
    print_header "Validating Location: $LOCATION"
    
    # Check if location exists
    local location_exists=$(az account list-locations --query "[?name=='$LOCATION'].displayName" -o tsv | head -n1)
    if [[ -z "$location_exists" ]]; then
        print_error "Location '$LOCATION' is not valid"
        echo "  Available locations:"
        az account list-locations --query "[].name" -o tsv | sort | head -20
        return
    fi
    
    print_success "Location '$LOCATION' is valid ($location_exists)"
    
    # Check availability zones
    echo ""
    echo "Checking service availability in $LOCATION..."
    
    # AKS availability
    local aks_available=$(az provider show -n Microsoft.ContainerService --query "resourceTypes[?resourceType=='managedClusters'].locations" -o tsv | grep -i "$LOCATION" || echo "")
    if [[ -n "$aks_available" ]]; then
        print_success "AKS is available in $LOCATION"
        
        # Check for availability zones
        local zones_output=$(az aks get-versions --location "$LOCATION" --query "values[0].patchVersions" -o json 2>/dev/null || echo "{}")
        if [[ "$zones_output" != "{}" ]] && [[ "$zones_output" != "null" ]]; then
            print_success "Availability zones supported for AKS"
        else
            print_warning "Could not verify availability zones for AKS"
        fi
    else
        print_warning "AKS may not be available in $LOCATION"
    fi
    
    # ARO availability
    local aro_regions=("eastus" "eastus2" "westus" "westus2" "westus3" "centralus" "southcentralus" "northcentralus" "canadacentral" "northeurope" "westeurope" "uksouth" "ukwest" "francecentral" "switzerlandnorth" "germanywestcentral" "norwayeast" "eastasia" "southeastasia" "japaneast" "japanwest" "koreacentral" "australiaeast" "australiasoutheast" "brazilsouth" "southafricanorth" "uaenorth" "centralindia")
    
    if [[ " ${aro_regions[@]} " =~ " ${LOCATION} " ]]; then
        print_success "ARO is available in $LOCATION"
    else
        print_warning "ARO is not available in $LOCATION"
    fi
    
    # Other services
    local services=("Microsoft.ContainerRegistry" "Microsoft.KeyVault" "Microsoft.DBforPostgreSQL" "Microsoft.Storage" "Microsoft.Network")
    for service in "${services[@]}"; do
        local available=$(az provider show -n "$service" --query "resourceTypes[0].locations" -o tsv | grep -i "$LOCATION" || echo "")
        if [[ -n "$available" ]]; then
            print_success "$service is available"
        else
            print_warning "$service availability could not be verified"
        fi
    done
}

# Validate resource providers
validate_providers() {
    print_header "Validating Resource Providers"
    
    local required_providers=(
        "Microsoft.ContainerService"
        "Microsoft.ContainerRegistry"
        "Microsoft.KeyVault"
        "Microsoft.Network"
        "Microsoft.OperationalInsights"
        "Microsoft.ManagedIdentity"
        "Microsoft.DBforPostgreSQL"
        "Microsoft.Storage"
    )
    
    for provider in "${required_providers[@]}"; do
        local state=$(az provider show -n "$provider" --query "registrationState" -o tsv 2>/dev/null || echo "NotFound")
        
        case "$state" in
            "Registered")
                print_success "$provider is registered"
                ;;
            "Registering")
                print_warning "$provider is still registering"
                ;;
            "NotRegistered")
                print_warning "$provider is not registered (will be registered during deployment)"
                ;;
            *)
                print_error "$provider status unknown: $state"
                ;;
        esac
    done
}

# Check quotas
check_quotas() {
    print_header "Checking Resource Quotas"
    
    echo "Checking compute quotas in $LOCATION..."
    
    # Check vCPU quota
    local vcpu_usage=$(az vm list-usage --location "$LOCATION" --query "[?name.value=='cores'].{current:currentValue, limit:limit}" -o json | jq -r '.[0] // {current: "unknown", limit: "unknown"}')
    local current_vcpus=$(echo "$vcpu_usage" | jq -r '.current // "unknown"')
    local limit_vcpus=$(echo "$vcpu_usage" | jq -r '.limit // "unknown"')
    
    if [[ "$current_vcpus" != "unknown" ]] && [[ "$limit_vcpus" != "unknown" ]]; then
        local available_vcpus=$((limit_vcpus - current_vcpus))
        
        if [[ $available_vcpus -ge 16 ]]; then
            print_success "Sufficient vCPU quota available ($available_vcpus vCPUs remaining)"
        elif [[ $available_vcpus -ge 8 ]]; then
            print_warning "Limited vCPU quota available ($available_vcpus vCPUs remaining)"
        else
            print_error "Insufficient vCPU quota ($available_vcpus vCPUs remaining, need at least 8)"
        fi
    else
        print_warning "Could not verify vCPU quota"
    fi
    
    # Check specific VM SKUs for AKS
    local aks_sku="Standard_D4s_v3"
    local sku_usage=$(az vm list-usage --location "$LOCATION" --query "[?name.value=='$aks_sku'].{current:currentValue, limit:limit}" -o json | jq -r '.[0] // {current: "0", limit: "unknown"}')
    local sku_limit=$(echo "$sku_usage" | jq -r '.limit // "unknown"')
    
    if [[ "$sku_limit" != "unknown" ]] && [[ "$sku_limit" != "0" ]]; then
        print_success "$aks_sku SKU is available (limit: $sku_limit)"
    else
        print_warning "Could not verify $aks_sku SKU availability"
    fi
}

# Check network configuration
check_network() {
    print_header "Checking Network Configuration"
    
    # Check if any VNets exist that might conflict
    local existing_vnets=$(az network vnet list --query "[?location=='$LOCATION'].{name:name, addressSpace:addressSpace.addressPrefixes[0]}" -o json)
    local vnet_count=$(echo "$existing_vnets" | jq '. | length')
    
    if [[ $vnet_count -gt 0 ]]; then
        print_warning "Found $vnet_count existing VNet(s) in $LOCATION"
        echo "$existing_vnets" | jq -r '.[] | "  - \(.name): \(.addressSpace)"'
        echo ""
        echo "  Ensure the address space 10.0.0.0/16 doesn't conflict"
    else
        print_success "No existing VNets found in $LOCATION"
    fi
    
    # Check DNS configuration
    if command_exists nslookup; then
        if nslookup github.com >/dev/null 2>&1; then
            print_success "DNS resolution working"
        else
            print_warning "DNS resolution may have issues"
        fi
    fi
}

# Estimate costs
estimate_costs() {
    print_header "Estimated Costs"
    
    echo "Approximate monthly costs for Three Horizons Platform:"
    echo ""
    echo "AKS Deployment:"
    echo "  - AKS Cluster (3x D4s_v3): ~\$300-400/month"
    echo "  - Container Registry (Premium): ~\$50/month"
    echo "  - PostgreSQL Flexible Server: ~\$100-150/month"
    echo "  - Key Vault: ~\$5/month"
    echo "  - Log Analytics: ~\$50-100/month"
    echo "  - Storage Account: ~\$20/month"
    echo "  - Network (Load Balancer, IP): ~\$30/month"
    echo ""
    echo "Total estimated: ~\$600-800/month for dev environment"
    echo ""
    echo "ARO Deployment adds:"
    echo "  - ARO Cluster (3x D4s_v3): ~\$500-600/month"
    echo ""
    print_warning "Actual costs may vary based on usage and region"
}

# Generate summary report
generate_summary() {
    print_header "Validation Summary"
    
    if [[ ${#ERRORS[@]} -eq 0 ]]; then
        print_success "All critical validations passed!"
    else
        print_error "Found ${#ERRORS[@]} critical error(s):"
        for error in "${ERRORS[@]}"; do
            echo "  - $error"
        done
    fi
    
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo ""
        print_warning "Found ${#WARNINGS[@]} warning(s):"
        for warning in "${WARNINGS[@]}"; do
            echo "  - $warning"
        done
    fi
    
    echo ""
    if [[ "$VALIDATION_PASSED" == "true" ]]; then
        print_success "Environment is ready for deployment!"
        echo ""
        echo "Next steps:"
        echo "1. Run: ./deploy-developer-hub.sh -e dev -p aks -l $LOCATION"
        echo "2. Save the generated passwords securely"
        echo "3. Configure GitHub OAuth after deployment"
    else
        print_error "Please fix the errors before proceeding with deployment"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Three Horizons Platform - Deployment Validation${NC}"
    echo "=============================================="
    echo ""
    echo "Validating environment for location: $LOCATION"
    
    validate_tools
    validate_azure_auth
    validate_location
    validate_providers
    check_quotas
    check_network
    estimate_costs
    generate_summary
}

# Run validation
main 