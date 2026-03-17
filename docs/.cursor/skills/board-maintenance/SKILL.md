---
name: board-maintenance
description: Updates markdown board items using the project lifecycle and promotion rules. Use when a stage artifact is created, reviewed, approved, or promoted to the next board. Ensures evidence-based transitions and correct downstream creation. Follows .cursor/prompts/board-update.md and docs/project/standards.md.
---

# Board Maintenance

## When to use
- A stage artifact was just created, reviewed, or approved and the board must reflect the new status.
- A human approved an item in READY_FOR_HUMAN_APPROVAL and the board must move to APPROVED.
- An item was rejected with comments and the board must show CHANGES_REQUESTED and upstream impact.
- An approved item must be promoted to the next board (e.g. BR → features, UI → backend handoff).
- Trigger source or approval mode or Notes must be updated for auditability.

## Required inputs
- **Board name** (e.g. `boards/business-requirements.md`, `boards/ui-build.md`).
- **Item ID** (e.g. BR-001, UI-003).
- **Current status** (exact value from the board).
- **Requested or evidence-based new status.**
- **Evidence** for the transition: review output (disposition, scores), human approval note (who/when), or merge/CI result where completion depends on it.
- **Approval mode** for this item (HUMAN_REQUIRED or AUTO_APPROVE_ALLOWED).
- **Milestone human gate or blocking dependency** (e.g. "Backend blocked until UI-001 APPROVED") if relevant.
- **Trigger source** (direct run, automation, human) when it affects the change.

## Valid transitions and evidence
- **TODO → IN_PROGRESS:** Work started. Evidence: assignment or intent; optional link to draft/branch.
- **IN_PROGRESS → NEEDS_REVIEW / IN_REVIEW:** Artifact ready for review. Evidence: link to artifact or review request.
- **IN_REVIEW / NEEDS_REVIEW → CHANGES_REQUESTED:** Review found blockers or required edits. Evidence: review summary or link. If human rejected with comments: record in Notes and list upstream artifacts to revise.
- **IN_REVIEW / NEEDS_REVIEW → READY_FOR_HUMAN_APPROVAL:** Review passed; item is HUMAN_REQUIRED. Evidence: review disposition and scores meeting threshold.
- **IN_REVIEW / NEEDS_REVIEW → APPROVED:** Only if item is AUTO_APPROVE_ALLOWED and review passed. Evidence: review disposition and explicit approval-mode check.
- **READY_FOR_HUMAN_APPROVAL → APPROVED:** Human approved. Evidence: approver name/date or explicit approval note. Do not set from automation without that evidence.
- **APPROVED → DONE (or next board):** Exit criteria met. For code/merge-dependent work, require merge/CI evidence before DONE. When promoting, create downstream row(s) with status TODO and link to this item.
- **Any → CHANGES_REQUESTED:** Human rejection or rework required. Add rejection summary and upstream artifacts to revise in Notes.

## Workflow
1. **Identify** the correct board file and item ID. If the item does not exist or ID is ambiguous, stop and clarify; do not create duplicate or mislinked rows.
2. **Verify** current status on the board matches what you expect. If not, note the discrepancy before proposing an update.
3. **Check** that the requested transition is valid and that **evidence** for it exists (see Valid transitions above). If evidence is missing (e.g. APPROVED without human approval for HUMAN_REQUIRED), do not perform the transition; instead recommend obtaining the evidence or state what is missing.
4. **Confirm** approval mode and milestone gates. Do not move to APPROVED for HUMAN_REQUIRED without human approval evidence. Do not create downstream rows for stages blocked by a milestone gate until that gate is APPROVED.
5. **Confirm** exit criteria are satisfied for promotion. Do not mark DONE if completion depends on merge/CI and that evidence is not present.
6. **Update** the board row: Status, Notes (rationale, rework links, upstream impact, trigger), and any Owner/Reviewer/Approval Mode/Trigger Source fields per the board’s Item Structure. Preserve other columns; do not drop required columns.
7. **If promoting:** Create the downstream board entry (e.g. in `boards/features.md` or `boards/ui-build.md`) with status TODO, link to this item, and carry Approval Mode and milestone-gate notes from the plan or parent. Create one row per downstream item; do not create downstream rows when a milestone gate is still blocking.
8. **If rejected:** Set status to CHANGES_REQUESTED; in Notes record the rejection and list upstream artifacts that must be revised. Do not leave in READY_FOR_HUMAN_APPROVAL or APPROVED.

## Required output
- **Updated board entry:** Full row(s) with all columns defined in the board’s Item Structure (ID, Title/Feature, Status, Owner, Reviewer, Approval Mode, Trigger Source, Inputs, Output/Exit Criteria, Notes, Promotes To, etc.).
- **Short change note:** Why this status, on what evidence.
- **Promotion decision:** "Promote to [board] as [new item ID]" or "No promotion; [reason]" or "Upstream items to revise: [list]."
- **Upstream/sibling items to update:** If rejection or milestone-gate change affects other items, list them; otherwise "None."

## Required checks (validation)
- Review was completed if the item is leaving NEEDS_REVIEW or IN_REVIEW.
- Human approval evidence exists if the item is moving to APPROVED and approval mode is HUMAN_REQUIRED.
- Direct APPROVED is used only when the item is explicitly AUTO_APPROVE_ALLOWED and review evidence exists.
- Promotion never skips lifecycle states (e.g. do not go from IN_PROGRESS to APPROVED).
- Do not mark DONE before merge/CI evidence when the stage requires it.
- Automation-triggered suggestions are not treated as authoritative approvals unless the configured approval mode explicitly allows it.
- Do not bypass a milestone human gate (e.g. do not create backend row when UI readiness gate is not yet APPROVED).

## References
- Prompt (transitions, evidence): `.cursor/prompts/board-update.md`.
- Delivery state model and promotion rules: `docs/project/standards.md`.
- Board schemas: each `boards/*.md` Item Structure table.
- Rules: `.cursor/rules/project-operating-model.mdc`, `.cursor/rules/approval-and-rework.mdc`.

## Example
**Before:** BR-001 | Outfit Recommendations | IN_REVIEW | ... | READY_FOR_HUMAN_APPROVAL | Notes: Review passed; awaiting human approval.

**Evidence:** Human approval recorded (e.g. "Approved by [name], [date]").

**After:** BR-001 | Outfit Recommendations | APPROVED | ... | APPROVED | Notes: Approved by [name/date]. Promotes to features board → F-001.

**Downstream:** Create row in `boards/features.md`: F-001 | [title] | TODO | ... | link to BR-001, Approval Mode and milestone-gate notes from BR.
