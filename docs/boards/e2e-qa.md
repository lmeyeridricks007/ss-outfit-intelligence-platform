# E2E QA Board

## Purpose
Track end-to-end QA items derived from approved UI, backend, and integration build work. QA items validate scenarios across the stack and promote to release/done when coverage and quality criteria are met. This is the terminal stage—no downstream board.

## Item Structure
| Field | Description |
|-------|--------------|
| QA ID | QA execution item identifier (e.g. QA-001, QA-002) |
| Upstream | Source build item(s) or plan (UI ID, BE ID, INT ID, or Plan ID) |
| Feature | Feature or capability name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — release/done typically requires human approval |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, build promotion, or schedule-assisted pickup |
| Output | Test plan, scenario checklist, or evidence summary |
| Exit Criteria | Conditions for release/done |
| Notes | Defect status, environment assumptions, traceability, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and executes the QA plan; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** Human approval is mandatory before marking a QA item DONE or releasing. For items with Approval Mode `HUMAN_REQUIRED`, a named human must approve before status moves to APPROVED/DONE. If QA completion depends on merged code or CI results, GitHub Actions or equivalent deterministic checks should be part of the final evidence path.

## Trigger Guidance
- QA items are created when UI, backend, or integration build items are APPROVED and promoted to this board (from `boards/ui-build.md`, `boards/backend-build.md`, or `boards/integration-build.md`).
- Cursor Automations may suggest QA pickup when build items are approved; automation may run checks and surface evidence but should not mark release/done without human approval and, where applicable, merge/CI evidence.

## Promotion Rules
- **Promotes to:** Release / done. There is no downstream board; when status is APPROVED and exit criteria are met, the item may move to DONE and be considered released or done for that scope.
- **Exit criteria:** QA item traces back to approved requirements and implementation plans; scenario coverage includes happy path, fallback, error handling, and telemetry validation; no open critical defects (block approval until resolved or accepted); review thresholds met per `docs/project/review-rubrics.md`; human approval recorded before DONE. If completion depends on merged code or CI, require GitHub Actions or equivalent evidence before DONE.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary and any defect or coverage gaps in Notes. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED/DONE without explicit human approval evidence.

---
## Current Items

| QA ID | Upstream | Feature | Status | Approval Mode | Owner | Reviewer | Trigger Source | Output | Exit Criteria | Notes |
|-------|----------|---------|--------|----------------|-------|----------|----------------|--------|---------------|-------|
| *(none yet)* | — | — | — | — | — | — | — | — | — | Add rows when UI, backend, or integration items are promoted to QA. |
