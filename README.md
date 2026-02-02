# IXV-Agents

## Overview

**IXV-Agents** is a specification-driven AI development system that organizes multiple AI agents into a fixed, role-based team. It integrates agile roles and events with specification-driven development to ensure governance, traceability, and practical enterprise usage.

---

## Core Concept

**Fixed roles, evolving skills.**
Humans define intent and specifications, while AI agents collaborate as a structured team.

- **Specifications (Specs)** are the single source of truth
- **Roles** define responsibility boundaries
- **Events** establish development rhythm

---

## Agent Team Composition (Fixed)

| Role | Count | Responsibility |
|------|-------|----------------|
| Product Owner (PO) | 1 | Define goals and priorities, create specifications |
| Scrum Master (SM) | 1 | Orchestrate workflow, decompose and assign tasks |
| Development (Dev) | 3 | Implementation |

---

## Prerequisites

- macOS / Linux
- [tmux](https://github.com/tmux/tmux/wiki)
- AI CLI (one of the following)
  - [OpenCode](https://github.com/opencode-ai/opencode) (`opencode`) - Default
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)
- Bash 4.0+

---

## Quick Start

### 1. Start Agents

```bash
# Start with OpenCode (default)
./scripts/boot.sh

# Start with Claude Code
./scripts/boot.sh --claude-code

# Specify model
./scripts/boot.sh --model anthropic/claude-opus-4-5
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
# Stop IXV sessions
./scripts/stop.sh

# Force stop if processes remain
./scripts/stop.sh --force
```

### 4. Setup New Workspace

```bash
./scripts/setup_workspace.sh

# Skip backup and reinitialize only
./scripts/setup_workspace.sh --no-backup
```

If an existing `workspace/` exists, it will be backed up to `backups/`, and a new workspace will be created.

### tmux Quick Reference

| Action | Command |
|--------|---------|
| Detach from session | `Ctrl+b d` |
| Reattach to session | `tmux attach-session -t ixv-agents` |
| List sessions | `tmux ls` |

---

## Directory Structure

```
ixv-agents/
├── roles/              # Role instructions (PO, SM, Dev)
├── skills/             # AI CLI skill definitions
├── templates/          # Workspace initialization templates
│   └── queue/          # Queue and report templates
├── scripts/            # Startup and management scripts
│   ├── banner.sh       # Display banner
│   ├── boot.sh         # Start agents
│   ├── flow_check.sh   # Flow check utility
│   ├── stop.sh         # Stop agents
│   └── setup_workspace.sh # Initialize workspace
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

---

## Operational Principles

- **Single Source of Truth**: Always reference `workspace/README.md`
- **Traceability**: Track via `spec_ref` / `request_id` / `task_id`
- **Role Boundaries**: Writing to files outside role scope is prohibited

---

## Key Documents

- `Spec.md`: System architecture, roles, workflow, and constraints
- `docs/20260129implementation-plan.md`: Implementation plan
- `docs/20260201directory-restructure-plan.md`: Directory restructure plan

---

## License

TBD
