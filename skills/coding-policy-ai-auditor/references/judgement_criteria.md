# Judgment-based Auditing Criteria

This document defines what constitutes "judgment-based" rules and how they should be handled by the AI Auditor.

## What are Judgment-based Rules?
Standard static analysis (Checkstyle, PMD) excels at structural rules (e.g., "no trailing whitespace", "max line length"). 
**Judgment-based rules** require semantic understanding:
- **Meaningful Naming**: Does the variable name `d` actually represent `daysSinceLastLogin` in this context?
- **Intent Alignment**: Is the method `calculateTax` actually calculating tax based on the jurisdictional rules defined in the business logic?
- **Architectural Policy**: Is a Controller directly accessing the Database instead of going through a Service layer?

## Evaluation States

### 1. OK (適合)
The code clearly follows the intent and the letter of the policy.

### 2. Violated (NG/不適合)
The code clearly contradicts the policy. 
- Example: Policy says "Do not use magic numbers", but the code has `if (status == 5)`.

### 3. Requires Review (要確認)
The rule is subjective, or the AI lacks sufficient context to make a definitive call.
- Example: Policy says "Names should be intuitive". The AI thinks `tempVal` is slightly vague but not explicitly wrong.
- Action: Human auditors focus their energy here.

## Tips for Refinement
- When a "Requires Review" is triggered, consider if the **Policy** needs to be more specific or if the **Prompt** needs additional examples.
