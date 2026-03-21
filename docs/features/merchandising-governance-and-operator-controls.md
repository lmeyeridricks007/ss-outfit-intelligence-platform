# Feature: Merchandising governance and operator controls

**Upstream traceability:** `docs/project/business-requirements.md` (BR-009); `docs/project/br/br-009-merchandising-governance.md`, `br-005-curated-plus-ai-recommendation-model.md`, `br-011-explainability-and-auditability.md`; `docs/project/data-standards.md`; `docs/project/glossary.md` (merchandising rule, curated look, override).

---

## 1. Purpose

Provide auditable operator control over recommendation behavior: **curated looks**, **merchandising rules**, campaigns, pins/boosts, exclusions, **overrides**, approvals, rollback—without engineering-only changes (BR-009).

## 2. Core Concept

Governance is a **control stack** with distinct families (curated, rules, campaigns, overrides) each with scope, time bounds, precedence class, and audit trail (BR-009 taxonomy).

## 3. Why This Feature Exists

Prevents uncontrolled model drift; enables seasonal and campaign intent; supports troubleshooting (`goals.md` operational goals).

## 4. User / Business Problems Solved

- S2 merchandiser scales intent.
- S4 measures effect of governance changes.
- Support resolves incidents with history (BR-011).

## 5. Scope

Control semantics, workflows, audit storage requirements, integration with decisioning and traces. **Missing decisions:** org role names; which changes need dual approval; UI vendor/build vs buy.

## 6. In Scope

- CRUD for curated **looks** with market/channel/type/mode scope.
- Rule types: hard vs soft; exclusions; mandatory includes; boosts; pins.
- Campaign windows and conflict policies.
- Overrides with reason, actor, expiry.

## 7. Out of Scope

Legal review workflow tooling beyond logging; financial planning for margin targets.

## 8. Main User Personas

S2 merchandiser; marketing ops; S1 stylist (consumer of outputs); governance/compliance reviewers.

## 9. Main User Journeys

Author seasonal curated set → schedule campaign → monitor telemetry → emergency override hot SKU → rollback after stockout resolved.

## 10. Triggering Events / Inputs

Merchandiser edits, scheduled activations, API imports from planning tools, incident tickets triggering override.

## 11. States / Lifecycle

`draft → pending approval → active → scheduled → expired → archived`; overrides `active → auto-expire/review`.

## 12. Business Rules

- Deterministic precedence documented alongside BR-005 order; campaign conflicts need tie-breaker (**missing decision**).
- Overrides must be visible in traces and analytics (BR-010 **override** event).
- Curated looks invalid under inventory may be auto-suppressed (BR-008).

## 13. Configuration Model

Role-based permissions; environment promotion (dev/stage/prod); effective dating; dependency links (“rule bundle v3”).

## 14. Data Model

`CuratedLook`, `MerchandisingRule`, `Campaign`, `Override`, `ApprovalRecord`, `AuditEvent` (before/after JSON, actor, timestamp, rationale).

## 15. Read Model / Projection Needs

Active rules index by market/surface/type for low-latency decisioning; admin search and diff views.

## 16. APIs / Contracts

Admin APIs (authenticated): CRUD + publish; decisioning read APIs: `GET /governance/effective?context`.

## 17. Events / Async Flows

`governance.rule.published`, `campaign.activated`, `override.applied` → invalidate caches; notify analytics for change markers.

## 18. UI / UX Design

Rule builder with test-against-anchor preview; campaign calendar; diff and rollback; clear risk labeling for high-impact changes.

## 19. Main Screens / Components

Look library, rule editor, campaign manager, override console, audit timeline, approval inbox.

## 20. Permissions / Security Rules

RBAC; separation of duty for high risk; full audit; no anonymous admin access.

## 21. Notifications / Alerts / Side Effects

Notify approvers; alert on overlapping campaigns; webhook to Slack optional.

## 22. Integrations / Dependencies

Decisioning service, catalog, experimentation (hold experiments during big governance pushes—**policy missing decision**).

## 23. Edge Cases / Failure Cases

Stale scheduled campaign after catalog withdrawal → auto-disable rules; conflicting pins → deterministic error surfacing to operators.

## 24. Non-Functional Requirements

Admin UX responsiveness; audit store immutability; high availability for read path used in decisioning.

## 25. Analytics / Auditability Requirements

Every recommendation trace carries rule/campaign/override IDs (BR-011); change markers in experiment analysis (BR-010).

## 26. Testing Requirements

Policy simulation tests; approval workflow tests; rollback drills; permissions matrix tests.

## 27. Recommended Architecture

Governance service as source of truth; signed snapshots consumed by decisioning; event-sourced audit log.

## 28. Recommended Technical Design

Versioned snapshots with `governanceSnapshotId` on each recommendation response; optimistic concurrency on edits.

## 29. Suggested Implementation Phasing

- **Phase 1:** Core rules, curated looks, basic approvals, audit log, pins/exclusions for PDP/cart.
- **Phase 3:** Rich rule builder, campaign complexity, cross-channel governance dashboards.

## 30. Summary

Governance makes the platform operable at scale (BR-009). Success requires clear precedence, expiry discipline, and trace linkage—several approval and conflict policies remain **missing decisions**.
