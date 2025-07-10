targetScope = 'resourceGroup'

@description('Name of the application')
param appName string = 'ecommerce-demo'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name')
param environmentName string = 'dev'

@description('SQL Database SKU')
param databaseSku string = 'S1'

@description('App Service Plan SKU')
param appServicePlanSku string = 'B1'

@description('Enable Application Insights')
param enableAppInsights bool = true

@description('Enable Azure SQL Database')
param enableSqlDatabase bool = true

@description('Enable Storage Account')
param enableStorageAccount bool = true

@description('Resource tags')
param tags object = {
  Environment: environmentName
  Application: appName
  ManagedBy: 'Bicep'
}

// Generate unique resource names
var resourceToken = uniqueString(resourceGroup().id)
var sqlServerName = '${appName}-sql-${resourceToken}'
var sqlDatabaseName = '${appName}-db'
var appServicePlanName = '${appName}-plan-${resourceToken}'
var webAppName = '${appName}-web-${resourceToken}'
var storageAccountName = '${appName}st${resourceToken}'
var keyVaultName = '${appName}-kv-${resourceToken}'
var appInsightsName = '${appName}-ai-${resourceToken}'

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (enableAppInsights) {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    RetentionInDays: 30
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

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (enableStorageAccount) {
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

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = if (enableSqlDatabase) {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: '@Microsoft.KeyVault(SecretUri=${keyVault.properties.vaultUri}secrets/sql-admin-password)'
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = if (enableSqlDatabase) {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: databaseSku
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
  }
}

// SQL Server Firewall Rule - Allow Azure Services
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = if (enableSqlDatabase) {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
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
          value: enableAppInsights ? appInsights.properties.ConnectionString : ''
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
          name: 'Storage__ConnectionString'
          value: enableStorageAccount ? '@Microsoft.KeyVault(SecretUri=${keyVault.properties.vaultUri}secrets/storage-key)' : ''
        }
      ]
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: enableSqlDatabase ? 'Server=tcp:${sqlServer.name}.${environment().suffixes.sqlServerHostname},1433;Database=${sqlDatabase.name};Authentication=Active Directory Default;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;' : ''
          type: 'SQLAzure'
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

resource storageDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableStorageAccount) {
  scope: storageAccount
  name: guid(storageAccount.id, webApp.id, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Store secrets in Key Vault
resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (enableSqlDatabase) {
  parent: keyVault
  name: 'sql-admin-password'
  properties: {
    value: '${uniqueString(resourceGroup().id, 'sql-password')}Aa1!'
    contentType: 'text/plain'
  }
}

resource storageKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (enableStorageAccount) {
  parent: keyVault
  name: 'storage-key'
  properties: {
    value: 'placeholder-key-will-be-updated-post-deployment'
    contentType: 'text/plain'
  }
}

// Outputs
output webAppName string = webApp.name
output webAppHostName string = webApp.properties.defaultHostName
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output sqlServerName string = enableSqlDatabase ? sqlServer.name : ''
output sqlDatabaseName string = enableSqlDatabase ? sqlDatabase.name : ''
output storageAccountName string = enableStorageAccount ? storageAccount.name : ''
output keyVaultName string = keyVault.name
output appInsightsName string = enableAppInsights ? appInsights.name : ''
output resourceGroupName string = resourceGroup().name
