#!/bin/bash

# Script to implement the Playbook Template structure

echo "Implementing Playbook Template structure..."

# 1. Create new directory structure
mkdir -p docs/1-architecture
mkdir -p docs/2-implementation-guide
mkdir -p docs/3-developer-guide
mkdir -p docs/4-operations-guide
mkdir -p docs/5-reference
mkdir -p docs/6-appendices

# 2. Move content to new directories
echo "Moving files to new directory structure..."

# Architecture
cp -R docs/architecture/* docs/1-architecture/ 2>/dev/null
echo "Moved architecture documentation"

# Implementation
cp -R docs/implementation/* docs/2-implementation-guide/ 2>/dev/null
cp -R docs/deployment/* docs/2-implementation-guide/ 2>/dev/null
echo "Moved implementation documentation"

# Developer
cp -R docs/developer-hub/* docs/3-developer-guide/ 2>/dev/null
cp -R docs/golden-paths/* docs/3-developer-guide/ 2>/dev/null
echo "Moved developer documentation"

# Operations
cp -R docs/operations/* docs/4-operations-guide/ 2>/dev/null
echo "Moved operations documentation"

# Reference
cp -R docs/references/* docs/5-reference/ 2>/dev/null
cp docs/LANGUAGE_GUIDELINES.md docs/5-reference/ 2>/dev/null
echo "Moved reference documentation"

# Appendices
cp -R docs/scenarios/* docs/6-appendices/ 2>/dev/null
echo "Moved appendices documentation"

# 3. Create README files for any empty directories
for dir in docs/1-architecture docs/2-implementation-guide docs/3-developer-guide docs/4-operations-guide docs/5-reference docs/6-appendices; do
  if [ ! -f "$dir/README.md" ]; then
    section=$(echo $dir | sed 's/.*\/\([0-9]\)-\(.*\)/\2/')
    title=$(echo $section | tr '-' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    echo "# $title" > "$dir/README.md"
    echo "" >> "$dir/README.md"
    echo "This directory contains documentation related to $section." >> "$dir/README.md"
    echo "" >> "$dir/README.md"
    echo "## Contents" >> "$dir/README.md"
    echo "" >> "$dir/README.md"
    echo "Placeholder for section contents." >> "$dir/README.md"
    echo "Created README for $dir"
  fi
done

# 4. Update Documentation Map
echo "Updating documentation map..."
cat > docs/DOCUMENTATION_MAP.md << 'EOL'
# Three Horizons Documentation Map

This document serves as a central index of all documentation in the Three Horizons Playbook repository, following the standardized playbook template structure.

## Repository Structure

- [**README.md**](../README.md) - Primary project introduction
- [**EXECUTIVE-OVERVIEW.md**](../EXECUTIVE-OVERVIEW.md) - High-level executive summary
- [**CONTRIBUTING.md**](../CONTRIBUTING.md) - Contribution guidelines
- [**LICENSE**](../LICENSE) - Licensing information
- [**SECURITY.md**](../SECURITY.md) - Security policy and reporting

## Documentation Structure

### 1. Architecture
- [**Architecture Documentation**](1-architecture/README.md) - System architecture details

### 2. Implementation Guide
- [**Implementation Guide**](2-implementation-guide/README.md) - Implementation instructions

### 3. Developer Guide
- [**Developer Guide**](3-developer-guide/README.md) - Developer-specific documentation

### 4. Operations Guide
- [**Operations Guide**](4-operations-guide/README.md) - Operational procedures

### 5. Reference
- [**Reference Materials**](5-reference/README.md) - Reference materials
- [**Language Guidelines**](5-reference/LANGUAGE_GUIDELINES.md) - Standardized terminology

### 6. Appendices
- [**Appendices**](6-appendices/README.md) - Supplementary documents

## Other Resources

### Examples
- [**Example Applications**](../examples/README.md) - Code and configuration examples

### Templates
- [**Reusable Templates**](../templates/README.md) - Reusable templates

### Scripts
- [**Utility Scripts**](../scripts/README.md) - Utility and automation scripts

### Images
- [**Documentation Images**](../docs/images/README.md) - Documentation images

---

> This documentation map follows the standardized playbook template structure.
EOL
echo "Updated documentation map"

# 5. Create documentation standards file
echo "Creating documentation standards file..."
cat > docs/5-reference/DOCUMENTATION_STANDARDS.md << 'EOL'
# Documentation Standards

This document outlines the standards and best practices for documentation in the Three Horizons Playbook repository.

## Markdown Best Practices

### Headers

Use ATX-style headers with a space after the hash signs:

```markdown
# Level 1 Header
## Level 2 Header
### Level 3 Header
```

### Lists

For unordered lists, use a single dash followed by a space:

```markdown
- First item
- Second item
- Third item
```

For ordered lists, use numbers followed by a period and a space:

```markdown
1. First item
2. Second item
3. Third item
```

### Code Blocks

Use triple backticks for code blocks, with the language specified:

```markdown
​```python
def example_function():
    return "Hello, world!"
​```
```

### Links

Use reference-style links for better readability:

```markdown
[Link text][reference]

[reference]: https://example.com
```

Or inline links for simpler cases:

```markdown
[Link text](https://example.com)
```

### Images

Include alt text for all images:

```markdown
![Alt text](path/to/image.png)
```

For images that need sizing, use HTML:

```markdown
<img src="path/to/image.png" alt="Alt text" width="600"/>
```

### Tables

Use standard Markdown table syntax, with a blank line before and after:

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
```

### Emphasis

Use single asterisks for italic and double asterisks for bold:

```markdown
*italic text*
**bold text**
```

## File Organization

- Each document should start with a level 1 header (#) matching the filename
- Include a brief description immediately following the title
- Use a logical hierarchy of headers (# → ## → ###)
- Include a table of contents for longer documents
- Group related content under appropriate headers

## Content Guidelines

- Write in clear, concise language
- Use active voice when possible
- Define acronyms on first use
- Include examples for complex concepts
- Keep paragraphs short (3-5 sentences)
- Use visuals (diagrams, charts) to illustrate complex ideas

## Cross-Referencing

- Use relative links to other documents in the repository
- Include descriptive link text (not "click here")
- Maintain a central documentation map file

## Versioning

- Note document version history at the bottom of significant documents
- Include last updated date for key documentation

By following these standards, we ensure documentation is consistent, accessible, and maintainable across the Three Horizons Playbook repository.
EOL
echo "Created documentation standards file"

echo "Playbook template structure implementation complete!" 