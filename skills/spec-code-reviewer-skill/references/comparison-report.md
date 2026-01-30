# Comparison Report: `spec-code-reviewer-skill` vs. External Tool

This report compares the `spec-code-reviewer-skill` with the `elvezjp/spec-code-ai-reviewer` GitHub repository to clarify capabilities and differences.

## 1. Overview of Comparison

The external GitHub tool is a **specialized web application** designed for batch processing of Japanese Excel design documents. In contrast, this **Skill** is an **agentic assistant** that provides interactive, deep, and actionable reviews directly within the development workflow.

| Feature | `elvezjp/spec-code-ai-reviewer` | `spec-code-reviewer-skill` (This Skill) |
| :--- | :--- | :--- |
| **Core Concept** | Batch processing tool (Web App) | Interactive AI Partner (Agent) |
| **Primary Input** | **Excel (.xlsx)** | **Markdown / Source Code / Repository** |
| **Review Method** | Fixed prompt on set files | Adaptive exploration and reasoning |
| **Actionability** | Report Generation only | Report + **Direct Code Correction** |
| **Context Awareness** | Limited to uploaded files | Repository-wide awareness (configs, libs, etc.) |

## 2. Key Strengths of This Skill

### 1) "Why" and Reasoning
While the GitHub tool focuses on identifying "differences," this skill analyzes the **intent**. It can identify not just where the code differs, but *why* it might be wrong or how the specification might be ambiguous. It can ask clarifying questions to the user.

### 2) Autonomous Exploration
The skill can autonomously navigate the repository. If a specification refers to a data model defined in another file, the agent will go and read that file to ensure consistency, whereas a batch tool typically requires all context to be pre-loaded.

### 3) Human-in-the-Loop Integration
As documented in [human-in-the-loop.md](./human-in-the-loop.md), the skill works as a collaborator. It doesn't just output a static report; it engages in a dialogue to refine its findings based on human feedback.

### 4) Instant Implementation
Beyond reporting, the skill can immediately propose and apply fixes using the AI assistant's editing tools, effectively closing the loop between "finding a bug" and "fixing it."

## 3. Limitations & Mitigations

*   **Excel Parsing**: The GitHub tool has a dedicated engine (`excel2md`) for complex merged cells in Excel.
    *   *Mitigation*: For highest accuracy, users should export Excel sheets to Markdown or CSV before review.
*   **Massive Batching**: For processing hundreds of files simultaneously, a dedicated server/web app is more efficient.
    *   *Mitigation*: This skill is optimized for "feature-level" or "module-level" deep reviews where quality and context matter most.

## 4. Conclusion

This skill offers **equal or superior review depth** compared to the target tool by leveraging the interactive nature of AI agents. It is best suited for developers who want a partner that understands the code's context and can assist in the actual resolution of identified issues.
