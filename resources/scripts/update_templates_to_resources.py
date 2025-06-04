#!/usr/bin/env python3
"""
Script to update all references from templates/ to resources/
"""
import re
import glob
import os


def update_links_in_file(filepath):
    """Update links in a single file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Update all references from templates to resources
    patterns = [
        (r'templates/', 'resources/'),
        (r'/templates/', '/resources/'),
        (r'\.\.\/templates\/', '../resources/'),
        (r'\.\.\/\.\.\/templates\/', '../../resources/'),
        (r'"templates\/', '"resources/'),
        (r'\[templates\/', '[resources/'),
    ]
    
    for old_pattern, new_pattern in patterns:
        content = re.sub(old_pattern, new_pattern, content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")
        return True
    return False


def main():
    """Main function to update all files"""
    updated_count = 0
    
    # Find all markdown and yaml files
    file_patterns = ['**/*.md', '**/*.yaml', '**/*.yml']
    all_files = []
    
    for pattern in file_patterns:
        all_files.extend(glob.glob(pattern, recursive=True))
    
    # Also update README at root
    if os.path.exists('README.md'):
        all_files.append('README.md')
    
    for filepath in all_files:
        # Skip files in .git directory
        if '.git' in filepath:
            continue
        
        if update_links_in_file(filepath):
            updated_count += 1
    
    print(f"\nTotal files updated: {updated_count}")


if __name__ == "__main__":
    main() 