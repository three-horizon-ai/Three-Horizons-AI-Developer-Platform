#!/bin/bash
set -e

# Three Horizons Local Development Environment Setup
echo "Setting up Three Horizons local development environment..."

# Check operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  echo "Detected macOS operating system"
  
  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew already installed, updating..."
    brew update
  fi
  
  # Install required tools
  echo "Installing required tools..."
  brew install azure-cli
  brew install github
  brew install kubernetes-cli
  brew install terraform
  brew install helm
  brew install jq
  brew install node
  brew install docker
  
  # Install OpenShift CLI
  echo "Installing OpenShift CLI..."
  brew install openshift-cli

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  echo "Detected Linux operating system"
  
  # Update package lists
  echo "Updating package lists..."
  sudo apt-get update
  
  # Install basic utilities
  echo "Installing basic utilities..."
  sudo apt-get install -y curl wget git jq unzip

  # Install Azure CLI
  echo "Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  
  # Install GitHub CLI
  echo "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
  
  # Install Terraform
  echo "Installing Terraform..."
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  
  # Install Kubectl
  echo "Installing Kubectl..."
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
  
  # Install OpenShift CLI
  echo "Installing OpenShift CLI..."
  OC_VERSION="4.13.0"
  curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz -o openshift-client.tar.gz
  tar -xzf openshift-client.tar.gz -C /tmp
  sudo mv /tmp/oc /usr/local/bin/
  sudo mv /tmp/kubectl /usr/local/bin/ 2>/dev/null || true
  rm openshift-client.tar.gz
  
  # Install Helm
  echo "Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  
  # Install Node.js
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs

else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Configure Azure CLI
echo "Configuring Azure CLI..."
az config set extension.use_dynamic_install=yes_without_prompt

# Log in to Azure (interactive)
echo "Please log in to Azure..."
az login

# Log in to GitHub (interactive)
echo "Please log in to GitHub..."
gh auth login

echo "Three Horizons local development environment setup complete!"
echo "You can now start developing with the Three Horizons platform." 