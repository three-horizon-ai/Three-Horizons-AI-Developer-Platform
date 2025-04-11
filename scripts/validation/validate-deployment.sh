#!/bin/bash
# Three Horizons: Deployment Validation Script
# This script validates a deployed Three Horizons platform environment

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for reporting
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Log function
log() {
    local type=$1
    local message=$2
    local color=$NC
    
    case $type in
        "info") color=$BLUE;;
        "success") color=$GREEN; PASS_COUNT=$((PASS_COUNT + 1));;
        "warning") color=$YELLOW; WARN_COUNT=$((WARN_COUNT + 1));;
        "error") color=$RED; FAIL_COUNT=$((FAIL_COUNT + 1));;
    esac
    
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] [$type] $message${NC}"
}

# Display help information
show_help() {
    echo -e "${BOLD}Three Horizons Platform Deployment Validation Script${NC}"
    echo
    echo "This script validates a deployed Three Horizons platform by checking"
    echo "infrastructure, component health, integrations, and configuration."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --cluster-type TYPE      Cluster type (ARO, AKS)"
    echo "  --resource-group RG      Azure resource group name"
    echo "  --all-components         Validate all platform components"
    echo "  --output-format FORMAT   Report format (text, json, html) [default: text]"
    echo "  -h, --help               Show this help message"
    echo
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Platform Deployment Validation                    ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script will validate the Three Horizons platform deployment."
    echo -e "It checks infrastructure, component health, integrations, and configuration."
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cluster-type)
                CLUSTER_TYPE=$2
                shift 2
                ;;
            --resource-group)
                RESOURCE_GROUP=$2
                shift 2
                ;;
            --all-components)
                ALL_COMPONENTS=true
                shift
                ;;
            --output-format)
                OUTPUT_FORMAT=$2
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log "error" "Unknown parameter: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$CLUSTER_TYPE" ]]; then
        log "error" "Cluster type must be specified with --cluster-type"
        show_help
        exit 1
    fi
    
    if [[ -z "$RESOURCE_GROUP" ]]; then
        log "error" "Resource group must be specified with --resource-group"
        show_help
        exit 1
    fi
    
    # Set defaults
    ALL_COMPONENTS=${ALL_COMPONENTS:-false}
    OUTPUT_FORMAT=${OUTPUT_FORMAT:-text}
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log "error" "Azure CLI is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log "error" "kubectl is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log "warning" "You are not logged in to Azure. Please log in."
        az login --use-device-code
    fi
    
    # Check if jq is installed (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        log "warning" "jq is not installed. Some validation checks may be limited."
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Connect to the cluster
connect_to_cluster() {
    log "info" "Connecting to $CLUSTER_TYPE cluster in resource group $RESOURCE_GROUP..."
    
    case $CLUSTER_TYPE in
        ARO)
            # Get ARO cluster name
            CLUSTER_NAME=$(az aro list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
            
            if [[ -z "$CLUSTER_NAME" ]]; then
                log "error" "No ARO cluster found in resource group $RESOURCE_GROUP"
                exit 1
            fi
            
            # Get ARO credentials
            log "info" "Getting credentials for ARO cluster $CLUSTER_NAME"
            az aro list-credentials \
                --name $CLUSTER_NAME \
                --resource-group $RESOURCE_GROUP \
                --query "{username: kubeadminUsername, password: kubeadminPassword}" \
                > cluster_credentials.json
                
            KUBEADMIN_USER=$(jq -r .username cluster_credentials.json)
            KUBEADMIN_PASS=$(jq -r .password cluster_credentials.json)
            
            # Get API Server URL
            API_SERVER=$(az aro show \
                --name $CLUSTER_NAME \
                --resource-group $RESOURCE_GROUP \
                --query apiserverProfile.url -o tsv)
                
            log "info" "Logging in to ARO cluster at $API_SERVER"
            
            # Login to the cluster
            oc login $API_SERVER -u $KUBEADMIN_USER -p $KUBEADMIN_PASS --insecure-skip-tls-verify
            
            if [ $? -ne 0 ]; then
                log "error" "Failed to log in to ARO cluster"
                exit 1
            fi
            
            # Clean up credentials file
            rm -f cluster_credentials.json
            ;;
            
        AKS)
            # Get AKS cluster name
            CLUSTER_NAME=$(az aks list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
            
            if [[ -z "$CLUSTER_NAME" ]]; then
                log "error" "No AKS cluster found in resource group $RESOURCE_GROUP"
                exit 1
            fi
            
            # Get credentials for the AKS cluster
            log "info" "Getting credentials for AKS cluster $CLUSTER_NAME"
            az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
            
            if [ $? -ne 0 ]; then
                log "error" "Failed to get credentials for AKS cluster"
                exit 1
            fi
            ;;
            
        *)
            log "error" "Unsupported cluster type: $CLUSTER_TYPE"
            exit 1
            ;;
    esac
    
    log "success" "Connected to $CLUSTER_TYPE cluster successfully."
}

