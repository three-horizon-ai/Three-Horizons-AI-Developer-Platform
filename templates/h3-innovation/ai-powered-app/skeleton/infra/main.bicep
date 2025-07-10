targetScope = 'resourceGroup'

@description('Name of the application')
param appName string = 'ai-powered-app'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name')
param environmentName string = 'dev'

@description('OpenAI model deployment name')
param openAiModelName string = 'gpt-4o'

@description('OpenAI API version')
param openAiApiVersion string = '2024-02-01'

@description('Enable Azure AI Search')
param enableAiSearch bool = true

@description('Enable Document Intelligence')
param enableDocumentIntelligence bool = true

@description('Enable Computer Vision')
param enableComputerVision bool = true

@description('Resource tags')
param tags object = {
  Environment: environmentName
  Application: appName
  ManagedBy: 'Bicep'
  Type: 'AI-Powered-Application'
}

// Generate unique resource names
var resourceToken = uniqueString(resourceGroup().id)
var openAiName = '${appName}-openai-${resourceToken}'
var searchServiceName = '${appName}-search-${resourceToken}'
var cosmosAccountName = '${appName}-cosmos-${resourceToken}'
var storageAccountName = '${appName}st${resourceToken}'
var keyVaultName = '${appName}-kv-${resourceToken}'
var appInsightsName = '${appName}-ai-${resourceToken}'
var appServicePlanName = '${appName}-plan-${resourceToken}'
var webAppName = '${appName}-web-${resourceToken}'
var documentIntelligenceName = '${appName}-doc-${resourceToken}'
var computerVisionName = '${appName}-cv-${resourceToken}'

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    RetentionInDays: 90
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enabledForDeployment: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// Storage Account for AI processing
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: 'Allow'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Cosmos DB Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosAccount
  name: '${appName}-db'
  properties: {
    resource: {
      id: '${appName}-db'
    }
  }
}

// Cosmos DB Container for AI data
resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'ai-data'
  properties: {
    resource: {
      id: 'ai-data'
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

// Azure OpenAI Service
resource openAiService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiName
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// OpenAI Model Deployment
resource openAiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAiService
  name: openAiModelName
  properties: {
    model: {
      format: 'OpenAI'
      name: openAiModelName
      version: '2024-05-13'
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    scaleSettings: {
      scaleType: 'Standard'
      capacity: 30
    }
  }
}

// Azure AI Search Service
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = if (enableAiSearch) {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

// Document Intelligence Service
resource documentIntelligence 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (enableDocumentIntelligence) {
  name: documentIntelligenceName
  location: location
  tags: tags
  kind: 'FormRecognizer'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: documentIntelligenceName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Computer Vision Service
resource computerVision 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (enableComputerVision) {
  name: computerVisionName
  location: location
  tags: tags
  kind: 'ComputerVision'
  sku: {
    name: 'S1'
  }
  properties: {
    customSubDomainName: computerVisionName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'S1'
  }
  kind: 'app'
  properties: {
    reserved: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: union(tags, {
    'azd-service-name': 'web'
  })
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'KeyVault__VaultUri'
          value: keyVault.properties.vaultUri
        }
        {
          name: 'OpenAI__Endpoint'
          value: openAiService.properties.endpoint
        }
        {
          name: 'OpenAI__DeploymentName'
          value: openAiModelName
        }
        {
          name: 'OpenAI__ApiVersion'
          value: openAiApiVersion
        }
        {
          name: 'Search__ServiceName'
          value: enableAiSearch ? searchService.name : ''
        }
        {
          name: 'Search__Endpoint'
          value: enableAiSearch ? 'https://${searchService.name}.search.windows.net' : ''
        }
        {
          name: 'CosmosDB__AccountUri'
          value: cosmosAccount.properties.documentEndpoint
        }
        {
          name: 'CosmosDB__DatabaseName'
          value: cosmosDatabase.name
        }
        {
          name: 'DocumentIntelligence__Endpoint'
          value: enableDocumentIntelligence ? 'https://${documentIntelligenceName}.cognitiveservices.azure.com/' : ''
        }
        {
          name: 'ComputerVision__Endpoint'
          value: enableComputerVision ? 'https://${computerVisionName}.cognitiveservices.azure.com/' : ''
        }
        {
          name: 'Storage__AccountName'
          value: storageAccount.name
        }
      ]
    }
  }
}

// Role assignments for managed identity
resource keyVaultSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, webApp.id, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource openAiUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openAiService
  name: guid(openAiService.id, webApp.id, 'Cognitive Services OpenAI User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource searchContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableAiSearch) {
  scope: searchService
  name: guid(searchService.id, webApp.id, 'Search Service Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7ca78c08-252a-4471-8644-bb5ff32d4ba0')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource cosmosContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: cosmosAccount
  name: guid(cosmosAccount.id, webApp.id, 'Cosmos DB Built-in Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00000000-0000-0000-0000-000000000002')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, webApp.id, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource documentIntelligenceUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableDocumentIntelligence) {
  scope: documentIntelligence
  name: guid(documentIntelligence.id, webApp.id, 'Cognitive Services User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource computerVisionUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableComputerVision) {
  scope: computerVision
  name: guid(computerVision.id, webApp.id, 'Cognitive Services User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Store service keys in Key Vault
resource openAiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'openai-key'
  properties: {
    value: 'managed-identity-preferred'
    contentType: 'text/plain'
  }
}

resource searchKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (enableAiSearch) {
  parent: keyVault
  name: 'search-key'
  properties: {
    value: 'managed-identity-preferred'
    contentType: 'text/plain'
  }
}

// Outputs
output webAppName string = webApp.name
output webAppHostName string = webApp.properties.defaultHostName
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output openAiEndpoint string = openAiService.properties.endpoint
output openAiName string = openAiService.name
output searchServiceName string = enableAiSearch ? searchService.name : ''
output searchServiceEndpoint string = enableAiSearch ? 'https://${searchService.name}.search.windows.net' : ''
output cosmosAccountName string = cosmosAccount.name
output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
output appInsightsName string = appInsights.name
output resourceGroupName string = resourceGroup().name
output documentIntelligenceName string = enableDocumentIntelligence ? documentIntelligence.name : ''
output computerVisionName string = enableComputerVision ? computerVision.name : ''
