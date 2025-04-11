#!/bin/bash
#
# Script Name: check-links.sh
#
# Description: This script verifies and fixes outdated documentation links,
#              especially references to the old "docs/documentation" structure
#              that has been reorganized. It identifies and reports all Markdown
#              files with potentially broken links.
#
# Usage: ./check-links.sh [OPTIONS]
#
# Options:
#   -h, --help         Display this help message and exit
#   -d, --dry-run      Show what would be done without making actual changes
#   -f, --fix          Automatically fix identified issues (use with caution)
#   -v, --verbose      Display more detailed information
#

# Set strict mode
set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=true
FIX=false
VERBOSE=false

# Display script header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}     Three Horizons Platform - Documentation Link Checker    ${NC}"
echo -e "${BLUE}============================================================${NC}"

# Function to display help message
display_help() {
    echo -e "\n${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo -e "\n${GREEN}Description:${NC}"
    echo "  This script verifies and fixes outdated documentation links,"
    echo "  especially references to the old 'docs/documentation' structure"
    echo "  that has been reorganized. It identifies and reports all Markdown"
    echo "  files with potentially broken links."
    echo -e "\n${GREEN}Options:${NC}"
    echo "  -h, --help         Display this help message and exit"
    echo "  -d, --dry-run      Show what would be done without making actual changes (default)"
    echo "  -f, --fix          Automatically fix identified issues (use with caution)"
    echo "  -v, --verbose      Display more detailed information"
    echo ""
    exit 0
}

# Function to perform a sed replacement that works on both Linux and macOS
# Usage: safe_sed "pattern" "replacement" file
safe_sed() {
    local pattern="$1"
    local replacement="$2"
    local file="$3"
    
    # Check if we're on macOS (BSD sed) or Linux (GNU sed)
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS version
        sed -i '' "s|${pattern}|${replacement}|g" "$file"
    else
        # Linux version
        sed -i "s|${pattern}|${replacement}|g" "$file"
    fi
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift # past argument
            ;;
        -f|--fix)
            FIX=true
            DRY_RUN=false
            shift # past argument
            ;;
        -v|--verbose)
            VERBOSE=true
            shift # past argument
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# Create necessary directories
mkdir -p docs/reports

# Report file
REPORT_FILE="docs/reports/link-check-report-$(date +"%Y%m%d-%H%M%S").md"

# Initialize report
echo "# Documentation Link Verification Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Find all Markdown files
echo -e "\n${BLUE}Searching for Markdown files...${NC}"
MD_FILES=$(find . -type f -name "*.md" | grep -v "node_modules" | grep -v ".git" | sort)
MD_COUNT=$(echo "$MD_FILES" | wc -l)
echo -e "${GREEN}Found ${MD_COUNT} Markdown files to check.${NC}"

# Initialize counters
TOTAL_ISSUES=0
TOTAL_FIXED=0
TOTAL_FILES_WITH_ISSUES=0

# Check for references to old documentation paths
echo -e "\n${BLUE}Checking for references to old documentation paths...${NC}"
echo "## References to Old Documentation Paths" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| File | Line | Content | Suggested Fix |" >> "$REPORT_FILE"
echo "|------|------|---------|---------------|" >> "$REPORT_FILE"

# Define patterns and their replacements as separate arrays (more compatible with older Bash versions)
PATTERNS=(
    "docs/documentation/architecture"
    "docs/documentation/guides"
    "docs/documentation/developer"
    "docs/documentation/operations"
    "docs/documentation/reference"
    "docs/documentation/appendices"
    "docs/documentation/implementation"
    "docs/architecture"
    "docs/implementation-guide"
    "docs/developer-guide"
    "docs/operations-guide"
    "docs/reference"
    "docs/appendices"
)

REPLACEMENTS=(
    "docs/1-architecture"
    "docs/2-implementation-guide"
    "docs/3-developer-guide"
    "docs/4-operations-guide"
    "docs/5-reference"
    "docs/6-appendices"
    "docs/2-implementation-guide"
    "docs/1-architecture"
    "docs/2-implementation-guide"
    "docs/3-developer-guide"
    "docs/4-operations-guide"
    "docs/5-reference"
    "docs/6-appendices"
)

