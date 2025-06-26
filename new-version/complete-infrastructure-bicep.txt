// ========================================
// Three Horizons AI Platform - Complete Infrastructure
// Version: 2.0
// Description: Production-ready Bicep template for deploying the complete platform
// ========================================

targetScope = 'subscription'

// ========================================
// PARAMETERS
// ========================================

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Azure region for deployment')
param location string = 'centralus'

@description('Base name for all resources')
@minLength(3)
@maxLength(10)
param baseName string = 'threehorizons'

@description('Platform configuration')
param platformConfig object = {
  aks: {
    enabled: true
    kubernetesVersion: '1.28.5'
    systemNodeCount: 3
    userNodeCount: 3
    systemNodeSize: 'Standard_D4s_v5'
    userNodeSize: 'Standard_D8s_v5'
    enableAutoScaling: true
    minNodeCount: 3
    maxNodeCount: 10
  }
  aro: {
    enabled: false
    version: '4.13'
    masterNodeSize: 'Standard_D8s_v4'
    workerNodeSize: 'Standard_D8s_v4'
    workerNodeCount: 3
  }
  security: {
    enableDefender: true
    enableSentinel: true
    enableGitHubAdvancedSecurity: true
  }
  monitoring: {
    retentionDays: 90
    enablePrometheus: true
    enableGrafana: true
  }
  ai: {
    enableAzureAIFoundry: true
    enableCopilot: true
    enableMCP: true
  }
}

@description('Network configuration')
param networkConfig object = {
  hub: {
    addressPrefix: '10.0.0.0/16'
    subnets: {
      firewall: '10.0.1.0/24'
      gateway: '10.0.2.0/24'
      bastion: '10.0.3.0/24'
      management: '10.0.4.0/24'
    }
  }
  aks: {
    addressPrefix: '10.1.0.0/16'
    subnets: {
      systemNodes: '10.1.0.0/24'
      userNodes: '10.1.1.0/24'
      internalLb: '10.1.2.0/24'
      privateEndpoints: '10.1.3.0/24'
      pods: '10.1.16.0/20'
      services: '10.1.32.0/24'
    }
  }
  devhub: {
    addressPrefix: '10.2.0.0/16'
    subnets: {
      app: '10.2.1.0/24'
      data: '10.2.2.0/24'
      privateEndpoints: '10.2.3.0/24'
    }
  }
}

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  Platform: 'Three Horizons AI'
  ManagedBy: 'Bicep'
  Version: '2.0'
  CostCenter: 'Engineering'
}

@secure()
@description('Administrator username for VMs')
param adminUsername string = 'azureuser'

@secure()
@description('SSH public key for VM access')
param sshPublicKey string

// ========================================
// VARIABLES
// ========================================

var resourceGroupNames = {
  infrastructure: 'rg-${baseName}-${environment}-infra'
  compute: 'rg-${baseName}-${environment}-compute'
  data: 'rg-${baseName}-${environment}-data'
  security: 'rg-${baseName}-${environment}-security'
  monitoring: 'rg-${baseName}-${environment}-monitor'
}

var deploymentName = 'threehorizons-${environment}-${uniqueString(deployment().name)}'

// ========================================
// RESOURCE GROUPS
// ========================================

resource rgInfra 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNames.infrastructure
  location: location
  tags: tags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNames.compute
  location: location
  tags: tags
}

resource rgData 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNames.data
  location: location
  tags: tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNames.security
  location: location
  tags: tags
}

resource rgMonitoring 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupNames.monitoring
  location: location
  tags: tags
}

// ========================================
// NETWORKING DEPLOYMENT
// ========================================

module networking './modules/networking.bicep' = {
  name: '${deploymentName}-networking'
  scope: rgInfra
  params: {
    location: location
    environment: environment
    baseName: baseName
    networkConfig: networkConfig
    tags: tags
  }
}

// ========================================
// IDENTITY & SECURITY DEPLOYMENT
// ========================================

module identity './modules/identity.bicep' = {
  name: '${deploymentName}-identity'
  scope: rgSecurity
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
  }
}

module keyVault './modules/keyvault.bicep' = {
  name: '${deploymentName}-keyvault'
  scope: rgSecurity
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkRules: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: [
        {
          id: networking.outputs.aksSystemSubnetId
        }
        {
          id: networking.outputs.aksUserSubnetId
        }
      ]
    }
  }
}

// ========================================
// MONITORING DEPLOYMENT
// ========================================

module monitoring './modules/monitoring.bicep' = {
  name: '${deploymentName}-monitoring'
  scope: rgMonitoring
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    retentionDays: platformConfig.monitoring.retentionDays
    enablePrometheus: platformConfig.monitoring.enablePrometheus
    enableGrafana: platformConfig.monitoring.enableGrafana
  }
}

