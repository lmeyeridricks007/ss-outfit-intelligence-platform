# Feature: Merchandising Governance

## Traceability / Sources

**Canonical project docs**

- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`
- `docs/project/review-rubrics.md`
- `docs/project/agent-operating-model.md`

**Business requirements (BR)**

- `docs/project/br/br-009-merchandising-governance.md` (primary)
- `docs/project/br/br-010-analytics-and-experimentation.md` (governance-impact telemetry, override/fallback visibility)
- `docs/project/br/br-011-explainability-and-auditability.md` (trace linkage to governance artifacts)
- `docs/project/br/br-003-multi-surface-delivery.md` (governance continuity across channels)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (type-level merchandising emphasis and boundaries)

---

## 1. Purpose

Define the **operating model and platform capabilities** that let business users **author, publish, override, and audit** recommendation-shaping artifacts—curated looks, compatibility/suppression rules, campaign priorities, and overrides—while preserving **hard safety constraints**, **precedence clarity**, and **cross-channel consistency** (BR-009).

## 2. Core Concept

**Merchandising governance** is a layer between **business intent** and **recommendation execution**: operators change *what is eligible, emphasized, protected, suppressed, or temporarily replaced* within guardrails; engineering owns **platform guardrails**, **rule classes**, and **non-bypassable constraints**. Every material change produces **audit evidence** and flows into **recommendation traces** (BR-011) and **analytics** (BR-010).

## 3. Why This Feature Exists

Premium retail requires **speed** (campaigns, seasonality, fixes) without **chaos** (incompatible looks, silent manual logic, un-auditable changes). BR-009 converts that need into explicit governance objects, override models, publication lifecycle, and health metrics.

## 4. User / Business Problems Solved

- Reduce engineering tickets for routine curation and campaign emphasis.
- Enable **urgent correction** (suppress bad pairings) with rollback and expiration.
- Make **campaign intent** predictable vs evergreen ranking.
- Provide **auditability** for “why did shoppers see this set?” (with BR-011).
- Surface **governance health** (override volume, repeated suppressions) to steer systemic fixes.

## 5. Scope

**In scope:** Governance objects, override taxonomy, precedence interpretation, publication states, roles/permissions at capability level, audit fields, integration points with engine and delivery traces, Phase 1 minimum vs later maturity.

**Out of scope:** Final admin UI pixel designs; IdP product choice; detailed rule DSL grammar (downstream architecture).

## 6. In Scope

- Curated look lifecycle: draft → review (when required) → scheduled → active → expired/rolled back.
- Compatibility/suppression rules within **approved rule classes** only.
- Campaign priority windows, coexistence with evergreen logic, market/surface scoping.
- Overrides: pin/protect, boost/deprioritize, suppress, replace, fallback-to-safer, emergency expiring.
- Governance health metrics and operator workflows for cleanup of stale overrides.
- Permission model: who can author, publish, emergency-override, rollback.

## 7. Out of Scope

- Customer-facing explanation copy (except noting that internal reasoning stays internal—BR-011).
- Ranker training pipelines.
- Full legal records-management policy (retention periods are open decisions).

## 8. Main User Personas

- **Merchandiser / stylist author.**
- **Campaign/marketing operator.**
- **Clienteling lead** (consumer of governed outputs, escalation path).
- **Governance admin** (workflow routing, audits).
- **Engineering/platform owner** (guardrails, releases).

## 9. Main User Journeys

1. **Seasonal curation update:** merchandiser edits curated looks for anchor families → scheduled publish before launch → trace shows curated source family in live sets.
2. **Campaign emphasis:** operator sets priority window for specific looks on PDP/homepage slots → coexistence rules prevent conflicting evergreen pin → post-campaign auto-expire.
3. **Incident response:** bad pairing discovered → suppression override with reason code → expires in 72h → analytics shows spike in suppressions for review.
4. **Audit inquiry:** support asks why product X appeared → operator traces recommendation set to campaign id + override id + rule ids (BR-011 linkage).

## 10. Triggering Events / Inputs

- Authoring saves, publish actions, rollback, bulk imports (if allowed), API-driven activations from approved tools.
- Engine requests **governance snapshot** or consumes evented updates—exact mechanism in architecture stage.

## 11. States / Lifecycle

- **Objects:** `draft`, `in_review`, `scheduled`, `active`, `expired`, `rolled_back`, `archived` (terminology may map to implementation enums).
- **Emergency overrides:** mandatory `expiresAt` or review ticket reference.
- **Rule evaluation order:** BR-009 precedence stack is authoritative.

## 12. Business Rules

1. Hard eligibility, consent, policy, inventory compatibility: **cannot be bypassed** by any self-service action.
2. Merchandising controls outrank generic AI optimization **within** the candidate pool defined by rules and curation.
3. Overrides are **diagnosed**: high volume triggers governance health review thresholds (exact numbers TBD).
4. Disallowed actions from BR-009 remain disallowed (hidden logic, permanent broad override without visibility, etc.).

## 13. Configuration Model

- **Scopes:** market, surface, channel, recommendation type, category/anchor family, campaign, customer segment (where permitted for governed emphasis—not violating consent).
- **Rule classes:** enumerated types engineering exposes; merchandisers cannot invent arbitrary code expressions in Phase 1.

## 14. Data Model

- **CuratedLook:** id, version, anchors, categories, associations, effective window, protection flags, author, status.
- **Rule/Suppression:** id, type, predicate summary, scope, reason code, author, status.
- **CampaignPriority:** id, campaign ref, window, targeted slots/surfaces, emphasis mode, coexistence policy id.
- **Override:** id, override kind, target refs, scope, reason, actor, createdAt, expiresAt, status, rollback ref.
- **AuditEvent:** immutable log of transitions with before/after summaries (not necessarily full document diff in Phase 1).

## 15. Read Model / Projection Needs

- **Operator consoles:** searchable governance objects, diff views, “what’s active now” timelines.
- **Engine projection:** high-read, low-latency compiled snapshot of active controls per scope; invalidation on publish.

## 16. APIs / Contracts

- Internal **governance CRUD/publish** APIs (service-to-service) with RBAC.
- **Read APIs** for operators and for engine consumption (may be push or pull).
- Responses include stable ids for trace embedding in recommendation sets (BR-011).

## 17. Events / Async Flows

- `GovernanceObjectPublished`, `GovernanceObjectRolledBack`, `OverrideActivated`, `OverrideExpired` events for analytics and cache invalidation.
- Async propagation tolerances defined so publish does not silently lag without visibility (metrics on staleness).

## 18. UI / UX Design

- **Progressive disclosure:** list → detail → impact preview (“affected anchors/slots”) before publish.
- **Risk banners** for broad suppressions, cross-market changes, fallback-to-safer activation.
- **Conflict resolution UX** when campaign pin competes with override (surface BR-009 open question).

## 19. Main Screens / Components

- `LookEditor`, `RuleManager`, `CampaignPriorityScheduler`, `OverrideConsole`, `AuditTimeline`, `GovernanceHealthDashboard` (illustrative).

## 20. Permissions / Security Rules

- Role-based: author vs publisher vs emergency operator vs read-only analyst.
- Segregation of duties where required for high-risk changes (exact matrix open).
- All actions authenticated; sensitive markets may restrict cross-border editors.

## 21. Notifications / Alerts / Side Effects

- Notify subscribers when high-risk publishes occur; page on-call only for defined emergency paths.
- Optional merchandising alerts when override expiration approaching for incomplete cleanup.

## 22. Integrations / Dependencies

- **Depends on:** identity/RBAC, recommendation engine, delivery trace contract, analytics event bus.
- **Informs:** experimentation console (experiments must not hide governance influence—BR-010).

## 23. Edge Cases / Failure Cases

- Partial publish failure: object must not enter inconsistent `active` in some regions only without explicit scope semantics.
- Concurrent edits: optimistic locking with clear merge UX.
- Engine cannot load snapshot: **safe fallback** mode per policy with trace flag `degradedMode=governance_snapshot_unavailable` (illustrative).
- Rule conflicts: deterministic resolution order documented; no silent “last writer wins” without audit.

## 24. Non-Functional Requirements

- **Audit durability:** append-only audit store; backup/restore tested.
- **Latency:** compiled snapshot read must meet engine SLO; publish pipeline async acceptable with bounded propagation SLA.
- **Compliance:** PII minimization in audit notes; free-text reason fields validated.

## 25. Analytics / Auditability Requirements

- BR-010: measurable override/fallback/campaign influence signals in recommendation analytics.
- BR-011: trace links from `recommendationSetId` to governing object versions active at decision time.
- Governance KPIs: time-to-publish, rollback rate, override aging, repeated override detection.

## 26. Testing Requirements

- Policy tests: forbidden bypass attempts must fail in automated suites.
- Simulation/preview tests: publish preview shows expected PDP module impact using recorded fixtures.
- Audit completeness tests: every material transition produces required fields.

## 27. Recommended Architecture

- **Governance service** (authoring, audit, workflow) separate from **ranking** but tightly integrated via snapshots.
- **Event-sourced audit** optional; minimum is immutable audit log + object versioning.

## 28. Recommended Technical Design

- Versioned curated look documents; content hashing for trace (“look version id”).
- Feature-flagged rule classes to avoid unbounded DSL risk early.

## 29. Suggested Implementation Phasing

- **Phase 1 (BR-009 §13.1):** curated look boundaries, basic suppress/protect, campaign priority basics, audit visibility, engineering vs business control matrix.
- **Phase 2:** richer targeting by surface/market/segment; governance health dashboards.
- **Phase 3:** multi-channel workflow parity, advanced review routing, deeper analytics integration.

## 30. Summary

Merchandising governance implements BR-009: **bounded self-service** over looks, rules, campaigns, and overrides with **explicit precedence**, **publication lifecycle**, **audit trails**, and **trace linkage** so recommendation behavior remains **explainable, reversible, and measurable** across channels (BR-003/010/011). Phase 1 delivers the minimum viable **control + audit** foundation for the first ecommerce loop.

## 31. Assumptions

- Business can supply reason codes and ownership discipline for overrides.
- Engineering curates an allowed **rule class** catalog before merchandisers get self-service rule UI.
- Initial operators are internal SuitSupply roles, not external partners.

## 32. Open Questions / Missing Decisions

- Which actions require **second-person approval** vs direct publish (BR-009 §16).
- Default **expiration windows** by override type; emergency override maximum duration.
- Resolution algorithm when **campaign priority** and **protected curation** collide on the same slot.
- Minimum **audit field** set for legal/regional policy (BR-009 §16).
- Governance snapshot **propagation SLA** and acceptable staleness per surface (PDP vs email freeze).
