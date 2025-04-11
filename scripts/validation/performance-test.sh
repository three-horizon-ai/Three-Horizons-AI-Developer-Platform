#!/bin/bash
# Three Horizons: Performance Testing Script
# This script runs performance tests on Three Horizons platform components

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_TEST_DURATION="5m"
DEFAULT_CONCURRENT_USERS=10
DEFAULT_TARGET_SERVICE="all"
DEFAULT_REQUEST_RATE=10
DEFAULT_OUTPUT_DIR="./performance-test-results"

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
    echo -e "${BOLD}Three Horizons Platform Performance Test Script${NC}"
    echo
    echo "This script runs performance tests on Three Horizons platform components."
    echo "It can test API endpoints, web interfaces, and service responsiveness."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --test-duration DURATION    Test duration (e.g., 5m, 30s, 1h) [default: ${DEFAULT_TEST_DURATION}]"
    echo "  --concurrent-users NUM      Number of concurrent users/connections [default: ${DEFAULT_CONCURRENT_USERS}]"
    echo "  --target-service SERVICE    Service to test (developer-hub, api, web, all) [default: ${DEFAULT_TARGET_SERVICE}]"
    echo "  --request-rate RATE         Rate of requests per second [default: ${DEFAULT_REQUEST_RATE}]"
    echo "  --output-dir DIR            Directory to store test results [default: ${DEFAULT_OUTPUT_DIR}]"
    echo "  --base-url URL              Base URL for testing (required)"
    echo "  --load-test-only            Only run load tests, skip other performance tests"
    echo "  --resource-usage-only       Only run resource usage tests, skip load tests"
    echo "  -h, --help                  Show this help message"
    echo
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Platform Performance Test                         ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script will run performance tests on Three Horizons platform components."
    echo -e "It measures response times, throughput, and resource utilization."
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --test-duration)
                TEST_DURATION=$2
                shift 2
                ;;
            --concurrent-users)
                CONCURRENT_USERS=$2
                shift 2
                ;;
            --target-service)
                TARGET_SERVICE=$2
                shift 2
                ;;
            --request-rate)
                REQUEST_RATE=$2
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR=$2
                shift 2
                ;;
            --base-url)
                BASE_URL=$2
                shift 2
                ;;
            --load-test-only)
                LOAD_TEST_ONLY=true
                shift
                ;;
            --resource-usage-only)
                RESOURCE_USAGE_ONLY=true
                shift
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
    TEST_DURATION=${TEST_DURATION:-$DEFAULT_TEST_DURATION}
    CONCURRENT_USERS=${CONCURRENT_USERS:-$DEFAULT_CONCURRENT_USERS}
    TARGET_SERVICE=${TARGET_SERVICE:-$DEFAULT_TARGET_SERVICE}
    REQUEST_RATE=${REQUEST_RATE:-$DEFAULT_REQUEST_RATE}
    OUTPUT_DIR=${OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}
    LOAD_TEST_ONLY=${LOAD_TEST_ONLY:-false}
    RESOURCE_USAGE_ONLY=${RESOURCE_USAGE_ONLY:-false}
    
    # Validate required parameters
    if [[ -z "$BASE_URL" ]]; then
        log "error" "Base URL must be specified with --base-url"
        show_help
        exit 1
    fi
    
    # Validate target service
    case $TARGET_SERVICE in
        developer-hub|api|web|all)
            ;;
        *)
            log "error" "Invalid target service: $TARGET_SERVICE"
            show_help
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Create output directory if it doesn't exist
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log "info" "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log "error" "curl is not installed. Please install it before proceeding."
        exit 1
    fi
    
    # Check if kubectl is installed (for resource usage tests)
    if [[ "$RESOURCE_USAGE_ONLY" == "true" || "$LOAD_TEST_ONLY" == "false" ]]; then
        if ! command -v kubectl &> /dev/null; then
            log "warning" "kubectl is not installed. Resource usage tests will be limited."
        fi
    fi
    
    # Check if hey is installed (for load testing)
    if [[ "$LOAD_TEST_ONLY" == "true" || "$RESOURCE_USAGE_ONLY" == "false" ]]; then
        if ! command -v hey &> /dev/null; then
            log "warning" "hey is not installed. Will try to use Apache Bench (ab) instead."
            if ! command -v ab &> /dev/null; then
                log "error" "Neither hey nor Apache Bench (ab) is installed. Please install one of them for load testing."
                log "info" "You can install hey with: go install github.com/rakyll/hey@latest"
                log "info" "Or install Apache Bench with: apt-get install apache2-utils (Ubuntu/Debian)"
                exit 1
            fi
        fi
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Check basic connectivity and response time
check_basic_connectivity() {
    log "info" "Checking basic connectivity to $BASE_URL..."
    
    # Run a simple curl test to measure basic response time
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL")
    
    if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "302" ]]; then
        # Measure response time with 5 requests
        log "info" "Measuring basic response time..."
        
        TOTAL_TIME=0
        for i in {1..5}; do
            RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL")
            TOTAL_TIME=$(echo "$TOTAL_TIME + $RESPONSE_TIME" | bc)
            log "info" "Request $i: $RESPONSE_TIME seconds"
        done
        
        AVG_RESPONSE_TIME=$(echo "scale=3; $TOTAL_TIME / 5" | bc)
        log "success" "Average response time: $AVG_RESPONSE_TIME seconds"
        
        # Save to results file
        echo "Basic Connectivity Test" > "$OUTPUT_DIR/basic_connectivity.txt"
        echo "URL: $BASE_URL" >> "$OUTPUT_DIR/basic_connectivity.txt"
        echo "HTTP Response Code: $RESPONSE_CODE" >> "$OUTPUT_DIR/basic_connectivity.txt"
        echo "Average Response Time: $AVG_RESPONSE_TIME seconds" >> "$OUTPUT_DIR/basic_connectivity.txt"
        
        return 0
    else
        log "error" "Failed to connect to $BASE_URL (HTTP code: $RESPONSE_CODE)"
        return 1
    fi
}

