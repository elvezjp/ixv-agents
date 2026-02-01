# IXV-Agents

## Overview

**IXV-Agents** is a specification-driven AI development system that organizes multiple AI agents into a fixed, role-based team. It integrates agile roles and events with specification-driven development to ensure governance, traceability, and practical enterprise usage.

---

## Status

| Item | Status |
|------|--------|
| Specification (Spec.md) | Draft v0.2.0 |
| Implementation | Foundation Complete (tmux + AI CLI) |

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
| Development (Dev) | 8 | Implementation |

---

## Prerequisites

- macOS / Linux
- tmux
- AI CLI (one of the following)
  - [OpenCode](https://github.com/opencode-ai/opencode) (`opencode`) - Default
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)
- Bash 4.0+

---

## Quick Start

### 1. Initialize Workspace

```bash
./scripts/setup_workdir.sh
```

This creates the `workspace/` directory and populates it with initial files from templates.
If an existing `workspace/` exists, it will be backed up to `backups/`.

### 2. Start Agents

```bash
# Start with OpenCode (default)
./scripts/boot.sh

# Start with Claude Code
./scripts/boot.sh --claude-code

# Specify model
./scripts/boot.sh --model opus
```

This creates the following tmux sessions:
- **ixv-po**: Product Owner (1 pane)
- **ixv-agents**: SM + Dev1-Dev8 (3x3 grid)

### 3. Connect to PO and Start Development

```bash
tmux attach-session -t ixv-po
```

Communicate your requirements to PO, and tasks will be assigned to the Dev team via SM.

### 4. Monitor Agent Team

```bash
tmux attach-session -t ixv-agents
```

### 5. Stop Sessions

```bash
# Stop IXV sessions
./scripts/stop.sh

# Stop all tmux sessions
./scripts/stop.sh --all-tmux
```

### tmux Quick Reference

| Action | Command |
|--------|---------|
| Detach from session | `Ctrl+b d` |
| List sessions | `tmux ls` |
| Navigate between panes | `Ctrl+b Arrow keys` |

---

## Directory Structure

```
ixv-agents/
├── instructions/       # Role instructions (PO, SM, Dev)
├── skills/             # AI CLI skill definitions
├── templates/          # Workspace initialization templates
├── scripts/            # Startup and management scripts
│   ├── boot.sh         # Start agents
│   ├── stop.sh         # Stop agents
│   └── setup_workdir.sh # Initialize workspace
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
├── instructions -> ../instructions  (symlink)
├── .claude/skills -> ../../skills   (symlink)
├── .opencode/skills -> ../../skills (symlink)
├── specs/              # Specifications (Single Source of Truth)
│   ├── current_spec.md
│   └── backlog.md
├── queue/              # Inter-agent communication
│   ├── po_to_sm.yaml   # PO -> SM
│   ├── tasks/          # SM -> Dev
│   └── reports/        # Dev -> SM
├── dashboard.md        # Project status board
└── (artifacts)         # Implementation code, tests, etc.
```

---

## Operational Principles

- **Single Source of Truth**: Always reference `workspace/specs/current_spec.md`
- **Traceability**: Track via `spec_ref` / `request_id` / `task_id`
- **Role Boundaries**: Writing to files outside role scope is prohibited

---

## Key Documents

- `Spec.md`: System architecture, roles, workflow, and constraints
- `docs/skill-guide.md`: Skill design guide for ixv-agents

---

## License

TBD
