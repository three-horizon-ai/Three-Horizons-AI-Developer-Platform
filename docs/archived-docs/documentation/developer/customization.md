# <span style="color: #0366d6;">📘 Developer Hub Customization Guide</span>

This document provides comprehensive guidance for customizing the Red Hat Developer Hub in the Three Horizons Platform.

## <span style="color: #0366d6;">🔍 Overview</span>

The Red Hat Developer Hub (RHDH) in the Three Horizons Platform can be customized to meet specific organizational requirements, branding guidelines, and developer workflows. This guide covers all aspects of customization, from visual appearance to plugin integration and content management.

## <span style="color: #0366d6;">🔹 Visual Customization</span>

### <span style="color: #0366d6;">Branding</span>

1. **Logo and Favicon**

   To update the Developer Hub logo and favicon:

   ```yaml
   app:
     title: Three Horizons Developer Hub
     branding:
       logo: https://storage.threehorizons.com/branding/logo.svg
       favicon: https://storage.threehorizons.com/branding/favicon.ico
       logoIcon: https://storage.threehorizons.com/branding/icon.svg
   ```

2. **Color Scheme**

   Customize the color palette by modifying the theme configuration:

   ```yaml
   app:
     theme:
       primaryColor: '#0066CC'
       textColor: '#333333'
       navigationBackgroundColor: '#172B4D'
       navigationTextColor: '#FFFFFF'
       tabBarBackgroundColor: '#F8F8F8'
   ```

3. **Custom Stylesheets**

   For advanced styling, add custom CSS:

   ```yaml
   app:
     theme:
       customStylesheet: 
         - https://storage.threehorizons.com/styles/custom.css
   ```

### <span style="color: #0366d6;">Layout Customization</span>

1. **Homepage Layout**

   Customize the homepage layout by creating an `app-config.local.yaml` file:

   ```yaml
   app:
     homepage:
       layout:
         - component: WelcomeTitle
         - component: ThreeHorizonsStats
         - component: GettingStartedCard
         - component: SearchBar
           properties:
             placeholder: Search components, templates, and docs...
         - component: CompanyNewsCard
   ```

2. **Navigation Menu**

   Modify the sidebar navigation structure:

   ```yaml
   app:
     sidebar:
       groups:
         - label: Developer Resources
           items:
             - label: Documentation
               icon: description
               to: /docs
             - label: API Catalog
               icon: api
               to: /catalog?filters[kind]=api
             - label: Components
               icon: extension
               to: /catalog?filters[kind]=component
         - label: Administration
           items:
             - label: Settings
               icon: settings
               to: /settings
   ```

## <span style="color: #0366d6;">🔹 Content Customization</span>

### <span style="color: #0366d6;">Documentation</span>

1. **Configure TechDocs**

   Enable and configure the documentation system:

   ```yaml
   techdocs:
     builder: 'local'
     publisher:
       type: 'azureBlobStorage'
       azureBlobStorage:
         containerName: 'techdocs'
         credentials:
           accountName: ${STORAGE_ACCOUNT_NAME}
           accountKey: ${STORAGE_ACCOUNT_KEY}
     generator:
       runIn: 'docker'
   ```

2. **Custom Documentation Landing Page**

   Create a custom documentation landing page by creating a React component in a custom plugin and then referencing it in the configuration:

   ```yaml
   app:
     routes:
       - path: /docs
         element: <ThreeHorizonsDocsPage />
   ```

### <span style="color: #0366d6;">Catalog Configuration</span>

1. **Entity Display**

   Customize how entities are displayed in the catalog:

   ```yaml
   catalog:
     entities:
       component:
         layout:
           - component: EntityHeader
             properties:
               title: 'Component: ${metadata.name}'
               subtitle: '${spec.type}'
           - component: EntityCatalogGraph
           - component: EntityLinksCard
   ```

2. **Custom Entity Pages**

   Create custom pages for specific entity kinds:

   ```yaml
   app:
     routes:
       - path: /catalog/:namespace/:kind/:name
         if:
           kind: 'service'
         element: <ThreeHorizonsServicePage />
   ```

## <span style="color: #0366d6;">🔄 Plugin Integration</span>

### <span style="color: #0366d6;">Installing Plugins</span>

1. **Add Official Plugins**

   Add official Backstage plugins to the Developer Hub:

   ```yaml
   app:
     plugins:
       - package: '@backstage/plugin-api-docs'
       - package: '@backstage/plugin-tech-radar'
       - package: '@backstage/plugin-cost-insights'
       - package: '@backstage/plugin-lighthouse'
   ```

