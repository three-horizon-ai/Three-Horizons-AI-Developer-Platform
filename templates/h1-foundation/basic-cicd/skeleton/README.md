# Basic CI/CD Pipeline - ${{ values.name }}

## Overview
This template creates a basic CI/CD pipeline for Horizon 1 foundation applications using GitHub Actions and Azure deployment.

## Features
- **Build Tool**: ${{ values.buildTool }}
- **Node.js Version**: ${{ values.nodeVersion }}
- **Deployment Target**: ${{ values.deploymentTarget }}
- **Environment**: ${{ values.environment }}
- **Testing**: ${{ values.enableTesting }}
- **Security Scanning**: ${{ values.enableSecurity }}
- **Rollback**: ${{ values.enableRollback }}

## Azure Configuration
- **Subscription**: ${{ values.azureSubscription }}
- **Location**: ${{ values.azureLocation }}
- **Resource Group**: ${{ values.resourceGroup }}

## Required Secrets
Configure the following secrets in your GitHub repository:

1. **AZURE_CREDENTIALS**: Azure service principal credentials
2. **AZURE_STATIC_WEB_APPS_API_TOKEN**: For static web apps deployment (if applicable)

## Setup Instructions
1. Configure GitHub repository secrets
2. Update Azure resource names in the workflow file
3. Customize build and deployment scripts as needed
4. Test the pipeline with a sample commit

## Deployment Targets
- **App Service**: Traditional web applications
- **Container Apps**: Containerized applications
- **Static Web Apps**: Frontend applications
- **AKS**: Kubernetes deployments
- **Functions**: Serverless functions

## Next Steps
1. Add environment-specific configurations
2. Implement advanced deployment strategies
3. Add monitoring and alerting
4. Configure security policies
