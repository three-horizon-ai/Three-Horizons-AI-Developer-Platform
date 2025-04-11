#!/bin/bash

# Three Horizons Platform - Enhanced Link Validator
# Version 1.0.0 - April 9, 2025
# This script performs comprehensive link checking in markdown files

# Text colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
DOCS_DIR=$(pwd)
OUTPUT_DIR="./reports/link-validation"
REPORT_FILE="${OUTPUT_DIR}/link-report-$(date +%Y%m%d-%H%M%S).md"
SUMMARY_FILE="${OUTPUT_DIR}/link-summary-$(date +%Y%m%d-%H%M%S).txt"
HISTORY_FILE="${OUTPUT_DIR}/link-history.json"
MAX_EXTERNAL_RETRIES=3
EXTERNAL_TIMEOUT=10
CHECK_EXTERNAL=false
VERBOSE=false

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Initialize counters
total_files=0
broken_internal_links=0
broken_external_links=0
total_links=0
fixed_links=0

# Display help information
show_help() {
    echo -e "${BLUE}Enhanced Link Validator for Three Horizons Platform${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help             Display this help message"
    echo "  -e, --external         Check external links (slower)"
    echo "  -v, --verbose          Display detailed information during execution"
    echo "  -d, --directory DIR    Specify the directory to scan (default: current)"
    echo "  -f, --fix              Attempt to auto-fix common link issues"
    echo "  -s, --summary-only     Only display summary, not full report"
    echo ""
    echo "Examples:"
    echo "  $0 --external          Check all links including external URLs"
    echo "  $0 --directory ./docs  Only check links in the docs directory"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    
    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
        -e|--external)
            CHECK_EXTERNAL=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--directory)
            DOCS_DIR="$2"
            shift
            shift
            ;;
        -f|--fix)
            FIX_LINKS=true
            shift
            ;;
        -s|--summary-only)
            SUMMARY_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $key${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Log message function
log_message() {
    local level=$1
    local message=$2
    
    case $level in
        "INFO")
            echo -e "[${GREEN}INFO${NC}] $message"
            ;;
        "WARN")
            echo -e "[${YELLOW}WARN${NC}] $message"
            ;;
        "ERROR")
            echo -e "[${RED}ERROR${NC}] $message"
            ;;
        "DEBUG")
            if [ "$VERBOSE" = true ]; then
                echo -e "[${BLUE}DEBUG${NC}] $message"
            fi
            ;;
    esac
}

# Initialize report file
initialize_report() {
    cat > "$REPORT_FILE" << EOF
# Link Validation Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

This report identifies broken links in the Three Horizons Platform documentation.

## Summary

- **Total files scanned:** [Placeholder]
- **Total links checked:** [Placeholder]
- **Broken internal links:** [Placeholder]
- **Broken external links:** [Placeholder]
- **Fixed links:** [Placeholder]

## Broken Links Details

| File | Link Type | Link Target | Status | Suggestion |
|------|-----------|-------------|--------|------------|
EOF
}

# Extract links from a markdown file
extract_links() {
    local file="$1"
    
    # Extract markdown links [text](url)
    grep -o -E '\[.*?\]\([^)]+\)' "$file" | sed 's/.*(\(.*\))/\1/' | sort | uniq
}