# Validate cluster health
validate_cluster_health() {
    log "info" "Validating cluster health..."
    
    # Check node status
    log "info" "Checking node status"
    NODES_NOT_READY=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.conditions[] | select(.type=="Ready" and .status!="True")) | .metadata.name')
    
    if [[ -z "$NODES_NOT_READY" ]]; then
        log "success" "All nodes are in Ready state"
    else
        log "error" "Some nodes are not in Ready state: $NODES_NOT_READY"
    fi
    
    # Check control plane health
    log "info" "Checking control plane health"
    UNHEALTHY_COMPONENTS=$(kubectl get componentstatuses -o json | jq -r '.items[] | select(.conditions[0].status != "True") | .metadata.name')
    
    if [[ -z "$UNHEALTHY_COMPONENTS" ]]; then
        log "success" "All control plane components are healthy"
    else
        log "error" "Some control plane components are unhealthy: $UNHEALTHY_COMPONENTS"
    fi
    
    # Check for pending or failed pods
    log "info" "Checking for problematic pods"
    PROBLEM_PODS=$(kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded") | .metadata.namespace + "/" + .metadata.name')
    
    if [[ -z "$PROBLEM_PODS" ]]; then
        log "success" "All pods are in Running or Succeeded state"
    else
        log "warning" "Some pods are not in Running or Succeeded state: $PROBLEM_PODS"
    fi
}

# Validate Developer Hub installation
validate_developer_hub() {
    log "info" "Validating Developer Hub installation..."
    
    # Check for Developer Hub namespace
    kubectl get namespace developer-hub > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "success" "Developer Hub namespace exists"
        
        # Check Developer Hub pods
        DEVHUB_PODS_RUNNING=$(kubectl get pods -n developer-hub -o json | jq -r '.items[] | select(.status.phase == "Running") | .metadata.name' | wc -l)
        DEVHUB_PODS_TOTAL=$(kubectl get pods -n developer-hub -o json | jq -r '.items[] | .metadata.name' | wc -l)
        
        log "info" "$DEVHUB_PODS_RUNNING/$DEVHUB_PODS_TOTAL Developer Hub pods are running"
        
        if [ "$DEVHUB_PODS_RUNNING" -eq "$DEVHUB_PODS_TOTAL" ]; then
            log "success" "All Developer Hub pods are running"
        else
            log "warning" "Some Developer Hub pods are not running"
            kubectl get pods -n developer-hub | grep -v "Running" | grep -v "Completed"
        fi
        
        # Check Developer Hub route/ingress
        if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
            DEVHUB_ROUTE=$(kubectl get route -n developer-hub -o json | jq -r '.items[] | select(.metadata.name == "developer-hub") | .spec.host')
            
            if [[ -n "$DEVHUB_ROUTE" ]]; then
                log "success" "Developer Hub route is configured: $DEVHUB_ROUTE"
                
                # Test connectivity
                if curl -s -k https://$DEVHUB_ROUTE > /dev/null; then
                    log "success" "Developer Hub is accessible via route"
                else
                    log "warning" "Developer Hub is not accessible via route"
                fi
            else
                log "warning" "Developer Hub route is not configured"
            fi
        elif [[ "$CLUSTER_TYPE" == "AKS" ]]; then
            DEVHUB_INGRESS=$(kubectl get ingress -n developer-hub -o json | jq -r '.items[] | select(.metadata.name == "developer-hub") | .spec.rules[0].host')
            
            if [[ -n "$DEVHUB_INGRESS" ]]; then
                log "success" "Developer Hub ingress is configured: $DEVHUB_INGRESS"
                
                # Test connectivity
                if curl -s -k https://$DEVHUB_INGRESS > /dev/null; then
                    log "success" "Developer Hub is accessible via ingress"
                else
                    log "warning" "Developer Hub is not accessible via ingress"
                fi
            else
                log "warning" "Developer Hub ingress is not configured"
            fi
        fi
    else
        log "error" "Developer Hub namespace does not exist"
    fi
}

# Validate required services
validate_required_services() {
    log "info" "Validating required services..."
    
    # Array of critical namespaces to check
    CRITICAL_NAMESPACES=("kube-system" "default" "developer-hub")
    
    for namespace in "${CRITICAL_NAMESPACES[@]}"; do
        kubectl get namespace $namespace > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "success" "Namespace $namespace exists"
        else
            log "error" "Namespace $namespace does not exist"
        fi
    done
    
    # Check for critical services based on cluster type
    if [[ "$CLUSTER_TYPE" == "ARO" ]]; then
        kubectl get namespace openshift-console > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "success" "OpenShift Console namespace exists"
        else
            log "error" "OpenShift Console namespace does not exist"
        fi
    elif [[ "$CLUSTER_TYPE" == "AKS" ]]; then
        kubectl get namespace ingress-nginx > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "success" "Ingress NGINX namespace exists"
        else
            log "warning" "Ingress NGINX namespace does not exist"
        fi
    fi
    
    # Check for database service (PostgreSQL)
    if [[ "$ALL_COMPONENTS" == "true" ]]; then
        log "info" "Checking for PostgreSQL service..."
        
        # This is platform-dependent; could be in-cluster or Azure service
        # For in-cluster PostgreSQL
        kubectl get pods -n developer-hub -l app=postgresql > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "success" "PostgreSQL is deployed in-cluster"
        else
            # Check for external PostgreSQL (Azure service)
            if [[ -n "$RESOURCE_GROUP" ]]; then
                POSTGRES_SERVERS=$(az postgres server list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv)
                if [[ -n "$POSTGRES_SERVERS" ]]; then
                    log "success" "External PostgreSQL server(s) found: $POSTGRES_SERVERS"
                else
                    log "warning" "No PostgreSQL server found, but might be using a different resource group"
                fi
            fi
        fi
    fi
}

