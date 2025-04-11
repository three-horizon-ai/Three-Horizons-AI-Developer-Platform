#!/usr/bin/env python3
"""
Link Checker Script for Three-Horizons-Playbook

This script scans all markdown files in the repository for links and validates:
1. Internal file links (relative paths within the repo)
2. Links to headers within the same document
3. Anchor links to sections in other documents

Usage:
    python check-broken-links.py
"""

import os
import re
import sys
from pathlib import Path
from collections import defaultdict

# Repository root is the parent directory of the scripts/validation directory
REPO_ROOT = Path(__file__).resolve().parent.parent.parent

# Regular expression to find markdown links
# Captures both [text](link) and [text][reference] + [reference]: link formats
LINK_PATTERN = re.compile(r'\[([^\]]+)\]\(([^)]+)\)|\[([^\]]+)\]\[([^\]]+)\]')
REFERENCE_PATTERN = re.compile(r'\[([^\]]+)\]:\s+([^\s]+)')

def find_markdown_files():
    """Find all markdown files in the repository."""
    markdown_files = []
    for root, _, files in os.walk(REPO_ROOT):
        for file in files:
            if file.endswith(".md"):
                markdown_files.append(os.path.join(root, file))
    return markdown_files

def extract_links(file_path):
    """Extract all links from a markdown file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    links = []
    # Find standard links [text](link)
    for match in LINK_PATTERN.finditer(content):
        if match.group(2):  # [text](link) format
            links.append(match.group(2))
        # For reference links, we don't process them here
    
    # Find reference definitions [ref]: link
    references = {}
    for match in REFERENCE_PATTERN.finditer(content):
        references[match.group(1)] = match.group(2)
    
    # Find reference usages and add their actual links
    for match in LINK_PATTERN.finditer(content):
        if match.group(4):  # [text][reference] format
            ref = match.group(4)
            if ref in references:
                links.append(references[ref])
    
    return links

def is_internal_link(link):
    """Check if a link is internal to the repository."""
    return not (link.startswith('http://') or link.startswith('https://') or 
                link.startswith('ftp://') or link.startswith('mailto:'))

def resolve_relative_path(base_path, link_path):
    """Resolve a relative path from the base path."""
    # Handle anchor links to the same document
    if link_path.startswith('#'):
        return base_path
    
    # Split the link to separate the anchor
    path_part = link_path.split('#')[0]
    
    # If the path is empty (happens with just anchor links)
    if not path_part:
        return base_path
    
    # Get the directory of the base file
    base_dir = os.path.dirname(base_path)
    
    # Resolve the path
    resolved_path = os.path.normpath(os.path.join(base_dir, path_part))
    return resolved_path

def check_broken_links():
    """Check for broken links in all markdown files."""
    markdown_files = find_markdown_files()
    broken_links = defaultdict(list)
    
    print(f"Scanning {len(markdown_files)} markdown files for broken links...")
    
    for file_path in markdown_files:
        # Get the file path relative to the repository root
        rel_file_path = os.path.relpath(file_path, REPO_ROOT)
        links = extract_links(file_path)
        
        for link in links:
            # Skip external links and anchor links to the same file
            if not is_internal_link(link) or link.startswith('#'):
                continue
            
            # If the link has an anchor, check only the path part
            path_part = link.split('#')[0]
            
            # If the path part is empty, it's a link to the same file, skip
            if not path_part:
                continue
            
            # Resolve the link path relative to the current file
            resolved_path = resolve_relative_path(file_path, path_part)
            rel_resolved_path = os.path.relpath(resolved_path, REPO_ROOT)
            
            # Check if the link target exists
            if not os.path.exists(resolved_path):
                broken_links[rel_file_path].append((link, rel_resolved_path))
    
    return broken_links

def main():
    """Main function to run the link checker."""
    print("Three Horizons Playbook - Markdown Link Checker")
    print("==============================================\n")
    
    broken_links = check_broken_links()
    
    if not broken_links:
        print("\n✅ No broken internal links found!")
        return 0
    
    print("\n❌ Broken links found:\n")
    
    total_broken = 0
    for file, links in broken_links.items():
        print(f"In file: {file}")
        for link, resolved in links:
            print(f"  - Link: {link}")
            print(f"    Resolves to: {resolved} (not found)")
            total_broken += 1
        print()
    
    print(f"Total broken links: {total_broken}")
    return 1

if __name__ == "__main__":
    sys.exit(main()) 