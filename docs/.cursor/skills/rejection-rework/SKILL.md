---
name: rejection-rework
description: Incorporates human rejection comments into the current artifact and any upstream requirements, plans, or dependency notes. Use when a board item was moved to CHANGES_REQUESTED after human rejection and the agent must rework the artifact and propagate feedback. Never self-approve; leave in CHANGES_REQUESTED until the next review. Follows .cursor/rules/approval-and-rework.mdc.
---

# Rejection Rework

## When to use
- A **human reviewer rejected** an item and left comments (in board Notes, review output, or PR feedback).
- The board item is in **CHANGES_REQUESTED** and the comments are recorded or available.
- The next agent pass must **address every comment** in the current artifact and **update upstream artifacts** when comments invalidate assumptions.
- Do **not** use this skill to approve or promote the item; use it only to perform the rework. After rework, a new review pass (or human) must decide promotion.

## Required inputs
- **Rejection comments:** Full text from board Notes, review output, or PR. If comments are missing or unclear, request them before reworking.
- **Current artifact:** The artifact that was rejected (BR, feature breakdown, architecture, plan, UI/backend/integration deliverable, or QA artifact). Full content or path.
- **Board item ID** and current status (must be CHANGES_REQUESTED).
- **Upstream artifacts:** Linked BR, feature item, architecture, implementation plan, or dependency notes so you can identify what must be updated when comments invalidate assumptions.

## Workflow
1. **Read** all rejection comments. List them explicitly so nothing is missed. If any comment is ambiguous, note it and address the best interpretation; do not skip.
2. **Map** each comment to the **current artifact:** which sections or elements must change so the comment is fully satisfied. Differentiate: (a) change in this artifact only, (b) change here and in upstream (comment invalidates upstream assumption).
3. **Update the current artifact** so it fully addresses every comment. Do not only summarize or acknowledge; make concrete edits. If a comment is deferred (e.g. out of scope for this stage), state the rationale explicitly in the artifact or Notes.
4. **Identify upstream impact:** For any comment that invalidates assumptions in requirements, plan, or dependency notes, list the affected artifacts (e.g. BR-001, implementation-plan section 2.1). For each: what assumption changed and what update is needed (or apply the update if that artifact is in scope).
5. **Apply upstream updates** when in scope: edit the upstream artifact(s) to reflect the new assumptions. When not in scope, produce a clear list: artifact (path or ID), what must be revised, and why. Add this list to board Notes so the next run or human can perform the update.
6. **Update board Notes:** Record that rework was done; list which upstream artifacts were updated or must be updated (with item IDs or paths). Do not remove or soften the rejection summary; add the rework outcome.
7. **Leave status as CHANGES_REQUESTED.** Do not set READY_FOR_HUMAN_APPROVAL or APPROVED. Do not recommend promotion from this run. Only a **new review pass** or human can move the item after rework. State explicitly in output: "Item remains in CHANGES_REQUESTED until the next review."

## Required output (complete)
- **Revised current artifact:** Full updated content or clear diff/instructions (section-by-section changes). Every rejection comment must be addressed or explicitly deferred with rationale.
- **Upstream impact list:** For each affected upstream artifact: path or board item ID, what changed (assumption/requirement), and what was done (updated) or what must be done (if out of scope). Empty list only when no comment invalidated upstream.
- **Updated board Notes:** Rework completed; list of upstream artifacts updated or to be revised; no removal of rejection context.
- **Explicit statement:** "Item remains in CHANGES_REQUESTED until the next review. Do not self-approve."

## Validation
- **Every** rejection comment is addressed in the artifact or explicitly deferred with rationale. Do not leave any comment unaddressed.
- Do not remove or soften requirements or scope that the human asked for. If the human said "limit to PDP and cart," the artifact must reflect that limit; do not keep broader scope.
- Do **not** mark the item READY_FOR_HUMAN_APPROVAL or APPROVED. Do not recommend promotion. Only a review pass or human can do that after rework.
- Upstream artifacts that were invalidated by the comments are either updated in this run or clearly listed for revision with concrete change description.

## References
- Rule: `.cursor/rules/approval-and-rework.mdc`.
- Review rubrics (rejection comment incorporation): `docs/project/review-rubrics.md`.
- Board maintenance (recording CHANGES_REQUESTED and upstream impact): `.cursor/skills/board-maintenance/SKILL.md`.

## Example (summary)
- **Comment:** "Scope of RTW recommendations is too broad; limit to PDP and cart."
- **Current artifact:** Implementation plan or UI checklist.
- **Action:** Narrow scope in the plan/checklist to PDP and cart; add explicit out-of-scope note for other surfaces. If the BR says "all surfaces," add to upstream impact list: "BR-001: Update scope boundaries to PDP and cart only; out of scope: homepage, email for v1." Update board Notes: "Rework done. Upstream: BR-001 must be updated per rejection (scope to PDP and cart). Item remains in CHANGES_REQUESTED until next review."
- **Status:** Leave CHANGES_REQUESTED. Do not recommend READY_FOR_HUMAN_APPROVAL or APPROVED.
