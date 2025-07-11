#!/bin/bash
#
# Three Horizons AI Developer Platform - DevBox Initialization
# This script runs on the host machine before the container is created
#

set -e

echo "🚀 Three Horizons AI Platform - Initializing DevBox..."

# Check if required environment variables are set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN environment variable is not set."
    echo "   Please set it with: export GITHUB_TOKEN=your_token_here"
fi

if [ -z "$AZURE_SUBSCRIPTION_ID" ]; then
    echo "⚠️  AZURE_SUBSCRIPTION_ID environment variable is not set."
    echo "   Please set it with: export AZURE_SUBSCRIPTION_ID=your_subscription_id"
fi

# Create local directories if they don't exist
mkdir -p ~/.azure
mkdir -p ~/.kube
mkdir -p ~/.ssh

echo "✅ Initialization complete. Starting container..."
