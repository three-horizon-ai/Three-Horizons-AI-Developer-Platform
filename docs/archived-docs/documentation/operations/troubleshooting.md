# <span style="color: #0366d6;">🔧 Troubleshooting Guide</span>

This document provides solutions to common issues you might encounter when implementing the Azure OpenShift Developer Experience solution.

## <span style="color: #0366d6;">🔹 Table of Contents</span>

1. [OpenShift Installation Issues](#openshift-installation-issues)
2. [GitHub Integration Issues](#github-integration-issues)
3. [DevHub Configuration Issues](#devhub-configuration-issues)
4. [Integration Service Issues](#integration-service-issues)
5. [Network and Connectivity Issues](#network-and-connectivity-issues)

## <span style="color: #0366d6;">🚀 OpenShift Installation Issues</span>

### <span style="color: #0366d6;">Insufficient Quota in Azure Subscription</span>

**Symptoms:**
- Installation fails with quota exceeded errors
- Error message mentions Azure resource quotas

**Solution:**
1. Go to your Azure Portal
2. Navigate to Subscriptions > Your Subscription > Usage + quotas
3. Review current quota usage
4. Request quota increase for required resources (vCPUs, storage, etc.)
5. Once approved, restart the installation

### <span style="color: #0366d6;">Missing Resource Provider Registrations</span>

**Symptoms:**
- Errors about "Resource provider not registered"
- Azure deployment fails early in the process

**Solution:**
```bash
# <span style="color: #0366d6;">🔹 Register all required providers</span>
az provider register --namespace Microsoft.RedHatOpenShift
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Authorization
az provider register --namespace Microsoft.ContainerService

# <span style="color: #0366d6;">🔹 Verify registration status</span>
az provider show -n Microsoft.RedHatOpenShift --query "registrationState"
```

### <span style="color: #0366d6;">Incorrect Service Principal Permissions</span>

**Symptoms:**
- Authentication errors during cluster creation
- Permission denied errors in Azure operations

**Solution:**
1. Verify the service principal has correct permissions:
```bash
# <span style="color: #0366d6;">📚 Grant Contributor access to resource group</span>
az role assignment create --assignee <APP_ID> \
  --role "Contributor" \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>
```

2. Ensure the service principal credentials are correct in your environment:
```bash
# <span style="color: #0366d6;">🔹 Check if credentials are set correctly</span>
env | grep AZURE_
```

## <span style="color: #0366d6;">🔧 GitHub Integration Issues</span>

### <span style="color: #0366d6;">GitHub Actions Workflow Failures</span>

**Symptoms:**
- GitHub Actions workflows fail with authentication errors
- Error messages about "invalid token" or "unauthorized"

**Solution:**
1. Verify the secret values:
```bash
# <span style="color: #0366d6;">📘 Check if the secret exists (will not show value)</span>
gh secret list --org YOUR_ORG
```

2. Recreate the OpenShift service account and token:
```bash
# <span style="color: #0366d6;">🔹 Create a new service account</span>
oc create serviceaccount github-actions-new -n default

# <span style="color: #0366d6;">🔹 Add appropriate roles</span>
oc adm policy add-cluster-role-to-user edit -z github-actions-new -n default

# <span style="color: #0366d6;">🔹 Get new token</span>
NEW_SA_SECRET=$(oc get serviceaccount github-actions-new -n default -o jsonpath='{.secrets[0].name}')
NEW_SA_TOKEN=$(oc get secret $NEW_SA_SECRET -n default -o jsonpath='{.data.token}' | base64 --decode)

# <span style="color: #0366d6;">🔹 Update GitHub secret</span>
gh secret set OPENSHIFT_TOKEN -b"$NEW_SA_TOKEN" --org YOUR_ORG
```

### <span style="color: #0366d6;">GitHub App Integration Issues</span>

**Symptoms:**
- Webhooks not triggering expected actions
- Error messages in DevHub logs about GitHub API permissions

**Solution:**
1. Verify the GitHub App has the required permissions
2. Ensure the webhook URL is correct and accessible from GitHub
3. Check the webhook secret matches between GitHub and DevHub

## <span style="color: #0366d6;">🔧 DevHub Configuration Issues</span>

### <span style="color: #0366d6;">DevHub Operator Installation Failures</span>

**Symptoms:**
- Operator fails to install or start
- Error messages in operator logs

**Solution:**
1. Check the operator status:
```bash
# <span style="color: #0366d6;">🔹 Check operator subscription</span>
oc get subscription -n openshift-operators

# <span style="color: #0366d6;">🚀 Check if CSV is installed</span>
oc get csv -n openshift-operators | grep developer-hub

# <span style="color: #0366d6;">🚀 Check for any operator install plans</span>
oc get installplan -n openshift-operators
```

2. If stuck, clean up and reinstall:
```bash
# <span style="color: #0366d6;">🔹 Delete subscription</span>
oc delete subscription rhoda-operator -n openshift-operators

# <span style="color: #0366d6;">🔹 Delete any CSV</span>
oc delete csv <csv-name> -n openshift-operators

# <span style="color: #0366d6;">🚀 Reinstall with correct parameters</span>
```

### <span style="color: #0366d6;">DevHub Database Connection Issues</span>

**Symptoms:**
- DevHub pods starting but then crashing
- Logs showing database connection errors

**Solution:**
1. Check the database service:
```bash
oc get svc -n devhub | grep database
```

2. Verify database pods are running:
```bash
oc get pods -n devhub | grep database
```

3. Check database logs:
```bash
oc logs deployment/devhub-database -n devhub
```

4. If needed, recreate the database:
```bash
oc delete pvc data-devhub-database-0 -n devhub
oc delete deployment devhub-database -n devhub
# <span style="color: #0366d6;">📊 DevHub operator should recreate it, monitor:</span>
oc get pods -n devhub -w
```

## <span style="color: #0366d6;">🔧 Integration Service Issues</span>

### <span style="color: #0366d6;">Integration Service Not Communicating with DevHub</span>

**Symptoms:**
- Components created in DevHub don't trigger GitHub operations
- GitHub events don't update DevHub status

**Solution:**
1. Verify the service URLs are correct in deployment:
```bash
oc get deployment three-horizons-integration-service -n devhub -o yaml | grep -A 5 DEVHUB_URL
```

2. Check integration service logs:
```bash
oc logs deployment/three-horizons-integration-service -n devhub
```

3. Ensure network policies allow communication:
```bash
# <span style="color: #0366d6;">🔹 Create explicit network policy allowing communication</span>
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-devhub-integration
  namespace: devhub
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
EOF
```

## <span style="color: #0366d6;">🔧 Network and Connectivity Issues</span>

### <span style="color: #0366d6;">External Service Access Problems</span>

**Symptoms:**
- Components can't access GitHub, Azure, or other external services
- Connection timeout errors

**Solution:**
1. Verify egress connectivity:
```bash
# <span style="color: #0366d6;">🔹 Test from a debug pod</span>
oc run debug-pod --image=registry.access.redhat.com/ubi8/ubi-minimal -- sleep 3600
oc exec -it debug-pod -- curl -v https://api.github.com
```

2. Check network policies:
```bash
oc get networkpolicy -n devhub
```

3. Verify proxy settings if using a proxy:
```bash
oc set env deployment/three-horizons-integration-service -n devhub --list | grep PROXY
```


---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
