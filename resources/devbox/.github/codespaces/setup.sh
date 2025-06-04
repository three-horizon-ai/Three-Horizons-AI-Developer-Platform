#!/bin/bash
set -e

echo "Setting up Three Horizons Codespace environment..."

# Install OpenShift CLI
echo "Installing OpenShift CLI (oc)..."
OC_VERSION="4.13.0"
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz -o openshift-client.tar.gz
tar -xzf openshift-client.tar.gz -C /tmp
sudo mv /tmp/oc /usr/local/bin/
sudo mv /tmp/kubectl /usr/local/bin/ 2>/dev/null || true
rm openshift-client.tar.gz

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Set up environment variables
echo "Setting up environment variables..."
echo 'export THREE_HORIZONS_ENV="development"' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc

# Clone additional repositories if needed
# Uncomment and modify as needed
# echo "Cloning additional repositories..."
# mkdir -p ~/workspace
# cd ~/workspace
# git clone https://github.com/your-org/your-repo.git

# Additional setup specific to your project
echo "Running project-specific setup..."
# Add your project-specific setup commands here

echo "Three Horizons Codespace environment setup complete!" 