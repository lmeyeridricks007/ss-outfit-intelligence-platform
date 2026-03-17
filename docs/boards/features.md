# Feature Breakdown Board

## Purpose
Track feature breakdown items: decomposition of approved business requirements into features, sub-features, dependencies, and implementation tracks. Feature items promote to the technical-architecture board when decomposition is sufficient for architecture work.

## Item Structure
| Field | Description |
|-------|--------------|
| Feature ID | Feature identifier (e.g. F1–F26 per `docs/project/feature-list.md`) |
| Title | Feature or capability name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, board pickup, or promotion from BR board |
| Upstream BR | BR ID(s) or link to approved business requirement(s) |
| Sub-features / Dependencies | Sub-features, shared capabilities, and dependencies called out explicitly |
| Output | Feature spec or artifact path (e.g. `docs/features/<feature>.md`) |
| Exit Criteria | Conditions for promotion to technical-architecture |
| Notes | Rejection summary, upstream impact, or milestone-gate notes |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the feature breakdown and spec; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human must approve before status moves to APPROVED and the item may promote to `technical-architecture.md`.

## Trigger Guidance
- Feature breakdown work begins when one or more BRs are APPROVED and promoted to this board (new rows with status TODO).
- Every feature must identify sub-features, dependencies, and implementation tracks; shared capabilities (e.g. data ingestion, API dependencies) must be called out explicitly.
- Automation may suggest IN_PROGRESS or NEEDS_REVIEW, but must not imply architecture handoff without approved upstream evidence and meeting exit criteria.

## Promotion Rules
- **Promotes to:** `boards/technical-architecture.md`. When status is APPROVED, create one or more architecture rows on the technical-architecture board with status TODO and link to this feature (e.g. in Notes or Output).
- **Exit criteria:** Decomposition sufficient for technical architecture; sub-features, dependencies, and shared capabilities explicit; feature spec complete and reviewed; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary and upstream artifacts to revise in Notes. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| FEAT ID | Parent BR | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Output | Exit Criteria | Notes | Promotes To |
|---------|-----------|---------|--------|-------|----------|----------------|----------------|--------|---------------|-------|-------------|
| FEAT-001 | BR-002 | Catalog and inventory ingestion | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-002 | BR-002 | Behavioral event ingestion | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-003 | BR-002 | Context data ingestion | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-004 | BR-002 | Identity resolution | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-005 | BR-004 | Product graph | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-006 | BR-004 | Outfit graph and look store | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-007 | BR-003 | Customer profile service | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-008 | BR-005 | Context engine | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-009 | BR-005 | Recommendation engine core | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-010 | BR-006 | Merchandising rules engine | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-011 | BR-007 | Delivery API | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-012 | BR-010 | Recommendation telemetry | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-013 | BR-001 | Webstore recommendation widgets | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-014 | BR-008 | Email CRM recommendation payloads | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-015 | BR-010 | Core analytics and reporting | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-016 | BR-011 | Admin look editor | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-017 | BR-006 | Admin rule builder | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-018 | BR-011 | Admin placement and campaign config | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-019 | BR-012 | Approval workflows and audit | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-020 | BR-012 | Privacy and consent enforcement | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-021 | BR-009 | Clienteling integration | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-022 | BR-010 | AB and experimentation | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-023 | BR-001 | Customer-facing look builder | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
| FEAT-024 | BR-010 | Performance and personalization tuning | APPROVED | Feature Breakdown Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | Feature breakdown / ready for architecture | Sub-features and dependencies mapped | Agent pickup: generate architecture then implementation plan | `boards/technical-architecture.md` |
