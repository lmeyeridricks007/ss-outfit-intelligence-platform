# Automation Issue Intake Prompt

## Objective
Handle a GitHub issue-triggered intake run safely and convert the issue into a structured project-aligned intake artifact or board suggestion. Output is always a suggestion or draft; do not assert approval or completion.

## Required Inputs
- Trigger source: "issue-created" or "issue-updated" (state explicitly in output).
- Issue title and body (full text).
- Project context: `docs/project/product-overview.md`, `docs/project/glossary.md`, roadmap or capability map if available.
- Existing related board item if one exists (to avoid duplicates; suggest update vs new row).
- Approval mode for the target stage if already known (else recommend HUMAN_REQUIRED and note as TBD).

## Section-by-section guidance
- **Intake summary:** A complete summary of what the issue is asking for, in product/business terms. Use as much detail as needed; use project terms (recommendation, look, outfit, PDP, etc.). Do not paraphrase vaguely ("user wants improvements") or truncate scope.
- **In-scope / out-of-scope:** Based on issue and project scope. If unclear, list "In scope (assumed): …" and "Out of scope (assumed): …" and add to Missing decisions.
- **Recommended feature area:** One of or combination: Recommendations (PDP, cart, email, etc.), Admin/Merchandising, Clienteling, Data/Profile, Integration, Other. Tie to a board if obvious (e.g. BR for new feature).
- **Missing decisions:** Every unresolved choice (e.g. "Which surfaces: PDP only or PDP + cart?"; "RTW only or RTW + CM?"). Ensures humans or next step can resolve.
- **Suggested board update:** Concrete: "Add row to boards/business-requirements.md: title [from issue], status TODO, Approval Mode HUMAN_REQUIRED, source [issue URL]." Do not suggest status APPROVED or DONE.
- **Next step / approval note:** "Human approval required before BR promotion" or "Governed auto-approval allowed for intake → TODO; human gate at [stage]."

## Automation constraints
- **Stop condition:** If the issue body is empty or too thin to infer scope (e.g. one word), output: "Insufficient context; request more detail from issue author" and do not suggest a board row.
- Do not mark the item APPROVED; intake only suggests TODO or IN_PROGRESS.
- Do not create or imply downstream stage completion (e.g. do not say "ready for development").
- Repo mutation: at most draft artifact in repo or suggested board edit; do not commit approval or merge.

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: do not wait for human approval before proceeding. Output the intake and suggested board update; the orchestrator will queue the next stage. Do not block on "Mark as ready."

## Required Output
- Intake summary, in/out scope, recommended feature area, missing decisions, suggested board update, explicit note on human approval vs auto-approval for next step.

## Output template
```markdown
## Intake: [Issue title]

**Trigger:** issue-created automation

**Summary:** [Structured summary of the request]

**In scope / out of scope:** [Brief assessment]

**Recommended feature area:** [e.g. Recommendations, PDP, Admin]

**Missing decisions:** [List]

**Suggested board update:** [e.g. Create BR-002 in boards/business-requirements.md, status TODO, Approval Mode HUMAN_REQUIRED]

**Next step:** [Human approval required before BR promotion | Governed auto-approval allowed for intake → TODO]
```
