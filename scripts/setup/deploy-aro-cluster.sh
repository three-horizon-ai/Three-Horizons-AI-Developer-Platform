#!/bin/bash
# Three Horizons: Azure Red Hat OpenShift (ARO) Deployment Script
# This script deploys an ARO cluster with the required configuration for Three Horizons

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    local type=$1
    local message=$2
    local color=$NC
    
    case $type in
        "info") color=$BLUE;;
        "success") color=$GREEN;;
        "warning") color=$YELLOW;;
        "error") color=$RED;;
    esac
    
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] [$type] $message${NC}"
}

# Prompt for input with default value
prompt_with_default() {
    local prompt=$1
    local default=$2
    local value

    read -p "$(echo -e $BLUE)$prompt$(echo -e $NC) [$default]: " value
    echo ${value:-$default}
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Azure Red Hat OpenShift Cluster Deployment        ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script will deploy an ARO cluster configured for Three Horizons platform."
    echo -e "Prerequisites:"
    echo -e "  - Azure CLI installed and logged in"
    echo -e "  - ARO resource provider registered"
    echo -e "  - Sufficient permissions to create resources"
    echo -e "  - Red Hat pull secret (optional but recommended)"
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Verify prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log "error" "Azure CLI is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log "warning" "You are not logged in to Azure. Please log in."
        az login --use-device-code
    fi
    
    # Check if ARO extension is installed
    if ! az extension show --name aro &> /dev/null; then
        log "info" "Installing ARO extension for Azure CLI..."
        az extension add --name aro
    fi
    
    # Check if ARO resource provider is registered
    if [[ "$(az provider show --namespace Microsoft.RedHatOpenShift --query registrationState -o tsv)" != "Registered" ]]; then
        log "info" "Registering ARO resource provider..."
        az provider register --namespace Microsoft.RedHatOpenShift --wait
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Collect deployment parameters
collect_parameters() {
    log "info" "Collecting deployment parameters..."
    
    # Get Azure subscription
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_ID=$(prompt_with_default "Azure Subscription ID" "$SUBSCRIPTION_ID")
    
    # Set subscription
    az account set --subscription $SUBSCRIPTION_ID
    log "success" "Using subscription: $(az account show --query name -o tsv)"
    
    # Basic deployment parameters
    RESOURCE_GROUP=$(prompt_with_default "Resource Group Name" "rg-three-horizons-aro")
    LOCATION=$(prompt_with_default "Azure Region" "centralus")
    CLUSTER_NAME=$(prompt_with_default "ARO Cluster Name" "aro-three-horizons")
    
    # Network parameters
    VNET_NAME=$(prompt_with_default "Virtual Network Name" "vnet-three-horizons")
    VNET_CIDR=$(prompt_with_default "VNet Address Space" "10.0.0.0/22")
    MASTER_SUBNET_NAME=$(prompt_with_default "Master Subnet Name" "snet-aro-master")
    MASTER_SUBNET_CIDR=$(prompt_with_default "Master Subnet CIDR" "10.0.0.0/23")
    WORKER_SUBNET_NAME=$(prompt_with_default "Worker Subnet Name" "snet-aro-worker")
    WORKER_SUBNET_CIDR=$(prompt_with_default "Worker Subnet CIDR" "10.0.2.0/23")
    
    # ARO cluster parameters
    WORKER_COUNT=$(prompt_with_default "Worker Node Count" "3")
    WORKER_VM_SIZE=$(prompt_with_default "Worker VM Size" "Standard_D4s_v3")
    MASTER_VM_SIZE=$(prompt_with_default "Master VM Size" "Standard_D8s_v3")
    
    # Pull secret (optional)
    read -p "$(echo -e $BLUE)Do you have a Red Hat pull secret? (y/N):$(echo -e $NC) " HAVE_PULL_SECRET
    if [[ "$HAVE_PULL_SECRET" == "y" || "$HAVE_PULL_SECRET" == "Y" ]]; then
        PULL_SECRET_PATH=$(prompt_with_default "Path to Pull Secret File" "$HOME/Downloads/pull-secret.txt")
        PULL_SECRET_ARG="--pull-secret @$PULL_SECRET_PATH"
    else
        PULL_SECRET_ARG=""
        log "warning" "Proceeding without pull secret. This may limit Red Hat container image access."
    fi
    
    # Display configuration summary
    echo
    log "info" "Deployment Configuration Summary:"
    echo -e "Resource Group: $RESOURCE_GROUP"
    echo -e "Region: $LOCATION"
    echo -e "Cluster Name: $CLUSTER_NAME"
    echo -e "Virtual Network: $VNET_NAME ($VNET_CIDR)"
    echo -e "Master Subnet: $MASTER_SUBNET_NAME ($MASTER_SUBNET_CIDR)"
    echo -e "Worker Subnet: $WORKER_SUBNET_NAME ($WORKER_SUBNET_CIDR)"
    echo -e "Worker Nodes: $WORKER_COUNT x $WORKER_VM_SIZE"
    echo -e "Master Nodes: 3 x $MASTER_VM_SIZE (fixed count)"
    echo
    
    # Confirm deployment
    read -p "$(echo -e $BLUE)Proceed with deployment? (y/N):$(echo -e $NC) " PROCEED
    if [[ "$PROCEED" != "y" && "$PROCEED" != "Y" ]]; then
        log "info" "Deployment cancelled by user."
        exit 0
    fi
}

# Create infrastructure resources
create_infrastructure() {
    log "info" "Creating infrastructure resources..."
    
    # Create resource group
    log "info" "Creating resource group: $RESOURCE_GROUP"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    
    # Create virtual network
    log "info" "Creating virtual network: $VNET_NAME"
    az network vnet create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VNET_NAME" \
        --address-prefixes "$VNET_CIDR"
    
    # Create master subnet
    log "info" "Creating master subnet: $MASTER_SUBNET_NAME"
    az network vnet subnet create \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "$MASTER_SUBNET_NAME" \
        --address-prefixes "$MASTER_SUBNET_CIDR" \
        --service-endpoints Microsoft.ContainerRegistry
    
    # Create worker subnet
    log "info" "Creating worker subnet: $WORKER_SUBNET_NAME"
    az network vnet subnet create \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "$WORKER_SUBNET_NAME" \
        --address-prefixes "$WORKER_SUBNET_CIDR" \
        --service-endpoints Microsoft.ContainerRegistry
    
    # Update master subnet for private link
    log "info" "Updating master subnet for private link service"
    az network vnet subnet update \
        --name "$MASTER_SUBNET_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --disable-private-link-service-network-policies true
    
    log "success" "Infrastructure resources created successfully."
}

# Deploy ARO cluster
deploy_aro_cluster() {
    log "info" "Deploying ARO cluster (this will take 30-40 minutes)..."
    
    # Create ARO cluster
    log "info" "Creating ARO cluster: $CLUSTER_NAME"
    az aro create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --vnet "$VNET_NAME" \
        --master-subnet "$MASTER_SUBNET_NAME" \
        --worker-subnet "$WORKER_SUBNET_NAME" \
        --worker-count "$WORKER_COUNT" \
        --worker-vm-size "$WORKER_VM_SIZE" \
        --master-vm-size "$MASTER_VM_SIZE" \
        $PULL_SECRET_ARG \
        --no-wait
    
    log "info" "ARO cluster deployment initiated. This will take approximately 30-40 minutes to complete."
    log "info" "You can check the deployment status with:"
    echo "az aro show -g $RESOURCE_GROUP -n $CLUSTER_NAME --query provisioningState -o tsv"
    
    # Ask if user wants to wait for deployment
    read -p "$(echo -e $BLUE)Would you like to wait for the deployment to complete? (y/N):$(echo -e $NC) " WAIT_FOR_DEPLOYMENT
    if [[ "$WAIT_FOR_DEPLOYMENT" == "y" || "$WAIT_FOR_DEPLOYMENT" == "Y" ]]; then
        log "info" "Waiting for ARO cluster deployment to complete (this may take 30-40 minutes)..."
        
        # Wait for deployment to complete
        while true; do
            PROVISIONING_STATE=$(az aro show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --query provisioningState -o tsv 2>/dev/null || echo "NotFound")
            
            if [[ "$PROVISIONING_STATE" == "Succeeded" ]]; then
                log "success" "ARO cluster deployed successfully."
                break
            elif [[ "$PROVISIONING_STATE" == "Failed" ]]; then
                log "error" "ARO cluster deployment failed. Please check the Azure portal for details."
                exit 1
            elif [[ "$PROVISIONING_STATE" == "NotFound" ]]; then
                log "info" "Waiting for deployment to start..."
            else
                log "info" "Current provisioning state: $PROVISIONING_STATE"
            fi
            
            sleep 60
        done
    else
        log "info" "Continuing without waiting for deployment completion."
    fi
}

# Get cluster credentials and information
get_cluster_info() {
    log "info" "Retrieving cluster credentials and information..."
    
    # Check if cluster is ready
    if [[ "$(az aro show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --query provisioningState -o tsv 2>/dev/null)" != "Succeeded" ]]; then
        log "warning" "Cluster is not yet ready. Skipping credential retrieval."
        return
    fi
    
    # Get cluster credentials
    log "info" "Retrieving ARO cluster credentials"
    ARO_USERNAME=$(az aro list-credentials \
        --name "$CLUSTER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query 'kubeadminUsername' -o tsv)
    
    ARO_PASSWORD=$(az aro list-credentials \
        --name "$CLUSTER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query 'kubeadminPassword' -o tsv)
    
    # Get API server URL
    API_SERVER=$(az aro show \
        --name "$CLUSTER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query apiserverProfile.url -o tsv)
    
    # Get console URL
    CONSOLE_URL=$(az aro show \
        --name "$CLUSTER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query consoleProfile.url -o tsv)
    
    # Save output information
    OUTPUT_FILE="aro_cluster_info.txt"
    log "info" "Saving cluster information to $OUTPUT_FILE"
    
    cat > $OUTPUT_FILE << EOF
Three Horizons - Azure Red Hat OpenShift Cluster Information
===========================================================
Deployment Timestamp: $(date +'%Y-%m-%d %H:%M:%S')

Resource Group: $RESOURCE_GROUP
Cluster Name: $CLUSTER_NAME
Region: $LOCATION

Access Information:
------------------
API Server URL: $API_SERVER
Console URL: $CONSOLE_URL
Username: $ARO_USERNAME
Password: $ARO_PASSWORD

Virtual Network: $VNET_NAME
Master Subnet: $MASTER_SUBNET_NAME
Worker Subnet: $WORKER_SUBNET_NAME
Worker Nodes: $WORKER_COUNT x $WORKER_VM_SIZE
Master Nodes: 3 x $MASTER_VM_SIZE

Next Steps:
----------
1. Access the OpenShift web console:
   $CONSOLE_URL

2. Log in with the credentials above

3. Connect using the OpenShift CLI:
   oc login $API_SERVER -u $ARO_USERNAME -p $ARO_PASSWORD

4. Install the Red Hat Developer Hub Operator:
   ./scripts/setup/install-devhub-operator.sh

Note: Keep this information secure as it contains cluster credentials.
EOF
    
    chmod 600 "$OUTPUT_FILE"
    log "success" "Cluster information saved to $OUTPUT_FILE"
}

# Main execution
main() {
    display_banner
    check_prerequisites
    collect_parameters
    create_infrastructure
    deploy_aro_cluster
    get_cluster_info
    
    log "success" "ARO cluster deployment process completed!"
    log "info" "Follow the next steps in the Three Horizons implementation guide to install Red Hat Developer Hub."
}

# Run the script
main 