2. **Configure Plugin Settings**

   Configure specific plugin settings:

   ```yaml
   lighthouse:
     baseUrl: https://lighthouse.threehorizons.com
   
   cost-insights:
     engineerCost: 200000
     products:
       computeEngine:
         name: Compute Engine
         icon: compute
   ```

### <span style="color: #0366d6;">Custom Plugin Development</span>

1. **Plugin Scaffolding**

   Create a new custom plugin:

   ```bash
   # Navigate to the Developer Hub plugins directory
   cd plugins
   
   # Create a new plugin
   npx @backstage/cli create-plugin --name three-horizons-dashboard
   ```

2. **Integration with Developer Hub**

   Add the plugin to your Developer Hub instance:

   ```yaml
   app:
     plugins:
       - name: three-horizons-dashboard
         path: plugins/three-horizons-dashboard
   ```

## <span style="color: #0366d6;">🔹 Authentication and Authorization</span>

### <span style="color: #0366d6;">Authentication Providers</span>

1. **Configure Multiple Auth Providers**

   Set up multiple authentication options:

   ```yaml
   auth:
     environment: production
     providers:
       azure:
         production:
           clientId: ${AUTH_AZURE_CLIENT_ID}
           clientSecret: ${AUTH_AZURE_CLIENT_SECRET}
           tenantId: ${AUTH_AZURE_TENANT_ID}
       github:
         production:
           clientId: ${AUTH_GITHUB_CLIENT_ID}
           clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
           enterpriseInstanceUrl: https://github.company.com
   ```

2. **Custom Sign-In Page**

   Create a custom sign-in experience:

   ```yaml
   app:
     routes:
       - path: /login
         element: <ThreeHorizonsLoginPage />
   ```

### <span style="color: #0366d6;">Permission Policies</span>

1. **Configure Permission Framework**

   Enable and configure the permission framework:

   ```yaml
   permission:
     enabled: true
     policies:
       - name: 'read-only-policy'
         effect: allow
         resource: catalog-entity
         action: read
       - name: 'admin-policy'
         effect: allow
         resource: '*'
         action: '*'
         conditions:
           user: 'group:administrators'
   ```

## <span style="color: #0366d6;">🔄 Integration Customization</span>

### <span style="color: #0366d6;">GitHub Integration</span>

1. **GitHub Enterprise Configuration**

   Configure Developer Hub for GitHub Enterprise:

   ```yaml
   integrations:
     github:
       - host: github.company.com
         token: ${GITHUB_TOKEN}
         apps:
           - appId: ${GITHUB_APP_ID}
             clientId: ${GITHUB_APP_CLIENT_ID}
             clientSecret: ${GITHUB_APP_CLIENT_SECRET}
             webhookSecret: ${GITHUB_APP_WEBHOOK_SECRET}
             privateKey: ${GITHUB_APP_PRIVATE_KEY}
   ```

2. **GitHub Discovery**

   Configure repository discovery for the catalog:

   ```yaml
   catalog:
     providers:
       github:
         schedule:
           frequency: { minutes: 30 }
           timeout: { minutes: 3 }
         organization: three-horizons
         catalogPath: '/catalog-info.yaml'
         filters:
           branch: 'main'
           repository: '.*'
   ```

### <span style="color: #0366d6;">Kubernetes Integration</span>

1. **Kubernetes Cluster Integration**

   Integrate with Kubernetes clusters:

   ```yaml
   kubernetes:
     serviceLocatorMethod:
       type: 'multiTenant'
     clusterLocatorMethods:
       - type: 'config'
         clusters:
           - name: 'production-cluster'
             url: https://api.production.cluster.threehorizons.com
             serviceAccountToken: ${K8S_PRODUCTION_TOKEN}
             caData: ${K8S_PRODUCTION_CA_DATA}
           - name: 'staging-cluster'
             url: https://api.staging.cluster.threehorizons.com
             serviceAccountToken: ${K8S_STAGING_TOKEN}
   ```

### <span style="color: #0366d6;">CI/CD Integration</span>

1. **Azure DevOps Integration**

   Configure integration with Azure DevOps:

   ```yaml
   integrations:
     azure:
       - host: dev.azure.com
         token: ${AZURE_TOKEN}
         organization: three-horizons
   
   catalog:
     providers:
       azureDevOps:
         organization: three-horizons
         project: platform
         repository: '.*'
   ```

