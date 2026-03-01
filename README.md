# IXV-Agents

[English](./README.md) | [日本語](./README_ja.md)

[![Elvez](https://img.shields.io/badge/Elvez-Product-3F61A7?style=flat-square)](https://elvez.co.jp/)
[![IXV Ecosystem](https://img.shields.io/badge/IXV-Ecosystem-3F61A7?style=flat-square)](https://elvez.co.jp/ixv/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](https://opensource.org/licenses/MIT)
[![Stars](https://img.shields.io/github/stars/elvezjp/ixv-agents?style=social)](https://github.com/elvezjp/ixv-agents/stargazers)

Specification-driven AI development system that organizes multiple AI agents into a fixed, role-based team. Integrates agile roles and events with specification-driven development to ensure governance, traceability, and practical enterprise usage.

## Features

- **Fixed Roles, Evolving Skills**: Humans define intent and specifications, while AI agents collaborate as a structured team
- **Specification as Single Source of Truth**: Specifications (Specs) are living documents and the SSoT for all development
- **Role-Based Agent Team**: Product Owner, Scrum Master, and 3 Development agents with clear responsibility boundaries
- **Automated Workflow**: Tasks are decomposed and distributed automatically from PO through SM to Dev agents
- **Cross-Platform Support**: Works on macOS (tmux) and Windows (psmux)
- **Multiple AI Editors**: Supports OpenCode and Claude Code

## Use Cases

- **Enterprise AI Development**: Structured AI-driven development with governance and traceability
- **Specification-Driven Projects**: Projects that require specs as the single source of truth
- **Multi-Agent Collaboration**: Parallel development with multiple AI agents working on decomposed tasks
- **Agile AI Workflow**: Agile-style development with AI agents filling scrum roles

## Documentation

- [Spec.md](Spec.md) - System architecture, roles, workflow, and constraints
- [docs/20260129implementation-plan.md](docs/20260129implementation-plan.md) - Implementation plan
- [docs/20260201directory-restructure-plan.md](docs/20260201directory-restructure-plan.md) - Directory restructure plan

## Setup

### Requirements

- macOS / Windows
- Terminal multiplexer ([tmux](https://github.com/tmux/tmux/wiki) / [psmux](https://github.com/marlocarlo/psmux))
- AI Editor (one of the following)
  - [OpenCode](https://github.com/anomalyco/opencode) (`opencode`) - Default
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)

### Install AI Editor

**[OpenCode](https://github.com/anomalyco/opencode)** (Default)

- Desktop app: Download from [opencode.ai/download](https://opencode.ai/download)
- Command install: `curl -fsSL https://opencode.ai/install | bash`
- Other installation methods: See [official site](https://opencode.ai)

**[Claude Code](https://github.com/anthropics/claude-code)**

- Desktop app: Download from [claude.ai/download](https://claude.ai/download)
- Command install: `curl -fsSL https://claude.ai/install.sh | bash`
- Other installation methods: See [official documentation](https://code.claude.com/docs/en/overview)

### Install Terminal Multiplexer

**macOS: [tmux](https://github.com/tmux/tmux/wiki)**

- Command install: `brew install tmux`
- Other installation methods: See [official Wiki](https://github.com/tmux/tmux/wiki/Installing)

**Windows: [psmux](https://github.com/marlocarlo/psmux)** (tmux-compatible)

- Command install: `irm https://raw.githubusercontent.com/marlocarlo/psmux/master/scripts/install.ps1 | iex`
- Other installation methods: See [official repository](https://github.com/marlocarlo/psmux)
- PowerShell 7+ required

## Usage

### 1. Start Agents

**macOS:**

```bash
# Start with OpenCode (default)
./scripts/boot.sh

# Start with Claude Code
./scripts/boot.sh --claude-code

# Specify model
./scripts/boot.sh --model anthropic/claude-opus-4-5
```

**Windows (PowerShell):**

```powershell
# Start with OpenCode (default)
.\scripts\boot.ps1

# Start with Claude Code
.\scripts\boot.ps1 -ClaudeCode

# Specify model
.\scripts\boot.ps1 -Model anthropic/claude-opus-4-5
```

On first run, the workspace is automatically initialized.

### 2. Session Layout

A single tmux session (`ixv-agents`) is created and automatically attached:

```
[ixv-agents] All Agents (5 panes)
┌─────────┬───────┬───────┬───────┐
│   PO    │ Dev1  │ Dev2  │ Dev3  │
│  (0.0)  │ (0.2) │ (0.3) │ (0.4) │
├─────────┤       │       │       │
│   SM    │       │       │       │
│  (0.1)  │       │       │       │
└─────────┴───────┴───────┴───────┘
```

**Usage:**
- Communicate your requirements to **PO** (upper-left pane), and tasks will be assigned to the Dev team via SM
- Other panes (SM, Dev1-3) operate automatically; no manual interaction required

**Detach from session:**
- `Ctrl+b d` to detach (session continues in background)

**Reattach to session:**

```bash
tmux attach-session -t ixv-agents
```

### 3. Stop Sessions

```bash
# macOS
./scripts/stop.sh
./scripts/stop.sh --force    # Force stop if processes remain
```

```powershell
# Windows
.\scripts\stop.ps1
.\scripts\stop.ps1 -Force    # Force stop if processes remain
```

### 4. Setup New Workspace

**macOS:**

```bash
./scripts/setup_workspace.sh

# Skip backup and reinitialize only
./scripts/setup_workspace.sh --no-backup
```

**Windows (PowerShell):**

```powershell
.\scripts\setup_workspace.ps1

# Skip backup and reinitialize only
.\scripts\setup_workspace.ps1 -NoBackup
```

If an existing `workspace/` exists, it will be backed up to `backups/`, and a new workspace will be created.

### tmux Quick Reference

| Action | Command |
|--------|---------|
| Detach from session | `Ctrl+b d` |
| Reattach to session | `tmux attach-session -t ixv-agents` |
| List sessions | `tmux ls` |

## Agent Team Composition

| Role | Count | Responsibility |
|------|-------|----------------|
| Product Owner (PO) | 1 | Define goals and priorities, create specifications |
| Scrum Master (SM) | 1 | Orchestrate workflow, decompose and assign tasks |
| Development (Dev) | 3 | Implementation |

## 4 Principles

1. Specs are living documents
2. Specs are the Single Source of Truth (SSoT)
3. Change and iteration are assumed
4. AI reduces cost, humans decide

## 7 Processes

| # | Process | Output | Approval |
|---|---------|--------|----------|
| 1 | Constitution | CONSTITUTION.md | Human |
| 2 | Specify | README.md (SSoT) | Human |
| 3 | Plan | docs/* | Human(*) |
| 4 | Tasks | queue/tasks/, dashboard.md | - |
| 5 | Implement | Code + Tests, reports/*.yaml | - |
| 6 | Verify/Accept | dashboard.md, Backlog update | Human |
| 7 | Migration/Op | → Process 2 or 4 | - |

(*) = when needed

> See `templates/PROCESS.md` for details.

## Directory Structure

```
ixv-agents/
├── roles/              # Role instructions (PO, SM, Dev)
├── skills/             # AI CLI skill definitions
├── templates/          # Workspace initialization templates
│   └── queue/          # Queue and report templates
├── scripts/            # Startup and management scripts
│   ├── banner.sh / .ps1           # Display banner
│   ├── boot.sh / .ps1             # Start agents
│   ├── stop.sh / .ps1             # Stop agents
│   ├── setup_workspace.sh / .ps1  # Initialize workspace
│   └── tmux-help.txt              # In-pane help text
├── OLD/                # Legacy assets (kept for reference)
├── backups/            # Workspace backups [.gitignore]
├── workspace/          # AI editor working directory [.gitignore]
├── docs/               # Documentation
├── Spec.md             # System specification
└── README.md
```

### workspace/ Directory

`workspace/` is the directory where AI editors actually perform their work.
It is isolated from the repository root, preventing AI editors from accessing tool READMEs and other unrelated files.

```
workspace/
├── README.md           # Project spec (Single Source of Truth)
├── CONSTITUTION.md     # Project constitution
├── PROCESS.md          # Process and operations
├── AGENTS.md           # AI conduct guidelines
├── roles -> ../roles   (symlink)
├── .claude/skills -> ../../skills   (symlink)
├── .opencode/skills -> ../../skills (symlink)
├── queue/              # Inter-agent communication
│   ├── dashboard.md    # Project status board
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
└── (artifacts)         # Implementation code, tests, etc.
```

## Operational Principles

- **Single Source of Truth**: Always reference `workspace/README.md`
- **Traceability**: Track via `spec_ref` / `request_id` / `task_id`
- **Role Boundaries**: Writing to files outside role scope is prohibited

## Contributing

Contributions are welcome!

- Report bugs via [GitHub Issues](https://github.com/elvezjp/ixv-agents/issues)
- Submit pull requests for improvements
- Follow existing code style

## Security

**Key security notes:**
- AI agents operate within defined role boundaries
- Writing to files outside role scope is prohibited
- All changes are traceable via spec references and task IDs
- The workspace is isolated from the repository root

## Background

This project is part of the **IXV** ecosystem, an AI development support tool suite by Elvez, Inc. IXV-Agents provides the multi-agent orchestration layer for specification-driven AI development.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contact

- **Email**: info@elvez.co.jp
- **Company**: [Elvez, Inc.](https://elvez.co.jp/)
