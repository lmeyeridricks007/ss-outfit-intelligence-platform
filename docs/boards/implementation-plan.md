# Implementation Plan Board

## Purpose
Track implementation plan items that sequence execution across UI, backend, and integration build boards and feed E2E QA. Plans depend on approved technical architecture and project standards (`boards/technical-architecture.md`) and align with `docs/project/roadmap.md`. Plan items promote to ui-build, backend-build, integration-build, and e2e-qa.

## Item Structure
| Field | Description |
|-------|--------------|
| Plan ID | Plan item identifier (e.g. IP-001, IP-002) |
| Title | Plan or deliverable name (e.g. Phase 1 implementation plan) |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, architecture promotion, or schedule-assisted pickup |
| Upstream | TA ID(s) or link to approved architecture/standards item(s) |
| Output | Plan artifact path or summary (e.g. `docs/boards/implementation-plan.md` or phase plan doc) |
| Exit Criteria | Conditions for promotion to build and QA boards |
| Notes | Dependencies, critical path, milestone gates, downstream fan-out, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the implementation plan; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human must approve before status moves to APPROVED and the item may fan out to build/QA boards.

## Trigger Guidance
- Plan work begins when technical architecture (and relevant standards) are approved and promoted from the technical-architecture board.
- Work must be split into execution tracks with explicit dependencies; sequence, critical path, and parallelizable work must be clear. Align with `docs/project/roadmap.md` (phases, milestone gates) for sequencing and readiness.
- Fan-out into downstream build boards (ui-build, backend-build, integration-build) and e2e-qa should remain explicit and auditable. If downstream row creation is automated, it must depend on approved upstream evidence and preferably merge-aware or explicitly recorded state.

## Promotion Rules
- **Promotes to:** `boards/ui-build.md`, `boards/backend-build.md`, `boards/integration-build.md`, `boards/e2e-qa.md`. When status is APPROVED, create or update rows on the relevant build and QA boards (status TODO) and link back to this plan item (e.g. in Notes or Upstream). Which boards get rows depends on the plan (UI work → ui-build; backend → backend-build; integration → integration-build; QA scenarios → e2e-qa).
- **Exit criteria:** Plan complete; execution tracks, dependencies, and critical path explicit; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded. Plans should align with approved (or READY_FOR_HUMAN_APPROVAL) architecture and standards; milestone human gates (e.g. UI readiness before backend) must be reflected in the plan and block downstream promotion until the gate is passed.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary and upstream artifacts to revise in Notes. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| Plan ID | Title | Status | Approval Mode | Owner | Reviewer | Trigger Source | Upstream | Output | Exit Criteria | Notes |
|---------|-------|--------|----------------|-------|----------|----------------|----------|--------|---------------|-------|
| IP-001 | F1 catalog and inventory ingestion implementation plan | TODO | HUMAN_REQUIRED | Planning Agent | Review Agent | Architecture promotion | TA-006 | Plan artifact TBD; create from `docs/project/architecture/f1-catalog-inventory-ingestion.md` | Split connector, canonical-store, events, read-API, and operations work into executable tracks with explicit dependencies and downstream board fan-out | Backend and integration tracks are expected first; incorporate non-blocking F1 assumptions on source ownership and storage technology |
