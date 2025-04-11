#!/bin/bash
# Three Horizons: Script Template
# Replace this comment with a description of what the script does

set -e

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

# Default parameter values
DEFAULT_PARAM1="default1"
DEFAULT_PARAM2="default2"

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
    echo -e "${BOLD}Three Horizons: Script Template${NC}"
    echo -e "Version: ${VERSION}"
    echo
    echo "Description:"
    echo "  This is a template script that can be used as a foundation for new scripts."
    echo "  Replace this description with a specific summary of what your script does."
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --param1 VALUE            Description of parameter 1 [default: ${DEFAULT_PARAM1}]"
    echo "  --param2 VALUE            Description of parameter 2 [default: ${DEFAULT_PARAM2}]"
    echo "  --required-param VALUE    Required parameter with no default value"
    echo "  --flag                    Boolean flag parameter (no value required)"
    echo "  --output-file FILE        Output file path [default: output.txt]"
    echo "  --verbose                 Enable verbose output"
    echo "  --version                 Show version information"
    echo "  -h, --help                Show this help message"
    echo
}

# Display script banner
display_banner() {
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "${BOLD}      Three Horizons - Script Template                                   ${NC}"
    echo -e "${BOLD}=========================================================================${NC}"
    echo -e "Replace this text with a brief description of the script's purpose."
    echo -e "It should explain what the script does and what to expect when running it."
    echo -e "${BOLD}=========================================================================${NC}"
    echo
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --param1)
                PARAM1=$2
                shift 2
                ;;
            --param2)
                PARAM2=$2
                shift 2
                ;;
            --required-param)
                REQUIRED_PARAM=$2
                shift 2
                ;;
            --flag)
                FLAG=true
                shift
                ;;
            --output-file)
                OUTPUT_FILE=$2
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --version)
                echo "Version: $VERSION"
                exit 0
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
    
    # Set defaults for optional parameters
    PARAM1=${PARAM1:-$DEFAULT_PARAM1}
    PARAM2=${PARAM2:-$DEFAULT_PARAM2}
    FLAG=${FLAG:-false}
    OUTPUT_FILE=${OUTPUT_FILE:-"output.txt"}
    VERBOSE=${VERBOSE:-false}
    
    # Validate required parameters
    if [[ -z "$REQUIRED_PARAM" ]]; then
        log "error" "Required parameter not provided: --required-param"
        show_help
        exit 1
    fi
    
    # Display parameters in verbose mode
    if [[ "$VERBOSE" == "true" ]]; then
        log "info" "Parameter values:"
        log "info" "  PARAM1 = $PARAM1"
        log "info" "  PARAM2 = $PARAM2"
        log "info" "  REQUIRED_PARAM = $REQUIRED_PARAM"
        log "info" "  FLAG = $FLAG"
        log "info" "  OUTPUT_FILE = $OUTPUT_FILE"
    fi
}

# Check prerequisites
check_prerequisites() {
    log "info" "Verifying prerequisites..."
    
    # Check for required commands
    if ! command -v jq &> /dev/null; then
        log "error" "jq is not installed. Please install it before proceeding."
        log "info" "Install with: apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
        exit 1
    fi
    
    # Check if running with sufficient permissions
    if [[ "$EUID" -ne 0 && "$SKIP_ROOT_CHECK" != "true" ]]; then
        log "warning" "This script may require root privileges for some operations."
        read -p "Continue without root privileges? (y/N): " CONTINUE
        if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
            log "info" "Rerun with sudo or as root user."
            exit 0
        fi
    fi
    
    log "success" "Prerequisites verified successfully."
}

# Example function for your script's main logic
example_function() {
    local input=$1
    local output=$2
    
    log "info" "Processing $input..."
    
    # Example logic
    echo "Processing $input with parameters:" > "$output"
    echo "  PARAM1: $PARAM1" >> "$output"
    echo "  PARAM2: $PARAM2" >> "$output"
    echo "  REQUIRED_PARAM: $REQUIRED_PARAM" >> "$output"
    echo "  FLAG: $FLAG" >> "$output"
    
    log "success" "Processing completed. Results saved to $output"
}

# Cleanup function called on script exit
cleanup() {
    local exit_code=$?
    
    # Perform cleanup operations
    log "info" "Performing cleanup..."
    
    # Delete temporary files
    if [[ -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
        log "info" "Removed temporary directory: $TMP_DIR"
    fi
    
    if [[ "$exit_code" -eq 0 ]]; then
        log "success" "Script completed successfully!"
    else
        log "error" "Script exited with error code: $exit_code"
    fi
    
    exit $exit_code
}

# Register cleanup function to be called on script exit
trap cleanup EXIT

# Main execution function
main() {
    # Create temporary directory
    TMP_DIR=$(mktemp -d)
    log "info" "Created temporary directory: $TMP_DIR"
    
    # Display banner
    display_banner
    
    # Check prerequisites
    check_prerequisites
    
    # Example function call
    example_function "$REQUIRED_PARAM" "$OUTPUT_FILE"
    
    log "success" "Main execution completed."
}

# Run the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse command line arguments
    parse_args "$@"
    
    # Run main function
    main
fi 