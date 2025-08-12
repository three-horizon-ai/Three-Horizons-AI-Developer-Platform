// Azure Dev Box - Project Template (Spoke)
// Creates individual projects that connect to a centralized Dev Center hub
// Following Azure best practices for hub-spoke architecture

targetScope = 'resourceGroup'

@description('Project name for the Dev Box project')
param projectName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Developer name for personalization')
param developerName string

@description('Team name')
param teamName string

@description('Environment type (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

@description('Unique identifier for this deployment (timestamp: yyyyMMdd-HHmm)')
param instanceId string

@description('Dev Center resource ID (from hub deployment)')
param devCenterId string

@description('Network Connection name (from hub deployment)')
param networkConnectionName string

@description('Dev Box definition to use for this project')
@allowed(['standard-dev-workstation', 'power-user-workstation', 'data-science-workstation'])
param devBoxDefinition string = 'standard-dev-workstation'

@description('User Principal ID for Dev Box access')
param userPrincipalId string

@description('Maximum number of dev boxes per developer (0 = unlimited)')
param maxDevBoxesPerUser int = 3

@description('Auto-stop settings for dev boxes')
param autoStopEnabled bool = true

@description('Auto-stop time in minutes of inactivity')
param autoStopGracePeriodMinutes int = 60

// Variables - Following Azure naming conventions
var uniqueSuffix = uniqueString(resourceGroup().id, projectName, instanceId)
var abbreviations = {
  project: 'dbp'
  pool: 'pool'
}

// Extract Dev Center name from resource ID
var devCenterName = last(split(devCenterId, '/'))

// Resource names following Azure CAF naming conventions
var devBoxProjectName = '${abbreviations.project}-${projectName}-${environment}-${location}-${take(uniqueSuffix, 6)}'
var devBoxPoolName = '${abbreviations.pool}-${projectName}-${environment}-${location}-${take(uniqueSuffix, 6)}'

// Common tags for all resources
var commonTags = {
  project: projectName
  environment: environment
  managedBy: 'red-hat-developer-hub'
  developer: developerName
  team: teamName
  instanceId: instanceId
  deploymentDate: instanceId
  architecture: 'hub-spoke'
  purpose: 'dev-box-project'
  parentDevCenter: devCenterName
}

// Create Dev Box Project
resource devBoxProject 'Microsoft.DevCenter/projects@2024-02-01' = {
  name: devBoxProjectName
  location: location
  properties: {
    devCenterId: devCenterId
    description: 'Three Horizons AI Development Project for ${teamName} - ${developerName}'
    maxDevBoxesPerUser: maxDevBoxesPerUser == 0 ? null : maxDevBoxesPerUser
  }
  tags: commonTags
}

// Create Dev Box Pool
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2024-02-01' = {
  parent: devBoxProject
  name: devBoxPoolName
  location: location
  properties: {
    devBoxDefinitionName: devBoxDefinition
    networkConnectionName: networkConnectionName
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    stopOnDisconnect: autoStopEnabled ? {
      status: 'Enabled'
      gracePeriodMinutes: autoStopGracePeriodMinutes
    } : {
      status: 'Disabled'
    }
    singleSignOnStatus: 'Enabled'
    displayName: '${teamName} Development Pool'
    virtualNetworkType: 'Managed'
  }
  tags: union(commonTags, {
    poolType: devBoxDefinition
    autoStop: string(autoStopEnabled)
  })
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

// Optional: Project Admin role assignment for team lead
resource projectAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(teamName)) {
  name: guid(devBoxProject.id, userPrincipalId, 'DevCenter Project Admin')
  scope: devBoxProject
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '331c37c6-af14-46d9-b9f4-e1909e1b95a0') // DevCenter Project Admin
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// Outputs
output projectId string = devBoxProject.id
output projectName string = devBoxProject.name
output poolId string = devBoxPool.id
output poolName string = devBoxPool.name
output devBoxDefinitionUsed string = devBoxDefinition
output maxDevBoxesPerUser int = maxDevBoxesPerUser
output autoStopEnabled bool = autoStopEnabled
output developerPortalUrl string = 'https://devbox.microsoft.com/'
output projectSummary object = {
  projectName: devBoxProject.name
  poolName: devBoxPool.name
  devBoxDefinition: devBoxDefinition
  team: teamName
  developer: developerName
  maxDevBoxes: maxDevBoxesPerUser
  autoStop: autoStopEnabled
  location: location
  instanceId: instanceId
}
output commonTags object = commonTags