# Run load test
run_load_test() {
    local endpoint=$1
    local output_file=$2
    local endpoint_name=$3
    
    log "info" "Running load test on $endpoint for $TEST_DURATION with $CONCURRENT_USERS concurrent users..."
    
    # Use hey if available, otherwise use Apache Bench
    if command -v hey &> /dev/null; then
        log "info" "Using hey for load testing..."
        hey -z "$TEST_DURATION" -c "$CONCURRENT_USERS" -q "$REQUEST_RATE" -o csv "$endpoint" > "$output_file"
        
        if [ $? -eq 0 ]; then
            # Extract and report metrics (assumes CSV output)
            TOTAL_REQUESTS=$(cat "$output_file" | wc -l)
            AVG_RESPONSE_TIME=$(tail -n +2 "$output_file" | awk -F',' '{sum+=$3} END {print sum/(NR-1)}')
            MAX_RESPONSE_TIME=$(tail -n +2 "$output_file" | awk -F',' '{if($3>max) max=$3} END {print max}')
            
            log "success" "Load test completed for $endpoint_name"
            log "info" "Total Requests: $TOTAL_REQUESTS"
            log "info" "Average Response Time: $AVG_RESPONSE_TIME seconds"
            log "info" "Maximum Response Time: $MAX_RESPONSE_TIME seconds"
            
            # Generate summary file
            cat > "${output_file}.summary" << EOF
Load Test Summary for $endpoint_name
===================================
Endpoint: $endpoint
Duration: $TEST_DURATION
Concurrent Users: $CONCURRENT_USERS
Request Rate: $REQUEST_RATE requests/second

Results:
- Total Requests: $TOTAL_REQUESTS
- Average Response Time: $AVG_RESPONSE_TIME seconds
- Maximum Response Time: $MAX_RESPONSE_TIME seconds
EOF
        else
            log "error" "Load test failed for $endpoint_name"
            return 1
        fi
    elif command -v ab &> /dev/null; then
        log "info" "Using Apache Bench for load testing..."
        
        # Convert duration to number of requests
        TOTAL_REQUESTS=$(($(echo "$TEST_DURATION" | grep -o '[0-9]\+' | head -1) * 60 * $REQUEST_RATE))
        if [[ "$TEST_DURATION" == *"s"* ]]; then
            TOTAL_REQUESTS=$(($(echo "$TEST_DURATION" | grep -o '[0-9]\+' | head -1) * $REQUEST_RATE))
        fi
        
        ab -n "$TOTAL_REQUESTS" -c "$CONCURRENT_USERS" -g "$output_file" "$endpoint" > "${output_file}.ab"
        
        if [ $? -eq 0 ]; then
            # Extract and report metrics
            TOTAL_REQUESTS=$(grep "Complete requests:" "${output_file}.ab" | awk '{print $3}')
            AVG_RESPONSE_TIME=$(grep "Time per request:" "${output_file}.ab" | head -1 | awk '{print $4/1000}')
            MAX_RESPONSE_TIME=$(tail -n +2 "$output_file" | awk '{if($5>max) max=$5} END {print max/1000}')
            
            log "success" "Load test completed for $endpoint_name"
            log "info" "Total Requests: $TOTAL_REQUESTS"
            log "info" "Average Response Time: $AVG_RESPONSE_TIME seconds"
            log "info" "Maximum Response Time: $MAX_RESPONSE_TIME seconds"
            
            # Generate summary file
            cat > "${output_file}.summary" << EOF
Load Test Summary for $endpoint_name
===================================
Endpoint: $endpoint
Duration: $TEST_DURATION (approximated to $TOTAL_REQUESTS requests)
Concurrent Users: $CONCURRENT_USERS

Results:
- Total Requests: $TOTAL_REQUESTS
- Average Response Time: $AVG_RESPONSE_TIME seconds
- Maximum Response Time: $MAX_RESPONSE_TIME seconds
EOF
        else
            log "error" "Load test failed for $endpoint_name"
            return 1
        fi
    else
        log "error" "No load testing tool available"
        return 1
    fi
    
    return 0
}

