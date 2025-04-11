#!/bin/bash
# Three Horizons: Developer Hub Integration Test Script
# This script tests the integration between Red Hat Developer Hub and various services

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results counters
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
    echo -e "${BOLD}Three Horizons Developer Hub Integration Test Script${NC}"
    echo
    echo "This script tests the integration between Red Hat Developer Hub and various services."
    echo "It validates the connections, API access, and functionality of integrated systems."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --url URL                 URL of the Developer Hub"
    echo "  --username USER           Username for authentication"
    echo "  --password PASS           Password for authentication"
    echo "  --integration-type TYPE   Integration type to test (github, kubernetes, ci, all)"
    echo "  --output-format FORMAT    Output format for test results (text, json, html) [default: text]"
    echo "  --output-file FILE        Output file for test results [default: devhub-integration-test-results.txt]"
    echo "  -h, --help                Show this help message"
    echo
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Developer Hub Integration Test                   ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script will test the integration between Developer Hub and various services."
    echo -e "It validates connections, API access, and functionality of integrated systems."
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --url)
                DEVHUB_URL=$2
                shift 2
                ;;
            --username)
                USERNAME=$2
                shift 2
                ;;
            --password)
                PASSWORD=$2
                shift 2
                ;;
            --integration-type)
                INTEGRATION_TYPE=$2
                shift 2
                ;;
            --output-format)
                OUTPUT_FORMAT=$2
                shift 2
                ;;
            --output-file)
                OUTPUT_FILE=$2
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
    if [[ -z "$DEVHUB_URL" ]]; then
        log "error" "Developer Hub URL must be specified with --url"
        show_help
        exit 1
    fi
    
    # Set defaults
    INTEGRATION_TYPE=${INTEGRATION_TYPE:-all}
    OUTPUT_FORMAT=${OUTPUT_FORMAT:-text}
    OUTPUT_FILE=${OUTPUT_FILE:-"devhub-integration-test-results.${OUTPUT_FORMAT}"}
    
    # Validate parameters
    case $INTEGRATION_TYPE in
        github|kubernetes|ci|all)
            ;;
        *)
            log "error" "Invalid integration type: $INTEGRATION_TYPE"
            show_help
            exit 1
            ;;
    esac
    
    case $OUTPUT_FORMAT in
        text|json|html)
            ;;
        *)
            log "error" "Invalid output format: $OUTPUT_FORMAT"
            show_help
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log "error" "curl is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        log "error" "jq is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # If testing Kubernetes integration, check if kubectl is installed
    if [[ "$INTEGRATION_TYPE" == "kubernetes" || "$INTEGRATION_TYPE" == "all" ]]; then
        if ! command -v kubectl &> /dev/null; then
            log "warning" "kubectl is not installed. Kubernetes integration tests will be limited."
        fi
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Test Developer Hub accessibility
test_devhub_accessibility() {
    log "info" "Testing Developer Hub accessibility..."
    
    # Test basic connectivity
    if curl -s -o /dev/null -w "%{http_code}" "$DEVHUB_URL" | grep -q "200\|302"; then
        log "success" "Developer Hub is accessible at $DEVHUB_URL"
    else
        log "error" "Cannot access Developer Hub at $DEVHUB_URL"
        return 1
    fi
    
    # Test login page access
    if curl -s -o /dev/null -w "%{http_code}" "$DEVHUB_URL/auth/login" | grep -q "200\|302"; then
        log "success" "Login page is accessible"
    else
        log "warning" "Login page may not be accessible"
    fi
    
    # Test API endpoint access
    if curl -s -o /dev/null -w "%{http_code}" "$DEVHUB_URL/api/catalog/entities" | grep -q "200\|302\|401"; then
        log "success" "API endpoints are accessible (may require authentication)"
    else
        log "warning" "API endpoints may not be accessible"
    fi
    
    return 0
}

# Test GitHub integration
test_github_integration() {
    log "info" "Testing GitHub integration..."
    
    # Check if GitHub provider is configured
    GITHUB_PROVIDER_CHECK=$(curl -s "$DEVHUB_URL/api/proxy/github/user" -H "Accept: application/json" -o /dev/null -w "%{http_code}")
    
    if [[ "$GITHUB_PROVIDER_CHECK" == "401" || "$GITHUB_PROVIDER_CHECK" == "302" ]]; then
        log "success" "GitHub provider is configured (requires authentication)"
    elif [[ "$GITHUB_PROVIDER_CHECK" == "200" ]]; then
        log "success" "GitHub provider is configured and authenticated"
    else
        log "error" "GitHub provider may not be configured properly (HTTP code: $GITHUB_PROVIDER_CHECK)"
        return 1
    fi
    
    # Check for GitHub actions in the scaffolder templates
    if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=template" | grep -q "github"; then
        log "success" "GitHub-related templates are available"
    else
        log "warning" "No GitHub-related templates found in catalog"
    fi
    
    # Check for GitHub-related software components in catalog
    if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=component" | grep -q "github"; then
        log "success" "GitHub-based components found in catalog"
    else
        log "warning" "No GitHub-based components found in catalog"
    fi
    
    return 0
}

