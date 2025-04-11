#!/bin/bash
#
# Script Name: convert-images-to-svg.sh
#
# Description: This script converts between SVG and PNG formats and optimizes 
#              SVG files for better GitHub compatibility. It supports batch 
#              processing of multiple image files and directories.
#
# Usage: ./scripts/utilities/convert-images-to-svg.sh [OPTIONS]
#
# Options:
#   -h, --help                 Display this help message and exit
#   -d, --directory DIR        Specify the root directory to scan for images (default: current directory)
#   -f, --force                Force overwrite existing files
#   -o, --optimize-only        Only optimize existing SVG files without converting
#   -v, --verbose              Display detailed progress information
#   -r, --reverse              Convert SVG to PNG instead of PNG to SVG
#   -s, --simplify             Apply extra simplification to SVGs for GitHub compatibility
#
# Requirements:
#   - For PNG to SVG: Inkscape (https://inkscape.org/) or ImageMagick (https://imagemagick.org/)
#   - For SVG to PNG: svgexport (npm install -g svgexport) or ImageMagick
#   - For optimization: svgo (npm install -g svgo)
#
# Examples:
#   ./convert-images-to-svg.sh                           # Process all files in current directory
#   ./convert-images-to-svg.sh -d ./docs                 # Process all files in docs directory
#   ./convert-images-to-svg.sh -d ./assets/images -f     # Force overwrite in assets/images
#   ./convert-images-to-svg.sh -o                        # Only optimize existing SVGs
#   ./convert-images-to-svg.sh -r                        # Convert SVGs to PNGs instead
#   ./convert-images-to-svg.sh -r -s                     # Convert SVGs to PNGs with GitHub compatibility
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
DIRECTORY="."
FORCE=false
OPTIMIZE_ONLY=false
VERBOSE=false
REVERSE=false
SIMPLIFY=false

# Display script header
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      Three Horizons Platform - Image Conversion Tool       ${NC}"
echo -e "${BLUE}============================================================${NC}"

# Function to display help message
display_help() {
    echo -e "\n${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo -e "\n${GREEN}Description:${NC}"
    echo "  This script converts between SVG and PNG formats and optimizes"
    echo "  SVG files for better GitHub compatibility. It supports batch"
    echo "  processing of multiple image files and directories."
    echo -e "\n${GREEN}Options:${NC}"
    echo "  -h, --help                 Display this help message and exit"
    echo "  -d, --directory DIR        Specify the root directory to scan for images (default: current directory)"
    echo "  -f, --force                Force overwrite existing files"
    echo "  -o, --optimize-only        Only optimize existing SVG files without converting"
    echo "  -v, --verbose              Display detailed progress information"
    echo "  -r, --reverse              Convert SVG to PNG instead of PNG to SVG"
    echo "  -s, --simplify             Apply extra simplification to SVGs for GitHub compatibility"
    echo -e "\n${GREEN}Examples:${NC}"
    echo "  $0                           # Process all files in current directory"
    echo "  $0 -d ./docs                 # Process all files in docs directory"
    echo "  $0 -d ./assets/images -f     # Force overwrite in assets/images"
    echo "  $0 -o                        # Only optimize existing SVGs"
    echo "  $0 -r                        # Convert SVGs to PNGs instead"
    echo "  $0 -r -s                     # Convert SVGs to PNGs with GitHub compatibility"
    echo -e "\n${GREEN}Requirements:${NC}"
    echo "  - For PNG to SVG: Inkscape (https://inkscape.org/) or ImageMagick (https://imagemagick.org/)"
    echo "  - For SVG to PNG: svgexport (npm install -g svgexport) or ImageMagick"
    echo "  - For optimization: svgo (npm install -g svgo)"
    echo ""
    exit 0
}