# Check if a file exists
check_link() {
    local file="$1"
    local link="$2"
    local source_dir=$(dirname "$file")
    local link_type=""
    local status=""
    local suggestion=""
    
    # Increment counter
    total_links=$((total_links+1))
    
    # Handle different types of links
    if [[ "$link" =~ ^http[s]?:// ]]; then
        # External URL
        link_type="External"
        
        if [ "$CHECK_EXTERNAL" = true ]; then
            log_message "DEBUG" "Checking external link: $link"
            
            local retry_count=0
            while [ $retry_count -lt $MAX_EXTERNAL_RETRIES ]; do
                status_code=$(curl -s -o /dev/null -w "%{http_code}" -L --connect-timeout $EXTERNAL_TIMEOUT "$link" 2>/dev/null)
                
                if [[ $status_code -ge 200 && $status_code -lt 400 ]]; then
                    status="OK"
                    log_message "DEBUG" "External link OK: $link"
                    break
                elif [[ $status_code -ge 400 && $status_code -lt 500 ]]; then
                    status="ERROR ($status_code)"
                    suggestion="The page might be moved or deleted"
                    log_message "WARN" "Broken external link ($status_code): $link in file $file"
                    broken_external_links=$((broken_external_links+1))
                    break
                else
                    retry_count=$((retry_count+1))
                    if [ $retry_count -lt $MAX_EXTERNAL_RETRIES ]; then
                        log_message "DEBUG" "Retrying external link ($status_code): $link (attempt $retry_count of $MAX_EXTERNAL_RETRIES)"
                        sleep 2
                    else
                        status="ERROR ($status_code)"
                        suggestion="Server error or timeout"
                        log_message "WARN" "External link check failed after $MAX_EXTERNAL_RETRIES attempts: $link in file $file"
                        broken_external_links=$((broken_external_links+1))
                    fi
                fi
            done
        else
            status="SKIPPED"
            log_message "DEBUG" "Skipped external link check: $link"
        fi
    elif [[ "$link" == /* ]]; then
        # Absolute path within the repository
        link_type="Internal (absolute)"
        target="$DOCS_DIR$link"
        
        if [ -f "$target" ] || [ -d "$target" ]; then
            status="OK"
            log_message "DEBUG" "Internal link OK: $link"
        else
            status="ERROR (Not Found)"
            
            # Try to find a similar file
            potential_match=$(find "$DOCS_DIR" -type f -name "$(basename "$link")" -print -quit 2>/dev/null)
            if [ -n "$potential_match" ]; then
                rel_path=$(realpath --relative-to="$(dirname "$DOCS_DIR$link")" "$potential_match")
                suggestion="Try: $rel_path"
                
                if [ "$FIX_LINKS" = true ]; then
                    # Create a backup
                    cp "$file" "${file}.bak"
                    # Replace the link
                    escaped_link=$(echo "$link" | sed 's/[\/&]/\\&/g')
                    escaped_suggestion=$(echo "$rel_path" | sed 's/[\/&]/\\&/g')
                    sed -i "s/($escaped_link)/($escaped_suggestion)/g" "$file"
                    fixed_links=$((fixed_links+1))
                    suggestion="$suggestion (Fixed automatically)"
                fi
            else
                suggestion="Check if the file exists or the path is correct"
            fi
            
            log_message "ERROR" "Broken internal link: $link in file $file"
            broken_internal_links=$((broken_internal_links+1))
        fi
    else
        # Relative path
        link_type="Internal (relative)"
        target=$(realpath -m "$source_dir/$link")
        
        if [ -f "$target" ] || [ -d "$target" ]; then
            status="OK"
            log_message "DEBUG" "Internal link OK: $link"
        else
            status="ERROR (Not Found)"
            
            # Try to find a similar file in nearby directories
            potential_match=$(find "$(dirname "$target")" -maxdepth 2 -type f -name "$(basename "$link")" -print -quit 2>/dev/null)
            if [ -n "$potential_match" ]; then
                rel_path=$(realpath --relative-to="$source_dir" "$potential_match")
                suggestion="Try: $rel_path"
                
                if [ "$FIX_LINKS" = true ]; then
                    # Create a backup
                    cp "$file" "${file}.bak"
                    # Replace the link
                    escaped_link=$(echo "$link" | sed 's/[\/&]/\\&/g')
                    escaped_suggestion=$(echo "$rel_path" | sed 's/[\/&]/\\&/g')
                    sed -i "s/($escaped_link)/($escaped_suggestion)/g" "$file"
                    fixed_links=$((fixed_links+1))
                    suggestion="$suggestion (Fixed automatically)"
                fi
            else
                suggestion="Check if the file exists or the path is correct"
            fi
            
            log_message "ERROR" "Broken internal link: $link in file $file"
            broken_internal_links=$((broken_internal_links+1))
        fi
    fi
    
    # Add to report if there's an issue
    if [[ "$status" != "OK" && "$status" != "SKIPPED" ]]; then
        echo "| $file | $link_type | $link | $status | $suggestion |" >> "$REPORT_FILE"
    fi
    
    return 0
}

# Main function
main() {
    log_message "INFO" "Starting link validation in $DOCS_DIR"
    initialize_report
    
    # Find all Markdown files
    markdown_files=$(find "$DOCS_DIR" -name "*.md" -type f | sort)
    total_files=$(echo "$markdown_files" | wc -l)
    
    log_message "INFO" "Found $total_files Markdown files to check"
    
    # Process each file
    while IFS= read -r file; do
        rel_file=$(realpath --relative-to="$DOCS_DIR" "$file")
        log_message "INFO" "Checking links in $rel_file"
        
        # Extract and check links
        links=$(extract_links "$file")
        for link in $links; do
            check_link "$file" "$link"
        done
    done <<< "$markdown_files"
    
    # Update summary in the report
    sed -i "s/\*\*Total files scanned:\*\* \[Placeholder\]/\*\*Total files scanned:\*\* $total_files/g" "$REPORT_FILE"
    sed -i "s/\*\*Total links checked:\*\* \[Placeholder\]/\*\*Total links checked:\*\* $total_links/g" "$REPORT_FILE"
    sed -i "s/\*\*Broken internal links:\*\* \[Placeholder\]/\*\*Broken internal links:\*\* $broken_internal_links/g" "$REPORT_FILE"
    sed -i "s/\*\*Broken external links:\*\* \[Placeholder\]/\*\*Broken external links:\*\* $broken_external_links/g" "$REPORT_FILE"
    sed -i "s/\*\*Fixed links:\*\* \[Placeholder\]/\*\*Fixed links:\*\* $fixed_links/g" "$REPORT_FILE"
    
    # Generate summary
    total_broken=$((broken_internal_links + broken_external_links))
    echo "=====================================" > "$SUMMARY_FILE"
    echo "  THREE HORIZONS LINK VALIDATION SUMMARY  " >> "$SUMMARY_FILE"
    echo "=====================================" >> "$SUMMARY_FILE"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$SUMMARY_FILE"
    echo "Total files scanned: $total_files" >> "$SUMMARY_FILE"
    echo "Total links checked: $total_links" >> "$SUMMARY_FILE"
    echo "Total broken links: $total_broken" >> "$SUMMARY_FILE"
    echo "  - Broken internal links: $broken_internal_links" >> "$SUMMARY_FILE"
    echo "  - Broken external links: $broken_external_links" >> "$SUMMARY_FILE"
    echo "Fixed links: $fixed_links" >> "$SUMMARY_FILE"
    echo "=====================================" >> "$SUMMARY_FILE"
    
    # Output summary to console
    cat "$SUMMARY_FILE"
    
    if [ $total_broken -eq 0 ]; then
        log_message "INFO" "No broken links found. Documentation is in excellent shape!"
    else
        log_message "WARN" "Found $total_broken broken links. See detailed report at: $REPORT_FILE"
    fi
    
    # Update history file
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    history_entry="{\"date\":\"$timestamp\",\"total_files\":$total_files,\"total_links\":$total_links,\"broken_internal\":$broken_internal_links,\"broken_external\":$broken_external_links,\"fixed_links\":$fixed_links}"
    
    if [ -f "$HISTORY_FILE" ]; then
        # Update existing history
        tmp_history=$(mktemp)
        jq --argjson new_entry "$history_entry" '. + [$new_entry]' "$HISTORY_FILE" > "$tmp_history"
        mv "$tmp_history" "$HISTORY_FILE"
    else
        # Create new history file
        echo "[$history_entry]" > "$HISTORY_FILE"
    fi
    
    log_message "INFO" "Link validation complete. Reports saved to $OUTPUT_DIR"
    
    # Return exit code based on findings
    if [ $total_broken -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Run the main function
main

# Exit with status
exit $?
