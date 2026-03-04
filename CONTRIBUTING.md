[English](./CONTRIBUTING.md) | [日本語](./CONTRIBUTING_ja.md)

# Contributing to IXV-Agents

Thank you for your interest in contributing to IXV-Agents! This document describes the guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub with the following information:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Sample files or screenshots (if applicable)
- Your environment:
  - OS (macOS / Windows)
  - AI editor (OpenCode / Claude Code) and version
  - tmux or psmux version

### Suggesting Features

We welcome feature suggestions! Please create an issue with:

- A clear and descriptive title
- Detailed description of the proposed feature
- Use cases and benefits
- Related examples or mockups (if applicable)

### Pull Requests

1. **Fork the repository** and create a branch from `main`:
   ```bash
   git checkout -b yourname/20260301-add-feature
   ```

2. **Follow the coding style** of the existing codebase (see [Coding Guidelines](#coding-guidelines))

3. **Test your changes**:
   ```bash
   # Verify boot scripts work
   ./scripts/boot.sh
   ./scripts/stop.sh

   # If you modified PowerShell scripts, test on Windows as well
   .\scripts\boot.ps1
   .\scripts\stop.ps1
   ```

4. **Update documentation** as needed:
   - User-facing changes: Update `README.md` and `README_ja.md`
   - Specification changes: Update `SPEC.md`
   - New features: Add usage examples

5. **Commit with a clear message** (see [Commit Messages](#commit-messages))

6. **Push to your fork** and submit a pull request:
   ```bash
   git push origin yourname/20260301-add-feature
   ```

7. **Wait for review** — maintainers will review your PR and may request changes

## Development Setup

### Prerequisites

- macOS or Windows
- [tmux](https://github.com/tmux/tmux/wiki) (macOS) or [psmux](https://github.com/marlocarlo/psmux) (Windows)
- AI editor: [OpenCode](https://github.com/anomalyco/opencode) or [Claude Code](https://github.com/anthropics/claude-code)

### Installation

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/ixv-agents.git
cd ixv-agents

# Initialize workspace
./scripts/setup_workspace.sh
```

### Testing Your Changes

Before submitting a PR, verify:

1. Boot scripts launch all 5 agent panes correctly
2. Stop scripts terminate all processes cleanly
3. Workspace setup creates the expected directory structure
4. Scripts work on both macOS and Windows (if applicable)

> **Note:** IXV-Agents does not currently have an automated test suite. Manual verification of the above is expected.

## Coding Guidelines

### Shell Scripts (.sh)

- Use `set -euo pipefail` at the top
- Indent with 4 spaces
- Quote all variables: `"${variable}"`
- Validate user inputs before use

### PowerShell Scripts (.ps1)

- Use `$ErrorActionPreference = "Stop"` at the top
- Indent with 4 spaces
- Follow PowerShell naming conventions (Verb-Noun)

### Markdown (.md)

- Follow existing formatting conventions
- Use relative links for internal references
- Specify language in code blocks (e.g., ` ```bash `, ` ```yaml `)

### YAML (.yaml)

- Use 2-space indentation
- Use ISO-8601 UTC timestamps (`YYYY-MM-DDTHH:MM:SSZ`)
- Follow the schema defined in `skills/references/`

## Commit Messages

Use the present tense, imperative mood. Keep the first line under 72 characters.

**Good examples:**
```
Add Windows support for boot script

- Add boot.ps1 with psmux integration
- Add stop.ps1 with graceful shutdown
- Update README with Windows instructions

Closes #42
```

```
Fix agent startup race condition

Introduce staged startup with delays between agent launches
to avoid token refresh conflicts.
```

**Avoid:**
```
# Too vague
Fixed stuff

# Past tense
Added new feature

# No context
Update boot.sh
```

## Branch Naming

Use the following format:

```
{username}/{YYYYMMDD}-{description}
```

- `username`: Your name in lowercase (e.g., `tominaga`)
- `YYYYMMDD`: Date the branch was created
- `description`: Short description using lowercase and hyphens only

**Examples:**
```
tominaga/20260301-add-windows-support
tanaka/20260215-fix-boot-race-condition
```

## Code Review Process

1. A maintainer will review your pull request
2. Changes or questions may be requested
3. Once approved, the PR will be merged
4. Your contribution will be acknowledged in the release notes

## Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others when possible
- Follow the project's code of conduct

## Questions

If you have questions about contributing:

- Create an issue with the `question` label: [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues)
- Contact: info@elvez.co.jp