# Monitor resource usage
monitor_resource_usage() {
    log "info" "Monitoring resource usage for $TEST_DURATION..."
    
    # Create output file
    RESOURCE_OUTPUT_FILE="$OUTPUT_DIR/resource_usage.txt"
    echo "Three Horizons Platform Resource Usage" > "$RESOURCE_OUTPUT_FILE"
    echo "Timestamp: $(date)" >> "$RESOURCE_OUTPUT_FILE"
    echo "Duration: $TEST_DURATION" >> "$RESOURCE_OUTPUT_FILE"
    echo "=============================================" >> "$RESOURCE_OUTPUT_FILE"
    
    # Check if we have kubectl access for better monitoring
    if command -v kubectl &> /dev/null && kubectl get nodes &> /dev/null; then
        log "info" "Using kubectl to monitor Kubernetes resources..."
        
        # Get namespace based on target service
        NAMESPACE="developer-hub"
        if [[ "$TARGET_SERVICE" != "all" && "$TARGET_SERVICE" != "developer-hub" ]]; then
            NAMESPACE="$TARGET_SERVICE"
        fi
        
        # Monitor CPU and memory usage at intervals
        # Convert duration to seconds for loop
        DURATION_SECONDS=300 # Default 5 minutes
        if [[ "$TEST_DURATION" =~ ([0-9]+)m ]]; then
            DURATION_SECONDS=$((${BASH_REMATCH[1]} * 60))
        elif [[ "$TEST_DURATION" =~ ([0-9]+)s ]]; then
            DURATION_SECONDS=${BASH_REMATCH[1]}
        elif [[ "$TEST_DURATION" =~ ([0-9]+)h ]]; then
            DURATION_SECONDS=$((${BASH_REMATCH[1]} * 3600))
        fi
        
        INTERVAL=15 # Sample every 15 seconds
        ITERATIONS=$((DURATION_SECONDS / INTERVAL))
        
        # Header for resource usage data
        echo "Pod CPU and Memory Usage (sampled every $INTERVAL seconds)" >> "$RESOURCE_OUTPUT_FILE"
        echo "Pod Name,CPU Usage,Memory Usage" >> "$RESOURCE_OUTPUT_FILE"
        
        for ((i=1; i<=ITERATIONS; i++)); do
            log "info" "Sampling resource usage ($i/$ITERATIONS)..."
            
            # Get pod resource usage
            kubectl top pods -n "$NAMESPACE" >> "$RESOURCE_OUTPUT_FILE"
            echo "-------------------------------------------" >> "$RESOURCE_OUTPUT_FILE"
            
            # Wait for next interval
            if [[ $i -lt $ITERATIONS ]]; then
                sleep $INTERVAL
            fi
        done
        
        # Get node resource usage
        echo "Node Resource Usage" >> "$RESOURCE_OUTPUT_FILE"
        echo "=============================================" >> "$RESOURCE_OUTPUT_FILE"
        kubectl top nodes >> "$RESOURCE_OUTPUT_FILE"
        
        log "success" "Resource usage monitoring completed. Results saved to $RESOURCE_OUTPUT_FILE"
    else
        log "warning" "kubectl not available or not authenticated. Using basic monitoring..."
        
        # Use simple resource monitoring
        echo "Basic Resource Monitoring" >> "$RESOURCE_OUTPUT_FILE"
        echo "=============================================" >> "$RESOURCE_OUTPUT_FILE"
        
        if curl -s "$BASE_URL/health" -o /dev/null; then
            echo "Health endpoint is accessible: $BASE_URL/health" >> "$RESOURCE_OUTPUT_FILE"
        else
            echo "Health endpoint is not accessible or not available" >> "$RESOURCE_OUTPUT_FILE"
        fi
        
        # Basic connectivity check
        echo "Response times:" >> "$RESOURCE_OUTPUT_FILE"
        for i in {1..5}; do
            RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL")
            echo "  Request $i: $RESPONSE_TIME seconds" >> "$RESOURCE_OUTPUT_FILE"
            sleep 1
        done
        
        log "warning" "Limited resource usage data available without kubectl access"
    fi
    
    return 0
}

