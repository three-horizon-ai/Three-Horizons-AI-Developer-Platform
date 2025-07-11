#!/usr/bin/env python3

import os
import re

def fix_yaml_format_error(filepath):
    """Corrige o erro específico de formatação YAML"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fazer backup
        with open(f"{filepath}.bak", 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Corrigir o problema específico: '""          title:' -> 'title:'
        fixed_content = re.sub(
            r'(\s+)description:\s*\n\s*""\s*title:',
            r'\1description:\n\1  title:',
            content
        )
        
        # Verificar se houve mudança
        if fixed_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"✅ Corrigido: {filepath}")
            os.remove(f"{filepath}.bak")
            return True
        else:
            print(f"ℹ️  Sem mudanças: {filepath}")
            os.remove(f"{filepath}.bak")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao processar {filepath}: {e}")
        return False

def main():
    """Corrigir todos os templates com o erro específico"""
    templates = [
        "templates/h1-foundation/microservices-starter/template.yaml",
        "templates/h1-foundation/basic-cicd/template.yaml", 
        "templates/h2-optimization/gitops-advanced/template.yaml",
        "templates/h2-optimization/monitoring-stack/template.yaml",
        "templates/h2-optimization/security-pipeline/template.yaml",
        "templates/h2-optimization/performance-testing/template.yaml",
        "templates/h3-innovation/ai-powered-app/template.yaml",
        "templates/h3-innovation/copilot-agent/template.yaml",
        "templates/h3-innovation/autonomous-devops/template.yaml",
        "templates/h3-innovation/mcp-integration/template.yaml"
    ]
    
    print("=== CORRIGINDO ERRO DE FORMATAÇÃO YAML ===")
    
    fixed_count = 0
    for template in templates:
        if os.path.exists(template):
            if fix_yaml_format_error(template):
                fixed_count += 1
        else:
            print(f"⚠️  Arquivo não encontrado: {template}")
    
    print(f"\n=== RESULTADO ===")
    print(f"Templates corrigidos: {fixed_count}")

if __name__ == "__main__":
    main()
