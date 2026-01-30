# Human-in-the-Loop (HITL) Governance

AI-assisted reviews are meant to augment, not replace, human judgment.

## Principles
1. **Critical Evaluation**: Humans must critically evaluate all AI-generated findings.
2. **Final Authority**: The final decision on whether a code change is accepted remains with the human engineer.
3. **Contextualization**: AI may lack project-specific context (e.g., upcoming architectural changes). Humans must bridge this gap.

## Workflow
1. AI generates the initial consistency report.
2. Human engineer reviews the report, marking findings as "Valid", "Invalid", or "Needs Clarification".
3. Human engineer identifies any missing gaps the AI failed to catch.
4. Human engineer signs off on the final review result.