# Generate validation report
generate_report() {
    log "info" "Generating validation report..."
    
    TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
    REPORT_FILE="three_horizons_validation_${TIMESTAMP}.${OUTPUT_FORMAT}"
    
    case $OUTPUT_FORMAT in
        text)
            cat > $REPORT_FILE << EOF
===========================================================================
                Three Horizons Platform Validation Report
===========================================================================
Timestamp: $(date +'%Y-%m-%d %H:%M:%S')
Cluster Type: $CLUSTER_TYPE
Resource Group: $RESOURCE_GROUP

Summary:
---------------------------------------------------------------------------
Total Checks: $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))
Passed: $PASS_COUNT
Failed: $FAIL_COUNT
Warnings: $WARN_COUNT

Overall Status: $([ $FAIL_COUNT -eq 0 ] && echo "PASSED" || echo "FAILED")
===========================================================================

Next Steps:
$([ $FAIL_COUNT -eq 0 ] && echo "Your Three Horizons platform deployment has been validated successfully!" || echo "Please address the failed validation checks before proceeding.")
$([ $WARN_COUNT -gt 0 ] && echo "Review the warnings to optimize your deployment.")

For detailed logs, please review the validation script output.
EOF
            ;;
            
        json)
            cat > $REPORT_FILE << EOF
{
  "validation": {
    "timestamp": "$(date +'%Y-%m-%d %H:%M:%S')",
    "cluster_type": "$CLUSTER_TYPE",
    "resource_group": "$RESOURCE_GROUP",
    "summary": {
      "total_checks": $((PASS_COUNT + FAIL_COUNT + WARN_COUNT)),
      "passed": $PASS_COUNT,
      "failed": $FAIL_COUNT,
      "warnings": $WARN_COUNT,
      "overall_status": $([ $FAIL_COUNT -eq 0 ] && echo "\"PASSED\"" || echo "\"FAILED\"")
    }
  }
}
EOF
            ;;
            
        html)
            cat > $REPORT_FILE << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Three Horizons Platform Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333366; }
        .summary { margin: 20px 0; }
        .passed { color: green; }
        .failed { color: red; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Three Horizons Platform Validation Report</h1>
    <p><strong>Timestamp:</strong> $(date +'%Y-%m-%d %H:%M:%S')</p>
    <p><strong>Cluster Type:</strong> $CLUSTER_TYPE</p>
    <p><strong>Resource Group:</strong> $RESOURCE_GROUP</p>
    
    <h2>Summary</h2>
    <div class="summary">
        <p><strong>Total Checks:</strong> $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))</p>
        <p><strong>Passed:</strong> <span class="passed">$PASS_COUNT</span></p>
        <p><strong>Failed:</strong> <span class="failed">$FAIL_COUNT</span></p>
        <p><strong>Warnings:</strong> <span class="warning">$WARN_COUNT</span></p>
        <p><strong>Overall Status:</strong> $([ $FAIL_COUNT -eq 0 ] && echo "<span class=\"passed\">PASSED</span>" || echo "<span class=\"failed\">FAILED</span>")</p>
    </div>
    
    <h2>Next Steps</h2>
    <p>$([ $FAIL_COUNT -eq 0 ] && echo "Your Three Horizons platform deployment has been validated successfully!" || echo "Please address the failed validation checks before proceeding.")</p>
    <p>$([ $WARN_COUNT -gt 0 ] && echo "Review the warnings to optimize your deployment.")</p>
    
    <p>For detailed logs, please review the validation script output.</p>
</body>
</html>
EOF
            ;;
            
        *)
            log "error" "Unsupported output format: $OUTPUT_FORMAT"
            return 1
            ;;
    esac
    
    log "success" "Validation report generated: $REPORT_FILE"
}

# Main execution
main() {
    # Display banner
    display_banner
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Connect to the cluster
    connect_to_cluster
    
    # Perform validation checks
    validate_cluster_health
    validate_required_services
    
    if [[ "$ALL_COMPONENTS" == "true" ]]; then
        validate_developer_hub
        # Add additional component validation as needed
    fi
    
    # Generate validation report
    generate_report
    
    # Final summary
    echo
    log "info" "Validation complete. Summary:"
    log "info" "Passed checks: $PASS_COUNT"
    log "info" "Failed checks: $FAIL_COUNT"
    log "info" "Warnings: $WARN_COUNT"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        log "success" "Validation PASSED!"
    else
        log "error" "Validation FAILED!"
        exit 1
    fi
}

# Run the script
main "$@" 