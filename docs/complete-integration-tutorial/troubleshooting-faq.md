# 🛠️ Three Horizons Platform - Troubleshooting & FAQ

## 📋 Table of Contents

- [Common Issues & Solutions](#common-issues--solutions)
- [Infrastructure Troubleshooting](#infrastructure-troubleshooting)
- [Developer Hub Issues](#developer-hub-issues)
- [GitHub Integration Problems](#github-integration-problems)
- [CI/CD Pipeline Failures](#cicd-pipeline-failures)
- [Monitoring & Observability](#monitoring--observability)
- [Security & Compliance](#security--compliance)
- [Performance Optimization](#performance-optimization)
- [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
- [Support & Resources](#support--resources)

## 🔧 Common Issues & Solutions

### Quick Diagnostics Commands

```bash
# Platform health check
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running
kubectl top nodes
kubectl top pods --all-namespaces

# Developer Hub status
kubectl get pods -n developer-hub
kubectl logs -n developer-hub deployment/developer-hub --tail=100

# Check ingress and services
kubectl get ingress --all-namespaces
kubectl get svc --all-namespaces
```

### Common Error Messages

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `Error: configmaps "developer-hub-config" not found` | Configuration not applied | Apply the ConfigMap from Phase 3 |
| `Failed to pull image` | Registry authentication issue | Check container registry credentials |
| `CrashLoopBackOff` | Application startup failure | Check pod logs for specific errors |
| `Pending` pod status | Resource constraints or PVC issues | Check node resources and storage classes |

## 🏗️ Infrastructure Troubleshooting

### AKS/ARO Cluster Issues

#### Problem: Cluster creation fails

```bash
# Check Azure provider registration
az provider show -n Microsoft.ContainerService --query registrationState
az provider show -n Microsoft.RedHatOpenShift --query registrationState

# If not registered
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift

# Check quotas
az vm list-usage --location "East US" --output table
```

#### Problem: Node pool scaling issues

```bash
# Check current node pool status
az aks nodepool list --resource-group three-horizons-rg --cluster-name three-horizons-aks

# Scale manually if autoscaler fails
az aks nodepool scale \
  --resource-group three-horizons-rg \
  --cluster-name three-horizons-aks \
  --name systempool \
  --node-count 5
```

#### Problem: Network connectivity issues

```bash
# Deploy network debug pod
kubectl run netshoot --rm -i --tty --image nicolaka/netshoot -- /bin/bash

# Inside the pod, test connectivity
nslookup kubernetes.default
curl -v telnet://developer-hub.developer-hub.svc.cluster.local:7007
```

### Azure Resource Issues

#### Problem: Key Vault access denied

```bash
# Check current permissions
az keyvault show --name $KEY_VAULT_NAME --query "properties.accessPolicies[?objectId=='$(az account show --query user.name -o tsv)']"

# Add required permissions
az keyvault set-policy --name $KEY_VAULT_NAME \
  --object-id $(az ad signed-in-user show --query id -o tsv) \
  --secret-permissions get list set delete \
  --certificate-permissions get list create delete
```

#### Problem: PostgreSQL connection failures

```bash
# Test connectivity from cluster
kubectl run psql-test --rm -i --tty --image postgres:14 -- bash
psql -h <your-postgres-host> -U backstage -d backstage -c "SELECT 1"

# Check firewall rules
az postgres flexible-server firewall-rule list \
  --resource-group three-horizons-shared \
  --server-name <your-server-name>
```

## 🎯 Developer Hub Issues

### Problem: Developer Hub won't start

```bash
# Check operator status
kubectl get pods -n developer-hub | grep operator
kubectl logs -n developer-hub -l name=rhdh-operator

# Check instance status
kubectl get backstage -n developer-hub
kubectl describe backstage developer-hub -n developer-hub

# Check events
kubectl get events -n developer-hub --sort-by='.lastTimestamp'
```

### Problem: Database connection errors

```yaml
# Verify secret exists and has correct data
kubectl get secret developer-hub-postgres -n developer-hub -o yaml

# Test connection from Developer Hub pod
kubectl exec -it -n developer-hub deployment/developer-hub -- sh
nc -zv <postgres-host> 5432
```

### Problem: Plugin loading failures

```bash
# Check dynamic plugins configuration
kubectl get configmap -n developer-hub -l rhdh.redhat.com/dynamic-plugins
kubectl describe configmap -n developer-hub dynamic-plugins-config

# View plugin loading logs
kubectl logs -n developer-hub deployment/developer-hub | grep -i plugin
```

### Problem: UI displays errors or blank pages

```bash
# Check for JavaScript errors in pod logs
kubectl logs -n developer-hub deployment/developer-hub | grep -i error

# Verify app-config is properly mounted
kubectl exec -n developer-hub deployment/developer-hub -- cat /opt/app-root/src/app-config.yaml

# Check ingress configuration
kubectl describe ingress developer-hub -n developer-hub
```

## 🔗 GitHub Integration Problems

### Problem: GitHub authentication fails

```bash
# Verify GitHub App credentials
kubectl get secret github-app-credentials -n developer-hub -o jsonpath='{.data}' | base64 -d

# Check GitHub App installation
curl -H "Authorization: Bearer $(kubectl get secret github-app-credentials -n developer-hub -o jsonpath='{.data.GITHUB_TOKEN}' | base64 -d)" \
  https://api.github.com/app/installations

# Test webhook connectivity
curl -X POST https://devhub.example.com/api/github/webhook \
  -H "X-GitHub-Event: ping" \
  -H "X-Hub-Signature: sha1=test"
```

### Problem: Repository discovery not working

```yaml
# Check catalog configuration
kubectl get configmap app-config-github-users -n developer-hub -o yaml

# Manually trigger discovery
kubectl exec -n developer-hub deployment/developer-hub -- \
  curl -X POST http://localhost:7007/api/catalog/refresh
```

### Problem: GitHub API rate limits

```bash
# Check current rate limit status
curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# Implement caching proxy if needed
helm install github-proxy ./charts/github-proxy \
  --set github.token=$GITHUB_TOKEN \
  --namespace developer-hub
```

## 🚀 CI/CD Pipeline Failures

### Problem: GitHub Actions can't authenticate to Azure

```bash
# Verify federated credentials
az ad app federated-credential list --id $AZURE_CLIENT_ID

# Test OIDC token exchange
curl -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://AzureADTokenExchange"
```

### Problem: Container build failures

```yaml
# Check GitHub Actions logs for specific errors
# Common fixes:

# 1. For multi-platform builds
- name: Set up QEMU
  uses: docker/setup-qemu-action@v3

# 2. For build cache issues
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
    cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
```

### Problem: Deployment failures

```bash
# Check GitOps sync status (Flux)
flux get sources git
flux get kustomizations
flux logs --follow

# Check GitOps sync status (ArgoCD)
argocd app get three-horizons-app
argocd app sync three-horizons-app
```

## 📊 Monitoring & Observability

### Problem: Prometheus not collecting metrics

```bash
# Check ServiceMonitor configuration
kubectl get servicemonitor --all-namespaces
kubectl describe servicemonitor developer-hub -n monitoring

# Verify metrics endpoint
kubectl port-forward -n developer-hub svc/developer-hub 7007:7007
curl http://localhost:7007/metrics
```

### Problem: Grafana dashboards showing no data

```bash
# Check datasource configuration
kubectl exec -n monitoring deployment/prometheus-grafana -- \
  curl -s http://localhost:3000/api/datasources

# Test Prometheus query
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open http://localhost:9090 and test queries
```

### Problem: Datadog agent not reporting

```bash
# Check agent status
kubectl exec -n monitoring -it $(kubectl get pods -n monitoring -l app=datadog -o jsonpath='{.items[0].metadata.name}') -- agent status

# Check API key
kubectl get secret datadog -n monitoring -o jsonpath='{.data.api-key}' | base64 -d

# Force a check
kubectl exec -n monitoring -it $(kubectl get pods -n monitoring -l app=datadog -o jsonpath='{.items[0].metadata.name}') -- agent check kubernetes_state
```

## 🔐 Security & Compliance

### Problem: RBAC permission denied

```bash
# Check current permissions
kubectl auth can-i --list --as=system:serviceaccount:developer-hub:developer-hub

# Grant required permissions
kubectl create clusterrolebinding developer-hub-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=developer-hub:developer-hub
```

### Problem: Secret scanning alerts

```bash
# Scan for exposed secrets
trufflehog git https://github.com/your-org/your-repo --only-verified

# Rotate compromised secrets
kubectl create secret generic github-app-credentials \
  --from-literal=GITHUB_TOKEN='new-token' \
  --namespace developer-hub \
  --dry-run=client -o yaml | kubectl apply -f -
```

## ⚡ Performance Optimization

### Problem: Slow application response times

```bash
# Check resource utilization
kubectl top pods -n developer-hub
kubectl describe pod -n developer-hub <pod-name>

# Scale horizontally
kubectl scale deployment developer-hub -n developer-hub --replicas=3

# Enable HPA
kubectl autoscale deployment developer-hub -n developer-hub \
  --cpu-percent=70 \
  --min=2 \
  --max=10
```

### Problem: Database performance issues

```sql
-- Check slow queries
SELECT query, calls, mean_exec_time, total_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;

-- Check connection count
SELECT count(*) FROM pg_stat_activity;

-- Optimize connection pooling
ALTER SYSTEM SET max_connections = 200;
```

## ❓ Frequently Asked Questions (FAQ)

### General Questions

**Q: What versions of Red Hat Developer Hub are supported?**
A: The platform is designed for RHDH 1.6+. Version 1.5 is also supported with minor configuration adjustments.

**Q: Can I use this with GitHub.com instead of GitHub Enterprise?**
A: Yes, the platform works with both GitHub.com and GitHub Enterprise. Adjust the GitHub host configuration accordingly.

**Q: Is air-gapped installation supported?**
A: Yes, RHDH 1.6 supports air-gapped installations. You'll need to mirror required images and configure local registries.

### Deployment Questions

**Q: How long does the full deployment take?**
A: Typical deployment times:
- Infrastructure: 15-20 minutes
- AKS cluster: 10-15 minutes  
- Developer Hub: 5-10 minutes
- Full platform: 45-60 minutes

**Q: Can I deploy to multiple regions?**
A: Yes, use the multi-region deployment pattern with Azure Traffic Manager or Front Door for global load balancing.

**Q: What are the minimum resource requirements?**
A: 
- Development: 3 nodes (4 vCPU, 16GB RAM each)
- Production: 5+ nodes (8 vCPU, 32GB RAM each)
- Database: 2 vCPU, 8GB RAM minimum

### Integration Questions

**Q: Can I integrate with other CI/CD tools besides GitHub Actions?**
A: Yes, the platform supports Azure DevOps, GitLab CI, Jenkins, and other CI/CD tools through webhooks and API integration.

**Q: Is multi-cloud deployment supported?**
A: Yes, you can deploy components across Azure, AWS, and GCP. Use Datadog or similar tools for unified monitoring.

**Q: Can I use my existing Active Directory?**
A: Yes, configure Microsoft Entra ID (formerly Azure AD) integration with your on-premises AD through Azure AD Connect.

### Troubleshooting Questions

**Q: How do I access logs for debugging?**
A: Use these commands:
```bash
# All Developer Hub logs
kubectl logs -n developer-hub deployment/developer-hub --all-containers=true

# Specific time range
kubectl logs -n developer-hub deployment/developer-hub --since=1h

# Follow logs in real-time
kubectl logs -n developer-hub deployment/developer-hub -f
```

**Q: How do I backup the platform?**
A: Implement these backup strategies:
- Database: Azure PostgreSQL automatic backups
- Kubernetes: Velero for cluster state backup
- Configurations: Git repository for IaC

**Q: How do I upgrade the platform?**
A: Follow the rolling upgrade process:
1. Backup current state
2. Update operator version
3. Update Developer Hub instance
4. Verify functionality
5. Update dependent services

## 📞 Support & Resources

### Getting Help

1. **Documentation Resources**
   - [Three Horizons Platform Docs](../index.md)
   - [Red Hat Developer Hub Docs](https://developers.redhat.com/rhdh)
   - [Azure AKS Docs](https://docs.microsoft.com/azure/aks)
   - [GitHub Enterprise Docs](https://docs.github.com/enterprise-cloud)

2. **Community Support**
   - Red Hat Developer Hub Community Forum
   - Azure Kubernetes Service Forum
   - GitHub Community Discussions

3. **Enterprise Support**
   - Red Hat Support Portal: [access.redhat.com](https://access.redhat.com)
   - Azure Support: [azure.microsoft.com/support](https://azure.microsoft.com/support)
   - GitHub Enterprise Support: [support.github.com](https://support.github.com)

4. **Diagnostic Information to Collect**
   ```bash
   # Generate support bundle
   mkdir support-bundle
   kubectl cluster-info dump --output-directory=support-bundle
   kubectl get events --all-namespaces > support-bundle/events.log
   kubectl logs -n developer-hub deployment/developer-hub > support-bundle/devhub.log
   tar -czf support-bundle-$(date +%Y%m%d-%H%M%S).tar.gz support-bundle/
   ```

### Useful Links

- [Platform Status Page](https://status.threehorizons.io)
- [Security Advisories](https://github.com/your-org/three-horizons-platform/security/advisories)
- [Release Notes](https://github.com/your-org/three-horizons-platform/releases)
- [Contributing Guide](https://github.com/your-org/three-horizons-platform/contributing)

---

> 💡 **Pro Tip**: Always check the [official troubleshooting guide](troubleshooting.md) specific to your deployment type (AKS/ARO) for additional platform-specific solutions. 