# Function to check if required tools are installed
check_requirements() {
    echo -e "\n${BLUE}Checking requirements...${NC}"
    
    # Determine which tools we need based on conversion direction
    if [ "$REVERSE" = false ] && [ "$OPTIMIZE_ONLY" = false ]; then
        # PNG to SVG conversion, need either Inkscape or ImageMagick
        if command -v inkscape &> /dev/null; then
            echo -e "${GREEN}✓ Inkscape is installed.${NC}"
            PNG_TO_SVG_TOOL="inkscape"
        elif command -v convert &> /dev/null; then
            echo -e "${GREEN}✓ ImageMagick is installed.${NC}"
            PNG_TO_SVG_TOOL="imagemagick"
        else
            echo -e "${RED}Error: Neither Inkscape nor ImageMagick is installed.${NC}"
            echo -e "${YELLOW}Please install Inkscape from https://inkscape.org/ or ImageMagick from https://imagemagick.org/${NC}"
            exit 1
        fi
    elif [ "$REVERSE" = true ]; then
        # SVG to PNG conversion, need either svgexport or ImageMagick
        if command -v svgexport &> /dev/null; then
            echo -e "${GREEN}✓ svgexport is installed.${NC}"
            SVG_TO_PNG_TOOL="svgexport"
        elif command -v convert &> /dev/null; then
            echo -e "${GREEN}✓ ImageMagick is installed.${NC}" 
            SVG_TO_PNG_TOOL="imagemagick"
        else
            echo -e "${RED}Error: Neither svgexport nor ImageMagick is installed.${NC}"
            echo -e "${YELLOW}Please install svgexport using: npm install -g svgexport OR install ImageMagick from https://imagemagick.org/${NC}"
            exit 1
        fi
    fi
    
    # Check for svgo if we're optimizing
    if [ "$REVERSE" = false ] || [ "$SIMPLIFY" = true ]; then
        if ! command -v svgo &> /dev/null; then
            echo -e "${RED}Error: svgo is not installed, which is required for SVG optimization.${NC}"
            echo -e "${YELLOW}Please install svgo using: npm install -g svgo${NC}"
            exit 1
        else
            echo -e "${GREEN}✓ svgo is installed.${NC}"
        fi
    fi
}

# Function to convert PNG to SVG
convert_png_to_svg() {
    local png_file="$1"
    local svg_file="${png_file%.png}.svg"
    
    # Check if SVG already exists and force flag is not set
    if [ -f "$svg_file" ] && [ "$FORCE" = false ]; then
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}Skipping conversion of ${png_file} (SVG already exists)${NC}"
        fi
        return 0
    fi
    
    echo -e "${BLUE}Converting: ${png_file} -> ${svg_file}${NC}"
    
    # Use the appropriate tool
    if [ "$PNG_TO_SVG_TOOL" = "inkscape" ]; then
        inkscape --export-filename="$svg_file" "$png_file"
    elif [ "$PNG_TO_SVG_TOOL" = "imagemagick" ]; then
        convert "$png_file" "$svg_file"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully converted ${png_file} to SVG${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to convert ${png_file} to SVG${NC}"
        return 1
    fi
}

# Function to convert SVG to PNG
convert_svg_to_png() {
    local svg_file="$1"
    local png_file="${svg_file%.svg}.png"
    
    # Check if PNG already exists and force flag is not set
    if [ -f "$png_file" ] && [ "$FORCE" = false ]; then
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}Skipping conversion of ${svg_file} (PNG already exists)${NC}"
        fi
        return 0
    fi
    
    echo -e "${BLUE}Converting: ${svg_file} -> ${png_file}${NC}"
    
    # Use the appropriate tool
    if [ "$SVG_TO_PNG_TOOL" = "svgexport" ]; then
        svgexport "$svg_file" "$png_file" 2x
    elif [ "$SVG_TO_PNG_TOOL" = "imagemagick" ]; then
        convert "$svg_file" "$png_file"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully converted ${svg_file} to PNG${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to convert ${svg_file} to PNG${NC}"
        return 1
    fi
}

