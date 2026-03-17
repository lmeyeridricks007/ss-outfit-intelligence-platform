# Business Requirements Board

## Purpose
Track feature requests as they are translated into business requirements and approved for feature breakdown work. BR items promote to the features board.

## Item Structure
| Field | Description |
|-------|--------------|
| BR ID | Requirement item identifier (e.g. BR-001, BR-002) |
| Feature | Requested capability or feature area |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, issue automation, or schedule-assisted pickup |
| Inputs | Intake sources and upstream context |
| Output | Business requirement artifact or summary (path or link) |
| Exit Criteria | Conditions for promotion to features |
| Notes | Rejection summary, upstream impact, or milestone-gate notes |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the BR artifact; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human must approve before status moves to APPROVED and the item may promote to `features.md`.

## Trigger Guidance
- Most new items should begin with a GitHub issue or structured intake request.
- A Cursor Automation may trigger the Request Intake Agent or Business Requirements Agent when a new issue is created or labeled for intake.
- Automation may draft the initial requirement artifact and suggest a board entry; it does not set APPROVED without evidence and the configured approval path.

## Promotion Rules
- **Promotes to:** `boards/features.md`. When status is APPROVED, create one or more feature rows on the features board with status TODO and link to this BR (e.g. in Notes or Inputs).
- **Exit criteria:** Scope and value approved; BR artifact complete and reviewed; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary and upstream artifacts to revise in Notes. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| BR ID | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
|-------|---------|--------|-------|----------|----------------|----------------|--------|--------|---------------|-------|-------------|
| BR-001 | Outfit and complete-look recommendations | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Complete-look and cross-sell on PDP, cart, inspiration for RTW and CM. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-002 | Data ingestion and identity | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Catalog, behavioral and context data ingestion; identity resolution across channels. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-003 | Customer profile and style signals | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Style profile from orders, browsing, visits; personal and intent-aware recommendations. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-004 | Product and outfit graph | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Product and outfit graph with relationships and compatibility rules; merchandising-configurable. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-005 | Recommendation strategies and algorithms | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Curated, rule-based, and AI/ML strategies; hybrid ranking and context-aware filtering. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-006 | Merchandising control and governance | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Look and rule authoring; pinning, suppression, constraints; approval and audit. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-007 | Delivery API and channel activation | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Delivery API for web, email, clienteling; placement, trace ID, channel activation. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-008 | Email and CRM recommendation payloads | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Recommendation payloads for email/CRM campaigns; audience, region, availability. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-009 | In-store clienteling recommendations | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Clienteling surfaces with outfit, cross-sell, style profile; store, appointment, CM context. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-010 | Analytics and optimization | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Recommendation metrics (impression to purchase), set/trace ID; attribution and A/B support. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-011 | Admin and merchandising UI | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Admin UI for looks, rules, campaigns, strategy selection; RBAC and approval workflows. | Scope, users, success metrics defined. | | `boards/features.md` |
| BR-012 | Governance and safety | APPROVED | Business Requirements Agent | Review Agent | HUMAN_REQUIRED | Initial seed for agent pickup | `docs/project/business-requirements.md` | Brand/compliance; approval gates for high-visibility changes; privacy and consent. | Scope, users, success metrics defined. | | `boards/features.md` |
