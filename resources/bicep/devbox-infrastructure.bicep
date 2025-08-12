// Azure Dev Box Infrastructure Template
// This Bicep template creates all necessary resources for Azure Dev Box

@description('Project name for the Dev Box')
param projectName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Developer name for personalization')
param developerName string

@description('Team name')
param teamName string

@description('Dev Box size')
@allowed([
  'Standard_D4as_v4'
  'Standard_D8as_v4'
  'Standard_D16as_v4'
])
param devBoxSize string = 'Standard_D8as_v4'

@description('User Principal ID for Dev Box access')
param userPrincipalId string

@description('User Principal Type (User or Group)')
@allowed([
  'User'
  'Group'
])
param userPrincipalType string = 'User'

@description('Virtual Network Name')
param vnetName string = '${projectName}-vnet'

@description('Subnet Name for Dev Boxes')
param subnetName string = 'devbox-subnet'

// Variables
var devCenterName = '${projectName}-devcenter'
var devBoxProjectName = '${projectName}-project'
var networkConnectionName = '${projectName}-network'
var devBoxDefinitionName = '${projectName}-definition'
var devBoxPoolName = '${projectName}-pool'

// Create Virtual Network if needed
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.DevCenter'
            }
          ]
        }
      }
    ]
  }
  tags: {
    project: projectName
    managedBy: 'red-hat-developer-hub'
    developer: developerName
    team: teamName
  }
}

// Create Dev Center
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: location
  properties: {}
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    project: projectName
    managedBy: 'red-hat-developer-hub'
    developer: developerName
    team: teamName
  }
}

// Create Network Connection
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' = {
  name: networkConnectionName
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: '${vnet.id}/subnets/${subnetName}'
    networkingResourceGroupName: '${resourceGroup().name}-networking'
  }
  tags: {
    project: projectName
    managedBy: 'red-hat-developer-hub'
    developer: developerName
    team: teamName
  }
}

// Attach Network Connection to Dev Center
resource networkConnectionAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: devCenter
  name: networkConnectionName
  properties: {
    networkConnectionId: networkConnection.id
  }
}

// Create Dev Box Definition
resource devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-02-01' = {
  parent: devCenter
  name: devBoxDefinitionName
  location: location
  properties: {
    imageReference: {
      id: '${devCenter.id}/galleries/default/images/microsoftwindowsdesktop_windows-11_win11-22h2-ent'
    }
    sku: {
      name: devBoxSize
    }
    osStorageType: 'ssd_1024gb'
    hibernateSupport: 'Enabled'
  }
}

// Create Dev Box Project
resource devBoxProject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: devBoxProjectName
  location: location
  properties: {
    devCenterId: devCenter.id
    description: 'Three Horizons AI Development Project for ${developerName}'
  }
  tags: {
    project: projectName
    managedBy: 'red-hat-developer-hub'
    developer: developerName
    team: teamName
  }
}

// Create Dev Box Pool
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-02-01' = {
  parent: devBoxProject
  name: devBoxPoolName
  properties: {
    devBoxDefinitionName: devBoxDefinitionName
    networkConnectionName: networkConnectionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    stopOnDisconnect: {
      status: 'Enabled'
      gracePeriodMinutes: 60
    }
  }
  location: location
  dependsOn: [
    networkConnectionAttachment
    devBoxDefinition
  ]
}

// Role assignment for Dev Box User
resource devBoxUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(devBoxProject.id, userPrincipalId, 'DevCenter Dev Box User')
  scope: devBoxProject
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '45d50f46-0b78-4001-a660-4198cbe8cd05') // DevCenter Dev Box User
    principalId: userPrincipalId
    principalType: userPrincipalType
  }
}

// Outputs
output devCenterName string = devCenter.name
output devCenterResourceId string = devCenter.id
output projectName string = devBoxProject.name
output projectResourceId string = devBoxProject.id
output poolName string = devBoxPool.name
output poolResourceId string = devBoxPool.id
output devBoxPortalUrl string = 'https://devbox.microsoft.com'
output vnetId string = vnet.id
output subnetId string = '${vnet.id}/subnets/${subnetName}'

// Instructions for next steps
output nextSteps object = {
  step1: 'Access the Dev Box Portal at https://devbox.microsoft.com'
  step2: 'Create a new Dev Box using the ${devBoxPoolName} pool'
  step3: 'Connect to your Dev Box and run the setup script'
  step4: 'Start developing with the Three Horizons AI Platform!'
}
