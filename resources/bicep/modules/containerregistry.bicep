@description('The name of the Container Registry')
@minLength(5)
@maxLength(50)
param acrName string

@description('Location for the primary registry')
param location string

@description('Location for the replica')
param replicaLocation string = 'eastus2'

@description('Tags to apply to resources')
param tags object = {}

@description('Enable admin user')
param adminUserEnabled bool = false

@description('SKU for Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Premium'

@description('Enable Microsoft Defender for container registry')
param enableDefender bool = true

// Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'enabled'
      }
      retentionPolicy: sku == 'Premium' ? {
        days: 30
        status: 'enabled'
      } : null
      exportPolicy: {
        status: 'enabled'
      }
    }
    encryption: sku == 'Premium' ? {
      status: 'enabled'
    } : null
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: sku == 'Premium' ? 'Enabled' : 'Disabled'
  }
}

// Geo-replication for Premium SKU
resource acrReplication 'Microsoft.ContainerRegistry/registries/replications@2023-01-01-preview' = if (sku == 'Premium') {
  parent: acr
  name: '${replace(replicaLocation, ' ', '')}replica'
  location: replicaLocation
  tags: tags
  properties: {
    regionEndpointEnabled: true
    zoneRedundancy: 'Enabled'
  }
}

// Note: Microsoft Defender for container registries must be configured at subscription level

// Outputs
output acrId string = acr.id
output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output acrPrimaryLocation string = acr.location
output acrReplicaLocation string = sku == 'Premium' ? replicaLocation : '' 
