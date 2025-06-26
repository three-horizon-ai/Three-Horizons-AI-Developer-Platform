# 🔧 Troubleshooting & FAQ - Three Horizons AI Platform

<div align="center">

**Quick Solutions for Common Issues**

</div>

## 📋 Table of Contents

1. [Quick Diagnostics](#-quick-diagnostics)
2. [Common Issues](#-common-issues)
3. [Infrastructure Problems](#-infrastructure-problems)
4. [Developer Hub Issues](#-developer-hub-issues)
5. [CI/CD Pipeline Problems](#-cicd-pipeline-problems)
6. [AI Services Troubleshooting](#-ai-services-troubleshooting)
7. [Security & Access Issues](#-security--access-issues)
8. [Performance Problems](#-performance-problems)
9. [Frequently Asked Questions](#-frequently-asked-questions)
10. [Getting Help](#-getting-help)

## 🔍 Quick Diagnostics

### Platform Health Check Script

```bash
#!/bin/bash
# platform-health-check.sh

echo "🏥 Three Horizons Platform Health Check"
echo "======================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check functions
check_service() {
    local service=$1
    local namespace=$2
    local expected_replicas=$3
    
    echo -n "Checking $service... "
    
    ready_replicas=$(kubectl get deployment -n $namespace $service -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    
    if [[ -z "$ready_replicas" ]]; then
        echo -e "${RED}✗ Not found${NC}"
        return 1
    elif [[ "$ready_replicas" -ge "$expected_replicas" ]]; then
        echo -e "${GREEN}✓ Running ($ready_replicas/$expected_replicas replicas)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Degraded ($ready_replicas/$expected_replicas replicas)${NC}"
        return 2
    fi
}

check_pod_logs() {
    local namespace=$1
    local label=$2
    
    echo "Recent errors in $namespace:"
    kubectl logs -n $namespace -l $label --tail=10 --prefix=true 2>/dev/null | grep -i error || echo "  No errors found"
}

# Core Services
echo -e "\n🏗️ Core Services:"
check_service "ingress-nginx-controller" "ingress-nginx" 1
check_service "cert-manager" "cert-manager" 1
check_service "source-controller" "flux-system" 1

# Platform Components
echo -e "\n📚 Platform Components:"
check_service "developer-hub" "rhdh" 1
check_service "deployment-agent" "ai-services" 1

# Monitoring
echo -e "\n📊 Monitoring Stack:"
check_service "prometheus-kube-prometheus-prometheus" "monitoring" 1
check_service "grafana" "monitoring" 1

# Recent Errors
echo -e "\n❌ Recent Errors:"
check_pod_logs "rhdh" "app=developer-hub"
check_pod_logs "flux-system" "app=source-controller"
check_pod_logs "ai-services" "app=deployment-agent"

# Resource Usage
echo -e "\n💾 Resource Usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

# DNS Resolution
echo -e "\n🌐 DNS Resolution:"
kubectl run dns-test --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default 2>/dev/null && echo -e "${GREEN}✓ Internal DNS working${NC}" || echo -e "${RED}✗ DNS issues detected${NC}"

echo -e "\n✅ Health check complete!"
```

### Quick Debug Commands

```bash
# View all pods status
kubectl get pods --all-namespaces | grep -v Running

# Check recent events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20

# View resource usage
kubectl top nodes
kubectl top pods --all-namespaces | sort -k3 -nr | head -20

# Check ingress status
kubectl get ingress --all-namespaces

# View recent deployments
kubectl get deployments --all-namespaces -o wide | grep -v "1/1"

# Check PVC status
kubectl get pvc --all-namespaces | grep -v Bound

# View service endpoints
kubectl get endpoints --all-namespaces | grep -v "<none>"
```

## 🚨 Common Issues

### Issue: Platform Unreachable

**Symptoms:**
- Cannot access Developer Hub
- Services returning 502/503 errors
- DNS not resolving

**Diagnosis:**
```bash
# Check ingress controller
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Check ingress rules
kubectl get ingress --all-namespaces

# Test DNS
nslookup devhub.yourdomain.com

# Check certificates
kubectl get certificates --all-namespaces
```

**Solutions:**

1. **Ingress Controller Down:**
```bash
# Restart ingress controller
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx

# Check logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

2. **DNS Not Configured:**
```bash
# Get ingress IP
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Configure DNS A record: *.yourdomain.com -> $INGRESS_IP"
```

3. **Certificate Issues:**
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Manually trigger certificate renewal
kubectl delete certificate devhub-tls -n rhdh
```

### Issue: Pods Crashing/Restarting

**Symptoms:**
- Pods in CrashLoopBackOff
- High restart count
- Services unavailable

**Diagnosis:**
```bash
# Get pod status
kubectl get pods --all-namespaces | grep -v Running

# Check pod logs
kubectl logs -n <namespace> <pod-name> --previous

# Describe pod
kubectl describe pod -n <namespace> <pod-name>

# Check resource limits
kubectl top pod -n <namespace> <pod-name>
```

**Solutions:**

1. **Out of Memory:**
```yaml
# Increase memory limits
kubectl patch deployment <deployment> -n <namespace> --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/resources/limits/memory",
    "value": "2Gi"
  }
]'
```

2. **Configuration Issues:**
```bash
# Check configmaps
kubectl get configmap -n <namespace>

# View config
kubectl describe configmap -n <namespace> <configmap-name>

# Edit if needed
kubectl edit configmap -n <namespace> <configmap-name>
```

3. **Image Pull Errors:**
```bash
# Check image pull secrets
kubectl get secrets -n <namespace>

# Verify ACR connection
az acr login --name <acr-name>

# Update image pull secret
kubectl create secret docker-registry acr-secret \
  --docker-server=<acr-name>.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  -n <namespace>
```

## 🏗️ Infrastructure Problems

### AKS Node Issues

**Problem: Nodes NotReady**

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check system pods
kubectl get pods -n kube-system

# SSH into node (if needed)
az aks get-credentials --resource-group <rg> --name <cluster>
kubectl debug node/<node-name> -it --image=mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
```

**Solutions:**

1. **Disk Pressure:**
```bash
# Clean up unused images
kubectl get nodes -o json | jq '.items[].status.images[].names[]' | sort | uniq -c | sort -nr

# Delete unused pods
kubectl delete pod --field-selector=status.phase=Failed --all-namespaces
kubectl delete pod --field-selector=status.phase=Succeeded --all-namespaces
```

2. **Network Issues:**
```bash
# Restart network pods
kubectl delete pod -n kube-system -l component=kube-proxy
kubectl delete pod -n kube-system -l k8s-app=azure-cni-networkmonitor
```

### Storage Issues

**Problem: PVC Pending**

```bash
# Check PVC status
kubectl get pvc --all-namespaces

# Describe PVC
kubectl describe pvc -n <namespace> <pvc-name>

# Check storage classes
kubectl get storageclass
```

**Solutions:**

1. **Wrong Storage Class:**
```yaml
# Create correct storage class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-premium-retain
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

2. **Quota Issues:**
```bash
# Check Azure quotas
az vm list-usage --location <location> --output table

# Request quota increase if needed
```

## 📚 Developer Hub Issues

### Cannot Access Developer Hub

**Diagnosis:**
```bash
# Check Developer Hub pods
kubectl get pods -n rhdh

# Check logs
kubectl logs -n rhdh deployment/developer-hub

# Check database connection
kubectl exec -n rhdh deployment/developer-hub -- nc -zv <postgres-host> 5432
```

**Solutions:**

1. **Database Connection Failed:**
```bash
# Update database secret
kubectl create secret generic postgres-credentials \
  --from-literal=POSTGRES_PASSWORD=<password> \
  --from-literal=POSTGRES_USER=devhubadmin \
  --from-literal=POSTGRES_HOST=<postgres-host> \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -

# Restart Developer Hub
kubectl rollout restart deployment/developer-hub -n rhdh
```

2. **GitHub Integration Issues:**
```bash
# Update GitHub token
kubectl create secret generic github-credentials \
  --from-literal=GITHUB_TOKEN=<token> \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -
```

### Catalog Not Updating

**Problem: Entities not appearing in catalog**

```bash
# Check catalog refresh
kubectl logs -n rhdh deployment/developer-hub | grep catalog

# Force refresh
curl -X POST https://devhub.yourdomain.com/api/catalog/refresh
```

**Solutions:**

1. **Invalid catalog-info.yaml:**
```yaml
# Validate catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My service description
  annotations:
    github.com/project-slug: org/repo
spec:
  type: service
  lifecycle: production
  owner: team-a
```

2. **Permission Issues:**
```bash
# Check GitHub token permissions
gh auth status
gh api /user/repos --paginate | jq '.[].full_name' | grep <repo>
```

## 🔄 CI/CD Pipeline Problems

### GitHub Actions Failing

**Common Issues:**

1. **Authentication Failures:**
```yaml
# Check secrets are set
- name: Debug secrets
  run: |
    echo "ACR_REGISTRY is set: ${{ secrets.ACR_REGISTRY != '' }}"
    echo "AZURE_CREDENTIALS is set: ${{ secrets.AZURE_CREDENTIALS != '' }}"
```

2. **Container Build Failures:**
```yaml
# Add debug output
- name: Build image
  run: |
    docker build -t ${{ secrets.ACR_REGISTRY }}/my-app:${{ github.sha }} . --progress=plain
    docker images
```

3. **Deployment Failures:**
```bash
# Check deployment status
kubectl rollout status deployment/my-app -n production

# View deployment history
kubectl rollout history deployment/my-app -n production

# Rollback if needed
kubectl rollout undo deployment/my-app -n production
```

### GitOps Sync Issues

**Problem: Flux not syncing**

```bash
# Check Flux status
flux get all -A

# Check source controller
kubectl logs -n flux-system deployment/source-controller

# Force reconciliation
flux reconcile source git flux-system
flux reconcile kustomization apps
```

**Solutions:**

1. **Git Repository Access:**
```bash
# Check SSH key
kubectl get secret -n flux-system flux-system -o jsonpath='{.data.identity}' | base64 -d

# Update Git credentials
flux create secret git flux-system \
  --url=ssh://git@github.com/org/repo \
  --private-key-file=<path-to-key>
```

2. **Kustomization Errors:**
```bash
# Validate kustomization
kubectl apply -k <path> --dry-run=client

# Check events
kubectl events -n flux-system --for kustomization/apps
```

## 🤖 AI Services Troubleshooting

### Copilot Not Working

**Problem: No AI suggestions**

1. **Check Copilot Status:**
```bash
# In VS Code
Ctrl+Shift+P -> "GitHub Copilot: Status"

# Check organization settings
gh api /orgs/<org>/copilot/billing
```

2. **Network Issues:**
```bash
# Test Copilot endpoint
curl -I https://copilot-proxy.githubusercontent.com/

# Check proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

3. **License Issues:**
```bash
# Verify license assignment
gh api /orgs/<org>/copilot/billing/seats
```

### AI Deployment Agent Issues

**Problem: Deployment decisions failing**

```bash
# Check deployment agent
kubectl logs -n ai-services deployment/deployment-agent

# Test AI endpoint
kubectl exec -n ai-services deployment/deployment-agent -- curl http://localhost:8080/health
```

**Solutions:**

1. **API Key Issues:**
```bash
# Update Azure OpenAI credentials
kubectl create secret generic ai-credentials \
  --from-literal=AZURE_OPENAI_KEY=<key> \
  --from-literal=AZURE_OPENAI_ENDPOINT=<endpoint> \
  -n ai-services --dry-run=client -o yaml | kubectl apply -f -
```

2. **Model Deployment:**
```bash
# Check model deployment
az cognitiveservices account deployment list \
  --name <cognitive-services-account> \
  --resource-group <rg>
```

## 🔐 Security & Access Issues

### RBAC Problems

**Problem: Permission denied**

```bash
# Check current permissions
kubectl auth can-i --list

# Check service account
kubectl get serviceaccount -n <namespace>

# View role bindings
kubectl get rolebindings,clusterrolebindings --all-namespaces | grep <user>
```

**Solutions:**

1. **Missing Role Binding:**
```bash
# Create role binding
kubectl create rolebinding developer-binding \
  --clusterrole=edit \
  --user=<user-email> \
  --namespace=<namespace>
```

2. **Azure AD Integration:**
```bash
# Check Azure AD groups
az ad user show --id <user-email> --query memberOf[].displayName

# Update cluster role binding
kubectl create clusterrolebinding ad-group-binding \
  --clusterrole=view \
  --group=<azure-ad-group-id>
```

### Certificate Issues

**Problem: SSL certificate errors**

```bash
# Check certificate status
kubectl get certificates --all-namespaces
kubectl describe certificate -n <namespace> <cert-name>

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Check challenge status
kubectl get challenges --all-namespaces
```

**Solutions:**

1. **DNS Challenge Failed:**
```bash
# Check DNS propagation
nslookup _acme-challenge.yourdomain.com

# Force renewal
kubectl delete certificate -n <namespace> <cert-name>
```

2. **Rate Limiting:**
```bash
# Switch to staging
kubectl annotate ingress -n <namespace> <ingress-name> \
  cert-manager.io/cluster-issuer=letsencrypt-staging --overwrite
```

## ⚡ Performance Problems

### Slow Application Response

**Diagnosis:**
```bash
# Check pod resources
kubectl top pods --all-namespaces | sort -k3 -nr | head -20

# Check node resources
kubectl top nodes

# View HPA status
kubectl get hpa --all-namespaces

# Check network latency
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
```

**Solutions:**

1. **Resource Constraints:**
```yaml
# Update resource requests/limits
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

2. **Scaling Issues:**
```yaml
# Configure HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

3. **Database Performance:**
```sql
-- Check slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Add indexes if needed
CREATE INDEX idx_table_column ON table(column);
```

### High Resource Usage

**Problem: Pods consuming too much CPU/Memory**

```bash
# Find resource hogs
kubectl top pods --all-namespaces | sort -k3 -nr | head -10

# Check for memory leaks
kubectl exec -n <namespace> <pod> -- cat /proc/meminfo

# Profile application
kubectl exec -n <namespace> <pod> -- kill -USR1 1  # For Go apps
```

**Solutions:**

1. **Memory Leaks:**
```bash
# Enable memory profiling
kubectl set env deployment/<deployment> -n <namespace> GOGC=20
kubectl set env deployment/<deployment> -n <namespace> GOMEMLIMIT=1GiB
```

2. **CPU Throttling:**
```bash
# Check throttling
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods | jq '.items[] | select(.containers[].usage.cpu | tonumber > 1000)'

# Adjust CPU limits
kubectl patch deployment <deployment> -n <namespace> --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/resources/limits/cpu",
    "value": "2000m"
  }
]'
```

## ❓ Frequently Asked Questions

### General Questions

**Q: How do I add a new developer to the platform?**

A: Follow these steps:
```bash
# 1. Add to GitHub organization
gh api -X PUT /orgs/<org>/memberships/<username>

# 2. Add to Azure AD group
az ad group member add --group "ThreeHorizons-Developers" --member-id <user-object-id>

# 3. Grant Kubernetes access
kubectl create rolebinding <username>-binding \
  --clusterrole=edit \
  --user=<user-email> \
  --namespace=development

# 4. Enable GitHub Copilot
# Go to https://github.com/organizations/<org>/settings/copilot
```

**Q: How do I create a new environment?**

A: Create a new environment with:
```bash
# 1. Create namespace
kubectl create namespace <env-name>

# 2. Label namespace
kubectl label namespace <env-name> environment=<env-name>

# 3. Create GitOps folder
mkdir -p gitops-config/environments/<env-name>

# 4. Configure RBAC
kubectl create rolebinding <env-name>-developers \
  --clusterrole=edit \
  --group=ThreeHorizons-Developers \
  --namespace=<env-name>

# 5. Add to Flux
flux create kustomization <env-name> \
  --source=flux-system \
  --path=./environments/<env-name> \
  --prune=true \
  --interval=10m
```

**Q: How do I update platform components?**

A: Update components safely:
```bash
# 1. Check current versions
helm list -A

# 2. Update Helm repos
helm repo update

# 3. Check for updates
helm search repo <chart> --versions

# 4. Test update in dev
helm upgrade --install <release> <chart> \
  --namespace <namespace> \
  --values values.yaml \
  --dry-run

# 5. Apply update
helm upgrade <release> <chart> \
  --namespace <namespace> \
  --values values.yaml \
  --wait
```

### Development Questions

**Q: My service can't connect to the database**

A: Check these items:
1. Database firewall rules
2. Connection string in secrets
3. Network policies
4. Service account permissions

```bash
# Test connectivity
kubectl run -it --rm debug --image=postgres:14 --restart=Never -- \
  psql -h <host> -U <user> -d <database> -c "SELECT 1"
```

**Q: How do I debug a failing deployment?**

A: Use this debugging workflow:
```bash
# 1. Check deployment status
kubectl describe deployment -n <namespace> <deployment>

# 2. Check replica sets
kubectl get rs -n <namespace> -l app=<app>

# 3. Check pod events
kubectl describe pod -n <namespace> <pod>

# 4. View logs
kubectl logs -n <namespace> <pod> --previous

# 5. Check resource quotas
kubectl describe resourcequota -n <namespace>
```

**Q: How do I enable feature flags?**

A: Configure feature flags:
```yaml
# 1. Add to ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  flags.yaml: |
    features:
      new-ui: enabled
      ai-assist: enabled
      experimental-api: disabled

# 2. Mount in deployment
volumes:
- name: feature-flags
  configMap:
    name: feature-flags
volumeMounts:
- name: feature-flags
  mountPath: /config/features
```

### Operations Questions

**Q: How do I perform a rollback?**

A: Multiple rollback options:
```bash
# 1. Kubernetes rollback
kubectl rollout undo deployment/<deployment> -n <namespace>

# 2. GitOps rollback
git revert <commit>
git push

# 3. Flux rollback
flux suspend kustomization <name>
# Fix issue
flux resume kustomization <name>

# 4. Feature flag disable
kubectl patch configmap feature-flags -n <namespace> \
  --type='json' -p='[{"op": "replace", "path": "/data/new-feature", "value": "disabled"}]'
```

**Q: How do I scale the platform?**

A: Scale different components:
```bash
# 1. Scale AKS nodes
az aks nodepool scale \
  --resource-group <rg> \
  --cluster-name <cluster> \
  --name <nodepool> \
  --node-count <count>

# 2. Scale deployments
kubectl scale deployment/<deployment> -n <namespace> --replicas=<count>

# 3. Configure HPA
kubectl autoscale deployment/<deployment> -n <namespace> \
  --cpu-percent=70 \
  --min=3 \
  --max=10
```

**Q: How do I backup the platform?**

A: Backup strategy:
```bash
# 1. Backup etcd
kubectl exec -n kube-system etcd-<node> -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  snapshot save /backup/etcd-snapshot.db

# 2. Backup persistent volumes
velero backup create <backup-name> --include-namespaces <namespace>

# 3. Export GitOps config
git clone <gitops-repo>
tar -czf gitops-backup.tar.gz gitops-config/

# 4. Backup databases
az postgres flexible-server backup create \
  --resource-group <rg> \
  --name <server> \
  --backup-name <backup>
```

## 🆘 Getting Help

### Self-Service Resources

1. **Documentation**
   - Platform Docs: `https://devhub.yourdomain.com/docs`
   - API Reference: `https://api.yourdomain.com/swagger`
   - Architecture Guide: Internal wiki

2. **Monitoring**
   - Grafana: `https://grafana.yourdomain.com`
   - Logs: `https://logs.yourdomain.com`
   - Traces: `https://traces.yourdomain.com`

3. **Status Pages**
   - Platform Status: `https://status.yourdomain.com`
   - Incident History: `https://incidents.yourdomain.com`

### Contact Support

**Tier 1: Self-Service**
- Knowledge Base
- Community Slack
- Documentation

**Tier 2: Platform Team**
- Slack: #platform-support
- Email: platform@yourdomain.com
- Office Hours: Tue/Thu 2-4 PM

**Tier 3: Emergency**
- PagerDuty: platform-oncall
- Phone: +1-555-PLATFORM
- Escalation: CTO

### Useful Commands Cheatsheet

```bash
# Quick status
alias k='kubectl'
alias kgp='kubectl get pods --all-namespaces'
alias kgs='kubectl get svc --all-namespaces'
alias kgi='kubectl get ingress --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Describe
alias kd='kubectl describe'

# Execute
alias ke='kubectl exec -it'

# Port forward
alias kpf='kubectl port-forward'

# Quick debug pod
alias kdebug='kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- /bin/bash'
```

### Emergency Procedures

**Platform Down:**
1. Check Azure status
2. Verify AKS cluster health
3. Check ingress controller
4. Review recent changes
5. Engage on-call if needed

**Security Incident:**
1. Isolate affected components
2. Preserve logs
3. Notify security team
4. Follow incident response plan

**Data Loss:**
1. Stop writes to affected system
2. Assess backup availability
3. Initiate recovery procedure
4. Notify stakeholders

---

<div align="center">

**Need More Help? 🤝**

We're here to support your success on the Three Horizons AI Platform.

[← Back to Documentation](../) | [Contact Support](mailto:platform@yourdomain.com)

</div>
