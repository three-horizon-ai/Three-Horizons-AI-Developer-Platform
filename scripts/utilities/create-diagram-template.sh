#!/bin/bash
#
# Script Name: create-diagram-template.sh
#
# Description: This script creates SVG diagram templates for architecture, workflows,
#              and other documentation elements using standard styling and formats.
#
# Usage: ./create-diagram-template.sh [OPTIONS] OUTPUT_FILE
#
# Options:
#   -h, --help                 Display this help message and exit
#   -t, --type TYPE            Type of diagram to create [architecture|workflow|component|network|security]
#   -d, --destination DIR      Destination directory (default: docs/documentation/architecture)
#   -n, --name NAME            Name of the diagram (used in title and description)
#   -s, --style                Generate with Three Horizons styling
#
# Examples:
#   ./create-diagram-template.sh -t architecture -n "API Gateway" output.svg
#   ./create-diagram-template.sh -t workflow -s -n "CI/CD Pipeline" docs/workflows/cicd.svg
#   ./create-diagram-template.sh -t component -n "Developer Portal" portal-diagram.svg
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
TYPE="architecture"
DESTINATION="docs/documentation/architecture"
NAME=""
STYLE=false
OUTPUT_FILE=""

# Display script header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}    Three Horizons Platform - SVG Diagram Template Creator   ${NC}"
echo -e "${BLUE}============================================================${NC}"

# Function to display help message
display_help() {
    echo -e "\n${GREEN}Usage:${NC} $0 [OPTIONS] OUTPUT_FILE"
    echo -e "\n${GREEN}Description:${NC}"
    echo "  This script creates SVG diagram templates for architecture, workflows,"
    echo "  and other documentation elements using standard styling and formats."
    echo -e "\n${GREEN}Options:${NC}"
    echo "  -h, --help                 Display this help message and exit"
    echo "  -t, --type TYPE            Type of diagram to create [architecture|workflow|component|network|security]"
    echo "  -d, --destination DIR      Destination directory (default: docs/documentation/architecture)"
    echo "  -n, --name NAME            Name of the diagram (used in title and description)"
    echo "  -s, --style                Generate with Three Horizons styling"
    echo -e "\n${GREEN}Examples:${NC}"
    echo "  $0 -t architecture -n \"API Gateway\" output.svg"
    echo "  $0 -t workflow -s -n \"CI/CD Pipeline\" docs/workflows/cicd.svg"
    echo "  $0 -t component -n \"Developer Portal\" portal-diagram.svg"
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
        -t|--type)
            TYPE="$2"
            shift # past argument
            shift # past value
            ;;
        -d|--destination)
            DESTINATION="$2"
            shift # past argument
            shift # past value
            ;;
        -n|--name)
            NAME="$2"
            shift # past argument
            shift # past value
            ;;
        -s|--style)
            STYLE=true
            shift # past argument
            ;;
        *)
            if [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
                shift # past argument
            else
                echo -e "${RED}Error: Unknown option or multiple output files specified: $1${NC}"
                echo "Use -h or --help for usage information."
                exit 1
            fi
            ;;
    esac
done

# Validate inputs
if [ -z "$OUTPUT_FILE" ]; then
    echo -e "${RED}Error: No output file specified.${NC}"
    echo "Use -h or --help for usage information."
    exit 1
fi

if [ -z "$NAME" ]; then
    # Extract name from filename if not provided
    NAME=$(basename "$OUTPUT_FILE" .svg | sed 's/-/ /g' | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    echo -e "${YELLOW}No name provided, using: ${NAME}${NC}"
fi

# Ensure output file has .svg extension
if [[ ! "$OUTPUT_FILE" =~ \.svg$ ]]; then
    OUTPUT_FILE="${OUTPUT_FILE}.svg"
    echo -e "${YELLOW}Adding .svg extension to output file: ${OUTPUT_FILE}${NC}"
fi

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${RED}Error: Output file already exists: ${OUTPUT_FILE}${NC}"
    echo "Please specify a different output file or remove the existing one."
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Validate diagram type
case $TYPE in
    architecture|workflow|component|network|security)
        echo -e "${BLUE}Creating ${TYPE} diagram template...${NC}"
        ;;
    *)
        echo -e "${RED}Error: Invalid diagram type: ${TYPE}${NC}"
        echo "Valid types are: architecture, workflow, component, network, security"
        exit 1
        ;;
