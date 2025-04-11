# <span style="color: #0366d6;">🔹 Scaling Operations</span>

## <span style="color: #0366d6;">🔍 Overview</span>

This document outlines the scaling strategies and operational procedures for the Three Horizons platform. It covers both horizontal and vertical scaling approaches, autoscaling configurations, and best practices for handling increased workloads.

## <span style="color: #0366d6;">🔹 Prerequisites</span>

- Access to Azure Portal or appropriate management tools
- Appropriate permissions to modify resource allocations
- Monitoring tools configuration (Azure Monitor, Prometheus/Grafana)

## <span style="color: #0366d6;">⚙️ Scaling Components</span>

### <span style="color: #0366d6;">Kubernetes Cluster Scaling</span>

#### Node Scaling

- **Manual Node Scaling**: Instructions for manually adjusting node counts in Azure portal or via CLI
  ```bash
  az aks scale --resource-group myResourceGroup --name myAKSCluster --node-count 5
  ```

- **Cluster Autoscaler**: Configuration for automatic node provisioning based on workload demands
  ```yaml
  apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  metadata:
    name: cluster-autoscaler
  spec:
    minReplicas: 3
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80
  ```

#### Pod Scaling

- **Horizontal Pod Autoscaler (HPA)**: Configuration for automatically scaling pod replicas
  ```yaml
  apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  metadata:
    name: application-hpa
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: application-deployment
    minReplicas: 2
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

- **Vertical Pod Autoscaler (VPA)**: Configuration for automatically adjusting pod resource requests
  ```yaml
  apiVersion: autoscaling.k8s.io/v1
  kind: VerticalPodAutoscaler
  metadata:
    name: application-vpa
  spec:
    targetRef:
      apiVersion: "apps/v1"
      kind: Deployment
      name: application-deployment
    updatePolicy:
      updateMode: "Auto"
  ```

### <span style="color: #0366d6;">Database Scaling</span>

- **Azure SQL Database Scaling**: Procedures for scaling database resources
  - DTU-based scaling
  - vCore-based scaling
  - Read replicas configuration

- **Cosmos DB Scaling**: Automatic scaling and throughput adjustment

### <span style="color: #0366d6;">Storage Scaling</span>

- **Azure Storage Account Scaling**: Best practices for managing storage growth
- **Persistent Volume Scaling**: Managing dynamic provisioning

## <span style="color: #0366d6;">🔹 Scaling Policies and Best Practices</span>

### <span style="color: #0366d6;">Scaling Thresholds</span>

| Resource Type | Metric | Warning Threshold | Critical Threshold | Action |
|---------------|--------|-------------------|-------------------|--------|
| Kubernetes Node | CPU Utilization | 70% | 85% | Add nodes |
| Kubernetes Node | Memory Utilization | 75% | 90% | Add nodes |
| Application Pod | CPU Utilization | 60% | 80% | Scale replica count |
| Database | DTU Utilization | 65% | 85% | Increase DTU/vCore |
| Storage | Capacity | 70% | 85% | Increase storage allocation |

### <span style="color: #0366d6;">Scaling Workflow</span>

1. **Monitoring**: Establish baselines and continuous monitoring
2. **Alerting**: Configure alerts based on thresholds
3. **Analysis**: Review metrics and determine scaling needs
4. **Implementation**: Apply scaling changes
5. **Validation**: Verify system performance after scaling
6. **Documentation**: Update configuration documentation

## <span style="color: #0366d6;">🔹 Scheduled Scaling</span>

For predictable workload patterns, configure scheduled scaling:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: ScheduledPodAutoscaler
metadata:
  name: workday-scaling
spec:
  timeZone: "Europe/London"
  schedule:
  - name: "business-hours"
    cronExpression: "0 8 * * 1-5"
    replicas: 10
  - name: "non-business-hours"
    cronExpression: "0 18 * * 1-5"
    replicas: 3
```

## <span style="color: #0366d6;">🔹 Cost Management</span>

- Implement automatic scale-down during periods of low usage
- Configure resource quotas to prevent over-scaling
- Regular review of resource utilization to optimize costs

## <span style="color: #0366d6;">🔧 Troubleshooting Scaling Issues</span>

### <span style="color: #0366d6;">Common Issues and Resolutions</span>

| Issue | Possible Causes | Resolution |
|-------|----------------|------------|
| Autoscaler not triggering | Incorrect metric configuration | Verify metrics and thresholds |
| Scale-up too slow | Insufficient resources in cluster | Add nodes or adjust reservation |
| Oscillation (frequent up/down) | Thresholds too close together | Adjust thresholds and cooldown periods |

### <span style="color: #0366d6;">Diagnostic Commands</span>

```bash
# <span style="color: #0366d6;">🔹 Check HPA status</span>
kubectl get hpa -A

# <span style="color: #0366d6;">🔹 Check cluster autoscaler logs</span>
kubectl logs -n kube-system -l app=cluster-autoscaler

# <span style="color: #0366d6;">📚 Check node resource utilization</span>
kubectl top nodes

# <span style="color: #0366d6;">📚 Check pod resource utilization</span>
kubectl top pods -A
```

## <span style="color: #0366d6;">🔹 Related Documentation</span>

For related information, see other operations documentation.

## <span style="color: #0366d6;">🔹 Contact</span>


---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
