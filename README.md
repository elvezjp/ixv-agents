# IXV-Agents

## Overview

**IXV-Agents** is a specification-driven AI development system that
organizes multiple AI agents into a fixed, role-based team. It
integrates agile roles and events with specification-driven development
to ensure governance, traceability, and practical enterprise usage.



------------------------------------------------------------------------

## Reference Implementation

This project explicitly references `multi-agent-shogun-main/` in this workspace as the baseline implementation for scripts, tmux layout, and role instruction templates.

------------------------------------------------------------------------

## 日本語サマリ

**IXV-Agents** は、仕様（Spec）を単一の真実として、PO/SM/Dev/QAの固定ロールで協働するAI開発体制を構築する仕組みです。
トレーサビリティとガバナンスを重視し、役割とイベントで運用を律します。

------------------------------------------------------------------------

## Status

| Item | Status |
|------|--------|
| Specification (Spec.md) | Draft v0.1.0 |
| Implementation Plan (Plan.md) | Draft v0.1.0 |
| Implementation | In Progress (Web UI + SSE demo) |

**Next Step**: Phase 1 - Environment Setup

------------------------------------------------------------------------

## Web UI

The system will provide a local Web UI for viewing dashboard and queue status. The Markdown files remain the source of truth, and the UI mirrors them.
Frontend uses **React + Tailwind**, and backend is a **read-only** local service.

### Demo mode (no backend required)

You can run the UI with built-in demo data:

- Start: `cd frontend && VITE_DEMO=1 npm run dev`
- Toggle: **Demo Mode / Live Mode** button in the header

### Real-time agent events (SSE)

The UI shows a live stream of agent events:

- **Demo mode**: frontend generates simulated events
- **Live mode**: connects to backend `/api/events` (SSE)

Backend start:
`cd backend && npm run dev`

------------------------------------------------------------------------

## Core Concept

**Fixed roles, evolving skills.** Humans define intent and
specifications, while AI agents collaborate as a structured team.

------------------------------------------------------------------------

## Agent Team Composition (Fixed)

-   Product Owner AI (1)
-   Scrum Master AI (1)
-   Development AI (8)
-   QA / Quality AI (2)

------------------------------------------------------------------------

## Roles

PO AI defines goals and priorities. SM AI orchestrates workflow. Dev AI
executes implementation. QA AI ensures compliance and quality.

------------------------------------------------------------------------

## Agile Events

Sprint Planning, Daily Scrum, Sprint Review, Retrospective are system
primitives.

------------------------------------------------------------------------

## Specification-Driven Development

Specifications are the single source of truth. Implementation is
continuously validated against them.

------------------------------------------------------------------------

## Skill System

Skills are reusable units of judgment that emerge from repeated
behavior.

------------------------------------------------------------------------

## Architecture

Role-based, event-driven, and fully traceable.

------------------------------------------------------------------------

## Philosophy

Specifications define intent. Roles define responsibility. Skills define
capability. Events define rhythm.

------------------------------------------------------------------------

## Key Documents

-   `Spec.md`: System architecture, roles, workflow, and constraints.
-   `Plan.md`: Implementation phases and tasks (execution plan).

------------------------------------------------------------------------

## Prerequisites

-   macOS / Linux
-   tmux
-   Claude Code CLI (`claude-code`)
-   Bash 4.0+

------------------------------------------------------------------------

## Getting Started

1. Read `Spec.md` to understand the system architecture.
2. Review `Plan.md` for the implementation roadmap.
3. (After implementation) Run `scripts/ixv_boot.sh` to start the agent team.

------------------------------------------------------------------------

## Directory Structure (Planned)

```
ixv-agents/
├── config/             # Project configuration
├── frontend/           # React + Tailwind UI (local, read-only)
├── backend/            # Local read-only service for files/queue
├── instructions/       # Role instructions (PO, SM, Dev, QA)
├── specs/              # Specifications (Single Source of Truth)
├── queue/              # Communication buffers
├── dashboard.md        # Project status board
├── memory/             # MCP Memory
└── scripts/            # Startup scripts
```

------------------------------------------------------------------------

## Operational Principles

- **Single Source of Truth**: `specs/current_spec.md` を必ず参照
- **Traceability**: `spec_ref` / `request_id` / `task_id` で追跡
- **Role Boundaries**: 役割外のファイル更新は禁止

------------------------------------------------------------------------

## License

TBD
