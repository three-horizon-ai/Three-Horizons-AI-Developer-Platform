#!/bin/bash
#
# Three Horizons - Red Hat Developer Hub Installation Script
# This script automates the installation of Red Hat Developer Hub on Azure Red Hat OpenShift or AKS
#

set -e

# Default values
CLUSTER_TYPE="ARO"  # ARO or AKS
INSTALL_METHOD="operator"  # operator or helm
NAMESPACE="developer-hub"
DB_TYPE="azure-postgresql"  # azure-postgresql or in-cluster

# Display the banner
echo "======================================================================================"
echo "                                                                                      "
echo "  ████████╗██╗  ██╗██████╗ ███████╗███████╗    ██╗  ██╗ ██████╗ ██████╗ ██╗███████╗ "
echo "  ╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔════╝    ██║  ██║██╔═══██╗██╔══██╗██║╚══███╔╝ "
echo "     ██║   ███████║██████╔╝█████╗  █████╗      ███████║██║   ██║██████╔╝██║  ███╔╝  "
echo "     ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══╝      ██╔══██║██║   ██║██╔══██╗██║ ███╔╝   "
echo "     ██║   ██║  ██║██║  ██║███████╗███████╗    ██║  ██║╚██████╔╝██║  ██║██║███████╗ "
echo "     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝ "
echo "                                                                                      "
echo "                        Red Hat Developer Hub Installation                            "
echo "======================================================================================"
echo ""

# Display help message
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --cluster-type TYPE     Cluster type (ARO or AKS) [default: ARO]"
    echo "  -m, --method METHOD         Installation method (operator or helm) [default: operator]"
    echo "  -n, --namespace NAMESPACE   Kubernetes namespace [default: developer-hub]"
    echo "  -d, --database TYPE         Database type (azure-postgresql or in-cluster) [default: azure-postgresql]"
    echo "  -h, --help                  Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --cluster-type ARO --method operator --namespace developer-hub --database azure-postgresql"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--cluster-type)
            CLUSTER_TYPE="$2"
            shift 2
            ;;
        -m|--method)
            INSTALL_METHOD="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -d|--database)
            DB_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate input parameters
if [[ ! "$CLUSTER_TYPE" =~ ^(ARO|AKS)$ ]]; then
    echo "Error: Invalid cluster type. Must be ARO or AKS."
    exit 1
fi

if [[ ! "$INSTALL_METHOD" =~ ^(operator|helm)$ ]]; then
    echo "Error: Invalid installation method. Must be operator or helm."
    exit 1
fi

if [[ ! "$DB_TYPE" =~ ^(azure-postgresql|in-cluster)$ ]]; then
    echo "Error: Invalid database type. Must be azure-postgresql or in-cluster."
    exit 1
fi

# Check for required command-line tools
echo "Checking prerequisites..."
command -v az >/dev/null 2>&1 || { echo "Error: Azure CLI is required but not installed. Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required but not installed. Aborting."; exit 1; }

if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
    command -v oc >/dev/null 2>&1 || { echo "Error: OpenShift CLI (oc) is required but not installed. Aborting."; exit 1; }
fi

if [[ "$INSTALL_METHOD" == "helm" ]]; then
    command -v helm >/dev/null 2>&1 || { echo "Error: Helm is required but not installed. Aborting."; exit 1; }
fi

# Check if logged in to Azure
echo "Checking Azure login..."
az account show >/dev/null 2>&1 || { echo "Error: Not logged in to Azure. Run 'az login' first."; exit 1; }

# Check cluster connection
echo "Checking cluster connection..."
if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
    oc whoami >/dev/null 2>&1 || { echo "Error: Not logged in to OpenShift cluster. Please log in first."; exit 1; }
else
    kubectl get nodes >/dev/null 2>&1 || { echo "Error: Not connected to Kubernetes cluster. Please set up your kubeconfig first."; exit 1; }
fi

# Create namespace if it doesn't exist
echo "Creating namespace $NAMESPACE if it doesn't exist..."
if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
    oc get namespace $NAMESPACE >/dev/null 2>&1 || oc create namespace $NAMESPACE
else
    kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE
fi

# Install Developer Hub based on method and cluster type
echo "Starting Developer Hub installation with the following parameters:"
echo "  - Cluster Type: $CLUSTER_TYPE"
echo "  - Installation Method: $INSTALL_METHOD"
echo "  - Namespace: $NAMESPACE"
echo "  - Database Type: $DB_TYPE"
echo ""

if [[ "$CLUSTER_TYPE" == "ARO" && "$INSTALL_METHOD" == "operator" ]]; then
    echo "Installing Developer Hub on ARO using the operator..."
    # Install Operator
    echo "Creating Developer Hub operator subscription..."
    cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhd-hub-operator
  namespace: $NAMESPACE
spec:
  channel: stable
  installPlanApproval: Automatic
  name: rhd-hub-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Wait for operator to be ready
    echo "Waiting for the Developer Hub operator to be ready..."
    sleep 20
    
    # Create Developer Hub instance
    echo "Creating Developer Hub instance..."
    if [[ "$DB_TYPE" == "azure-postgresql" ]]; then
        # Prompt for database details if using Azure PostgreSQL
        read -p "Enter Azure PostgreSQL server host: " PG_HOST
        read -p "Enter Azure PostgreSQL database name [devhub]: " PG_DB
        PG_DB=${PG_DB:-devhub}
        read -p "Enter Azure PostgreSQL username: " PG_USER
        read -sp "Enter Azure PostgreSQL password: " PG_PASS
        echo ""
        
        # Create secret for database credentials
        cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: developer-hub-db-auth
  namespace: $NAMESPACE
