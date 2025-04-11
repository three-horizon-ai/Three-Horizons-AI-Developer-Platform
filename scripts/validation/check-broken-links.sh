#!/bin/bash

# Script to check for broken links in Markdown files
echo "Checking for broken links in Markdown files..."

# Directory containing Markdown files
DOCS_DIR="/Users/paulasilva/Documents/GH Repositories/Three-Horizons-Playbook"

# Find all Markdown files
MARKDOWN_FILES=$(find "$DOCS_DIR" -name "*.md")

# Counter for broken links
BROKEN_LINKS=0

# Function to extract links from a Markdown file
extract_links() {
    local file="$1"
    # Extract links [text](url)
    grep -o -E '\[.*?\]\([^)]+\)' "$file" | sed 's/.*(\(.*\))/\1/'
}

# Check if a file exists
check_link() {
    local file="$1"
    local link="$2"
    local source_dir=$(dirname "$file")
    
    # Handle different types of links
    if [[ "$link" =~ ^http[s]?:// ]]; then
        # External URL - skip checking
        echo "SKIPPED: External link $link in $file"
        return 0
    elif [[ "$link" == /* ]]; then
        # Absolute path within the repository
        target="$DOCS_DIR$link"
    else
        # Relative path
        target=$(realpath -m "$source_dir/$link")
    fi
    
    # Check if file exists
    if [ ! -f "$target" ] && [ ! -d "$target" ]; then
        echo "BROKEN: $link in $file -> $target does not exist"
        return 1
    fi
    
    return 0
}

# Main loop
for file in $MARKDOWN_FILES; do
    echo "Checking file: $file"
    links=$(extract_links "$file")
    
    for link in $links; do
        if ! check_link "$file" "$link"; then
            BROKEN_LINKS=$((BROKEN_LINKS+1))
        fi
    done
done

echo "Check completed. Found $BROKEN_LINKS broken links."

if [ $BROKEN_LINKS -gt 0 ]; then
    exit 1
else
    exit 0
fi
