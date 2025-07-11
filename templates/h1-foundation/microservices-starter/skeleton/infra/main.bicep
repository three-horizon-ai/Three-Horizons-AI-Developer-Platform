// Three Horizons AI Platform - Azure Infrastructure Template
// This template follows Microsoft Azure Cloud Adoption Framework (CAF) best practices
// and implements security-by-default configurations for enterprise deployments

targetScope = 'resourceGroup'

// ================================================================================================
// METADATA
// ================================================================================================

metadata name = 'Three Horizons AI Platform Infrastructure'
metadata description = 'Deploys foundational Azure infrastructure following CAF standards and security best practices'
metadata version = '1.0.0'
metadata author = 'Three Horizons Platform Team'

// ================================================================================================
// PARAMETERS
// ================================================================================================

@description('Base name for all resources. Will be combined with environment and location.')
@minLength(3)
@maxLength(10)
param resourceBaseName string = 'th3horiz'

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Instance number for this deployment (001, 002, etc.)')
@minLength(3)
@maxLength(3)
param instance string = '001'

@description('Administrator object ID for Key Vault access')
param administratorObjectId string

@description('Tags to apply to all resources')
param tags object = {
  project: 'three-horizons-ai'
  environment: environment
  'cost-center': 'platform-engineering'
  'managed-by': 'bicep'
  'created-date': utcNow('yyyy-MM-dd')
}

@description('Enable diagnostic settings for monitoring')
param enableDiagnostics bool = true

@description('Log Analytics workspace name for centralized logging')
param logAnalyticsWorkspaceName string = ''

@description('Virtual network address space')
param vnetAddressSpace string = '10.0.0.0/16'

@description('AKS subnet address prefix')
param aksSubnetAddressPrefix string = '10.0.1.0/24'

@description('Services subnet address prefix')
param servicesSubnetAddressPrefix string = '10.0.2.0/24'

@description('Private endpoints subnet address prefix')
param privateEndpointsSubnetAddressPrefix string = '10.0.3.0/24'

@description('Kubernetes version for AKS cluster')
param kubernetesVersion string = '1.28.3'

@description('Enable Azure Policy Add-on for AKS')
param enableAzurePolicy bool = true

@description('Enable container insights monitoring')
param enableContainerInsights bool = true

// ================================================================================================
// VARIABLES
// ================================================================================================

// Generate unique suffix for globally unique resources
var uniqueSuffix = uniqueString(resourceGroup().id, resourceBaseName, environment)

// Resource naming following Azure CAF standards
var namingConvention = {
  // Storage accounts (globally unique, alphanumeric only, max 24 chars)
  storageAccount: 'st${resourceBaseName}${environment}${take(uniqueSuffix, 5)}'
  
  // Key Vault (globally unique, max 24 chars)
  keyVault: 'kv-${resourceBaseName}-${environment}-${take(location, 6)}-${instance}'
  
  // AKS Cluster
  aksCluster: 'aks-${resourceBaseName}-${environment}-${location}-${instance}'
  
  // Container Registry (globally unique, alphanumeric only)
  containerRegistry: 'cr${resourceBaseName}${environment}${take(uniqueSuffix, 7)}'
  
  // Log Analytics Workspace
  logAnalytics: 'log-${resourceBaseName}-${environment}-${location}-${instance}'
  
  // Virtual Network
  virtualNetwork: 'vnet-${resourceBaseName}-${environment}-${location}-${instance}'
  
  // Network Security Groups
  nsgAks: 'nsg-aks-${environment}-${location}-${instance}'
  nsgServices: 'nsg-services-${environment}-${location}-${instance}'
  
  // Managed Identity
  managedIdentity: 'id-${resourceBaseName}-${environment}-${location}-${instance}'
  
  // Application Insights
  applicationInsights: 'appi-${resourceBaseName}-${environment}-${location}-${instance}'
}

