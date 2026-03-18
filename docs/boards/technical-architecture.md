# Technical Architecture Board

## Purpose
Track architecture and standards artifacts that define system design, contracts, and cross-cutting expectations. Items include technical architecture deliverables and project standards (API, data, UI, integration) that implementation plans and build stages depend on. Architecture items promote to the implementation-plan board.

## Item Structure
| Field | Description |
|-------|--------------|
| TA ID | Architecture/standards item identifier (e.g. TA-001, TA-002) |
| Artifact | Document or deliverable name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, review automation, or schedule-assisted pickup |
| Upstream Feature | Feature ID(s) or link to approved feature(s), if feature-driven |
| Output | Artifact path or summary (e.g. `docs/project/api-standards.md`) |
| Exit Criteria | Conditions for promotion to implementation-plan |
| Notes | Dependencies, milestone gates, rework links, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Architecture / Standards agent or document owner; drafts and maintains the artifact; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human (e.g. architecture or product lead) must approve before status moves to APPROVED and the item may promote to `implementation-plan.md`.

## Trigger Guidance
- Architecture work should usually begin only after a feature item is explicitly approved and promoted from the features board.
- Cursor Automations may suggest that an item is ready for architecture, but architecture generation should usually be a direct agent run because trade-offs are high-impact.
- Standards docs (API, data, UI, integration) may be produced in parallel to support architecture and build; review per `docs/project/review-rubrics.md`.

## Promotion Rules
- **Promotes to:** `boards/implementation-plan.md`. When status is APPROVED, create or update implementation-plan row(s) with status TODO and link to this architecture item (e.g. in Notes or Output).
- **Exit criteria:** Artifact complete; contracts, boundaries, and dependencies explicit; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded. Implementation plans and build boards should reference approved (or READY_FOR_HUMAN_APPROVAL) standards as baseline; material changes to standards require review and approval per doc.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary and upstream artifacts to revise in Notes. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| TA ID | Artifact | Status | Approval Mode | Owner | Reviewer | Trigger Source | Upstream Feature | Output | Exit Criteria | Notes |
|-------|----------|--------|----------------|-------|----------|----------------|------------------|--------|---------------|-------|
| TA-001 | Project standards (lifecycle, promotion, naming) | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Standards Agent | Review Agent | Direct run | — | `docs/project/standards.md` | Review passed; human approval pending | Referenced by boards, review outputs, agent-operating-model |
| TA-002 | API standards (design, versioning, errors, auth) | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Standards Agent | Review Agent | Direct run | F11 | `docs/project/api-standards.md` | Review passed; human approval pending | Primary reference for Delivery API (F11) and channel APIs |
| TA-003 | Data standards (entities, identity, events, telemetry, privacy) | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Standards Agent | Review Agent | Direct run | F2, F4, F7, F12, F22 | `docs/project/data-standards.md` | Review passed; human approval pending | Primary reference for F2, F4, F7, F12, F22 |
| TA-004 | UI standards (patterns, accessibility, analytics events) | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Standards Agent | Review Agent | Direct run | F13–F16, F23, F25 | `docs/project/ui-standards.md` | Review passed; human approval pending | Primary reference for UI build, F13–F16, F23, F25 |
| TA-005 | Integration standards (auth, retries, idempotency) | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Standards Agent | Review Agent | Direct run | F2, F12 | `docs/project/integration-standards.md` | Review passed; human approval pending | Primary reference for F2, F12, event ingest, outbound integrations |
| TA-006 | Catalog and inventory ingestion technical architecture | READY_FOR_HUMAN_APPROVAL | HUMAN_REQUIRED | Technical Architecture Agent | Review Agent | Direct run (issue #27 context) | FEAT-001 / F1 | `docs/project/catalog-and-inventory-ingestion-technical-architecture.md` | Technical architecture drafted; review passed at 4.8 average; human approval pending | Follow-ups: confirm attach logic source of record, merchandising constraint authority, inventory latency targets before implementation-plan promotion |
