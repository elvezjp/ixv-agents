---
name: coding-policy-ai-auditor
description: Audit source code against semantic and judgment-based coding policies (e.g. naming, architecture, intent) using the rule-by-rule evaluation method.
---

# Coding Policy AI Auditor Skill

This skill provides a structured workflow for auditing source code against subjective or semantic coding standards (judgment-based rules) that are difficult for traditional linting tools to detect.

## What This Skill Is / Is Not

- **Best for**: naming clarity, architectural intent, layering rules, readability policies, “no magic numbers”, “service must not call DB directly”, etc.
- **Not for**: formatting-only rules (use formatter), purely structural static checks (use linter), or fully-automated large-scale batch audits (use dedicated pipeline).

## Inputs (Required)

- **Coding policies / standards** (Markdown recommended)
  - Each rule should be **one checkable statement**.
  - If the rules are subjective, include examples of OK/NG to reduce “要確認”.
- **Source code with line numbers (1-indexed)**  
  Reporting must cite line ranges (e.g., `L45-L50`).

## Output (Required)

Per policy, output exactly one of:

- **OK**: no issues for that policy
- **NG**: clear violation (must include evidence and a concrete fix)
- **要確認**: ambiguous / context missing (must state what context is needed)

Use the table format defined in `assets/audit_prompt.md`.

## Core Concepts

1.  **Judgment-based Auditing**: Focuses on rules requiring contextual understanding (e.g., naming conventions, architectural alignment, logic clarity).
2.  **Rule-by-Rule Evaluation**: To ensure high precision, each coding policy is evaluated individually against the code.
3.  **Human-in-the-Loop**: Flagging ambiguous cases with "Requires Review" (要確認) to focus human effort where it's most needed.

## Instructions

1.  **Gather Inputs**:
    - Obtain the coding policies/standards (Markdown or Excel/CSV converted to Markdown).
    - Obtain the source code files to be audited.
2.  **Add Line Numbers**: Ensure the source code has line numbers (1-indexed) to allow precise reporting of violations.
    - Example (macOS/Linux): `nl -ba path/to/file` or `nl -ba path/to/file | sed -n '1,200p'`
3.  **Handle Large Files (Chunking Strategy)**:
    - For files exceeding 300 lines, split into logical chunks (e.g., by class, function, or module).
    - Use `sed -n 'START,ENDp'` to extract specific line ranges: `nl -ba file.java | sed -n '1,300p'`
    - Audit each chunk separately, then consolidate findings.
    - Maintain overlap (10-20 lines) between chunks to avoid missing violations at boundaries.
4.  **Iterative Audit**: For each policy in the coding standards:
    - Apply the `audit_prompt.md` to evaluate the code specifically against that single policy.
    - Identify violations, citing the specific line numbers and providing the rationale.
5.  **Categorize Findings**:
    - **Violated (NG)**: Clear violation of the policy.
    - **Requires Review (要確認)**: Ambiguous implementation or context-dependent logic that requires human judgment.
    - **OK**: Compliant with the policy.
6.  **Generate Report**: Compile the findings into a consolidated report including violations, rationales, and suggested fixes.

## References

For detailed information on judgment criteria, see:
- [judgement_criteria.md](./references/judgement_criteria.md)
- [comparison_report_ja.md](./references/comparison_report_ja.md)

## Execution

Use the following templates to perform the analysis:
- [audit_prompt.md](./assets/audit_prompt.md)