type: Opaque
stringData:
  username: $PG_USER
  password: $PG_PASS
EOF

        # Create Developer Hub instance with external DB
        cat <<EOF | oc apply -f -
apiVersion: developer.hub/v1alpha1
kind: DeveloperHub
metadata:
  name: developer-hub
  namespace: $NAMESPACE
spec:
  database:
    enableTLS: true
    host: $PG_HOST
    name: $PG_DB
    port: 5432
    authSecret:
      name: developer-hub-db-auth
  image: registry.redhat.io/rhdh/rhdh-rhel9@sha256:abc123def456
EOF
    else
        # Create Developer Hub instance with in-cluster DB
        cat <<EOF | oc apply -f -
apiVersion: developer.hub/v1alpha1
kind: DeveloperHub
metadata:
  name: developer-hub
  namespace: $NAMESPACE
spec:
  database:
    enableTLS: false
    local: {}
  image: registry.redhat.io/rhdh/rhdh-rhel9@sha256:abc123def456
EOF
    fi
    
elif [[ "$CLUSTER_TYPE" == "ARO" && "$INSTALL_METHOD" == "helm" ]]; then
    echo "Installing Developer Hub on ARO using Helm..."
    # Add Helm repo
    helm repo add backstage https://backstage.github.io/charts
    helm repo update
    
    # Create values file
    cat > devhub-values.yaml <<EOF
# Developer Hub Helm values
global:
  clusterDomain: apps.example.com
  
backstage:
  image:
    registry: registry.redhat.io
    repository: rhdh/rhdh-rhel9
    tag: latest
  
  database:
EOF
    
    if [[ "$DB_TYPE" == "azure-postgresql" ]]; then
        # Prompt for database details if using Azure PostgreSQL
        read -p "Enter Azure PostgreSQL server host: " PG_HOST
        read -p "Enter Azure PostgreSQL database name [devhub]: " PG_DB
        PG_DB=${PG_DB:-devhub}
        read -p "Enter Azure PostgreSQL username: " PG_USER
        read -sp "Enter Azure PostgreSQL password: " PG_PASS
        echo ""
        
        # Add database config to values file
        cat >> devhub-values.yaml <<EOF
    enableTLS: true
    connection:
      host: $PG_HOST
      port: 5432
      user: $PG_USER
      password: $PG_PASS
      database: $PG_DB
EOF
    else
        # Add in-cluster database config to values file
        cat >> devhub-values.yaml <<EOF
    enableTLS: false
    local: true
EOF
    fi
    
    # Install using Helm
    helm install developer-hub backstage/backstage -n $NAMESPACE -f devhub-values.yaml
    
elif [[ "$CLUSTER_TYPE" == "AKS" ]]; then
    echo "Installing Developer Hub on AKS using Helm..."
    # Add Helm repo
    helm repo add backstage https://backstage.github.io/charts
    helm repo update
    
    # Create values file
    cat > devhub-values.yaml <<EOF
# Developer Hub Helm values
global:
  clusterDomain: apps.example.com
  
backstage:
  image:
    registry: registry.redhat.io
    repository: rhdh/rhdh-rhel9
    tag: latest
  
  database:
EOF
    
    if [[ "$DB_TYPE" == "azure-postgresql" ]]; then
        # Prompt for database details if using Azure PostgreSQL
        read -p "Enter Azure PostgreSQL server host: " PG_HOST
        read -p "Enter Azure PostgreSQL database name [devhub]: " PG_DB
        PG_DB=${PG_DB:-devhub}
        read -p "Enter Azure PostgreSQL username: " PG_USER
        read -sp "Enter Azure PostgreSQL password: " PG_PASS
        echo ""
        
        # Add database config to values file
        cat >> devhub-values.yaml <<EOF
    enableTLS: true
    connection:
      host: $PG_HOST
      port: 5432
      user: $PG_USER
      password: $PG_PASS
      database: $PG_DB
EOF
    else
        # Add in-cluster database config to values file
        cat >> devhub-values.yaml <<EOF
    enableTLS: false
    local: true
EOF
    fi
    
    # Install using Helm
    helm install developer-hub backstage/backstage -n $NAMESPACE -f devhub-values.yaml
fi

echo ""
echo "Developer Hub installation started. Check status with:"
if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
    echo "  oc get pods -n $NAMESPACE"
    echo ""
    echo "Once deployed, access Developer Hub at:"
    echo "  oc get route -n $NAMESPACE"
else
    echo "  kubectl get pods -n $NAMESPACE"
    echo ""
    echo "Once deployed, set up an ingress or port-forward with:"
    echo "  kubectl port-forward svc/developer-hub -n $NAMESPACE 7007:7007"
fi

echo ""
echo "Installation complete. For more information, visit the Three Horizons documentation."
echo "======================================================================================" 