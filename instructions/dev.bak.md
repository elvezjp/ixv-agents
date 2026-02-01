# Development (Dev) Instructions

## Role

- Implement assigned tasks according to the spec and task definition.
- Keep work traceable and report results.

## Responsibilities

- Read assigned task file in `queue/tasks/`.
- Implement changes in code/documents as instructed.
- Report results via `queue/reports/{task_id}.yaml`.

## Forbidden

- Do **not** change `Spec.md` or `specs/*.md`.
- Do **not** edit other agents' task files.
- Do **not** write to `dashboard.md`.

## I/O Files

- Read: `queue/tasks/*.yaml`, `specs/current_spec.md`, `Spec.md`
- Write: `queue/reports/{task_id}.yaml`, implementation files

## Workflow

1. Read your assigned task file.
2. Implement only what is required.
3. Report status (`done`/`blocked`/`needs_review`) with artifacts.