# Test Kubernetes integration
test_kubernetes_integration() {
    log "info" "Testing Kubernetes integration..."
    
    # Check if kubectl is available for deeper integration tests
    if ! command -v kubectl &> /dev/null; then
        log "warning" "kubectl is not available. Limited testing will be performed."
        
        # Basic check using Developer Hub API
        if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=resource" | grep -q "kubernetes"; then
            log "success" "Kubernetes resources found in catalog"
        else
            log "warning" "No Kubernetes resources found in catalog"
        fi
        
        return 0
    fi
    
    # Check if namespace exists for Developer Hub
    if kubectl get namespace developer-hub &> /dev/null; then
        log "success" "Developer Hub namespace exists in Kubernetes"
        
        # Check if Developer Hub pods are running
        RUNNING_PODS=$(kubectl get pods -n developer-hub -o json | jq '.items | map(select(.status.phase == "Running")) | length')
        TOTAL_PODS=$(kubectl get pods -n developer-hub -o json | jq '.items | length')
        
        if [[ "$RUNNING_PODS" == "$TOTAL_PODS" && "$TOTAL_PODS" -gt 0 ]]; then
            log "success" "All Developer Hub pods are running ($RUNNING_PODS/$TOTAL_PODS)"
        else
            log "warning" "Some Developer Hub pods may not be running ($RUNNING_PODS/$TOTAL_PODS)"
        fi
        
        # Check Developer Hub service account permissions
        if kubectl auth can-i --as=system:serviceaccount:developer-hub:default list pods -n developer-hub &> /dev/null; then
            log "success" "Developer Hub service account has proper permissions"
        else
            log "warning" "Developer Hub service account may have limited permissions"
        fi
    else
        log "error" "Developer Hub namespace does not exist in Kubernetes"
        return 1
    fi
    
    # Check for Kubernetes resources in catalog
    if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=resource" | grep -q "kubernetes"; then
        log "success" "Kubernetes resources found in catalog"
        
        # Try to get specific Kubernetes resources
        RESOURCE_COUNT=$(curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=resource" | jq 'length')
        if [[ "$RESOURCE_COUNT" -gt 0 ]]; then
            log "success" "Found $RESOURCE_COUNT Kubernetes resources in catalog"
        else
            log "warning" "No Kubernetes resources found in catalog"
        fi
    else
        log "warning" "No Kubernetes resources found in catalog"
    fi
    
    return 0
}

# Test CI/CD integration
test_cicd_integration() {
    log "info" "Testing CI/CD integration..."
    
    # Check for CI/CD templates in catalog
    if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=template" | grep -q "github-actions\|tekton\|jenkins\|gitlab\|azure-pipelines"; then
        log "success" "CI/CD templates found in catalog"
    else
        log "warning" "No CI/CD templates found in catalog"
    fi
    
    # Check for CI/CD components in catalog
    if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=component" | grep -q "github-actions\|tekton\|jenkins\|gitlab\|azure-pipelines"; then
        log "success" "CI/CD components found in catalog"
    else
        log "warning" "No CI/CD components found in catalog"
    fi
    
    # If GitHub Actions is used, check for workflow templates
    if [[ "$INTEGRATION_TYPE" == "github" || "$INTEGRATION_TYPE" == "all" ]]; then
        if curl -s "$DEVHUB_URL/api/catalog/entities?filter=kind=template" | grep -q "github-actions\|workflow"; then
            log "success" "GitHub Actions workflow templates found"
        else
            log "warning" "No GitHub Actions workflow templates found"
        fi
    fi
    
    return 0
}

# Generate test report
generate_report() {
    log "info" "Generating test report..."
    
    case $OUTPUT_FORMAT in
        text)
            cat > $OUTPUT_FILE << EOF
===========================================================================
            Three Horizons Developer Hub Integration Test Report
===========================================================================
Timestamp: $(date +'%Y-%m-%d %H:%M:%S')
Developer Hub URL: $DEVHUB_URL
Integration Type: $INTEGRATION_TYPE

Test Summary:
---------------------------------------------------------------------------
Total Tests: $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))
Passed: $PASS_COUNT
Failed: $FAIL_COUNT
Warnings: $WARN_COUNT

Overall Status: $([ $FAIL_COUNT -eq 0 ] && echo "PASSED" || echo "FAILED")
===========================================================================

