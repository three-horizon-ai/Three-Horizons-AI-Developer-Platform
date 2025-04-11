# AKS Cluster Configuration Examples

This directory contains configuration examples for Azure Kubernetes Service (AKS) clusters used in the Three Horizons Platform. These configurations demonstrate best practices for setting up secure, scalable, and production-ready Kubernetes environments.

## Included Configurations

This directory includes the following configurations:

- **Base AKS Cluster**: Core cluster configuration with recommended settings
- **Advanced Networking**: Private cluster setup with Azure CNI
- **Security Hardening**: Pod security policies and network policies
- **Scaling Configurations**: Cluster autoscaler and node pool settings
- **Monitoring Setup**: Prometheus and Grafana configurations

## Base AKS Cluster Configuration

The base configuration provides a starting point for AKS clusters:

```yaml
# aks-base-cluster.yaml
apiVersion: v1
kind: AksClusterConfig
metadata:
  name: three-horizons-aks
spec:
  location: eastus2
  kubernetesVersion: 1.25.6
  nodeResourceGroup: rg-three-horizons-aks-nodes
  networkProfile:
    networkPlugin: azure
    networkPolicy: calico
    serviceCidr: "10.0.0.0/16"
    dnsServiceIP: "10.0.0.10"
    dockerBridgeCidr: "172.17.0.1/16"
  identity:
    type: SystemAssigned
  nodePools:
    - name: systempool
      mode: System
      count: 3
      vmSize: Standard_DS2_v2
      osDiskSizeGB: 128
      osDiskType: Managed
      maxPods: 30
      availabilityZones: [1, 2, 3]
      enableAutoScaling: true
      minCount: 3
      maxCount: 5
    - name: userpool
      mode: User
      count: 3
      vmSize: Standard_DS3_v2
      osDiskSizeGB: 128
      osDiskType: Managed
      maxPods: 30
      availabilityZones: [1, 2, 3]
      enableAutoScaling: true
      minCount: 3
      maxCount: 10
  addonProfiles:
    omsagent:
      enabled: true
      config:
        logAnalyticsWorkspaceResourceID: "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"
    azurepolicy:
      enabled: true
    ingressApplicationGateway:
      enabled: true
      config:
        applicationGatewayId: "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Network/applicationGateways/{appgw-name}"
```

## Advanced Networking Configuration

```yaml
# aks-advanced-networking.yaml
apiVersion: v1
kind: AksClusterConfig
metadata:
  name: three-horizons-aks-private
spec:
  # Base configuration settings...
  networkProfile:
    networkPlugin: azure
    networkPolicy: calico
    serviceCidr: "10.0.0.0/16"
    dnsServiceIP: "10.0.0.10"
    dockerBridgeCidr: "172.17.0.1/16"
    outboundType: userDefinedRouting
  apiServerAccessProfile:
    enablePrivateCluster: true
    privateDNSZone: "system"
    enablePrivateClusterPublicFQDN: false
  # Additional private cluster settings...
```

## Security Hardening Configuration

```yaml
# aks-security-hardening.yaml
apiVersion: v1
kind: AksClusterConfig
metadata:
  name: three-horizons-aks-secure
spec:
  # Base configuration settings...
  securityProfile:
    azureKeyVaultKms:
      enabled: true
      keyId: "{key-vault-key-id}"
    defender:
      securityMonitoring:
        enabled: true
  apiServerAccessProfile:
    authorizedIPRanges:
      - "10.0.0.0/24"  # Example corporate IP range
    enablePrivateCluster: true
  # Additional security settings...
```

## Deployment Instructions

### Prerequisites

- Azure CLI installed and configured
- Sufficient permissions in your Azure subscription
- Required resource providers registered

### Deployment Steps

1. Create the AKS cluster using Azure CLI or ARM template:

```bash
# Using Azure CLI
az aks create -g MyResourceGroup -n ThreeHorizonsAKS --file ./aks-base-cluster.yaml

# Using ARM template
az deployment group create \
  --resource-group MyResourceGroup \
  --template-file ./aks-arm-template.json \
  --parameters ./aks-parameters.json
```

2. Connect to the AKS cluster:

```bash
az aks get-credentials -g MyResourceGroup -n ThreeHorizonsAKS
```

3. Apply additional Kubernetes configurations:

```bash
kubectl apply -f ./kubernetes-configs/
```

## Post-Deployment Configuration

After deploying the AKS cluster, you should:

1. **Configure RBAC**: Set up role-based access control for your team
2. **Set up GitOps**: Configure Flux or ArgoCD for GitOps deployment
3. **Implement Policies**: Apply Azure Policy for Kubernetes
4. **Set up Monitoring**: Configure alerts and dashboards
5. **Test the Cluster**: Run validation tests to ensure everything is working

## Best Practices

- **Uptime**: Use multiple node pools and availability zones for high availability
- **Security**: Implement network policies and pod security policies
- **Scalability**: Configure autoscaling based on actual workload needs
- **Governance**: Use Azure Policy to enforce compliance
- **Monitoring**: Set up comprehensive monitoring and alerting
- **Updates**: Plan for regular node and Kubernetes version updates

## References

- [Azure Kubernetes Service documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/overview/)
- [Three Horizons Network Architecture](../../docs/documentation/architecture/network-diagram.svg)
- [Three Horizons Security Architecture](../../docs/documentation/architecture/security-architecture.svg) 