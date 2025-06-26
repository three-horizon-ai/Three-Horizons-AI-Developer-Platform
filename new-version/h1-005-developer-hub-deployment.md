# 📚 H1-005: Red Hat Developer Hub 1.6 Deployment Guide

<div align="center">

**Installing and Configuring Red Hat Developer Hub 1.6 on Three Horizons Platform**

</div>

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Prerequisites](#-prerequisites)
3. [PostgreSQL Database Setup](#-postgresql-database-setup)
4. [Developer Hub Installation](#-developer-hub-installation)
5. [Authentication Configuration](#-authentication-configuration)
6. [Catalog Setup](#-catalog-setup)
7. [Plugin Configuration](#-plugin-configuration)
8. [Customization](#-customization)
9. [Integration Setup](#-integration-setup)
10. [Validation & Testing](#-validation--testing)

## 🔍 Overview

Red Hat Developer Hub 1.6 serves as the central developer portal for the Three Horizons AI Platform, providing a unified interface for:

- **Software Catalog**: Centralized registry of all services, APIs, and components
- **Golden Path Templates**: Standardized application scaffolding
- **Self-Service Portal**: Automated provisioning and deployment
- **Documentation Hub**: TechDocs for all components
- **Plugin Ecosystem**: 100+ integrations with enterprise tools

### Red Hat Developer Hub 1.6 Features

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Dynamic Plugins** | Hot-swappable plugins without restart | Zero downtime updates |
| **RBAC Delegation** | Granular permission management | Enhanced security |
| **Air-gapped Support** | Deployment in disconnected environments | Enterprise compliance |
| **High Availability** | Multi-replica deployment | 99.9% uptime |
| **Local Development** | RHDH Local for testing | Faster development |

## ✅ Prerequisites

### Required Components

```bash
# Verify prerequisites
echo "🔍 Checking prerequisites..."

# Check AKS connection
kubectl cluster-info
kubectl get nodes

# Check PostgreSQL
az postgres server show \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
  --name "psql-${BASE_NAME}-${ENVIRONMENT}"

# Check storage account
az storage account show \
  --name "st${BASE_NAME}${ENVIRONMENT}devhub" \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data"

# Check Key Vault
az keyvault show \
  --name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-security"
```

### Required Secrets

```bash
# Generate required secrets
POSTGRES_PASSWORD=$(openssl rand -base64 32)
BACKEND_SECRET=$(openssl rand -hex 32)
GITHUB_TOKEN="ghp_xxxxxxxxxxxx"  # Your GitHub PAT
GITHUB_CLIENT_ID="xxxxxxxxxxxx"   # From GitHub OAuth App
GITHUB_CLIENT_SECRET="xxxxxxxxxxxx" # From GitHub OAuth App

# Store in Key Vault
az keyvault secret set \
  --vault-name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --name "devhub-postgres-password" \
  --value "$POSTGRES_PASSWORD"

az keyvault secret set \
  --vault-name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --name "devhub-backend-secret" \
  --value "$BACKEND_SECRET"

az keyvault secret set \
  --vault-name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --name "devhub-github-token" \
  --value "$GITHUB_TOKEN"

az keyvault secret set \
  --vault-name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --name "devhub-github-client-id" \
  --value "$GITHUB_CLIENT_ID"

az keyvault secret set \
  --vault-name "kv-${BASE_NAME}-${ENVIRONMENT}" \
  --name "devhub-github-client-secret" \
  --value "$GITHUB_CLIENT_SECRET"
```

## 🗄️ PostgreSQL Database Setup

### 1. Configure PostgreSQL Server

```bash
# Create PostgreSQL server (if not already created)
az postgres server create \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
  --name "psql-${BASE_NAME}-${ENVIRONMENT}" \
  --location $LOCATION \
  --admin-user "devhubadmin" \
  --admin-password "$POSTGRES_PASSWORD" \
  --sku-name "GP_Gen5_4" \
  --version "14" \
  --storage-size 102400 \
  --backup-retention 35 \
  --geo-redundant-backup "Enabled" \
  --minimal-tls-version "TLS1_2" \
  --public-network-access "Disabled"

# Configure private endpoint
az network private-endpoint create \
  --name "pe-postgresql-${BASE_NAME}-${ENVIRONMENT}" \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
  --vnet-name "vnet-${BASE_NAME}-${ENVIRONMENT}-data" \
  --subnet "snet-private-endpoints" \
  --private-connection-resource-id $(az postgres server show \
    --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
    --name "psql-${BASE_NAME}-${ENVIRONMENT}" \
    --query id -o tsv) \
  --group-id "postgresqlServer" \
  --connection-name "postgresql-connection"
```

### 2. Create Databases

```bash
# Create databases for Developer Hub
PGHOST="psql-${BASE_NAME}-${ENVIRONMENT}.postgres.database.azure.com"

# Create databases
for db in devhub backstage_plugin_catalog backstage_plugin_auth backstage_plugin_permission backstage_plugin_scaffolder backstage_plugin_search; do
  az postgres db create \
    --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
    --server-name "psql-${BASE_NAME}-${ENVIRONMENT}" \
    --name $db
done

# Configure database extensions
az postgres server configuration set \
  --name shared_preload_libraries \
  --resource-group "rg-${BASE_NAME}-${ENVIRONMENT}-data" \
  --server-name "psql-${BASE_NAME}-${ENVIRONMENT}" \
  --value "pg_stat_statements,pgaudit"
```

### 3. Create Database Secret

```yaml
# postgres-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: rhdh
type: Opaque
stringData:
  POSTGRES_HOST: psql-threehorizons-${ENVIRONMENT}.postgres.database.azure.com
  POSTGRES_PORT: "5432"
  POSTGRES_USER: devhubadmin@psql-threehorizons-${ENVIRONMENT}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

## 🚀 Developer Hub Installation

### 1. Create Namespace and RBAC

```bash
# Create namespace
kubectl create namespace rhdh

# Create service account
kubectl create serviceaccount developer-hub -n rhdh

# Create RBAC
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer-hub-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "namespaces"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developer-hub-reader-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developer-hub-reader
subjects:
- kind: ServiceAccount
  name: developer-hub
  namespace: rhdh
EOF
```

### 2. Add Red Hat Helm Repository

```bash
# Add Red Hat Developer Hub Helm repository
helm repo add redhat-developer-hub https://redhat-developer.github.io/rhdh-chart
helm repo update

# Download and customize values
helm show values redhat-developer-hub/developer-hub > devhub-values.yaml
```

### 3. Configure Helm Values

```yaml
# devhub-values.yaml
global:
  # Dynamic plugins enabled
  dynamic:
    includes:
      - dynamic-plugins.default.yaml
    plugins:
      - package: '@backstage/plugin-kubernetes-backend-dynamic'
        disabled: false
      - package: '@backstage/plugin-github-actions'
        disabled: false
      - package: '@backstage/plugin-azure-devops'
        disabled: false
      - package: '@roadiehq/backstage-plugin-prometheus'
        disabled: false
      - package: '@backstage/plugin-sonarqube'
        disabled: false

route:
  enabled: false  # Using Ingress instead

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  host: devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
  tls:
    enabled: true
    secretName: devhub-tls

upstream:
  backstage:
    image:
      registry: registry.redhat.io
      repository: rhdh/rhdh-hub-rhel9
      tag: 1.6-latest
      
    replicas: 3
    
    resources:
      requests:
        memory: 2Gi
        cpu: 1000m
      limits:
        memory: 4Gi
        cpu: 2000m
        
    extraEnvVars:
      - name: NODE_ENV
        value: production
      - name: LOG_LEVEL
        value: info
      - name: BACKEND_SECRET
        valueFrom:
          secretKeyRef:
            name: backend-secret
            key: backend-secret
            
    appConfig:
      app:
        title: Three Horizons Developer Hub
        baseUrl: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
        support:
          url: https://github.com/${GITHUB_ORG}/support
          items:
            - title: Documentation
              icon: docs
              links:
                - url: https://docs.threehorizons.ai
                  title: Platform Documentation
            - title: Support
              icon: help
              links:
                - url: https://support.threehorizons.ai
                  title: Get Support
                  
      backend:
        baseUrl: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
        listen:
          port: 7007
        cors:
          origin: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
          methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
          credentials: true
        database:
          client: pg
          connection:
            host: ${POSTGRES_HOST}
            port: ${POSTGRES_PORT}
            user: ${POSTGRES_USER}
            password: ${POSTGRES_PASSWORD}
            database: devhub
            ssl:
              rejectUnauthorized: false
        cache:
          store: memory
        reading:
          allow:
            - host: github.com
            - host: '*.githubusercontent.com'
            
      integrations:
        github:
          - host: github.com
            token: ${GITHUB_TOKEN}
        azure:
          - host: dev.azure.com
            credentials:
              - clientId: ${AZURE_CLIENT_ID}
                clientSecret: ${AZURE_CLIENT_SECRET}
                tenantId: ${AZURE_TENANT_ID}
                
      proxy:
        '/prometheus':
          target: http://prometheus-server.monitoring.svc.cluster.local
        '/grafana':
          target: http://grafana.monitoring.svc.cluster.local
        '/sonarqube':
          target: https://sonarqube.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
          
      techdocs:
        builder: external
        generator:
          runIn: docker
        publisher:
          type: azureBlobStorage
          azureBlobStorage:
            containerName: techdocs
            accountName: st${BASE_NAME}${ENVIRONMENT}devhub
            
      auth:
        environment: production
        providers:
          github:
            production:
              clientId: ${GITHUB_CLIENT_ID}
              clientSecret: ${GITHUB_CLIENT_SECRET}
          microsoft:
            production:
              clientId: ${AZURE_CLIENT_ID}
              clientSecret: ${AZURE_CLIENT_SECRET}
              tenantId: ${AZURE_TENANT_ID}
              
      catalog:
        import:
          entityFilename: catalog-info.yaml
          pullRequestBranchName: backstage-integration
        rules:
          - allow: [Component, System, API, Resource, Location, User, Group]
        locations:
          - type: url
            target: https://github.com/${GITHUB_ORG}/application-templates/blob/main/catalog-info.yaml
          - type: url
            target: https://github.com/${GITHUB_ORG}/platform-infrastructure/blob/main/catalog-info.yaml
            
      kubernetes:
        serviceLocatorMethod:
          type: multiTenant
        clusterLocatorMethods:
          - type: config
            clusters:
              - url: ${K8S_API_URL}
                name: aks-${ENVIRONMENT}
                authProvider: serviceAccount
                skipTLSVerify: false
                serviceAccountToken: ${K8S_SA_TOKEN}
                
      scaffolder:
        defaultAuthor:
          name: Three Horizons Platform
          email: platform@threehorizons.ai
        defaultCommitMessage: "Initial commit from Developer Hub scaffolder"
        
    postgresql:
      enabled: false  # Using external PostgreSQL
      
    serviceAccount:
      create: false
      name: developer-hub
```

### 4. Deploy Developer Hub

```bash
# Create secrets
kubectl create secret generic backend-secret \
  --from-literal=backend-secret=$BACKEND_SECRET \
  -n rhdh

kubectl create secret generic github-credentials \
  --from-literal=GITHUB_TOKEN=$GITHUB_TOKEN \
  --from-literal=GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID \
  --from-literal=GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET \
  -n rhdh

kubectl create secret generic azure-credentials \
  --from-literal=AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
  --from-literal=AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET \
  --from-literal=AZURE_TENANT_ID=$AZURE_TENANT_ID \
  -n rhdh

# Install Developer Hub
helm upgrade --install developer-hub \
  redhat-developer-hub/developer-hub \
  --namespace rhdh \
  --values devhub-values.yaml \
  --version 1.6.0 \
  --wait \
  --timeout 10m
```

## 🔐 Authentication Configuration

### 1. Configure Azure AD Integration

```yaml
# azure-ad-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: azure-ad-config
  namespace: rhdh
data:
  auth.config.yaml: |
    auth:
      environment: production
      session:
        secret: ${BACKEND_SECRET}
      providers:
        microsoft:
          production:
            clientId: ${AZURE_CLIENT_ID}
            clientSecret: ${AZURE_CLIENT_SECRET}
            tenantId: ${AZURE_TENANT_ID}
            domainHint: ${AZURE_TENANT_ID}
            additionalScopes:
              - Mail.Send
            signIn:
              resolvers:
                - resolver: emailMatchingUserEntityProfileEmail
                - resolver: emailLocalPartMatchingUserEntityName
                - resolver: emailMatchingUserEntityAnnotation
```

### 2. Configure GitHub OAuth

```bash
# Create GitHub OAuth App
echo "Create OAuth App at: https://github.com/organizations/$GITHUB_ORG/settings/applications"
echo "Homepage URL: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai"
echo "Authorization callback URL: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai/api/auth/github/handler/frame"

# Update configuration with OAuth credentials
kubectl create configmap github-oauth-config \
  --from-literal=clientId=$GITHUB_CLIENT_ID \
  --from-literal=clientSecret=$GITHUB_CLIENT_SECRET \
  -n rhdh
```

### 3. Configure RBAC

```yaml
# rbac-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rbac-policy
  namespace: rhdh
data:
  rbac-policy.csv: |
    # Platform administrators - full access
    g, ThreeHorizons-Platform-Admins, role:admin
    
    # Developers - limited access
    g, ThreeHorizons-Developers, role:developer
    p, role:developer, catalog-entity, read, allow
    p, role:developer, catalog-entity, create, allow
    p, role:developer, catalog-entity, update, allow
    p, role:developer, catalog-entity, delete, deny
    p, role:developer, scaffolder-template, read, allow
    p, role:developer, scaffolder-template, use, allow
    p, role:developer, kubernetes, read, allow
    
    # SRE team - operational access
    g, ThreeHorizons-SRE, role:sre
    p, role:sre, *, read, allow
    p, role:sre, kubernetes, *, allow
    p, role:sre, techdocs, *, allow
    
    # Auditors - read only
    g, ThreeHorizons-Auditors, role:auditor
    p, role:auditor, *, read, allow
```

## 📚 Catalog Setup

### 1. Create Root Catalog

```yaml
# catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: three-horizons-root
  description: Root catalog for Three Horizons Platform
spec:
  type: url
  targets:
    - https://github.com/${GITHUB_ORG}/platform-infrastructure/blob/main/catalog/all.yaml
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: three-horizons-platform
  description: Three Horizons AI Development Platform
  tags:
    - platform
    - ai
    - kubernetes
spec:
  owner: platform-team
  domain: infrastructure
---
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: infrastructure
  description: Platform Infrastructure Domain
spec:
  owner: platform-team
```

### 2. Import Catalog Entities

```bash
# Create catalog structure in platform-infrastructure repo
mkdir -p catalog/{systems,components,apis,resources,groups,users}

# Create all.yaml to aggregate catalogs
cat > catalog/all.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: all-catalogs
  description: All Three Horizons catalogs
spec:
  type: url
  targets:
    - ./systems/all.yaml
    - ./components/all.yaml
    - ./apis/all.yaml
    - ./resources/all.yaml
    - ./groups/all.yaml
    - ./users/all.yaml
EOF

# Create system catalog
cat > catalog/systems/platform.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: developer-hub
  description: Red Hat Developer Hub System
  tags:
    - developer-portal
    - backstage
spec:
  owner: platform-team
  domain: infrastructure
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: kubernetes-platform
  description: Kubernetes Platform (AKS/ARO)
  tags:
    - kubernetes
    - infrastructure
spec:
  owner: platform-team
  domain: infrastructure
EOF

# Create component catalog
cat > catalog/components/developer-hub.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: developer-hub-backend
  description: Developer Hub Backend Service
  annotations:
    github.com/project-slug: ${GITHUB_ORG}/developer-hub-config
    backstage.io/kubernetes-id: developer-hub
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: developer-hub
  providesApis:
    - developer-hub-api
EOF
```

### 3. Configure Auto-discovery

```yaml
# auto-discovery.yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: github-discovery
  description: Auto-discover from GitHub
spec:
  type: github-discovery
  targets:
    - https://github.com/${GITHUB_ORG}
```

## 🔌 Plugin Configuration

### 1. Install Core Plugins

```bash
# Configure dynamic plugins
cat > dynamic-plugins.yaml << 'EOF'
plugins:
  # Kubernetes plugin
  - package: '@backstage/plugin-kubernetes'
    disabled: false
    pluginConfig:
      kubernetes:
        customResources:
          - group: 'argoproj.io'
            apiVersion: 'v1alpha1'
            plural: 'applications'
          - group: 'tekton.dev'
            apiVersion: 'v1beta1'
            plural: 'pipelineruns'
            
  # GitHub Actions plugin
  - package: '@backstage/plugin-github-actions'
    disabled: false
    
  # TechDocs plugin
  - package: '@backstage/plugin-techdocs'
    disabled: false
    pluginConfig:
      techdocs:
        sanitizer:
          allowedTags: ['iframe', 'video', 'audio']
          allowedAttributes:
            iframe: ['src', 'width', 'height', 'frameborder']
            
  # Azure DevOps plugin
  - package: '@backstage/plugin-azure-devops'
    disabled: false
    
  # SonarQube plugin
  - package: '@backstage/plugin-sonarqube'
    disabled: false
    
  # Prometheus plugin
  - package: '@roadiehq/backstage-plugin-prometheus'
    disabled: false
    
  # ArgoCD plugin
  - package: '@roadiehq/backstage-plugin-argo-cd'
    disabled: false
    
  # Cost Insights plugin
  - package: '@backstage/plugin-cost-insights'
    disabled: false
EOF

kubectl create configmap dynamic-plugins-config \
  --from-file=dynamic-plugins.yaml \
  -n rhdh
```

### 2. Configure Plugin Permissions

```yaml
# plugin-permissions.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: plugin-permissions
  namespace: rhdh
data:
  permissions.yaml: |
    permission:
      enabled: true
      policies:
        - name: catalog.entity.create
          decision: CONDITIONAL
          conditions:
            rule: IS_ENTITY_OWNER
        - name: catalog.entity.delete
          decision: CONDITIONAL
          conditions:
            anyOf:
              - rule: IS_ENTITY_OWNER
              - rule: HAS_ANNOTATION
                params:
                  annotation: backstage.io/managed-by-location
        - name: scaffolder.action.execute
          decision: ALLOW
```

## 🎨 Customization

### 1. Theme Customization

```typescript
// app-config.production.yaml
app:
  title: Three Horizons Developer Hub
  baseUrl: https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai
  
  branding:
    theme:
      light:
        primaryColor: '#0066CC'
        headerColor: '#FFFFFF'
        navigationColor: '#F5F5F5'
      dark:
        primaryColor: '#4A90E2'
        headerColor: '#1A1A1A'
        navigationColor: '#2D2D2D'
    
    homepage:
      logo:
        url: https://assets.threehorizons.ai/logo.svg
      background:
        image: https://assets.threehorizons.ai/hero-background.jpg
```

### 2. Homepage Configuration

```tsx
// packages/app/src/components/home/HomePage.tsx
import React from 'react';
import {
  HomePageCompanyLogo,
  HomePageStarredEntities,
  HomePageToolkit,
  HomePageRandomTip,
} from '@backstage/plugin-home';
import { Grid } from '@material-ui/core';
import { HomePageSearchBar } from '@backstage/plugin-search';

export const HomePage = () => {
  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <HomePageCompanyLogo />
      </Grid>
      <Grid item xs={12}>
        <HomePageSearchBar />
      </Grid>
      <Grid item xs={12} md={6}>
        <HomePageStarredEntities />
      </Grid>
      <Grid item xs={12} md={6}>
        <HomePageToolkit
          tools={[
            {
              label: 'Create Component',
              url: '/create',
              icon: 'scaffolder',
            },
            {
              label: 'Documentation',
              url: '/docs',
              icon: 'techdocs',
            },
            {
              label: 'API Catalog',
              url: '/api-docs',
              icon: 'api',
            },
          ]}
        />
      </Grid>
      <Grid item xs={12}>
        <HomePageRandomTip />
      </Grid>
    </Grid>
  );
};
```

### 3. Custom Sidebar

```tsx
// packages/app/src/components/Root/Root.tsx
import {
  Sidebar,
  SidebarPage,
  SidebarGroup,
  SidebarItem,
  SidebarDivider,
} from '@backstage/core-components';
import HomeIcon from '@material-ui/icons/Home';
import CreateIcon from '@material-ui/icons/Create';
import CloudIcon from '@material-ui/icons/Cloud';

export const Root = ({ children }: PropsWithChildren<{}>) => (
  <SidebarPage>
    <Sidebar>
      <SidebarGroup label="Platform" icon={<HomeIcon />}>
        <SidebarItem icon={HomeIcon} to="/" text="Home" />
        <SidebarItem icon={CreateIcon} to="/create" text="Create" />
        <SidebarItem icon={CloudIcon} to="/kubernetes" text="Kubernetes" />
      </SidebarGroup>
      <SidebarDivider />
      <SidebarGroup label="Infrastructure">
        <SidebarItem to="/catalog" text="Software Catalog" />
        <SidebarItem to="/api-docs" text="APIs" />
        <SidebarItem to="/docs" text="Docs" />
      </SidebarGroup>
    </Sidebar>
    {children}
  </SidebarPage>
);
```

## 🔗 Integration Setup

### 1. Kubernetes Integration

```bash
# Create service account for Developer Hub
kubectl create serviceaccount developer-hub-k8s -n rhdh

# Create cluster role binding
kubectl create clusterrolebinding developer-hub-k8s \
  --clusterrole=cluster-admin \
  --serviceaccount=rhdh:developer-hub-k8s

# Get service account token
K8S_SA_TOKEN=$(kubectl create token developer-hub-k8s -n rhdh --duration=87600h)

# Store in secret
kubectl create secret generic k8s-credentials \
  --from-literal=token=$K8S_SA_TOKEN \
  -n rhdh
```

### 2. GitHub Integration

```yaml
# github-integration.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: github-integration
  namespace: rhdh
data:
  github.yaml: |
    integrations:
      github:
        - host: github.com
          token: ${GITHUB_TOKEN}
          apiBaseUrl: https://api.github.com
          rawBaseUrl: https://raw.githubusercontent.com
    
    catalog:
      providers:
        github:
          organization:
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              repository: '.*'
            schedule:
              frequency: PT30M
              timeout: PT5M
```

### 3. Azure Integration

```bash
# Create Azure service principal for Developer Hub
az ad sp create-for-rbac \
  --name "sp-developer-hub-${ENVIRONMENT}" \
  --role "Reader" \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
  --sdk-auth > azure-sp.json

# Extract credentials
AZURE_CLIENT_ID=$(jq -r .clientId azure-sp.json)
AZURE_CLIENT_SECRET=$(jq -r .clientSecret azure-sp.json)
AZURE_TENANT_ID=$(jq -r .tenantId azure-sp.json)

# Update secret
kubectl create secret generic azure-integration \
  --from-literal=clientId=$AZURE_CLIENT_ID \
  --from-literal=clientSecret=$AZURE_CLIENT_SECRET \
  --from-literal=tenantId=$AZURE_TENANT_ID \
  -n rhdh

rm azure-sp.json
```

## ✅ Validation & Testing

### 1. Health Check Script

```bash
#!/bin/bash
# save as validate-devhub.sh

echo "🔍 Validating Developer Hub Deployment..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check deployment
echo "📊 Deployment Status:"
kubectl get deployment -n rhdh

# Check pods
echo -e "\n🏃 Pod Status:"
kubectl get pods -n rhdh

# Check services
echo -e "\n🌐 Services:"
kubectl get svc -n rhdh

# Check ingress
echo -e "\n🔗 Ingress:"
kubectl get ingress -n rhdh

# Test connectivity
DEVHUB_URL="https://devhub.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai"
echo -e "\n🌐 Testing Developer Hub URL: $DEVHUB_URL"

# Health endpoint
if curl -s -o /dev/null -w "%{http_code}" "$DEVHUB_URL/api/health" | grep -q "200"; then
  echo -e "${GREEN}✓ Health check passed${NC}"
else
  echo -e "${RED}✗ Health check failed${NC}"
fi

# Catalog endpoint
if curl -s -o /dev/null -w "%{http_code}" "$DEVHUB_URL/api/catalog/entities" -H "Authorization: Bearer $GITHUB_TOKEN" | grep -q "200"; then
  echo -e "${GREEN}✓ Catalog API accessible${NC}"
else
  echo -e "${RED}✗ Catalog API not accessible${NC}"
fi

# Check logs for errors
echo -e "\n📝 Recent logs:"
kubectl logs -n rhdh -l app.kubernetes.io/name=developer-hub --tail=20 | grep -E "(ERROR|WARN)"
```

### 2. Integration Tests

```typescript
// integration-tests/devhub.test.ts
import { test, expect } from '@playwright/test';

const DEVHUB_URL = process.env.DEVHUB_URL || 'https://devhub.threehorizons.dev.threehorizons.ai';

test.describe('Developer Hub Integration Tests', () => {
  test('Homepage loads successfully', async ({ page }) => {
    await page.goto(DEVHUB_URL);
    await expect(page).toHaveTitle(/Three Horizons Developer Hub/);
  });

  test('Catalog page accessible', async ({ page }) => {
    await page.goto(`${DEVHUB_URL}/catalog`);
    await expect(page.locator('h1')).toContainText('Software Catalog');
  });

  test('Create page shows templates', async ({ page }) => {
    await page.goto(`${DEVHUB_URL}/create`);
    await expect(page.locator('[data-testid="template-card"]')).toBeVisible();
  });

  test('API docs page loads', async ({ page }) => {
    await page.goto(`${DEVHUB_URL}/api-docs`);
    await expect(page.locator('h1')).toContainText('APIs');
  });

  test('GitHub authentication works', async ({ page }) => {
    await page.goto(`${DEVHUB_URL}/settings`);
    await page.click('text=Sign in with GitHub');
    // Complete OAuth flow
  });
});
```

### 3. Performance Monitoring

```yaml
# monitoring/devhub-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: devhub-grafana-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Developer Hub Monitoring",
        "panels": [
          {
            "title": "Request Rate",
            "targets": [
              {
                "expr": "rate(http_request_duration_seconds_count{job=\"developer-hub\"}[5m])"
              }
            ]
          },
          {
            "title": "Response Time",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job=\"developer-hub\"}[5m]))"
              }
            ]
          },
          {
            "title": "Error Rate",
            "targets": [
              {
                "expr": "rate(http_request_duration_seconds_count{job=\"developer-hub\",status=~\"5..\"}[5m])"
              }
            ]
          }
        ]
      }
    }
```

## 📋 Post-Installation Tasks

### 1. Configure Golden Path Templates

```bash
# Clone templates repository
git clone https://github.com/$GITHUB_ORG/application-templates.git
cd application-templates

# Add template to catalog
cat > templates/microservice/template.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: microservice-template
  title: Microservice
  description: Create a new microservice with CI/CD
  tags:
    - recommended
    - microservice
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Details
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          pattern: '^[a-z0-9-]+$'
        description:
          title: Description
          type: string
EOF

git add .
git commit -m "Add microservice template"
git push
```

### 2. Import Existing Services

```bash
# Create catalog info for existing services
for service in api-gateway user-service order-service; do
  cat > catalog-info-${service}.yaml << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${service}
  description: ${service} component
  annotations:
    github.com/project-slug: ${GITHUB_ORG}/${service}
spec:
  type: service
  lifecycle: production
  owner: developers
  system: three-horizons-platform
EOF
done
```

### 3. Enable TechDocs

```bash
# Configure TechDocs storage
STORAGE_ACCOUNT="st${BASE_NAME}${ENVIRONMENT}devhub"
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_ACCOUNT \
  --query "[0].value" -o tsv)

kubectl create secret generic techdocs-storage \
  --from-literal=accountName=$STORAGE_ACCOUNT \
  --from-literal=accountKey=$STORAGE_KEY \
  -n rhdh

# Update Developer Hub configuration
kubectl patch configmap developer-hub-config -n rhdh --type merge -p '
{
  "data": {
    "app-config.production.yaml": "techdocs:\n  builder: external\n  publisher:\n    type: azureBlobStorage\n    azureBlobStorage:\n      containerName: techdocs\n      accountName: '$STORAGE_ACCOUNT'\n"
  }
}'
```

## 🎯 Success Metrics

### Key Performance Indicators

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Page Load Time** | <2 seconds | Prometheus + Grafana |
| **Availability** | 99.9% | Uptime monitoring |
| **Catalog Sync Time** | <5 minutes | GitHub webhook latency |
| **Template Success Rate** | >95% | Scaffolder metrics |
| **User Adoption** | >80% developers | Active users/total |

### Monitoring Dashboard

Access the monitoring dashboard at:
- Grafana: `https://grafana.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai`
- Prometheus: `https://prometheus.${BASE_NAME}.${ENVIRONMENT}.threehorizons.ai`

## 🚦 Next Steps

### Immediate Actions
1. ✅ Access Developer Hub and verify all pages load
2. ✅ Import your first service into the catalog
3. ✅ Create a test component using a template
4. ✅ Configure team access and permissions

### Continue to Next Phase
- [**H1-006: Basic CI/CD Pipeline**](h1-006-basic-cicd.md) - Set up initial pipelines
- [**H1-007: Demo Environment**](h1-007-demo-environment.md) - Create demo scenarios
- [**H2-001: Advanced Deployment**](../horizon-2/h2-001-advanced-deployment.md) - GitOps setup

---

<div align="center">

**Developer Hub Successfully Deployed! 🎉**

Your central developer portal is now ready to accelerate development.

[← Previous: GitHub Setup](h1-004-github-setup.md) | [Next: CI/CD Pipeline →](h1-006-basic-cicd.md)

</div>
