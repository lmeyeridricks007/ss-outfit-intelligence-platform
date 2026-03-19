# Backend Build Board

## Purpose
Track backend execution items derived from approved implementation plans. Backend work items promote to the e2e-qa board when readiness criteria are met.

## Item Structure
| Field | Description |
|-------|--------------|
| BE ID | Backend execution item identifier (e.g. BE-001, BE-002) |
| Parent Plan | Source implementation plan (Plan ID or link) |
| Feature | Feature or capability name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, next-task automation, or PR-driven follow-up |
| Output | Backend task pack, checklist, or deliverable summary |
| Exit Criteria | Conditions for QA handoff |
| Notes | Milestone gates, rework links, dependency notes, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the backend build artifact; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human (e.g. engineering lead) must approve before status moves to APPROVED and the item may promote to `e2e-qa.md`. Backend items that depend on code merge must not be treated as DONE until merge-aware checks succeed.

## Trigger Guidance
- Backend items are created when an implementation plan is approved and work is fanned out to this board (e.g. from `boards/implementation-plan.md`).
- Cursor Automations may suggest backend pickup after implementation planning approval; PR-triggered review automations are appropriate for backend change review. Automation should not mark backend work DONE if code has not been merged and required checks have not passed.
- If the implementation plan defines a UI milestone human gate, backend pickup must stay blocked until that checkpoint is approved; record blocking dependency in Notes.

## Promotion Rules
- **Promotes to:** `boards/e2e-qa.md`. When status is APPROVED, create or update e2e-qa row(s) with status TODO and link to this backend item (e.g. in Notes or Parent Plan).
- **Exit criteria:** Backend item defines contracts, business logic, persistence, observability, and failure behavior; dependencies on data quality or integration feeds are explicit; interface assumptions are stable; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded. For code deliverables, merge/CI evidence is required before DONE per stage policy.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary in Notes. If comments change contracts or flow assumptions, update the linked plan or requirement notes before returning to review. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| BE ID | Parent Plan | Feature | Status | Approval Mode | Owner | Reviewer | Trigger Source | Output | Exit Criteria | Notes |
|-------|-------------|---------|--------|----------------|-------|----------|----------------|--------|---------------|-------|
| BE-001 | IMPL-001 | Outfit Recommendations | TODO | HUMAN_REQUIRED | Backend Build Agent | Review Agent | Next-task automation suggestion + direct run | Recommendation service checklist | Candidate generation, ranking, fallback, and logs defined | Blocked until UI-001 milestone approval exists |
| BE-002 | IMPL-002 | Cross Sell | TODO | HUMAN_REQUIRED | Backend Build Agent | Review Agent | Direct run | Cross-sell backend checklist | Complement logic and rule hooks defined | Commercial logic remains human-gated |
| BE-003 | IMPL-003 | Occasion-Based Recommendations | TODO | AUTO_APPROVE_ALLOWED | Backend Build Agent | Review Agent | Direct run | Occasion context backend checklist | Occasion inference and ranking inputs defined | No upstream milestone gate configured yet |
| BE-004 | IMPL-004 | Customer Style Profile | IN_PROGRESS | HUMAN_REQUIRED | Backend Build Agent | Review Agent | Direct run | Style profile service checklist | Profile schema, update jobs, and retrieval logic defined | Data-governance concerns require review |
| BE-005 | IMPL-005 | Recommendation API | TODO | HUMAN_REQUIRED | Backend Build Agent | Review Agent | PR-driven follow-up review | Delivery API backend checklist | Endpoint contracts, auth, and trace metadata defined | API work is human-gated |
| BE-006 | IMPL-006 | Merchandising Rule Builder | TODO | HUMAN_REQUIRED | Backend Build Agent | Review Agent | Direct run | Rule service checklist | Rule model, validation, and publish lifecycle defined | Approval-sensitive admin behavior |
| BE-007 | IMPL-007 | Look Editor | TODO | AUTO_APPROVE_ALLOWED | Backend Build Agent | Review Agent | Next-task automation suggestion + direct run | Look persistence checklist | Look model, versioning, and preview support defined | Can proceed autonomously while gate remains open |
| BE-008 | IMPL-008 | Recommendation Analytics Dashboard | TODO | AUTO_APPROVE_ALLOWED | Backend Build Agent | Review Agent | Schedule-assisted suggestion | Analytics API checklist | KPI aggregation contracts and query rules defined | Internal analytics capability can iterate faster |
