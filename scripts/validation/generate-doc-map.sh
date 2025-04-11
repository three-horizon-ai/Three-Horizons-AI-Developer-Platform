#!/bin/bash
# Script to automatically generate the documentation map for Three Horizons Playbook

set -e

echo "Generating documentation map..."

# Root directory of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Output file
OUTPUT_FILE="docs/DOCUMENTATION_MAP.md"

# Function to get the title from a markdown file
get_title() {
  local file="$1"
  if [ -f "$file" ]; then
    # Extract the first heading (# title)
    head -20 "$file" | grep -m 1 "^# " | sed 's/^# //'
  else
    basename "$file" .md | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g' # Title case
  fi
}

# Function to get a brief description from a markdown file
get_description() {
  local file="$1"
  if [ -f "$file" ]; then
    # Try to extract the first paragraph after the title
    # Skipping the title and empty lines
    description=$(awk 'BEGIN{start=0} /^# / {start=1; next} /^$/ {if(start==1) start=2; next} /^[^#]/ {if(start==2) {print; exit}}' "$file")
    
    # If no description was found, try the second heading and paragraph
    if [ -z "$description" ]; then
      description=$(awk 'BEGIN{start=0} /^## / {start=1; next} /^$/ {if(start==1) start=2; next} /^[^#]/ {if(start==2) {print; exit}}' "$file")
    fi
    
    # If still no description, use a generic one
    if [ -z "$description" ]; then
      title=$(get_title "$file")
      description="Documentation about $title"
    fi
    
    # Truncate long descriptions
    if [ ${#description} -gt 80 ]; then
      description="${description:0:77}..."
    fi
    
    echo "$description"
  else
    echo "Documentation pending"
  fi
}

# Start generating the map
cat > "$OUTPUT_FILE" << EOF
# Three Horizons Documentation Map

This document serves as a central index of all documentation in the Three Horizons Playbook repository, facilitating navigation and ensuring complete coverage of all aspects of the platform.

## Repository Structure

EOF

# Add root files
for file in README.md CONTRIBUTING.md SECURITY.md LICENSE; do
  if [ -f "$file" ]; then
    title=$(get_title "$file")
    [ -z "$title" ] && title=$(basename "$file" .md)
    echo "- [**$file**]($file) - $title" >> "$OUTPUT_FILE"
  fi
done

# Documentation directories
echo -e "\n## Main Documentation\n" >> "$OUTPUT_FILE"

# Process each main documentation directory
for dir in docs/*/; do
  dir_name=$(basename "$dir")
  dir_title=$(echo "$dir_name" | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
  
  echo -e "### $dir_title" >> "$OUTPUT_FILE"
  
  # Find markdown files in the directory
  find "$dir" -maxdepth 1 -name "*.md" | sort | while read -r file; do
    rel_file=${file#docs/}
    title=$(get_title "$file")
    description=$(get_description "$file")
    
    [ -z "$title" ] && title=$(basename "$file" .md | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
    echo "- [**$title**]($rel_file) - $description" >> "$OUTPUT_FILE"
  done
  
  echo "" >> "$OUTPUT_FILE"
done

# Templates section
echo -e "## Templates\n" >> "$OUTPUT_FILE"

# ARM Templates
echo "### ARM Templates" >> "$OUTPUT_FILE"
if [ -f "templates/arm/README.md" ]; then
  echo "- [**README**](../templates/arm/README.md) - $(get_description "templates/arm/README.md")" >> "$OUTPUT_FILE"
fi
if [ -d "templates/arm/docs" ]; then
  find "templates/arm/docs" -name "*.md" | sort | while read -r file; do
    rel_file=${file#templates/}
    title=$(get_title "$file")
    [ -z "$title" ] && title=$(basename "$file" .md | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
    echo "- [**$title**](../templates/$rel_file) - $(get_description "$file")" >> "$OUTPUT_FILE"
  done
fi

# Bicep Templates
echo -e "\n### Bicep Templates" >> "$OUTPUT_FILE"
if [ -f "templates/bicep/README.md" ]; then
  echo "- [**README**](../templates/bicep/README.md) - $(get_description "templates/bicep/README.md")" >> "$OUTPUT_FILE"
fi

# Azure Templates
echo -e "\n### Azure Templates" >> "$OUTPUT_FILE"
for cloud in aks aro; do
  if [ -f "templates/azure/$cloud/docs/README.md" ]; then
    title=$(echo "$cloud" | tr '[:lower:]' '[:upper:]')
    echo "- [**$title README**](../templates/azure/$cloud/docs/README.md) - Templates for $title" >> "$OUTPUT_FILE"
  fi
done

# DevBox Templates
echo -e "\n### DevBox Templates" >> "$OUTPUT_FILE"
if [ -f "templates/devbox/README.md" ]; then
  echo "- [**README**](../templates/devbox/README.md) - $(get_description "templates/devbox/README.md")" >> "$OUTPUT_FILE"
fi

# Infrastructure Templates
echo -e "\n### Infrastructure Templates" >> "$OUTPUT_FILE"
if [ -f "templates/infrastructure/README.md" ]; then
  echo "- [**README**](../templates/infrastructure/README.md) - $(get_description "templates/infrastructure/README.md")" >> "$OUTPUT_FILE"
fi

# Examples section
echo -e "\n## Examples\n" >> "$OUTPUT_FILE"

# Applications
echo "### Applications" >> "$OUTPUT_FILE"
if [ -f "examples/applications/README.md" ]; then
  echo "- [**README**](../examples/applications/README.md) - Overview of example applications" >> "$OUTPUT_FILE"
fi

# Key application examples
for app_type in microservices/spring-boot web-apps/nextjs-demo serverless/event-processor data/analytics-api; do
  if [ -f "examples/applications/$app_type/README.md" ]; then
    type_name=$(echo "$app_type" | cut -d '/' -f 1 | sed 's/\b\(.\)/\u\1/g')
    app_name=$(echo "$app_type" | cut -d '/' -f 2 | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
    echo "- [**$type_name**](../examples/applications/$app_type/README.md) - Example of $app_name" >> "$OUTPUT_FILE"
  fi
done

# Configurations
echo -e "\n### Configurations" >> "$OUTPUT_FILE"
if [ -f "examples/configurations/README.md" ]; then
  echo "- [**README**](../examples/configurations/README.md) - Overview of example configurations" >> "$OUTPUT_FILE"
fi

# Pipelines
echo -e "\n### Pipelines" >> "$OUTPUT_FILE"
if [ -f "examples/pipelines/README.md" ]; then
  echo "- [**README**](../examples/pipelines/README.md) - Overview of example pipelines" >> "$OUTPUT_FILE"
fi
if [ -f "examples/pipelines/github-actions/microservice/README.md" ]; then
  echo "- [**GitHub Actions**](../examples/pipelines/github-actions/microservice/README.md) - Pipeline for microservices" >> "$OUTPUT_FILE"
fi

# Scripts section
echo -e "\n## Scripts" >> "$OUTPUT_FILE"
if [ -f "scripts/README.md" ]; then
  echo "- [**README**](../scripts/README.md) - Overview of scripts" >> "$OUTPUT_FILE"
fi
for script_dir in setup validation; do
  if [ -f "scripts/$script_dir/README.md" ]; then
    dir_title=$(echo "$script_dir" | sed 's/\b\(.\)/\u\1/g')
    echo "- [**$dir_title**](../scripts/$script_dir/README.md) - $script_dir scripts" >> "$OUTPUT_FILE"
  fi
done

# GitHub section
echo -e "\n## GitHub" >> "$OUTPUT_FILE"
if [ -f ".github/workflows/README.md" ]; then
  echo "- [**Workflows README**](../.github/workflows/README.md) - GitHub Actions workflows documentation" >> "$OUTPUT_FILE"
fi
if [ -f ".github/copilot-instructions.md" ]; then
  echo "- [**Copilot Instructions**](../.github/copilot-instructions.md) - Instructions for GitHub Copilot" >> "$OUTPUT_FILE"
fi

# Footer
echo -e "\n---\n\n> This documentation map is automatically updated as part of the CI/CD workflow." >> "$OUTPUT_FILE"

echo "Documentation map generated at $OUTPUT_FILE" 