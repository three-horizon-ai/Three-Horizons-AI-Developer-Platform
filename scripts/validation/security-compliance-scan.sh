#!/bin/bash
# Three Horizons: Security Compliance Scan Script
# This script performs security compliance scans for the Three Horizons platform

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

# Display help information
show_help() {
    echo -e "${BOLD}Three Horizons Platform Security Compliance Scan${NC}"
    echo
    echo "This script performs security compliance scans for the Three Horizons platform."
    echo "It checks various security aspects including CIS benchmarks, network policies,"
    echo "RBAC configuration, and vulnerability scanning."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --cluster-type TYPE      Cluster type (ARO, AKS)"
    echo "  --scan-type TYPE         Scan type (full, quick, cis, network, rbac, vulnerability)"
    echo "  --report-format FORMAT   Report format (text, json, html) [default: text]"
    echo "  --policy-set SET         Policy set to use (standard, strict, custom)"
    echo "  --output-dir DIR         Directory to store scan results [default: ./security-scans]"
    echo "  -h, --help               Show this help message"
    echo
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Security Compliance Scan                          ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script will perform security compliance scans on the Three Horizons platform."
    echo -e "It checks CIS benchmarks, network policies, RBAC, and vulnerabilities."
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
            --scan-type)
                SCAN_TYPE=$2
                shift 2
                ;;
            --report-format)
                REPORT_FORMAT=$2
                shift 2
                ;;
            --policy-set)
                POLICY_SET=$2
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR=$2
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
    
    # Set defaults
    CLUSTER_TYPE=${CLUSTER_TYPE:-ARO}
    SCAN_TYPE=${SCAN_TYPE:-full}
    REPORT_FORMAT=${REPORT_FORMAT:-text}
    POLICY_SET=${POLICY_SET:-standard}
    OUTPUT_DIR=${OUTPUT_DIR:-"./security-scans"}
    
    # Validate parameters
    case $SCAN_TYPE in
        full|quick|cis|network|rbac|vulnerability)
            ;;
        *)
            log "error" "Invalid scan type: $SCAN_TYPE"
            show_help
            exit 1
            ;;
    esac
    
    case $REPORT_FORMAT in
        text|json|html)
            ;;
        *)
            log "error" "Invalid report format: $REPORT_FORMAT"
            show_help
            exit 1
            ;;
    esac
    
    case $POLICY_SET in
        standard|strict|custom)
            ;;
        *)
            log "error" "Invalid policy set: $POLICY_SET"
            show_help
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log "error" "kubectl is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        log "error" "jq is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Create output directory if it doesn't exist
    if [ ! -d "$OUTPUT_DIR" ]; then
        log "info" "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi
    
    # Check cluster access
    if ! kubectl get nodes &> /dev/null; then
        log "error" "Cannot access Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    # Check for kube-bench (CIS benchmark tool)
    if [[ "$SCAN_TYPE" == "full" || "$SCAN_TYPE" == "cis" ]]; then
        if ! command -v kube-bench &> /dev/null; then
            log "warning" "kube-bench is not installed. CIS benchmark scan will be skipped."
            log "info" "You can install kube-bench from https://github.com/aquasecurity/kube-bench"
        fi
    fi
    
    # Check for Trivy (vulnerability scanner)
    if [[ "$SCAN_TYPE" == "full" || "$SCAN_TYPE" == "vulnerability" ]]; then
        if ! command -v trivy &> /dev/null; then
            log "warning" "Trivy is not installed. Vulnerability scan will be skipped."
            log "info" "You can install Trivy from https://github.com/aquasecurity/trivy"
        fi
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Run CIS benchmark scan
run_cis_benchmark() {
    log "info" "Running CIS Kubernetes benchmark scan..."
    
    # Output file
    CIS_OUTPUT_FILE="$OUTPUT_DIR/cis-benchmark-$(date +'%Y%m%d-%H%M%S')"
    
    # Check if kube-bench is installed
    if ! command -v kube-bench &> /dev/null; then
        log "warning" "kube-bench is not installed. Skipping CIS benchmark scan."
        return
    fi
    
    # Run kube-bench
    log "info" "Running kube-bench..."
    
    case $REPORT_FORMAT in
        json)
            kube-bench --json > "${CIS_OUTPUT_FILE}.json" 2>/dev/null
            ;;
        text|html|*)
            kube-bench > "${CIS_OUTPUT_FILE}.txt" 2>/dev/null
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "success" "CIS benchmark scan completed. Results saved to: ${CIS_OUTPUT_FILE}.${REPORT_FORMAT}"
        
        # Count findings by severity
        if [[ "$REPORT_FORMAT" == "json" ]]; then
            FAIL_COUNT=$(jq '.Totals.total_fail' "${CIS_OUTPUT_FILE}.json")
            WARN_COUNT=$(jq '.Totals.total_warn' "${CIS_OUTPUT_FILE}.json")
            PASS_COUNT=$(jq '.Totals.total_pass' "${CIS_OUTPUT_FILE}.json")
            
            log "info" "CIS Benchmark findings: $FAIL_COUNT critical, $WARN_COUNT warning, $PASS_COUNT passed"
        else
            # Simple grep for text output
            FAIL_COUNT=$(grep -i "FAIL" "${CIS_OUTPUT_FILE}.txt" | wc -l)
            WARN_COUNT=$(grep -i "WARN" "${CIS_OUTPUT_FILE}.txt" | wc -l)
            PASS_COUNT=$(grep -i "PASS" "${CIS_OUTPUT_FILE}.txt" | wc -l)
            
            log "info" "CIS Benchmark findings: $FAIL_COUNT critical, $WARN_COUNT warning, $PASS_COUNT passed"
        fi
    else
        log "error" "CIS benchmark scan failed."
    fi
}

