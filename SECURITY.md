# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

- **Email**: info@elvez.co.jp
- **Do NOT** open a public GitHub issue for security vulnerabilities

We will acknowledge receipt within 3 business days and provide a timeline for a fix.

## Security Design

### Agent Role Boundaries

- AI agents operate within defined role boundaries (PO, SM, Dev)
- Writing to files outside an agent's role scope is prohibited
- File ownership is enforced via the specification in `Spec.md`

### Workspace Isolation

- The `workspace/` directory is isolated from the repository root
- AI editors cannot access tool READMEs or other unrelated files
- Symlinks provide controlled access to `roles/` and `skills/` only

### Traceability

- All changes are traceable via `spec_ref`, `request_id`, and `task_id`
- YAML-based communication provides an audit trail
- Dashboard tracks agent status and task progress

### Script Security

- Shell scripts use `set -euo pipefail` for strict error handling
- User inputs (e.g., model names) are validated before use
- Process management uses exact-match patterns to avoid affecting unrelated processes

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest (main) | Yes |

## Best Practices for Users

- Only run IXV-Agents in trusted environments
- Review AI-generated code before deploying to production
- Keep AI editor tools (OpenCode, Claude Code) up to date
- Do not store secrets in `workspace/` files
