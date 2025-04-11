#!/bin/bash

# Template Generator for Three Horizons Playbook
# This script helps create new templates for the Three Horizons platform

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
function show_banner() {
    echo "========================================================================="
    echo "      Three Horizons - Template Generator                               "
    echo "========================================================================="
    echo "This script helps create new templates for the Three Horizons platform."
    echo "It will generate the necessary directory structure and scaffold files."
    echo "========================================================================="
    echo ""
}

# Logging function
function log() {
    local type=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    case $type in
        "info")
            echo -e "${BLUE}[${timestamp}] [info] ${message}${NC}"
            ;;
        "success")
            echo -e "${GREEN}[${timestamp}] [success] ${message}${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}[${timestamp}] [warning] ${message}${NC}"
            ;;
        "error")
            echo -e "${RED}[${timestamp}] [error] ${message}${NC}"
            ;;
        *)
            echo -e "[${timestamp}] ${message}"
            ;;
    esac
}

# Help
function show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE       Template type (web, kubernetes, infrastructure, azure)"
    echo "  -n, --name NAME       Template name"
    echo "  -d, --description DESC  Template description"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --type web --name react-app --description \"React application template\""
}

# Check prerequisites
function check_prerequisites() {
    log "info" "Checking prerequisites..."
    
    # Check if running in the repository root
    if [[ ! -d "templates" ]]; then
        log "error" "This script must be run from the repository root or templates directory"
        exit 1
    fi
    
    log "success" "Prerequisites OK"
}

# Create template structure
function create_template_structure() {
    local type=$1
    local name=$2
    local description=$3
    local target_dir="templates/${type}-templates/${name}"
    
    log "info" "Creating template structure for $name ($type)"
    
    # Create directory structure
    mkdir -p "${target_dir}/skeleton"
    
    # Create template.yaml using cat with proper escaping
    cat > "${target_dir}/template.yaml" << 'TEMPLATE_EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: three-horizons-NAME_PLACEHOLDER
  title: Three Horizons TITLE_PLACEHOLDER Template
  description: DESCRIPTION_PLACEHOLDER
  tags:
    - recommended
    - TYPE_PLACEHOLDER
    - three-horizons
spec:
  owner: three-horizons-platform-team
  type: TYPE_PLACEHOLDER
  parameters:
    - title: Provide Basic Information
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          description: Unique name
          ui:autofocus: true
          pattern: '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'
          maxLength: 63
        description:
          title: Description
          type: string
          description: Description
          
  steps:
    - id: template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        targetPath: ./
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          
    - id: publish
      name: Publish
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: ${{ parameters.description }}
        repoUrl: github.com?owner=ThreeHorizonsOrg&repo=${{ parameters.name }}
        defaultBranch: main
        
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
TEMPLATE_EOF

    # Replace placeholders with sed
    sed -i '' "s/NAME_PLACEHOLDER/$name/g" "${target_dir}/template.yaml"
    name_title="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
    sed -i '' "s/TITLE_PLACEHOLDER/$name_title/g" "${target_dir}/template.yaml"
    sed -i '' "s/DESCRIPTION_PLACEHOLDER/$description/g" "${target_dir}/template.yaml"
    sed -i '' "s/TYPE_PLACEHOLDER/$type/g" "${target_dir}/template.yaml"
    
    # Create README.md
    cat > "${target_dir}/README.md" << 'README_EOF'
# NAME_TITLE_PLACEHOLDER Template

DESCRIPTION_PLACEHOLDER

This template is part of the Three Horizons platform template collection. It provides a standardized way to create new TYPE_PLACEHOLDER components.

## Usage

This template can be accessed through the Red Hat Developer Hub.

## Template Structure

- `template.yaml`: Main template definition
- `skeleton/`: Files that will be used to generate the new component

## Customization

To customize this template:

1. Modify the files in the `skeleton/` directory
2. Update the parameters in `template.yaml` as needed
3. Test the template with the Developer Hub

## Related Templates

Check out other templates in the Three Horizons collection:

- Web Application Templates
- Kubernetes Application Templates
- Infrastructure Templates
- Azure Resource Templates
README_EOF

    # Replace placeholders in README
    sed -i '' "s/NAME_TITLE_PLACEHOLDER/$name_title/g" "${target_dir}/README.md"
    sed -i '' "s/DESCRIPTION_PLACEHOLDER/$description/g" "${target_dir}/README.md"
    sed -i '' "s/TYPE_PLACEHOLDER/$type/g" "${target_dir}/README.md"

    # Create basic skeleton README
    cat > "${target_dir}/skeleton/README.md" << 'SKELETON_README_EOF'
# ${{values.name}}

${{values.description}}

This component was generated using the Three Horizons NAME_TITLE_PLACEHOLDER Template.

## Getting Started

[Include instructions here]

## Configuration

[Include configuration details here]

## Additional Resources

- [Three Horizons Documentation](https://github.com/ThreeHorizonsOrg/documentation)
SKELETON_README_EOF

    # Replace placeholders in skeleton README
    sed -i '' "s/NAME_TITLE_PLACEHOLDER/$name_title/g" "${target_dir}/skeleton/README.md"

    log "success" "Template structure created at ${target_dir}"
    log "info" "Don't forget to customize the template parameters and skeleton files!"
}

# Main function
function main() {
    # Parse arguments
    template_type=""
    template_name=""
    template_description=""
    
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -t|--type)
                template_type="$2"
                shift
                shift
                ;;
            -n|--name)
                template_name="$2"
                shift
                shift
                ;;
            -d|--description)
                template_description="$2"
                shift
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log "error" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate inputs
    if [[ -z "$template_type" ]]; then
        log "error" "Template type is required"
        show_help
        exit 1
    fi
    
    if [[ -z "$template_name" ]]; then
        log "error" "Template name is required"
        show_help
        exit 1
    fi
    
    if [[ -z "$template_description" ]]; then
        log "error" "Template description is required"
        show_help
        exit 1
    fi
    
    # Ensure template type is valid
    case $template_type in
        web|kubernetes|infrastructure|azure)
            # Valid type
            ;;
        *)
            log "error" "Invalid template type: $template_type. Use web, kubernetes, infrastructure, or azure."
            exit 1
            ;;
    esac
    
    # Create template
    create_template_structure "$template_type" "$template_name" "$template_description"
    
    log "success" "Template creation complete!"
}

# Execute
show_banner
check_prerequisites
main "$@" 