#!/bin/bash
#
# Script Name: convert-images-to-svgs.sh
#
# Description: This script automates the process of identifying and converting all PNG images
#              in the documentation to SVG format, following the Three Horizons Platform standards.
#
# Usage: ./convert-images-to-svgs.sh [OPTIONS]
#
# Options:
#   -h, --help         Display this help message and exit
#   -d, --dry-run      Show what would be done without making changes
#   -f, --force        Force overwrite existing SVG files
#   -v, --verbose      Display detailed progress information
#
# Requirements:
#   - utilities/convert-images-to-svg.sh script
#   - utilities/svg-validation.js script
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
FORCE=false
VERBOSE=false

# Display script header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      Three Horizons Platform - Documentation SVG Converter  ${NC}"
echo -e "${BLUE}============================================================${NC}"

# Check if required scripts exist
if [ ! -f "scripts/utilities/convert-images-to-svg.sh" ]; then
    echo -e "${RED}Error: Required script 'scripts/utilities/convert-images-to-svg.sh' not found.${NC}"
    exit 1
fi

if [ ! -f "scripts/utilities/svg-validation.js" ]; then
    echo -e "${RED}Error: Required script 'scripts/utilities/svg-validation.js' not found.${NC}"
    exit 1
fi

# Function to display help message
display_help() {
    echo -e "\n${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo -e "\n${GREEN}Description:${NC}"
    echo "  This script automates the process of identifying and converting all PNG images"
    echo "  in the documentation to SVG format, following the Three Horizons Platform standards."
    echo -e "\n${GREEN}Options:${NC}"
    echo "  -h, --help         Display this help message and exit"
    echo "  -d, --dry-run      Show what would be done without making changes"
    echo "  -f, --force        Force overwrite existing SVG files"
    echo "  -v, --verbose      Display detailed progress information"
    echo -e "\n${GREEN}Requirements:${NC}"
    echo "  - utilities/convert-images-to-svg.sh script"
    echo "  - utilities/svg-validation.js script"
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
        -f|--force)
            FORCE=true
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
mkdir -p assets/icons
mkdir -p docs/reports

# Report file
REPORT_FILE="docs/reports/svg-conversion-report-$(date +"%Y%m%d-%H%M%S").md"

# Initialize report
echo "# SVG Conversion Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Converted Images" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Original Image | Converted SVG | Status |" >> "$REPORT_FILE"
echo "|---------------|--------------|--------|" >> "$REPORT_FILE"

# Step 1: Identify all PNG images in the documentation
echo -e "\n${BLUE}Step 1: Identifying PNG images in the documentation...${NC}"

PNG_FILES=$(find . -type f -name "*.png" | grep -v "node_modules" | grep -v ".git")
PNG_COUNT=$(echo "$PNG_FILES" | wc -l)

echo -e "${GREEN}Found ${PNG_COUNT} PNG files to process.${NC}"

if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Files to process:${NC}"
    echo "$PNG_FILES"
fi

# Step 2: Process each PNG file
echo -e "\n${BLUE}Step 2: Processing PNG files...${NC}"

CONVERTED_COUNT=0
FAILED_COUNT=0

for PNG_FILE in $PNG_FILES; do
    BASE_NAME=$(basename "$PNG_FILE" .png)
    DIR_NAME=$(dirname "$PNG_FILE")
    SVG_FILE="${DIR_NAME}/${BASE_NAME}.svg"
    
    echo -e "${BLUE}Processing: ${PNG_FILE}${NC}"
    
    # Check if SVG already exists and force flag is not set
    if [ -f "$SVG_FILE" ] && [ "$FORCE" = false ]; then
        echo -e "${YELLOW}SVG file already exists: ${SVG_FILE} (use --force to overwrite)${NC}"
        echo "| \`${PNG_FILE}\` | \`${SVG_FILE}\` | Already exists |" >> "$REPORT_FILE"
        continue
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}Dry run: Would convert ${PNG_FILE} to ${SVG_FILE}${NC}"
        echo "| \`${PNG_FILE}\` | \`${SVG_FILE}\` | Dry run |" >> "$REPORT_FILE"
    else
        # Convert PNG to SVG
        if ./scripts/utilities/convert-images-to-svg.sh -d "$(dirname "$PNG_FILE")" $([ "$FORCE" = true ] && echo "-f") $([ "$VERBOSE" = true ] && echo "-v"); then
            echo -e "${GREEN}Successfully converted: ${PNG_FILE} to ${SVG_FILE}${NC}"
            echo "| \`${PNG_FILE}\` | \`${SVG_FILE}\` | ✅ Converted |" >> "$REPORT_FILE"
            ((CONVERTED_COUNT++))
            
            # Validate the SVG
            if [ -f "$SVG_FILE" ]; then
                echo -e "${BLUE}Validating: ${SVG_FILE}${NC}"
                if node ./scripts/utilities/svg-validation.js --fix "$SVG_FILE" > /dev/null; then
                    echo -e "${GREEN}Validation successful for ${SVG_FILE}${NC}"
                else
                    echo -e "${YELLOW}Validation issues found in ${SVG_FILE} (auto-fixed where possible)${NC}"
                fi
            fi
        else
            echo -e "${RED}Failed to convert: ${PNG_FILE}${NC}"
            echo "| \`${PNG_FILE}\` | \`${SVG_FILE}\` | ❌ Failed |" >> "$REPORT_FILE"
            ((FAILED_COUNT++))
        fi
    fi