for MD_FILE in $MD_FILES; do
    FILE_ISSUES=0
    FILE_FIXES=0
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Checking ${MD_FILE} for old doc paths...${NC}"
    fi
    
    # Check for each pattern
    for i in "${!PATTERNS[@]}"; do
        PATTERN="${PATTERNS[$i]}"
        REPLACEMENT="${REPLACEMENTS[$i]}"
        
        # Find lines containing the pattern
        MATCHES=$(grep -n "$PATTERN" "$MD_FILE" 2>/dev/null || true)
        
        if [ -n "$MATCHES" ]; then
            while IFS= read -r LINE; do
                if [ -z "$LINE" ]; then
                    continue
                fi
                
                LINE_NUM=$(echo "$LINE" | cut -d':' -f1)
                LINE_CONTENT=$(echo "$LINE" | cut -d':' -f2-)
                
                # Add to report
                echo "| \`$MD_FILE\` | $LINE_NUM | \`${LINE_CONTENT}\` | Replace \`$PATTERN\` with \`$REPLACEMENT\` |" >> "$REPORT_FILE"
                
                # Increment counters
                ((FILE_ISSUES++))
                ((TOTAL_ISSUES++))
                
                # Fix if requested
                if [ "$FIX" = true ]; then
                    if [ "$VERBOSE" = true ]; then
                        echo -e "${YELLOW}Fixing in ${MD_FILE}:${LINE_NUM} - Replacing ${PATTERN} with ${REPLACEMENT}${NC}"
                    fi
                    
                    # Create a backup if it doesn't exist
                    if [ ! -f "${MD_FILE}.bak" ]; then
                        cp "$MD_FILE" "${MD_FILE}.bak"
                    fi
                    
                    # Replace the pattern using the safe sed function
                    safe_sed "$PATTERN" "$REPLACEMENT" "$MD_FILE"
                    
                    ((FILE_FIXES++))
                    ((TOTAL_FIXED++))
                fi
            done <<< "$MATCHES"
        fi
    done
    
    # Report file summary for this check
    if [ "$FILE_ISSUES" -gt 0 ]; then
        ((TOTAL_FILES_WITH_ISSUES++))
        
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}Found ${FILE_ISSUES} old path issues in ${MD_FILE}${NC}"
            if [ "$FILE_FIXES" -gt 0 ]; then
                echo -e "${GREEN}Fixed ${FILE_FIXES} path issues${NC}"
            fi
        fi
    elif [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}No old path issues found in ${MD_FILE}${NC}"
    fi
done

# Check for empty or undefined links
echo -e "\n${BLUE}Checking for empty or undefined links...${NC}"
echo "" >> "$REPORT_FILE"
echo "## Empty or Undefined Links" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| File | Line | Content |" >> "$REPORT_FILE"
echo "|------|------|---------|" >> "$REPORT_FILE"

for MD_FILE in $MD_FILES; do
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Checking ${MD_FILE} for empty links...${NC}"
    fi
    
    # Find empty links
    EMPTY_LINKS=$(grep -n -E "\[\]?\(\)|\[\]?\(#undefined\)" "$MD_FILE" 2>/dev/null || true)
    
    if [ -n "$EMPTY_LINKS" ]; then
        while IFS= read -r LINE; do
            LINE_NUM=$(echo "$LINE" | cut -d':' -f1)
            LINE_CONTENT=$(echo "$LINE" | cut -d':' -f2-)
            
            echo "| \`$MD_FILE\` | $LINE_NUM | \`${LINE_CONTENT}\` |" >> "$REPORT_FILE"
            ((TOTAL_ISSUES++))
        done <<< "$EMPTY_LINKS"
    fi
done

# Check for Mermaid diagrams
echo -e "\n${BLUE}Checking for Mermaid diagrams to convert to SVG...${NC}"
echo "" >> "$REPORT_FILE"
echo "## Mermaid Diagrams to Convert" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The following files contain Mermaid diagrams that should be converted to SVG:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Handle mermaid files more carefully to avoid syntax errors
MERMAID_FILES=$(find . -type f -name "*.md" -exec grep -l '```mermaid' {} \; 2>/dev/null || echo "")
MERMAID_COUNT=0
if [ -n "$MERMAID_FILES" ]; then
    MERMAID_COUNT=$(echo "$MERMAID_FILES" | wc -l)
fi

if [ -n "$MERMAID_FILES" ]; then
    for MERMAID_FILE in $MERMAID_FILES; do
        if [ -z "$MERMAID_FILE" ] || [ ! -f "$MERMAID_FILE" ]; then
            continue
        fi
        
        echo "- \`${MERMAID_FILE}\`" >> "$REPORT_FILE"
        
        # Count diagrams in the file
        DIAGRAM_COUNT=$(grep -c '```mermaid' "$MERMAID_FILE" 2>/dev/null || echo "0")
        echo "  - Contains ${DIAGRAM_COUNT} Mermaid diagrams" >> "$REPORT_FILE"
        
        # Safely add to total issues
        if [ "$DIAGRAM_COUNT" -gt 0 ]; then
            TOTAL_ISSUES=$((TOTAL_ISSUES + DIAGRAM_COUNT))
        fi
    done