2. **GitHub Actions Integration**

   Configure integration with GitHub Actions:

   ```yaml
   integrations:
     github:
       - host: github.com
         token: ${GITHUB_TOKEN}
   
   githubActions:
     selfHostedRunners:
       enabled: true
       queueUrls:
         - url: http://github-runner-controller.cicd/actions/queues
   ```

## <span style="color: #0366d6;">🔹 Extensibility</span>

### <span style="color: #0366d6;">Custom Extensions</span>

1. **Create Extension Points**

   Define extension points in the Developer Hub:

   ```typescript
   // In your custom plugin
   import { createExtensionPoint } from '@backstage/core-plugin-api';

   export const threeHorizonsDashboardExtensionPoint = createExtensionPoint({
     id: 'three-horizons.dashboard.extension-point',
     getItems: () => Promise.resolve([]),
   });
   ```

2. **Register Extensions**

   Register components to extension points:

   ```yaml
   app:
     extensions:
       - extension: 'three-horizons.dashboard.extension-point'
         component: 'ThreeHorizonsMetricsCard'
         properties:
           title: 'Platform Metrics'
   ```

### <span style="color: #0366d6;">Scaffolder Actions</span>

1. **Custom Scaffolder Actions**

   Register custom actions for the software templates:

   ```yaml
   scaffolder:
     actions:
       - id: 'three-horizons:create-repository'
         description: 'Creates a new repository in the Three Horizons organization'
         handler: './actions/create-repository'
   ```

## <span style="color: #0366d6;">🔹 Advanced Customization</span>

### <span style="color: #0366d6;">Custom Backend Services</span>

1. **Create Custom Backend Service**

   Create a custom backend service for specific functionality:

   ```typescript
   // In packages/backend/src/plugins/threehorizons.ts
   import { createRouter } from '@internal/plugin-three-horizons-backend';
   import { Router } from 'express';
   import { PluginEnvironment } from '../types';

   export default async function createPlugin(
     env: PluginEnvironment,
   ): Promise<Router> {
     return await createRouter({
       logger: env.logger,
       database: env.database,
     });
   }
   ```

2. **Register Backend Service**

   Register the service in the backend:

   ```typescript
   // In packages/backend/src/index.ts
   import threehorizons from './plugins/threehorizons';
   // ...
   
   async function main() {
     // ...
     const threehorizonsEnv = useHotMemoize(module, () => createEnv('threehorizons'));
     const apiRouter = Router();
     // ...
     apiRouter.use('/three-horizons', await threehorizons(threehorizonsEnv));
     // ...
   }
   ```

### <span style="color: #0366d6;">Custom Search</span>

1. **Configure Custom Search Engine**

   Set up a custom search implementation:

   ```yaml
   search:
     engines:
       elasticsearch:
         provider:
           type: elastic
           url: https://elasticsearch.threehorizons.com
           username: ${ELASTIC_USERNAME}
           password: ${ELASTIC_PASSWORD}
           indexes:
             - name: catalog
               type: catalog-entity
             - name: techdocs
               type: techdocs
   ```

## <span style="color: #0366d6;">🚀 Deployment Customization</span>

### <span style="color: #0366d6;">Helm Chart Customization</span>

1. **Create Custom Values**

   Create a custom values file for Helm deployment:

   ```yaml
   # three-horizons-values.yaml
   global:
     enabled: true
   
   backstage:
     enabled: true
     ingress:
       enabled: true
       host: developer-hub.threehorizons.com
       annotations:
         kubernetes.io/ingress.class: nginx
         cert-manager.io/cluster-issuer: letsencrypt-prod
   
   postgresql:
     enabled: true
     persistence:
       size: 10Gi
   ```

2. **Deploy with Custom Values**

   Deploy Developer Hub with custom values:

   ```bash
   helm upgrade --install developer-hub developer-hub/developer-hub \
     -f three-horizons-values.yaml \
     --namespace developer-hub
   ```

## <span style="color: #0366d6;">⚡ Performance Optimization</span>

### <span style="color: #0366d6;">Caching</span>

1. **Configure Frontend Caching**

   Optimize frontend caching:

   ```yaml
   app:
     caching:
       ttl: 3600000  # 1 hour in milliseconds
   ```

2. **Backend Cache**

   Configure backend caching:

   ```yaml
   backend:
     cache:
       store: memory
       connection: ''
   ```

## <span style="color: #0366d6;">📚 References</span>

- [Backstage Documentation](https://backstage.io/docs)
- [Red Hat Developer Hub Documentation](https://developers.redhat.com/rhdh)
- [Custom Templates](custom-templates.md)
- [Golden Paths](golden-paths.md)

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
