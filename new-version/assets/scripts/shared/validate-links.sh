#!/bin/bash

# Script para validar todos os links da documentação
# Verifica se todos os arquivos referenciados existem

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔗 Validando todos os links da documentação${NC}"
echo "=============================================="

# Diretório base
BASE_DIR="/Users/paulasilva/Documents/paulasilvatech/GH Repos/Three-Horizons-AI-Developer-Platform/new-version"
DOCS_DIR="$BASE_DIR/docs"

# Contadores
total_links=0
valid_links=0
invalid_links=0
missing_files=()

# Função para verificar se um arquivo existe
check_file_exists() {
    local file_path="$1"
    local source_file="$2"
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✓${NC} $file_path"
        ((valid_links++))
        return 0
    else
        echo -e "${RED}✗${NC} $file_path (referenciado em: $source_file)"
        missing_files+=("$file_path <- $source_file")
        ((invalid_links++))
        return 1
    fi
}

# Função para validar links de um arquivo
validate_file_links() {
    local file="$1"
    local file_dir=$(dirname "$file")
    
    echo -e "\n${YELLOW}📄 Verificando: $(basename "$file")${NC}"
    
    # Buscar links para arquivos .md
    while IFS= read -r line; do
        if [[ $line =~ \[.*\]\(([^)]+\.md)\) ]]; then
            ((total_links++))
            link="${BASH_REMATCH[1]}"
            
            # Resolver caminho relativo
            if [[ $link == ../* ]]; then
                # Link relativo para diretório pai
                resolved_path="$file_dir/$link"
            elif [[ $link == ./* ]]; then
                # Link relativo para diretório atual
                resolved_path="$file_dir/${link#./}"
            elif [[ $link != /* ]]; then
                # Link relativo simples
                resolved_path="$file_dir/$link"
            else
                # Link absoluto
                resolved_path="$link"
            fi
            
            # Normalizar caminho
            resolved_path=$(realpath -m "$resolved_path" 2>/dev/null || echo "$resolved_path")
            
            check_file_exists "$resolved_path" "$(basename "$file")"
        fi
    done < "$file"
    
    # Buscar links para imagens e diagramas
    while IFS= read -r line; do
        if [[ $line =~ !\[.*\]\(([^)]+\.(svg|png|jpg|jpeg|mermaid))\) ]]; then
            ((total_links++))
            link="${BASH_REMATCH[1]}"
            
            # Resolver caminho relativo
            if [[ $link == ../* ]]; then
                resolved_path="$file_dir/$link"
            elif [[ $link == ./* ]]; then
                resolved_path="$file_dir/${link#./}"
            elif [[ $link != /* ]]; then
                resolved_path="$file_dir/$link"
            else
                resolved_path="$link"
            fi
            
            # Normalizar caminho
            resolved_path=$(realpath -m "$resolved_path" 2>/dev/null || echo "$resolved_path")
            
            check_file_exists "$resolved_path" "$(basename "$file")"
        fi
    done < "$file"
}

# Validar todos os arquivos .md na documentação
echo -e "${PURPLE}🔍 Procurando arquivos .md para validar...${NC}"

find "$DOCS_DIR" -name "*.md" -type f | sort | while read -r file; do
    validate_file_links "$file"
done

# Validar README principal
if [ -f "$BASE_DIR/README.md" ]; then
    validate_file_links "$BASE_DIR/README.md"
fi

echo -e "\n${BLUE}📊 Resumo da Validação${NC}"
echo "======================="
echo -e "Total de links verificados: ${BLUE}$total_links${NC}"
echo -e "Links válidos: ${GREEN}$valid_links${NC}"
echo -e "Links inválidos: ${RED}$invalid_links${NC}"

if [ $invalid_links -gt 0 ]; then
    echo -e "\n${RED}❌ Arquivos não encontrados:${NC}"
    printf '%s\n' "${missing_files[@]}"
    echo -e "\n${YELLOW}💡 Dicas para correção:${NC}"
    echo "1. Verifique se os arquivos existem nos caminhos corretos"
    echo "2. Corrija os caminhos relativos nos documentos"
    echo "3. Mova arquivos para as localizações esperadas"
    echo "4. Atualize os links com os caminhos corretos"
    exit 1
else
    echo -e "\n${GREEN}✅ Todos os links estão válidos!${NC}"
    echo -e "${GREEN}🎉 A documentação está consistente e navegável.${NC}"
fi

echo -e "\n${BLUE}🚀 Próximos passos recomendados:${NC}"
echo "1. Testar a navegação manualmente"
echo "2. Verificar renderização dos diagramas Mermaid"
echo "3. Validar a experiência do usuário final"
echo "4. Configurar validação automática no CI/CD"