# Function to optimize an SVG file using svgo
optimize_svg() {
    local svg_file="$1"
    local temp_file="${svg_file}.temp"
    
    echo -e "${BLUE}Optimizing: ${svg_file}${NC}"
    
    # Basic configuration for SVG optimization
    local svgo_config='{ 
        "multipass": true, 
        "pretty": true, 
        "plugins": [ 
            { 
                "name": "preset-default", 
                "params": { 
                    "overrides": { 
                        "removeViewBox": false, 
                        "cleanupIDs": false,
                        "removeComments": false
                    } 
                } 
            } 
        ] 
    }'
    
    # If simplify flag is true, use a more aggressive configuration for GitHub compatibility
    if [ "$SIMPLIFY" = true ]; then
        echo -e "${BLUE}Applying GitHub compatibility optimizations...${NC}"
        svgo_config='{ 
            "multipass": true, 
            "pretty": true, 
            "plugins": [ 
                { 
                    "name": "preset-default", 
                    "params": { 
                        "overrides": { 
                            "removeViewBox": false,
                            "removeTitle": false,
                            "removeDesc": false, 
                            "removeUselessDefs": false,
                            "cleanupIDs": false,
                            "removeComments": false
                        } 
                    } 
                },
                { "name": "removeXMLNS", "active": false },
                { "name": "removeDimensions", "active": true },
                { "name": "removeStyleElement", "active": false },
                { "name": "removeScriptElement", "active": true },
                { "name": "convertStyleToAttrs", "active": true },
                { "name": "removeFilterAttributes", "active": true },
                { "name": "removeOffCanvasPaths", "active": true }
            ] 
        }'
        
        # Make sure the SVG has XML declaration
        if ! grep -q "<?xml" "$svg_file"; then
            echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' > "${temp_file}.header"
            cat "$svg_file" >> "${temp_file}.header"
            mv "${temp_file}.header" "$svg_file"
        fi
    fi
    
    # Write config to temporary file
    local config_file=$(mktemp)
    echo "$svgo_config" > "$config_file"
    
    # Run svgo with the selected configuration
    svgo --config "$config_file" -i "$svg_file" -o "$temp_file"
    
    # Clean up config file
    rm -f "$config_file"
    
    if [ $? -eq 0 ]; then
        # Get file sizes before and after optimization
        local original_size=$(wc -c < "$svg_file")
        local optimized_size=$(wc -c < "$temp_file")
        local reduction=$(( (original_size - optimized_size) * 100 / original_size ))
        
        # Replace original with optimized version
        mv "$temp_file" "$svg_file"
        
        echo -e "${GREEN}✓ Successfully optimized ${svg_file} (reduced by ${reduction}%)${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to optimize ${svg_file}${NC}"
        # Clean up temp file if it exists
        [ -f "$temp_file" ] && rm -f "$temp_file"
        return 1
    fi
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -d|--directory)
            DIRECTORY="$2"
            shift # past argument
            shift # past value
            ;;
        -f|--force)
            FORCE=true
            shift # past argument
            ;;
        -o|--optimize-only)
            OPTIMIZE_ONLY=true
            shift # past argument
            ;;
        -v|--verbose)
            VERBOSE=true
            shift # past argument
            ;;
        -r|--reverse)
            REVERSE=true
            shift # past argument
            ;;
        -s|--simplify)
            SIMPLIFY=true
            shift # past argument
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# Check if the specified directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo -e "${RED}Error: Directory '$DIRECTORY' does not exist.${NC}"
    exit 1
fi

# Check for required tools
check_requirements

# Counter variables
PNG_COUNT=0
PNG_CONVERTED=0
SVG_COUNT=0
SVG_OPTIMIZED=0

echo -e "\n${BLUE}Starting image processing in directory: ${DIRECTORY}${NC}"

# First pass: Count files
if [ "$VERBOSE" = true ]; then
    echo -e "\n${BLUE}Counting files...${NC}"
fi

PNG_FILES_TOTAL=$(find "$DIRECTORY" -type f -name "*.png" | wc -l)
SVG_FILES_TOTAL=$(find "$DIRECTORY" -type f -name "*.svg" | wc -l)

echo -e "${BLUE}Found ${PNG_FILES_TOTAL} PNG files and ${SVG_FILES_TOTAL} SVG files.${NC}"

