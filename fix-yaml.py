#!/usr/bin/env python3

import os
import re
import yaml

def fix_template_yaml(filepath):
    """Corrige um arquivo template.yaml com problemas de sintaxe"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fazer backup
        with open(f"{filepath}.bak", 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Corrigir problemas comuns
        lines = content.split('\n')
        fixed_lines = []
        
        for line in lines:
            # Corrigir title: fields que contêm ':'
            if re.match(r'^\s*title:\s*[^"]*:.*', line):
                # Extrair indentação e valor
                match = re.match(r'^(\s*title:\s*)(.*)$', line)
                if match:
                    indent, value = match.groups()
                    # Adicionar aspas se não existirem
                    if not (value.startswith('"') and value.endswith('"')):
                        line = f'{indent}"{value}"'
            
            # Corrigir description: fields que contêm ':'
            if re.match(r'^\s*description:\s*[^"]*:.*', line):
                match = re.match(r'^(\s*description:\s*)(.*)$', line)
                if match:
                    indent, value = match.groups()
                    if not (value.startswith('"') and value.endswith('"')):
                        line = f'{indent}"{value}"'
            
            # Corrigir URLs sem aspas
            if 'url:https://' in line and not re.search(r'url:\s*"', line):
                line = re.sub(r'url:(https://[^\s]+)', r'url:"\1"', line)
            
            fixed_lines.append(line)
        
        fixed_content = '\n'.join(fixed_lines)
        
        # Tentar fazer parse para verificar se está válido
        try:
            yaml.safe_load(fixed_content)
            # Se chegou até aqui, o YAML é válido
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"✅ Corrigido: {filepath}")
            os.remove(f"{filepath}.bak")
            return True
        except yaml.YAMLError as e:
            print(f"❌ Ainda inválido depois da correção: {filepath} - {e}")
            # Restaurar backup
            with open(f"{filepath}.bak", 'r', encoding='utf-8') as f:
                original = f.read()
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(original)
            os.remove(f"{filepath}.bak")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao processar {filepath}: {e}")
        return False

def main():
    """Corrigir todos os templates"""
    templates_dir = "templates"
    fixed_count = 0
    total_count = 0
    
    print("=== CORRIGINDO TEMPLATES YAML ===")
    
    # Encontrar todos os template.yaml
    for root, dirs, files in os.walk(templates_dir):
        for file in files:
            if file == "template.yaml":
                filepath = os.path.join(root, file)
                total_count += 1
                
                # Verificar se precisa de correção
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        yaml.safe_load(f.read())
                    print(f"✅ Já válido: {filepath}")
                    fixed_count += 1
                except yaml.YAMLError:
                    # Precisa de correção
                    if fix_template_yaml(filepath):
                        fixed_count += 1
    
    print(f"\n=== RESULTADO ===")
    print(f"Templates processados: {total_count}")
    print(f"Templates válidos: {fixed_count}")
    print(f"Templates com problema: {total_count - fixed_count}")

if __name__ == "__main__":
    main()
