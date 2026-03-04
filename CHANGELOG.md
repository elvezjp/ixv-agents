[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-04

Initial public release.

### Added

- Role-based multi-agent team: Product Owner (PO), Scrum Master (SM), and 3 Development agents
- 7-process specification-driven workflow (Constitution → Specify → Plan → Tasks → Implement → Verify/Accept → Migration/Op)
- tmux-based session management with 5-pane layout (`boot.sh` / `boot.ps1`)
- Cross-platform support: macOS (tmux) and Windows (psmux / PowerShell)
- Multiple AI editor support: OpenCode (default) and Claude Code
- Workspace isolation (`workspace/`) separating AI editor working directory from repository root
- YAML-based inter-agent communication via `queue/` (PO→SM, SM→Dev, Dev→SM)
- 13 AI CLI skills covering the full development workflow
- Workspace setup and backup scripts (`setup_workspace.sh` / `setup_workspace.ps1`)
- Session stop scripts with graceful and force shutdown (`stop.sh` / `stop.ps1`)
- Staged agent startup to avoid token refresh conflicts
- In-pane tmux help text for quick reference
- Demo video embedded in README

### Documentation

- System specification (`SPEC.md`)
- README in English (`README.md`) and Japanese (`README_ja.md`)
- CONTRIBUTING.md with code style and PR guidelines
- SECURITY.md with vulnerability reporting and agent permission details

### Security

- Workspace isolation from repository root
- Role boundary enforcement via agent instructions
- Shell scripts use `set -euo pipefail` for strict error handling
- Input validation for user-provided parameters (e.g., model names)
- Exact-match process management to avoid affecting unrelated processes

### Known Limitations

- Workspace isolation and role boundaries are prompt-based operational guidelines, not technically enforced security boundaries
- Boot scripts grant AI editors broad permissions (`--dangerously-skip-permissions` for Claude Code, all-allow for OpenCode); run only in trusted/isolated environments

## Links

- [Repository](https://github.com/elvezjp/ixv-agents)
- [Issues](https://github.com/elvezjp/ixv-agents/issues)

## Version Summary

| Version | Summary |
|---------|---------|
| 0.1.0   | Initial public release with role-based multi-agent system, 7-process workflow, cross-platform support |
