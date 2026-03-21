# Feature: Identity and style profile

**Upstream traceability:** `docs/project/business-requirements.md` (BR-012); `docs/project/br/br-012-identity-and-profile-foundation.md`, `br-006-customer-signal-usage.md`, `br-011-explainability-and-auditability.md`; `docs/project/data-standards.md`; `docs/project/glossary.md` (style profile); `docs/project/roadmap.md` (Phase 2).

---

## 1. Purpose

Maintain **canonical customer identity**, source mappings, **identity-resolution confidence**, and a usable **style profile** for ranking, suppression, and cross-channel consistency (BR-012).

## 2. Core Concept

Identity layers: canonical ID, source mappings, confidence state, provenance, anonymous/session state (BR-012 table). **Style profile** is separate from identity mechanics.

## 3. Why This Feature Exists

Prevents wrong-history personalization and channel inconsistency (`problem-statement.md` fragmentation).

## 4. User / Business Problems Solved

- P2 gets coherent recommendations across web and email.
- Operators see confidence and suppressions explicitly.
- Safer GDPR/CCPA handling via bounded activation.

## 5. Scope

Identity graph operations, merge rules, API for profile consumers, suppression flags, degradation behavior. **Missing decisions:** matching algorithm; human review queue thresholds; profile attribute catalog.

## 6. In Scope

- Confidence states: high, bounded, low, conflicted, unknown (BR-012).
- Profile domains: category affinities, fit tendencies, price tier, owned-item signals, occasion tendencies—**exact list TBD**.
- Cross-channel consistency rules.

## 7. Out of Scope

Full CDP product roadmap; credit bureau data.

## 8. Main User Personas

P2; S1 clienteling; privacy stakeholders; S4.

## 9. Main User Journeys

Login links session to customer → confidence upgraded → email click uses same canonical ID; conflict detected → conservative mode.

## 10. Triggering Events / Inputs

Logins, orders, ESP identifiers, store visits, explicit linking in clienteling app.

## 11. States / Lifecycle

Mapping `proposed → active → superseded|revoked`; profile features `computed → stale → refreshed`.

## 12. Business Rules

- Low/conflicted confidence → no durable **personal** ranking (BR-012, BR-002).
- Suppressions (opt-out, category block) override personalization.
- Profile features include freshness metadata (BR-006 alignment).

## 13. Configuration Model

Market-specific consent definitions; merge auto-approval thresholds; feature TTLs.

## 14. Data Model

`Customer` { canonicalId }, `SourceMapping` { source, externalId, status, confidence, timestamps }, `StyleProfile` { version, features[], suppressions[], consentState }.

## 15. Read Model / Projection Needs

Low-latency profile slice for recommendation path; batch enrichments.

## 16. APIs / Contracts

`GET /customers/{id}/profile?purpose=recommendation` returns features + confidence + consent flags; `POST /identity/link` internal.

## 17. Events / Async Flows

`identity.merged`, `profile.refreshed`, `consent.updated` → invalidate caches.

## 18. UI / UX Design

Clienteling profile panel with confidence badges; customer-facing transparency minimal (privacy).

## 19. Main Screens / Components

Identity admin console; merge review queue; suppression editor.

## 20. Permissions / Security Rules

Strict access logging; PII encryption; role-based field visibility.

## 21. Notifications / Alerts / Side Effects

Alert on abnormal merge volume; notify customer on sensitive link actions if policy requires (**missing decision**).

## 22. Integrations / Dependencies

Signal ingestion, commerce, ESP, CRM, recommendation decisioning.

## 23. Edge Cases / Failure Cases

Shared household devices; email forwarded; duplicate accounts after return—merge policies **missing decision**.

## 24. Non-Functional Requirements

High read QPS for PDP; strong consistency for consent updates; disaster recovery **RPO/RPO TBD**.

## 25. Analytics / Auditability Requirements

Expose `identityConfidence` summary on traces (BR-011); experiments stratified by confidence (BR-010).

## 26. Testing Requirements

Property tests on merge; consent flip tests; load tests on profile reads.

## 27. Recommended Architecture

Identity service + profile service (may be modules); event-driven recomputation; cache at edge with TTL.

## 28. Recommended Technical Design

Feature snapshots referenced by `profileSnapshotId` in ranking requests for reproducibility.

## 29. Suggested Implementation Phasing

- **Phase 1:** Anonymous session identifiers only; no cross-session **personal** type.
- **Phase 2:** Full identity + profile for ecommerce/email expansion per roadmap.

## 30. Summary

Identity/profile is the gate for trustworthy personalization (BR-012). Ship confidence-visible contracts before scaling **personal** recommendations. Merge algorithms and profile schemas are key **missing decisions**.
