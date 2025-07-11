# 🔧 H1-007-J: Troubleshooting e Resolução de Problemas

## 📋 Índice

1. [🚨 Problemas Comuns](#problemas-comuns)
2. [🔍 Diagnóstico Sistemático](#diagnostico-sistematico)
3. [☁️ Issues Azure](#issues-azure)
4. [☸️ Issues Kubernetes](#issues-kubernetes)
5. [📦 Issues Aplicação](#issues-aplicacao)
6. [🔄 Issues GitOps](#issues-gitops)
7. [📊 Issues Monitoramento](#issues-monitoramento)
8. [🛠️ Scripts de Diagnóstico](#scripts-diagnostico)
9. [📝 Runbooks](#runbooks)
10. [🆘 Recuperação de Desastres](#recuperacao-desastres)

## 🚨 Problemas Comuns {#problemas-comuns}

### Quick Reference - Top 10 Issues

| Problema | Sintoma | Solução Rápida | Script |
|----------|---------|----------------|--------|
| Pods em CrashLoop | Restart count > 5 | Check logs e resources | `diagnose-pod.sh` |
| 503 Service Unavailable | Ingress retorna 503 | Verificar endpoints | `check-ingress.sh` |
| ArgoCD OutOfSync | Apps não sincronizam | Manual sync/refresh | `fix-argocd-sync.sh` |
| High Memory Usage | OOMKilled pods | Aumentar limits | `adjust-resources.sh` |
| Slow Database | Latency > 1s | Check connections | `db-diagnostics.sh` |
| Auth Failures | 401/403 errors | Renovar tokens | `refresh-auth.sh` |
| Disk Full | PVC at 100% | Expand volume | `expand-pvc.sh` |
| Network Timeouts | Connection refused | Check network policies | `test-connectivity.sh` |
| Certificate Expired | SSL errors | Renovar cert | `renew-certificates.sh` |
| Metrics Missing | Gaps in Grafana | Restart prometheus | `fix-monitoring.sh` |

## 🔍 Diagnóstico Sistemático {#diagnostico-sistematico}

### Framework de Troubleshooting

```bash
#!/bin/bash
# scripts/systematic-diagnosis.sh

# Framework LAYERS - Low-level to Application
diagnose_system() {
    echo "🔍 Starting Systematic Diagnosis..."
    echo "================================"
    
    # Layer 1: Infrastructure
    echo "1️⃣ Checking Infrastructure..."
    check_azure_resources
    check_kubernetes_cluster
    check_networking
    
    # Layer 2: Platform
    echo "2️⃣ Checking Platform Services..."
    check_ingress_controller
    check_cert_manager
    check_argocd
    check_monitoring
    
    # Layer 3: Applications
    echo "3️⃣ Checking Applications..."
    check_pods_health
    check_services
    check_deployments
    
    # Layer 4: Data
    echo "4️⃣ Checking Data Layer..."
    check_databases
    check_caches
    check_message_queues
    
    # Layer 5: Observability
    echo "5️⃣ Checking Observability..."
    check_metrics
    check_logs
    check_traces
}

# Implementação das funções
check_azure_resources() {
    echo -n "  Azure Resource Group... "
    if az group show -n $RESOURCE_GROUP &>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        echo "    Fix: az group create -n $RESOURCE_GROUP -l $LOCATION"
    fi
    
    echo -n "  AKS Cluster... "
    if az aks show -n $AKS_NAME -g $RESOURCE_GROUP &>/dev/null; then
        echo "✅ OK"
        
        # Check node health
        node_count=$(kubectl get nodes --no-headers | grep -c Ready)
        echo "    Nodes Ready: $node_count"
    else
        echo "❌ FAILED"
    fi
}

check_kubernetes_cluster() {
    echo -n "  Kubernetes API... "
    if kubectl cluster-info &>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        echo "    Fix: az aks get-credentials -n $AKS_NAME -g $RESOURCE_GROUP"
    fi
    
    echo -n "  Node Resources... "
    local pressure=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.conditions[] | select(.type=="MemoryPressure" or .type=="DiskPressure") | .status=="True") | .metadata.name' | wc -l)
    if [ $pressure -eq 0 ]; then
        echo "✅ OK"
    else
        echo "⚠️ WARNING - Resource pressure detected"
        kubectl top nodes
    fi
}

# Main execution
diagnose_system
```

### Árvore de Decisão para Debugging

```mermaid
graph TD
    A[Problema Detectado] --> B{Tipo de Erro?}
    
    B -->|503/504| C[Network/Ingress]
    B -->|500| D[Application Error]
    B -->|OOMKilled| E[Resource Issue]
    B -->|CrashLoop| F[Startup Failure]
    
    C --> C1[Check Ingress]
    C --> C2[Check Service Endpoints]
    C --> C3[Check Network Policies]
    
    D --> D1[Check Application Logs]
    D --> D2[Check Dependencies]
    D --> D3[Check Configuration]
    
    E --> E1[Check Memory Limits]
    E --> E2[Check Node Resources]
    E --> E3[Scale or Optimize]
    
    F --> F1[Check Init Containers]
    F --> F2[Check Liveness Probe]
    F --> F3[Check Dependencies]
```

## ☁️ Issues Azure {#issues-azure}

### AKS Node Issues

```bash
#!/bin/bash
# scripts/fix-aks-nodes.sh

echo "🔧 Diagnosing AKS Node Issues..."

# Check node status
kubectl get nodes -o wide

# Check for NotReady nodes
NOT_READY=$(kubectl get nodes --no-headers | grep -v Ready | wc -l)

if [ $NOT_READY -gt 0 ]; then
    echo "⚠️ Found $NOT_READY nodes in NotReady state"
    
    # Get node details
    kubectl describe nodes | grep -A 5 "Conditions:" | grep -B 5 "False"
    
    # Common fixes
    echo "🔧 Attempting fixes..."
    
    # 1. Cordon and drain problematic nodes
    for node in $(kubectl get nodes --no-headers | grep -v Ready | awk '{print $1}'); do
        echo "Draining node: $node"
        kubectl cordon $node
        kubectl drain $node --delete-emptydir-data --ignore-daemonsets --force
    done
    
    # 2. Scale node pool
    echo "Scaling node pool..."
    az aks nodepool scale \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $AKS_NAME \
        --name nodepool1 \
        --node-count 4
    
    # 3. Wait for new nodes
    echo "Waiting for new nodes..."
    sleep 60
    
    # 4. Delete old nodes
    for node in $(kubectl get nodes --no-headers | grep -v Ready | awk '{print $1}'); do
        kubectl delete node $node
    done
fi
```

### Azure Networking Issues

```bash
#!/bin/bash
# scripts/fix-azure-networking.sh

echo "🌐 Diagnosing Azure Networking..."

# Check Load Balancer
echo "Checking Load Balancer..."
az network lb list -g $RESOURCE_GROUP -o table

# Check Public IPs
echo "Checking Public IPs..."
az network public-ip list -g $RESOURCE_GROUP -o table

# Check NSG Rules
echo "Checking Network Security Groups..."
for nsg in $(az network nsg list -g $RESOURCE_GROUP --query "[].name" -o tsv); do
    echo "NSG: $nsg"
    az network nsg rule list -g $RESOURCE_GROUP --nsg-name $nsg -o table
done

# Fix common networking issues
fix_networking() {
    # 1. Ensure ingress controller has public IP
    INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [ -z "$INGRESS_IP" ]; then
        echo "❌ Ingress controller has no public IP"
        
        # Recreate service
        kubectl delete svc -n ingress-nginx ingress-nginx-controller
        kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  selector:
    app.kubernetes.io/name: ingress-nginx
EOF
    fi
    
    # 2. Update DNS records
    echo "Current Ingress IP: $INGRESS_IP"
    echo "Update DNS records to point to this IP"
}

fix_networking
```

### Storage Issues

```bash
#!/bin/bash
# scripts/fix-storage-issues.sh

echo "💾 Diagnosing Storage Issues..."

# Check PVCs
echo "Checking PVCs..."
kubectl get pvc --all-namespaces

# Find full PVCs
FULL_PVCS=$(kubectl get pvc --all-namespaces -o json | jq -r '.items[] | select(.status.capacity.storage == .status.capacity.storage) | "\(.metadata.namespace)/\(.metadata.name)"')

for pvc in $FULL_PVCS; do
    namespace=$(echo $pvc | cut -d'/' -f1)
    name=$(echo $pvc | cut -d'/' -f2)
    
    echo "📈 Expanding PVC: $pvc"
    
    # Get current size
    current_size=$(kubectl get pvc $name -n $namespace -o jsonpath='{.spec.resources.requests.storage}')
    
    # Calculate new size (double it)
    new_size=$(echo $current_size | sed 's/Gi//' | awk '{print $1 * 2}')Gi
    
    # Patch PVC
    kubectl patch pvc $name -n $namespace -p '{"spec":{"resources":{"requests":{"storage":"'$new_size'"}}}}'
done

# Clean up old logs and temp files
echo "🧹 Cleaning up disk space..."
kubectl get pods --all-namespaces -o json | jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name)"' | while read ns pod; do
    kubectl exec -n $ns $pod -- sh -c "find /tmp -type f -mtime +7 -delete 2>/dev/null || true"
    kubectl exec -n $ns $pod -- sh -c "find /var/log -type f -name '*.log' -mtime +7 -delete 2>/dev/null || true"
done
```

## ☸️ Issues Kubernetes {#issues-kubernetes}

### Pod Troubleshooting

```bash
#!/bin/bash
# scripts/diagnose-pod.sh

diagnose_pod() {
    local namespace=$1
    local pod=$2
    
    echo "🔍 Diagnosing pod: $namespace/$pod"
    echo "================================"
    
    # Basic info
    echo "📊 Pod Status:"
    kubectl get pod $pod -n $namespace -o wide
    
    # Container statuses
    echo -e "\n📦 Container Statuses:"
    kubectl get pod $pod -n $namespace -o json | jq -r '.status.containerStatuses[] | "Container: \(.name)\nState: \(.state | keys[0])\nRestart Count: \(.restartCount)\n"'
    
    # Recent events
    echo -e "\n📅 Recent Events:"
    kubectl get events -n $namespace --field-selector involvedObject.name=$pod --sort-by='.lastTimestamp' | tail -10
    
    # Logs from all containers
    echo -e "\n📝 Container Logs:"
    for container in $(kubectl get pod $pod -n $namespace -o jsonpath='{.spec.containers[*].name}'); do
        echo -e "\n--- Logs for container: $container ---"
        kubectl logs $pod -n $namespace -c $container --tail=50 || echo "Failed to get logs"
        
        # Previous logs if restarted
        if kubectl logs $pod -n $namespace -c $container --previous &>/dev/null; then
            echo -e "\n--- Previous logs for container: $container ---"
            kubectl logs $pod -n $namespace -c $container --previous --tail=50
        fi
    done
    
    # Resource usage
    echo -e "\n💻 Resource Usage:"
    kubectl top pod $pod -n $namespace --containers || echo "Metrics not available"
    
    # Describe pod
    echo -e "\n📋 Pod Description:"
    kubectl describe pod $pod -n $namespace | grep -A 10 -E "(Conditions:|Events:|State:|Reason:|Message:)"
}

# Fix common pod issues
fix_pod_issues() {
    local namespace=$1
    local pod=$2
    
    # Get pod status
    local status=$(kubectl get pod $pod -n $namespace -o jsonpath='{.status.phase}')
    local restart_count=$(kubectl get pod $pod -n $namespace -o jsonpath='{.status.containerStatuses[0].restartCount}')
    
    # CrashLoopBackOff
    if [[ "$status" == *"CrashLoopBackOff"* ]] || [ $restart_count -gt 5 ]; then
        echo "🔧 Fixing CrashLoopBackOff..."
        
        # Delete pod to force recreation
        kubectl delete pod $pod -n $namespace --grace-period=0 --force
        
        # Scale deployment
        local deployment=$(kubectl get pod $pod -n $namespace -o jsonpath='{.metadata.ownerReferences[0].name}')
        kubectl scale deployment $deployment -n $namespace --replicas=0
        sleep 5
        kubectl scale deployment $deployment -n $namespace --replicas=1
    fi
    
    # ImagePullBackOff
    if [[ "$status" == *"ImagePullBackOff"* ]]; then
        echo "🔧 Fixing ImagePullBackOff..."
        
        # Check image
        local image=$(kubectl get pod $pod -n $namespace -o jsonpath='{.spec.containers[0].image}')
        echo "Image: $image"
        
        # Verify ACR access
        kubectl get secret -n $namespace | grep -q acr-secret || {
            echo "Creating ACR secret..."
            kubectl create secret docker-registry acr-secret \
                --docker-server=$ACR_NAME.azurecr.io \
                --docker-username=$ACR_USERNAME \
                --docker-password=$ACR_PASSWORD \
                -n $namespace
        }
    fi
}

# Usage
if [ $# -eq 2 ]; then
    diagnose_pod $1 $2
    fix_pod_issues $1 $2
else
    echo "Usage: $0 <namespace> <pod-name>"
fi
```

### Service Discovery Issues

```bash
#!/bin/bash
# scripts/fix-service-discovery.sh

echo "🔍 Checking Service Discovery..."

# Test DNS resolution
test_dns() {
    local test_pod="dns-test-$$"
    
    # Create test pod
    kubectl run $test_pod --image=busybox:1.28 --rm -it --restart=Never -- sh -c "
        echo 'Testing DNS resolution...'
        nslookup kubernetes.default
        nslookup api-gateway.ecommerce-dev.svc.cluster.local
        nslookup google.com
    "
    
    # Check CoreDNS
    echo "Checking CoreDNS pods..."
    kubectl get pods -n kube-system -l k8s-app=kube-dns
    
    # Check CoreDNS logs
    echo "CoreDNS logs:"
    kubectl logs -n kube-system -l k8s-app=kube-dns --tail=20
}

# Fix endpoint issues
fix_endpoints() {
    echo "🔧 Fixing Service Endpoints..."
    
    # List services without endpoints
    kubectl get services --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="ClusterIP") | "\(.metadata.namespace)/\(.metadata.name)"' | while read svc; do
        namespace=$(echo $svc | cut -d'/' -f1)
        name=$(echo $svc | cut -d'/' -f2)
        
        endpoints=$(kubectl get endpoints $name -n $namespace -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)
        
        if [ -z "$endpoints" ]; then
            echo "⚠️ No endpoints for service: $svc"
            
            # Check if pods match selector
            selector=$(kubectl get svc $name -n $namespace -o jsonpath='{.spec.selector}')
            echo "  Selector: $selector"
            
            # Find matching pods
            kubectl get pods -n $namespace -l "$selector" --no-headers
        fi
    done
}

test_dns
fix_endpoints
```

### Resource Quota Issues

```bash
#!/bin/bash
# scripts/fix-resource-quotas.sh

echo "📊 Checking Resource Quotas..."

# Check all quotas
kubectl get resourcequota --all-namespaces

# Check limit ranges
kubectl get limitrange --all-namespaces

# Analyze resource usage vs quotas
check_quota_usage() {
    local namespace=$1
    
    echo "Namespace: $namespace"
    
    # Get quota
    kubectl get resourcequota -n $namespace -o json | jq -r '.items[] | {
        name: .metadata.name,
        hard: .status.hard,
        used: .status.used
    }'
    
    # Calculate percentage used
    kubectl get resourcequota -n $namespace -o json | jq -r '.items[] | 
        .status | 
        to_entries | 
        map(select(.key | endswith(".used"))) | 
        map({
            resource: (.key | split(".")[0]),
            used: .value,
            limit: .hard[.key | split(".")[0]],
            percentage: ((.value | tonumber) / (.hard[.key | split(".")[0]] | tonumber) * 100)
        }) | 
        map(select(.percentage > 80))
    '
}

# Fix quota issues
fix_quota_issues() {
    # Increase quotas for namespaces over 80%
    for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
        high_usage=$(check_quota_usage $ns | jq '. | length')
        
        if [ "$high_usage" -gt 0 ]; then
            echo "🔧 Increasing quota for namespace: $ns"
            
            kubectl patch resourcequota default-quota -n $ns --type=merge -p '{
                "spec": {
                    "hard": {
                        "requests.cpu": "20",
                        "requests.memory": "40Gi",
                        "limits.cpu": "40",
                        "limits.memory": "80Gi",
                        "persistentvolumeclaims": "20"
                    }
                }
            }'
        fi
    done
}

check_quota_usage ecommerce-dev
fix_quota_issues
```

## 📦 Issues Aplicação {#issues-aplicacao}

### Application Debugging

```bash
#!/bin/bash
# scripts/debug-application.sh

debug_app() {
    local app_name=$1
    local namespace=${2:-ecommerce-dev}
    
    echo "🐛 Debugging Application: $app_name"
    echo "===================================="
    
    # 1. Check deployment status
    echo "📊 Deployment Status:"
    kubectl get deployment $app_name -n $namespace
    kubectl rollout status deployment/$app_name -n $namespace
    
    # 2. Check recent rollouts
    echo -e "\n📜 Rollout History:"
    kubectl rollout history deployment/$app_name -n $namespace
    
    # 3. Check configuration
    echo -e "\n⚙️ Configuration:"
    kubectl get configmap -n $namespace | grep $app_name
    kubectl get secret -n $namespace | grep $app_name
    
    # 4. Check service connectivity
    echo -e "\n🌐 Service Connectivity:"
    kubectl get svc $app_name -n $namespace
    kubectl get endpoints $app_name -n $namespace
    
    # 5. Test application health
    echo -e "\n❤️ Health Check:"
    local pod=$(kubectl get pod -n $namespace -l app=$app_name -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -n $namespace $pod -- wget -q -O- http://localhost:8080/health || echo "Health check failed"
    
    # 6. Check dependencies
    echo -e "\n🔗 Dependencies:"
    kubectl exec -n $namespace $pod -- env | grep -E "(DATABASE|REDIS|API)" || true
    
    # 7. Performance metrics
    echo -e "\n📈 Performance Metrics:"
    kubectl exec -n $namespace $pod -- wget -q -O- http://localhost:8080/metrics | grep -E "(http_request_duration|memory_usage)" | head -20
}

# Common fixes
fix_app_issues() {
    local app_name=$1
    local namespace=$2
    
    # Restart deployment
    echo "🔄 Restarting deployment..."
    kubectl rollout restart deployment/$app_name -n $namespace
    
    # Clear cache if Redis-based
    if kubectl get svc -n $namespace | grep -q redis; then
        echo "🧹 Clearing Redis cache..."
        kubectl exec -n $namespace deployment/redis -- redis-cli FLUSHALL
    fi
    
    # Refresh configuration
    echo "🔄 Refreshing configuration..."
    kubectl delete pod -n $namespace -l app=$app_name
}

# Usage
debug_app "$1" "${2:-ecommerce-dev}"
```

### Database Connection Issues

```bash
#!/bin/bash
# scripts/fix-database-issues.sh

echo "🗄️ Diagnosing Database Issues..."

# Test PostgreSQL connection
test_postgres() {
    local namespace=$1
    local pod=$2
    
    echo "Testing PostgreSQL connection..."
    
    kubectl exec -n $namespace $pod -- sh -c '
        apt-get update && apt-get install -y postgresql-client
        
        # Test connection
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT version();"
        
        # Check connection pool
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
            SELECT count(*) as total_connections,
                   count(*) filter (where state = ''active'') as active,
                   count(*) filter (where state = ''idle'') as idle,
                   count(*) filter (where state = ''idle in transaction'') as idle_in_transaction
            FROM pg_stat_activity;"
    '
}

# Test MongoDB connection
test_mongodb() {
    local namespace=$1
    local pod=$2
    
    echo "Testing MongoDB connection..."
    
    kubectl exec -n $namespace $pod -- sh -c '
        # Install mongo shell
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
        apt-get update && apt-get install -y mongodb-mongosh
        
        # Test connection
        mongosh "$MONGO_URI" --eval "db.serverStatus()"
    '
}

# Fix connection pool issues
fix_connection_pool() {
    echo "🔧 Fixing connection pool issues..."
    
    # Update connection pool settings
    for deployment in $(kubectl get deployments -n ecommerce-dev -o jsonpath='{.items[*].metadata.name}'); do
        kubectl set env deployment/$deployment -n ecommerce-dev \
            DB_POOL_MIN=5 \
            DB_POOL_MAX=20 \
            DB_POOL_IDLE_TIMEOUT=30000
    done
}

# Run diagnostics
test_postgres ecommerce-dev api-gateway
test_mongodb ecommerce-dev catalog-service
fix_connection_pool
```

### Memory Leaks

```bash
#!/bin/bash
# scripts/detect-memory-leaks.sh

echo "💾 Detecting Memory Leaks..."

# Monitor memory usage over time
monitor_memory() {
    local namespace=$1
    local duration=${2:-300} # 5 minutes default
    
    echo "Monitoring memory usage for $duration seconds..."
    
    local end=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end ]; do
        echo -e "\n$(date '+%Y-%m-%d %H:%M:%S')"
        kubectl top pods -n $namespace --containers | grep -v "NAME" | while read line; do
            pod=$(echo $line | awk '{print $1}')
            container=$(echo $line | awk '{print $2}')
            memory=$(echo $line | awk '{print $4}')
            
            # Convert to MB
            memory_mb=$(echo $memory | sed 's/Mi//')
            
            # Alert if memory > 1GB
            if [ "$memory_mb" -gt 1024 ]; then
                echo "⚠️ High memory usage: $pod/$container - $memory"
            else
                echo "✅ $pod/$container - $memory"
            fi
        done
        
        sleep 30
    done
}

# Generate heap dump
generate_heap_dump() {
    local namespace=$1
    local pod=$2
    local container=${3:-$pod}
    
    echo "📸 Generating heap dump for $pod..."
    
    # For Java applications
    kubectl exec -n $namespace $pod -c $container -- sh -c '
        # Find Java process
        PID=$(pgrep java)
        
        # Generate heap dump
        jmap -dump:format=b,file=/tmp/heapdump.hprof $PID
        
        # Compress
        gzip /tmp/heapdump.hprof
    '
    
    # Copy heap dump
    kubectl cp $namespace/$pod:/tmp/heapdump.hprof.gz ./heapdump-$pod-$(date +%Y%m%d-%H%M%S).hprof.gz
    
    echo "Heap dump saved locally"
}

# Fix memory issues
fix_memory_issues() {
    local namespace=$1
    
    echo "🔧 Fixing memory issues..."
    
    # Increase memory limits for pods using > 80% of limit
    kubectl get pods -n $namespace -o json | jq -r '.items[] | 
        select(.status.phase == "Running") | 
        .metadata.name as $pod | 
        .spec.containers[] | 
        select(.resources.limits.memory != null) |
        {
            pod: $pod,
            container: .name,
            limit: .resources.limits.memory
        }' | while read -r line; do
        
        pod=$(echo $line | jq -r '.pod')
        container=$(echo $line | jq -r '.container')
        limit=$(echo $line | jq -r '.limit')
        
        # Get current usage
        usage=$(kubectl top pod $pod -n $namespace --containers | grep $container | awk '{print $4}' | sed 's/Mi//')
        limit_mb=$(echo $limit | sed 's/Mi//')
        
        # Calculate percentage
        if [ -n "$usage" ] && [ -n "$limit_mb" ]; then
            percentage=$((usage * 100 / limit_mb))
            
            if [ $percentage -gt 80 ]; then
                echo "📈 Increasing memory limit for $pod/$container (${percentage}% used)"
                
                # Double the limit
                new_limit=$((limit_mb * 2))Mi
                
                # Patch deployment
                deployment=$(kubectl get pod $pod -n $namespace -o jsonpath='{.metadata.ownerReferences[0].name}')
                kubectl patch deployment $deployment -n $namespace --type=json -p='[
                    {
                        "op": "replace",
                        "path": "/spec/template/spec/containers/'$(kubectl get deployment $deployment -n $namespace -o json | jq -r '.spec.template.spec.containers | map(.name == "'$container'") | index(true)')'/resources/limits/memory",
                        "value": "'$new_limit'"
                    }
                ]'
            fi
        fi
    done
}

# Execute
monitor_memory ecommerce-dev 60
fix_memory_issues ecommerce-dev
```

## 🔄 Issues GitOps {#issues-gitops}

### ArgoCD Sync Issues

```bash
#!/bin/bash
# scripts/fix-argocd-sync.sh

echo "🔄 Fixing ArgoCD Sync Issues..."

# Get all applications
apps=$(argocd app list -o json | jq -r '.[].metadata.name')

for app in $apps; do
    echo "Checking app: $app"
    
    # Get sync status
    sync_status=$(argocd app get $app -o json | jq -r '.status.sync.status')
    health_status=$(argocd app get $app -o json | jq -r '.status.health.status')
    
    echo "  Sync: $sync_status, Health: $health_status"
    
    if [ "$sync_status" != "Synced" ]; then
        echo "  🔧 Fixing sync for $app..."
        
        # Get sync error
        sync_error=$(argocd app get $app -o json | jq -r '.status.conditions[] | select(.type=="SyncError") | .message')
        echo "  Error: $sync_error"
        
        # Common fixes
        case "$sync_error" in
            *"ComparisonError"*)
                echo "  Refreshing app..."
                argocd app get $app --refresh
                ;;
            *"connection refused"*)
                echo "  Repository connection issue..."
                argocd repo list
                ;;
            *)
                echo "  Force syncing..."
                argocd app sync $app --force --prune
                ;;
        esac
    fi
    
    if [ "$health_status" == "Degraded" ]; then
        echo "  ⚠️ Application is degraded"
        
        # Get degraded resources
        argocd app get $app -o json | jq -r '.status.resources[] | select(.health.status=="Degraded") | "\(.kind)/\(.name)"' | while read resource; do
            echo "    Degraded resource: $resource"
        done
    fi
done

# Fix common ArgoCD issues
fix_argocd_common_issues() {
    # 1. Clear cache
    echo "🧹 Clearing ArgoCD cache..."
    argocd app list | grep -v NAME | awk '{print $1}' | xargs -I {} argocd app get {} --hard-refresh
    
    # 2. Restart ArgoCD components
    echo "🔄 Restarting ArgoCD..."
    kubectl rollout restart deployment -n argocd
    
    # 3. Fix RBAC issues
    echo "🔐 Checking RBAC..."
    kubectl auth can-i --list --as=system:serviceaccount:argocd:argocd-application-controller -n ecommerce-dev
}

fix_argocd_common_issues
```

### Git Repository Issues

```bash
#!/bin/bash
# scripts/fix-git-sync.sh

echo "🐙 Fixing Git Sync Issues..."

# Check repository access
check_repo_access() {
    echo "Checking repository access..."
    
    # List repositories
    argocd repo list
    
    # Test each repository
    argocd repo list -o json | jq -r '.[].repo' | while read repo; do
        echo "Testing repo: $repo"
        
        # Try to ls-remote
        if ! git ls-remote $repo &>/dev/null; then
            echo "  ❌ Cannot access repository"
            
            # Re-add repository
            echo "  🔧 Re-adding repository..."
            argocd repo rm $repo
            argocd repo add $repo --ssh-private-key-path ~/.ssh/id_rsa
        else
            echo "  ✅ Repository accessible"
        fi
    done
}

# Fix webhook issues
fix_webhooks() {
    echo "🔗 Fixing webhook issues..."
    
    # Get webhook URL
    WEBHOOK_URL="https://argocd.demo.threehorizons.io/api/webhook"
    
    # Update GitHub webhook
    gh api repos/$GITHUB_ORG/$GITHUB_REPO/hooks -X POST -f name=web -f active=true \
        -f 'events[]=push' -f 'events[]=pull_request' \
        -f config[url]=$WEBHOOK_URL \
        -f config[content_type]=json
}

check_repo_access
fix_webhooks
```

## 📊 Issues Monitoramento {#issues-monitoramento}

### Prometheus Issues

```bash
#!/bin/bash
# scripts/fix-prometheus.sh

echo "📊 Fixing Prometheus Issues..."

# Check Prometheus targets
check_prometheus_targets() {
    echo "Checking Prometheus targets..."
    
    # Port-forward to Prometheus
    kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090 &
    PF_PID=$!
    sleep 5
    
    # Get unhealthy targets
    curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health != "up") | {job: .labels.job, instance: .labels.instance, error: .lastError}'
    
    kill $PF_PID
}

# Fix service discovery
fix_service_discovery() {
    echo "🔧 Fixing service discovery..."
    
    # Restart Prometheus operator
    kubectl rollout restart deployment -n monitoring prometheus-operator
    
    # Check ServiceMonitors
    kubectl get servicemonitor --all-namespaces
    
    # Ensure labels match
    kubectl get servicemonitor --all-namespaces -o json | jq -r '.items[] | select(.spec.selector.matchLabels) | {namespace: .metadata.namespace, name: .metadata.name, selector: .spec.selector.matchLabels}'
}

# Fix storage issues
fix_prometheus_storage() {
    echo "💾 Fixing Prometheus storage..."
    
    # Check PVC usage
    kubectl exec -n monitoring prometheus-prometheus-stack-kube-prom-prometheus-0 -- df -h /prometheus
    
    # Clean up old data
    kubectl exec -n monitoring prometheus-prometheus-stack-kube-prom-prometheus-0 -- sh -c '
        # Delete data older than 7 days
        find /prometheus -name "*.tmp" -mtime +7 -delete
        
        # Compact TSDB
        promtool tsdb clean /prometheus
    '
}

check_prometheus_targets
fix_service_discovery
fix_prometheus_storage
```

### Grafana Issues

```bash
#!/bin/bash
# scripts/fix-grafana.sh

echo "📊 Fixing Grafana Issues..."

# Reset admin password
reset_grafana_password() {
    echo "🔐 Resetting Grafana admin password..."
    
    kubectl exec -n monitoring deployment/prometheus-stack-grafana -- grafana-cli admin reset-admin-password 'ThreeHorizons2024!'
}

# Fix datasources
fix_datasources() {
    echo "🔧 Fixing Grafana datasources..."
    
    # Get Grafana API key
    GRAFANA_URL="http://admin:ThreeHorizons2024!@localhost:3000"
    kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80 &
    PF_PID=$!
    sleep 5
    
    # Check datasources
    curl -s $GRAFANA_URL/api/datasources | jq
    
    # Fix Prometheus datasource
    curl -X POST $GRAFANA_URL/api/datasources \
        -H "Content-Type: application/json" \
        -d '{
            "name": "Prometheus",
            "type": "prometheus",
            "url": "http://prometheus-stack-kube-prom-prometheus:9090",
            "access": "proxy",
            "isDefault": true
        }'
    
    kill $PF_PID
}

# Import dashboards
import_dashboards() {
    echo "📊 Importing dashboards..."
    
    # Dashboard IDs from grafana.com
    dashboards=(
        "13502:10"  # Kubernetes cluster monitoring
        "12740:8"   # Kubernetes pod monitoring  
        "11074:9"   # Node exporter
        "10000:2"   # Nginx ingress
    )
    
    for dashboard in "${dashboards[@]}"; do
        id="${dashboard%:*}"
        revision="${dashboard#*:}"
        
        echo "Importing dashboard $id (revision $revision)..."
        
        curl -s https://grafana.com/api/dashboards/$id/revisions/$revision/download | \
            jq '. + {overwrite: true, inputs: [{name: "DS_PROMETHEUS", type: "datasource", pluginId: "prometheus", value: "Prometheus"}]}' | \
            curl -X POST $GRAFANA_URL/api/dashboards/import \
                -H "Content-Type: application/json" \
                -d @-
    done
}

reset_grafana_password
fix_datasources
import_dashboards
```

## 🛠️ Scripts de Diagnóstico {#scripts-diagnostico}

### Health Check Completo

```bash
#!/bin/bash
# scripts/full-health-check.sh

echo "🏥 Running Full Platform Health Check..."
echo "========================================"

# Function to check component health
check_health() {
    local name=$1
    local check_command=$2
    local expected=$3
    
    echo -n "Checking $name... "
    
    if eval "$check_command" 2>/dev/null | grep -q "$expected"; then
        echo "✅ Healthy"
        return 0
    else
        echo "❌ Unhealthy"
        return 1
    fi
}

# Infrastructure checks
echo -e "\n🏗️ Infrastructure Health:"
check_health "Azure Resource Group" "az group show -n $RESOURCE_GROUP --query properties.provisioningState -o tsv" "Succeeded"
check_health "AKS Cluster" "az aks show -n $AKS_NAME -g $RESOURCE_GROUP --query powerState.code -o tsv" "Running"
check_health "Container Registry" "az acr show -n $ACR_NAME --query provisioningState -o tsv" "Succeeded"

# Kubernetes checks
echo -e "\n☸️ Kubernetes Health:"
check_health "API Server" "kubectl version --short" "Server Version"
check_health "All Nodes Ready" "kubectl get nodes --no-headers | grep -v ' Ready '" "^$"
check_health "System Pods" "kubectl get pods -n kube-system --no-headers | grep -v Running | grep -v Completed" "^$"

# Application checks
echo -e "\n📦 Application Health:"
check_health "Frontend Portal" "curl -s https://portal.demo.threehorizons.io/api/health" "ok"
check_health "API Gateway" "curl -s https://api.demo.threehorizons.io/health" "healthy"
check_health "All Deployments Ready" "kubectl get deployments -n ecommerce-dev -o json | jq -r '.items[] | select(.status.replicas != .status.readyReplicas) | .metadata.name'" "^$"

# GitOps checks
echo -e "\n🔄 GitOps Health:"
check_health "ArgoCD Server" "kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers | grep Running" "Running"
check_health "All Apps Synced" "argocd app list -o json | jq -r '.[] | select(.status.sync.status != \"Synced\") | .metadata.name'" "^$"

# Monitoring checks
echo -e "\n📊 Monitoring Health:"
check_health "Prometheus" "kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --no-headers | grep Running" "Running"
check_health "Grafana" "curl -s https://grafana.demo.threehorizons.io/api/health" "ok"
check_health "Loki" "kubectl get pods -n monitoring -l app=loki --no-headers | grep Running" "Running"

# Summary
echo -e "\n📊 Health Check Summary:"
echo "========================"
total_checks=18
failed_checks=$((total_checks - $(grep -c "✅" /tmp/health-check.log 2>/dev/null || echo 0)))

if [ $failed_checks -eq 0 ]; then
    echo "✅ All systems operational!"
else
    echo "⚠️ $failed_checks out of $total_checks checks failed"
    echo "Run individual diagnostic scripts for failed components"
fi
```

## 📝 Runbooks {#runbooks}

### Runbook: High Error Rate

```markdown
# Runbook: High Error Rate Alert

## Alert Details
- **Alert Name**: HighErrorRate
- **Severity**: Critical
- **Threshold**: Error rate > 5% for 5 minutes

## Impact
- User experience degradation
- Potential revenue loss
- SLA violation risk

## Diagnosis Steps

1. **Identify affected service**
   ```bash
   kubectl logs -n monitoring prometheus-0 | grep HighErrorRate
   ```

2. **Check service logs**
   ```bash
   kubectl logs -n ecommerce-dev -l app=<service-name> --tail=100
   ```

3. **Check recent deployments**
   ```bash
   kubectl rollout history deployment/<service-name> -n ecommerce-dev
   ```

4. **Verify dependencies**
   ```bash
   kubectl exec -n ecommerce-dev deployment/<service-name> -- env | grep -E "(DATABASE|REDIS|API)"
   ```

## Resolution Steps

### Quick Fix (< 5 min)
1. **Rollback to previous version**
   ```bash
   kubectl rollout undo deployment/<service-name> -n ecommerce-dev
   ```

2. **Restart pods**
   ```bash
   kubectl rollout restart deployment/<service-name> -n ecommerce-dev
   ```

### Root Cause Analysis
1. **Collect error samples**
   ```bash
   kubectl logs -n ecommerce-dev -l app=<service-name> | grep ERROR > errors.log
   ```

2. **Check distributed traces**
   - Open Grafana
   - Go to Explore > Tempo
   - Filter by service and error status

3. **Review recent changes**
   ```bash
   git log --oneline -10
   argocd app history <app-name>
   ```

## Prevention
- Implement feature flags for gradual rollout
- Increase test coverage for error scenarios
- Add canary deployments
- Review and update alerts thresholds
```

### Runbook: Database Connection Issues

```markdown
# Runbook: Database Connection Pool Exhausted

## Alert Details
- **Alert Name**: DatabaseConnectionPoolExhausted
- **Severity**: Critical
- **Threshold**: Available connections < 10%

## Impact
- Application timeouts
- Degraded performance
- Potential cascading failures

## Diagnosis Steps

1. **Check connection pool metrics**
   ```sql
   SELECT count(*) as total,
          sum(case when state = 'active' then 1 else 0 end) as active,
          sum(case when state = 'idle' then 1 else 0 end) as idle,
          sum(case when state = 'idle in transaction' then 1 else 0 end) as idle_in_transaction,
          sum(case when state = 'idle in transaction (aborted)' then 1 else 0 end) as aborted
   FROM pg_stat_activity
   WHERE datname = 'ecommerce';
   ```

2. **Identify long-running queries**
   ```sql
   SELECT pid, 
          age(clock_timestamp(), query_start) as duration,
          usename,
          query,
          state
   FROM pg_stat_activity
   WHERE state != 'idle'
     AND query NOT ILIKE '%pg_stat_activity%'
   ORDER BY duration DESC
   LIMIT 10;
   ```

3. **Check application logs**
   ```bash
   kubectl logs -n ecommerce-dev -l app=api-gateway | grep -i "connection"
   ```

## Resolution Steps

### Immediate Actions
1. **Kill long-running queries**
   ```sql
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE state != 'idle'
     AND query_start < now() - interval '5 minutes';
   ```

2. **Increase connection pool temporarily**
   ```bash
   kubectl set env deployment/api-gateway -n ecommerce-dev \
     DB_POOL_MAX=50 \
     DB_POOL_MIN=10
   ```

3. **Restart affected services**
   ```bash
   kubectl rollout restart deployment -n ecommerce-dev -l tier=backend
   ```

### Long-term Solutions
1. **Optimize queries**
   - Add missing indexes
   - Review N+1 queries
   - Implement query caching

2. **Scale database**
   ```bash
   az postgres flexible-server update \
     --resource-group $RG \
     --name $DB_NAME \
     --sku-name Standard_D8s_v3
   ```

3. **Implement connection pooling**
   - Use PgBouncer
   - Configure application-level pooling

## Prevention
- Monitor connection pool usage
- Set up alerts at 70% threshold
- Regular query performance reviews
- Load testing with realistic connection patterns
```

## 🆘 Recuperação de Desastres {#recuperacao-desastres}

### Disaster Recovery Plan

```bash
#!/bin/bash
# scripts/disaster-recovery.sh

echo "🆘 Disaster Recovery Procedure"
echo "=============================="

# 1. Assess damage
assess_damage() {
    echo "📊 Assessing system damage..."
    
    # Check what's still running
    echo "Active components:"
    kubectl get pods --all-namespaces --field-selector status.phase=Running
    
    # Check data integrity
    echo "Database status:"
    kubectl exec -n ecommerce-prod deployment/api-gateway -- psql $DATABASE_URL -c "SELECT COUNT(*) FROM users;"
}

# 2. Backup current state
backup_current_state() {
    echo "💾 Backing up current state..."
    
    BACKUP_DIR="disaster-recovery-$(date +%Y%m%d-%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup Kubernetes resources
    kubectl get all,configmap,secret,ingress,pvc --all-namespaces -o yaml > $BACKUP_DIR/k8s-resources.yaml
    
    # Backup databases
    kubectl exec -n ecommerce-prod deployment/postgres -- pg_dumpall > $BACKUP_DIR/postgres-backup.sql
    
    # Backup persistent volumes
    kubectl get pv -o yaml > $BACKUP_DIR/persistent-volumes.yaml
}

# 3. Restore from backup
restore_from_backup() {
    local backup_timestamp=$1
    
    echo "📥 Restoring from backup: $backup_timestamp"
    
    # Restore database
    kubectl exec -n ecommerce-prod deployment/postgres -- psql < backups/$backup_timestamp/postgres-backup.sql
    
    # Restore Kubernetes resources
    kubectl apply -f backups/$backup_timestamp/k8s-resources.yaml
    
    # Restore GitOps state
    cd /tmp
    git clone https://github.com/$GITHUB_ORG/$GITHUB_REPO
    cd $GITHUB_REPO
    git checkout $backup_timestamp
    git push origin $backup_timestamp:main --force
}

# 4. Validate recovery
validate_recovery() {
    echo "✅ Validating recovery..."
    
    # Run health checks
    ./scripts/full-health-check.sh
    
    # Test critical paths
    curl -f https://portal.demo.threehorizons.io || echo "Portal check failed"
    curl -f https://api.demo.threehorizons.io/health || echo "API check failed"
    
    # Verify data integrity
    kubectl exec -n ecommerce-prod deployment/api-gateway -- npm run validate:data
}

# Main recovery procedure
case "${1:-assess}" in
    assess)
        assess_damage
        ;;
    backup)
        backup_current_state
        ;;
    restore)
        restore_from_backup $2
        validate_recovery
        ;;
    full)
        assess_damage
        backup_current_state
        restore_from_backup $2
        validate_recovery
        ;;
    *)
        echo "Usage: $0 {assess|backup|restore <timestamp>|full <timestamp>}"
        ;;
esac
```

---

## 🎯 Quick Reference Card

```bash
# Most common fixes - copy/paste ready

# Pod in CrashLoop
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force

# ArgoCD out of sync
argocd app sync <app-name> --force --prune

# High memory usage
kubectl set resources deployment/<name> -n <namespace> --limits=memory=2Gi

# Database connections exhausted
kubectl set env deployment/<name> -n <namespace> DB_POOL_MAX=50

# Certificate expired
kubectl delete certificate <cert-name> -n <namespace>
kubectl apply -f <cert-manifest>

# Prometheus not scraping
kubectl rollout restart deployment -n monitoring prometheus-operator

# 503 errors
kubectl rollout restart deployment -n ingress-nginx

# Clear Redis cache
kubectl exec -n <namespace> deployment/redis -- redis-cli FLUSHALL

# Emergency scale
kubectl scale deployment <name> -n <namespace> --replicas=0
kubectl scale deployment <name> -n <namespace> --replicas=3
```

---

**📝 Notas Importantes**

1. **Sempre faça backup** antes de aplicar fixes
2. **Documente** todas as ações tomadas
3. **Comunique** a equipe sobre problemas em andamento
4. **Post-mortem** após incidentes críticos
5. **Automatize** fixes recorrentes