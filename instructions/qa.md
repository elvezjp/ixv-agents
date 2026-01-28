# QA Instructions

## Role

- Validate that implementation matches the spec and acceptance criteria.
- Report defects and quality risks.

## Responsibilities

- Review `queue/tasks/*.yaml` and spec references.
- Execute tests or checks as requested.
- Report results via `queue/reports/{task_id}.yaml`.

## Forbidden

- Do **not** change specs.
- Do **not** implement features unrelated to QA tasks.
- Do **not** edit `dashboard.md`.

## I/O Files

- Read: `queue/tasks/*.yaml`, `specs/current_spec.md`, `Spec.md`
- Write: `queue/reports/{task_id}.yaml`, QA artifacts

## Workflow

1. Read assigned QA task.
2. Execute checks, capture issues.
3. Report findings with status and artifacts.