Recommendations:
$([ $FAIL_COUNT -eq 0 ] && echo "The Developer Hub integration appears to be functioning correctly." || echo "Please address the failed integration tests before proceeding.")
$([ $WARN_COUNT -gt 0 ] && echo "Review the warnings to ensure optimal integration.")

For detailed logs, please review the test script output.
EOF
            ;;
            
        json)
            cat > $OUTPUT_FILE << EOF
{
  "integration_test": {
    "timestamp": "$(date +'%Y-%m-%d %H:%M:%S')",
    "developer_hub_url": "$DEVHUB_URL",
    "integration_type": "$INTEGRATION_TYPE",
    "summary": {
      "total_tests": $((PASS_COUNT + FAIL_COUNT + WARN_COUNT)),
      "passed": $PASS_COUNT,
      "failed": $FAIL_COUNT,
      "warnings": $WARN_COUNT,
      "overall_status": $([ $FAIL_COUNT -eq 0 ] && echo "\"PASSED\"" || echo "\"FAILED\"")
    },
    "recommendations": [
      $([ $FAIL_COUNT -eq 0 ] && echo "\"The Developer Hub integration appears to be functioning correctly.\"" || echo "\"Please address the failed integration tests before proceeding.\""),
      $([ $WARN_COUNT -gt 0 ] && echo "\"Review the warnings to ensure optimal integration.\"" || echo "\"No warnings detected.\"")
    ]
  }
}
EOF
            ;;
            
        html)
            cat > $OUTPUT_FILE << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Three Horizons Developer Hub Integration Test Report</title>
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
    <h1>Three Horizons Developer Hub Integration Test Report</h1>
    <p><strong>Timestamp:</strong> $(date +'%Y-%m-%d %H:%M:%S')</p>
    <p><strong>Developer Hub URL:</strong> $DEVHUB_URL</p>
    <p><strong>Integration Type:</strong> $INTEGRATION_TYPE</p>
    
    <h2>Test Summary</h2>
    <div class="summary">
        <table>
            <tr>
                <th>Metric</th>
                <th>Count</th>
            </tr>
            <tr>
                <td>Total Tests</td>
                <td>$((PASS_COUNT + FAIL_COUNT + WARN_COUNT))</td>
            </tr>
            <tr>
                <td>Passed</td>
                <td class="passed">$PASS_COUNT</td>
            </tr>
            <tr>
                <td>Failed</td>
                <td class="failed">$FAIL_COUNT</td>
            </tr>
            <tr>
                <td>Warnings</td>
                <td class="warning">$WARN_COUNT</td>
            </tr>
            <tr>
                <td>Overall Status</td>
                <td class="$([ $FAIL_COUNT -eq 0 ] && echo "passed" || echo "failed")">$([ $FAIL_COUNT -eq 0 ] && echo "PASSED" || echo "FAILED")</td>
            </tr>
        </table>
    </div>
    
    <h2>Recommendations</h2>
    <ul>
        <li>$([ $FAIL_COUNT -eq 0 ] && echo "The Developer Hub integration appears to be functioning correctly." || echo "Please address the failed integration tests before proceeding.")</li>
        $([ $WARN_COUNT -gt 0 ] && echo "<li>Review the warnings to ensure optimal integration.</li>" || echo "")
    </ul>
    
    <p>For detailed logs, please review the test script output.</p>
</body>
</html>
EOF
            ;;
            
        *)
            log "error" "Unsupported output format: $OUTPUT_FORMAT"
            return 1
            ;;
    esac
    
    log "success" "Test report generated: $OUTPUT_FILE"
}

# Main execution
main() {
    # Display banner
    display_banner
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Test Developer Hub accessibility (required for all tests)
    if ! test_devhub_accessibility; then
        log "error" "Cannot proceed with integration tests. Developer Hub is not accessible."
        exit 1
    fi
    
    # Run integration tests based on type
    case $INTEGRATION_TYPE in
        github)
            log "info" "Running GitHub integration tests..."
            test_github_integration
            ;;
        kubernetes)
            log "info" "Running Kubernetes integration tests..."
            test_kubernetes_integration
            ;;
        ci)
            log "info" "Running CI/CD integration tests..."
            test_cicd_integration
            ;;
        all)
            log "info" "Running all integration tests..."
            test_github_integration
            test_kubernetes_integration
            test_cicd_integration
            ;;
    esac
    
    # Generate test report
    generate_report
    
    # Summary
    echo
    log "info" "Integration test complete. Summary:"
    log "info" "Passed tests: $PASS_COUNT"
    log "info" "Failed tests: $FAIL_COUNT"
    log "info" "Warnings: $WARN_COUNT"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        log "success" "All integration tests PASSED!"
    else
        log "error" "Some integration tests FAILED!"
        exit 1
    fi
}

# Run the script
main "$@" 