// ========================================
// CONTAINER REGISTRY DEPLOYMENT
// ========================================

module containerRegistry './modules/containerregistry.bicep' = {
  name: '${deploymentName}-acr'
  scope: rgInfra
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    sku: 'Premium'
    enableZoneRedundancy: environment == 'prod'
    dataEndpointEnabled: true
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
  }
}

// ========================================
// STORAGE DEPLOYMENT
// ========================================

module storageDevHub './modules/storage.bicep' = {
  name: '${deploymentName}-storage-devhub'
  scope: rgData
  params: {
    location: location
    environment: environment
    purpose: 'devhub'
    baseName: baseName
    tags: tags
    sku: environment == 'prod' ? 'Standard_ZRS' : 'Standard_LRS'
    containers: [
      'techdocs'
      'catalog'
      'templates'
      'artifacts'
    ]
  }
}

module storageBackup './modules/storage.bicep' = {
  name: '${deploymentName}-storage-backup'
  scope: rgData
  params: {
    location: location
    environment: environment
    purpose: 'backup'
    baseName: baseName
    tags: tags
    sku: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
    containers: [
      'aks-backups'
      'database-backups'
      'config-backups'
    ]
  }
}

// ========================================
// DATABASE DEPLOYMENT
// ========================================

module postgresql './modules/postgresql.bicep' = {
  name: '${deploymentName}-postgresql'
  scope: rgData
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    administratorLogin: 'devhubadmin'
    skuName: environment == 'prod' ? 'Standard_D4s_v3' : 'Standard_D2s_v3'
    storageSizeGB: environment == 'prod' ? 256 : 128
    backupRetentionDays: environment == 'prod' ? 35 : 7
    geoRedundantBackup: environment == 'prod' ? 'Enabled' : 'Disabled'
    version: '14'
    databases: [
      'devhub'
      'backstage_plugin_catalog'
      'backstage_plugin_auth'
      'backstage_plugin_permission'
    ]
  }
}

// ========================================
// AKS DEPLOYMENT (if enabled)
// ========================================

module aks './modules/aks.bicep' = if (platformConfig.aks.enabled) {
  name: '${deploymentName}-aks'
  scope: rgCompute
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    kubernetesVersion: platformConfig.aks.kubernetesVersion
    
    // Network configuration
    vnetSubnetId: networking.outputs.aksSystemSubnetId
    podSubnetId: networking.outputs.aksPodSubnetId
    serviceCidr: networkConfig.aks.subnets.services
    dnsServiceIP: '${split(networkConfig.aks.subnets.services, '/')[0]}.10'
    
    // Node pools
    systemNodeCount: platformConfig.aks.systemNodeCount
    systemNodeVmSize: platformConfig.aks.systemNodeSize
    userNodeCount: platformConfig.aks.userNodeCount
    userNodeVmSize: platformConfig.aks.userNodeSize
    
    // Auto-scaling
    enableAutoScaling: platformConfig.aks.enableAutoScaling
    minNodeCount: platformConfig.aks.minNodeCount
    maxNodeCount: platformConfig.aks.maxNodeCount
    
    // Add-ons
    enableMonitoring: true
    logAnalyticsWorkspaceId: monitoring.outputs.workspaceId
    enableAzurePolicy: true
    enableKeyVaultSecretsProvider: true
    enableIngressApplicationGateway: false
    
    // Identity
    identityType: 'SystemAssigned'
    
    // Security
    enableDefender: platformConfig.security.enableDefender
    networkPolicy: 'calico'
    
    // Container Registry
    acrId: containerRegistry.outputs.id
  }
}

// ========================================
// ARO DEPLOYMENT (if enabled)
// ========================================

module aro './modules/aro.bicep' = if (platformConfig.aro.enabled) {
  name: '${deploymentName}-aro'
  scope: rgCompute
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    version: platformConfig.aro.version
    
    // Network configuration
    vnetId: networking.outputs.hubVnetId
    masterSubnetId: networking.outputs.aroMasterSubnetId
    workerSubnetId: networking.outputs.aroWorkerSubnetId
    
    // Node configuration
    masterVmSize: platformConfig.aro.masterNodeSize
    workerVmSize: platformConfig.aro.workerNodeSize
    workerCount: platformConfig.aro.workerNodeCount
    
    // Monitoring
    enableMonitoring: true
    logAnalyticsWorkspaceId: monitoring.outputs.workspaceId
  }
}

// ========================================
// SECURITY COMPONENTS
// ========================================

module defender './modules/defender.bicep' = if (platformConfig.security.enableDefender) {
  name: '${deploymentName}-defender'
  scope: subscription()
  params: {
    environment: environment
    enableAllPlans: environment == 'prod'
    securityContactEmail: 'security@threehorizon.ai'
    securityContactPhone: '+1-555-0123'
    alertNotifications: 'On'
    alertsToAdmins: 'On'
  }
}

