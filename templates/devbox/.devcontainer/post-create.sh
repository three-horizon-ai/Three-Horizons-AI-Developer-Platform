#!/bin/bash
set -e

echo "Setting up Three Horizons development environment..."

# Install additional tools
echo "Installing additional development tools..."
sudo apt-get update
sudo apt-get install -y curl wget jq unzip git

# Install Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install OpenShift CLI
echo "Installing OpenShift CLI (oc)..."
OC_VERSION="4.13.0"
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz -o openshift-client.tar.gz
tar -xzf openshift-client.tar.gz -C /tmp
sudo mv /tmp/oc /usr/local/bin/
sudo mv /tmp/kubectl /usr/local/bin/
rm openshift-client.tar.gz

# Check installations
echo "Verifying installations..."
az --version
gh --version
docker --version
node --version
terraform --version
oc version

echo "Three Horizons development environment setup complete!" 