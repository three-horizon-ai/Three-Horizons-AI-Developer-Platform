#!/bin/bash

# Script completo para adicionar navegação Previous/Next a TODOS os documentos
# Cobre H1, H2, H3, guides e reference

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧭 Adicionando navegação completa a todos os documentos${NC}"
echo "========================================================="

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
    
    # Backup do arquivo original
    cp "$file" "${file}.backup"
    
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

**Path**: $horizon → $section → $title

EOF
    
    # Adicionar o resto do documento (exceto primeira linha)
    tail -n +2 "$file" >> "$temp_file"
    
    # Adicionar navegação no final
    cat >> "$temp_file" << EOF

---

## 🔗 Quick Navigation

<div align="center">

### Three Horizons Navigation

| [🏗️ Foundation (H1)](../h1-horizon-foundation/README.md) | [⚡ Optimization (H2)](../h2-horizon-optimization/README.md) | [🤖 Innovation (H3)](../h3-horizon-innovation/README.md) |
|:---:|:---:|:---:|
| Core Platform Setup | Enhanced Capabilities | AI-Driven Features |

</div>

### Related Documentation

EOF
    
    # Adicionar links específicos do horizonte
    case "$horizon" in
        "H1 Foundation"|"Foundation")
            cat >> "$temp_file" << EOF
**Foundation Horizon (H1)**:
- [📖 Platform Introduction](001-platform-intro.md)
- [🏗️ Infrastructure Setup](002-infrastructure-setup.md)
- [🔒 Security Foundation](003-security-foundation.md)
- [🐙 GitHub Setup](004-github-setup.md)
- [📚 Developer Hub Deployment](005-developer-hub-deployment.md)
- [🔄 Basic CI/CD](006-basic-cicd.md)
- [🎬 Demo Environment](007-demo-environment.md)
EOF
            ;;
        "H2 Optimization"|"Optimization")
            cat >> "$temp_file" << EOF
**Optimization Horizon (H2)**:
- [🚀 Advanced Deployment](001-advanced-deployment.md)
- [📊 Comprehensive Monitoring](002-comprehensive-monitoring.md)
- [🛡️ Enhanced Security](003-enhanced-security.md)
- [⚡ Performance Optimization](004-performance-optimization.md)
- [🛣️ Golden Paths](005-golden-paths.md)
- [🏛️ Advanced Developer Hub](006-advanced-devhub.md)
- [🎭 Enhanced Demo](007-enhanced-demo.md)
EOF
            ;;
        "H3 Innovation"|"Innovation")
            cat >> "$temp_file" << EOF
**Innovation Horizon (H3)**:
- [🧠 AI-Driven Development](001-ai-driven-development.md)
- [🧪 Azure AI Foundry](002-azure-ai-foundry.md)
- [🤖 Autonomous Operations](003-autonomous-operations.md)
- [🔌 MCP Implementation](004-mcp-implementation.md)
- [📈 Advanced Analytics](005-advanced-analytics.md)
- [🎯 Unified Experience](006-unified-experience.md)
- [🎪 Innovation Showcase](007-innovation-showcase.md)
EOF
            ;;
        "Guides")
            cat >> "$temp_file" << EOF
**Developer Guides**:
- [👨‍💻 Developer Guide](developer-guide.md)
- [💻 Inner Loop Development](inner-loop-development.md)
- [🚀 Outer Loop Deployment](outer-loop-deployment.md)
- [📖 Complete Integration Tutorial](complete-integration-tutorial.md)
EOF
            ;;
        "Reference")
            cat >> "$temp_file" << EOF
**Reference Documentation**:
- [🔧 Troubleshooting & FAQ](troubleshooting-faq.md)
- [📚 Additional Resources](README.md)
EOF
            ;;
    esac
    
    cat >> "$temp_file" << EOF

### Essential Resources

- [🏠 Documentation Home](../README.md) - Complete navigation
- [👨‍💻 Developer Guide](../guides/developer-guide.md) - Development workflows
- [🔧 Troubleshooting](../reference/troubleshooting-faq.md) - Common issues & solutions

---

<div align="center">

**📍 You are here**: $horizon → $section → **$title**

$prev_link | [🏠 Home](../README.md) | $next_link

*Part of the Three Horizons AI Developer Platform*

</div>
EOF
    
    # Substituir arquivo original
    mv "$temp_file" "$file"
}

# =============================================================================
# HORIZON 1 - FOUNDATION
# =============================================================================

echo -e "\n${YELLOW}📋 Horizon 1 - Foundation${NC}"

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

# =============================================================================
# HORIZON 2 - OPTIMIZATION
# =============================================================================

echo -e "\n${YELLOW}📋 Horizon 2 - Optimization${NC}"

