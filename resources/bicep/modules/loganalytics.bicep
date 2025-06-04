@description('The name of the Log Analytics Workspace')
param workspaceName string

@description('Location for all resources')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('SKU for Log Analytics Workspace')
@allowed(['Free', 'PerGB2018', 'PerNode', 'Standard', 'Standalone', 'CapacityReservation'])
param sku string = 'PerGB2018'

@description('Retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Daily quota in GB (-1 for unlimited)')
param dailyQuotaGb int = -1

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      enableDataExport: true
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Outputs
output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name
output workspaceResourceId string = logAnalyticsWorkspace.id
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId 
