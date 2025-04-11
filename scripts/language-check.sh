#!/bin/bash

# language-check.sh
# Script to check for non-English content in the repository
# Helps maintain the English-only language policy

echo "Three Horizons Platform - Language Consistency Check"
echo "==================================================="
echo "Checking repository for potentially non-English content..."
echo

# Directories to exclude from checks
EXCLUDE_DIRS="node_modules|\.git|\.github\/workflows|\.local-scripts|\.temp_files"

# File extensions to check
MD_FILES="md|markdown"
CODE_FILES="js|ts|jsx|tsx|py|java|sh|bash|cs|go|rb|php|html|css|scss|json|yml|yaml"
DOC_FILES="txt|rst|adoc"

# Check Markdown files for non-English content
echo "Checking Markdown documentation files..."
find . -type f -regextype posix-extended -regex ".*\.($MD_FILES)$" | grep -v -E "($EXCLUDE_DIRS)" | xargs grep -l "[áàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ]" 2>/dev/null

# Check code files for non-English comments or strings
echo -e "\nChecking code files for non-English comments or strings..."
find . -type f -regextype posix-extended -regex ".*\.($CODE_FILES)$" | grep -v -E "($EXCLUDE_DIRS)" | xargs grep -l "[áàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ]" 2>/dev/null

# Check other documentation files
echo -e "\nChecking other documentation files..."
find . -type f -regextype posix-extended -regex ".*\.($DOC_FILES)$" | grep -v -E "($EXCLUDE_DIRS)" | xargs grep -l "[áàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ]" 2>/dev/null

echo -e "\nLanguage check completed. Please review any listed files for non-English content."
echo "Refer to docs/LANGUAGE_GUIDELINES.md for guidance on maintaining English-language consistency."
echo

exit 0 