add_navigation "$DOCS_DIR/h2-horizon-optimization/001-advanced-deployment.md" \
    "Advanced Deployment" \
    "[🎬 Demo Environment](../h1-horizon-foundation/007-demo-environment.md)" \
    "Demo Environment (H1)" \
    "[📊 Comprehensive Monitoring](002-comprehensive-monitoring.md)" \
    "Comprehensive Monitoring" \
    "H2 Optimization" \
    "Advanced Deployment"

add_navigation "$DOCS_DIR/h2-horizon-optimization/002-comprehensive-monitoring.md" \
    "Comprehensive Monitoring" \
    "[🚀 Advanced Deployment](001-advanced-deployment.md)" \
    "Advanced Deployment" \
    "[🛡️ Enhanced Security](003-enhanced-security.md)" \
    "Enhanced Security" \
    "H2 Optimization" \
    "Comprehensive Monitoring"

add_navigation "$DOCS_DIR/h2-horizon-optimization/003-enhanced-security.md" \
    "Enhanced Security" \
    "[📊 Comprehensive Monitoring](002-comprehensive-monitoring.md)" \
    "Comprehensive Monitoring" \
    "[⚡ Performance Optimization](004-performance-optimization.md)" \
    "Performance Optimization" \
    "H2 Optimization" \
    "Enhanced Security"

add_navigation "$DOCS_DIR/h2-horizon-optimization/004-performance-optimization.md" \
    "Performance Optimization" \
    "[🛡️ Enhanced Security](003-enhanced-security.md)" \
    "Enhanced Security" \
    "[🛣️ Golden Paths](005-golden-paths.md)" \
    "Golden Paths" \
    "H2 Optimization" \
    "Performance Optimization"

add_navigation "$DOCS_DIR/h2-horizon-optimization/005-golden-paths.md" \
    "Golden Paths" \
    "[⚡ Performance Optimization](004-performance-optimization.md)" \
    "Performance Optimization" \
    "[🏛️ Advanced Developer Hub](006-advanced-devhub.md)" \
    "Advanced Developer Hub" \
    "H2 Optimization" \
    "Golden Paths"

add_navigation "$DOCS_DIR/h2-horizon-optimization/006-advanced-devhub.md" \
    "Advanced Developer Hub" \
    "[🛣️ Golden Paths](005-golden-paths.md)" \
    "Golden Paths" \
    "[🎭 Enhanced Demo](007-enhanced-demo.md)" \
    "Enhanced Demo" \
    "H2 Optimization" \
    "Advanced Developer Hub"

add_navigation "$DOCS_DIR/h2-horizon-optimization/007-enhanced-demo.md" \
    "Enhanced Demo" \
    "[🏛️ Advanced Developer Hub](006-advanced-devhub.md)" \
    "Advanced Developer Hub" \
    "[🧠 AI-Driven Development](../h3-horizon-innovation/001-ai-driven-development.md)" \
    "AI-Driven Development (H3)" \
    "H2 Optimization" \
    "Enhanced Demo"

# =============================================================================
# HORIZON 3 - INNOVATION
# =============================================================================

echo -e "\n${YELLOW}📋 Horizon 3 - Innovation${NC}"

add_navigation "$DOCS_DIR/h3-horizon-innovation/001-ai-driven-development.md" \
    "AI-Driven Development" \
    "[🎭 Enhanced Demo](../h2-horizon-optimization/007-enhanced-demo.md)" \
    "Enhanced Demo (H2)" \
    "[🧪 Azure AI Foundry](002-azure-ai-foundry.md)" \
    "Azure AI Foundry" \
    "H3 Innovation" \
    "AI-Driven Development"

add_navigation "$DOCS_DIR/h3-horizon-innovation/002-azure-ai-foundry.md" \
    "Azure AI Foundry" \
    "[🧠 AI-Driven Development](001-ai-driven-development.md)" \
    "AI-Driven Development" \
    "[🤖 Autonomous Operations](003-autonomous-operations.md)" \
    "Autonomous Operations" \
    "H3 Innovation" \
    "Azure AI Foundry"

add_navigation "$DOCS_DIR/h3-horizon-innovation/003-autonomous-operations.md" \
    "Autonomous Operations" \
    "[🧪 Azure AI Foundry](002-azure-ai-foundry.md)" \
    "Azure AI Foundry" \
    "[🔌 MCP Implementation](004-mcp-implementation.md)" \
    "MCP Implementation" \
    "H3 Innovation" \
    "Autonomous Operations"

add_navigation "$DOCS_DIR/h3-horizon-innovation/004-mcp-implementation.md" \
    "MCP Implementation" \
    "[🤖 Autonomous Operations](003-autonomous-operations.md)" \
    "Autonomous Operations" \
    "[📈 Advanced Analytics](005-advanced-analytics.md)" \
    "Advanced Analytics" \
    "H3 Innovation" \
    "MCP Implementation"

