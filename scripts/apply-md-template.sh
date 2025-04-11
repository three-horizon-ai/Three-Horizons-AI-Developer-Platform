#!/bin/bash
#
# Script Name: apply-md-template.sh
#
# Description: This script applies a standardized template to Markdown files in the docs directory.
#              It adds colored headings with emojis, consistent styling, and formatted sections.
#
# Usage: ./scripts/apply-md-template.sh [OPTIONS]
#
# Options:
#   -h, --help         Display this help message and exit
#   -d, --dry-run      Show what would be done without making actual changes
#   -p, --path         Specify a specific path to process (default: ./docs)
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
DRY_RUN=false
VERBOSE=false
TARGET_PATH="./docs"

# Display script header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}     Three Horizons Platform - Markdown Template Formatter   ${NC}"
echo -e "${BLUE}============================================================${NC}"

# Function to display help message
display_help() {
    echo -e "\n${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo -e "\n${GREEN}Description:${NC}"
    echo "  This script applies a standardized template to Markdown files"
    echo "  in the docs directory. It adds colored headings with emojis,"
    echo "  consistent styling, and formatted sections."
    echo -e "\n${GREEN}Options:${NC}"
    echo "  -h, --help         Display this help message and exit"
    echo "  -d, --dry-run      Show what would be done without making actual changes"
    echo "  -p, --path PATH    Specify a specific path to process (default: ./docs)"
    echo "  -v, --verbose      Display more detailed information"
    echo ""
    exit 0
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
        -p|--path)
            TARGET_PATH="$2"
            shift # past argument
            shift # past value
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

echo -e "\n${BLUE}=== Script Configuration ===${NC}"
echo -e "Target Path: ${TARGET_PATH}"
echo -e "Dry Run: ${DRY_RUN}"
echo -e "Verbose: ${VERBOSE}"

# Create necessary directories for backup
BACKUP_DIR="./docs/backup/original-md-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "Backup Directory: ${BACKUP_DIR}"

# Function to add emoji to heading based on content
add_emoji() {
    local heading="$1"
    local emoji=""
    
    # Convert to lowercase for comparison
    local heading_lower=$(echo "$heading" | tr '[:upper:]' '[:lower:]')
    
    # Assign emoji based on heading content
    if [[ "$heading_lower" == *"overview"* ]]; then
        emoji="🔍"
    elif [[ "$heading_lower" == *"architecture"* || "$heading_lower" == *"structure"* ]]; then
        emoji="🏗️"
    elif [[ "$heading_lower" == *"component"* ]]; then
        emoji="⚙️"
    elif [[ "$heading_lower" == *"security"* || "$heading_lower" == *"protect"* ]]; then
        emoji="🛡️"
    elif [[ "$heading_lower" == *"feature"* || "$heading_lower" == *"advantage"* || "$heading_lower" == *"benefit"* ]]; then
        emoji="✨"
    elif [[ "$heading_lower" == *"implement"* || "$heading_lower" == *"deploy"* || "$heading_lower" == *"install"* ]]; then
        emoji="🚀"
    elif [[ "$heading_lower" == *"troubleshoot"* || "$heading_lower" == *"issue"* || "$heading_lower" == *"problem"* ]]; then
        emoji="🔧"
    elif [[ "$heading_lower" == *"guide"* || "$heading_lower" == *"tutorial"* || "$heading_lower" == *"how"* ]]; then
        emoji="📘"
    elif [[ "$heading_lower" == *"reference"* || "$heading_lower" == *"resource"* ]]; then
        emoji="📚"
    elif [[ "$heading_lower" == *"appendix"* || "$heading_lower" == *"appendice"* ]]; then
        emoji="📋"
    elif [[ "$heading_lower" == *"integration"* || "$heading_lower" == *"connect"* ]]; then
        emoji="🔄"
    elif [[ "$heading_lower" == *"performance"* || "$heading_lower" == *"optimization"* ]]; then
        emoji="⚡"
    elif [[ "$heading_lower" == *"monitor"* || "$heading_lower" == *"observability"* ]]; then
        emoji="📊"
    elif [[ "$heading_lower" == *"workflow"* || "$heading_lower" == *"pipeline"* || "$heading_lower" == *"process"* ]]; then
        emoji="🔄"
    elif [[ "$heading_lower" == *"next"* || "$heading_lower" == *"future"* ]]; then
        emoji="🚀"
    else
        emoji="🔹"
    fi
    
    echo "$emoji"
}

