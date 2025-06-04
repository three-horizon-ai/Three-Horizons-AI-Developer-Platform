#!/bin/bash

# Script to convert ARM templates to Bicep
# Usage: ./arm-to-bicep.sh <arm-file.json>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if bicep is installed
if ! command -v bicep &> /dev/null; then
    echo -e "${RED}Error: Bicep is not installed${NC}"
    echo "Install with: az bicep install"
    exit 1
fi

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 <arm-file.json>${NC}"
    echo "Example: $0 template.json"
    exit 1
fi

ARM_FILE=$1

# Check if file exists
if [ ! -f "$ARM_FILE" ]; then
    echo -e "${RED}Error: File '$ARM_FILE' not found${NC}"
    exit 1
fi

# Get filename without extension
BASENAME=$(basename "$ARM_FILE" .json)
BICEP_FILE="${BASENAME}.bicep"

echo -e "${GREEN}Converting ARM to Bicep...${NC}"
echo "Source file: $ARM_FILE"
echo "Target file: $BICEP_FILE"

# Convert using Azure CLI
az bicep decompile --file "$ARM_FILE"

# Check if conversion was successful
if [ -f "$BICEP_FILE" ]; then
    echo -e "${GREEN}✓ Conversion completed successfully!${NC}"
    echo ""
    echo "Recommended next steps:"
    echo "1. Review the file $BICEP_FILE"
    echo "2. Add descriptions to parameters with @description()"
    echo "3. Simplify complex expressions"
    echo "4. Add appropriate tags and metadata"
    echo "5. Validate with: az bicep build --file $BICEP_FILE"
    echo ""
    
    # Show warnings if any
    if grep -q "WARNING" "$BICEP_FILE"; then
        echo -e "${YELLOW}⚠ Warning: Warnings found in the converted file${NC}"
        echo "Check the comments in the file for more details."
    fi
else
    echo -e "${RED}✗ Conversion error${NC}"
    exit 1
fi

# Ask if user wants to validate
read -p "Do you want to validate the Bicep file now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Validating Bicep file...${NC}"
    az bicep build --file "$BICEP_FILE"
fi 