# Analyze RBAC configuration
analyze_rbac() {
    log "info" "Analyzing RBAC configuration..."
    
    # Output file
    RBAC_OUTPUT_FILE="$OUTPUT_DIR/rbac-analysis-$(date +'%Y%m%d-%H%M%S')"
    
    # Get all ClusterRoles that allow powerful permissions
    log "info" "Checking for privileged ClusterRoles..."
    kubectl get clusterrole -o json | \
        jq '.items[] | select(.rules[] | select((.verbs | contains(["*"])) and (.resources | contains(["pods"])) and (.apiGroups | contains(["*"])))) | .metadata.name' \
        > "${RBAC_OUTPUT_FILE}-privileged-roles.txt"
    
    # Get all ServiceAccounts with cluster-admin binding
    log "info" "Checking for ServiceAccounts with cluster-admin binding..."
    kubectl get clusterrolebinding -o json | \
        jq '.items[] | select(.roleRef.name == "cluster-admin") | .subjects[] | select(.kind == "ServiceAccount") | .name + " (namespace: " + .namespace + ")"' \
        > "${RBAC_OUTPUT_FILE}-cluster-admin-accounts.txt"
    
    # Get all non-default ServiceAccounts
    log "info" "Listing all non-default ServiceAccounts..."
    kubectl get serviceaccounts --all-namespaces -o json | \
        jq '.items[] | select(.metadata.name != "default") | .metadata.namespace + "/" + .metadata.name' \
        > "${RBAC_OUTPUT_FILE}-service-accounts.txt"
    
    log "success" "RBAC analysis completed. Results saved to: ${RBAC_OUTPUT_FILE}-*.txt"
    
    # Count findings
    PRIVILEGED_ROLES=$(wc -l < "${RBAC_OUTPUT_FILE}-privileged-roles.txt")
    CLUSTER_ADMIN_ACCOUNTS=$(wc -l < "${RBAC_OUTPUT_FILE}-cluster-admin-accounts.txt")
    
    log "info" "RBAC analysis findings: $PRIVILEGED_ROLES privileged roles, $CLUSTER_ADMIN_ACCOUNTS service accounts with cluster-admin"
    
    if [ $PRIVILEGED_ROLES -gt 0 ]; then
        log "warning" "Found privileged ClusterRoles with excessive permissions."
    fi
    
    if [ $CLUSTER_ADMIN_ACCOUNTS -gt 0 ]; then
        log "warning" "Found ServiceAccounts with cluster-admin binding."
    fi
}

