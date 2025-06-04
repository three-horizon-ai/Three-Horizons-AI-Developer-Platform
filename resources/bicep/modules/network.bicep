@description('The name of the virtual network')
param vnetName string

@description('Location for all resources')
param location string

@description('Virtual network address space')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Tags to apply to resources')
param tags object = {}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// AKS Subnet
resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'aks-subnet'
  properties: {
    addressPrefix: '10.0.0.0/22'
    serviceEndpoints: [
      {
        service: 'Microsoft.ContainerRegistry'
      }
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
    ]
  }
}

// Services Subnet
resource servicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'services-subnet'
  dependsOn: [aksSubnet]
  properties: {
    addressPrefix: '10.0.4.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
}

// Private Endpoints Subnet
resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'endpoint-subnet'
  dependsOn: [servicesSubnet]
  properties: {
    addressPrefix: '10.0.5.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

// ARO Master Subnet (optional)
resource aroMasterSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'aro-master-subnet'
  dependsOn: [privateEndpointSubnet]
  properties: {
    addressPrefix: '10.0.8.0/23'
    serviceEndpoints: [
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ]
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

// ARO Worker Subnet (optional)
resource aroWorkerSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'aro-worker-subnet'
  dependsOn: [aroMasterSubnet]
  properties: {
    addressPrefix: '10.0.10.0/23'
    serviceEndpoints: [
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ]
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${vnetName}-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Outputs
output vnetId string = vnet.id
output vnetName string = vnet.name
output aksSubnetId string = aksSubnet.id
output servicesSubnetId string = servicesSubnet.id
output privateEndpointSubnetId string = privateEndpointSubnet.id
output aroMasterSubnetId string = aroMasterSubnet.id
output aroWorkerSubnetId string = aroWorkerSubnet.id
output nsgId string = nsg.id 
