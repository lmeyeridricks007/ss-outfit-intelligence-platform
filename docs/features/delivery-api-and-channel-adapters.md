# Feature: Delivery API and Channel Adapters

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

- `docs/project/br/br-003-multi-surface-delivery.md` (primary)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (typed sets, overlays, contract expectations)
- `docs/project/br/br-009-merchandising-governance.md` (governance continuity, precedence, no forked rules)
- `docs/project/br/br-010-analytics-and-experimentation.md` (telemetry continuity, experiment visibility in traces)
- `docs/project/br/br-011-explainability-and-auditability.md` (trace IDs, provenance in responses)
- `docs/project/br/br-001-complete-look-recommendation-capability.md` / `docs/project/br/br-002-multi-type-recommendation-support.md` (Phase 1 types: outfit, cross-sell, upsell bound to shared contracts)

---

## 1. Purpose

Define the **API-first recommendation delivery layer** that exposes governed, typed recommendation sets to multiple consumers (ecommerce web, email, clienteling, future API clients) through a **stable core contract** and **channel adapters** that shape payloads without forking business logic.

## 2. Core Concept

A single **recommendation delivery service** accepts **surface-aware, channel-aware requests** and returns **recommendation sets** each with a **primary recommendation type**, **canonical identifiers**, **inventory-eligible product/look references**, and **decision trace metadata**. **Channel adapters** translate the core model into consumer-specific envelopes (web module props, ESP content blocks, clienteling views) while preserving shared semantics, IDs, and governance applicability.

## 3. Why This Feature Exists

Without a shared delivery contract, each channel re-implements eligibility, typing, and measurement—fragmenting merchandising control and breaking cross-channel analytics. BR-003 requires one delivery model; architecture-overview positions delivery API and adapters between the engine and experience layer.

## 4. User / Business Problems Solved

- **Consistency:** Same recommendation meaning on PDP, cart, and later channels.
- **Speed to market:** New surfaces integrate via adapters, not new engines.
- **Governance:** Merchandising rules and precedence apply uniformly (BR-009).
- **Measurement:** Shared recommendation set ID and trace context for BR-010/BR-011.
- **Operational safety:** Explicit versioning, fallback, and timeout semantics reduce silent failures.

## 5. Scope

**In scope:** HTTP (or equivalent) API design principles, request/response semantics, error and empty-result behavior, versioning strategy, adapter boundaries, consumer responsibilities, multi-type responses for Phase 1 types, trace fields, idempotency and reliability patterns at the contract level.

**Adjacent but specified elsewhere:** Exact JSON Schema/OpenAPI files (downstream), specific ESP or storefront SDK code, ranker implementation.

## 6. In Scope

- Core recommendation request: identity/session, surface, channel, locale/region, anchor product and/or cart context, allowed recommendation types, RTW vs CM mode flags where material.
- Core response: ordered sets per requested type slots; each set includes `recommendationSetId`, `traceId`, `primaryRecommendationType`, `channel`, `surface`, source blend hints (curated / rule / AI / fallback), experiment/campaign/override linkage when material.
- Adapter layer: ecommerce, email, clienteling, future API—each maps core model to presentation-agnostic vs presentation-oriented subdivisions per standards.
- Versioning: breaking vs additive changes; deprecation notices; consumer negotiation (headers or path version).
- Fallback: degraded inputs, upstream timeouts, empty inventory, governance-forced fallback modes.
- Consumer boundaries: what adapters must not re-interpret (compatibility, type labels, trace IDs).

## 7. Out of Scope

- Checkout, OMS, or ESP replacement.
- Authoring UI for looks/rules (see merchandising feature).
- Pixel-level web layout for PDP modules (see ecommerce surface feature)—delivery supplies data contracts adapters consume.

## 8. Main User Personas

- **Integration engineers** (web, email, clienteling, mobile).
- **Platform/backend engineers** owning the delivery service and adapters.
- **Merchandising/governance operators** (indirect—via trace and governance continuity).
- **Analytics/engineering** consuming traces and events.

## 9. Main User Journeys

1. **PDP request:** Web adapter calls delivery with `surface=PDP`, anchor `productId`, session/customer context; receives outfit + cross-sell + upsell sets; renders via storefront module.
2. **Cart request:** Same pattern with cart line context; types may emphasize cross-sell/upsell with outfit completion where appropriate (BR-002 surface table).
3. **Phase 3 email batch:** Campaign adapter requests sets with campaign and customer context; uses stable IDs in rendered links for telemetry continuity.
4. **Clienteling:** Associate-triggered request with richer internal trace display (adapter adds operator-facing fields allowed for internal consumers only).

