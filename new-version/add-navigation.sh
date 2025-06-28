#!/bin/bash

# Script para adicionar navegação Previous/Next a todos os documentos
# Adiciona tabela de navegação e links de navegação no final

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧭 Adicionando navegação aos documentos${NC}"
echo "========================================"

# Diretório base
DOCS_DIR="/Users/paulasilva/Documents/paulasilvatech/GH Repos/Three-Horizons-AI-Developer-Platform/new-version/docs"

# Função para adicionar navegação a um documento
add_navigation() {
    local file="$1"
    local title="$2"
    local prev_link="$3"
    local prev_title="$4"
    local next_link="$5"
    local next_title="$6"
    local horizon="$7"
    local section="$8"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC} Arquivo não encontrado: $file"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Adicionando navegação: $(basename "$file")"
    
    # Criar arquivo temporário
    local temp_file="${file}.temp"
    
    # Ler primeira linha (título)
    local first_line=$(head -n 1 "$file")
    
    # Criar nova navegação
    cat > "$temp_file" << EOF
$first_line

<div align="center">

![Architecture Diagram](../../assets/diagrams/three-horizons-architecture.svg)

**$title**

</div>

## 📍 Navigation

| Previous | Current | Next |
|----------|---------|------|
| $prev_link | **$title** | $next_link |

**Horizon Path**: $horizon → $section → $title

EOF
    
    # Adicionar o resto do documento (exceto primeira linha)
    tail -n +2 "$file" >> "$temp_file"
    
    # Adicionar navegação no final
    cat >> "$temp_file" << EOF

---

## 🔗 Related Documentation

### This Horizon ($horizon)

EOF
    
    # Adicionar links específicos do horizonte
    case "$horizon" in
        "H1 Foundation")
            cat >> "$temp_file" << EOF
- [📖 Platform Introduction](001-platform-intro.md)
- [🏗️ Infrastructure Setup](002-infrastructure-setup.md)
- [🔒 Security Foundation](003-security-foundation.md)
- [🐙 GitHub Setup](004-github-setup.md)
- [📚 Developer Hub Deployment](005-developer-hub-deployment.md)
- [🔄 Basic CI/CD](006-basic-cicd.md)
- [🎬 Demo Environment](007-demo-environment.md)
EOF
            ;;
        "H2 Optimization")
            cat >> "$temp_file" << EOF
- [🚀 Advanced Deployment](001-advanced-deployment.md)
- [📊 Comprehensive Monitoring](002-comprehensive-monitoring.md)
- [🛡️ Enhanced Security](003-enhanced-security.md)
- [⚡ Performance Optimization](004-performance-optimization.md)
- [🛣️ Golden Paths](005-golden-paths.md)
- [🏛️ Advanced Developer Hub](006-advanced-devhub.md)
- [🎭 Enhanced Demo](007-enhanced-demo.md)
EOF
            ;;
        "H3 Innovation")
            cat >> "$temp_file" << EOF
- [🧠 AI-Driven Development](001-ai-driven-development.md)
- [🧪 Azure AI Foundry](002-azure-ai-foundry.md)
- [🤖 Autonomous Operations](003-autonomous-operations.md)
- [🔌 MCP Implementation](004-mcp-implementation.md)
- [📈 Advanced Analytics](005-advanced-analytics.md)
- [🎯 Unified Experience](006-unified-experience.md)
- [🎪 Innovation Showcase](007-innovation-showcase.md)
EOF
            ;;
    esac
    
    cat >> "$temp_file" << EOF

### Other Horizons

- [🏗️ Foundation](../h1-horizon-foundation/README.md) - Core platform setup
- [⚡ Optimization](../h2-horizon-optimization/README.md) - Enhanced capabilities
- [🤖 Innovation](../h3-horizon-innovation/README.md) - AI-driven features
- [🏠 Documentation Home](../README.md) - Complete navigation

### Additional Resources