# Analyze network policies
analyze_network_policies() {
    log "info" "Analyzing network policies..."
    
    # Output file
    NETWORK_OUTPUT_FILE="$OUTPUT_DIR/network-analysis-$(date +'%Y%m%d-%H%M%S')"
    
    # Get all namespaces
    NAMESPACES=$(kubectl get namespaces -o json | jq -r '.items[].metadata.name')
    
    # Check for namespaces without network policies
    NAMESPACES_WITHOUT_NETPOL=""
    
    for ns in $NAMESPACES; do
        # Skip kube-system and other system namespaces
        if [[ "$ns" == kube-* || "$ns" == openshift-* ]]; then
            continue
        fi
        
        NETPOL_COUNT=$(kubectl get networkpolicy -n $ns 2>/dev/null | wc -l)
        # Subtract 1 for the header line
        NETPOL_COUNT=$((NETPOL_COUNT - 1))
        
        if [ $NETPOL_COUNT -le 0 ]; then
            NAMESPACES_WITHOUT_NETPOL="$NAMESPACES_WITHOUT_NETPOL$ns "
            echo "$ns" >> "${NETWORK_OUTPUT_FILE}-namespaces-without-netpol.txt"
        fi
    done
    
    # Check for default allow all ingress
    log "info" "Checking for overly permissive network policies..."
    
    kubectl get networkpolicy --all-namespaces -o json | \
        jq '.items[] | select(.spec.ingress != null and (.spec.ingress | length > 0) and (.spec.ingress[0].from | length == 0)) | .metadata.namespace + "/" + .metadata.name' \
        > "${NETWORK_OUTPUT_FILE}-permissive-policies.txt"
    
    log "success" "Network policy analysis completed. Results saved to: ${NETWORK_OUTPUT_FILE}-*.txt"
    
    # Count findings
    if [ -f "${NETWORK_OUTPUT_FILE}-namespaces-without-netpol.txt" ]; then
        NS_WITHOUT_NETPOL=$(wc -l < "${NETWORK_OUTPUT_FILE}-namespaces-without-netpol.txt")
    else
        NS_WITHOUT_NETPOL=0
    fi
    
    if [ -f "${NETWORK_OUTPUT_FILE}-permissive-policies.txt" ]; then
        PERMISSIVE_POLICIES=$(wc -l < "${NETWORK_OUTPUT_FILE}-permissive-policies.txt")
    else
        PERMISSIVE_POLICIES=0
    fi
    
    log "info" "Network policy findings: $NS_WITHOUT_NETPOL namespaces without policies, $PERMISSIVE_POLICIES permissive policies"
    
    if [ $NS_WITHOUT_NETPOL -gt 0 ]; then
        log "warning" "Found namespaces without network policies: $NAMESPACES_WITHOUT_NETPOL"
    fi
    
    if [ $PERMISSIVE_POLICIES -gt 0 ]; then
        log "warning" "Found permissive network policies that allow all ingress traffic."
    fi
}

