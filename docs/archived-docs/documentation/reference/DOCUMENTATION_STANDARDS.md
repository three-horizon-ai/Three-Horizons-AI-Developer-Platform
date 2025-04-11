# <span style="color: #0366d6;">🔹 Documentation Standards</span>

This document outlines the standards and best practices for documentation in the Three Horizons Playbook repository.

## <span style="color: #0366d6;">🔹 Markdown Best Practices</span>

### <span style="color: #0366d6;">Headers</span>

Use ATX-style headers with a space after the hash signs:

```markdown
# <span style="color: #0366d6;">🔹 Level 1 Header</span>
## <span style="color: #0366d6;">🔹 Level 2 Header</span>
### <span style="color: #0366d6;">Level 3 Header</span>
```

### <span style="color: #0366d6;">Lists</span>

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

### <span style="color: #0366d6;">Code Blocks</span>

Use triple backticks for code blocks, with the language specified:

```markdown
​```python
def example_function():
    return "Hello, world!"
​```
```

### <span style="color: #0366d6;">Links</span>

Use reference-style links for better readability:

```markdown
[Link text][reference]

[reference]: https://example.com
```

Or inline links for simpler cases:

```markdown
[Link text](https://example.com)
```

### <span style="color: #0366d6;">Images</span>

All diagrams and images must use SVG format according to our [SVG standards](../../SVG_STANDARD.md). Include alt text for all images:

```markdown
![Alt text](path/to/image.svg)
```

For images that need sizing, use HTML:

```markdown
<img src="path/to/image.svg" alt="Alt text" width="600"/>
```

### <span style="color: #0366d6;">Tables</span>

Use standard Markdown table syntax, with a blank line before and after:

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
```

### <span style="color: #0366d6;">Emphasis</span>

Use single asterisks for italic and double asterisks for bold:

```markdown
*italic text*
**bold text**
```

## <span style="color: #0366d6;">🔹 File Organization</span>

- Each document should start with a level 1 header (#) matching the filename
- Include a brief description immediately following the title
- Use a logical hierarchy of headers (# → ## → ###)
- Include a table of contents for longer documents
- Group related content under appropriate headers

## <span style="color: #0366d6;">📘 Content Guidelines</span>

- Write in clear, concise language
- Use active voice when possible
- Define acronyms on first use
- Include examples for complex concepts
- Keep paragraphs short (3-5 sentences)
- Use visuals (diagrams, charts) to illustrate complex ideas

## <span style="color: #0366d6;">🔹 Cross-Referencing</span>

- Use relative links to other documents in the repository
- Include descriptive link text (not "click here")
- Maintain a central documentation map file

## <span style="color: #0366d6;">🔹 Versioning</span>

- Note document version history at the bottom of significant documents
- Include last updated date for key documentation

By following these standards, we ensure documentation is consistent, accessible, and maintainable across the Three Horizons Playbook repository.

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