# Check if target path exists
echo -e "\n${BLUE}=== Target Path Check ===${NC}"
if [ ! -d "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Target path ${TARGET_PATH} does not exist!${NC}"
    exit 1
fi

echo -e "Target path exists: ${TARGET_PATH}"
echo -e "Target path contents:"
ls -la "$TARGET_PATH"

# Find all markdown files in the target path, excluding README.md and node_modules
echo -e "\n${BLUE}=== Searching for Markdown Files ===${NC}"
echo -e "Running find command: find \"$TARGET_PATH\" -type f -name \"*.md\" | grep -v \"README.md\" | grep -v \"node_modules\" | grep -v \"/reports/\" | grep -v \"/backup/\" | sort"

MD_FILES=$(find "$TARGET_PATH" -type f -name "*.md" | grep -v "README.md" | grep -v "node_modules" | grep -v "/reports/" | grep -v "/backup/" | sort)

# Create a simple array for processing
MD_FILES_ARRAY=()
while IFS= read -r line; do
    [ -n "$line" ] && MD_FILES_ARRAY+=("$line")
done <<< "$MD_FILES"

MD_COUNT=${#MD_FILES_ARRAY[@]}
echo -e "${GREEN}Found ${MD_COUNT} Markdown files to process.${NC}"

# Show all found files
echo -e "Files found:"
for file in "${MD_FILES_ARRAY[@]}"; do
    echo "  - $file"
done

# Initialize counters
TOTAL_PROCESSED=0
TOTAL_SKIPPED=0

# Simple test file for debugging
echo -e "\n${BLUE}=== Creating Test File ===${NC}"
TEST_FILE="${TARGET_PATH}/test-template.md"
echo "# Test Heading for Template" > "$TEST_FILE"
echo "## Second Level Test Heading" >> "$TEST_FILE"
echo "### Third Level Test Heading" >> "$TEST_FILE"
echo "Some regular content paragraph." >> "$TEST_FILE"
echo "" >> "$TEST_FILE"
echo "Another paragraph with **bold** and *italic* text." >> "$TEST_FILE"

echo -e "Created test file: $TEST_FILE"
echo -e "Test file contents:"
cat "$TEST_FILE"

# Add test file to the array
MD_FILES_ARRAY+=("$TEST_FILE")
MD_COUNT=${#MD_FILES_ARRAY[@]}

# Process files
echo -e "\n${BLUE}=== Processing Markdown Files ===${NC}"

for file in "${MD_FILES_ARRAY[@]}"; do
    echo -e "\n${YELLOW}Processing: $file${NC}"
    
    # Skip if file doesn't exist or is empty
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo -e "  Skipping: file doesn't exist or is empty"
        continue
    fi
    
    # Skip processing if the file already has the new template
    if grep -q "<span style=\"color: #0366d6;" "$file" 2>/dev/null; then
        echo -e "  Skipping: already has the template applied"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    # Create a backup of the original file
    RELATIVE_PATH=${file#./}
    BACKUP_PATH="$BACKUP_DIR/$RELATIVE_PATH"
    mkdir -p "$(dirname "$BACKUP_PATH")"
    cp "$file" "$BACKUP_PATH"
    echo -e "  Backup created: $BACKUP_PATH"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  Would process (dry run mode)"
        continue
    fi
    
    # Process content directly
    echo -e "  Processing content"
    TEMP_FILE=$(mktemp)
    
    # Show content of the file
    echo -e "  Original file content:"
    cat "$file"
    
    # Check for front matter
    if grep -q "^---$" "$file"; then
        echo -e "  File has front matter"
        # Skip front matter for now
        awk 'BEGIN{f=0} /^---$/{f++; if(f==2){next}} f>=2{print}' "$file" > "${TEMP_FILE}.content"
    else
        echo -e "  File does not have front matter"
        # No front matter
        cat "$file" > "${TEMP_FILE}.content"
    fi
    
    echo -e "  Content extracted ($(wc -l < "${TEMP_FILE}.content" | tr -d ' ') lines)"
    
    # Process each line
    echo -e "  Transforming headings"
    while IFS= read -r line; do
        # Process level 1 headings
        if [[ "$line" =~ ^#\ (.+)$ ]]; then
            HEADING="${BASH_REMATCH[1]}"
            EMOJI=$(add_emoji "$HEADING")
            echo -e "    H1: '$HEADING' -> emoji: $EMOJI"
            echo "# <span style=\"color: #0366d6;\">${EMOJI} ${HEADING}</span>" >> "$TEMP_FILE"
        # Process level 2 headings
        elif [[ "$line" =~ ^##\ (.+)$ ]]; then
            HEADING="${BASH_REMATCH[1]}"
            EMOJI=$(add_emoji "$HEADING")
            echo -e "    H2: '$HEADING' -> emoji: $EMOJI"
            echo "## <span style=\"color: #0366d6;\">${EMOJI} ${HEADING}</span>" >> "$TEMP_FILE"
        # Process level 3 headings
        elif [[ "$line" =~ ^###\ (.+)$ ]]; then
            HEADING="${BASH_REMATCH[1]}"
            EMOJI=$(add_emoji "$HEADING")
            echo -e "    H3: '$HEADING' -> emoji: $EMOJI"
            echo "### <span style=\"color: #0366d6;\">${HEADING}</span>" >> "$TEMP_FILE"
        # Leave other lines unchanged
        else
            echo "$line" >> "$TEMP_FILE"
        fi
    done < "${TEMP_FILE}.content"
    
    # Remove temporary content file
    rm "${TEMP_FILE}.content"
    
    # Add footer if not already present
    if ! grep -q "<footer>" "$TEMP_FILE" 2>/dev/null; then
        echo -e "  Adding footer"
        echo "" >> "$TEMP_FILE"
        echo "---" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "<footer>" >> "$TEMP_FILE"
        echo "  <p align=\"center\">🔄 Last updated: $(date +"%B %Y") | Contribute to this document through <a href=\"../../.github/CONTRIBUTING.md\">Pull Requests</a></p>" >> "$TEMP_FILE"
        echo "</footer>" >> "$TEMP_FILE"
    fi
    
    echo -e "  Processed content size: $(wc -l < "$TEMP_FILE" | tr -d ' ') lines"
    echo -e "  Processed content:"
    cat "$TEMP_FILE"
    
    # Replace the original file with the processed file
    echo -e "  Replacing original file with processed version"
    mv "$TEMP_FILE" "$file"
    
    echo -e "${GREEN}  Successfully applied template${NC}"
    ((TOTAL_PROCESSED++))
    
    # Show processed file
    echo -e "  Final file after processing:"
    cat "$file"
done

# Final summary
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${BLUE}                       Summary                              ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}Markdown files found:         ${MD_COUNT}${NC}"
echo -e "${GREEN}Files processed:              ${TOTAL_PROCESSED}${NC}"
echo -e "${GREEN}Files skipped:                ${TOTAL_SKIPPED}${NC}"
echo -e "${BLUE}============================================================${NC}"

echo -e "\n${GREEN}Original files backed up to: ${BACKUP_DIR}${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Note: This was a dry run. No changes were made.${NC}"
else
    echo -e "${GREEN}Template applied successfully to ${TOTAL_PROCESSED} files.${NC}"
fi

exit 0 