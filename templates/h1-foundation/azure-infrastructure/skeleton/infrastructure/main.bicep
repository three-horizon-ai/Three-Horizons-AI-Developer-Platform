// Main Bicep template for Azure Infrastructure
// Horizon 1 Foundation - Basic Azure Infrastructure Setup

@description('Base name for all resources')
param name string = '${{ values.name }}'

@description('Environment (dev, test, prod)')
param environment string = '${{ values.environment }}'

@description('Azure region for primary resources')
param azureLocation string = '${{ values.azureLocation }}'

@description('Azure region for secondary resources (for multi-region setup)')
param secondaryLocation string = '${{ values.secondaryLocation }}'

@description('Azure subscription ID')
param subscriptionId string = '${{ values.subscriptionId }}'

@description('Deploy AKS cluster')
param deployAKS bool = ${{ values.deployAKS }}

@description('Deploy Azure Red Hat OpenShift')
param deployARO bool = ${{ values.deployARO }}

// Variables
var resourceGroupName = 'rg-${name}-${environment}'
var containerRegistryName = 'acr${replace(name, '-', '')}${environment}'
var keyVaultName = 'kv-${name}-${environment}'
var logAnalyticsName = 'log-${name}-${environment}'
var aksClusterName = 'aks-${name}-${environment}'
var aroClusterName = 'aro-${name}-${environment}'

// Tags
var commonTags = {
  Environment: environment
  Project: name
  ManagedBy: 'Backstage'
  Owner: '${{ values.owner }}'
}

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: azureLocation
  tags: commonTags
}

// Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  scope: resourceGroup
  params: {
    name: containerRegistryName
    location: azureLocation
    tags: commonTags
  }
}

// Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup
  params: {
    name: keyVaultName
    location: azureLocation
    tags: commonTags
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  scope: resourceGroup
  params: {
    name: logAnalyticsName
    location: azureLocation
    tags: commonTags
  }
}

// AKS Cluster (if enabled)
module aksCluster 'modules/aks-cluster.bicep' = if (deployAKS) {
  name: 'aksCluster'
  scope: resourceGroup
  params: {
    name: aksClusterName
    location: azureLocation
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    containerRegistryId: containerRegistry.outputs.registryId
    tags: commonTags
  }
}

// ARO Cluster (if enabled)
module aroCluster 'modules/aro-cluster.bicep' = if (deployARO) {
  name: 'aroCluster'
  scope: resourceGroup
  params: {
    name: aroClusterName
    location: azureLocation
    tags: commonTags
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output containerRegistryName string = containerRegistry.outputs.registryName
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output keyVaultName string = keyVault.outputs.vaultName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId

output aksClusterName string = deployAKS ? aksCluster.outputs.clusterName : ''
output aksClusterFqdn string = deployAKS ? aksCluster.outputs.clusterFqdn : ''

output aroClusterName string = deployARO ? aroCluster.outputs.clusterName : ''
output aroConsoleUrl string = deployARO ? aroCluster.outputs.consoleUrl : ''