- [👨‍💻 Developer Guide](../guides/developer-guide.md)
- [💻 Inner Loop Development](../guides/inner-loop-development.md)
- [🚀 Outer Loop Deployment](../guides/outer-loop-deployment.md)
- [🔧 Troubleshooting & FAQ](../reference/troubleshooting-faq.md)

---

<div align="center">

**📍 Current Location**: $horizon → $section → **$title**

$prev_link | [🏠 Home](../README.md) | $next_link

*Part of the Three Horizons AI Platform Documentation*

</div>
EOF
    
    # Substituir arquivo original
    mv "$temp_file" "$file"
}

# Horizon 1 - Foundation
echo -e "\n${YELLOW}📋 Adicionando navegação - Horizon 1 Foundation${NC}"

add_navigation "$DOCS_DIR/h1-horizon-foundation/001-platform-intro.md" \
    "Platform Introduction" \
    "[🏠 Documentation Home](../README.md)" \
    "Documentation Home" \
    "[🏗️ Infrastructure Setup](002-infrastructure-setup.md)" \
    "Infrastructure Setup" \
    "H1 Foundation" \
    "Platform Introduction"

add_navigation "$DOCS_DIR/h1-horizon-foundation/002-infrastructure-setup.md" \
    "Infrastructure Setup" \
    "[📖 Platform Introduction](001-platform-intro.md)" \
    "Platform Introduction" \
    "[🔒 Security Foundation](003-security-foundation.md)" \
    "Security Foundation" \
    "H1 Foundation" \
    "Infrastructure Setup"

add_navigation "$DOCS_DIR/h1-horizon-foundation/003-security-foundation.md" \
    "Security Foundation" \
    "[🏗️ Infrastructure Setup](002-infrastructure-setup.md)" \
    "Infrastructure Setup" \
    "[🐙 GitHub Setup](004-github-setup.md)" \
    "GitHub Setup" \
    "H1 Foundation" \
    "Security Foundation"

add_navigation "$DOCS_DIR/h1-horizon-foundation/004-github-setup.md" \
    "GitHub Setup" \
    "[🔒 Security Foundation](003-security-foundation.md)" \
    "Security Foundation" \
    "[📚 Developer Hub Deployment](005-developer-hub-deployment.md)" \
    "Developer Hub Deployment" \
    "H1 Foundation" \
    "GitHub Setup"

add_navigation "$DOCS_DIR/h1-horizon-foundation/005-developer-hub-deployment.md" \
    "Developer Hub Deployment" \
    "[🐙 GitHub Setup](004-github-setup.md)" \
    "GitHub Setup" \
    "[🔄 Basic CI/CD](006-basic-cicd.md)" \
    "Basic CI/CD" \
    "H1 Foundation" \
    "Developer Hub Deployment"

add_navigation "$DOCS_DIR/h1-horizon-foundation/006-basic-cicd.md" \
    "Basic CI/CD" \
    "[📚 Developer Hub Deployment](005-developer-hub-deployment.md)" \
    "Developer Hub Deployment" \
    "[🎬 Demo Environment](007-demo-environment.md)" \
    "Demo Environment" \
    "H1 Foundation" \
    "Basic CI/CD"

add_navigation "$DOCS_DIR/h1-horizon-foundation/007-demo-environment.md" \
    "Demo Environment" \
    "[🔄 Basic CI/CD](006-basic-cicd.md)" \
    "Basic CI/CD" \
    "[🚀 Advanced Deployment](../h2-horizon-optimization/001-advanced-deployment.md)" \
    "Advanced Deployment (H2)" \
    "H1 Foundation" \
    "Demo Environment"

echo -e "\n${GREEN}✅ Navegação adicionada aos documentos Horizon 1!${NC}"
echo -e "\n${BLUE}📋 Próximos passos:${NC}"
echo "1. Adicionar navegação aos documentos Horizon 2 e 3"
echo "2. Validar todos os links de navegação"
echo "3. Testar a experiência de navegação completa"