add_navigation "$DOCS_DIR/h3-horizon-innovation/005-advanced-analytics.md" \
    "Advanced Analytics" \
    "[🔌 MCP Implementation](004-mcp-implementation.md)" \
    "MCP Implementation" \
    "[🎯 Unified Experience](006-unified-experience.md)" \
    "Unified Experience" \
    "H3 Innovation" \
    "Advanced Analytics"

add_navigation "$DOCS_DIR/h3-horizon-innovation/006-unified-experience.md" \
    "Unified Experience" \
    "[📈 Advanced Analytics](005-advanced-analytics.md)" \
    "Advanced Analytics" \
    "[🎪 Innovation Showcase](007-innovation-showcase.md)" \
    "Innovation Showcase" \
    "H3 Innovation" \
    "Unified Experience"

add_navigation "$DOCS_DIR/h3-horizon-innovation/007-innovation-showcase.md" \
    "Innovation Showcase" \
    "[🎯 Unified Experience](006-unified-experience.md)" \
    "Unified Experience" \
    "[👨‍💻 Developer Guide](../guides/developer-guide.md)" \
    "Developer Guide" \
    "H3 Innovation" \
    "Innovation Showcase"

# =============================================================================
# GUIDES
# =============================================================================

echo -e "\n${YELLOW}📋 Guides & Tutorials${NC}"

add_navigation "$DOCS_DIR/guides/developer-guide.md" \
    "Developer Guide" \
    "[🎪 Innovation Showcase](../h3-horizon-innovation/007-innovation-showcase.md)" \
    "Innovation Showcase (H3)" \
    "[💻 Inner Loop Development](inner-loop-development.md)" \
    "Inner Loop Development" \
    "Guides" \
    "Developer Guide"

add_navigation "$DOCS_DIR/guides/inner-loop-development.md" \
    "Inner Loop Development" \
    "[👨‍💻 Developer Guide](developer-guide.md)" \
    "Developer Guide" \
    "[🚀 Outer Loop Deployment](outer-loop-deployment.md)" \
    "Outer Loop Deployment" \
    "Guides" \
    "Inner Loop Development"

add_navigation "$DOCS_DIR/guides/outer-loop-deployment.md" \
    "Outer Loop Deployment" \
    "[💻 Inner Loop Development](inner-loop-development.md)" \
    "Inner Loop Development" \
    "[📖 Complete Integration Tutorial](complete-integration-tutorial.md)" \
    "Complete Integration Tutorial" \
    "Guides" \
    "Outer Loop Deployment"

add_navigation "$DOCS_DIR/guides/complete-integration-tutorial.md" \
    "Complete Integration Tutorial" \
    "[🚀 Outer Loop Deployment](outer-loop-deployment.md)" \
    "Outer Loop Deployment" \
    "[🔧 Troubleshooting & FAQ](../reference/troubleshooting-faq.md)" \
    "Troubleshooting & FAQ" \
    "Guides" \
    "Complete Integration Tutorial"

# =============================================================================
# REFERENCE
# =============================================================================

echo -e "\n${YELLOW}📋 Reference Documentation${NC}"

add_navigation "$DOCS_DIR/reference/troubleshooting-faq.md" \
    "Troubleshooting & FAQ" \
    "[📖 Complete Integration Tutorial](../guides/complete-integration-tutorial.md)" \
    "Complete Integration Tutorial" \
    "[🏠 Documentation Home](../README.md)" \
    "Documentation Home" \
    "Reference" \
    "Troubleshooting & FAQ"

echo -e "\n${GREEN}✅ Navegação completa adicionada a todos os documentos!${NC}"
echo -e "\n${PURPLE}📊 Resumo das alterações:${NC}"
echo "- ✅ Horizon 1 Foundation: 7 documentos"
echo "- ✅ Horizon 2 Optimization: 7 documentos"
echo "- ✅ Horizon 3 Innovation: 7 documentos"
echo "- ✅ Guides: 4 documentos"
echo "- ✅ Reference: 1 documento"
echo "- 📊 Total: 26 documentos com navegação completa"

echo -e "\n${BLUE}🎯 Recursos adicionados:${NC}"
echo "- 📍 Breadcrumbs em todos os documentos"
echo "- ⬅️➡️ Navegação Previous/Next"
echo "- 🔗 Links relacionados por categoria"
echo "- 🧭 Navegação visual entre horizontes"
echo "- 🏠 Links para documentação principal"

echo -e "\n${BLUE}🚀 Próximos passos recomendados:${NC}"
echo "1. Validar todos os links de navegação"
echo "2. Testar a experiência de navegação completa"
echo "3. Verificar renderização dos diagramas SVG e Mermaid"
echo "4. Otimizar performance de carregamento das páginas"