# Run vulnerability scan
run_vulnerability_scan() {
    log "info" "Running vulnerability scan on running containers..."
    
    # Output file
    VULN_OUTPUT_FILE="$OUTPUT_DIR/vulnerability-scan-$(date +'%Y%m%d-%H%M%S')"
    
    # Check if Trivy is installed
    if ! command -v trivy &> /dev/null; then
        log "warning" "Trivy is not installed. Skipping vulnerability scan."
        return
    fi
    
    # Create a list of images to scan
    log "info" "Getting list of running container images..."
    kubectl get pods --all-namespaces -o json | \
        jq -r '.items[].spec.containers[].image' | sort | uniq \
        > "${VULN_OUTPUT_FILE}-images.txt"
    
    # Count the number of images
    IMAGE_COUNT=$(wc -l < "${VULN_OUTPUT_FILE}-images.txt")
    log "info" "Found $IMAGE_COUNT unique container images to scan."
    
    # Scan each image for vulnerabilities
    log "info" "Scanning images for vulnerabilities (this may take some time)..."
    
    CRITICAL_COUNT=0
    HIGH_COUNT=0
    MEDIUM_COUNT=0
    
    while read -r image; do
        log "info" "Scanning image: $image"
        
        # Run Trivy scan
        if [[ "$REPORT_FORMAT" == "json" ]]; then
            # Use JSON output
            trivy image --quiet --no-progress --security-checks vuln --format json \
                --output "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').json" \
                "$image"
            
            # Count vulnerabilities by severity
            if [ -f "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').json" ]; then
                CRITICAL=$(jq '[.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "CRITICAL")] | length' "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').json")
                HIGH=$(jq '[.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "HIGH")] | length' "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').json")
                MEDIUM=$(jq '[.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "MEDIUM")] | length' "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').json")
                
                CRITICAL_COUNT=$((CRITICAL_COUNT + CRITICAL))
                HIGH_COUNT=$((HIGH_COUNT + HIGH))
                MEDIUM_COUNT=$((MEDIUM_COUNT + MEDIUM))
                
                log "info" "Found vulnerabilities in $image: $CRITICAL critical, $HIGH high, $MEDIUM medium"
            fi
        else
            # Use text output
            trivy image --quiet --no-progress --security-checks vuln \
                --output "${VULN_OUTPUT_FILE}-$(echo $image | tr '/:' '__').txt" \
                "$image"
        fi
    done < "${VULN_OUTPUT_FILE}-images.txt"
    
    log "success" "Vulnerability scan completed. Results saved to: ${VULN_OUTPUT_FILE}-*.${REPORT_FORMAT}"
    log "info" "Total vulnerabilities found: $CRITICAL_COUNT critical, $HIGH_COUNT high, $MEDIUM_COUNT medium"
    
    if [ $CRITICAL_COUNT -gt 0 ]; then
        log "warning" "Found $CRITICAL_COUNT critical vulnerabilities that should be addressed immediately."
    fi
}

# Generate security report
generate_report() {
    log "info" "Generating comprehensive security report..."
    
    TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
    REPORT_FILE="$OUTPUT_DIR/security_report_${TIMESTAMP}.${REPORT_FORMAT}"
    
    case $REPORT_FORMAT in
        text)
            cat > $REPORT_FILE << EOF
===========================================================================
                Three Horizons Platform Security Report
===========================================================================
Timestamp: $(date +'%Y-%m-%d %H:%M:%S')
Cluster Type: $CLUSTER_TYPE
Scan Type: $SCAN_TYPE
Policy Set: $POLICY_SET

Security Scan Summary:
---------------------------------------------------------------------------
EOF

            # Add CIS benchmark results if available
            if [ -f "$OUTPUT_DIR/cis-benchmark-*.txt" ]; then
                echo "CIS Benchmark:" >> $REPORT_FILE
                echo "  FAIL: $FAIL_COUNT" >> $REPORT_FILE
                echo "  WARN: $WARN_COUNT" >> $REPORT_FILE
                echo "  PASS: $PASS_COUNT" >> $REPORT_FILE
                echo "" >> $REPORT_FILE
            fi

            # Add RBAC analysis results if available
            if [ -f "$OUTPUT_DIR/rbac-analysis-*-privileged-roles.txt" ]; then
                echo "RBAC Analysis:" >> $REPORT_FILE
                echo "  Privileged Roles: $PRIVILEGED_ROLES" >> $REPORT_FILE
                echo "  Cluster-Admin Service Accounts: $CLUSTER_ADMIN_ACCOUNTS" >> $REPORT_FILE
                echo "" >> $REPORT_FILE
            fi

            # Add Network Policy analysis results if available
            if [ -f "$OUTPUT_DIR/network-analysis-*-namespaces-without-netpol.txt" ]; then
                echo "Network Policy Analysis:" >> $REPORT_FILE
                echo "  Namespaces Without Policies: $NS_WITHOUT_NETPOL" >> $REPORT_FILE
                echo "  Permissive Policies: $PERMISSIVE_POLICIES" >> $REPORT_FILE
                echo "" >> $REPORT_FILE
            fi

            # Add Vulnerability scan results if available
            if [ -f "$OUTPUT_DIR/vulnerability-scan-*-images.txt" ]; then
                echo "Vulnerability Scan:" >> $REPORT_FILE
                echo "  Critical Vulnerabilities: $CRITICAL_COUNT" >> $REPORT_FILE
                echo "  High Vulnerabilities: $HIGH_COUNT" >> $REPORT_FILE
                echo "  Medium Vulnerabilities: $MEDIUM_COUNT" >> $REPORT_FILE
                echo "" >> $REPORT_FILE
            fi

            cat >> $REPORT_FILE << EOF
