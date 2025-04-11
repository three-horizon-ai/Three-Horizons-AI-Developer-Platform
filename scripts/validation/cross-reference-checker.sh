#!/bin/bash
# Cross-reference validation script for Three Horizons documentation
# This script checks that all referenced files and directories actually exist

set -e

echo "Starting cross-reference validation..."

# Root directory of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Counter for issues
ISSUE_COUNT=0

# Function to check if a file exists
check_file_exists() {
  local file="$1"
  local source_file="$2"
  
  # Remove any anchors from the file path
  file_path="${file%%#*}"
  
  # Handle both absolute (within repo) and relative paths
  if [[ "$file_path" == /* ]]; then
    # Absolute path (from repo root)
    check_path="${REPO_ROOT}${file_path}"
  else
    # Relative path (from the directory containing the source file)
    source_dir=$(dirname "$source_file")
    check_path="${source_dir}/${file_path}"
  fi
  
  if [ ! -f "$check_path" ] && [ ! -d "$check_path" ]; then
    echo -e "${RED}ERROR:${NC} In file '${source_file}', reference to '${file_path}' does not exist"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
    return 1
  fi
  
  return 0
}

# Find all markdown files
echo "Finding all markdown files..."
MD_FILES=$(find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*")
echo "Found $(echo "$MD_FILES" | wc -l) markdown files"

# Regular expression to match relative links [text](path)
LINK_REGEX='\[.*\]\(([^:)]+)\)'

# Check each markdown file
for md_file in $MD_FILES; do
  echo -e "${YELLOW}Checking file:${NC} $md_file"
  
  # Extract all links using the regex
  links=$(grep -o "$LINK_REGEX" "$md_file" | sed -E 's/\[.*\]\(([^:)]+)\)/\1/g')
  
  if [ -z "$links" ]; then
    echo "  No links found"
    continue
  fi
  
  # Check each link
  for link in $links; do
    # Skip external links, anchors, and mailto links
    if [[ "$link" == http* ]] || [[ "$link" == "#"* ]] || [[ "$link" == "mailto:"* ]]; then
      continue
    fi
    
    # Check if the file exists
    if check_file_exists "$link" "$md_file"; then
      echo -e "  ${GREEN}✓${NC} $link"
    fi
  done
done

# Report summary
if [ $ISSUE_COUNT -eq 0 ]; then
  echo -e "\n${GREEN}Success:${NC} All checked references exist."
  exit 0
else
  echo -e "\n${RED}Error:${NC} Found $ISSUE_COUNT issues with references."
  exit 1
fi 