# Run load tests for specified target
run_target_load_tests() {
    local target=$1
    
    case $target in
        developer-hub)
            log "info" "Running Developer Hub load tests..."
            
            # Main page load test
            run_load_test "$BASE_URL" "$OUTPUT_DIR/devhub_main.csv" "Developer Hub Main Page"
            
            # Catalog API load test (if accessible)
            if curl -s "$BASE_URL/api/catalog/entities" -o /dev/null; then
                run_load_test "$BASE_URL/api/catalog/entities" "$OUTPUT_DIR/devhub_catalog_api.csv" "Developer Hub Catalog API"
            else
                log "warning" "Catalog API requires authentication, skipping load test"
            fi
            
            # Template catalog load test (if accessible)
            if curl -s "$BASE_URL/create" -o /dev/null; then
                run_load_test "$BASE_URL/create" "$OUTPUT_DIR/devhub_templates.csv" "Developer Hub Templates Page"
            fi
            ;;
            
        api)
            log "info" "Running API load tests..."
            
            # Try to identify API endpoints
            if [[ "$BASE_URL" == *"api"* ]]; then
                API_URL="$BASE_URL"
            else
                API_URL="${BASE_URL}/api"
            fi
            
            # API health endpoint test
            if curl -s "$API_URL/health" -o /dev/null; then
                run_load_test "$API_URL/health" "$OUTPUT_DIR/api_health.csv" "API Health Endpoint"
            fi
            
            # API version endpoint test
            if curl -s "$API_URL/version" -o /dev/null; then
                run_load_test "$API_URL/version" "$OUTPUT_DIR/api_version.csv" "API Version Endpoint"
            fi
            ;;
            
        web)
            log "info" "Running Web interface load tests..."
            
            # Main page load test
            run_load_test "$BASE_URL" "$OUTPUT_DIR/web_main.csv" "Web Main Page"
            
            # About page load test (if exists)
            if curl -s "$BASE_URL/about" -o /dev/null; then
                run_load_test "$BASE_URL/about" "$OUTPUT_DIR/web_about.csv" "Web About Page"
            fi
            ;;
            
        all)
            log "info" "Running load tests for all components..."
            
            # Main page load test
            run_load_test "$BASE_URL" "$OUTPUT_DIR/main_page.csv" "Main Page"
            
            # If we can access /api path, test that too
            if curl -s "$BASE_URL/api" -o /dev/null; then
                run_load_test "$BASE_URL/api" "$OUTPUT_DIR/api_endpoint.csv" "API Endpoint"
            fi
            
            # If we can access /health path, test that too
            if curl -s "$BASE_URL/health" -o /dev/null; then
                run_load_test "$BASE_URL/health" "$OUTPUT_DIR/health_endpoint.csv" "Health Endpoint"
            fi
            ;;
    esac
}

