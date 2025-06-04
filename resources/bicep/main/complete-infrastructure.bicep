targetScope = 'subscription'

@description('Base name for all resources')
param baseName string = 'threehorizons'

@description('Environment name')
@allowed(['dev', 'test', 'prod'])
param environment string = 'prod'

@description('Primary location for all resources')
param location string = 'centralus'

@description('Secondary location for replication')
param secondaryLocation string = 'eastus2'

@description('Administrator password for PostgreSQL')
@secure()
param postgresAdminPassword string

@description('Deploy AKS cluster')
param deployAKS bool = true

@description('Deploy ARO cluster')
param deployARO bool = false

@description('Pull secret for ARO')
@secure()
param aroPullSecret string = ''

@description('Service principal client ID for ARO')
@secure()
param aroClientId string = ''

@description('Service principal client secret for ARO')
@secure()
param aroClientSecret string = ''

@description('Tags to apply to resources')
param tags object = {
  Environment: environment
  Project: 'ThreeHorizons'
  ManagedBy: 'Bicep'
}

// Variables
var resourceGroupNames = {
  platform: '${baseName}-platform-${environment}'
  shared: '${baseName}-shared-${environment}'
  devbox: '${baseName}-devbox-${environment}'
}

var uniqueSuffix = uniqueString(subscription().subscriptionId, baseName, environment)

// Resource Groups
resource platformRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupNames.platform
  location: location
  tags: tags
}

resource sharedRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupNames.shared
  location: location
  tags: tags
}

resource devboxRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupNames.devbox
  location: location
  tags: tags
}

// Network Module
module network '../modules/network.bicep' = {
  name: 'network-deployment'
  scope: platformRg
  params: {
    vnetName: '${baseName}-vnet'
    location: location
    tags: tags
    vnetAddressPrefix: '10.0.0.0/16'
  }
}

// Log Analytics Module
module logAnalytics '../modules/loganalytics.bicep' = {
  name: 'loganalytics-deployment'
  scope: sharedRg
  params: {
    workspaceName: '${baseName}-workspace'
    location: location
    tags: tags
  }
}

// Key Vault Module
module keyVault '../modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  scope: sharedRg
  params: {
    keyVaultName: 'kv${baseName}${uniqueSuffix}'
    location: location
    tags: tags
    subnetId: network.outputs.servicesSubnetId
  }
}

// Container Registry Module
module containerRegistry '../modules/containerregistry.bicep' = {
  name: 'acr-deployment'
  scope: sharedRg
  params: {
    acrName: 'acr${baseName}${uniqueSuffix}'
    location: location
    replicaLocation: secondaryLocation
    tags: tags
  }
}

// Managed Identity Module
module managedIdentity '../modules/managedidentity.bicep' = {
  name: 'identity-deployment'
  scope: sharedRg
  params: {
    identityName: '${baseName}-identity'
    location: location
    tags: tags
  }
}

// PostgreSQL Module
module postgresql '../modules/postgresql.bicep' = {
  name: 'postgresql-deployment'
  scope: sharedRg
  params: {
    serverName: 'psql-${baseName}-${uniqueSuffix}'
    location: location
    tags: tags
    administratorPassword: postgresAdminPassword
  }
}

// Storage Account Module for DevBox
module storageAccount '../modules/storageaccount.bicep' = {
  name: 'storage-deployment'
  scope: sharedRg
  params: {
    storageAccountName: 'st${baseName}${uniqueSuffix}'
    location: location
    tags: tags
    containerNames: ['scripts', 'artifacts']
  }
}

// AKS Module
module aksCluster '../modules/aks-cluster.bicep' = if (deployAKS) {
  name: 'aks-deployment'
  scope: platformRg
  params: {
    clusterName: '${baseName}-aks'
    location: location
    tags: tags
    subnetId: network.outputs.aksSubnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// Configure AKS Workload Identity
module aksWorkloadIdentity '../modules/managedidentity.bicep' = if (deployAKS) {
  name: 'aks-workload-identity-deployment'
  scope: sharedRg
  params: {
    identityName: '${baseName}-aks-workload-identity'
    location: location
    tags: tags
    aksOidcIssuerUrl: deployAKS ? aksCluster.outputs.aksOidcIssuerUrl : ''
    serviceAccountNamespace: 'default'
    serviceAccountName: 'workload-identity-sa'
  }
}

// Outputs
output platformResourceGroupName string = platformRg.name
output sharedResourceGroupName string = sharedRg.name
output devboxResourceGroupName string = devboxRg.name
output vnetId string = network.outputs.vnetId
output keyVaultName string = keyVault.outputs.keyVaultName
output acrLoginServer string = containerRegistry.outputs.acrLoginServer
output postgresServerFqdn string = postgresql.outputs.serverFqdn
output aksClusterName string = deployAKS ? aksCluster.outputs.aksClusterName : ''
output aksOidcIssuerUrl string = deployAKS ? aksCluster.outputs.aksOidcIssuerUrl : ''
output storageAccountName string = storageAccount.outputs.storageAccountName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId 
