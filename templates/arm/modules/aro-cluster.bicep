@description('Name of the ARO cluster.')
param clusterName string = 'aro-threehorizons'

@description('Location of the ARO cluster.')
param location string = 'centralus'

@description('Name of the Virtual Network.')
param vnetName string = 'vnet-threehorizons'

@description('Name of the master node subnet.')
param masterSubnetName string = 'master-subnet'

@description('Name of the worker node subnet.')
param workerSubnetName string = 'worker-subnet'

@description('Client ID of the Microsoft Entra ID service principal.')
param clientId string

@description('Client Secret of the Microsoft Entra ID service principal.')
@secure()
param clientSecret string

@description('Customer Resource ID of the Virtual Network.')
param vnetId string

@description('Resource ID of the master node subnet.')
param masterSubnetId string

@description('Resource ID of the worker node subnet.')
param workerSubnetId string

@description('Domain prefix for the ARO cluster.')
param domain string = 'threehorizons'

@description('Path to the Red Hat Pull Secret file.')
@secure()
param pullSecret string

@description('Set to false to disable public API server endpoint.')
param apiServerVisibility string = 'Public'

@description('Set to false to disable public ingress.')
param ingressVisibility string = 'Public'

@description('Number of worker nodes. Must be between 3 and 20.')
@minValue(3)
@maxValue(20)
param workerCount int = 3

@description('VM size for worker nodes. Refer to ARO docs for valid values.')
param workerVmSize string = 'Standard_D4s_v3'

@description('Type of outbound connectivity for the cluster.')
@allowed([
  'Loadbalancer'
  'UserDefinedRouting'
])
param outboundType string = 'Loadbalancer'

resource aroCluster 'Microsoft.RedHatOpenShift/openShiftClusters@2022-04-01' = {
  name: clusterName
  location: location
  properties: {
    clusterProfile: {
      domain: domain
      resourceGroupId: resourceGroup().id
      pullSecret: pullSecret
    }
    networkProfile: {
      podCidr: '10.128.0.0/14'
      serviceCidr: '172.30.0.0/16'
      outboundType: outboundType
    }
    servicePrincipalProfile: {
      clientId: clientId
      clientSecret: clientSecret
    }
    masterProfile: {
      vmSize: 'Standard_D8s_v3'
      subnetId: masterSubnetId
    }
    workerProfiles: [
      {
        name: 'worker'
        vmSize: workerVmSize
        diskSizeGB: 128
        subnetId: workerSubnetId
        count: workerCount
      }
    ]
    apiserverProfile: {
      visibility: apiServerVisibility
    }
    ingressProfiles: [
      {
        name: 'default'
        visibility: ingressVisibility
      }
    ]
  }
}

output apiServerUrl string = aroCluster.properties.apiserverProfile.url
output consoleUrl string = aroCluster.properties.consoleProfile.url 