// Subnet configurations
var subnets = [
  {
    name: 'snet-aks'
    addressPrefix: aksSubnetAddressPrefix
    networkSecurityGroup: namingConvention.nsgAks
    serviceEndpoints: [
      {
        service: 'Microsoft.ContainerRegistry'
        locations: [location]
      }
      {
        service: 'Microsoft.KeyVault'
        locations: [location]
      }
      {
        service: 'Microsoft.Storage'
        locations: [location]
      }
    ]
  }
  {
    name: 'snet-services'
    addressPrefix: servicesSubnetAddressPrefix
    networkSecurityGroup: namingConvention.nsgServices
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
        locations: [location]
      }
      {
        service: 'Microsoft.Storage'
        locations: [location]
      }
      {
        service: 'Microsoft.Sql'
        locations: [location]
      }
    ]
  }
  {
    name: 'snet-private-endpoints'
    addressPrefix: privateEndpointsSubnetAddressPrefix
    networkSecurityGroup: null
    serviceEndpoints: []
    privateEndpointNetworkPolicies: 'Disabled'
  }
]

// ================================================================================================
// EXISTING RESOURCES
// ================================================================================================

// Reference to existing Log Analytics workspace if provided
resource existingLogAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = if (!empty(logAnalyticsWorkspaceName)) {
  name: logAnalyticsWorkspaceName
}

// ================================================================================================
// CORE INFRASTRUCTURE
// ================================================================================================

// Managed Identity for secure authentication across services
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: namingConvention.managedIdentity
  location: location
  tags: tags
}

// Log Analytics Workspace for centralized logging and monitoring
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (empty(logAnalyticsWorkspaceName)) {
  name: namingConvention.logAnalytics
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'prod' ? 90 : 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
    workspaceCapping: {
      dailyQuotaGb: environment == 'prod' ? 10 : 5
    }
  }
}

// Application Insights for application performance monitoring
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: namingConvention.applicationInsights
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ================================================================================================
// NETWORKING
// ================================================================================================

// Network Security Groups with security-hardened rules
resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [for subnet in subnets: if (subnet.networkSecurityGroup != null) {
  name: subnet.networkSecurityGroup!
  location: location
  tags: tags
  properties: {
    securityRules: subnet.name == 'snet-aks' ? [
      // AKS-specific security rules
      {
        name: 'AllowHttpsInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1010
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ] : [
      // Default security rules for other subnets
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}]

// Virtual Network with security-optimized configuration
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: namingConvention.virtualNetwork
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressSpace]
    }
    subnets: [for (subnet, index) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: subnet.networkSecurityGroup != null ? {
          id: networkSecurityGroups[index].id
        } : null
        serviceEndpoints: subnet.serviceEndpoints
        privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies ?? 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    }]
    enableDdosProtection: environment == 'prod'
  }
}

// ================================================================================================
// SECURITY & SECRETS MANAGEMENT
// ================================================================================================

// Key Vault with enhanced security configuration
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: namingConvention.keyVault
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: environment == 'prod' ? 'premium' : 'standard'
    }
    // Security configurations
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: environment == 'prod'
    
    // Network access restrictions
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${virtualNetwork.id}/subnets/snet-services'
          ignoreMissingVnetServiceEndpoint: false
        }
        {
          id: '${virtualNetwork.id}/subnets/snet-aks'
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
  }
}

// RBAC assignment for managed identity to Key Vault
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, managedIdentity.id, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// RBAC assignment for administrator to Key Vault
resource keyVaultAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, administratorObjectId, 'Key Vault Administrator')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483') // Key Vault Administrator
    principalId: administratorObjectId
    principalType: 'User'
  }
}

// ================================================================================================
// CONTAINER INFRASTRUCTURE
// ================================================================================================

// Azure Container Registry with security enhancements
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: namingConvention.containerRegistry
  location: location
  tags: tags
  sku: {
    name: environment == 'prod' ? 'Premium' : 'Standard'
  }
  properties: {
    adminUserEnabled: false // Use managed identity instead
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        status: environment == 'prod' ? 'enabled' : 'disabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: environment == 'prod' ? 30 : 7
      }
    }
    encryption: {
      status: 'disabled' // Can be enabled with customer-managed keys if needed
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled' // Consider 'Disabled' for production with private endpoints
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: environment == 'prod' ? 'Enabled' : 'Disabled'
  }
}

