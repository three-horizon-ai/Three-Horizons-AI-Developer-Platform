#!/bin/bash
# Three Horizons: Script Validator
# This script checks all shell scripts in the repository for common issues

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for reporting
TOTAL_SCRIPTS=0
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

# Log function
log() {
    local type=$1
    local message=$2
    local color=$NC
    
    case $type in
        "info") color=$BLUE;;
        "success") color=$GREEN;;
        "warning") color=$YELLOW; WARN_COUNT=$((WARN_COUNT + 1));;
        "error") color=$RED; FAIL_COUNT=$((FAIL_COUNT + 1));;
    esac
    
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] [$type] $message${NC}"
}

# Display help information
show_help() {
    echo -e "${BOLD}Three Horizons Script Validator${NC}"
    echo
    echo "This script checks all shell scripts in the repository for common issues"
    echo "including syntax errors, shellcheck warnings, and missing elements like"
    echo "help text or standard functions."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --fix                  Attempt to fix common issues automatically"
    echo "  --check-dir DIRECTORY  Only check scripts in this directory"
    echo "  --verbose              Show detailed output for each check"
    echo "  --report-file FILE     Output report to file [default: script-check-report.txt]"
    echo "  -h, --help             Show this help message"
    echo
}

# Display banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Script Validator                                  ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "This script checks all shell scripts in the repository for common issues,"
    echo -e "ensures they follow best practices, and validates syntax."
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                FIX_ISSUES=true
                shift
                ;;
            --check-dir)
                CHECK_DIR=$2
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --report-file)
                REPORT_FILE=$2
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
    FIX_ISSUES=${FIX_ISSUES:-false}
    CHECK_DIR=${CHECK_DIR:-"scripts"}
    VERBOSE=${VERBOSE:-false}
    REPORT_FILE=${REPORT_FILE:-"script-check-report.txt"}
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check if shellcheck is installed
    if ! command -v shellcheck &> /dev/null; then
        log "warning" "shellcheck is not installed. Shell script syntax and style will not be checked."
        log "info" "Install with: apt-get install shellcheck (Ubuntu/Debian) or brew install shellcheck (macOS)"
        SHELLCHECK_AVAILABLE=false
    else
        SHELLCHECK_AVAILABLE=true
        log "success" "shellcheck is available for syntax checking"
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log "warning" "Not inside a git repository. Some features may be limited."
        IN_GIT_REPO=false
    else
        IN_GIT_REPO=true
        log "success" "Inside a git repository at $REPO_ROOT"
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Find all shell scripts
find_shell_scripts() {
    local check_dir=$1
    local scripts=()
    
    log "info" "Finding shell scripts in $check_dir..."
    
    # Find files with .sh extension or with bash shebang
    while IFS= read -r -d '' file; do
        scripts+=("$file")
    done < <(find "$check_dir" -type f \( -name "*.sh" -o -exec grep -l "^#!/bin/bash" {} \; -o -exec grep -l "^#!/usr/bin/env bash" {} \; \) -print0)
    
    TOTAL_SCRIPTS=${#scripts[@]}
    log "info" "Found $TOTAL_SCRIPTS shell scripts to check"
    
    echo "${scripts[@]}"
}

# Check script for shebang line
check_shebang() {
    local script=$1
    local has_shebang=false
    
    if grep -q "^#!/bin/bash" "$script" || grep -q "^#!/usr/bin/env bash" "$script"; then
        has_shebang=true
        [[ "$VERBOSE" == "true" ]] && log "success" "$script has a proper shebang line"
    else
        log "error" "$script does not have a proper shebang line (#!/bin/bash or #!/usr/bin/env bash)"
        
        if [[ "$FIX_ISSUES" == "true" ]]; then
            sed -i '1s/^/#!/bin/bash\n/' "$script"
            log "info" "Added shebang line to $script"
        fi
    fi
    
    echo "$has_shebang"
}

# Check if script has a help function
check_help_function() {
    local script=$1
    local has_help=false
    
    if grep -q "show_help" "$script" || grep -q "usage()" "$script" || grep -q "display_help" "$script"; then
        has_help=true
        [[ "$VERBOSE" == "true" ]] && log "success" "$script has a help function"
    else
        log "warning" "$script does not have a help function"
        
        if [[ "$FIX_ISSUES" == "true" ]]; then
            # Get the script name for use in the help text
            script_name=$(basename "$script")
            
            # Add a basic help function after the shebang line
            awk 'NR==1{print; print ""; print "# Display help information"; print "show_help() {"; print "    echo \"Usage: $0 [options]\""; print "    echo \"\""; print "    echo \"Options:\""; print "    echo \"  -h, --help    Show this help message\""; print "    echo \"\""; print "}"; print ""} NR!=1' "$script" > "${script}.new"
            mv "${script}.new" "$script"
            
            # Add parse_args function if it doesn't exist
            if ! grep -q "parse_args" "$script"; then
                echo '
# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown parameter: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Run the script
parse_args "$@"' >> "$script"
            fi
            
            log "info" "Added help function to $script"
        fi
    fi
    
    echo "$has_help"
}

# Run shellcheck on script
run_shellcheck() {
    local script=$1
    local shellcheck_passed=true
    
    if [[ "$SHELLCHECK_AVAILABLE" == "true" ]]; then
        # Run shellcheck with common exclusions
        shellcheck_result=$(shellcheck -e SC2155,SC2086 "$script" 2>&1)
        
        if [[ -n "$shellcheck_result" ]]; then
            shellcheck_passed=false
            log "warning" "$script has shellcheck warnings:"
            if [[ "$VERBOSE" == "true" ]]; then
                echo "$shellcheck_result" | sed 's/^/    /'
            else
                echo "$shellcheck_result" | head -3 | sed 's/^/    /'
                if [[ $(echo "$shellcheck_result" | wc -l) -gt 3 ]]; then
                    log "info" "    ... (more warnings, use --verbose to see all)"
                fi
            fi
        else
            [[ "$VERBOSE" == "true" ]] && log "success" "$script passes shellcheck"
        fi
    else
        [[ "$VERBOSE" == "true" ]] && log "info" "Skipping shellcheck for $script"
    fi
    
    echo "$shellcheck_passed"
}

# Check script for executable permission
check_executable() {
    local script=$1
    local is_executable=false
    
    if [[ -x "$script" ]]; then
        is_executable=true
        [[ "$VERBOSE" == "true" ]] && log "success" "$script is executable"
    else
        log "warning" "$script is not executable"
        
        if [[ "$FIX_ISSUES" == "true" ]]; then
            chmod +x "$script"
            log "info" "Made $script executable"
        fi
    fi
    
    echo "$is_executable"
}

# Check script for standard elements
check_standard_elements() {
    local script=$1
    local issues=0
    
    # Check for log function
    if ! grep -q "log()" "$script"; then
        log "warning" "$script does not have a standard log function"
        issues=$((issues + 1))
    fi
    
    # Check for banner display
    if ! grep -q "display_banner" "$script" && ! grep -q "banner" "$script"; then
        log "warning" "$script does not have a banner display function"
        issues=$((issues + 1))
    fi
    
    # Check for error handling (set -e)
    if ! grep -q "set -e" "$script"; then
        log "warning" "$script does not have 'set -e' for error handling"
        issues=$((issues + 1))
        
        if [[ "$FIX_ISSUES" == "true" ]]; then
            # Add set -e after the shebang line
            awk 'NR==1{print; print ""; print "set -e"} NR!=1' "$script" > "${script}.new"
            mv "${script}.new" "$script"
            log "info" "Added 'set -e' to $script"
        fi
    fi
    
    # Check for prerequisite checks
    if ! grep -q "check_prerequisites" "$script" && ! grep -q "prerequisites" "$script"; then
        log "warning" "$script does not have prerequisite checks"
        issues=$((issues + 1))
    fi
    
    # Check for main function
    if ! grep -q "main()" "$script" && ! grep -q "function main" "$script"; then
        log "warning" "$script does not have a main function"
        issues=$((issues + 1))
    fi
    
    # Return success if no issues or only minor warnings
    if [[ $issues -eq 0 ]]; then
        [[ "$VERBOSE" == "true" ]] && log "success" "$script contains all standard elements"
        return 0
    else
        return 1
    fi
}

# Validate a single script
validate_script() {
    local script=$1
    local all_checks_passed=true
    
    [[ "$VERBOSE" == "true" ]] && echo -e "\n${BOLD}Checking: $script${NC}"
    
    # Run all checks
    local has_shebang=$(check_shebang "$script")
    local has_help=$(check_help_function "$script")
    local shellcheck_passed=$(run_shellcheck "$script")
    local is_executable=$(check_executable "$script")
    local standard_elements=true; check_standard_elements "$script" || standard_elements=false
    
    # Determine overall result
    if [[ "$has_shebang" == "false" ]]; then
        all_checks_passed=false
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        [[ "$VERBOSE" != "true" ]] && log "success" "$script passes all checks"
    fi
    
    # Add to report
    echo -e "Script: $script" >> "$REPORT_FILE"
    echo -e "  Shebang Line: $(if [[ "$has_shebang" == "true" ]]; then echo "✓"; else echo "✗"; fi)" >> "$REPORT_FILE"
    echo -e "  Help Function: $(if [[ "$has_help" == "true" ]]; then echo "✓"; else echo "✗"; fi)" >> "$REPORT_FILE"
    echo -e "  ShellCheck: $(if [[ "$shellcheck_passed" == "true" ]]; then echo "✓"; else echo "✗"; fi)" >> "$REPORT_FILE"
    echo -e "  Executable: $(if [[ "$is_executable" == "true" ]]; then echo "✓"; else echo "✗"; fi)" >> "$REPORT_FILE"
    echo -e "  Standard Elements: $(if [[ "$standard_elements" == "true" ]]; then echo "✓"; else echo "✗"; fi)" >> "$REPORT_FILE"
    echo -e "  Overall: $(if [[ "$all_checks_passed" == "true" ]]; then echo "PASS"; else echo "FAIL"; fi)" >> "$REPORT_FILE"
    echo -e "" >> "$REPORT_FILE"
    
    echo "$all_checks_passed"
}

# Generate report summary
generate_report_summary() {
    local total=$1
    local passed=$2
    local failed=$3
    local warnings=$4
    
    # Add summary to report file
    cat > "${REPORT_FILE}.tmp" << EOF
Three Horizons Script Validation Summary
=======================================
Timestamp: $(date +'%Y-%m-%d %H:%M:%S')

Summary:
- Total Scripts: $total
- Passed: $passed
- Failed: $failed
- Warnings: $warnings

Overall Status: $(if [[ $failed -eq 0 ]]; then echo "PASSED"; else echo "FAILED"; fi)

Detailed Results:
----------------------------------------

EOF

    # Append detailed results
    cat "$REPORT_FILE" >> "${REPORT_FILE}.tmp"
    mv "${REPORT_FILE}.tmp" "$REPORT_FILE"
    
    log "success" "Validation report generated: $REPORT_FILE"
}

# Main execution
main() {
    # Display banner
    display_banner
    
    # Check prerequisites
    check_prerequisites
    
    # Create empty report file
    > "$REPORT_FILE"
    
    # Find all shell scripts
    scripts=($(find_shell_scripts "$CHECK_DIR"))
    
    # Validate each script
    for script in "${scripts[@]}"; do
        validate_script "$script"
    done
    
    # Generate report summary
    generate_report_summary "$TOTAL_SCRIPTS" "$PASS_COUNT" "$FAIL_COUNT" "$WARN_COUNT"
    
    # Print summary
    echo
    log "info" "Validation complete. Summary:"
    log "info" "Total Scripts: $TOTAL_SCRIPTS"
    log "info" "Passed: $PASS_COUNT"
    log "info" "Failed: $FAIL_COUNT"
    log "info" "Warnings: $WARN_COUNT"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        log "success" "All scripts passed required checks!"
    else
        log "error" "Some scripts failed validation checks."
        exit 1
    fi
}

# Parse command line arguments
parse_args "$@"

# Run main function
main 