esac

# Define diagram-specific settings
VIEWBOX="0 0 800 600"
TITLE="${NAME} Diagram"
DESCRIPTION="${NAME} diagram for the Three Horizons Platform"

case $TYPE in
    architecture)
        VIEWBOX="0 0 1000 700"
        TITLE="${NAME} Architecture"
        DESCRIPTION="Architecture diagram showing the ${NAME} components and relationships"
        ;;
    workflow)
        VIEWBOX="0 0 900 500"
        TITLE="${NAME} Workflow"
        DESCRIPTION="Workflow diagram illustrating the ${NAME} process"
        ;;
    component)
        VIEWBOX="0 0 800 600"
        TITLE="${NAME} Component"
        DESCRIPTION="Component diagram detailing the ${NAME} structure"
        ;;
    network)
        VIEWBOX="0 0 1000 600"
        TITLE="${NAME} Network"
        DESCRIPTION="Network diagram showing the ${NAME} connectivity"
        ;;
    security)
        VIEWBOX="0 0 900 650"
        TITLE="${NAME} Security"
        DESCRIPTION="Security diagram illustrating the ${NAME} controls and measures"
        ;;
esac

# Define colors for Three Horizons styling
AZURE_COLOR="#0072C6"
GITHUB_COLOR="#24292E"
REDHAT_COLOR="#EE0000"
TEXT_COLOR="#333333"
BACKGROUND_COLOR="#FFFFFF"
ACCENT_COLOR="#4CAF50"
GRID_COLOR="#E0E0E0"

