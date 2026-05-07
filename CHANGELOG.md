[English](./CHANGELOG.md) | [日本語](./CHANGELOG_ja.md)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-07

Workflow validation layer release. Adds explicit validation steps for required fields, Definition of Done, dependencies, and task-phase routing on top of the existing PO → SM → Dev workflow. Backward compatible with `0.1.0` (no schema changes); existing workspaces benefit from re-running `setup_workspace` to pick up the updated skills and roles.

### Added

- `VERSION` file at repository root as the canonical Single Source of Truth for the release version
- Workflow validation layer — explicit validation steps wired into the issuing skills (#31, #32, #33, #40):
  - Required-field / non-empty-array validation before issuing `po_to_sm.yaml` and `tasks/dev{N}.yaml`
  - Definition of Done cross-check on Dev self-report and SM receipt; auto-downgrade `done` → `needs_review` when DoD items are uncovered
  - Dependency validation: cyclic-dependency detection (DAG enforcement) and dependent-task status gating (`done` / `in_progress` / `blocked` / `needs_review` / missing)
  - `task_type` → phase routing with a decision tree for generic `feature` / `bugfix` task types
- Role validation duties — PO / SM / Dev role instructions now describe each role's validation responsibilities (`roles/po.md`, `roles/sm.md`, `roles/dev.md`)
- Shared skill references — `skills/references/dod-verification.md` and `skills/references/dependency-validation.md`
- GitHub Actions CI — pre-commit job plus a workspace-setup smoke test running on Ubuntu, macOS, and Windows (`.github/workflows/ci.yml`)
- `shellcheck` static analysis and `shfmt` formatting checks integrated into pre-commit / CI
- Test case table and execution results for the workflow validation layer (`docs/20260430-workflow-validation-test-cases.md`, `docs/20260430-workflow-validation-test-results.md`)
- Workflow validation layer implementation plan (`docs/20260430-workflow-validation-fix-plan.md`)

### Changed

- `SPEC.md` expanded to v0.2.0:
  - §2.3 YAML data schema as field tables (required / optional, allowed values)
  - §2.4 Task state transitions and validation rules (required-array enforcement, DoD cross-check, missing-field handling)
  - §2.5 Exclusivity rules and dependency DAG, including dependent-task status requirements
  - §2.6 `task_type` → phase routing rules (direct mapping table + decision tree for `feature` / `bugfix`)
  - §2.7 File ownership matrix (write / read permissions per role)
- Skill instructions extended to invoke the new validation steps: `po-request-yaml`, `sm-receive-request`, `sm-write-task-yaml`, `sm-scan-reports`, `dev-receive-task`, `dev-write-report`
- Shell scripts reformatted to 2-space indentation, enforced via `shfmt` in pre-commit
- `gitleaks` pre-commit hook bumped from `v8.22.1` to `v8.30.0`

### Fixed

- Removed unused shell variables surfaced by `shellcheck`

### Documentation

- Updated public-release preparation note (`docs/20260304publishing-preparation.md`)
- README links and references kept in sync with the new SPEC sections

### Known Limitations

- Validation is enforced by the issuing skills (prompt-level). It is not a hard schema check at the YAML layer; agents that bypass the skills can still emit non-conformant YAML.
- The abnormal-case validation scenarios for the workflow validation layer remain unverified as of this release; see `docs/20260430-workflow-validation-test-results.md` for the current status.
- The `0.1.x` entry's stated count of "13 AI CLI skills" was inaccurate; the actual count is 12 (no skill was added or removed in `0.2.0`).

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
| 0.2.0   | Workflow validation layer (required-field / DoD / dependency / phase-routing checks), SPEC.md expansion, GitHub Actions CI |
| 0.1.0   | Initial public release with role-based multi-agent system, 7-process workflow, cross-platform support |
