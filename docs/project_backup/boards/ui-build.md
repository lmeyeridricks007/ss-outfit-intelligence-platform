# UI Build Board

## Purpose
Track UI-specific execution items derived from approved implementation plans. UI work items promote to the e2e-qa board when readiness criteria are met.

## Item Structure
| Field | Description |
|-------|--------------|
| UI ID | UI execution item identifier (e.g. UI-001, UI-002) |
| Parent Plan | Source implementation plan (Plan ID or link) |
| Feature | Feature or capability name |
| Status | Lifecycle state (see Lifecycle States) |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` — governs promotion after review |
| Owner | Owning agent or human |
| Reviewer | Review role |
| Trigger Source | Direct run, next-task automation, or PR-driven follow-up |
| Output | UI build checklist, artifact path, or deliverable summary |
| Exit Criteria | Conditions for QA handoff |
| Notes | Milestone gates, rework links, dependency notes, or rejection summary |

## Lifecycle States
`TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`

## Ownership
- **Owner:** Agent or human who drafts and maintains the UI build artifact; drives the item to NEEDS_REVIEW.
- **Reviewer:** Agent or human who performs the review pass per `docs/project/review-rubrics.md`; recommends READY_FOR_HUMAN_APPROVAL, APPROVED, or CHANGES_REQUESTED.
- **Approver:** For items with Approval Mode `HUMAN_REQUIRED`, a named human (e.g. product or design lead) must approve before status moves to APPROVED and the item may promote to `e2e-qa.md`. Final UI completion must respect the configured approval mode and, where code is involved, merged GitHub state.

## Trigger Guidance
- UI items are created when an implementation plan is approved and work is fanned out to this board (e.g. from `boards/implementation-plan.md`).
- Cursor Automations may suggest UI pickup when a plan is approved; PR review automations may trigger review passes against UI-oriented changes. Automation-triggered reviews may request changes but should not mark merged-state completion on their own.
- If UI readiness is the milestone human gate, record that clearly in Notes so backend continuation remains blocked until approval exists.

## Promotion Rules
- **Promotes to:** `boards/e2e-qa.md`. When status is APPROVED, create or update e2e-qa row(s) with status TODO and link to this UI item (e.g. in Notes or Parent Plan).
- **Exit criteria:** UI item defines surface, states, interaction flow, analytics events, and API dependencies where applicable; internal admin features include approval and audit visibility; linked backend or integration assumptions documented where applicable; review thresholds met per `docs/project/review-rubrics.md`; if HUMAN_REQUIRED, human approval recorded. For code deliverables, merge/CI evidence may be required before DONE per stage policy.
- **From REVIEW:** Average score above 4.1 with no dimension below 4 → eligible for READY_FOR_HUMAN_APPROVAL (HUMAN_REQUIRED) or APPROVED (AUTO_APPROVE_ALLOWED when configured). Average below 3.5 or any dimension ≤ 2 → CHANGES_REQUESTED.
- **Rejection:** If a human rejects with comments, set or keep status CHANGES_REQUESTED; record rejection summary in Notes. Update the UI artifact and any affected upstream requirements or plan notes before returning to review. Do not promote until rework is done and re-reviewed.
- **No promotion** from READY_FOR_HUMAN_APPROVAL to APPROVED without explicit human approval evidence.

---
## Current Items

| UI ID | Parent Plan | Feature | Status | Approval Mode | Owner | Reviewer | Trigger Source | Output | Exit Criteria | Notes |
|-------|-------------|---------|--------|----------------|-------|----------|----------------|--------|---------------|-------|
| UI-001 | IMPL-001 | Outfit Recommendations | TODO | HUMAN_REQUIRED | UI Build Agent | Review Agent | Next-task automation suggestion + direct run | PDP and cart widget checklist | Surface states, components, and analytics defined | UI readiness is the milestone human gate before backend continuation |
| UI-002 | IMPL-002 | Cross Sell | TODO | HUMAN_REQUIRED | UI Build Agent | Review Agent | Direct run | Cross-sell module checklist | Trigger context and attach interactions defined | Conversion-impacting UI remains reviewed |
| UI-003 | IMPL-003 | Occasion-Based Recommendations | TODO | AUTO_APPROVE_ALLOWED | UI Build Agent | Review Agent | Direct run | Occasion-led recommendation surface checklist | Occasion entry points and content framing defined | Can iterate autonomously until later checkpoint |
| UI-004 | IMPL-004 | Customer Style Profile | TODO | HUMAN_REQUIRED | UI Build Agent | Review Agent | Direct run | Profile view and preference controls checklist | Visibility rules and profile edit states defined | Privacy-sensitive UX needs visible approval |
| UI-005 | IMPL-005 | Recommendation API | TODO | HUMAN_REQUIRED | UI Build Agent | Review Agent | PR-driven follow-up review | API consumer contract checklist | Consumer handling, fallback, and explanation states defined | Consumer-facing contract UI is gated |
| UI-006 | IMPL-006 | Merchandising Rule Builder | IN_PROGRESS | HUMAN_REQUIRED | UI Build Agent | Review Agent | Direct run | Rule authoring and approval screen checklist | Rule scope, conflict display, and publish states defined | Admin workflow includes approval and audit controls |
| UI-007 | IMPL-007 | Look Editor | TODO | AUTO_APPROVE_ALLOWED | UI Build Agent | Review Agent | Next-task automation suggestion + direct run | Look editor screen checklist | Composition, tagging, and preview states defined | Drafting may auto-approve before later milestone review |
| UI-008 | IMPL-008 | Recommendation Analytics Dashboard | TODO | AUTO_APPROVE_ALLOWED | UI Build Agent | Review Agent | Schedule-assisted suggestion | Dashboard module checklist | KPI panels, filters, and drilldown states defined | Internal dashboard UI can iterate quickly |
