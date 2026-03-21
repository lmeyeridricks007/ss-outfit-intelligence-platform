# Feature: Analytics and experimentation

**Upstream traceability:** `docs/project/business-requirements.md` (BR-010); `docs/project/br/br-010-analytics-and-experimentation.md`, `br-003-multi-surface-delivery.md`, `br-002-multi-type-recommendation-support.md`; `docs/project/data-standards.md`; `docs/project/goals.md` (telemetry success criteria).

---

## 1. Purpose

Provide trustworthy **recommendation telemetry**, attribution from impression to outcome, **experiment** hooks, and reporting dimensions—so optimization does not rely on clicks alone (BR-010).

## 2. Core Concept

Minimum event families: impression, click, save, add-to-cart, purchase, dismiss, **override**—each with **recommendation set ID**, **trace ID**, type, surface, experiment/rule context (`data-standards.md`).

## 3. Why This Feature Exists

Without shared measurement, channel teams misread performance and ship harmful ranking changes (`problem-statement.md` root causes).

## 4. User / Business Problems Solved

- S4: Defensible uplift and debugging.
- S2: See campaign vs baseline effects.
- Business: Conversion/AOV targets (`goals.md`).

## 5. Scope

Event schemas, collection SDKs/hooks, warehouse contracts, experiment assignment, reporting semantics. **Missing decisions:** attribution window lengths; BI tool; MDE targets; whether experimentation is in-house vs vendor (`architecture-overview.md` missing decision).

## 6. In Scope

- Cross-surface consistent event names and required fields.
- Experiment + variant on delivery and events.
- Governance change markers for analysis.
- Operator dashboards requirements (high level).

## 7. Out of Scope

Advanced causal inference methodology; ad network analytics.

## 8. Main User Personas

S4; S2; S3 marketing; engineering integrators.

## 9. Main User Journeys

Launch A/B on ranking policy → monitor funnel by **recommendation type** → roll out winner; investigate dip using trace + events.

## 10. Triggering Events / Inputs

Surface renders, user interactions, order completion webhooks, operator overrides, email opens/clicks (Phase 2+).

## 11. States / Lifecycle

Event validated → enriched (customer, product) → streamed → warehoused → aggregated; experiment subject enrollment sticky per session/customer policy (**missing decision**).

## 12. Business Rules

- No personalization analytics on non-consented data (BR-006/012).
- Impression must mean visible render, not API success only (BR-010 completeness).
- When browser telemetry is blocked, ecommerce surfaces must use the server-side
  impression fallback described in `ecommerce-surface-experiences.md` and
  preserve the same `recommendationSetId`, `traceId`, placement, and
  recommendation-type fields to avoid breaking attribution continuity.

## 13. Configuration Model

Event schema versioning; sampling rates for high-volume; PII redaction rules; feature flags for new fields.

## 14. Data Model

`RecommendationEvent` { type, ts, customerOrSessionId, channel, surface, placement, recommendationSetId, traceId, recommendationType, anchorProductId?, lookId?, itemId?, position, experiment, variant, ruleContext, sourceMix }.

## 15. Read Model / Projection Needs

Daily aggregates by type/surface/campaign; funnel joins orders via commerce ids; experiment assignment table.

## 16. APIs / Contracts

Ingestion endpoint or stream schema; server-side GTM replacement optional; admin config API for experiments.

## 17. Events / Async Flows

High-volume streaming (Kafka/PubSub **TBD**); dead-letter queues; late-arriving order attribution jobs.

## 18. UI / UX Design

Internal dashboards with filters: type, surface, campaign, experiment, governance version; guardrail tiles (empty rate, dismiss rate).

## 19. Main Screens / Components

Experiment console; metric catalog; alert configuration UI.

## 20. Permissions / Security Rules

Role-based dashboard access; row-level security by market; PII minimization.

## 21. Notifications / Alerts / Side Effects

Anomaly detection alerts; experiment auto-stop hooks (**governance missing decision**).

## 22. Integrations / Dependencies

Delivery API (IDs), commerce order feed, email provider events, clienteling app (Phase 3).

## 23. Edge Cases / Failure Cases

Missing **trace ID** on order → probabilistic attribution only; ad blockers on web → server-side impression logging required.

## 24. Non-Functional Requirements

Near-real-time for ops dashboards optional; scalable ingestion; schema backward compatibility.

## 25. Analytics / Auditability Requirements

Ability to reconstruct path from impression to purchase for a sample of **trace IDs** (BR-011 linkage).

## 26. Testing Requirements

Contract tests on payloads; load tests; data quality monitors; experiment assignment distribution tests.

## 27. Recommended Architecture

Event collection layer → stream → warehouse ( medallion optional ) → semantic layer → BI.

## 28. Recommended Technical Design

Single analytics ID namespace; schema registry; feature tags on events; experiment as first-class dimension.

## 29. Suggested Implementation Phasing

- **Phase 1:** Web PDP/cart events + order linkage + basic experiments on ranking policy.
- **Phase 2:** Email + expanded ecommerce placements.
- **Phase 3:** Clienteling + cross-channel reporting.

## 30. Summary

Analytics is production-critical (BR-010). Standardize events early; several attribution and platform choices remain **missing decisions** but must not block schema stability for Phase 1.
