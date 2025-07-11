#!/bin/bash
#
# Three Horizons AI Developer Platform - DevBox Post-Create Setup
# This script runs after the devcontainer is created
#

set -e

echo "🔧 Three Horizons AI Platform - Setting up development environment..."

# Update package lists
sudo apt-get update

# Install additional development tools
echo "📦 Installing additional development tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    yq \
    htop \
    tree \
    unzip \
    zip \
    make \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release

# Install Azure AI CLI if AI tools are selected
if command -v python3 &> /dev/null; then
    echo "🤖 Installing Azure AI CLI..."
    pip3 install --user azure-ai-cli
fi

# Install additional Node.js tools if Node.js is available
if command -v node &> /dev/null; then
    echo "🟢 Installing Node.js development tools..."
    npm install -g \
        @azure/cli \
        typescript \
        @types/node \
        nodemon \
        ts-node \
        eslint \
        prettier \
        jest \
        @nestjs/cli \
        @angular/cli \
        create-react-app \
        vite
fi

# Install Python development tools if Python is available
if command -v python3 &> /dev/null; then
    echo "🐍 Installing Python development tools..."
    pip3 install --user \
        azure-cli \
        azure-identity \
        azure-keyvault-secrets \
        azure-storage-blob \
        requests \
        flask \
        fastapi \
        uvicorn \
        pytest \
        black \
        flake8 \
        mypy \
        jupyter \
        pandas \
        numpy \
        matplotlib \
        scikit-learn
fi

# Install .NET tools if .NET is available
if command -v dotnet &> /dev/null; then
    echo "🔷 Installing .NET development tools..."
    dotnet tool install -g dotnet-ef
    dotnet tool install -g dotnet-aspnet-codegenerator
fi

# Configure Git if not already configured
if [ -z "$(git config --global user.name)" ]; then
    echo "📝 Configuring Git..."
    if [ ! -z "$DEVELOPER_NAME" ]; then
        git config --global user.name "$DEVELOPER_NAME"
    fi
    if [ ! -z "$GITHUB_EMAIL" ]; then
        git config --global user.email "$GITHUB_EMAIL"
    fi
fi

# Set up shell preferences
if [ "$PREFERRED_SHELL" = "zsh" ] && command -v zsh &> /dev/null; then
    echo "🐚 Configuring Zsh..."
    # Install oh-my-zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
    
    # Update plugins in .zshrc
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl docker azure)/' ~/.zshrc || true
fi

# Create helpful aliases
echo "🔗 Setting up helpful aliases..."
cat >> ~/.bashrc << 'EOF'

# Three Horizons AI Platform aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias azlogin='az login --use-device-code'
alias azctx='az account show'
alias h1='cd /workspace/templates/h1-foundation'
alias h2='cd /workspace/templates/h2-optimization'
alias h3='cd /workspace/templates/h3-innovation'
alias devbox='cd /workspace/templates/h0-devbox'
alias three-horizons-help='cat /workspace/.devcontainer/DEVELOPMENT-GUIDE.md'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gb='git branch'
alias gco='git checkout'

EOF

# Add aliases to zsh if it's the preferred shell
if [ "$PREFERRED_SHELL" = "zsh" ] && [ -f ~/.zshrc ]; then
    cat >> ~/.zshrc << 'EOF'

# Three Horizons AI Platform aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias azlogin='az login --use-device-code'
alias azctx='az account show'
alias h1='cd /workspace/templates/h1-foundation'
alias h2='cd /workspace/templates/h2-optimization'
alias h3='cd /workspace/templates/h3-innovation'
alias devbox='cd /workspace/templates/h0-devbox'
alias three-horizons-help='cat /workspace/.devcontainer/DEVELOPMENT-GUIDE.md'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gb='git branch'
alias gco='git checkout'

EOF
fi

# Create workspace directories
echo "📁 Creating workspace structure..."
mkdir -p /workspace/playground
mkdir -p /workspace/projects
mkdir -p /workspace/scripts
mkdir -p /workspace/docs

# Create a welcome script
cat > /workspace/welcome.sh << 'EOF'
#!/bin/bash
echo "🌟 Welcome to Three Horizons AI Developer Platform!"
echo ""
echo "📚 Available Templates:"
echo "   • H0 DevBox: Developer environment foundation"
echo "   • H1 Foundation: Core microservices and infrastructure"
echo "   • H2 Optimization: Advanced GitOps and scaling"
echo "   • H3 Innovation: AI and experimentation platform"
echo ""
echo "🚀 Quick Start:"
echo "   • Type 'three-horizons-help' for comprehensive guide"
echo "   • Use 'h1', 'h2', 'h3', 'devbox' to navigate"
echo "   • Run 'azlogin' to authenticate with Azure"
echo "   • Use 'k' for kubectl commands"
echo ""
echo "💡 Need help? Check the documentation in /workspace/docs"
echo ""
EOF

chmod +x /workspace/welcome.sh

# Set permissions for scripts
chmod +x /workspace/.devcontainer/*.sh

echo "✅ Three Horizons AI DevBox setup complete!"
echo "🎉 Run '/workspace/welcome.sh' to see available commands"