else
    echo "No Mermaid diagrams found." >> "$REPORT_FILE"
fi

# Check for suspicious external links
echo -e "\n${BLUE}Checking for suspicious external links...${NC}"
echo "" >> "$REPORT_FILE"
echo "## Suspicious External Links" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The following links might need verification:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| File | Line | Content |" >> "$REPORT_FILE"
echo "|------|------|---------|" >> "$REPORT_FILE"

for MD_FILE in $MD_FILES; do
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Checking ${MD_FILE} for suspicious links...${NC}"
    fi
    
    # Find potentially broken external links
    SUSPICIOUS_LINKS=$(grep -n -E "https?://\)" "$MD_FILE" 2>/dev/null || true)
    
    if [ -n "$SUSPICIOUS_LINKS" ]; then
        while IFS= read -r LINE; do
            LINE_NUM=$(echo "$LINE" | cut -d':' -f1)
            LINE_CONTENT=$(echo "$LINE" | cut -d':' -f2-)
            
            echo "| \`$MD_FILE\` | $LINE_NUM | \`${LINE_CONTENT}\` |" >> "$REPORT_FILE"
            ((TOTAL_ISSUES++))
        done <<< "$SUSPICIOUS_LINKS"
    fi
done

# Generate summary for report
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **Total Markdown Files**: ${MD_COUNT}" >> "$REPORT_FILE"
echo "- **Files with Issues**: ${TOTAL_FILES_WITH_ISSUES}" >> "$REPORT_FILE"
echo "- **Total Issues Found**: ${TOTAL_ISSUES}" >> "$REPORT_FILE"
if [ "$FIX" = true ]; then
    echo "- **Issues Fixed**: ${TOTAL_FIXED}" >> "$REPORT_FILE"
fi
echo "- **Files with Mermaid Diagrams**: ${MERMAID_COUNT}" >> "$REPORT_FILE"

# Add recommendations to report
echo "" >> "$REPORT_FILE"
echo "## Recommendations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. **Fix Documentation Links**: Update all links to use the new documentation structure." >> "$REPORT_FILE"
echo "2. **Convert Mermaid Diagrams**: Use the `scripts/utilities/create-diagram-template.sh` script to create SVG templates for each diagram, then manually convert the Mermaid syntax to SVG." >> "$REPORT_FILE"
echo "3. **Fix Empty Links**: Review and update empty or undefined links with proper destinations." >> "$REPORT_FILE"
echo "4. **Review External Links**: Verify that all external links are correct and accessible." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Tools" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **Link Checker**: Re-run this script with the `-f` flag to automatically fix path issues." >> "$REPORT_FILE"
echo "- **SVG Creator**: Use `./scripts/utilities/create-diagram-template.sh` to create SVG templates." >> "$REPORT_FILE"
echo "- **SVG Validator**: Use `./scripts/utilities/svg-validation.js` to validate SVG files." >> "$REPORT_FILE"

# Final summary
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${BLUE}                       Summary                              ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}Markdown files checked:       ${MD_COUNT}${NC}"
echo -e "${GREEN}Files with issues:            ${TOTAL_FILES_WITH_ISSUES}${NC}"
echo -e "${GREEN}Total issues found:           ${TOTAL_ISSUES}${NC}"
if [ "$FIX" = true ]; then
    echo -e "${GREEN}Issues fixed:                 ${TOTAL_FIXED}${NC}"
fi
echo -e "${GREEN}Files with Mermaid diagrams:  ${MERMAID_COUNT}${NC}"
echo -e "${BLUE}============================================================${NC}"

echo -e "\n${GREEN}Report generated: ${REPORT_FILE}${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Note: This was a dry run. No changes were made. Use the --fix flag to apply changes.${NC}"
elif [ "$FIX" = true ]; then
    echo -e "${GREEN}Fixed ${TOTAL_FIXED} issues across the documentation.${NC}"
    echo -e "${YELLOW}Manual review is still required for:${NC}"
    echo -e "  - Mermaid diagrams conversion to SVG"
    echo -e "  - Empty or undefined links"
    echo -e "  - External links verification"
fi

exit 0 