===========================================================================

Recommendations:
1. Address all critical vulnerabilities immediately
2. Review and limit privileged RBAC roles
3. Implement network policies in all namespaces
4. Address CIS benchmark failures

For detailed scan results, see the individual scan files in: $OUTPUT_DIR
EOF
            ;;
            
        json)
            cat > $REPORT_FILE << EOF
{
  "security_report": {
    "timestamp": "$(date +'%Y-%m-%d %H:%M:%S')",
    "cluster_type": "$CLUSTER_TYPE",
    "scan_type": "$SCAN_TYPE",
    "policy_set": "$POLICY_SET",
    "summary": {
EOF

            # Add CIS benchmark results if available
            if [ -f "$OUTPUT_DIR/cis-benchmark-*.json" ]; then
                cat >> $REPORT_FILE << EOF
      "cis_benchmark": {
        "fail": $FAIL_COUNT,
        "warn": $WARN_COUNT,
        "pass": $PASS_COUNT
      },
EOF
            fi

            # Add RBAC analysis results if available
            if [ -f "$OUTPUT_DIR/rbac-analysis-*-privileged-roles.txt" ]; then
                cat >> $REPORT_FILE << EOF
      "rbac_analysis": {
        "privileged_roles": $PRIVILEGED_ROLES,
        "cluster_admin_service_accounts": $CLUSTER_ADMIN_ACCOUNTS
      },
EOF
            fi

            # Add Network Policy analysis results if available
            if [ -f "$OUTPUT_DIR/network-analysis-*-namespaces-without-netpol.txt" ]; then
                cat >> $REPORT_FILE << EOF
      "network_policy_analysis": {
        "namespaces_without_policies": $NS_WITHOUT_NETPOL,
        "permissive_policies": $PERMISSIVE_POLICIES
      },
EOF
            fi

            # Add Vulnerability scan results if available
            if [ -f "$OUTPUT_DIR/vulnerability-scan-*-images.txt" ]; then
                cat >> $REPORT_FILE << EOF
      "vulnerability_scan": {
        "critical": $CRITICAL_COUNT,
        "high": $HIGH_COUNT,
        "medium": $MEDIUM_COUNT
      }
EOF
            else
                # Remove trailing comma if this is the last section
                sed -i '$ s/,$//' $REPORT_FILE
            fi

            cat >> $REPORT_FILE << EOF
    },
    "recommendations": [
      "Address all critical vulnerabilities immediately",
      "Review and limit privileged RBAC roles",
      "Implement network policies in all namespaces",
      "Address CIS benchmark failures"
    ]
  }
}
EOF
            ;;
            
        html)
            cat > $REPORT_FILE << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Three Horizons Platform Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333366; }
        .summary { margin: 20px 0; }
        .critical { color: #d9534f; }
        .high { color: #f0ad4e; }
        .medium { color: #5bc0de; }
        .pass { color: #5cb85c; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Three Horizons Platform Security Report</h1>
    <p><strong>Timestamp:</strong> $(date +'%Y-%m-%d %H:%M:%S')</p>
    <p><strong>Cluster Type:</strong> $CLUSTER_TYPE</p>
    <p><strong>Scan Type:</strong> $SCAN_TYPE</p>
    <p><strong>Policy Set:</strong> $POLICY_SET</p>
    
    <h2>Security Scan Summary</h2>
    <div class="summary">
EOF

            # Add CIS benchmark results if available
            if [ -f "$OUTPUT_DIR/cis-benchmark-*.txt" ]; then
                cat >> $REPORT_FILE << EOF
        <h3>CIS Benchmark</h3>
        <table>
            <tr>
                <th>Severity</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>FAIL</td>
                <td class="critical">$FAIL_COUNT</td>
            </tr>
            <tr>
                <td>WARN</td>
                <td class="high">$WARN_COUNT</td>
            </tr>
            <tr>
                <td>PASS</td>
                <td class="pass">$PASS_COUNT</td>
            </tr>
        </table>
EOF
            fi

            # Add RBAC analysis results if available
            if [ -f "$OUTPUT_DIR/rbac-analysis-*-privileged-roles.txt" ]; then
                cat >> $REPORT_FILE << EOF
        <h3>RBAC Analysis</h3>
        <table>
            <tr>
                <th>Issue</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Privileged Roles</td>
                <td class="high">$PRIVILEGED_ROLES</td>
            </tr>
            <tr>
                <td>Cluster-Admin Service Accounts</td>
                <td class="critical">$CLUSTER_ADMIN_ACCOUNTS</td>
            </tr>
        </table>
EOF
            fi

            # Add Network Policy analysis results if available
            if [ -f "$OUTPUT_DIR/network-analysis-*-namespaces-without-netpol.txt" ]; then
                cat >> $REPORT_FILE << EOF
        <h3>Network Policy Analysis</h3>
        <table>
            <tr>
                <th>Issue</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Namespaces Without Policies</td>
                <td class="high">$NS_WITHOUT_NETPOL</td>
            </tr>
            <tr>
                <td>Permissive Policies</td>
                <td class="medium">$PERMISSIVE_POLICIES</td>
            </tr>
        </table>
EOF
            fi

            # Add Vulnerability scan results if available
            if [ -f "$OUTPUT_DIR/vulnerability-scan-*-images.txt" ]; then
                cat >> $REPORT_FILE << EOF
        <h3>Vulnerability Scan</h3>
        <table>
            <tr>
                <th>Severity</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Critical</td>
                <td class="critical">$CRITICAL_COUNT</td>
            </tr>
            <tr>
                <td>High</td>
                <td class="high">$HIGH_COUNT</td>
            </tr>
            <tr>
                <td>Medium</td>
                <td class="medium">$MEDIUM_COUNT</td>
            </tr>
        </table>
EOF
            fi

            cat >> $REPORT_FILE << EOF
    </div>
    
    <h2>Recommendations</h2>
    <ol>
        <li>Address all critical vulnerabilities immediately</li>
        <li>Review and limit privileged RBAC roles</li>
        <li>Implement network policies in all namespaces</li>
        <li>Address CIS benchmark failures</li>
    </ol>
    
    <p>For detailed scan results, see the individual scan files in: $OUTPUT_DIR</p>
</body>
</html>
EOF
            ;;
            
        *)
            log "error" "Unsupported report format: $REPORT_FORMAT"
            return 1
            ;;
    esac
    
    log "success" "Security report generated: $REPORT_FILE"
}

# Main execution
main() {
    # Display banner
    display_banner
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Run security scans based on scan type
    case $SCAN_TYPE in
        full)
            log "info" "Running full security scan..."
            run_cis_benchmark
            analyze_rbac
            analyze_network_policies
            run_vulnerability_scan
            ;;
        quick)
            log "info" "Running quick security scan..."
            analyze_rbac
            analyze_network_policies
            ;;
        cis)
            log "info" "Running CIS benchmark scan only..."
            run_cis_benchmark
            ;;
        network)
            log "info" "Running network policy analysis only..."
            analyze_network_policies
            ;;
        rbac)
            log "info" "Running RBAC analysis only..."
            analyze_rbac
            ;;
        vulnerability)
            log "info" "Running vulnerability scan only..."
            run_vulnerability_scan
            ;;
    esac
    
    # Generate comprehensive security report
    generate_report
    
    log "success" "Security compliance scan completed!"
    log "info" "Full report saved to: $REPORT_FILE"
}

# Run the script
main "$@" 