// Azure Dev Box - Hub Architecture Template
// Following Azure best practices for centralized Dev Center with multiple projects
// Based on Microsoft Dev Box architecture guide and resource organization best practices

targetScope = 'resourceGroup'

@description('Organization name for the Dev Box environment')
param organizationName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment type (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Unique identifier for this deployment (timestamp: yyyyMMdd-HHmm)')
param instanceId string

@description('Network configuration type')
@allowed(['microsoft-hosted', 'azure-network'])
param networkType string = 'microsoft-hosted'

@description('VNet address space for Azure network connection (required if networkType is azure-network)')
param vnetAddressSpace string = '10.0.0.0/16'

@description('Subnet address space for dev boxes (required if networkType is azure-network)')
param devboxSubnetAddressSpace string = '10.0.1.0/24'

// Variables - Following Azure naming conventions with uniqueness
var uniqueSuffix = uniqueString(resourceGroup().id, organizationName, instanceId)
var abbreviations = {
  devCenter: 'dc'
  virtualNetwork: 'vnet'
  subnet: 'snet'
  networkConnection: 'nc'
  networkSecurityGroup: 'nsg'
}

// Resource names following Azure CAF naming conventions
var devCenterName = '${abbreviations.devCenter}-${organizationName}-hub-${environment}-${location}-${take(uniqueSuffix, 6)}'
var vnetName = '${abbreviations.virtualNetwork}-${organizationName}-devbox-${environment}-${location}-${take(uniqueSuffix, 6)}'
var subnetName = '${abbreviations.subnet}-devbox-${environment}-${take(uniqueSuffix, 6)}'
var nsgName = '${abbreviations.networkSecurityGroup}-devbox-${environment}-${location}-${take(uniqueSuffix, 6)}'
var networkConnectionName = '${abbreviations.networkConnection}-${organizationName}-${environment}-${location}-${take(uniqueSuffix, 6)}'

// Common tags for all resources
var commonTags = {
  organization: organizationName
  environment: environment
  managedBy: 'red-hat-developer-hub'
  instanceId: instanceId
  deploymentDate: instanceId
  architecture: 'hub-spoke'
  purpose: 'dev-box-platform'
  costCenter: 'development'
}

// Create Virtual Network (only if Azure network connection is selected)
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = if (networkType == 'azure-network') {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressSpace]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: devboxSubnetAddressSpace
          networkSecurityGroup: {
            id: nsg.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
    ]
    enableDdosProtection: false
  }
  tags: commonTags
}

// Create Network Security Group (only if Azure network connection is selected)
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = if (networkType == 'azure-network') {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          description: 'Allow RDP traffic to dev boxes'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          description: 'Allow HTTPS traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1010
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowDevBoxManagement'
        properties: {
          description: 'Allow Dev Box management traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'DevBoxService'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1020
          direction: 'Inbound'
        }
      }
    ]
  }
  tags: commonTags
}

// Create Dev Center (Hub)
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: location
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: commonTags
}

// Create Network Connection (Azure or Microsoft-hosted)
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' = {
  name: networkConnectionName
  location: location
  properties: networkType == 'azure-network' ? {
    networkingResourceGroupName: resourceGroup().name
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    domainJoinType: 'AzureADJoin'
  } : {
    networkingResourceGroupName: resourceGroup().name
    domainJoinType: 'AzureADJoin'
  }
  tags: commonTags
  dependsOn: networkType == 'azure-network' ? [vnet] : []
}

// Attach Network Connection to Dev Center
resource networkConnectionAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: devCenter
  name: networkConnectionName
  properties: {
    networkConnectionId: networkConnection.id
  }
}

// Create standard Dev Box Definitions
resource devBoxDefinitionStandard 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  parent: devCenter
  name: 'standard-dev-workstation'
  location: location
  properties: {
    imageReference: {
      id: '${devCenter.id}/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
    sku: {
      name: 'Standard_D8as_v4'
    }
    osStorageType: 'ssd_512gb'
    hibernateSupport: 'Enabled'
  }
  tags: union(commonTags, {
    definitionType: 'standard'
    targetAudience: 'general-development'
  })
}

resource devBoxDefinitionPowerUser 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  parent: devCenter
  name: 'power-user-workstation'
  location: location
  properties: {
    imageReference: {
      id: '${devCenter.id}/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
    sku: {
      name: 'Standard_D16as_v4'
    }
    osStorageType: 'ssd_1024gb'
    hibernateSupport: 'Enabled'
  }
  tags: union(commonTags, {
    definitionType: 'power-user'
    targetAudience: 'intensive-development'
  })
}

resource devBoxDefinitionDataScience 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  parent: devCenter
  name: 'data-science-workstation'
  location: location
  properties: {
    imageReference: {
      id: '${devCenter.id}/galleries/default/images/microsoftwindowsdesktop_windows-11_win11-22h2-ent'
    }
    sku: {
      name: 'Standard_D32as_v4'
    }
    osStorageType: 'ssd_1024gb'
    hibernateSupport: 'Enabled'
  }
  tags: union(commonTags, {
    definitionType: 'data-science'
    targetAudience: 'data-science-ml'
  })
}

// Outputs for use in project templates
output devCenterId string = devCenter.id
output devCenterName string = devCenter.name
output networkConnectionName string = networkConnection.name
output networkConnectionId string = networkConnection.id
output vnetId string = networkType == 'azure-network' ? vnet.id : ''
output vnetName string = networkType == 'azure-network' ? vnet.name : ''
output availableDefinitions array = [
  {
    name: devBoxDefinitionStandard.name
    displayName: 'Standard Developer Workstation'
    description: 'VS2022 Enterprise with standard development tools - 8 vCPU, 32GB RAM, 512GB SSD'
    sku: 'Standard_D8as_v4'
    targetAudience: 'General Development'
  }
  {
    name: devBoxDefinitionPowerUser.name
    displayName: 'Power User Workstation'
    description: 'VS2022 Enterprise with enhanced resources - 16 vCPU, 64GB RAM, 1TB SSD'
    sku: 'Standard_D16as_v4'
    targetAudience: 'Intensive Development'
  }
  {
    name: devBoxDefinitionDataScience.name
    displayName: 'Data Science Workstation'
    description: 'Windows 11 Enterprise for data science and ML - 32 vCPU, 128GB RAM, 1TB SSD'
    sku: 'Standard_D32as_v4'
    targetAudience: 'Data Science & ML'
  }
]
output commonTags object = commonTags
output instanceId string = instanceId
output resourceGroupName string = resourceGroup().name