module sentinel './modules/sentinel.bicep' = if (platformConfig.security.enableSentinel) {
  name: '${deploymentName}-sentinel'
  scope: rgSecurity
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    workspaceId: monitoring.outputs.workspaceId
    enabledDataConnectors: [
      'AzureActiveDirectory'
      'AzureActivity'
      'SecurityCenter'
      'ThreatIntelligence'
    ]
  }
}

// ========================================
// AI COMPONENTS (Horizon 2+)
// ========================================

module aiFoundry './modules/ai-foundry.bicep' = if (platformConfig.ai.enableAzureAIFoundry) {
  name: '${deploymentName}-ai-foundry'
  scope: rgCompute
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    sku: environment == 'prod' ? 'S0' : 'F0'
    enableMCP: platformConfig.ai.enableMCP
  }
}

// ========================================
// PRIVATE ENDPOINTS
// ========================================

module privateEndpoints './modules/private-endpoints.bicep' = {
  name: '${deploymentName}-private-endpoints'
  scope: rgInfra
  params: {
    location: location
    environment: environment
    baseName: baseName
    tags: tags
    subnetId: networking.outputs.privateEndpointsSubnetId
    resources: [
      {
        name: 'pe-keyvault'
        resourceId: keyVault.outputs.id
        groupId: 'vault'
      }
      {
        name: 'pe-acr'
        resourceId: containerRegistry.outputs.id
        groupId: 'registry'
      }
      {
        name: 'pe-postgresql'
        resourceId: postgresql.outputs.id
        groupId: 'postgresqlServer'
      }
      {
        name: 'pe-storage-devhub'
        resourceId: storageDevHub.outputs.id
        groupId: 'blob'
      }
    ]
  }
}

// ========================================
// RBAC ASSIGNMENTS
// ========================================

// AKS to ACR pull permissions
resource aksAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (platformConfig.aks.enabled) {
  name: guid(aks.outputs.principalId, containerRegistry.outputs.id, 'acrpull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: aks.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// AKS to Key Vault secrets access
resource aksKeyVaultSecrets 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (platformConfig.aks.enabled) {
  name: guid(aks.outputs.principalId, keyVault.outputs.id, 'keyvault')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: aks.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// ========================================
// OUTPUTS
// ========================================

output deploymentInfo object = {
  subscriptionId: subscription().subscriptionId
  resourceGroups: resourceGroupNames
  deploymentName: deploymentName
  timestamp: utcNow()
}

output infrastructure object = {
  networking: {
    hubVnetId: networking.outputs.hubVnetId
    aksVnetId: networking.outputs.aksVnetId
    devHubVnetId: networking.outputs.devHubVnetId
  }
  identity: {
    managedIdentities: identity.outputs.identities
  }
  security: {
    keyVaultName: keyVault.outputs.name
    keyVaultUri: keyVault.outputs.uri
  }
}

output compute object = {
  aks: platformConfig.aks.enabled ? {
    clusterName: aks.outputs.clusterName
    apiServerUrl: aks.outputs.apiServerUrl
    resourceId: aks.outputs.id
  } : null
  aro: platformConfig.aro.enabled ? {
    clusterName: aro.outputs.clusterName
    consoleUrl: aro.outputs.consoleUrl
    apiServerUrl: aro.outputs.apiServerUrl
  } : null
  containerRegistry: {
    name: containerRegistry.outputs.name
    loginServer: containerRegistry.outputs.loginServer
  }
}

output data object = {
  postgresql: {
    serverName: postgresql.outputs.serverName
    fqdn: postgresql.outputs.fqdn
    administratorLogin: postgresql.outputs.administratorLogin
  }
  storage: {
    devHub: {
      name: storageDevHub.outputs.name
      primaryEndpoint: storageDevHub.outputs.primaryBlobEndpoint
    }
    backup: {
      name: storageBackup.outputs.name
      primaryEndpoint: storageBackup.outputs.primaryBlobEndpoint
    }
  }
}

output monitoring object = {
  workspace: {
    id: monitoring.outputs.workspaceId
    name: monitoring.outputs.workspaceName
  }
  applicationInsights: {
    instrumentationKey: monitoring.outputs.appInsightsInstrumentationKey
    connectionString: monitoring.outputs.appInsightsConnectionString
  }
}

output nextSteps array = [
  'Run: az aks get-credentials --resource-group ${resourceGroupNames.compute} --name ${platformConfig.aks.enabled ? aks.outputs.clusterName : "aks-name"}'
  'Configure GitHub integration using the service principal credentials'
  'Deploy Red Hat Developer Hub using Helm charts'
  'Configure monitoring dashboards in Grafana'
  'Set up GitOps with Flux or ArgoCD'
]