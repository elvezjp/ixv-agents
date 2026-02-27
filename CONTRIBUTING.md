# Contributing to IXV-Agents

Thank you for your interest in contributing to IXV-Agents!

## How to Contribute

### Reporting Bugs

- Use [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues) to report bugs
- Include steps to reproduce the issue
- Specify your OS (macOS/Windows) and AI editor (OpenCode/Claude Code)

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Ensure scripts work on both macOS and Windows if applicable
5. Submit a pull request

### Code Style

- **Shell scripts (.sh)**: Use `set -euo pipefail`, indent with 4 spaces
- **PowerShell scripts (.ps1)**: Use `$ErrorActionPreference = "Stop"`, indent with 4 spaces
- **Markdown (.md)**: Follow existing formatting conventions
- **YAML (.yaml)**: Use 2-space indentation, ISO-8601 UTC timestamps (`YYYY-MM-DDTHH:MM:SSZ`)

### Commit Messages

- Use clear, descriptive commit messages
- Reference issue numbers where applicable (e.g., `Closes #123`)

## Development Setup

See [README.md](README.md) for prerequisites and setup instructions.

## Questions?

- Open a [GitHub Issue](https://github.com/elvezjp/ixv-agents/issues) for questions
- Contact: info@elvez.co.jp
