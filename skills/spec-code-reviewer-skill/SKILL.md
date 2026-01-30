---
name: spec-code-reviewer-skill
description: Verify semantic consistency and identify logic gaps between design specifications (Markdown) and source code implementation.
---

# Spec-to-Code Semantic Review Skill

This skill provides a structured workflow for comparing software specifications with their corresponding source code to identify inconsistencies, missing features, or logic errors.

## What This Skill Is / Is Not

- **Best for**: Feature-level or module-level reviews where you can provide the relevant spec sections and the implementing code.
- **Not for**: Pure formatting/style checks (use linters/formatters), or fully-automated batch processing of hundreds of files (use dedicated tooling).

## Inputs (Recommended Format)

- **Specification (Markdown)**:
  - Requirement statements should be explicit (e.g., *Must/Shall/Should*).
  - Prefer stable identifiers such as **Requirement IDs** (`AUTH-001`) or at least **section headers**.
- **Source Code**:
  - Provide the most relevant files (or modules) that implement the spec.
  - If the code is large, provide **scoped excerpts** and include file paths.

## Output (Required)

Use this structure so findings are easy to track:

- **Summary**: `Highly Consistent / Partially Consistent / Inconsistent`
- **Findings table** (each row must cite evidence):
  - `Requirement ID / Section`
  - `Status` (`OK / NG / 要確認`)
  - `Observation` (what is missing/divergent/ambiguous, and *where* in code)
- **Suggested Improvements**: actionable next steps (implementation and/or spec clarification)

## Instructions

1.  **Gather Inputs**: Obtain the project specification (in Markdown) and the relevant source code files.
    - **Excel to Markdown Conversion**: If the spec is in Excel, convert it first using:
      - `xlsx2csv spec.xlsx | csvtomd` (requires xlsx2csv and csvtomd)
      - Pandoc: `pandoc spec.xlsx -o spec.md`
      - Online tools: TableConvert, Excel2Markdown
2.  **Contextualize**: Read the specification to understand the intended behavior, data structures, and edge cases.
3.  **Assign Requirement IDs** (if not present):
    - Use section headers as identifiers: `[AUTH-001]`, `[API-002]`
    - Or use line references: `Spec L45-L52`
    - Document the mapping in a traceability matrix for future reference.
4.  **Cross-Reference**: Systematically map each requirement in the specification to the corresponding implementation in the code.
5.  **Analyze**: Look for the following:
    - **Missing Logic**: Requirements that are not implemented.
    - **Divergent Logic**: Implementation that differs from the specification.
    - **Ambiguity**: Vague specifications that lead to questionable implementation.
6.  **Report**: Generate a detailed report highlighting identified gaps and suggesting improvements.

## Handling Large Inputs (Chunking Strategy)

- **Spec**: focus on the section(s) relevant to the target feature; include cross-referenced sections (data models, error handling, API contracts).
- **Code**:
  - Prefer chunking by **module/class/function boundaries**.
  - Keep **10–20 lines overlap** between chunks to avoid boundary misses.
  - Maintain a stable mapping: `Requirement → file path → symbol (function/class)`.

## References

For review criteria and case studies, see:
- [review-criteria.md](./references/review-criteria.md)
- [case-study.md](./references/case-study.md)
- [human-in-the-loop.md](./references/human-in-the-loop.md)
- [comparison-report.md](./references/comparison-report.md)
- [comparison-report_ja.md](./references/comparison-report_ja.md)

## Execution

Use the prompt template:

- [review_prompt.md](./assets/review_prompt.md)