# Create SVG content
create_svg_content() {
    cat << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="100%" height="100%" viewBox="${VIEWBOX}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">
    <title>${TITLE}</title>
    <desc>${DESCRIPTION}</desc>
    
    <!-- Definitions for reusable elements -->
    <defs>
        <!-- Grid pattern -->
        <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
            <rect width="20" height="20" fill="none" stroke="${GRID_COLOR}" stroke-width="0.5"/>
        </pattern>
        
        <!-- Arrows -->
        <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
            <path d="M 0 0 L 10 5 L 0 10 z" fill="#666"/>
        </marker>
        
        <!-- Component styles -->
        <style type="text/css">
            .component {
                fill: white;
                stroke: #666;
                stroke-width: 2;
                rx: 5;
                ry: 5;
            }
            .azure { fill: ${AZURE_COLOR}; color: white; }
            .github { fill: ${GITHUB_COLOR}; color: white; }
            .redhat { fill: ${REDHAT_COLOR}; color: white; }
            .label { 
                font-family: Arial, sans-serif; 
                font-size: 14px; 
                text-anchor: middle; 
                dominant-baseline: middle;
            }
            .title { 
                font-family: Arial, sans-serif; 
                font-size: 24px; 
                font-weight: bold; 
                text-anchor: middle; 
            }
            .subtitle { 
                font-family: Arial, sans-serif; 
                font-size: 16px; 
                text-anchor: middle; 
            }
            .connector {
                fill: none;
                stroke: #666;
                stroke-width: 2;
                marker-end: url(#arrow);
            }
            .group {
                fill: rgba(0,0,0,0.05);
                stroke: #666;
                stroke-width: 1;
                stroke-dasharray: 5,5;
                rx: 10;
                ry: 10;
            }
            .group-label {
                font-family: Arial, sans-serif;
                font-size: 16px;
                font-weight: bold;
                text-anchor: middle;
            }
        </style>
    </defs>
    
    <!-- Background grid -->
    <rect width="100%" height="100%" fill="url(#grid)" />
    
    <!-- Title and subtitle -->
    <g id="title">
        <text x="50%" y="30" class="title">${TITLE}</text>
        <text x="50%" y="55" class="subtitle">Three Horizons Platform</text>
    </g>
EOF

    # Add diagram-specific template content
    case $TYPE in
        architecture)
            cat << EOF
    
    <!-- Architecture Components -->
    <g id="architecture">
        <!-- Microsoft Azure Group -->
        <rect x="100" y="100" width="200" height="250" class="group" />
        <text x="200" y="125" class="group-label">Microsoft Azure</text>
        
        <!-- Component examples -->
        <rect x="125" y="150" width="150" height="50" class="component azure" />
        <text x="200" y="175" class="label" fill="white">AKS</text>
        
        <rect x="125" y="225" width="150" height="50" class="component azure" />
        <text x="200" y="250" class="label" fill="white">Microsoft Entra ID</text>
        
        <rect x="125" y="300" width="150" height="50" class="component azure" />
        <text x="200" y="325" class="label" fill="white">Azure Monitor</text>
        
        <!-- Red Hat Group -->
        <rect x="500" y="100" width="200" height="250" class="group" />
        <text x="600" y="125" class="group-label">Red Hat</text>
        
        <rect x="525" y="150" width="150" height="50" class="component redhat" />
        <text x="600" y="175" class="label" fill="white">Developer Hub</text>
        
        <rect x="525" y="225" width="150" height="50" class="component redhat" />
        <text x="600" y="250" class="label" fill="white">OpenShift</text>
        
        <rect x="525" y="300" width="150" height="50" class="component redhat" />
        <text x="600" y="325" class="label" fill="white">Service Catalog</text>
        
        <!-- GitHub Group -->
        <rect x="300" y="400" width="200" height="150" class="group" />
        <text x="400" y="425" class="group-label">GitHub</text>
        
        <rect x="325" y="450" width="150" height="50" class="component github" />
        <text x="400" y="475" class="label" fill="white">GitHub Actions</text>
        
        <rect x="325" y="525" width="150" height="50" class="component github" />
        <text x="400" y="550" class="label" fill="white">GitHub Copilot</text>
        
        <!-- Connectors -->
        <path d="M 275 175 L 525 175" class="connector" />
        <path d="M 275 250 L 525 250" class="connector" />
        <path d="M 200 350 L 200 450 L 325 450" class="connector" />
        <path d="M 600 350 L 600 450 L 475 450" class="connector" />
    </g>
EOF
            ;;
        workflow)
            cat << EOF
    
    <!-- Workflow Components -->
    <g id="workflow">
        <!-- Start and End -->
        <circle cx="100" cy="150" r="30" fill="${ACCENT_COLOR}" stroke="#333" stroke-width="2" />
        <text x="100" y="150" class="label" fill="white">Start</text>
        
        <circle cx="700" cy="350" r="30" fill="#FF5722" stroke="#333" stroke-width="2" />
        <text x="700" y="350" class="label" fill="white">End</text>
        
        <!-- Process Steps -->
        <rect x="200" y="125" width="150" height="50" class="component" />
        <text x="275" y="150" class="label">Step 1</text>
        
        <rect x="400" y="125" width="150" height="50" class="component" />
        <text x="475" y="150" class="label">Step 2</text>
        
        <rect x="400" y="225" width="150" height="50" class="component" />
        <text x="475" y="250" class="label">Step 3</text>
        
        <rect x="200" y="325" width="150" height="50" class="component" />
        <text x="275" y="350" class="label">Step 4</text>
        
        <rect x="400" y="325" width="150" height="50" class="component" />
        <text x="475" y="350" class="label">Step 5</text>
        
        <!-- Decision Point -->
        <polygon points="275,200 325,250 275,300 225,250" fill="white" stroke="#666" stroke-width="2" />
        <text x="275" y="250" class="label">Decision</text>
        
        <!-- Connectors -->
        <path d="M 130 150 L 200 150" class="connector" />
        <path d="M 350 150 L 400 150" class="connector" />
        <path d="M 550 150 L 600 150 L 600 225 L 550 225" class="connector" />
        <path d="M 400 250 L 325 250" class="connector" />
        <path d="M 225 250 L 150 250 L 150 350 L 200 350" class="connector" />
        <path d="M 350 350 L 400 350" class="connector" />
        <path d="M 550 350 L 670 350" class="connector" />
        <path d="M 275 300 L 275 325" class="connector" />
    </g>
