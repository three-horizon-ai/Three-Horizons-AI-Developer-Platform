// Azure Dev Box - Simplified Template
// This version addresses common 500 errors by using a more basic approach

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

@description('Unique identifier for resource naming (use timestamp: yyyyMMdd-HHmm)')
param instanceId string

// Variables - Following Azure naming conventions with uniqueness
var uniqueSuffix = uniqueString(resourceGroup().id, projectName, instanceId)

// Resource names following Azure naming conventions: {resource-type}-{workload}-{environment}-{region}-{instance}-{unique}
// Using Azure resource abbreviations from CAF: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var devCenterName = 'dc-${projectName}-dev-${location}-${take(instanceId, 8)}-${take(uniqueSuffix, 6)}'
var devBoxProjectName = 'dbp-${projectName}-dev-${location}-${take(instanceId, 8)}-${take(uniqueSuffix, 6)}'
var devBoxDefinitionName = 'dbd-${projectName}-dev-${location}-${take(instanceId, 8)}-${take(uniqueSuffix, 6)}'
var devBoxPoolName = 'pool-${projectName}-dev-${location}-${take(instanceId, 8)}-${take(uniqueSuffix, 6)}'
var networkConnectionName = 'nc-${projectName}-dev-${location}-${take(instanceId, 8)}-${take(uniqueSuffix, 6)}'

// Common tags for all resources
var commonTags = {
  project: projectName
  managedBy: 'red-hat-developer-hub'
  developer: developerName
  team: teamName
  instanceId: instanceId
  environment: 'development'
  createdBy: 'bicep-template'
}
var vnetName = '${projectName}-vnet'

// Create Virtual Network
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
        name: 'devbox-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
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

// Create Dev Center first
resource devCenter 'Microsoft.DevCenter/devcenters@2024-02-01' = {
  name: devCenterName
  location: location
  properties: {}
  identity: {
    type: 'SystemAssigned'
  }
  tags: commonTags
}

// Create Network Connection
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-02-01' = {
  name: networkConnectionName
  location: location
  properties: {
    networkingResourceGroupName: resourceGroup().name
    domainJoinType: 'AzureADJoin'
  }
  tags: commonTags
}

// Attach Network Connection to Dev Center
resource networkConnectionAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-02-01' = {
  parent: devCenter
  name: networkConnectionName
  properties: {
    networkConnectionId: networkConnection.id
  }
}

// Create Dev Box Definition with marketplace image
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
    osStorageType: 'ssd_512gb'
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
  tags: commonTags
}

// Create Dev Box Pool (with network connection)
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
    devBoxDefinition
    networkConnectionAttachment
  ]
}

// Role assignment for Dev Box User
resource devBoxUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(devBoxProject.id, userPrincipalId, 'DevCenter Dev Box User')
  scope: devBoxProject
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '45d50f46-0b78-4001-a660-4198cbe8cd05') // DevCenter Dev Box User
    principalId: userPrincipalId
    principalType: 'User'
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

// Instructions for next steps
output nextSteps object = {
  step1: 'Access the Dev Box Portal at https://devbox.microsoft.com'
  step2: 'Create a new Dev Box using the ${devBoxPoolName} pool'
  step3: 'Connect to your Dev Box and install additional tools'
  step4: 'Start developing with the Three Horizons AI Platform!'
  note: 'This simplified version uses Windows 11 base image without custom networking'
}
