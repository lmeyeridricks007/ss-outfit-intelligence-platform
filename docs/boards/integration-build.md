# Integration Build Board

## Purpose
Track external system, channel, and dependency integration work derived from approved implementation plans. Integration work items promote to the e2e-qa board when readiness criteria are met.

## Item Structure
| Field | Description |
|-------|--------------|
| INT ID | Integration execution item identifier (e.g. INT-001, INT-002) |
| Parent Plan | Source implementation plan (Plan ID or link) |
| Feature | Feature or capability name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, next-task automation, or PR-driven follow-up |
| Output | Integration plan, checklist, or deliverable summary |
| Exit Criteria | Conditions for QA handoff |
| Notes | Milestone gates, rework links, dependency notes, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the integration build artifact; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human (e.g. technical lead or integration owner) must approve before status moves to APPROVED and the item may promote to `e2e-qa.md`. Integration completion often depends on explicit external-system or environment validation; automation may surface evidence but should not finalize approval on its own.

## Trigger Guidance
- Integration items are created when an implementation plan is approved and work is fanned out to this board (e.g. from `boards/implementation-plan.md`).
- Cursor Automations may flag integration items as ready when a plan is approved; PR review automations are appropriate for integration-related changes. If integration readiness depends on environment or external validation, automation may surface evidence but should not finalize approval on its own.

## Promotion Rules
- **Promotes to:** `boards/e2e-qa.md`. When status is APPROVED, create or update e2e-qa row(s) with status TODO and link to this integration item (e.g. in Notes or Parent Plan).
- **Exit criteria:** Integration item defines source and target systems, triggers, auth, retries, and failure handling; data freshness assumptions are explicit; testable contract and verification approach for QA; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded. For deliverables that depend on external validation or merge, evidence is required before DONE per stage policy.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary in Notes. If comments change assumptions about external behavior, update the linked plan or dependency notes before returning to review. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| INT ID | Parent Plan | Feature | Status | Approval Mode | Owner | Reviewer | Trigger Source | Output | Exit Criteria | Notes |
|--------|-------------|---------|--------|----------------|-------|----------|----------------|--------|---------------|-------|
| INT-001 | IMPL-001 | Outfit Recommendations | TODO | HUMAN_REQUIRED | Integration Build Agent | Review Agent | Next-task automation suggestion + direct run | Web and clienteling integration checklist | Consumers, payload mappings, and trace handling defined | External consumer mapping reviewed before QA |
| INT-002 | IMPL-002 | Cross Sell | TODO | HUMAN_REQUIRED | Integration Build Agent | Review Agent | Direct run | Cart and recommendation event integration checklist | Cart hooks and measurement paths defined | Revenue events need explicit review |
| INT-003 | IMPL-003 | Occasion-Based Recommendations | TODO | AUTO_APPROVE_ALLOWED | Integration Build Agent | Review Agent | Direct run | Context-provider integration checklist | Weather and calendar data integrations defined | Can iterate autonomously while gates stay open |
| INT-004 | IMPL-004 | Customer Style Profile | NEEDS_REVIEW | HUMAN_REQUIRED | Integration Build Agent | Review Agent | Schedule-assisted suggestion + direct run | Customer signal ingestion checklist | Identity feeds and profile update sources defined | Consent and data-sharing dependencies visible |
| INT-005 | IMPL-005 | Recommendation API | TODO | HUMAN_REQUIRED | Integration Build Agent | Review Agent | PR-driven follow-up review | API consumer integration checklist | Channel consumers and auth flows defined | Consumer contracts remain human-gated |
| INT-006 | IMPL-006 | Merchandising Rule Builder | TODO | HUMAN_REQUIRED | Integration Build Agent | Review Agent | Direct run | Rule publication integration checklist | Approval and publish dependencies defined | Publish path is approval-sensitive |
| INT-007 | IMPL-007 | Look Editor | TODO | AUTO_APPROVE_ALLOWED | Integration Build Agent | Review Agent | Next-task automation suggestion + direct run | Look asset integration checklist | Catalog look references and preview dependencies defined | Lower-risk internal integration path |
| INT-008 | IMPL-008 | Recommendation Analytics Dashboard | TODO | AUTO_APPROVE_ALLOWED | Integration Build Agent | Review Agent | Schedule-assisted suggestion | Metrics source integration checklist | Event feeds and analytics refresh logic defined | Reporting integrations can iterate faster |