EOF
            ;;
        component)
            cat << EOF
    
    <!-- Component Structure -->
    <g id="component">
        <!-- Main Component -->
        <rect x="300" y="150" width="200" height="80" class="component" stroke-width="3" />
        <text x="400" y="190" class="label">Main Component</text>
        
        <!-- Sub-components -->
        <rect x="150" y="300" width="150" height="60" class="component" />
        <text x="225" y="330" class="label">Sub-component 1</text>
        
        <rect x="325" y="300" width="150" height="60" class="component" />
        <text x="400" y="330" class="label">Sub-component 2</text>
        
        <rect x="500" y="300" width="150" height="60" class="component" />
        <text x="575" y="330" class="label">Sub-component 3</text>
        
        <!-- Connectors -->
        <path d="M 400 230 L 400 260 L 225 260 L 225 300" class="connector" />
        <path d="M 400 230 L 400 300" class="connector" />
        <path d="M 400 230 L 400 260 L 575 260 L 575 300" class="connector" />
        
        <!-- Dependencies -->
        <rect x="150" y="400" width="120" height="50" class="component" fill="#E0E0E0" />
        <text x="210" y="425" class="label">Dependency 1</text>
        
        <rect x="340" y="400" width="120" height="50" class="component" fill="#E0E0E0" />
        <text x="400" y="425" class="label">Dependency 2</text>
        
        <rect x="530" y="400" width="120" height="50" class="component" fill="#E0E0E0" />
        <text x="590" y="425" class="label">Dependency 3</text>
        
        <path d="M 225 360 L 225 400" class="connector" stroke-dasharray="5,5" />
        <path d="M 400 360 L 400 400" class="connector" stroke-dasharray="5,5" />
        <path d="M 575 360 L 575 400" class="connector" stroke-dasharray="5,5" />
    </g>
EOF
            ;;
        network)
            cat << EOF
    
    <!-- Network Diagram -->
    <g id="network">
        <!-- Network zones -->
        <rect x="100" y="100" width="800" height="150" class="group" fill="rgba(0,114,198,0.1)" />
        <text x="150" y="125" class="group-label" text-anchor="start">Public Zone</text>
        
        <rect x="100" y="275" width="800" height="150" class="group" fill="rgba(76,175,80,0.1)" />
        <text x="150" y="300" class="group-label" text-anchor="start">DMZ</text>
        
        <rect x="100" y="450" width="800" height="150" class="group" fill="rgba(238,0,0,0.1)" />
        <text x="150" y="475" class="group-label" text-anchor="start">Private Zone</text>
        
        <!-- Network components -->
        <rect x="400" y="150" width="140" height="60" class="component" />
        <text x="470" y="180" class="label">Load Balancer</text>
        
        <rect x="250" y="320" width="140" height="60" class="component" />
        <text x="320" y="350" class="label">API Gateway</text>
        
        <rect x="450" y="320" width="140" height="60" class="component" />
        <text x="520" y="350" class="label">Web Server</text>
        
        <rect x="650" y="320" width="140" height="60" class="component" />
        <text x="720" y="350" class="label">Identity</text>
        
        <rect x="250" y="500" width="140" height="60" class="component" />
        <text x="320" y="530" class="label">App Server</text>
        
        <rect x="450" y="500" width="140" height="60" class="component" />
        <text x="520" y="530" class="label">Database</text>
        
        <rect x="650" y="500" width="140" height="60" class="component" />
        <text x="720" y="530" class="label">Storage</text>
        
        <!-- Network connections -->
        <path d="M 470 210 L 470 245 L 320 245 L 320 320" class="connector" />
        <path d="M 470 210 L 470 245 L 520 245 L 520 320" class="connector" />
        <path d="M 470 210 L 470 245 L 720 245 L 720 320" class="connector" />
        
        <path d="M 320 380 L 320 415 L 320 500" class="connector" />
        <path d="M 520 380 L 520 500" class="connector" />
        <path d="M 720 380 L 720 415 L 520 415" class="connector" />
        
        <path d="M 320 415 L 720 415" class="connector" stroke="#666" stroke-width="1" stroke-dasharray="5,5" marker-end="none" />
    </g>
