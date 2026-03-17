# Board Update Prompt

## Objective
Update the appropriate markdown board after stage work, review, or approval. Only apply status transitions that are valid and supported by evidence; never skip lifecycle states or bypass approval gates.

## Required Inputs
- Board name (e.g. `boards/business-requirements.md`, `boards/ui-build.md`)
- Item ID (e.g. BR-001, UI-003)
- Current status (exact value from the board)
- Requested or recommended new status
- Evidence for the status change (review output, human approval note, merge/CI result)
- Approval mode for this item (`HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED`)
- Any milestone human gate or blocking dependency (e.g. "Backend blocked until UI-001 APPROVED")
- Next-stage impact (downstream board and item to create or update)
- Trigger source (direct run, automation, human)

## Valid transitions and required evidence
- **TODO → IN_PROGRESS:** Work has started; no evidence beyond assignment or intent. Optional: link to draft artifact or branch.
- **IN_PROGRESS → NEEDS_REVIEW / IN_REVIEW:** Artifact is ready for review; link or attach review request or artifact path.
- **IN_REVIEW / NEEDS_REVIEW → CHANGES_REQUESTED:** Review completed with blocking issues or required edits; note review summary or link. If human rejected with comments, record the rejection and list upstream artifacts to revise in Notes.
- **IN_REVIEW / NEEDS_REVIEW → READY_FOR_HUMAN_APPROVAL:** Review passed (scores and thresholds met); item is HUMAN_REQUIRED. Evidence: review disposition and scores.
- **IN_REVIEW / NEEDS_REVIEW → APPROVED:** Only if item is AUTO_APPROVE_ALLOWED and review passed. Evidence: review disposition and explicit approval-mode check.
- **READY_FOR_HUMAN_APPROVAL → APPROVED:** Human approval given. Evidence: approver name/date or explicit approval note; do not set from automation without that evidence.
- **APPROVED → DONE (or next board):** Exit criteria met; for code/merge-dependent work, require merge/CI evidence before DONE. When promoting to next board, create the downstream row with status TODO and link to this item.
- **Any → CHANGES_REQUESTED:** Human rejection or rework required; add rejection summary and upstream impact to Notes.

## When to create a downstream row
- When status moves to APPROVED and the stage has a defined "promotes to" (e.g. BR → features, UI → backend handoff). Create one row per downstream item; set status TODO; set Approval Mode and milestone-gate notes from the plan or parent.
- Do not create downstream rows for stages that are blocked by a milestone gate until that gate is APPROVED.

## Required Output
- Updated board row (all columns: ID, Title, Status, Owner, Reviewer, Approval Mode, Notes, etc. per board template).
- Short change note (why this status, on what evidence).
- Promotion decision: "Promote to [board] as [new item ID]" or "No promotion; [reason]" or "Upstream items to revise: [list]."
- Any upstream or sibling items that require updates due to rejection comments or milestone-gate changes.

## Quality Rules
- Never promote without evidence that exit criteria were met (review passed, human approved, or merge/CI as required).
- Do not skip lifecycle states (e.g. do not go from IN_PROGRESS to APPROVED).
- Keep status notes specific and traceable (who, when, what evidence).
- If the update came from automation, say so in the change note.
- Do not mark APPROVED unless the item's approval mode allows it and the required approval-path evidence exists (review + human approval for HUMAN_REQUIRED; review only for AUTO_APPROVE_ALLOWED when configured).
- Do not mark DONE unless merge-aware or completion evidence exists where the stage requires it.
- If a human rejection invalidated upstream artifacts, set status to CHANGES_REQUESTED and list in Notes which artifacts must be revised.

## Output template
```markdown
## Board update: [Board name] — [Item ID]

**Current status:** [e.g. IN_REVIEW]
**New status:** [e.g. READY_FOR_HUMAN_APPROVAL]
**Evidence:** [Review passed; scores above threshold; approval mode HUMAN_REQUIRED]

**Change note:** [One-line rationale]

**Promotion decision:** [Promote to next board / Create downstream item / No promotion — record upstream items to revise]

**Upstream/sibling items to update (if rejection or gate change):** [List or "None"]

**Updated row (excerpt):**
| ID | Title | Status | Owner | Reviewer | Approval Mode | Notes |
|----|-------|--------|-------|----------|----------------|-------|
| ... | ... | [new status] | ... | ... | ... | [note] |
```
