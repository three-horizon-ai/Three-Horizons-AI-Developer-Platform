#!/bin/bash

echo "Realizando commit e push das alterações da reorganização do repositório..."

# Adicionar todas as alterações
git add .
echo "✓ Alterações adicionadas ao stage"

# Criar o commit com uma mensagem descritiva
git commit -m "refactor: reorganiza estrutura do repositório

- Move CONTRIBUTING.md e SECURITY.md para .github/
- Move EXECUTIVE-OVERVIEW.md para docs/meta/
- Move arquivos de configuração para docs/config/
- Move relatórios para docs/reports/
- Atualiza .gitignore para incluir arquivos temporários
- Atualiza referências nos arquivos README.md, index.md e DOCUMENTATION_MAP.md
- Remove diretórios redundantes
- Mantém apenas arquivos essenciais no diretório raiz"

echo "✓ Commit realizado"

# Verificar se há um remote configurado antes de tentar fazer push
remote_exists=$(git remote | wc -l)
if [ "$remote_exists" -gt 0 ]; then
  # Fazer push para o repositório remoto
  git push
  echo "✓ Push realizado com sucesso"
else
  echo "⚠️ Nenhum repositório remoto configurado. O push não foi realizado."
  echo "Para configurar um repositório remoto, use:"
  echo "  git remote add origin URL_DO_REPOSITORIO"
  echo "  git push -u origin BRANCH_ATUAL"
fi

echo "Processo concluído!" 