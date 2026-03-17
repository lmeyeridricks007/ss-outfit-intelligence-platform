# Automation PR Review Prompt

## Objective
Run a structured review when a pull request is opened or updated. Produce findings and suggested board impact only; do not grant approval or mark items DONE. Use `docs/project/review-rubrics.md` for severity and disposition logic.

## Required Inputs
- Trigger source: "PR-opened" or "PR-updated" (state in output).
- PR title, description, and list of changed files (or diff summary).
- Changed artifacts or implementation context (which board item or stage this PR relates to, if known).
- Relevant standards: `docs/project/standards.md`, `docs/project/data-standards.md`, review rubrics.
- Board item approval mode and milestone gates (if available from board or plan).

## Section-by-section guidance
- **Findings by severity:** Critical (blocking: e.g. wrong approval path, missing required contract), Major (should fix before merge: e.g. missing error handling, inconsistent terminology), Minor (nice to fix: e.g. style, docs). For each: short title, location or file/area, and recommendation. Tie to PR scope; do not invent issues outside the diff.
- **Missing tests or dependency concerns:** List test gaps (e.g. "No test for empty recommendation response") and dependency risks (e.g. "Assumes API X is available; no fallback").
- **Standards alignment:** Reference project standards: terminology (glossary), data/event schema (data-standards), lifecycle (no APPROVED without evidence). List specific violations or "No issues found."
- **Recommended board impact:** E.g. "Move UI-003 to IN_REVIEW" or "Do not change status; review found blocking issues." Never recommend APPROVED unless board item is AUTO_APPROVE_ALLOWED and review criteria are fully met; never recommend DONE.
- **Approval mode and human approval:** State: "Item is HUMAN_REQUIRED → human approval still required after review" or "Item is AUTO_APPROVE_ALLOWED → review may support APPROVED if criteria met; do not set by automation without explicit config."
- **Rejection comment propagation:** If this review is following up on a prior human rejection, or if findings imply requirements/plan changes: "Propagate to [list artifacts], e.g. BR-001 scope, implementation-plan milestone gate."

## Automation constraints
- Focus on findings and evidence; do not "grant" approval in narrative.
- Do not mark a board item DONE based on review alone (merge/CI may be required).
- Do not imply APPROVED unless board context explicitly shows AUTO_APPROVE_ALLOWED and review thresholds are met.
- Do not bypass a milestone human gate (e.g. UI review before backend); if the PR is backend and UI gate is not approved, note as blocker.
- If PR context is insufficient (no link to board item, no description), request clarification; do not guess scope.
- Keep all feedback tied to the actual PR (files, behavior, contracts); no generic advice.

## Required Output
- Findings (by severity), missing tests/dependency concerns, standards alignment, recommended board impact, approval-mode statement, rejection-propagation note if applicable.

## Output template
```markdown
## PR review: [PR title]

**Trigger:** PR-opened / PR-updated automation

**Findings (by severity):** [Critical / Major / Minor — list]

**Missing tests or dependency concerns:** [List or "None"]

**Standards alignment:** [Issues or "OK"]

**Recommended board impact:** [e.g. Move UI-003 to IN_REVIEW; do not set APPROVED]

**Approval mode:** [Item is HUMAN_REQUIRED → human approval still required | AUTO_APPROVE_ALLOWED → review may recommend APPROVED if criteria met]

**Rejection comment propagation:** [If previous human rejection applies: list upstream artifacts to update; otherwise "N/A"]
```