# Generate performance report
generate_report() {
    log "info" "Generating performance test report..."
    
    REPORT_FILE="$OUTPUT_DIR/performance_test_report.html"
    
    cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Three Horizons Platform Performance Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333366; }
        .summary { margin: 20px 0; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .threshold-good { color: green; }
        .threshold-warning { color: orange; }
        .threshold-critical { color: red; }
    </style>
</head>
<body>
    <h1>Three Horizons Platform Performance Test Report</h1>
    <p><strong>Timestamp:</strong> $(date +'%Y-%m-%d %H:%M:%S')</p>
    <p><strong>Base URL:</strong> $BASE_URL</p>
    <p><strong>Target Service:</strong> $TARGET_SERVICE</p>
    <p><strong>Test Duration:</strong> $TEST_DURATION</p>
    <p><strong>Concurrent Users:</strong> $CONCURRENT_USERS</p>
    
    <h2>Test Summary</h2>
    <div class="summary">
EOF

    # Add basic connectivity results if available
    if [[ -f "$OUTPUT_DIR/basic_connectivity.txt" ]]; then
        BASIC_RESPONSE_TIME=$(grep "Average Response Time:" "$OUTPUT_DIR/basic_connectivity.txt" | awk '{print $4}')
        cat >> "$REPORT_FILE" << EOF
        <h3>Basic Connectivity</h3>
        <table>
            <tr>
                <th>Metric</th>
                <th>Value</th>
                <th>Status</th>
            </tr>
            <tr>
                <td>Response Time</td>
                <td>$BASIC_RESPONSE_TIME seconds</td>
                <td class="$(if (( $(echo "$BASIC_RESPONSE_TIME < 0.3" | bc -l) )); then echo "threshold-good"; elif (( $(echo "$BASIC_RESPONSE_TIME < 1.0" | bc -l) )); then echo "threshold-warning"; else echo "threshold-critical"; fi)">
                    $(if (( $(echo "$BASIC_RESPONSE_TIME < 0.3" | bc -l) )); then echo "Good"; elif (( $(echo "$BASIC_RESPONSE_TIME < 1.0" | bc -l) )); then echo "Acceptable"; else echo "Slow"; fi)
                </td>
            </tr>
        </table>
EOF
    fi

    # Add load test results if available
    cat >> "$REPORT_FILE" << EOF
        <h3>Load Test Results</h3>
        <table>
            <tr>
                <th>Endpoint</th>
                <th>Requests</th>
                <th>Avg Response Time</th>
                <th>Max Response Time</th>
                <th>Status</th>
            </tr>
EOF

    # Find all summary files and add them to the report
    for summary_file in "$OUTPUT_DIR"/*.summary; do
        if [[ -f "$summary_file" ]]; then
            ENDPOINT=$(grep "Endpoint:" "$summary_file" | cut -d ' ' -f 2-)
            TOTAL_REQUESTS=$(grep "Total Requests:" "$summary_file" | awk '{print $3}')
            AVG_RESPONSE_TIME=$(grep "Average Response Time:" "$summary_file" | awk '{print $4}')
            MAX_RESPONSE_TIME=$(grep "Maximum Response Time:" "$summary_file" | awk '{print $4}')
            ENDPOINT_NAME=$(echo "$summary_file" | sed 's/.*\/\(.*\)\.summary/\1/' | sed 's/_/ /g')
            
            cat >> "$REPORT_FILE" << EOF
            <tr>
                <td>$ENDPOINT_NAME</td>
                <td>$TOTAL_REQUESTS</td>
                <td>$AVG_RESPONSE_TIME seconds</td>
                <td>$MAX_RESPONSE_TIME seconds</td>
                <td class="$(if (( $(echo "$AVG_RESPONSE_TIME < 0.5" | bc -l) )); then echo "threshold-good"; elif (( $(echo "$AVG_RESPONSE_TIME < 2.0" | bc -l) )); then echo "threshold-warning"; else echo "threshold-critical"; fi)">
                    $(if (( $(echo "$AVG_RESPONSE_TIME < 0.5" | bc -l) )); then echo "Good"; elif (( $(echo "$AVG_RESPONSE_TIME < 2.0" | bc -l) )); then echo "Acceptable"; else echo "Slow"; fi)
                </td>
            </tr>
EOF
        fi
    done

    cat >> "$REPORT_FILE" << EOF
        </table>
EOF

    # Add resource usage results if available
    if [[ -f "$OUTPUT_DIR/resource_usage.txt" ]]; then
        cat >> "$REPORT_FILE" << EOF
        <h3>Resource Usage</h3>
        <p>See detailed resource usage data in the <a href="resource_usage.txt">resource usage file</a>.</p>
EOF
    fi

    # Add recommendations
    cat >> "$REPORT_FILE" << EOF
    </div>
    
    <h2>Recommendations</h2>
    <ul>
EOF

    # Add recommendations based on results
    if [[ -f "$OUTPUT_DIR/basic_connectivity.txt" ]]; then
        if (( $(echo "$BASIC_RESPONSE_TIME > 1.0" | bc -l) )); then
            cat >> "$REPORT_FILE" << EOF
        <li class="threshold-critical">Consider optimizing the main page load time, which is currently slow ($BASIC_RESPONSE_TIME seconds).</li>
EOF
        fi
    fi

    # Check any slow endpoints
    SLOW_ENDPOINTS=false
    for summary_file in "$OUTPUT_DIR"/*.summary; do
        if [[ -f "$summary_file" ]]; then
            AVG_RESPONSE_TIME=$(grep "Average Response Time:" "$summary_file" | awk '{print $4}')
            ENDPOINT_NAME=$(echo "$summary_file" | sed 's/.*\/\(.*\)\.summary/\1/' | sed 's/_/ /g')
            
            if (( $(echo "$AVG_RESPONSE_TIME > 2.0" | bc -l) )); then
                cat >> "$REPORT_FILE" << EOF
        <li class="threshold-critical">The $ENDPOINT_NAME endpoint is extremely slow ($AVG_RESPONSE_TIME seconds). Consider optimizing this endpoint.</li>
EOF
                SLOW_ENDPOINTS=true
            elif (( $(echo "$AVG_RESPONSE_TIME > 1.0" | bc -l) )); then
                cat >> "$REPORT_FILE" << EOF
        <li class="threshold-warning">The $ENDPOINT_NAME endpoint is slow ($AVG_RESPONSE_TIME seconds). Consider reviewing its performance.</li>
EOF
                SLOW_ENDPOINTS=true
            fi
        fi
    done
    
    if [[ "$SLOW_ENDPOINTS" == "false" ]]; then
        cat >> "$REPORT_FILE" << EOF
        <li class="threshold-good">All tested endpoints respond within acceptable time limits.</li>
EOF
    fi

    # Add scaling recommendation if high load
    if [[ $CONCURRENT_USERS -gt 20 ]]; then
        cat >> "$REPORT_FILE" << EOF
        <li>For production environments handling $CONCURRENT_USERS concurrent users, consider scaling the platform components horizontally.</li>
EOF
    fi

    # Close HTML tags
    cat >> "$REPORT_FILE" << EOF
    </ul>
    
    <h2>Conclusion</h2>
    <p>
        This performance test shows that the Three Horizons platform 
        $(if [[ "$SLOW_ENDPOINTS" == "false" && (( $(echo "$BASIC_RESPONSE_TIME < 0.5" | bc -l) )) ]]; then 
            echo "performs well under the tested load conditions."; 
        elif [[ "$SLOW_ENDPOINTS" == "true" || (( $(echo "$BASIC_RESPONSE_TIME > 1.0" | bc -l) )) ]]; then 
            echo "has performance issues that should be addressed."; 
        else 
            echo "performs adequately but has room for optimization."; 
        fi)
    </p>
    
    <p>Tests were conducted with $CONCURRENT_USERS concurrent users for $TEST_DURATION.</p>
</body>
</html>
EOF
    
    log "success" "Performance test report generated: $REPORT_FILE"
}

# Main execution
main() {
    # Display banner
    display_banner
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Check basic connectivity
    if ! check_basic_connectivity; then
        log "error" "Basic connectivity check failed. Cannot proceed with performance tests."
        exit 1
    fi
    
    # Run load tests if not in resource-usage-only mode
    if [[ "$RESOURCE_USAGE_ONLY" == "false" ]]; then
        log "info" "Starting load tests..."
        run_target_load_tests "$TARGET_SERVICE"
    fi
    
    # Monitor resource usage if not in load-test-only mode
    if [[ "$LOAD_TEST_ONLY" == "false" ]]; then
        log "info" "Starting resource usage monitoring..."
        monitor_resource_usage
    fi
    
    # Generate performance report
    generate_report
    
    log "success" "Performance testing completed!"
    log "info" "Results saved to $OUTPUT_DIR"
}

# Run the script
main "$@" 