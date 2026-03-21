# Feature: Shared contracts and delivery API

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003, BR-002); `docs/project/br/br-003-multi-surface-delivery.md`, `br-002-multi-type-recommendation-support.md`; `docs/project/architecture-overview.md` (delivery API); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/project/roadmap.md` (Phase 1).

---

## 1. Purpose

Define the **API-first, versioned delivery layer** that returns typed **recommendation sets** to ecommerce, email, clienteling, and future consumers with stable identifiers (**recommendation set ID**, **trace ID**), explicit **recommendation types**, degraded-state signaling, and shared semantics so core decisioning does not fork per channel.

## 2. Core Concept

A **recommendation set** is the atomic response unit: it has a primary **recommendation type** (per BR-002), ordered items or grouped **look** members, governance/experiment/rule context summaries, and trace metadata. Consumers own presentation; the platform owns meaning, eligibility, and traceability.

## 3. Why This Feature Exists

Without shared contracts, surfaces invent incompatible request/response shapes, telemetry breaks cross-channel comparison, and governance cannot apply consistently (`docs/project/problem-statement.md`, BR-003).

## 4. User / Business Problems Solved

- **Shoppers (P1):** Consistent, inventory-valid suggestions on PDP/cart (Phase 1).
- **Operators (S2, S4):** Same rule and campaign semantics everywhere; measurable experiments.
- **Engineering:** One integration pattern for new surfaces (vision: API-first platform).

## 5. Scope

Covers synchronous (and optionally async job-based) **recommendation retrieval**, contract versioning, consumer context identification (channel, surface, placement, RTW/CM mode), error and degraded-result semantics, and mandatory trace fields. Does not define final URL paths or JSON field names in production code—those belong to architecture—but specifies **required business concepts** BR-003 lists.

**Assumptions:** AuthN/AuthZ model exists for each consumer class; idempotency policy TBD.

**Missing decisions:** Transport (REST vs GraphQL), cache TTLs per surface, exact versioning scheme (URL vs header), SLA per channel.

## 6. In Scope

- Request context: channel, surface, placement, market, mode (RTW/CM), anchor product/cart/occasion/campaign IDs as applicable.
- Response: typed sets, grouped **outfit** payloads, source-mix category (curated / rule-based / AI-ranked / fallback).
- Explicit partial/degraded/stale indicators per BR-003.
- Correlation: **trace ID** on request/response; **recommendation set ID** per set.

## 7. Out of Scope

- Ranking model internals (see `recommendation-decisioning-and-ranking.md`).
- Admin UI for rules (see `merchandising-governance-and-operator-controls.md`).
- Warehouse schemas for analytics (see `analytics-and-experimentation.md`).

## 8. Main User Personas

- P1 Anchor-product shopper; P2 Returning customer; S2 Merchandiser; S4 Analytics; future API integrator (implicit in BR-003).

## 9. Main User Journeys

1. PDP requests outfit + cross-sell sets in one call or batched calls (implementation choice—**missing decision**).
2. Cart requests basket-aware completion sets.
3. Phase 2+: email batch fetch with freshness metadata; Phase 3: clienteling authenticated fetch with operator-safe trace depth.

## 10. Triggering Events / Inputs

- Page render (PDP), cart change, campaign send-time assembly, stylist “refresh recommendations,” scheduled regeneration for stale checks.
- Inputs: canonical product IDs, cart lines, optional customer token, session ID, explicit occasion/context payload.

## 11. States / Lifecycle

- **Requested → Assembled → Delivered → Telemetry bound:** set ID issued at assembly; immutable snapshot for attribution once delivered (updates require new set ID—**missing decision**: email resend refresh policy).
- **Degraded:** e.g. inventory partial, profile suppressed, context fallback—state must be machine-readable.

## 12. Business Rules

- Every set declares **recommendation type**; multi-set responses keep separate set IDs (BR-002).
- Anonymous vs known customer state must not be conflated (BR-003, BR-012).
- Inventory-invalid items must not appear on ecommerce without governed fallback (BR-008).

## 13. Configuration Model

- Feature flags per surface/placement; API version compatibility matrix; rate limits per API key; environment-specific base URLs.
- Contract changelog with deprecation windows (`docs/project/standards.md` API assumptions).

## 14. Data Model

**Conceptual entities:** `RecommendationRequestContext`, `RecommendationSet` (id, type, items/look groups, ranking metadata), `TraceContext`, `DegradationReason`, `ExperimentContext`, `RuleContextRef` (IDs not free text).

**Minimum required fields by concept:**

| Concept | Required fields |
| --- | --- |
| `RecommendationRequestContext` | `channel`, `surface`, `placement`, `market`, `mode`, at least one of `anchorProductId`, `cart`, `occasion`, or `campaignId`, plus either `sessionId` or `customerRef` |
| `RecommendationSet` | `recommendationSetId`, `type`, `sourceMix`, `items` or grouped look members, `traceId`, `generatedAt`, `degradation` |
| `TraceContext` | `traceId`, `requestVersion`, `surface`, `market`, `mode`, `experimentContext?`, `ruleContextRefs[]` |
| `DegradationReason` | machine-readable `code`, human-readable `summary`, `severity`, `fallbackApplied` |
| `ExperimentContext` | `experimentId`, `variantId`, `assignmentMethod` |
| `RuleContextRef` | `ruleId`, `campaignId?`, `overrideId?`, `governanceVersion?` |

## 15. Read Model / Projection Needs

- None beyond serving-time assembly; optional read-through cache keyed by (anchor, market, mode, version, experiment bucket).

## 16. APIs / Contracts

**Example request (illustrative):** `POST /v1/recommendations` with body `{ channel, surface, placement, market, mode, anchorProductId?, cart?, customerRef?, sessionId?, occasion?, contextHints }`.

**Example response fragment:** `{ traceId, sets: [ { recommendationSetId, type: "outfit", sourceMix, items: [...], degradation: null } ] }`.

**Errors:** structured codes (validation, unauthorized, upstream timeout, empty eligible set).

**Minimum contract outline for downstream consumers:**

| Resource / interaction | Purpose | Required request fields | Required response fields |
| --- | --- | --- | --- |
| `POST /recommendations` | Interactive recommendation retrieval for web and authenticated clients | `channel`, `surface`, `placement`, `market`, `mode`, request trigger payload, identity/session reference | `traceId`, one or more `RecommendationSet` objects, contract `version`, degradation summary |
| `POST /recommendations/batch` | Non-interactive assembly for email or scheduled workflows | batch item list with `campaignId`, `market`, identity or audience refs, freshness requirements | batch job or inline result IDs, per-item `traceId`, per-set IDs, freshness metadata |
| `GET /recommendations/{recommendationSetId}` | Optional retrieval of stored snapshot for audit or support flows | path ID, caller authz context | immutable set snapshot, `traceId`, generation timestamp, source summary |
| `GET /contract/versions/{version}` | Contract discovery and compatibility checks | version identifier | supported resources, field requirements, deprecation status |

**Structured error envelope outline:**

| Field | Meaning |
| --- | --- |
| `code` | Stable machine-readable error code, e.g. `invalid_request`, `unauthorized`, `upstream_timeout`, `empty_eligible_set` |
| `message` | Consumer-safe explanation |
| `traceId` | Correlates failure to logs and support tooling |
| `retryable` | Whether the caller should retry automatically |
| `degradationSuggested` | Whether a degraded UX path is appropriate |

## 17. Events / Async Flows

- Optional async: email precompute job emits `recommendation.set.prepared` with freshness timestamp (Phase 2+).
- Webhook or message to analytics on delivery optional—**missing decision**.

## 18. UI / UX Design

- Not applicable to API core; consumers must render loading, empty, degraded states (`docs/project/standards.md` UI assumptions).

## 19. Main Screens / Components

- API docs portal; contract tests dashboard; developer sandbox keys (governance TBD).

## 20. Permissions / Security Rules

- Service-to-service auth; scoped API keys per channel; PII minimization in logs; clienteling elevated roles (Phase 3).

## 21. Notifications / Alerts / Side Effects

- Alerting on error rate spikes, empty-set rate anomalies, contract version mismatch; no customer notifications from API layer.

## 22. Integrations / Dependencies

- **Depends on:** catalog/inventory services, decisioning service, governance store, experiment assignment service.
- **Upstream docs:** `architecture-overview.md`, BR-003.

## 23. Edge Cases / Failure Cases

- Upstream timeout → degraded empty or last-known-good policy (**missing decision**).
- Split inventory across variants → substitute or omit per BR-008.
- Version skew between mobile/web → backward-compatible fields required.

## 24. Non-Functional Requirements

- PDP interactive latency target (specific ms **missing decision**); higher latency acceptable for email batch; 99.9% availability target TBD; idempotency for retries.

## 25. Analytics / Auditability Requirements

- Every response logs trace ID + set IDs; surfaces must emit impression events with same IDs (`data-standards.md`, BR-010, BR-011).

## 26. Testing Requirements

- Contract tests (consumer-driven), chaos tests for upstream failures, golden JSON fixtures per recommendation type, backward-compatibility tests per version.

## 27. Recommended Architecture

Dedicated **Recommendation Delivery** service as façade over decisioning; contract validation layer; edge cache optional; separate BFF per channel allowed if it does not alter recommendation meaning (BR-003).

## 28. Recommended Technical Design

- OpenAPI-first spec in repo; JSON schema for `RecommendationSet`; centralized error envelope; feature flags via standard config service.

## 29. Suggested Implementation Phasing

- **Phase 1:** PDP/cart synchronous API; outfit/cross-sell/upsell types; trace + set IDs; minimal degradation codes.
- **Phase 2:** Email-oriented freshness metadata; expanded placements.
- **Phase 3:** Clienteling authz and operator trace depth; partner API consumers.

## 30. Summary

Shared delivery contracts are the backbone for multi-surface consistency (BR-003). Phase 1 must prove typed sets, traceability, and degraded states on ecommerce; later phases extend consumers without forking decision semantics. Open API details and performance numbers remain **missing decisions** for architecture.
