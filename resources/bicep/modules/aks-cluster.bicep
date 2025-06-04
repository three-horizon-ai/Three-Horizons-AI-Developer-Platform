@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = clusterName

@description('Disk size (in GB) to provision for each of the agent pool nodes.')
@minValue(30)
@maxValue(1023)
param osDiskSizeGB int = 100

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_D4s_v3'

@description('The virtual network subnet ID used for nodes and/or pods IP assignment.')
param subnetId string

@description('Kubernetes version')
param kubernetesVersion string = '1.28.3'

@description('Network plugin')
@allowed(['azure', 'kubenet', 'none'])
param networkPlugin string = 'azure'

@description('Network plugin mode')
@allowed(['', 'overlay'])
param networkPluginMode string = 'overlay'

@description('Network policy')
@allowed(['', 'azure', 'calico', 'cilium'])
param networkPolicy string = 'azure'

@description('Service CIDR')
param serviceCidr string = '10.2.0.0/24'

@description('DNS service IP')
param dnsServiceIP string = '10.2.0.10'

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('Enable Azure RBAC')
param enableAzureRBAC bool = true

@description('Enable Workload Identity')
param enableWorkloadIdentity bool = true

@description('Enable OIDC Issuer')
param enableOidcIssuer bool = true

// AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    enableRBAC: true
    aadProfile: enableAzureRBAC ? {
      managed: true
      enableAzureRBAC: true
    } : null
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnetId
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: true
        minCount: 2
        maxCount: 5
        maxPods: 110
        availabilityZones: ['1', '2', '3']
      }
    ]
    networkProfile: {
      networkPlugin: networkPlugin
      networkPluginMode: networkPluginMode
      networkPolicy: networkPolicy
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
      azurepolicy: {
        enabled: true
      }
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    oidcIssuerProfile: {
      enabled: enableOidcIssuer
    }
    securityProfile: {
      workloadIdentity: {
        enabled: enableWorkloadIdentity
      }
      defender: {
        logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceId
        securityMonitoring: {
          enabled: true
        }
      }
    }
  }
}

// Outputs
output aksClusterId string = aksCluster.id
output aksClusterName string = aksCluster.name
output aksClusterFqdn string = aksCluster.properties.fqdn
output aksOidcIssuerUrl string = enableOidcIssuer ? aksCluster.properties.oidcIssuerProfile.issuerURL : ''
output aksManagedIdentityPrincipalId string = aksCluster.identity.principalId
output nodeResourceGroup string = aksCluster.properties.nodeResourceGroup 
