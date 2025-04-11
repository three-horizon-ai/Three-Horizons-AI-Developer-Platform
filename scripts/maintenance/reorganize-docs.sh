#!/bin/bash

# Script to reorganize the documentation structure
# This script moves redundant documentation to the appendices directory and 
# establishes a clearer documentation structure focused on the complete integration tutorial.

echo "Starting documentation reorganization..."

# Create additional documentation directory in appendices if it doesn't exist
mkdir -p docs/documentation/appendices/additional-documentation

# Move redundant READMEs and documents to appendices/additional-documentation
echo "Moving redundant documents to appendices/additional-documentation..."

# Create a list of files to move (leaving only essential documents in their original location)
FILES_TO_MOVE=(
  "docs/1-architecture/README.md"
  "docs/2-implementation-guide/README.md"
  "docs/3-developer-guide/README.md"
  "docs/4-operations-guide/README.md"
  "docs/5-reference/README.md"
  "docs/6-appendices/README.md"
  "docs/getting-started/README.md"
)

# Copy files to appendices/additional-documentation
for file in "${FILES_TO_MOVE[@]}"; do
  if [ -f "$file" ]; then
    # Create target directory in appendices preserving structure
    target_dir="docs/documentation/appendices/additional-documentation/$(dirname "$file" | sed 's|^docs/||')"
    mkdir -p "$target_dir"
    
    # Copy the file
    cp "$file" "docs/documentation/appendices/additional-documentation/$(echo "$file" | sed 's|^docs/||')"
    echo "Copied $file to appendices/additional-documentation"
  else
    echo "Warning: File $file not found"
  fi
done

# Create README in appendices/additional-documentation
cat > docs/documentation/appendices/additional-documentation/README.md << 'EOF'
---
title: "Additional Documentation"
description: "Archive of additional documentation that complements the main Three Horizons Platform documentation"
position_in_journey: "6.9 Appendices"
previous_doc: "../index.md"
next_doc: "../../index.md"
last_updated: "April 2025"
---

# <span style="color: #0366d6;">📚 Additional Documentation</span>

**Navigation:** [Home](../../../../README.md) > [Documentation Map](../../../DOCUMENTATION_MAP.md) > [Appendices](../index.md) > Additional Documentation

## <span style="color: #0366d6;">🔍 Overview</span>

This section contains additional documentation that complements the main Three Horizons Platform documentation. While not essential for following the [Complete Integration Tutorial](../complete-integration/index.md), these documents provide additional context, background information, and alternative implementation approaches.

## <span style="color: #0366d6;">📋 Contents</span>

### <span style="color: #0366d6;">Architecture</span>
- [Architecture Guide](1-architecture/README.md) - Alternative architecture documentation

### <span style="color: #0366d6;">Implementation</span>
- [Implementation Guide](2-implementation-guide/README.md) - Alternative implementation approaches

### <span style="color: #0366d6;">Development</span>
- [Developer Guide](3-developer-guide/README.md) - Additional developer resources

### <span style="color: #0366d6;">Operations</span>
- [Operations Guide](4-operations-guide/README.md) - Additional operations documentation

### <span style="color: #0366d6;">Reference</span>
- [Reference Guide](5-reference/README.md) - Reference materials

### <span style="color: #0366d6;">Getting Started</span>
- [Getting Started Guide](getting-started/README.md) - Alternative getting started information

## <span style="color: #0366d6;">🔗 Primary Documentation</span>

For the main, streamlined documentation path, please refer to:

- [Main README](../../../../README.md) - Platform overview and quick start
- [Complete Integration Tutorial](../../../complete-integration-tutorial/index.md) - Step-by-step implementation guide
- [Documentation Map](../../../DOCUMENTATION_MAP.md) - Complete documentation navigation

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../../../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
EOF

echo "Created README for additional documentation"

# Update index.md in documentation/appendices to link to additional-documentation
echo "Updating appendices index.md..."

# Search for the additional resources section in the appendices index.md and add link
if grep -q "## <span style=\"color: #0366d6;\">📚 Additional Resources</span>" docs/documentation/appendices/index.md; then
  # Add the link if the section exists
  sed -i '' -e '/## <span style="color: #0366d6;">📚 Additional Resources<\/span>/a\\
