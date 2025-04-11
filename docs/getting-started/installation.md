---
title: "Installation Guide"
description: "Step-by-step instructions to install the Three Horizons Platform"
position_in_journey: "2. Installation"
previous_doc: "../getting-started/README.md"
next_doc: "../2-implementation-guide/README.md"
last_updated: "April 10, 2025"
---

# <span style="color: #0366d6;">🏗️ Your Installation Journey</span>

**Navigation:** [Home](../../README.md) > [Getting Started](README.md) > Installation

Welcome to your Three Horizons Platform installation journey! This guide walks you through the complete process of deploying the platform in your environment. By following these structured steps, you'll establish the foundation for your organization's developer experience transformation.

## Prerequisites

Before you begin, ensure you have:

- An Azure subscription with Owner or Contributor access
- A GitHub Enterprise account or GitHub organization with admin access
- GitHub Copilot subscription for your organization
- Admin access to a domain name (for configuring DNS)
- A workstation with the following tools installed:
  - Azure CLI (latest version)
  - Git (latest version)
  - kubectl (latest version)
  - Helm v3 (latest version)
  - OpenShift CLI (if using ARO)
  - VS Code or JetBrains IDE with GitHub Copilot extension

## Installation Options

The Three Horizons Platform offers three primary installation options:

| Installation Option | Description | Recommended For |
|---------------------|-------------|----------------|
| **Basic** | Core components with minimal configuration | Evaluation, small teams |
| **Standard** | Complete platform with default configuration | Most organizations |
| **Enterprise** | Full platform with high availability and advanced security | Large enterprises with strict requirements |

This guide covers the Standard installation. For other options, see the [Implementation Guide](../2-implementation-guide/README.md) for customized deployment scenarios.

## Step 1: Prepare Your Environment

First, log in to Azure and set up your environment:

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "Your-Subscription-ID"

# Create a resource group
az group create --name three-horizons-rg --location eastus

# Register required resource providers
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.OperationalInsights
```

## Step 2: Choose Your Infrastructure Platform

### Option A: Azure Kubernetes Service (AKS)

```bash
# Create AKS cluster
az aks create \
  --resource-group three-horizons-rg \
  --name three-horizons-aks \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get AKS credentials
az aks get-credentials \
  --resource-group three-horizons-rg \
  --name three-horizons-aks
```

### Option B: Azure Red Hat OpenShift (ARO)

```bash
# Create ARO cluster
az aro create \
  --resource-group three-horizons-rg \
  --name three-horizons-aro \
  --vnet-name aro-vnet \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet

# Get ARO credentials
az aro list-credentials \
  --resource-group three-horizons-rg \
  --name three-horizons-aro
```

## Step 3: Deploy Red Hat Developer Hub

### For AKS:

```bash
# Install Red Hat Developer Hub Operator
kubectl create namespace developer-hub

# Add Helm repository for Developer Hub
helm repo add developer-hub https://charts.example.com/developer-hub
helm repo update

# Install Developer Hub
helm install developer-hub developer-hub/developer-hub \
  --namespace developer-hub \
  --set global.domain=devhub.yourdomain.com
```

### For ARO:

```bash
# Login to OpenShift
oc login --token=<token> --server=<server>

# Create project for Developer Hub
oc new-project developer-hub

# Install Developer Hub Operator
oc apply -f https://example.com/developer-hub-operator.yaml
```

## Step 4: Configure Azure AD Integration

```bash
# Register an application in Azure AD
az ad app create \
  --display-name "Three Horizons Platform" \
  --web-redirect-uris "https://devhub.yourdomain.com/oauth/callback" \
  --identifier-uris "https://devhub.yourdomain.com" \
  --app-roles @app-roles.json

# Create service principal
az ad sp create --id <application-id>

# Assign permissions
az role assignment create \
  --assignee <service-principal-id> \
  --role "Contributor" \
  --scope /subscriptions/<subscription-id>/resourceGroups/three-horizons-rg
