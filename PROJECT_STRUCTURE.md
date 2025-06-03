# Project Structure

## Overview

The Three Horizons Platform project follows a clean, organized structure where the root directory contains only essential files, with all other resources organized into appropriate subdirectories.

## Root Directory Contents

The following files should remain in the root directory:

- **README.md** - Main project documentation and entry point
- **LICENSE** - MIT license for the project
- **CHANGELOG.md** - Project change history
- **PROJECT_STRUCTURE.md** - This file
- **package.json** & **package-lock.json** - Node.js project configuration and dependencies
- **.gitignore** - Git ignore configuration
- **.git/** - Git repository data (hidden)
- **.github/** - GitHub-specific configurations (workflows, templates, etc.)

## Directory Organization

### `/assets/`
Contains all project assets including images, icons, and diagrams
- `/images/` - Project images and diagrams
- `/icons/` - Icon files and logos

### `/docs/`
Comprehensive documentation structure
- `/playbook/` - Main playbook content organized by horizons
- `/complete-integration-tutorial/` - Step-by-step implementation guide
- `/documentation/` - Technical documentation and guides
- `/resources/` - Additional resources (PDFs, reference materials)
- Architecture, implementation, developer, and operations guides

### `/examples/`
Working examples and sample configurations
- `/applications/` - Sample applications (React, TypeScript, etc.)
- `/configurations/` - Configuration examples
  - `/rhdh/` - Red Hat Developer Hub configuration files
  - `/aks-cluster/` - Azure Kubernetes Service configurations
- `/pipelines/` - CI/CD pipeline examples

### `/templates/`
Reusable templates for various components
- `/applications/` - Application templates
- `/arm/` - Azure Resource Manager templates
- `/azure/` - Azure-specific templates (AKS, ARO)
- `/infrastructure/` - Infrastructure as Code templates

### `/scripts/`
Automation and utility scripts
- `/setup/` - Initial setup scripts
- `/maintenance/` - Maintenance and cleanup scripts
- `/utilities/` - General utility scripts
- `/validation/` - Validation and testing scripts

## Organization Principles

1. **Root Cleanliness**: Keep only essential project files in root
2. **Logical Grouping**: Group related files by function or purpose
3. **Clear Naming**: Use descriptive names for directories and files
4. **Documentation**: Each major directory should have its own README
5. **Examples Separate**: Keep examples and configurations separate from core documentation
6. **Templates Reusable**: Templates should be generic and reusable

## Finding Resources

- **RHDH/Backstage Configurations**: `examples/configurations/rhdh/`
- **Implementation Guides**: `docs/complete-integration-tutorial/`
- **Architecture Diagrams**: `assets/images/`
- **CI/CD Examples**: `examples/pipelines/`
- **Application Templates**: `templates/applications/`
- **Azure Resources**: `templates/azure/` and `templates/arm/` 