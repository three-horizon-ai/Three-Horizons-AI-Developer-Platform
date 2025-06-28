# 🐙 H1-004: GitHub Enterprise Setup - Complete Configuration Guide

<div align="center">

**Configuring GitHub Enterprise for AI-Powered Development**

</div>

## 📋 Table of Contents

1. [Overview](#-overview)
2. [GitHub Organization Setup](#-github-organization-setup)
3. [Repository Structure](#-repository-structure)
4. [Team Management](#-team-management)
5. [GitHub Actions Configuration](#-github-actions-configuration)
6. [Security Settings](#-security-settings)
7. [Integration Configuration](#-integration-configuration)
8. [Webhook Setup](#-webhook-setup)
9. [GitHub Apps Creation](#-github-apps-creation)
10. [Validation & Testing](#-validation--testing)

## 🔍 Overview

GitHub Enterprise serves as the central source control and collaboration platform for the Three Horizons AI Platform. This guide covers the complete setup including organization structure, security configuration, CI/CD workflows, and integration with other platform components.

### Key Features We'll Configure

| Feature | Purpose | Horizon |
|---------|---------|---------|
| **Organization Structure** | Logical repository grouping | H1 |
| **GitHub Actions** | CI/CD automation | H1 |
| **GitHub Advanced Security** | Shift-left security scanning | H1 |
| **Codespaces** | Cloud development environments | H1 |
| **GitHub Copilot Enterprise** | AI-powered development | H2 |
| **GitHub Apps** | Platform integrations | H1 |
| **Webhooks** | Real-time event handling | H1 |

## 🏢 GitHub Organization Setup

### 1. Create Organization Structure

```bash
# Using GitHub CLI
gh auth login

# Set organization name
export GITHUB_ORG="threehorizons-ai"
export GITHUB_ADMIN_TOKEN="ghp_xxxxxxxxxxxx"  # Your PAT with admin:org scope

# Create organization (if using GitHub Enterprise Cloud)
curl -X POST \
  -H "Authorization: token $GITHUB_ADMIN_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/orgs \
  -d '{
    "login": "'$GITHUB_ORG'",
    "admin": "platform-admin",
    "profile_name": "Three Horizons AI Platform",
    "billing_email": "billing@threehorizon.ai",
    "description": "Enterprise AI-Powered Development Platform",
    "has_organization_projects": true,
    "has_repository_projects": true,
    "default_repository_permission": "read",
    "members_can_create_repositories": false,
    "members_can_create_public_repositories": false,
    "members_can_create_private_repositories": true,
    "members_can_create_internal_repositories": true
  }'
```

### 2. Configure Organization Settings

```bash
# Configure organization settings
gh api -X PATCH /orgs/$GITHUB_ORG \
  -F company="Three Horizons AI" \
  -F location="Global" \
  -F email="admin@threehorizon.ai" \
  -F twitter_username="threehorizonsai" \
  -F has_organization_projects=true \
  -F has_repository_projects=true \
  -F default_repository_permission="read" \
  -F members_can_create_repositories=false \
  -F members_can_create_public_repositories=false \
  -F members_can_create_private_repositories=true \
  -F members_can_create_internal_repositories=true \
  -F members_can_create_pages=true \
  -F members_can_fork_private_repositories=false \
  -F web_commit_signoff_required=true

# Enable features
gh api -X PATCH /orgs/$GITHUB_ORG \
  -F advanced_security_enabled=true \
  -F dependency_graph_enabled=true \
  -F dependabot_alerts_enabled=true \
  -F dependabot_security_updates_enabled=true \
  -F secret_scanning_enabled=true \
  -F secret_scanning_push_protection_enabled=true
```

### 3. Organization Security Policies

```yaml
# .github/security-policy.yml
name: Organization Security Policy
version: 1.0

policies:
  authentication:
    require_two_factor: true
    session_timeout: 8_hours
    
  access_control:
    default_permission: read
    admin_enforcement: true
    
  code_security:
    dependency_scanning: required
    secret_scanning: required
    code_scanning: required
    security_updates: automatic
    
  compliance:
    signed_commits: recommended
    protected_branches: enforced
    audit_log_retention: 180_days
```

## 📁 Repository Structure

### 1. Create Core Repositories

```bash
# Platform Infrastructure Repository
gh repo create $GITHUB_ORG/platform-infrastructure \
  --private \
  --description "Core infrastructure as code for Three Horizons Platform" \
  --add-readme \
  --license mit \
  --gitignore Terraform

# Developer Hub Configuration
gh repo create $GITHUB_ORG/developer-hub-config \
  --private \
  --description "Red Hat Developer Hub configuration and customization" \
  --add-readme \
  --license mit

# Application Templates
gh repo create $GITHUB_ORG/application-templates \
  --internal \
  --description "Golden Path templates for application scaffolding" \
  --add-readme \
  --license mit

# CI/CD Workflows
gh repo create $GITHUB_ORG/cicd-workflows \
  --internal \
  --description "Reusable GitHub Actions workflows" \
  --add-readme \
  --license mit

# Security Policies
gh repo create $GITHUB_ORG/security-policies \
  --private \
  --description "Security policies and compliance configurations" \
  --add-readme \
  --license mit

# Documentation
gh repo create $GITHUB_ORG/platform-documentation \
  --public \
  --description "Public documentation for Three Horizons Platform" \
  --add-readme \
  --license mit
```

### 2. Repository Templates Structure

```bash
# Clone and set up application templates repository
git clone https://github.com/$GITHUB_ORG/application-templates.git
cd application-templates

# Create template structure
mkdir -p templates/{microservice,api,frontend,fullstack,ai-model}

# Create base template configuration
cat > templates/template-config.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: three-horizons-base-template
  title: Base Application Template
  description: Standard template with security, monitoring, and CI/CD
  tags:
    - recommended
    - kubernetes
    - github-actions
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Application Details
      required:
        - name
        - description
        - owner
      properties:
        name:
          title: Name
          type: string
          pattern: '^[a-z0-9-]+$'
        description:
          title: Description
          type: string
        owner:
          title: Owner
          type: string
          ui:field: OwnerPicker
    
    - title: Technology Stack
      required:
        - language
        - framework
      properties:
        language:
          title: Programming Language
          type: string
          enum:
            - java
            - python
            - nodejs
            - go
            - dotnet
        framework:
          title: Framework
          type: string
          
    - title: Infrastructure Options
      properties:
        kubernetes:
          title: Deploy to Kubernetes
          type: boolean
          default: true
        database:
          title: Database
          type: string
          enum:
            - none
            - postgresql
            - mysql
            - mongodb
            - redis
EOF

# Commit and push
git add .
git commit -m "Initial template structure"
git push origin main
```

### 3. Standard Repository Structure

```bash
# Create standard .github directory structure for all repos
cat > .github/CODEOWNERS << 'EOF'
# Platform Infrastructure
/infrastructure/ @threehorizons-ai/platform-team
/terraform/ @threehorizons-ai/platform-team
/bicep/ @threehorizons-ai/platform-team

# Security
/security/ @threehorizons-ai/security-team
/.github/workflows/security-*.yml @threehorizons-ai/security-team

# Applications
/src/ @threehorizons-ai/developers
/tests/ @threehorizons-ai/developers @threehorizons-ai/qa-team

# Documentation
/docs/ @threehorizons-ai/docs-team
*.md @threehorizons-ai/docs-team
EOF

# Create PR template
cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change
- [ ] Documentation update
- [ ] Infrastructure change

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Security scan complete
- [ ] Performance impact assessed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Security review if needed
- [ ] Breaking changes documented

## Related Issues
Fixes #(issue)
EOF

# Create issue templates
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'EOF'
name: Bug Report
description: File a bug report
title: "[Bug]: "
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  
  - type: textarea
    id: what-happened
    attributes:
      label: What happened?
      description: Clear and concise description of the bug
      placeholder: Tell us what you see!
    validations:
      required: true
  
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      description: How severe is this issue?
      options:
        - Critical
        - High
        - Medium
        - Low
    validations:
      required: true
EOF
```

## 👥 Team Management

### 1. Create Teams Structure

```bash
# Create teams
for team in platform-team developers security-team sre-team qa-team docs-team; do
  gh api -X POST /orgs/$GITHUB_ORG/teams \
    -F name="$team" \
    -F description="$(echo $team | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')" \
    -F privacy="closed" \
    -F notification_setting="notifications_enabled"
done

# Create nested teams for developers
gh api -X POST /orgs/$GITHUB_ORG/teams \
  -F name="frontend-developers" \
  -F description="Frontend Development Team" \
  -F privacy="closed" \
  -F parent_team_id=$(gh api /orgs/$GITHUB_ORG/teams/developers --jq '.id')

gh api -X POST /orgs/$GITHUB_ORG/teams \
  -F name="backend-developers" \
  -F description="Backend Development Team" \
  -F privacy="closed" \
  -F parent_team_id=$(gh api /orgs/$GITHUB_ORG/teams/developers --jq '.id')
```

### 2. Configure Team Permissions

```bash
# Platform Team - Admin access to infrastructure repos
gh api -X PUT /orgs/$GITHUB_ORG/teams/platform-team/repos/$GITHUB_ORG/platform-infrastructure \
  -F permission="admin"

gh api -X PUT /orgs/$GITHUB_ORG/teams/platform-team/repos/$GITHUB_ORG/developer-hub-config \
  -F permission="admin"

# Developers - Write access to application repos, read to infrastructure
gh api -X PUT /orgs/$GITHUB_ORG/teams/developers/repos/$GITHUB_ORG/application-templates \
  -F permission="write"

gh api -X PUT /orgs/$GITHUB_ORG/teams/developers/repos/$GITHUB_ORG/platform-infrastructure \
  -F permission="read"

# Security Team - Admin access to security repos
gh api -X PUT /orgs/$GITHUB_ORG/teams/security-team/repos/$GITHUB_ORG/security-policies \
  -F permission="admin"
```

### 3. Team Sync with Azure AD

```yaml
# .github/azure-ad-sync.yml
name: Azure AD Team Sync
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  sync-teams:
    runs-on: ubuntu-latest
    steps:
      - name: Sync Platform Team
        uses: github/team-sync@v1
        with:
          azure-ad-group: "ThreeHorizons-Platform-Admins"
          github-team: "platform-team"
          
      - name: Sync Developers
        uses: github/team-sync@v1
        with:
          azure-ad-group: "ThreeHorizons-Developers"
          github-team: "developers"
          
      - name: Sync Security Team
        uses: github/team-sync@v1
        with:
          azure-ad-group: "ThreeHorizons-Security"
          github-team: "security-team"
```

## ⚡ GitHub Actions Configuration

### 1. Enable GitHub Actions

```bash
# Enable Actions for organization
gh api -X PUT /orgs/$GITHUB_ORG/actions/permissions \
  -F enabled_repositories="all" \
  -F allowed_actions="all"

# Configure Actions settings
gh api -X PUT /orgs/$GITHUB_ORG/actions/permissions/workflow \
  -F default_workflow_permissions="read" \
  -F can_approve_pull_request_reviews=false
```

### 2. Create Reusable Workflows

```yaml
# .github/workflows/ci-base.yml
name: Base CI Workflow
on:
  workflow_call:
    inputs:
      language:
        required: true
        type: string
      run-tests:
        required: false
        type: boolean
        default: true
      run-security-scan:
        required: false
        type: boolean
        default: true
    secrets:
      SONAR_TOKEN:
        required: false
      SNYK_TOKEN:
        required: false

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
      
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Set up language environment
        uses: ./.github/actions/setup-${{ inputs.language }}
        
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: |
            ~/.npm
            ~/.cache/pip
            ~/.m2/repository
            ~/go/pkg/mod
          key: ${{ runner.os }}-${{ inputs.language }}-${{ hashFiles('**/package-lock.json', '**/requirements.txt', '**/pom.xml', '**/go.sum') }}
          
      - name: Install dependencies
        run: |
          case "${{ inputs.language }}" in
            node) npm ci ;;
            python) pip install -r requirements.txt ;;
            java) mvn install -DskipTests ;;
            go) go mod download ;;
          esac
          
      - name: Run tests
        if: inputs.run-tests
        run: |
          case "${{ inputs.language }}" in
            node) npm test ;;
            python) pytest ;;
            java) mvn test ;;
            go) go test ./... ;;
          esac
          
      - name: Security scanning
        if: inputs.run-security-scan
        uses: ./.github/workflows/security-scan.yml
        with:
          language: ${{ inputs.language }}
```

### 3. Create CI/CD Pipeline Templates

```yaml
# .github/workflows/deploy-to-aks.yml
name: Deploy to AKS
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
      
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          
      - name: Set AKS Context
        uses: azure/aks-set-context@v3
        with:
          resource-group: rg-threehorizons-${{ inputs.environment }}-compute
          cluster-name: aks-threehorizons-${{ inputs.environment }}
          
      - name: Create namespace if not exists
        run: |
          kubectl create namespace ${{ inputs.environment }} --dry-run=client -o yaml | kubectl apply -f -
          
      - name: Deploy to AKS
        run: |
          kubectl set image deployment/${{ github.event.repository.name }} \
            ${{ github.event.repository.name }}=acr${{ vars.ACR_NAME }}.azurecr.io/${{ github.event.repository.name }}:${{ inputs.image-tag }} \
            -n ${{ inputs.environment }}
            
      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/${{ github.event.repository.name }} -n ${{ inputs.environment }}
          
      - name: Run smoke tests
        run: |
          kubectl run smoke-test \
            --image=curlimages/curl:latest \
            --rm \
            --attach \
            --restart=Never \
            -- curl -f http://${{ github.event.repository.name }}.${{ inputs.environment }}.svc.cluster.local/health
```

### 4. Configure Self-Hosted Runners

```bash
# Create runner group for AKS
gh api -X POST /orgs/$GITHUB_ORG/actions/runner-groups \
  -F name="aks-runners" \
  -F visibility="all" \
  -F allows_public_repositories=false

# Deploy runner controller to AKS
kubectl create namespace actions-runner-system

helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update

helm install arc actions-runner-controller/actions-runner-controller \
  --namespace actions-runner-system \
  --set authSecret.github_token=$GITHUB_ADMIN_TOKEN \
  --set image.actionsRunnerRepositoryAndTag="summerwind/actions-runner:latest" \
  --set githubWebhookServer.enabled=true

# Create runner deployment
cat <<EOF | kubectl apply -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: threehorizons-runner
  namespace: actions-runner-system
spec:
  replicas: 3
  template:
    spec:
      organization: $GITHUB_ORG
      labels:
        - self-hosted
        - linux
        - x64
        - aks
      resources:
        requests:
          cpu: "1"
          memory: "2Gi"
        limits:
          cpu: "2"
          memory: "4Gi"
EOF
```

## 🔒 Security Settings

### 1. Configure Branch Protection

```bash
# Function to configure branch protection
configure_branch_protection() {
  local repo=$1
  local branch=${2:-main}
  
  gh api -X PUT /repos/$GITHUB_ORG/$repo/branches/$branch/protection \
    -F required_status_checks='{"strict":true,"contexts":["continuous-integration","security-scan","code-review"]}' \
    -F enforce_admins=true \
    -F required_pull_request_reviews='{
      "required_approving_review_count":2,
      "dismiss_stale_reviews":true,
      "require_code_owner_reviews":true,
      "require_last_push_approval":true
    }' \
    -F restrictions='{"users":[],"teams":["platform-team"]}' \
    -F required_linear_history=true \
    -F allow_force_pushes=false \
    -F allow_deletions=false \
    -F required_conversation_resolution=true \
    -F lock_branch=false \
    -F allow_fork_syncing=false
}

# Apply to all repositories
for repo in platform-infrastructure developer-hub-config application-templates security-policies; do
  configure_branch_protection $repo main
done
```

### 2. Enable Security Features

```bash
# Enable Dependabot
for repo in platform-infrastructure developer-hub-config application-templates; do
  # Create .github/dependabot.yml
  gh api -X PUT /repos/$GITHUB_ORG/$repo/contents/.github/dependabot.yml \
    -F message="Enable Dependabot" \
    -F content="$(echo 'version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
      
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      
  - package-ecosystem: "terraform"
    directory: "/"
    schedule:
      interval: "weekly"' | base64)"
      
  # Enable security scanning
  gh api -X PUT /repos/$GITHUB_ORG/$repo/vulnerability-alerts -F enabled=true
  gh api -X PUT /repos/$GITHUB_ORG/$repo/automated-security-fixes -F enabled=true
done
```

### 3. Configure Code Scanning

```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '30 5 * * 1'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python', 'java', 'go' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
        queries: security-extended,security-and-quality

    - name: Autobuild
      uses: github/codeql-action/autobuild@v3

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{matrix.language}}"
```

## 🔗 Integration Configuration

### 1. Create Service Account

```bash
# Create machine user for integrations
gh api -X POST /orgs/$GITHUB_ORG/members \
  -F role="member" \
  -F user="threehorizons-bot"

# Generate personal access token for bot
# Note: This must be done through the UI or using the device flow
echo "Visit: https://github.com/settings/tokens/new"
echo "Scopes needed: repo, workflow, read:org, write:packages"
```

### 2. Configure Azure Integration

```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac \
  --name "github-actions-$GITHUB_ORG" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth > github-azure-credentials.json

# Store as organization secret
gh secret set AZURE_CREDENTIALS \
  --org $GITHUB_ORG \
  --body "$(cat github-azure-credentials.json)"

# Store individual values
AZURE_CLIENT_ID=$(jq -r .clientId github-azure-credentials.json)
AZURE_CLIENT_SECRET=$(jq -r .clientSecret github-azure-credentials.json)
AZURE_TENANT_ID=$(jq -r .tenantId github-azure-credentials.json)
AZURE_SUBSCRIPTION_ID=$(jq -r .subscriptionId github-azure-credentials.json)

gh secret set AZURE_CLIENT_ID --org $GITHUB_ORG --body "$AZURE_CLIENT_ID"
gh secret set AZURE_CLIENT_SECRET --org $GITHUB_ORG --body "$AZURE_CLIENT_SECRET"
gh secret set AZURE_TENANT_ID --org $GITHUB_ORG --body "$AZURE_TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID --org $GITHUB_ORG --body "$AZURE_SUBSCRIPTION_ID"

# Clean up
rm github-azure-credentials.json
```

### 3. Configure Container Registry Access

```bash
# Get ACR credentials
ACR_NAME="acrthreehorizons${ENVIRONMENT}"
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Store as secrets
gh secret set REGISTRY_URL --org $GITHUB_ORG --body "$ACR_NAME.azurecr.io"
gh secret set REGISTRY_USERNAME --org $GITHUB_ORG --body "$ACR_USERNAME"
gh secret set REGISTRY_PASSWORD --org $GITHUB_ORG --body "$ACR_PASSWORD"
```

## 🔔 Webhook Setup

### 1. Configure Organization Webhooks

```bash
# Create webhook for Developer Hub
WEBHOOK_SECRET=$(openssl rand -hex 32)

gh api -X POST /orgs/$GITHUB_ORG/hooks \
  -F name="web" \
  -F active=true \
  -F events='["push","pull_request","issues","issue_comment","deployment","deployment_status","release","package","repository"]' \
  -F config='{
    "url": "https://devhub.threehorizons.ai/api/github/webhook",
    "content_type": "json",
    "secret": "'$WEBHOOK_SECRET'",
    "insecure_ssl": "0"
  }'

# Store webhook secret in Key Vault
az keyvault secret set \
  --vault-name "kv-threehorizons-$ENVIRONMENT" \
  --name "github-webhook-secret" \
  --value "$WEBHOOK_SECRET"
```

### 2. Configure Webhook for Monitoring

```bash
# Create webhook for monitoring events
gh api -X POST /orgs/$GITHUB_ORG/hooks \
  -F name="web" \
  -F active=true \
  -F events='["workflow_run","check_run","check_suite","status"]' \
  -F config='{
    "url": "https://monitor.threehorizons.ai/api/github/events",
    "content_type": "json",
    "secret": "'$WEBHOOK_SECRET'",
    "insecure_ssl": "0"
  }'
```

## 📱 GitHub Apps Creation

### 1. Create Developer Hub Integration App

```bash
# Generate private key
openssl genrsa -out devhub-app.pem 2048

# Create app manifest
cat > devhub-app-manifest.json << EOF
{
  "name": "Three Horizons Developer Hub",
  "description": "Integration between GitHub and Red Hat Developer Hub",
  "url": "https://devhub.threehorizons.ai",
  "hook_attributes": {
    "url": "https://devhub.threehorizons.ai/api/github/app-webhook"
  },
  "redirect_url": "https://devhub.threehorizons.ai/auth/github/callback",
  "public": false,
  "default_permissions": {
    "metadata": "read",
    "contents": "read",
    "issues": "write",
    "pull_requests": "write",
    "actions": "read",
    "packages": "read",
    "repository_projects": "read",
    "organization_projects": "read",
    "team_discussions": "read"
  },
  "default_events": [
    "push",
    "pull_request",
    "issues",
    "issue_comment",
    "repository"
  ]
}
EOF

echo "Visit: https://github.com/organizations/$GITHUB_ORG/settings/apps/new"
echo "Upload the manifest and private key"
```

### 2. Create CI/CD Bot App

```bash
# Create CI/CD automation app
cat > cicd-bot-manifest.json << EOF
{
  "name": "Three Horizons CI/CD Bot",
  "description": "Automated CI/CD operations",
  "url": "https://cicd.threehorizons.ai",
  "public": false,
  "default_permissions": {
    "actions": "write",
    "checks": "write",
    "contents": "write",
    "deployments": "write",
    "issues": "write",
    "metadata": "read",
    "packages": "write",
    "pull_requests": "write",
    "repository_hooks": "write",
    "repository_projects": "write",
    "statuses": "write"
  },
  "default_events": [
    "check_run",
    "check_suite",
    "deployment",
    "deployment_status",
    "pull_request",
    "push",
    "release",
    "workflow_dispatch",
    "workflow_run"
  ]
}
EOF
```

### 3. Install Apps to Organization

```bash
# After creating apps, install them
# Get app IDs from GitHub UI

# Install Developer Hub app
gh api -X POST /orgs/$GITHUB_ORG/installations \
  -F app_id=$DEVHUB_APP_ID

# Install CI/CD Bot app  
gh api -X POST /orgs/$GITHUB_ORG/installations \
  -F app_id=$CICD_BOT_APP_ID

# Configure app permissions for repositories
for repo in $(gh repo list $GITHUB_ORG --json name -q '.[].name'); do
  gh api -X PUT /repos/$GITHUB_ORG/$repo/installations/$DEVHUB_APP_ID/permissions
done
```

## ✅ Validation & Testing

### 1. Validation Script

```bash
#!/bin/bash
# save as validate-github.sh

echo "🐙 Validating GitHub Enterprise Configuration..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validation functions
check_feature() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -n "Checking $name... "
    result=$(eval $command 2>/dev/null)
    
    if [[ "$result" == *"$expected"* ]]; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        echo "  Expected: $expected"
        echo "  Got: $result"
        return 1
    fi
}

# Organization checks
echo "📋 Organization Configuration"
check_feature "Organization exists" \
    "gh api /orgs/$GITHUB_ORG --jq '.login'" \
    "$GITHUB_ORG"

check_feature "Advanced Security enabled" \
    "gh api /orgs/$GITHUB_ORG --jq '.advanced_security_enabled'" \
    "true"

check_feature "Two-factor required" \
    "gh api /orgs/$GITHUB_ORG --jq '.two_factor_requirement_enabled'" \
    "true"

# Repository checks
echo -e "\n📁 Repository Configuration"
for repo in platform-infrastructure developer-hub-config application-templates; do
    check_feature "Repository $repo exists" \
        "gh repo view $GITHUB_ORG/$repo --json name --jq '.name'" \
        "$repo"
done

# Team checks
echo -e "\n👥 Team Configuration"
for team in platform-team developers security-team; do
    check_feature "Team $team exists" \
        "gh api /orgs/$GITHUB_ORG/teams/$team --jq '.name'" \
        "$team"
done

# Actions checks
echo -e "\n⚡ GitHub Actions"
check_feature "Actions enabled" \
    "gh api /orgs/$GITHUB_ORG/actions/permissions --jq '.enabled_repositories'" \
    "all"

check_feature "Self-hosted runners" \
    "gh api /orgs/$GITHUB_ORG/actions/runners --jq '.total_count > 0'" \
    "true"

# Security checks
echo -e "\n🔒 Security Configuration"
check_feature "Branch protection on main" \
    "gh api /repos/$GITHUB_ORG/platform-infrastructure/branches/main/protection --jq '.enabled'" \
    "true"

check_feature "Secret scanning enabled" \
    "gh api /orgs/$GITHUB_ORG --jq '.secret_scanning_enabled'" \
    "true"

# Integration checks
echo -e "\n🔗 Integrations"
check_feature "Azure credentials configured" \
    "gh secret list --org $GITHUB_ORG | grep -c AZURE_CREDENTIALS" \
    "1"

check_feature "Registry credentials configured" \
    "gh secret list --org $GITHUB_ORG | grep -c REGISTRY_" \
    "3"

echo -e "\n✅ GitHub validation complete!"
```

### 2. Test Workflows

```yaml
# .github/workflows/test-integration.yml
name: Test Platform Integration

on:
  workflow_dispatch:

jobs:
  test-azure:
    runs-on: ubuntu-latest
    steps:
      - name: Azure Login Test
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          
      - name: List Resource Groups
        run: |
          az group list --query "[?contains(name, 'threehorizons')].name" -o table
          
  test-acr:
    runs-on: ubuntu-latest
    steps:
      - name: ACR Login Test
        uses: docker/login-action@v3
        with:
          registry: ${{ secrets.REGISTRY_URL }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
          
      - name: Test Push
        run: |
          docker pull hello-world
          docker tag hello-world ${{ secrets.REGISTRY_URL }}/test:latest
          docker push ${{ secrets.REGISTRY_URL }}/test:latest
          
  test-k8s:
    runs-on: self-hosted
    steps:
      - name: Kubernetes Connection Test
        run: |
          kubectl get nodes
          kubectl get namespaces
```

## 📋 Configuration Summary

### Created Resources

| Resource Type | Name | Purpose |
|---------------|------|---------|
| **Organization** | threehorizons-ai | Main organization |
| **Teams** | platform-team, developers, security-team | Access control |
| **Repositories** | 6 core repositories | Code organization |
| **GitHub Apps** | 2 apps | Integrations |
| **Webhooks** | 2 webhooks | Event handling |
| **Secrets** | 7 organization secrets | Secure configuration |

### Security Configuration

- ✅ Advanced Security enabled
- ✅ Two-factor authentication required
- ✅ Branch protection on all main branches
- ✅ Secret scanning with push protection
- ✅ Dependabot enabled
- ✅ Code scanning with CodeQL
- ✅ Security policies defined

### Next Steps

1. **Configure GitHub Copilot Enterprise** (Horizon 2)
   ```bash
   gh api -X PUT /orgs/$GITHUB_ORG/copilot/billing \
     -F copilot_enabled=true \
     -F seat_management_type="assign_all"
   ```

2. **Set up GitHub Packages**
   ```bash
   gh api -X PUT /orgs/$GITHUB_ORG/packages \
     -F packages_enabled=true
   ```

3. **Configure GitHub Projects**
   ```bash
   gh api -X POST /orgs/$GITHUB_ORG/projects \
     -F name="Platform Development" \
     -F body="Three Horizons Platform Development Tracking"
   ```

## 🚦 Next Steps

### Immediate Actions
1. ✅ Run the validation script to ensure all configurations are correct
2. ✅ Test the CI/CD workflows with sample applications
3. ✅ Configure team members and permissions
4. ✅ Set up branch policies for all repositories

### Continue to Next Phase
- [**H1-005: Developer Hub Deployment**](h1-horizon-foundation/005-developer-hub-deployment.md) - Install Red Hat Developer Hub
- [**H1-006: Basic CI/CD Pipeline**](h1-horizon-foundation/006-basic-cicd.md) - Create initial pipelines
- [**H1-007: Demo Environment**](h1-horizon-foundation/007-demo-environment.md) - Set up demo scenarios

---

<div align="center">

**GitHub Enterprise Configuration Complete! 🎉**

Your source control platform is now ready for AI-powered development.

[← Previous: Security Foundation](h1-horizon-foundation/003-security-foundation.md) | [Next: Developer Hub Deployment →](h1-horizon-foundation/005-developer-hub-deployment.md)

</div>