done

# Step 3: Update README and documentation references
echo -e "\n${BLUE}Step 3: Identifying documentation files that reference PNG images...${NC}"

MD_FILES=$(find . -type f -name "*.md" | grep -v "node_modules" | grep -v ".git")
MD_WITH_PNG=$(grep -l "\.png" $MD_FILES | sort -u)
MD_COUNT=$(echo "$MD_WITH_PNG" | wc -l)

echo -e "${GREEN}Found ${MD_COUNT} Markdown files with PNG references.${NC}"

# Add to report
echo "" >> "$REPORT_FILE"
echo "## Markdown Files with PNG References" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The following ${MD_COUNT} Markdown files contain references to PNG images:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for MD_FILE in $MD_WITH_PNG; do
    echo "- \`${MD_FILE}\`" >> "$REPORT_FILE"
    
    # Find all PNG references in this file
    PNG_REFS=$(grep -o "\!\[.*\].*\.png[)\"]" "$MD_FILE" || echo "")
    
    if [ -n "$PNG_REFS" ]; then
        echo "  - References:" >> "$REPORT_FILE"
        echo "$PNG_REFS" | while read -r REF; do
            echo "    - \`${REF}\`" >> "$REPORT_FILE"
        done
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}File: ${MD_FILE}${NC}"
        echo -e "${BLUE}PNG References:${NC}"
        echo "$PNG_REFS"
    fi
done

# Step 4: Create report of all SVGs in the repository
echo -e "\n${BLUE}Step 4: Creating inventory of all SVG files...${NC}"

SVG_FILES=$(find . -type f -name "*.svg" | grep -v "node_modules" | grep -v ".git" | sort)
SVG_COUNT=$(echo "$SVG_FILES" | wc -l)

echo -e "${GREEN}Found ${SVG_COUNT} SVG files in the repository.${NC}"

# Add to report
echo "" >> "$REPORT_FILE"
echo "## SVG Inventory" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The repository contains ${SVG_COUNT} SVG files:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| SVG File | Description |" >> "$REPORT_FILE"
echo "|----------|-------------|" >> "$REPORT_FILE"

for SVG_FILE in $SVG_FILES; do
    # Extract title from SVG if available
    SVG_TITLE=$(grep -o "<title>.*</title>" "$SVG_FILE" | sed -E 's/<title>(.*)<\/title>/\1/' || echo "No title")
    echo "| \`${SVG_FILE}\` | ${SVG_TITLE} |" >> "$REPORT_FILE"
done

# Step 5: Summary and recommendations
echo -e "\n${BLUE}Step 5: Generating summary and recommendations...${NC}"

# Add to report
echo "" >> "$REPORT_FILE"
echo "## Recommendations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Based on the analysis, here are the recommended next steps:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. **Update Documentation References**: Edit the Markdown files listed above to reference SVG versions instead of PNG." >> "$REPORT_FILE"
echo "2. **Review Converted SVGs**: Check the automatically converted SVGs for quality and optimize them where needed." >> "$REPORT_FILE"
echo "3. **Create Missing Diagrams**: Identify concepts that need visual representation and create new SVG diagrams." >> "$REPORT_FILE"
echo "4. **Standardize Styling**: Ensure all SVGs follow the Three Horizons Platform styling guidelines." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Tools" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Use the following tools to maintain SVG quality:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **SVG Creation**: `./scripts/utilities/create-diagram-template.sh`" >> "$REPORT_FILE"
echo "- **SVG Optimization**: `./scripts/utilities/convert-images-to-svg.sh -o`" >> "$REPORT_FILE"
echo "- **SVG Validation**: `./scripts/utilities/svg-validation.js`" >> "$REPORT_FILE"

# Final summary
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${BLUE}                       Summary                              ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}PNG files found:       ${PNG_COUNT}${NC}"
echo -e "${GREEN}PNG files converted:   ${CONVERTED_COUNT}${NC}"
echo -e "${GREEN}Conversion failures:   ${FAILED_COUNT}${NC}"
echo -e "${GREEN}Markdown files with PNG references: ${MD_COUNT}${NC}"
echo -e "${GREEN}Total SVG files in repository: ${SVG_COUNT}${NC}"
echo -e "${BLUE}============================================================${NC}"

echo -e "\n${GREEN}Report generated: ${REPORT_FILE}${NC}"
echo -e "\n${GREEN}Conversion process complete!${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Note: This was a dry run. No actual changes were made.${NC}"
fi

exit 0 