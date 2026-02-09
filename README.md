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

## Sentinel Architecture (Planned)

We will introduce a 24/7 local agent **Sentinel** on a single Mac Studio (512GB). Sentinel runs with a local LLM (Brain) and wakes the existing API agents (PO/SM/Dev) only when needed. Sentinel is a standalone Python application; no framework or class hierarchy is introduced.

```
Mac Studio 512GB (24/7)
│
├── Sentinel (local LLM, always on, API cost $0)
│   ├── Brain: MLX 70B-class model always loaded
│   ├── Heartbeat monitoring: liveness + sync for all agents
│   ├── Doc Triage: document structure analysis + key pages
│   └── Machine Monitor: system-wide monitoring (process/resource/FS)
│
├── PO Agent  (Claude Code CLI / API + Heartbeat)  ← on-demand
├── SM Agent  (Claude Code CLI / API + Heartbeat)  ← on-demand
├── Dev1-3    (Claude Code CLI / API + Heartbeat)  ← on-demand
│
├── Cursor (Repo A)  ← monitored by Sentinel
├── Cursor (Repo B)  ← monitored by Sentinel
└── Other processes  ← monitored by Sentinel
```

Existing behavior (`roles/*.md`, YAML queues, `scripts/*.sh`, tmux) remains unchanged. Sentinel is additive and optional. Heartbeat is a shared YAML schema: Sentinel reads; PO/SM/Dev write.

Plan document: `docs/20260209-baseagent-plan.md`

---

## 4 Principles

1. Specs are living documents
2. Specs are the Single Source of Truth (SSoT)
3. Change and iteration are assumed
4. AI reduces cost, humans decide

---

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

---

## Agent Team Composition (Fixed)

| Role | Count | Runtime | Responsibility |
|------|-------|---------|----------------|
| Sentinel | 1 | Local LLM (24h) | Monitor, triage, route, wake API agents |
| Product Owner (PO) | 1 | API (on-demand) | Define goals and priorities, create specifications |
| Scrum Master (SM) | 1 | API (on-demand) | Orchestrate workflow, decompose and assign tasks |
| Development (Dev) | 3 | API (on-demand) | Implementation |

---

## Prerequisites

- macOS / Windows
- Terminal multiplexer ([tmux](https://github.com/tmux/tmux/wiki) / [psmux](https://github.com/marlocarlo/psmux))
- AI Editor (one of the following)
  - [OpenCode](https://github.com/anomalyco/opencode) (`opencode`) - Default
  - [Claude Code](https://github.com/anthropics/claude-code) (`claude`)

---

## Setup

### AI Editor

Install one of the following.

**[OpenCode](https://github.com/anomalyco/opencode)** (Default)

- Desktop app: Download from [opencode.ai/download](https://opencode.ai/download)
- Command install: `curl -fsSL https://opencode.ai/install | bash`
- Other installation methods: See [official site](https://opencode.ai)

**[Claude Code](https://github.com/anthropics/claude-code)**

- Desktop app: Download from [claude.ai/download](https://claude.ai/download)
- Command install: `curl -fsSL https://claude.ai/install.sh | bash`
- Other installation methods: See [official documentation](https://code.claude.com/docs/en/overview)

### Terminal Multiplexer

**macOS: [tmux](https://github.com/tmux/tmux/wiki)**

- Command install: `brew install tmux`
- Other installation methods: See [official Wiki](https://github.com/tmux/tmux/wiki/Installing)

**Windows: [psmux](https://github.com/marlocarlo/psmux)** (tmux-compatible)

- Command install: `irm https://raw.githubusercontent.com/marlocarlo/psmux/master/scripts/install.ps1 | iex`
- Other installation methods: See [official repository](https://github.com/marlocarlo/psmux)
- PowerShell 7+ required

---

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

---

## Directory Structure

```
ixv-agents/
├── src/sentinel/       # Sentinel local agent (Python)
│   ├── main.py         # Entrypoint and event loop
│   ├── brain.py        # Local LLM interface (MLX)
│   ├── heartbeat.py    # Heartbeat reader
│   ├── machine.py      # Machine monitoring (psutil)
│   ├── queue_watcher.py # Queue change detection
│   ├── router.py       # Routing decisions
│   ├── tmux.py         # tmux send-keys adapter
│   └── config.py       # Configuration loader
├── tests/              # Sentinel tests
├── roles/              # Role instructions (Sentinel, PO, SM, Dev)
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

---

## Operational Principles

- **Single Source of Truth**: Always reference `workspace/README.md`
- **Traceability**: Track via `spec_ref` / `request_id` / `task_id`
- **Role Boundaries**: Writing to files outside role scope is prohibited

---

## Key Documents

- `Spec.md`: System architecture, roles, workflow, and constraints
- `docs/20260209-baseagent-plan.md`: Sentinel introduction plan
- `docs/20260129implementation-plan.md`: Implementation plan
- `docs/20260201directory-restructure-plan.md`: Directory restructure plan

---

## License

TBD