- [Additional Documentation](additional-documentation/) - Archive of complementary documents and guides\\
' docs/documentation/appendices/index.md
  echo "Added additional documentation link to appendices index.md"
else
  echo "Warning: Couldn't find additional resources section in appendices index.md"
fi

# Update Documentation Map to emphasize the complete integration tutorial
echo "Updating Documentation Map..."

# Create a backup of the current documentation map
cp docs/DOCUMENTATION_MAP.md docs/DOCUMENTATION_MAP.md.bak

cat > docs/DOCUMENTATION_MAP.md << 'EOF'
---
title: Documentation Map
description: Navigate the Three Horizons Platform documentation structure
position_in_journey: 5
previous_doc: /README.md
next_doc: /docs/complete-integration-tutorial/index.md
last_updated: 2025-04-10
---

# <span style="color: #0366d6;">📋 Your Documentation Journey Map</span>

**Navigation:** [Home](../README.md) > Documentation Map

## <span style="color: #0366d6;">🔄 Your Documentation Journey</span>

Welcome to the Three Horizons Platform documentation. This map will help you navigate through our documentation structure, with a focus on the complete integration tutorial that provides a comprehensive, step-by-step guide to implementing the platform.

## <span style="color: #0366d6;">📚 Core Documentation</span>

### <span style="color: #0366d6;">Essential Guides</span>

- [**Complete Integration Tutorial**](complete-integration-tutorial/index.md) - Comprehensive step-by-step implementation guide (RECOMMENDED STARTING POINT)
- [README](../README.md) - Platform overview and quick start

### <span style="color: #0366d6;">Architecture Documentation</span>

- [Architecture Overview](documentation/architecture/index.md) - Platform architecture and design
- [Three Horizons Architecture](documentation/architecture/three-horizons-architecture.svg) - Complete architectural overview
- [Developer Hub Architecture](documentation/architecture/developer-hub-architecture.svg) - Developer Hub components
- [Security Architecture](documentation/architecture/security-architecture.svg) - Security framework
- [Network Architecture](documentation/architecture/network-diagram.svg) - Network topology

### <span style="color: #0366d6;">Implementation Patterns</span>

- [Web Application (Standard)](documentation/architecture/web-application-standard.svg) - Standard web app pattern
- [Microservices Architecture](documentation/architecture/web-application-microservices.svg) - Microservices pattern
- [Serverless Architecture](documentation/architecture/web-application-serverless.svg) - Serverless pattern
- [CI/CD Pipeline](documentation/architecture/cicd-pipeline.svg) - DevOps workflow

### <span style="color: #0366d6;">Operations Documentation</span>

- [Operations Guide](documentation/operations/index.md) - Platform operations
- [Monitoring](documentation/operations/monitoring.md) - Observability setup
- [Change Management](documentation/operations/change-management.md) - Managing platform changes

## <span style="color: #0366d6;">📚 Developer Resources</span>

### <span style="color: #0366d6;">Developer Experience</span>

- [Developer Guide](documentation/developer/README.md) - Guide for developers
- [Golden Paths](documentation/developer/golden-paths.md) - Standardized development workflows
- [Custom Templates](documentation/developer/custom-templates.md) - Creating custom templates

### <span style="color: #0366d6;">Example Implementation Resources</span>

- [Example Applications](../examples/applications/) - Reference implementations
- [Example Configurations](../examples/configurations/) - Configuration examples
- [Pipeline Examples](../examples/pipelines/) - CI/CD pipeline examples

## <span style="color: #0366d6;">📚 Additional Resources</span>

- [Appendices](documentation/appendices/index.md) - Supplementary documentation
- [Additional Documentation](documentation/appendices/additional-documentation/) - Archive of complementary documents
- [Reference Documentation](documentation/reference/) - Technical references
- [Glossary](GLOSSARY.md) - Terminology definitions

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Your Documentation Journey Map v2.0</p>
</footer>
EOF

echo "Updated Documentation Map"

echo "Documentation reorganization complete!"
echo "The main documentation path now focuses on the Complete Integration Tutorial, with redundant documents moved to the appendices."