// RBAC assignment for managed identity to Container Registry
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, managedIdentity.id, 'AcrPull')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// AKS Cluster with security-hardened configuration
resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: namingConvention.aksCluster
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: namingConvention.aksCluster
    
    // Security configurations
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    
    // Network configuration
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'azure'
      serviceCidr: '10.2.0.0/24'
      dnsServiceIP: '10.2.0.10'
      outboundType: 'loadBalancer'
      loadBalancerSku: 'standard'
    }
    
    // Node pool configuration
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: environment == 'prod' ? 3 : 2
        vmSize: environment == 'prod' ? 'Standard_D4s_v5' : 'Standard_D2s_v5'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: '${virtualNetwork.id}/subnets/snet-aks'
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: true
        minCount: environment == 'prod' ? 3 : 1
        maxCount: environment == 'prod' ? 10 : 5
        maxPods: 30
        availabilityZones: environment == 'prod' ? ['1', '2', '3'] : ['1']
        osDiskSizeGB: 100
        osDiskType: 'Managed'
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
    
    // Add-ons and features
    addonProfiles: {
      azurePolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: {
        enabled: enableContainerInsights
        config: {
          logAnalyticsWorkspaceResourceID: empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
    }
    
    // Security features
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      imageCleaner: {
        enabled: true
        intervalHours: 24
      }
    }
    
    // API server configuration
    apiServerAccessProfile: {
      enablePrivateCluster: environment == 'prod'
      privateDNSZone: environment == 'prod' ? 'system' : null
    }
    
    // Auto-upgrade configuration
    autoUpgradeProfile: {
      upgradeChannel: environment == 'prod' ? 'stable' : 'patch'
    }
    
    // Workload identity and OIDC issuer
    oidcIssuerProfile: {
      enabled: true
    }
  }
}

// ================================================================================================
// STORAGE
// ================================================================================================

// Storage Account with security enhancements
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: namingConvention.storageAccount
  location: location
  tags: tags
  sku: {
    name: environment == 'prod' ? 'Standard_ZRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // Security configurations
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false // Use Azure AD authentication only
    supportsHttpsTrafficOnly: true
    
    // Access tier
    accessTier: 'Hot'
    
    // Network access
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${virtualNetwork.id}/subnets/snet-services'
          action: 'Allow'
        }
        {
          id: '${virtualNetwork.id}/subnets/snet-aks'
          action: 'Allow'
        }
      ]
    }
  }
}

// RBAC assignment for managed identity to Storage Account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, managedIdentity.id, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// ================================================================================================
// MONITORING & DIAGNOSTICS
// ================================================================================================

// Diagnostic settings for Key Vault
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: keyVault
  name: 'default'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Diagnostic settings for Container Registry
resource acrDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: containerRegistry
  name: 'default'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Diagnostic settings for Storage Account
resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: storageAccount
  name: 'default'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// ================================================================================================
// OUTPUTS
// ================================================================================================

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Resource group location')
output location string = location

@description('Environment name')
output environment string = environment

@description('Managed Identity resource ID')
output managedIdentityId string = managedIdentity.id

@description('Managed Identity client ID')
output managedIdentityClientId string = managedIdentity.properties.clientId

@description('Managed Identity principal ID')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('Key Vault name')
output keyVaultName string = keyVault.name

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri

@description('AKS cluster name')
output aksClusterName string = aksCluster.name

@description('AKS cluster FQDN')
output aksClusterFqdn string = aksCluster.properties.fqdn

@description('AKS cluster resource ID')
output aksClusterId string = aksCluster.id

@description('Container Registry name')
output containerRegistryName string = containerRegistry.name

@description('Container Registry login server')
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

@description('Storage Account name')
output storageAccountName string = storageAccount.name

@description('Virtual Network name')
output virtualNetworkName string = virtualNetwork.name

@description('Virtual Network resource ID')
output virtualNetworkId string = virtualNetwork.id

@description('AKS subnet resource ID')
output aksSubnetId string = '${virtualNetwork.id}/subnets/snet-aks'

@description('Services subnet resource ID')
output servicesSubnetId string = '${virtualNetwork.id}/subnets/snet-services'

@description('Private endpoints subnet resource ID')
output privateEndpointsSubnetId string = '${virtualNetwork.id}/subnets/snet-private-endpoints'

@description('Log Analytics Workspace name')
output logAnalyticsWorkspaceName string = empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.name : logAnalyticsWorkspaceName

@description('Log Analytics Workspace resource ID')
output logAnalyticsWorkspaceId string = empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspace.id : existingLogAnalytics.id

@description('Application Insights name')
output applicationInsightsName string = applicationInsights.name

@description('Application Insights instrumentation key')
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights connection string')
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