## 10. Triggering Events / Inputs

- **Synchronous:** Page load, cart refresh, module visibility, stylist explicit refresh, campaign assembly job.
- **Inputs:** Mandatory surface + channel; optional customerId, sessionId, anchorProductId, cart snapshot, locale, market, consent/identity-confidence hints, requested `recommendationTypes[]`, experiment headers if applicable.

## 11. States / Lifecycle

- **Request lifecycle:** validated → authorized → context resolved → engine invoked → sets assembled → trace sealed → response returned.
- **Set states (logical):** `OK`, `EMPTY_ALLOWED`, `DEGRADED_FALLBACK`, `ERROR` (with safe empty or last-known-good policy per consumer contract).
- **Version lifecycle:** `current`, `deprecated`, `sunset` with documented consumer migration windows.

## 12. Business Rules

- Every returned set has exactly one **primary recommendation type** (BR-002); overlays (contextual/personal) retain primary type + modifier metadata when used.
- Hard eligibility, inventory, consent, and compatibility constraints are enforced **before** adapter shaping; adapters cannot override exclusions.
- BR-009 precedence applies end-to-end: hard constraints → journey context → merchandising controls → candidates → ranking → **surface assembly in adapter** last.
- Phase 1: outfit, cross-sell, upsell are in-contract; other types may be requested only when enabled by phase flags or feature toggles aligned with roadmap.

## 13. Configuration Model

- **Per environment:** base URLs, timeouts, circuit-breaker thresholds, default fallback mode.
- **Per consumer:** adapter mapping profiles (field renames, max slots, image CDN rules)—presentation only.
- **Feature flags:** phase-gated types, experimental ranking blends (visible in trace per BR-010/011).

## 14. Data Model

- **Request DTO:** `requestId`, `surface`, `channel`, `customerContext`, `sessionContext`, `anchorProductId`, `cartLines[]`, `market`, `locale`, `rtwCmMode`, `requestedTypes[]`, `clientCapabilities` (e.g., max items per slot).
- **Recommendation item:** canonical `productId` or `lookId`, display attributes delegated to catalog projection, price/stock flags as allowed by catalog service—not recomputed in contradictory ways.
- **Recommendation set:** `recommendationSetId`, `traceId`, `primaryRecommendationType`, `items[]`, `provenanceSummary`, `governanceRefs[]`, `experimentRefs[]`, `degradedMode` enum.
- **Error object:** machine-readable code, optional retry hint, never leak internal stack traces to external consumers.

## 15. Read Model / Projection Needs

- Catalog read model for product display fields and eligibility snapshots at decision time.
- Customer profile projection with identity confidence (for gating personal overlays in later phases).
- Governance snapshot: active campaigns, overrides, suppressions effective for request scope (engine-owned; delivery forwards trace).

## 16. APIs / Contracts

- **Style:** RESTful `GET`/`POST` as appropriate; POST preferred when cart body or PII-bearing context is required.
- **Illustrative resource:** `POST /v1/recommendations` with JSON body matching §14 request shape; response wraps `sets[]`.
- **Headers:** `Accept-Version` or path `/v1/`; `X-Request-Id` for correlation; optional `X-Experiment-Variant` echo in response trace.
- **Semantics:** Idempotent for same logical inputs within short TTL where safe; explicit **cache semantics** documented per consumer (e.g., email assembly vs live PDP).
- **Pagination:** slot-based limits per surface in contract, not unbounded arrays.

## 17. Events / Async Flows

- Delivery emits or forwards **decision completed** signals for operational metrics (latency, error rate, fallback rate).
- Consumers remain responsible for **impression/interaction/outcome** events (BR-010) but must copy `recommendationSetId` and `traceId` from API response into those events.
- Async **email assembly** jobs: batch requests include batch correlation ID linking to individual recommendation sets.

## 18. UI / UX Design

- **API surface:** Clear error messages for integrators; consistent empty states as structured payloads (`reasonCode`: `NO_ELIGIBLE_CANDIDATES`, `GOVERNANCE_SUPPRESSED`, etc.).
- **Adapter UX contract:** Adapters receive enough grouping labels (recommendation type, module slot id) for accessible presentation without embedding HTML in core API.

## 19. Main Screens / Components

- Not applicable at core API layer; **adapter components** (web module props schema, email JSON block schema, clienteling panel schema) are documented as **consumer contracts** attached to this feature’s adapter annex in later architecture artifacts.

