[English](./SECURITY.md) | [日本語](./SECURITY_ja.md)

# Security Policy

## Supported Versions

Only the latest version is supported:

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |
| < 0.2   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in IXV-Agents, please follow the responsible disclosure process below:

### Reporting Methods

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Report via one of the following methods:
   - Create a GitHub Private Security Advisory (recommended)
   - Email: info@elvez.co.jp
   - For low-severity issues, create an issue with the `security` label

### What to Include in Your Report

Please include the following information:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact and severity
- Suggested fix or mitigation (if possible)
- Your contact information (optional)

### Report Example

```
Subject: [SECURITY] Potential vulnerability in boot script permission handling

Description:
The boot script passes broad permissions to AI editors without
validating the target workspace directory, potentially allowing
unintended file access.

Steps to Reproduce:
1. Modify workspace/ symlink to point outside the repository
2. Run ./scripts/boot.sh
3. Observe that agents can access files outside the intended scope

Impact:
Could allow AI agents to read or modify files outside the workspace
directory on the host machine.

Suggested Fix:
Validate that workspace/ is a real directory (not a symlink to an
external path) before launching agents.
```

## Response Timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 7 days
- **Resolution**: Based on severity
  - Critical: Within 14 days
  - High: Within 30 days
  - Medium: Within 60 days
  - Low: Next release cycle

## Security Considerations

### AI Editor Permissions

The boot scripts grant AI editors broad permissions to enable autonomous agent operation:

- **Claude Code**: `--dangerously-skip-permissions` (all tool calls allowed without user approval)
- **OpenCode**: `OPENCODE_PERMISSION='{"permission":{"*":"allow"}}'` (all operations allowed)

These permissions are **required** for the multi-agent workflow (agents must operate without manual confirmation). The following operational guidelines mitigate risk:

- **Workspace isolation**: Agents operate within `workspace/`, separated from the repository root
- **Role boundaries**: Each agent is instructed via `roles/*.md` to only access files within its role scope
- **Audit trail**: All agent communication is logged in YAML files (`queue/`)
- **Controlled environment**: IXV-Agents should **only** be run on trusted machines in isolated environments

> **Note:** Workspace isolation and role boundaries are prompt-based operational guidelines, not technically enforced security boundaries. AI editors operate with full system permissions, so these controls rely on the AI model following its instructions.

### Agent Role Boundaries

- AI agents operate within defined role boundaries (PO, SM, Dev)
- Writing to files outside an agent's role scope is prohibited
- File ownership is enforced via the specification in `SPEC.md`

### Script Security

- Shell scripts use `set -euo pipefail` for strict error handling
- User inputs (e.g., model names) are validated before use
- Process management uses exact-match patterns to avoid affecting unrelated processes

### Traceability

- All changes are traceable via `spec_ref`, `request_id`, and `task_id`
- YAML-based communication provides an audit trail
- Dashboard tracks agent status and task progress

## Security Best Practices

1. **Use the latest version**: Always run the latest release of IXV-Agents
2. **Run in trusted environments**: Only run IXV-Agents on trusted machines in isolated environments
3. **Review AI-generated code**: Always review code produced by agents before deploying to production
4. **Keep tools up to date**: Update AI editor tools (OpenCode, Claude Code) regularly
5. **Protect credentials**: Do not store API keys, passwords, or secrets in `workspace/` files
6. **Monitor agent activity**: Review the `queue/` audit trail periodically
7. **Isolate workloads**: Use containers or VMs when running with untrusted inputs

## Known Security Limitations

1. **Prompt-based isolation**: Workspace isolation and role boundaries rely on AI model compliance, not technical enforcement
2. **Broad AI editor permissions**: Boot scripts grant AI editors unrestricted system access; mitigations are operational, not technical
3. **No secret detection**: The system does not automatically scan for secrets or credentials in workspace files
4. **Agent communication**: YAML-based inter-agent messages are not encrypted or signed

## Security Updates

Security updates are released as follows:

- Minor issues: Patch version (e.g., 0.1.1)
- Critical issues: Minor version (e.g., 0.2.0)
- Updates are noted in CHANGELOG.md with a `Security` category

## Acknowledgments

We appreciate security researchers who responsibly report vulnerabilities. Contributors who report valid security issues will be acknowledged in:

- CHANGELOG.md (unless they prefer anonymity)
- Release notes for the fix

## Questions

For security-related questions that are not vulnerabilities:

- Create an issue with the `security` label
- Contact: info@elvez.co.jp
