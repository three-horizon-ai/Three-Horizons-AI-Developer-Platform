# <span style="color: #0366d6;">🔹 OpenShift GitOps Setup for Three Horizons</span>

This guide explains how to set up and configure OpenShift GitOps (ArgoCD) for use with the Three Horizons platform.

## <span style="color: #0366d6;">🔍 Overview</span>

OpenShift GitOps is a key component of the Three Horizons platform that enables declarative, GitOps-based deployment of applications and infrastructure. By using GitOps principles, we ensure that the desired state of our applications is always stored in Git and automatically synchronized to our environments.

## <span style="color: #0366d6;">🔹 Prerequisites</span>

- Azure Red Hat OpenShift (ARO) cluster with administrator access
- `oc` CLI tool installed and configured
- GitHub (or other Git provider) repository for storing manifests
- Necessary permissions to install operators in OpenShift

## <span style="color: #0366d6;">🚀 Installation</span>

### <span style="color: #0366d6;">Installing the OpenShift GitOps Operator</span>

1. Log in to your OpenShift cluster as an administrator

2. Install the GitOps Operator via the OpenShift web console:
   - Navigate to **Operators** > **OperatorHub**
   - Search for "Red Hat OpenShift GitOps"
   - Click **Install**
   - Accept the default settings and click **Install** again

3. Alternatively, install via CLI:

```bash
# <span style="color: #0366d6;">🔹 Create namespace</span>
oc create namespace openshift-gitops

# <span style="color: #0366d6;">🔹 Apply the Operator subscription</span>
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

4. Verify the installation:

```bash
oc get pods -n openshift-gitops
```

You should see several pods including the ArgoCD server, repo server, and application controller.

## <span style="color: #0366d6;">🔹 Configuration</span>

### <span style="color: #0366d6;">Accessing ArgoCD</span>

1. Get the ArgoCD URL:

```bash
oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}'
```

2. Retrieve the admin password:

```bash
oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-
```

3. Log in to the ArgoCD UI using:
   - Username: `admin`
   - Password: (from the previous step)

### <span style="color: #0366d6;">Setting Up Projects</span>

Create separate ArgoCD projects for different application teams or environments:

```bash
# <span style="color: #0366d6;">🔹 Create a Development project</span>
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: development
  namespace: openshift-gitops
spec:
  description: Development Environment Applications
  sourceRepos:
  - '*'
  destinations:
  - namespace: 'dev-*'
    server: 'https://kubernetes.default.svc'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
EOF

# <span style="color: #0366d6;">🔹 Create a Production project</span>
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: openshift-gitops
spec:
  description: Production Environment Applications
  sourceRepos:
  - '*'
  destinations:
  - namespace: 'prod-*'
    server: 'https://kubernetes.default.svc'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
EOF
```

### <span style="color: #0366d6;">Connecting Git Repositories</span>

1. Create a secret with your Git credentials:

```bash
# <span style="color: #0366d6;">🔹 For GitHub with personal access token</span>
oc create secret generic github-credentials \
  --namespace openshift-gitops \
  --from-literal=username=YOUR_GITHUB_USERNAME \
  --from-literal=password=YOUR_GITHUB_TOKEN
```

2. Add the repository to ArgoCD:

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-repo-secret
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/your-org/your-repo.git
  username: YOUR_GITHUB_USERNAME
  password: YOUR_GITHUB_TOKEN
EOF
```

## <span style="color: #0366d6;">🔹 Defining Applications</span>

### <span style="color: #0366d6;">Application Structure</span>

For Three Horizons, we recommend organizing your GitOps repository with the following structure:

```
├── apps/
│   ├── developer-hub/
│   │   ├── base/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── kustomization.yaml
│   │   ├── overlays/
│   │   │   ├── dev/
│   │   │   │   ├── config.yaml
│   │   │   │   └── kustomization.yaml
│   │   │   └── prod/
│   │   │       ├── config.yaml
│   │   │       └── kustomization.yaml
│   └── other-app/
│       └── ...
├── environments/
│   ├── dev/
│   │   ├── applications.yaml
│   │   └── kustomization.yaml
│   └── prod/
│       ├── applications.yaml
│       └── kustomization.yaml
```

### <span style="color: #0366d6;">Creating an Application</span>

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: developer-hub
  namespace: openshift-gitops
spec:
  project: development
  source:
    repoURL: https://github.com/your-org/your-repo.git
    targetRevision: HEAD
    path: apps/developer-hub/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: dev-developer-hub
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## <span style="color: #0366d6;">🚀 Deployment Strategies</span>

### <span style="color: #0366d6;">Blue-Green Deployments</span>

For blue-green deployments with OpenShift GitOps:

1. Create two identical deployments (blue and green)
2. Use a service to route traffic to the active version
3. Update the inactive version with new changes
4. Switch the service to the updated version

Example application configuration:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: openshift-gitops
  annotations:
    argocd-image-updater.argoproj.io/image-list: myapp=quay.io/myorg/myapp
    argocd-image-updater.argoproj.io/myapp.update-strategy: blue-green
    argocd-image-updater.argoproj.io/myapp.blue-green.active-selector: role=active
    argocd-image-updater.argoproj.io/myapp.blue-green.inactive-selector: role=inactive
spec:
  project: default
  source:
    # ...
  syncPolicy:
    # ...
```

### <span style="color: #0366d6;">Canary Deployments</span>

For canary deployments, use a service mesh like OpenShift Service Mesh (Istio):

1. Deploy the new version alongside the existing version
2. Route a small percentage of traffic to the new version
3. Gradually increase traffic to the new version
4. Eventually replace the old version

## <span style="color: #0366d6;">⚙️ Integrating with Three Horizons Components</span>

### <span style="color: #0366d6;">Integrating with Developer Hub</span>

1. Register the GitOps repository in the Developer Hub catalog
2. Create a software template that sets up GitOps-friendly applications
3. Configure the Developer Hub to display GitOps deployment status

### <span style="color: #0366d6;">Integrating with GitHub Actions</span>

Create a GitHub Actions workflow that updates manifests in your GitOps repository:

```yaml
name: Update GitOps Repository

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: 'New image tag to deploy'
        required: true

jobs:
  update-gitops:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          repository: your-org/gitops-repo
          token: ${{ secrets.GH_PAT }}
          
      - name: Update image version
        run: |
          cd apps/my-app/overlays/dev
          kustomize edit set image quay.io/myorg/myapp:${{ github.event.inputs.image_tag }}
          
      - name: Commit and push changes
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "Update my-app to ${{ github.event.inputs.image_tag }}"
          git push
```

## <span style="color: #0366d6;">🔹 Best Practices</span>

- Use Kustomize for managing environment-specific configurations
- Implement cluster bootstrapping with GitOps (install operators and configurations)
- Establish clear separation between application and infrastructure repositories
- Implement proper RBAC for ArgoCD projects
- Configure health checks and monitoring for GitOps components
- Use sealed secrets for managing sensitive information

## <span style="color: #0366d6;">🔧 Troubleshooting</span>

- **Application not syncing**: Check the application status in ArgoCD UI and look for error messages
- **Permission issues**: Verify that the ArgoCD service account has necessary permissions
- **Git authentication problems**: Test Git credentials and check repository access
- **Resource conflicts**: Ensure that resources aren't being managed by multiple controllers

## <span style="color: #0366d6;">📚 Additional Resources</span>

- [OpenShift GitOps Documentation](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