## 20. Permissions / Security Rules

- Authenticate service-to-service calls; scoped API keys or OAuth for channel integrations.
- Redact internal trace details for external consumers; full trace for internal tooling only (BR-011 customer-facing boundary).
- Respect regional data routing and consent flags on customer context fields.

## 21. Notifications / Alerts / Side Effects

- Alerts on elevated error rates, latency SLO breach, fallback spike, or trace ID generation failure.
- No customer notifications from delivery itself.

## 22. Integrations / Dependencies

- **Upstream:** recommendation engine, catalog/inventory, identity/profile, governance services, experimentation assignment service.
- **Downstream:** ecommerce adapters, ESP adapters, clienteling apps, internal debug tools.
- **Standards alignment:** `docs/project/standards.md` API and contract expectations.

## 23. Edge Cases / Failure Cases

- Partial upstream failure: return degraded sets with `degradedMode` and reduced slots rather than 500 when policy allows.
- Stale inventory: mark items `ineligible` in response or omit with trace reason—**no** silent substitution without trace.
- Anonymous session: omit personal overlay; still return Phase 1 types.
- Conflicting campaign + override: precedence per BR-009; trace must show winning control.
- Version skew: old mobile client on deprecated API—document error contract and minimum supported versions.

## 24. Non-Functional Requirements

- **Latency:** PDP/cart p95 targets defined in implementation plan; email batch may trade latency for throughput.
- **Availability:** Multi-AZ deployment; graceful degradation.
- **Scalability:** Stateless delivery nodes; engine scaling independent.
- **Observability:** Distributed tracing on `traceId`; metrics per surface/channel/type.

## 25. Analytics / Auditability Requirements

- 100% of successful responses include `recommendationSetId` and `traceId` when any set is non-empty (BR-010/011).
- Trace includes experiment, campaign, override fingerprints when they materially affected output.
- Adapter logs must not drop trace continuity when transforming payloads.

## 26. Testing Requirements

- Contract tests per API version with golden fixtures for Phase 1 types.
- Adapter round-trip tests: core model → adapter → validate required fields for each consumer profile.
- Chaos tests: inventory service timeout, engine timeout—assert fallback behavior and trace flags.
- Cross-consumer tests: same request context produces semantically consistent types and IDs across adapters (allowing slot count differences only where configured).

## 27. Recommended Architecture

- **Delivery service** as BFF-style API in front of recommendation orchestration; **thin adapters** as libraries or microservices per channel family.
- **Anti-corruption layer** between raw engine DTOs and public contract.
- **Versioned** public API; internal engine API may evolve faster behind the ACL.

## 28. Recommended Technical Design

- OpenAPI-first public contract generation for clients.
- JSON schema validation on ingress/egress for external boundary.
- Feature registry mapping `surface` + `channel` → allowed types and slot templates.

## 29. Suggested Implementation Phasing

- **Phase 1:** REST `v1`, ecommerce adapter only (PDP + cart), outfit/cross-sell/upsell, trace IDs, basic fallback—aligns with roadmap Phase 1.
- **Phase 2:** Extend request context for contextual/personal modifiers; homepage adapter profiles without breaking v1 semantics (additive fields).
- **Phase 3:** Email and clienteling adapters, batch endpoints or async job integration, stricter SLA reporting.

## 30. Summary

Delivery API and channel adapters implement BR-003’s API-first, multi-consumer model: a **versioned core contract** carries typed recommendation sets and **traceable decision context**, while **adapters** handle presentation and channel timing without forking eligibility or recommendation-type semantics. Phase 1 prioritizes ecommerce PDP/cart and three recommendation types; later phases add surfaces and channels on the same contract spine.

## 31. Assumptions

- Initial consumers can integrate via HTTPS JSON with service credentials.
- Catalog provides display-ready attributes or a stable companion read API.
- A single logical “recommendation orchestration” capability exists behind delivery (may be modular internally).
- Phase 1 defers full personal/contextual **types** but preserves **contract fields** for future overlays (BR-002).

## 32. Open Questions / Missing Decisions

- Exact **caching policy** per surface (PDP TTL vs cart vs email freeze at send time)—BR-003 open questions.
- **Batch API** shape for email vs synchronous-only in Phase 3.
- **Minimum trace payload** exposed to external integrators vs internal-only detail (BR-011).
- **Idempotency key** standard for cart refreshes and client retries.
- Whether **multi-type** responses are always bundled or optionally single-type per request in Phase 1 for simpler web clients.
