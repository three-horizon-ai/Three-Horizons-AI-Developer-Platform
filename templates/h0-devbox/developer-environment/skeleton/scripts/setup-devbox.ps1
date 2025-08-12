# Three Horizons AI Developer Platform - Dev Box Setup Script
# This script configures a freshly provisioned Dev Box with all necessary tools and settings

param(
    [string]$DeveloperName = "{{ values.developer_name }}",
    [string]$PreferredShell = "{{ values.preferred_shell }}",
    [string]$AzureSubscriptionId = "{{ values.azure_subscription_id }}",
    [bool]$SetupAzureAuth = ${{ values.setup_azure_auth }},
    [bool]$SetupAksAccess = ${{ values.setup_aks_access }}
)

Write-Host "🚀 Starting Three Horizons AI Dev Box setup for $DeveloperName..." -ForegroundColor Green

# Create workspace directory
$WorkspaceDir = "C:\Workspaces\Three-Horizons-AI-Developer-Platform"
if (!(Test-Path $WorkspaceDir)) {
    Write-Host "📁 Creating workspace directory..." -ForegroundColor Blue
    New-Item -ItemType Directory -Force -Path "C:\Workspaces"
    Set-Location "C:\Workspaces"
    
    # Clone the main repository
    Write-Host "📥 Cloning Three Horizons AI Developer Platform repository..." -ForegroundColor Blue
    git clone https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform.git
}

Set-Location $WorkspaceDir

# Configure Git
Write-Host "🔧 Configuring Git..." -ForegroundColor Blue
git config --global user.name "$DeveloperName"
if ("{{ values.azure_subscription_id }}" -ne "") {
    git config --global user.email "$DeveloperName@company.com"
}

# Install VS Code extensions
Write-Host "🔌 Installing VS Code extensions..." -ForegroundColor Blue
$extensions = @(
{% for extension in values.vscode_extensions %}
    "{{ extension }}"{% if not loop.last %},{% endif %}
{% endfor %}
)

foreach ($extension in $extensions) {
    Write-Host "  Installing $extension..." -ForegroundColor Gray
    code --install-extension $extension
}

# Configure Azure CLI if requested
if ($SetupAzureAuth) {
    Write-Host "☁️ Configuring Azure CLI..." -ForegroundColor Blue
    az login --use-device-code
    
    if ($AzureSubscriptionId -ne "") {
        Write-Host "🎯 Setting Azure subscription..." -ForegroundColor Blue
        az account set --subscription $AzureSubscriptionId
    }
}

# Setup AKS access if requested
if ($SetupAksAccess -and $SetupAzureAuth) {
    Write-Host "🚢 Setting up AKS access..." -ForegroundColor Blue
    # This will be configured based on available AKS clusters
    $aksClusters = az aks list --query "[].{name:name, resourceGroup:resourceGroup}" -o json | ConvertFrom-Json
    
    if ($aksClusters.Count -gt 0) {
        foreach ($cluster in $aksClusters) {
            Write-Host "  Configuring access to AKS cluster: $($cluster.name)" -ForegroundColor Gray
            az aks get-credentials --resource-group $cluster.resourceGroup --name $cluster.name
        }
    }
}

# Install additional AI/ML tools if Python is selected
{% if 'python' in values.languages %}
Write-Host "🤖 Installing AI/ML Python packages..." -ForegroundColor Blue
$aiPackages = @(
{% for tool in values.ai_tools %}
    {% if tool == 'jupyter' %}"jupyter"{% endif %}
    {% if tool == 'tensorboard' %}"tensorboard"{% endif %}
    {% if tool == 'mlflow' %}"mlflow"{% endif %}
    {% if tool == 'langchain' %}"langchain"{% endif %}
    {% if tool == 'huggingface-cli' %}"huggingface_hub"{% endif %}
{% endfor %}
    "azure-ai-ml"
    "pandas"
    "numpy"
    "scikit-learn"
)

pip install --upgrade pip
foreach ($package in $aiPackages) {
    if ($package -ne "") {
        Write-Host "  Installing $package..." -ForegroundColor Gray
        pip install $package
    }
}
{% endif %}

# Configure workspace settings if requested
{% if values.workspace_settings %}
Write-Host "⚙️ Applying workspace settings..." -ForegroundColor Blue
$workspaceSettings = @{
    "editor.formatOnSave" = $true
    "editor.codeActionsOnSave" = @{
        "source.organizeImports" = $true
    }
    "files.autoSave" = "onFocusChange"
    "terminal.integrated.defaultProfile.windows" = "PowerShell"
    "azure.showSignedInEmail" = $true
    "git.autofetch" = $true
    "workbench.startupEditor" = "readme"
}

$settingsDir = "$WorkspaceDir\.vscode"
if (!(Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Force -Path $settingsDir
}

$workspaceSettings | ConvertTo-Json -Depth 10 | Out-File -FilePath "$settingsDir\settings.json" -Encoding UTF8
{% endif %}

# Open the workspace in VS Code
Write-Host "💻 Opening workspace in VS Code..." -ForegroundColor Blue
code "$WorkspaceDir\three-horizons-devbox.code-workspace"

# Display completion message
Write-Host "`n✅ Three Horizons AI Dev Box setup completed successfully!" -ForegroundColor Green
Write-Host "📁 Workspace location: $WorkspaceDir" -ForegroundColor Yellow
Write-Host "🎯 You can now start developing with the Three Horizons AI Platform!" -ForegroundColor Yellow

# Display useful commands
Write-Host "`n📚 Useful commands:" -ForegroundColor Cyan
Write-Host "  • Open workspace: code '$WorkspaceDir'" -ForegroundColor White
Write-Host "  • View documentation: Get-ChildItem '$WorkspaceDir\docs'" -ForegroundColor White
Write-Host "  • Explore templates: Get-ChildItem '$WorkspaceDir\templates'" -ForegroundColor White
{% if values.setup_azure_auth %}
Write-Host "  • Check Azure account: az account show" -ForegroundColor White
{% endif %}
{% if values.setup_aks_access %}
Write-Host "  • List Kubernetes contexts: kubectl config get-contexts" -ForegroundColor White
{% endif %}
