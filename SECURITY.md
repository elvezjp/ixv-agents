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

### AI Editor Permissions

The boot scripts grant AI editors broad permissions to enable autonomous agent operation:

- **Claude Code**: `--dangerously-skip-permissions` (all tool calls allowed without user approval)
- **OpenCode**: `OPENCODE_PERMISSION='{"permission":{"*":"allow"}}'` (all operations allowed)

These permissions are **required** for the multi-agent workflow (agents must operate without manual confirmation). The following operational guidelines are in place to mitigate risk:

- **Workspace isolation**: Agents are instructed to operate within `workspace/`, separated from the repository root
- **Role boundaries**: Each agent is instructed via `roles/*.md` to only access files within its role scope
- **Audit trail**: All agent communication is logged in YAML files (`queue/`)
- **Controlled environment**: IXV-Agents should **only** be run on trusted machines in isolated environments

> **Note:** Workspace isolation and role boundaries are prompt-based operational guidelines, not technically enforced security boundaries. AI editors operate with full system permissions, so these controls rely on the AI model following its instructions and do not completely prevent access outside the intended scope.

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest (main) | Yes |

## Best Practices for Users

- Only run IXV-Agents in trusted environments
- Review AI-generated code before deploying to production
- Keep AI editor tools (OpenCode, Claude Code) up to date
- Do not store secrets in `workspace/` files