```

## Step 5: Configure GitHub Copilot Integration

Enhance your platform with AI-assisted development capabilities through GitHub Copilot integration.

### Enable GitHub Copilot for Your Organization

1. As a GitHub organization admin, navigate to your organization settings
2. Go to GitHub Copilot settings
3. Enable GitHub Copilot for your organization
4. Assign GitHub Copilot seats to your development team members

### Set Up GitHub Copilot for CI/CD

```bash
# Create a service principal for GitHub Actions integration
az ad sp create-for-rbac --name "github-copilot-cicd" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/three-horizons-rg \
  --sdk-auth

# Add the JSON output as a GitHub secret named AZURE_CREDENTIALS
# in your GitHub repository settings
```

### Configure GitHub Copilot in Developer Environments

Ensure all developers install the GitHub Copilot extension in their IDEs:

- **VS Code**: Search for "GitHub Copilot" in the extensions marketplace
- **JetBrains IDEs**: Install via Settings > Plugins > Marketplace

For detailed configuration and usage guidance, see the [GitHub Copilot Integration Guide](github-copilot-integration.md).

## Step 6: Configure GitHub Integration

```bash
# Create GitHub App
# Follow the instructions at: https://docs.github.com/en/developers/apps/creating-a-github-app

# Install the GitHub App in your organization

# Create Kubernetes secret for GitHub integration
kubectl create secret generic github-app-credentials \
  --namespace developer-hub \
  --from-literal=app-id=<your-github-app-id> \
  --from-literal=private-key="<your-github-app-private-key>"

# Configure Developer Hub to use GitHub integration
kubectl apply -f github-integration.yaml
```

## Step 7: Configure DNS and TLS

Secure your platform with proper DNS configuration and TLS certificates:

```bash
# Get load balancer IP/hostname
HOSTNAME=$(kubectl get svc -n developer-hub developer-hub-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Update your DNS records to point to this IP

# Install cert-manager for TLS
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.0/cert-manager.yaml

# Create certificate for Developer Hub
kubectl apply -f devhub-certificate.yaml
```

## Step 8: Verification

After installation, verify that all components are running correctly:

```bash
# Check pod status
kubectl get pods -n developer-hub

# Check web access
# Open https://devhub.yourdomain.com in your browser

# Test authentication
# Try logging in with your Azure AD credentials

# Verify GitHub integration
# Check that repositories are available in Developer Hub
```

## Finalize Your Installation

Complete your installation by following these configuration steps:

1. Log in to the Developer Hub web interface
2. Navigate to **Settings** > **General**
3. Configure the basic settings:
   - Organization name
   - Theme and branding
   - Default user role
4. Configure Golden Paths under **Settings** > **Scaffolder**
5. Set up your catalog under **Settings** > **Catalog**

## Continue Your Journey

Now that you've successfully installed the Three Horizons Platform, continue your journey with these next steps:

- [Configure Golden Paths](../documentation/developer/golden-paths.md) - Create standardized development workflows
- [Set Up CI/CD Pipelines](../documentation/guides/ci-cd-integration.md) - Implement automated delivery
- [Configure Monitoring](../documentation/operations/monitoring.md) - Establish observability
- [Create Custom Templates](../documentation/developer/custom-templates.md) - Customize for your organization

For additional implementation guidance, proceed to the [Implementation Guide](../2-implementation-guide/README.md).

## Troubleshooting Your Installation

If you encounter challenges during your installation journey:

- Check the [Troubleshooting Guide](../documentation/developer/troubleshooting.md)
- Ensure all prerequisites are met
- Verify connectivity between components
- Check pod logs for specific error messages

## Related Topics

- [GitHub Copilot Integration](github-copilot-integration.md) - Optimize development with AI assistance
- [Architecture Overview](../documentation/architecture/index.md) - Understand the platform architecture
- [OpenShift Configuration](../2-implementation-guide/README.md) - Advanced OpenShift configuration
- [Security Best Practices](../5-reference/README.md) - Security recommendations

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>