#!/bin/bash

# Script para reorganizar documentos do Three Horizons AI Platform
# Move documentos para nova estrutura e atualiza links

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Reorganizando documentos Three Horizons AI Platform${NC}"
echo "=================================================="

# Diretórios base
OLD_DIR="/Users/paulasilva/Documents/paulasilvatech/GH Repos/Three-Horizons-AI-Developer-Platform/new-version"
NEW_DOCS_DIR="$OLD_DIR/docs"

# Função para mover documentos
move_document() {
    local source="$1"
    local destination="$2"
    local new_name="$3"
    
    if [ -f "$source" ]; then
        echo -e "${GREEN}✓${NC} Movendo: $(basename "$source") → $new_name"
        cp "$source" "$destination/$new_name"
    else
        echo -e "${RED}✗${NC} Arquivo não encontrado: $source"
    fi
}

# Mover documentos H1 (Foundation)
echo -e "\n${YELLOW}📁 Movendo documentos Horizon 1 (Foundation)${NC}"
move_document "$OLD_DIR/h1-001-platform-intro.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "001-platform-intro.md"
move_document "$OLD_DIR/h1-002-infrastructure-setup.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "002-infrastructure-setup.md"
move_document "$OLD_DIR/h1-003-security-foundation.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "003-security-foundation.md"
move_document "$OLD_DIR/h1-004-github-setup.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "004-github-setup.md"
move_document "$OLD_DIR/h1-005-developer-hub-deployment.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "005-developer-hub-deployment.md"
move_document "$OLD_DIR/h1-006-basic-cicd.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "006-basic-cicd.md"
move_document "$OLD_DIR/h1-007-demo-environment.md" "$NEW_DOCS_DIR/h1-horizon-foundation" "007-demo-environment.md"

# Mover documentos H2 (Optimization)
echo -e "\n${YELLOW}📁 Movendo documentos Horizon 2 (Optimization)${NC}"
move_document "$OLD_DIR/h2-001-advanced-deployment.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "001-advanced-deployment.md"
move_document "$OLD_DIR/h2-002-comprehensive-monitoring.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "002-comprehensive-monitoring.md"
move_document "$OLD_DIR/h2-003-enhanced-security.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "003-enhanced-security.md"
move_document "$OLD_DIR/h2-004-performance-optimization.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "004-performance-optimization.md"
move_document "$OLD_DIR/h2-005-golden-paths.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "005-golden-paths.md"
move_document "$OLD_DIR/h2-006-advanced-devhub.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "006-advanced-devhub.md"
move_document "$OLD_DIR/h2-007-enhanced-demo.md" "$NEW_DOCS_DIR/h2-horizon-optimization" "007-enhanced-demo.md"

# Mover documentos H3 (Innovation)
echo -e "\n${YELLOW}📁 Movendo documentos Horizon 3 (Innovation)${NC}"
move_document "$OLD_DIR/h3-001-ai-driven-development.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "001-ai-driven-development.md"
move_document "$OLD_DIR/h3-002-azure-ai-foundry.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "002-azure-ai-foundry.md"
move_document "$OLD_DIR/h3-003-autonomous-operations.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "003-autonomous-operations.md"
move_document "$OLD_DIR/h3-004-mcp-implementation.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "004-mcp-implementation.md"
move_document "$OLD_DIR/h3-005-advanced-analytics.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "005-advanced-analytics.md"
move_document "$OLD_DIR/h3-006-unified-experience.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "006-unified-experience.md"
move_document "$OLD_DIR/h3-007-innovation-showcase.md" "$NEW_DOCS_DIR/h3-horizon-innovation" "007-innovation-showcase.md"

# Mover guias
echo -e "\n${YELLOW}📁 Movendo guias para pasta guides${NC}"
move_document "$OLD_DIR/developer-guide.md" "$NEW_DOCS_DIR/guides" "developer-guide.md"
move_document "$OLD_DIR/inner-loop-development-guide.md" "$NEW_DOCS_DIR/guides" "inner-loop-development.md"
move_document "$OLD_DIR/outer-loop-deployment-guide.md" "$NEW_DOCS_DIR/guides" "outer-loop-deployment.md"
move_document "$OLD_DIR/devhub-aro-guide.md" "$NEW_DOCS_DIR/guides" "devhub-aro-guide.md"

# Mover documentos de referência
echo -e "\n${YELLOW}📁 Movendo documentos de referência${NC}"
move_document "$OLD_DIR/troubleshooting-faq.md" "$NEW_DOCS_DIR/reference" "troubleshooting-faq.md"
move_document "$OLD_DIR/complete-integration-tutorial.md" "$NEW_DOCS_DIR/reference" "complete-integration-tutorial.md"

echo -e "\n${GREEN}✅ Reorganização completa!${NC}"
echo -e "\n${BLUE}📋 Resumo da nova estrutura:${NC}"
echo "docs/"
echo "├── h1-horizon-foundation/     (7 documentos)"
echo "├── h2-horizon-optimization/   (7 documentos)"
echo "├── h3-horizon-innovation/     (7 documentos)"
echo "├── guides/                    (4 guias)"
echo "└── reference/                 (2 documentos de referência)"
echo ""
echo "assets/"
echo "├── diagrams/                  (todos os diagramas)"
echo "└── images/                    (para futuras imagens)"
echo ""
echo "templates/"
echo "└── document-template.md       (template padrão)"

echo -e "\n${YELLOW}⚠️  Próximos passos:${NC}"
echo "1. Atualizar links internos nos documentos"
echo "2. Adicionar navegação 'Previous/Next' em todos os documentos"
echo "3. Validar todas as referências a diagramas"
echo "4. Criar README.md para cada horizonte"
echo "5. Atualizar README.md principal"
