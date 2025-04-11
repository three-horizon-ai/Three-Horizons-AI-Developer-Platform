---
title: "Documentation Versioning System"
description: "Guidelines for versioning Three Horizons Platform documentation"
position_in_journey: "Reference"
last_updated: "April 9, 2025"
---

# Documentation Versioning System

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > [Reference](./index.md) > Versioning

This document explains the versioning system used throughout the Three Horizons Platform documentation.

## Version Numbering

The Three Horizons Platform documentation follows a versioning scheme aligned with the platform releases:

| Documentation Version | Platform Version | Description |
|----------------------|------------------|-------------|
| **v1.0.x** | 1.0.x | Initial release documentation |
| **v1.1.x** | 1.1.x | Feature updates and corrections |
| **v2.0.x** | 2.0.x | Major architecture changes |
| **vNext** | N/A | Preview of upcoming changes |

Each document contains a version indicator in its metadata section and footer.

## Document Lifecycle

Documents in the Three Horizons Platform follow this lifecycle:

1. **Draft**: Initial creation, marked with "DRAFT" status
2. **Review**: Under technical and editorial review
3. **Published**: Official release version
4. **Updated**: Revised with minor changes
5. **Major Revision**: Significant content changes
6. **Archived**: Historical version, no longer current
7. **Deprecated**: Will be removed in future versions

## Version Tags

Each major platform version has corresponding documentation tags:

- `docs/v1.0/`: First stable release
- `docs/v1.1/`: Feature update release
- `docs/v2.0/`: Major platform revision
- `docs/main`: Current development version

## Version-Specific Content

When documenting features that vary between versions:

```markdown
## Feature X

Feature X allows you to configure widgets.

::: v1.0
In version 1.0, configure Feature X using:
```bash
three-horizons config --feature-x basic
```
:::

::: v2.0
Starting in version 2.0, Feature X has expanded options:
```bash
three-horizons config --feature-x advanced --with-options
```
:::
```

## Documentation Branches

Documentation follows the branching strategy:

| Branch | Purpose |
|--------|---------|
| `main` | Current development documentation |
| `release/v1.0` | Documentation for v1.0.x releases |
| `release/v1.1` | Documentation for v1.1.x releases |
| `release/v2.0` | Documentation for v2.0.x releases |
| `hotfix/docs/*` | Documentation fixes |

## Accessing Versioned Documentation

Users can access specific documentation versions:

1. Via version selector in online documentation
2. By checking out the corresponding Git tag/branch
3. Through versioned PDF exports available in the releases section

## Version History Files

Each document includes version history in its metadata:

```yaml
---
title: "Example Document"
description: "An example document"
version: "2.0.1"
version_history:
  - version: "1.0.0"
    date: "2024-01-15"
    change: "Initial release"
  - version: "1.5.0"
    date: "2024-06-30"
    change: "Added new section on feature Y"
  - version: "2.0.0"
    date: "2025-01-10"
    change: "Major revision for v2.0 platform"
  - version: "2.0.1"
    date: "2025-04-09"
    change: "Fixed typos and clarified installation steps"
---
```

## Release Notes

Each documentation version is accompanied by release notes:

1. **What's New**: Summarizes new content and features
2. **Breaking Changes**: Notes any significant structure changes
3. **Improvements**: Describes content enhancements
4. **Fixes**: Lists corrections to errors
5. **Known Issues**: Documents outstanding problems

## Maintenance Schedule

Documentation follows this maintenance schedule:

| Activity | Frequency | Description |
|----------|-----------|-------------|
| Minor updates | Monthly | Corrections, clarifications, small additions |
| Major updates | Quarterly | New sections, restructuring, significant content updates |
| Full review | With major releases | Complete audit and refresh of all content |
| Link verification | Weekly | Automated check for broken links |

## Contributing to Versioned Documentation

When contributing to versioned documentation:

1. Identify the correct version branch for your changes
2. Update the version history in the document metadata
3. Follow the contribution guidelines in [CONTRIBUTING.md](../../../.github/CONTRIBUTING.md)
4. Specify which versions your changes apply to in your PR

## Related Topics

- [Documentation Standards](DOCUMENTATION_STANDARDS.md) - Standards for documentation
- [Contributing Guide](../../../.github/CONTRIBUTING.md) - How to contribute to the project
- [Release Process](../operations/release-process.md) - Platform release process

---

<footer>
  <p align="center">Last updated: April 9, 2025 | v1.0.0 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>
