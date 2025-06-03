# Security Policy

## Reporting a Vulnerability

The Three Horizons team takes security seriously. We appreciate your efforts to responsibly disclose your findings and will make every effort to acknowledge your contributions.

To report a security issue, please use the GitHub Security tab and click on "Report a vulnerability" or email us directly at security@threehorizons.example.com with the details of the vulnerability.

Please include the following information in your report:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit the issue

We request that you contact us via the above methods and give the project maintainers up to 90 days to resolve the issue before any public exposure.

## Supported Versions

We will address security vulnerabilities in the most recent version of our project. We encourage users to update to the latest version.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Measures

Three Horizons implementation includes several security measures:

- All services communicate over TLS
- Secrets are stored in Azure Key Vault
- Infrastructure is deployed with strict RBAC controls
- Continuous security scanning of source code and dependencies

## Best Practices

When implementing Three Horizons, we recommend the following security best practices:

1. Use Microsoft Entra ID for identity management
2. Enable Just-in-Time (JIT) VM access for management
3. Implement network security groups and application security groups
4. Use Azure Policy to enforce security controls
5. Enable Azure Defender for cloud workload protection
6. Set up regular security scanning in CI/CD pipelines
7. Follow the principle of least privilege for all accounts 