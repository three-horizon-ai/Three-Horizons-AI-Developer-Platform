#!/bin/bash

# Script para atualizar links internos nos documentos reorganizados
# Atualiza referências para a nova estrutura de diretórios

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔗 Atualizando links internos nos documentos${NC}"
echo "=============================================="

# Diretório base
DOCS_DIR="/Users/paulasilva/Documents/paulasilvatech/GH Repos/Three-Horizons-AI-Developer-Platform/new-version/docs"

# Função para atualizar links em um arquivo
update_links() {
    local file="$1"
    local backup_file="${file}.backup"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC} Arquivo não encontrado: $file"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Atualizando: $(basename "$file")"
    
    # Criar backup
    cp "$file" "$backup_file"
    
    # Atualizar links para diagramas
    sed -i '' 's|diagrams/|../../assets/diagrams/|g' "$file"
    sed -i '' 's|../diagrams/|../../assets/diagrams/|g' "$file"
    
    # Atualizar links para documentos H1
    sed -i '' 's|h1-001-platform-intro\.md|h1-horizon-foundation/001-platform-intro.md|g' "$file"
    sed -i '' 's|h1-002-infrastructure-setup\.md|h1-horizon-foundation/002-infrastructure-setup.md|g' "$file"
    sed -i '' 's|h1-003-security-foundation\.md|h1-horizon-foundation/003-security-foundation.md|g' "$file"
    sed -i '' 's|h1-004-github-setup\.md|h1-horizon-foundation/004-github-setup.md|g' "$file"
    sed -i '' 's|h1-005-developer-hub-deployment\.md|h1-horizon-foundation/005-developer-hub-deployment.md|g' "$file"
    sed -i '' 's|h1-006-basic-cicd\.md|h1-horizon-foundation/006-basic-cicd.md|g' "$file"
    sed -i '' 's|h1-007-demo-environment\.md|h1-horizon-foundation/007-demo-environment.md|g' "$file"
    
    # Atualizar links para documentos H2
    sed -i '' 's|h2-001-advanced-deployment\.md|h2-horizon-optimization/001-advanced-deployment.md|g' "$file"
    sed -i '' 's|h2-002-comprehensive-monitoring\.md|h2-horizon-optimization/002-comprehensive-monitoring.md|g' "$file"
    sed -i '' 's|h2-003-enhanced-security\.md|h2-horizon-optimization/003-enhanced-security.md|g' "$file"
    sed -i '' 's|h2-004-performance-optimization\.md|h2-horizon-optimization/004-performance-optimization.md|g' "$file"
    sed -i '' 's|h2-005-golden-paths\.md|h2-horizon-optimization/005-golden-paths.md|g' "$file"
    sed -i '' 's|h2-006-advanced-devhub\.md|h2-horizon-optimization/006-advanced-devhub.md|g' "$file"
    sed -i '' 's|h2-007-enhanced-demo\.md|h2-horizon-optimization/007-enhanced-demo.md|g' "$file"
    
    # Atualizar links para documentos H3
    sed -i '' 's|h3-001-ai-driven-development\.md|h3-horizon-innovation/001-ai-driven-development.md|g' "$file"
    sed -i '' 's|h3-002-azure-ai-foundry\.md|h3-horizon-innovation/002-azure-ai-foundry.md|g' "$file"
    sed -i '' 's|h3-003-autonomous-operations\.md|h3-horizon-innovation/003-autonomous-operations.md|g' "$file"
    sed -i '' 's|h3-004-mcp-implementation\.md|h3-horizon-innovation/004-mcp-implementation.md|g' "$file"
    sed -i '' 's|h3-005-advanced-analytics\.md|h3-horizon-innovation/005-advanced-analytics.md|g' "$file"
    sed -i '' 's|h3-006-unified-experience\.md|h3-horizon-innovation/006-unified-experience.md|g' "$file"
    sed -i '' 's|h3-007-innovation-showcase\.md|h3-horizon-innovation/007-innovation-showcase.md|g' "$file"
    
    # Atualizar links para guias
    sed -i '' 's|developer-guide\.md|guides/developer-guide.md|g' "$file"
    sed -i '' 's|inner-loop-development-guide\.md|guides/inner-loop-development.md|g' "$file"
    sed -i '' 's|outer-loop-deployment-guide\.md|guides/outer-loop-deployment.md|g' "$file"
    sed -i '' 's|devhub-aro-guide\.md|guides/devhub-aro-guide.md|g' "$file"
    
    # Atualizar links para referência
    sed -i '' 's|troubleshooting-faq\.md|reference/troubleshooting-faq.md|g' "$file"
    sed -i '' 's|complete-integration-tutorial\.md|reference/complete-integration-tutorial.md|g' "$file"
    
    # Remover backup se a atualização foi bem-sucedida
    if [ $? -eq 0 ]; then
        rm "$backup_file"
    else
        echo -e "${RED}✗${NC} Erro ao atualizar $file, restaurando backup"
        mv "$backup_file" "$file"
    fi
}

# Atualizar README principal
echo -e "\n${YELLOW}📋 Atualizando README principal${NC}"
update_links "$DOCS_DIR/README.md"

# Atualizar documentos H1
echo -e "\n${YELLOW}📋 Atualizando documentos Horizon 1${NC}"
for file in "$DOCS_DIR/h1-horizon-foundation"/*.md; do
    if [ -f "$file" ]; then
        update_links "$file"
    fi
done

# Atualizar documentos H2
echo -e "\n${YELLOW}📋 Atualizando documentos Horizon 2${NC}"
for file in "$DOCS_DIR/h2-horizon-optimization"/*.md; do
    if [ -f "$file" ]; then
        update_links "$file"
    fi
done

# Atualizar documentos H3
echo -e "\n${YELLOW}📋 Atualizando documentos Horizon 3${NC}"
for file in "$DOCS_DIR/h3-horizon-innovation"/*.md; do
    if [ -f "$file" ]; then
        update_links "$file"
    fi
done

# Atualizar guias
echo -e "\n${YELLOW}📋 Atualizando guias${NC}"
for file in "$DOCS_DIR/guides"/*.md; do
    if [ -f "$file" ]; then
        update_links "$file"
    fi
done

# Atualizar documentos de referência
echo -e "\n${YELLOW}📋 Atualizando documentos de referência${NC}"
for file in "$DOCS_DIR/reference"/*.md; do
    if [ -f "$file" ]; then
        update_links "$file"
    fi
done

echo -e "\n${GREEN}✅ Atualização de links completa!${NC}"
echo -e "\n${BLUE}📋 Resumo das atualizações:${NC}"
echo "• Links para diagramas atualizados para ../../assets/diagrams/"
echo "• Links internos atualizados para nova estrutura de diretórios"
echo "• Referências entre documentos corrigidas"
echo "• Links para guias e referência atualizados"

echo -e "\n${YELLOW}⚠️  Próximos passos:${NC}"
echo "1. Adicionar navegação Previous/Next em todos os documentos"
echo "2. Validar todos os links manualmente"
echo "3. Testar acesso aos diagramas"
echo "4. Atualizar README.md principal com nova estrutura"