# Initialize counters differently based on conversion direction
if [ "$REVERSE" = false ]; then
    # PNG to SVG conversion
    if [ "$OPTIMIZE_ONLY" = false ]; then
        echo -e "\n${BLUE}Converting PNG files to SVG...${NC}"
        
        while IFS= read -r png_file; do
            ((PNG_COUNT++))
            if [ "$VERBOSE" = true ]; then
                echo -e "${BLUE}Processing PNG file ${PNG_COUNT}/${PNG_FILES_TOTAL}: ${png_file}${NC}"
            fi
            
            if convert_png_to_svg "$png_file"; then
                ((PNG_CONVERTED++))
            fi
        done < <(find "$DIRECTORY" -type f -name "*.png")
        
        echo -e "\n${GREEN}PNG conversion complete: ${PNG_CONVERTED}/${PNG_COUNT} files converted to SVG${NC}"
    fi

    # Optimize SVG files
    echo -e "\n${BLUE}Optimizing SVG files...${NC}"

    # Get a fresh count of SVG files (in case we just created some)
    SVG_FILES_TOTAL=$(find "$DIRECTORY" -type f -name "*.svg" | wc -l)

    while IFS= read -r svg_file; do
        ((SVG_COUNT++))
        if [ "$VERBOSE" = true ]; then
            echo -e "${BLUE}Processing SVG file ${SVG_COUNT}/${SVG_FILES_TOTAL}: ${svg_file}${NC}"
        fi
        
        if optimize_svg "$svg_file"; then
            ((SVG_OPTIMIZED++))
        fi
    done < <(find "$DIRECTORY" -type f -name "*.svg")
else
    # SVG to PNG conversion
    echo -e "\n${BLUE}Converting SVG files to PNG...${NC}"
    
    # If simplify is true, optimize SVGs first for better compatibility
    if [ "$SIMPLIFY" = true ]; then
        echo -e "\n${BLUE}First optimizing SVGs for better GitHub compatibility...${NC}"
        
        while IFS= read -r svg_file; do
            ((SVG_COUNT++))
            if [ "$VERBOSE" = true ]; then
                echo -e "${BLUE}Preparing SVG file ${SVG_COUNT}/${SVG_FILES_TOTAL}: ${svg_file}${NC}"
            fi
            
            if optimize_svg "$svg_file"; then
                ((SVG_OPTIMIZED++))
            fi
        done < <(find "$DIRECTORY" -type f -name "*.svg")
        
        echo -e "\n${GREEN}SVG optimization complete: ${SVG_OPTIMIZED}/${SVG_COUNT} files optimized${NC}"
        
        # Reset counters for conversion pass
        SVG_COUNT=0
        SVG_OPTIMIZED=0
    fi
    
    # Now convert the SVGs to PNGs
    SVG_FILES_TOTAL=$(find "$DIRECTORY" -type f -name "*.svg" | wc -l)
    
    while IFS= read -r svg_file; do
        ((SVG_COUNT++))
        if [ "$VERBOSE" = true ]; then
            echo -e "${BLUE}Processing SVG file ${SVG_COUNT}/${SVG_FILES_TOTAL}: ${svg_file}${NC}"
        fi
        
        if convert_svg_to_png "$svg_file"; then
            ((SVG_OPTIMIZED++))  # Reusing counter for conversions
        fi
    done < <(find "$DIRECTORY" -type f -name "*.svg")
    
    echo -e "\n${GREEN}SVG to PNG conversion complete: ${SVG_OPTIMIZED}/${SVG_COUNT} files converted${NC}"
fi

# Only show this if we're not in reverse mode and we're optimizing SVGs
if [ "$REVERSE" = false ]; then
    echo -e "\n${GREEN}SVG optimization complete: ${SVG_OPTIMIZED}/${SVG_COUNT} files optimized${NC}"
fi

# Summary - customize based on what operation was performed
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${BLUE}                       Summary                              ${NC}"
echo -e "${BLUE}============================================================${NC}"

if [ "$REVERSE" = false ]; then
    echo -e "${GREEN}PNG files found:       ${PNG_COUNT}${NC}"
    echo -e "${GREEN}PNG files converted:   ${PNG_CONVERTED}${NC}"
    echo -e "${GREEN}SVG files found:       ${SVG_COUNT}${NC}"
    echo -e "${GREEN}SVG files optimized:   ${SVG_OPTIMIZED}${NC}"
else
    echo -e "${GREEN}SVG files found:       ${SVG_COUNT}${NC}"
    echo -e "${GREEN}SVG files converted to PNG: ${SVG_OPTIMIZED}${NC}"
    if [ "$SIMPLIFY" = true ]; then
        echo -e "${GREEN}SVG files optimized for GitHub: Yes${NC}"
    fi
fi

echo -e "${BLUE}============================================================${NC}"

echo -e "\n${GREEN}Image processing complete!${NC}"
exit 0 