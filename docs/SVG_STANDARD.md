
---
title: SVG Standards & GitHub Compatibility Guide
description: Best practices for creating and maintaining SVG diagrams in the Three Horizons Platform documentation
position_in_journey: 40
previous_doc: /docs/GLOSSARY.md
next_doc: /docs/5-reference/README.md
last_updated: 2025-04-10
---

# Your Visual Communication Journey

Welcome to the SVG Standards & GitHub Compatibility Guide for the Three Horizons Platform. This document will help you create effective visual communications that maintain consistency and accessibility across your implementation journey.

## Your Diagram Creation Guide

This guide outlines our standards for SVG diagrams in documentation, focusing on ensuring compatibility with GitHub's rendering engine while maintaining visual clarity for all users.

## Ensuring Platform Compatibility

As you create visual assets for your Three Horizons implementation, follow these guidelines to ensure compatibility across all platforms:

### GitHub Rendering Optimization (Horizon 1)

1. **Include Essential XML Structure**:
   ```xml
   <?xml version="1.0" encoding="UTF-8" standalone="no"?>
   <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
   ```

2. **Focus on Clarity and Simplicity**:
   - Avoid complex filters and effects that GitHub may not render correctly
   - Use simplified color schemes for better cross-platform compatibility
   - Maintain clear visual hierarchy in your diagrams

3. **Create Format Alternatives**:
   - Always provide PNG fallbacks for your SVG diagrams
   - Use PNG versions in GitHub Markdown for optimal viewing
   - Provide SVG originals for high-resolution downloads

## Your Diagram Conversion Toolkit

We've created powerful tools to help you manage visual assets throughout your Three Horizons journey:

### Essential Conversion Tools (Horizon 1)

1. **Creating GitHub-Compatible PNGs**:
   ```bash
   ./scripts/utilities/convert-images-to-svg.sh -r -s -d ./path/to/diagrams
   ```
   *This creates optimized PNG versions of your SVGs for GitHub display*

2. **Converting Images to SVGs**:
   ```bash
   ./scripts/utilities/convert-images-to-svg.sh -d ./path/to/images
   ```
   *Transform existing images into vector graphics for higher quality*

### Advanced Optimization (Horizon 2)

3. **GitHub-Optimized SVGs**:
   ```bash
   ./scripts/utilities/convert-images-to-svg.sh -o -s -d ./path/to/diagrams
   ```
   *Creates specially optimized SVGs that render better on GitHub*

**Best Practice**: For optimal viewing experience in documentation, we recommend **using PNG files in your Markdown** while providing direct links to the SVG versions for those who need vector formats or higher resolution.

## Diagram Creation Excellence

Create professional, consistent diagrams throughout your Three Horizons implementation:

### Creation Fundamentals (Horizon 1)

1. **Use Professional Tools**:
   - Inkscape: Powerful open-source vector editor
   - Draw.io: Browser-based diagramming with excellent collaboration
   - Figma: Design system integration for enterprise teams

2. **Optimize for Performance**:
   - Keep file sizes under 100KB for fast loading
   - Remove unnecessary elements and metadata
   - Use appropriate compression techniques

### Design Best Practices (Horizon 2)

3. **Accessibility First**:
   - Include alt text descriptions for all diagrams
   - Ensure sufficient color contrast for readability
   - Make text in diagrams selectable when possible

4. **Maintain Visual Consistency**:
   - Follow the Three Horizons color palette and design system
   - Use consistent iconography and visual language
   - Apply standard connector styles and layout patterns

5. **Validate Before Publishing**:
   - Test rendering on GitHub before submitting PRs
   - Verify diagrams display correctly on different devices
   - Seek feedback on clarity and understandability

## Solving Common Diagram Challenges

When you encounter issues with your diagrams in your Three Horizons journey:

### Troubleshooting Process (Horizon 1)

1. **Validate Structure**:
   - Check XML validity with an SVG validator
   - Verify all required namespaces are present
   - Ensure proper nesting of SVG elements

2. **Simplify for Compatibility**:
   - Remove complex filters and effects
   - Replace gradient fills with solid colors
   - Simplify paths and reduce node counts

3. **Use Our Optimization Tools**:
   ```bash
   ./scripts/utilities/convert-images-to-svg.sh -s -o -d ./path/to/problematic-svg
   ```

4. **Fallback Strategy**:
   - When SVG compatibility can't be resolved, use the PNG version
   - Include a link to the original SVG for download
   - Document the issue for future improvements

## Continue Your Visual Journey

For more advanced diagram techniques and integration with the Three Horizons model, proceed to the [Architecture Documentation](./1-architecture/README.md) section.

---

<footer>
  <p align="center">🔄 Last updated: April 10, 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
