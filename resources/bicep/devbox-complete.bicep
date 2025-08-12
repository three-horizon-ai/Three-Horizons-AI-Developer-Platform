// Azure Dev Box - Complete Hub-Spoke Architecture Orchestrator
// Deploys hub infrastructure and individual project in a single resource group
// Following Azure best practices for centralized Dev Box management

targetScope = 'resourceGroup'

@description('Organization name for the Dev Box environment')
param organizationName string

@description('Project name for the initial Dev Box project')
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

@description('Network configuration type')
@allowed(['microsoft-hosted', 'azure-network'])
param networkType string = 'microsoft-hosted'

@description('VNet address space for Azure network connection (required if networkType is azure-network)')
param vnetAddressSpace string = '10.0.0.0/16'

@description('Subnet address space for dev boxes (required if networkType is azure-network)')
param devboxSubnetAddressSpace string = '10.0.1.0/24'

@description('Dev Box definition to use for the initial project')
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

// Deploy Hub Infrastructure (Dev Center, Network, Definitions)
module hubInfrastructure 'devbox-hub-architecture.bicep' = {
  name: 'devbox-hub-${instanceId}'
  params: {
    organizationName: organizationName
    location: location
    environment: environment
    instanceId: instanceId
    networkType: networkType
    vnetAddressSpace: vnetAddressSpace
    devboxSubnetAddressSpace: devboxSubnetAddressSpace
  }
}

// Deploy Initial Project
module initialProject 'devbox-project.bicep' = {
  name: 'devbox-project-${projectName}-${instanceId}'
  params: {
    projectName: projectName
    location: location
    developerName: developerName
    teamName: teamName
    environment: environment
    instanceId: instanceId
    devCenterId: hubInfrastructure.outputs.devCenterId
    networkConnectionName: hubInfrastructure.outputs.networkConnectionName
    devBoxDefinition: devBoxDefinition
    userPrincipalId: userPrincipalId
    maxDevBoxesPerUser: maxDevBoxesPerUser
    autoStopEnabled: autoStopEnabled
    autoStopGracePeriodMinutes: autoStopGracePeriodMinutes
  }
}

// Outputs
output hubInfrastructure object = {
  devCenterId: hubInfrastructure.outputs.devCenterId
  devCenterName: hubInfrastructure.outputs.devCenterName
  networkConnectionName: hubInfrastructure.outputs.networkConnectionName
  networkConnectionId: hubInfrastructure.outputs.networkConnectionId
  vnetId: hubInfrastructure.outputs.vnetId
  vnetName: hubInfrastructure.outputs.vnetName
  availableDefinitions: hubInfrastructure.outputs.availableDefinitions
  instanceId: hubInfrastructure.outputs.instanceId
  resourceGroupName: hubInfrastructure.outputs.resourceGroupName
}

output initialProject object = {
  projectId: initialProject.outputs.projectId
  projectName: initialProject.outputs.projectName
  poolId: initialProject.outputs.poolId
  poolName: initialProject.outputs.poolName
  devBoxDefinitionUsed: initialProject.outputs.devBoxDefinitionUsed
  maxDevBoxesPerUser: initialProject.outputs.maxDevBoxesPerUser
  autoStopEnabled: initialProject.outputs.autoStopEnabled
  developerPortalUrl: initialProject.outputs.developerPortalUrl
  projectSummary: initialProject.outputs.projectSummary
}

output deploymentSummary object = {
  deploymentType: 'hub-spoke-architecture'
  organizationName: organizationName
  environment: environment
  location: location
  instanceId: instanceId
  networkType: networkType
  totalProjects: 1
  hubDevCenter: hubInfrastructure.outputs.devCenterName
  initialProject: initialProject.outputs.projectName
  developerPortalUrl: 'https://devbox.microsoft.com/'
  managementPortalUrl: 'https://portal.azure.com/#view/Microsoft_Azure_DevCenter/DevCenterMenuBlade/~/overview'
  nextSteps: [
    'Access the developer portal at https://devbox.microsoft.com/'
    'Create additional projects using the devbox-project.bicep template'
    'Configure team-specific dev box definitions if needed'
    'Set up CI/CD pipelines for automated dev box management'
  ]
}

output availableDevBoxDefinitions array = hubInfrastructure.outputs.availableDefinitions

output resourceNaming object = {
  pattern: '{resource-type}-{organization/project}-{environment}-{location}-{unique-suffix}'
  example: hubInfrastructure.outputs.devCenterName
  instanceId: instanceId
  uniqueSuffix: take(uniqueString(resourceGroup().id, organizationName, instanceId), 6)
}
