# AKS Troubleshooting Guide

This guide provides detailed troubleshooting steps for common issues encountered when deploying and managing the Three Horizons Platform on Azure Kubernetes Service (AKS).

## Table of Contents
- [Deployment Issues](#deployment-issues)
- [Networking Issues](#networking-issues)
- [Developer Hub Issues](#developer-hub-issues)
- [GitHub Integration Issues](#github-integration-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)
- [Diagnostic Tools](#diagnostic-tools)

## Deployment Issues

### AKS Cluster Deployment Failures

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| Service quota exceeded | Deployment fails with error about quotas or limits | 1. Check Azure subscription quotas<br>2. Request quota increase if needed<br>3. Select a different region with available capacity |
| Network configuration errors | Deployment fails with network-related errors | 1. Verify subnet has enough IP addresses<br>2. Check if subnet is already in use<br>3. Ensure service endpoints are properly configured |
| Service principal issues | Authentication or permission errors | 1. Verify service principal exists and is valid<br>2. Check if service principal has correct permissions<br>3. Recreate service principal if necessary |
| Resource conflicts | "Resource already exists" errors | 1. Check for existing resources with same name<br>2. Delete or rename conflicting resources<br>3. Use unique naming patterns |

### Common AKS Deployment Error Codes

| Error Code | Description | Resolution |
|------------|-------------|------------|
| MissingSubscriptionRegistration | Required resource provider not registered | `az provider register --namespace Microsoft.ContainerService` |
| LinkedAuthorizationFailed | Insufficient permissions | Assign the appropriate role (e.g., Contributor) to the service principal |
| NetworkingInternalOperationError | Networking configuration issue | Verify VNET/subnet configuration and ensure no conflicting resources |
| QuotaExceeded | Exceeded Azure resource limits | Request quota increase through Azure portal |

## Networking Issues

### Pod Communication Problems

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| Pods can't reach external services | Connection timeouts or refused connections | 1. Check NSG rules on AKS subnet<br>2. Verify DNS configuration<br>3. Test network connectivity with debug pods |
| Services not accessible from outside | External traffic can't reach services | 1. Verify Ingress controller configuration<br>2. Check service type (LoadBalancer/ClusterIP)<br>3. Validate DNS records and routing |
| Inter-pod communication failures | Pods can't communicate with each other | 1. Check network policies<br>2. Verify Kubernetes service discovery<br>3. Test communication with debug pods |

### Network Diagnostics

Use the following commands for network diagnostics:

```bash
# Deploy network debugging pod
kubectl run network-debug --rm -i --tty --image=nicolaka/netshoot -- /bin/bash

# Test DNS resolution
kubectl exec -it network-debug -- nslookup kubernetes.default

# Test pod-to-pod connectivity
kubectl exec -it network-debug -- curl http://service-name.namespace.svc.cluster.local

# Check network policies
kubectl get networkpolicies --all-namespaces
```

## Developer Hub Issues

### Red Hat Developer Hub Connectivity Issues

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| Database connection failures | Developer Hub can't connect to PostgreSQL | 1. Verify PostgreSQL server is running<br>2. Check connection string and credentials<br>3. Ensure firewall rules allow AKS subnet access |
| GitHub integration failures | Can't authenticate with GitHub | 1. Verify OAuth configuration<br>2. Check GitHub token validity<br>3. Ensure correct callback URLs are configured |
| Missing or broken UI elements | UI components display errors or are missing | 1. Check pod logs for frontend errors<br>2. Verify configuration for plugins<br>3. Ensure all required services are running |

### Diagnosing Developer Hub Issues

```bash
# Check Developer Hub pod status
kubectl get pods -n developer-hub

# Check Developer Hub pod logs
kubectl logs -n developer-hub deployment/developer-hub

# Check Developer Hub configuration
kubectl get configmap -n developer-hub

# Check Developer Hub secrets (without revealing values)
kubectl get secrets -n developer-hub
```

## GitHub Integration Issues

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| GitHub Action runners can't connect to AKS | Deployment failures from GitHub Actions | 1. Verify OIDC trust configuration<br>2. Check permissions of service principal<br>3. Ensure kubeconfig is properly set up |
| Developer Hub can't access GitHub APIs | GitHub API rate limits or authentication failures | 1. Check GitHub token configuration<br>2. Verify OAuth application settings<br>3. Check for API rate limit issues |
| Webhook delivery failures | Actions not triggered by code changes | 1. Verify webhook configuration in GitHub<br>2. Check webhook logs for delivery issues<br>3. Ensure ingress routes webhook traffic correctly |

## Performance Issues

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| Node resource exhaustion | Nodes running at high CPU/memory | 1. Check pod resource requests/limits<br>2. Enable cluster autoscaler<br>3. Consider vertical scaling of node pool VMs |
| Slow container startup | Containers take long time to start | 1. Optimize container image size<br>2. Use multi-stage builds<br>3. Consider using image caching |
| Database performance | Slow Developer Hub operations | 1. Check PostgreSQL query performance<br>2. Optimize database configurations<br>3. Scale up database if needed |

### Performance Diagnostics

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods --all-namespaces

# Get detailed node information
kubectl describe node [node-name]

# Check events for performance issues
kubectl get events --sort-by='.lastTimestamp'
```

## Security Issues

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|------------------------|
| Unauthorized access | Unexpected access to resources | 1. Review RBAC configuration<br>2. Check service account permissions<br>3. Audit Kubernetes API server logs |
| Container security vulnerabilities | Security scanners report vulnerabilities | 1. Update container images<br>2. Apply security patches<br>3. Implement security policies |
| Secret exposure | Secrets visible in logs or environment | 1. Use proper Kubernetes secrets<br>2. Configure Key Vault integration<br>3. Audit access to secrets |

## Diagnostic Tools

### Essential kubectl Commands

```bash
# Get cluster information
kubectl cluster-info

# Check AKS node status
kubectl get nodes

# Check pod status across all namespaces
kubectl get pods --all-namespaces

# Describe a specific pod for detailed information
kubectl describe pod <pod-name> -n <namespace>

# Get logs from a pod
kubectl logs <pod-name> -n <namespace>

# Execute commands in a pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Check service endpoints
kubectl get endpoints -n <namespace>
```

### Azure CLI Diagnostics

```bash
# Get AKS cluster details
az aks show --resource-group <resource-group> --name <cluster-name>

# Get AKS diagnostics
az aks kanalyze --resource-group <resource-group> --name <cluster-name>

# Check AKS upgrade availability
az aks get-upgrades --resource-group <resource-group> --name <cluster-name>

# Run AKS diagnostics
az aks diagnostic run --resource-group <resource-group> --name <cluster-name>
```

## Getting Support

If you're unable to resolve the issue using this guide:

1. Check the [Azure Status page](https://status.azure.com/status) for potential Azure service outages
2. Review the [AKS Troubleshooting documentation](https://docs.microsoft.com/azure/aks/troubleshooting)
3. Open a support ticket with Microsoft Azure Support
4. For Developer Hub specific issues, consult the [Red Hat Developer Hub documentation](https://developers.redhat.com/developer-hub)
5. For GitHub Enterprise issues, consult the [GitHub Enterprise documentation](https://docs.github.com/enterprise-cloud) 