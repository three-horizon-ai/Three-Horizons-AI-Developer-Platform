#!/bin/bash

echo "Realizing commit and push of changes to the repository..."

# Add all changes
git add .
echo "✓ Changes added to stage"

# Create a commit with a descriptive message
git commit -m "refactor: reorganize repository structure

- Move CONTRIBUTING.md and SECURITY.md to .github/
- Move EXECUTIVE-OVERVIEW.md to docs/meta/
- Move configuration files to docs/config/
- Move reports to docs/reports/
- Update .gitignore to include temporary files
- Update references in README.md, index.md and DOCUMENTATION_MAP.md
- Remove redundant directories
- Keep only essential files in the root directory"

echo "✓ Commit done"

# Check if there is a remote configured before trying to push
remote_exists=$(git remote | wc -l)
if [ "$remote_exists" -gt 0 ]; then
  # Push to the remote repository
  git push
  echo "✓ Push done successfully"
else
  echo "⚠️ No remote repository configured. Push not done."
  echo "To configure a remote repository, use:"
  echo "  git remote add origin URL_DO_REPOSITORIO"
  echo "  git push -u origin BRANCH_ATUAL"
fi

echo "Process done!" 