EOF
            ;;
        security)
            cat << EOF
    
    <!-- Security Diagram -->
    <g id="security">
        <!-- Security layers -->
        <rect x="150" y="150" width="600" height="400" rx="15" ry="15" fill="none" stroke="#ccc" stroke-width="2" stroke-dasharray="none" />
        <rect x="200" y="200" width="500" height="300" rx="15" ry="15" fill="none" stroke="#ccc" stroke-width="2" stroke-dasharray="none" />
        <rect x="250" y="250" width="400" height="200" rx="15" ry="15" fill="none" stroke="#ccc" stroke-width="2" stroke-dasharray="none" />
        
        <text x="180" y="175" class="label" text-anchor="start" font-weight="bold">Perimeter Security</text>
        <text x="230" y="225" class="label" text-anchor="start" font-weight="bold">Network Security</text>
        <text x="280" y="275" class="label" text-anchor="start" font-weight="bold">Application Security</text>
        
        <!-- Security components -->
        <rect x="150" y="500" width="120" height="50" class="component" fill="#FF5722" stroke="#333" />
        <text x="210" y="525" class="label" fill="white">Firewall</text>
        
        <rect x="300" y="500" width="120" height="50" class="component" fill="#FF9800" stroke="#333" />
        <text x="360" y="525" class="label" fill="white">WAF</text>
        
        <rect x="450" y="500" width="120" height="50" class="component" fill="#2196F3" stroke="#333" />
        <text x="510" y="525" class="label" fill="white">Identity</text>
        
        <rect x="600" y="500" width="120" height="50" class="component" fill="#673AB7" stroke="#333" />
        <text x="660" y="525" class="label" fill="white">Encryption</text>
        
        <!-- Central assets -->
        <rect x="400" y="300" width="100" height="100" fill="white" stroke="#333" stroke-width="2" />
        <text x="450" y="350" class="label">Protected Assets</text>
        
        <!-- Security controls arrows -->
        <path d="M 210 500 L 210 425 L 350 425" class="connector" />
        <path d="M 360 500 L 360 400 L 400 400" class="connector" />
        <path d="M 510 500 L 510 400 L 500 400" class="connector" />
        <path d="M 660 500 L 660 425 L 550 425" class="connector" />
        
        <!-- Threat indicators -->
        <circle cx="125" y="175" r="10" fill="red" />
        <text x="125" y="175" class="label" font-size="12" fill="white">!</text>
        
        <circle cx="125" y="225" r="10" fill="red" />
        <text x="125" y="225" class="label" font-size="12" fill="white">!</text>
        
        <circle cx="125" y="275" r="10" fill="red" />
        <text x="125" y="275" class="label" font-size="12" fill="white">!</text>
    </g>
EOF
            ;;
    esac

    # Footer content
    cat << EOF
    
    <!-- Footer with credits -->
    <g id="footer">
        <text x="50%" y="580" font-family="Arial, sans-serif" font-size="12" text-anchor="middle">
            Three Horizons Platform - Created $(date +"%Y-%m-%d")
        </text>
    </g>
</svg>
EOF
}

# Generate SVG content
if [ "$STYLE" = true ]; then
    echo -e "${BLUE}Creating SVG with Three Horizons styling...${NC}"
else
    echo -e "${BLUE}Creating basic SVG template...${NC}"
fi

# Create SVG file
create_svg_content > "$OUTPUT_FILE"

echo -e "${GREEN}✓ SVG template created successfully: ${OUTPUT_FILE}${NC}"

# Provide next steps
echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Open the SVG file in a vector graphics editor like Inkscape or Adobe Illustrator"
echo "2. Customize the diagram with your specific content"
echo "3. Save and use in your documentation"
echo -e "\n${BLUE}To optimize the SVG for web use:${NC}"
echo "  ./scripts/utilities/convert-images-to-svg.sh -o -d $(dirname "$OUTPUT_FILE")"

exit 0 