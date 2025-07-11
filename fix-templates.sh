#!/bin/bash

# Script para corrigir todos os templates YAML

echo "=== CORRIGINDO TODOS OS TEMPLATES YAML ==="

# Lista de todos os templates
templates=(
    "h1-foundation/microservices-starter"
    "h1-foundation/basic-web-app"
    "h1-foundation/azure-infrastructure"
    "h1-foundation/basic-cicd"
    "h2-optimization/gitops-advanced"
    "h2-optimization/monitoring-stack"
    "h2-optimization/security-pipeline"
    "h2-optimization/performance-testing"
    "h2-optimization/microservices-app"
    "h3-innovation/ai-powered-app"
    "h3-innovation/copilot-agent"
    "h3-innovation/autonomous-devops"
    "h3-innovation/mcp-integration"
)

# Função para corrigir um template
fix_template() {
    local template_path="$1"
    local template_file="templates/$template_path/template.yaml"
    
    if [ -f "$template_file" ]; then
        echo "Corrigindo: $template_file"
        
        # Fazer backup
        cp "$template_file" "$template_file.bak"
        
        # Corrigir aspas nos campos title e description
        sed -i '' \
            -e 's/title: \(.*\)$/title: "\1"/' \
            -e 's/description: \(.*\)$/description: "\1"/' \
            -e 's/url:\(.*\)$/url:"\1"/' \
            "$template_file"
        
        # Verificar se é válido
        if python3 -c "import yaml; yaml.safe_load(open('$template_file'))" 2>/dev/null; then
            echo "✅ $template_file corrigido com sucesso"
            rm "$template_file.bak"
        else
            echo "❌ Erro em $template_file, restaurando backup"
            mv "$template_file.bak" "$template_file"
        fi
    else
        echo "⚠️  Arquivo não encontrado: $template_file"
    fi
}

# Corrigir todos os templates
for template in "${templates[@]}"; do
    fix_template "$template"
done

echo ""
echo "=== VERIFICAÇÃO FINAL ==="

# Verificar todos os templates
for template in "${templates[@]}"; do
    template_file="templates/$template/template.yaml"
    if [ -f "$template_file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$template_file'))" 2>/dev/null; then
            echo "✅ $template_file - VÁLIDO"
        else
            echo "❌ $template_file - INVÁLIDO"
        fi
    fi
done
