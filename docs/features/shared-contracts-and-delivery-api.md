# Feature: Shared contracts and delivery API

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003, BR-002, BR-010, BR-011); `docs/project/br/br-003-multi-surface-delivery.md`, `br-002-multi-type-recommendation-support.md`, `br-010-analytics-and-experimentation.md`, `br-011-explainability-and-auditability.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/api-standards.md`; `docs/project/integration-standards.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/project/roadmap.md`; `docs/features/open-decisions.md` (`DEC-001`, `DEC-002`, `DEC-003`, `DEC-010`).

---

## 1. Purpose

Define the shared, versioned delivery boundary that exposes recommendation outcomes to ecommerce, email, clienteling, and future consumers without forcing each channel to invent its own request semantics, response taxonomy, or degraded-state behavior.

This feature makes the platform truly API-first. It ensures downstream consumers receive:

- explicit **recommendation types**
- stable **recommendation set IDs** and **trace IDs**
- machine-readable freshness and degradation semantics
- rule / experiment / governance linkage
- contract evolution rules that allow new consumers to onboard without rewriting core decisioning

## 2. Core Concept

The delivery API is the semantic boundary between internal recommendation logic and consuming surfaces.

It has three responsibilities:

1. **Normalize request context** - identify channel, surface, placement, market, mode, customer state, and the request trigger such as anchor product, cart, occasion, or campaign.
2. **Package recommendation meaning** - return one or more typed recommendation results in a stable envelope that preserves recommendation intent, grouped **look** / **outfit** structure where applicable, freshness, and traceability.
3. **Signal safety and operability** - expose structured degraded, partial, stale, empty, or unauthorized outcomes so consumers can render responsibly and operators can troubleshoot consistently.

Consumers own presentation. The platform owns recommendation meaning, identifiers, and contract stability.

## 3. Why This Feature Exists

`docs/project/vision.md` and BR-003 require a shared recommendation platform, not disconnected channel-specific widgets. Without a common delivery contract:

- ecommerce, email, and clienteling teams would define incompatible request and response shapes
- telemetry and experiment attribution would drift across surfaces
- governance rules and campaign context would be applied differently per consumer
- new API consumers would require bespoke integration logic instead of contract reuse
- degraded states would be hidden or inconsistently rendered, damaging trust

This feature is therefore foundational to Phase 1 launch quality and to all later channel expansion.

## 4. User / Business Problems Solved

| User / stakeholder | Problem | What this feature solves |
| --- | --- | --- |
| `P1` Anchor-product shopper | Needs fast, coherent recommendations on PDP and cart | Gives surfaces stable typed recommendation responses with safe fallback signaling |
| `P2` Returning customer | Should not receive ambiguous personalized outputs when identity confidence is weak | Forces explicit customer-state and degradation handling in requests and responses |
| `S1` Stylist / clienteling associate | Needs trustworthy, inspectable recommendation payloads | Preserves trace context, grouped results, and role-aware metadata for assisted flows |
| `S2` Merchandiser | Needs campaign and rule semantics to survive across channels | Carries governance context consistently instead of hiding it inside local consumers |
| `S3` Marketing operator | Needs email or lifecycle recommendations without inventing separate contract logic | Adds batch and freshness-safe delivery semantics for outbound consumers |
| `S4` Product / analytics | Needs comparable telemetry and experiment context across surfaces | Requires stable IDs, experiment linkage, and machine-readable delivery states |
| Engineering / architecture | Needs one reusable integration pattern for all consumers | Establishes a shared contract, versioning model, and operational expectations |

## 5. Scope

This feature covers the implementation-oriented requirements for synchronous and batch recommendation delivery, request normalization, response packaging, contract versioning, snapshot retrieval, structured errors, degraded-state semantics, freshness metadata, and delivery-time observability.

It intentionally stops short of freezing every wire-level implementation detail. Final transport and field-shape decisions belong to architecture so long as they preserve the business semantics documented here.

**Assumptions:**

- upstream decisioning, catalog, governance, and experiment services can supply the minimum inputs required for a delivery response
- consumers can preserve `traceId` and `recommendationSetId` into downstream telemetry
- contract discovery, deprecation notices, and compatibility checks are part of the delivery platform responsibility
- Phase 1 optimizes for interactive ecommerce PDP and cart before broader channel expansion

**Open decisions tracked in `docs/features/open-decisions.md`:**

- `DEC-001` - transport and versioning model
- `DEC-002` - Phase 1 latency and availability targets
- `DEC-003` - canonical delivery contract freeze
- `DEC-010` - email freshness threshold and regeneration policy

## 6. In Scope

- request context for `channel`, `surface`, `placement`, `market`, `mode`, trigger type, customer or session state, and relevant journey inputs
- typed recommendation delivery for `outfit`, `cross-sell`, `upsell`, later `style bundle`, `occasion-based`, `contextual`, and `personal`
- grouped **look** / **outfit** payload support where recommendation meaning requires grouped members
- sync interactive retrieval and batch-oriented delivery workflows
- contract version discovery, compatibility communication, and deprecation windows
- recommendation snapshot retrieval for support, audit, and attribution continuity
- structured errors and explicit partial / degraded / stale / empty result semantics
- request / response trace propagation and delivery-time observability
- consumer-safe field visibility rules by surface and role

## 7. Out of Scope

- ranking model selection, candidate-generation internals, or compatibility scoring formulas
- final UI layout, module copy, or design-system treatment for each surface
- detailed warehouse-table design or BI vendor selection
- merchandising-rule authoring UI and workflow specifics
- final infrastructure topology, edge network choice, or API gateway product selection
- downstream implementation tickets for every consumer team

## 8. Main User Personas

| Persona | How this feature serves them |
| --- | --- |
| `P1` Anchor-product shopper | Receives inventory-safe, typed recommendation payloads on PDP and cart without semantic drift between placements |
| `P2` Returning customer | Benefits from contract-level customer-state distinction and safe degraded behavior when profile confidence is low |
| `S1` Stylist / clienteling associate | Gets authenticated access to delivery payloads with richer trace depth than public surfaces |
| `S2` Merchandiser | Sees campaign, rule, and override context survive all the way to delivery and downstream analysis |
| `S3` Marketing operator | Can request or consume freshness-aware batch recommendations for outbound channels |
| `S4` Product / analytics | Relies on stable IDs, response states, and experiment linkage across every consumer |
| Future API integrator | Onboards against a documented, versioned contract rather than a bespoke channel implementation |

## 9. Main User Journeys

### Journey 1: Interactive PDP recommendation retrieval

1. Shopper views an anchor product on PDP.
2. Surface calls the shared delivery endpoint with `channel`, `surface`, `placement`, `mode`, `anchorProductId`, and session or customer state.
3. Delivery layer normalizes request context, calls decisioning, validates response shape, and packages typed recommendation sets.
4. PDP receives a response with `traceId`, contract version, one or more typed sets, and any degradation / freshness indicators.
5. UI renders or suppresses the module safely and emits telemetry with the same stable identifiers.

### Journey 2: Cart-aware recommendation retrieval

1. Shopper changes the cart.
2. Delivery request includes cart lines and current consumer context.
3. Delivery layer packages basket-aware recommendation sets and explicitly signals duplicate suppression, empty, or degraded outcomes when needed.
4. Cart surface renders a coherent recommendation module rather than guessing meaning from item lists.

### Journey 3: Email precompute and send-time delivery

1. Marketing workflow submits a batch request for a campaign audience or recipient set.
2. Delivery platform accepts the batch, tracks job state, and records freshness requirements.
3. Results are prepared with per-recipient traceability and explicit freshness metadata.
4. If freshness is stale at send time, the workflow must regenerate, suppress, or degrade according to the later-resolved `DEC-010` policy.

### Journey 4: Clienteling recommendation retrieval

1. Authenticated operator opens a clienteling workflow.
2. Delivery request includes operator scope plus customer, product, or appointment context.
3. Delivery platform returns typed recommendation results with role-appropriate trace depth.
4. Operator can inspect recommendation intent without exposing sensitive reasoning on customer-facing surfaces.

### Journey 5: Future API consumer onboarding

1. A new channel or internal product wants recommendation delivery.
2. Team checks supported contract versions and consumer capability guidance.
3. Consumer implements the shared request context and response semantics without changing recommendation meaning.
4. Compatibility tests verify the consumer can handle versioned, degraded, stale, and empty outcomes safely.

## 10. Triggering Events / Inputs

| Trigger | Required inputs | Important notes |
| --- | --- | --- |
| PDP render / refresh | `channel`, `surface`, `placement`, `market`, `mode`, `anchorProductId`, `sessionId` or `customerRef` | Highest-priority Phase 1 path |
| Cart change | same context fields plus cart lines | Requires basket-aware request semantics |
| Occasion-led request | context bundle plus occasion or journey identifiers | No single product anchor may exist |
| Campaign batch submission | campaign or audience context, market, freshness requirements, recipient identity refs | Later phase; batch-safe semantics required |
| Clienteling refresh | authenticated operator scope, customer ref, optional product or appointment context | Role-aware trace depth required |
| Support / audit retrieval | `recommendationSetId` or trace identifier plus auth scope | Must retrieve immutable snapshot semantics |

Optional request enrichment may include:

- `experimentContext`
- `contextHints`
- `governanceSnapshotId`
- `identityConfidence`
- consumer capability hints for grouped payload support

## 11. States / Lifecycle

The delivery lifecycle must be explicit enough for troubleshooting and analytics.

### Delivery request lifecycle

1. **`requested`** - request accepted with consumer context
2. **`authenticated`** - consumer identity and scope validated
3. **`normalized`** - request context converted to canonical delivery shape
4. **`assembled`** - upstream recommendation payload received and packaged
5. **`validated`** - contract schema, field visibility, and consumer capability checks passed
6. **`degraded`** - safe but non-ideal response prepared because freshness, identity, inventory, or upstream dependency quality is limited
7. **`delivered`** - response returned with stable identifiers
8. **`traced`** - request / response metadata persisted for support and attribution continuity

### Snapshot lifecycle

`created -> retained -> retrieved -> expired`

- a delivered snapshot is immutable for support and attribution purposes
- later re-generation creates a new response and new stable identifiers rather than mutating the original payload

`degraded` is a successful but bounded outcome. It is not the same as `failed`.

## 12. Business Rules

- Every consumer request must identify `channel`, `surface`, and `placement`; placement inference alone is not acceptable.
- Every successful response must include contract version metadata, `traceId`, and at least one typed recommendation result or an explicit empty / degraded outcome.
- Recommendation type must be explicit in the response; consumers must not infer type from placement names alone.
- Response envelopes may carry one or more typed recommendation results; exact envelope cardinality is finalized by `DEC-003`, but set-level traceability is mandatory.
- `recommendationSetId` and `traceId` must remain stable across delivery, support retrieval, and telemetry linkage.
- Known, anonymous, low-confidence, and suppressed customer states must remain distinguishable.
- Interactive consumers must receive explicit freshness and degradation semantics rather than silently falling back to stale or partial outputs.
- Additive contract evolution is the default. Breaking changes require explicit versioning and migration support.
- Consumer-specific BFFs are allowed only if they preserve shared recommendation meaning and identifiers.
- Batch delivery must preserve the same recommendation semantics as synchronous delivery, not invent a separate outbound-only taxonomy.
- Email and other non-interactive consumers must not treat stale results as equivalent to fresh interactive responses.
- Structured errors must remain correlation-friendly while not leaking sensitive system or profile details.

## 13. Configuration Model

| Configuration area | Description |
| --- | --- |
| `contractVersionPolicy` | Active, deprecated, and sunset versions plus migration windows |
| `consumerRegistry` | Allowed channels, surfaces, scopes, and capability declarations |
| `rateLimitPolicy` | Limits by consumer class, environment, and interaction type |
| `freshnessPolicy` | Interactive vs batch freshness windows and stale handling rules |
| `fallbackPolicy` | Which degraded states are displayable vs suppressible per surface |
| `fieldVisibilityPolicy` | Role- and surface-based metadata visibility, especially for clienteling and support |
| `snapshotRetentionPolicy` | How long immutable delivery snapshots remain accessible by environment and class |
| `batchPolicy` | Maximum batch sizes, idempotency expectations, and job-state retention rules |

All configuration changes should be versioned or auditable so delivery behavior can be reconstructed later.

## 14. Data Model

### Conceptual entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `DeliveryRequestContext` | Canonical request representation | `requestId`, `channel`, `surface`, `placement`, `market`, `mode`, trigger fields, `sessionId` or `customerRef`, `traceId` |
| `DeliveryEnvelope` | Top-level response object | `contractVersion`, `traceId`, consumer context summary, `generatedAt`, `sets[]`, `degradationSummary?` |
| `RecommendationSet` | Typed recommendation result carried in the envelope | `recommendationSetId`, `recommendationType`, `sourceMix`, ranking or ordering summary, freshness, members or grouped look payload, rule / experiment references |
| `RecommendationMember` | Individual recommendation line item | canonical product ID, display order, eligibility / availability summary, optional grouped-role label |
| `GroupedLookPayload` | Grouped **look** data used for **outfit** or bundle responses | `lookId`, grouped members, slot labels, optional anchor lineage |
| `FreshnessState` | Consumer-safe freshness descriptor | `state`, `generatedAt`, `validUntil?`, `reasonCode?` |
| `DegradationDescriptor` | Machine-readable bounded-state explanation | `code`, `severity`, `fallbackApplied`, `consumerAction` |
| `ErrorEnvelope` | Structured non-success response | `code`, `message`, `traceId`, `retryable`, `details?` |
| `DeliverySnapshot` | Immutable stored delivery result | `snapshotId`, `recommendationSetId` or response key, `traceId`, contract version, payload, retention metadata |

### Minimum required field expectations

| Concept | Required field expectations |
| --- | --- |
| `DeliveryRequestContext` | consumer identity, market, mode, one trigger source such as anchor, cart, occasion, or campaign, and one session / customer reference |
| `DeliveryEnvelope` | contract version, trace ID, generation time, one or more typed results or explicit empty / degraded outcome |
| `RecommendationSet` | stable set ID, type, source-mix category, freshness, and a machine-readable way to distinguish grouped vs flat results |
| `DegradationDescriptor` | stable code, severity, fallback indicator, and expected consumer handling |
| `ErrorEnvelope` | stable code, consumer-safe message, trace ID, and retryability signal |

### Illustrative response payload

```json
{
  "contractVersion": "2026-01",
  "traceId": "trace_01JQ4S2KB0F7G8R4HZR4V6P2Q9",
  "generatedAt": "2026-03-21T14:05:00Z",
  "channel": "web",
  "surface": "pdp",
  "placement": "complete_the_look_primary",
  "sets": [
    {
      "recommendationSetId": "recset_01JQ4S2KCYQY5NJ8TRMEAK1F9A",
      "recommendationType": "outfit",
      "sourceMix": "mixed",
      "freshness": {
        "state": "fresh",
        "generatedAt": "2026-03-21T14:05:00Z"
      },
      "groupedLook": {
        "lookId": "look_90210",
        "anchorProductId": "prod_12345",
        "members": [
          { "productId": "prod_12345", "role": "anchor", "position": 1 },
          { "productId": "prod_67890", "role": "shirt", "position": 2 },
          { "productId": "prod_54321", "role": "shoes", "position": 3 }
        ]
      },
      "experimentContext": {
        "experimentId": "exp_delivery_v2",
        "variantId": "variant_b"
      },
      "ruleContextRefs": [
        { "ruleId": "rule_44", "campaignId": "cmp_spring" }
      ],
      "degradation": null
    }
  ]
}
```

## 15. Read Model / Projection Needs

This feature needs lightweight serving and operational projections beyond raw request handling:

- **Contract version registry** - maps active, deprecated, and unsupported versions
- **Consumer compatibility projection** - records which consumers support which contract versions and grouped payload semantics
- **Delivery snapshot store** - immutable support / attribution retrieval by stable identifier
- **Batch job projection** - accepted, running, partial, completed, failed states for outbound delivery workflows
- **Degradation analytics projection** - aggregates fallback, stale, empty, and timeout outcomes by surface and version
- **Support lookup projection** - maps `traceId` and `recommendationSetId` to stored snapshots and upstream context summaries

An optional read-through cache may exist for hot interactive requests, but cached entries must preserve freshness state and contract version identity.

## 16. APIs / Contracts

Per `docs/project/api-standards.md`, the default expectation is a resource-oriented HTTP contract unless `DEC-001` resolves differently. The shapes below are illustrative and define required business concepts, not final endpoint names.

### Contract interactions

| Resource / interaction | Purpose | Required request concepts | Required response concepts |
| --- | --- | --- | --- |
| `POST /recommendations` | Interactive recommendation retrieval | consumer context, market, mode, trigger payload, session or customer state, optional context hints | contract version, `traceId`, typed recommendation sets, freshness, degradation / empty semantics |
| `POST /recommendations/batch` | Batch or scheduled recommendation assembly | campaign or audience context, recipient or item list, freshness requirements, idempotency key | accepted job metadata or inline results with stable identifiers |
| `GET /recommendations/batch/{jobId}` | Batch job status retrieval | job ID plus auth scope | job state, result counts, per-item failures, freshness / regeneration status |
| `GET /recommendation-sets/{recommendationSetId}` | Immutable snapshot retrieval for support and audit | set ID plus auth scope | stored response payload or supported subset, trace metadata, generation timestamp |
| `GET /contract/versions/{version}` | Consumer compatibility and field discovery | contract version identifier | support status, required resources, deprecation status, migration notes |

### Illustrative interactive request

```json
{
  "channel": "web",
  "surface": "pdp",
  "placement": "complete_the_look_primary",
  "market": "nl",
  "mode": "RTW",
  "anchorProductId": "prod_12345",
  "sessionId": "sess_abc123",
  "contextHints": {
    "country": "NL",
    "season": "spring"
  }
}
```

### Structured error envelope

| Field | Meaning |
| --- | --- |
| `code` | Stable machine-readable error code such as `invalid_request`, `unsupported_version`, `unauthorized`, `forbidden_consumer_scope`, `upstream_timeout`, `empty_eligible_set` |
| `message` | Consumer-safe explanation |
| `traceId` | Correlates failure with logs and support tools |
| `retryable` | Whether safe retry is recommended |
| `details` | Optional bounded metadata such as invalid field names or unsupported values |

### Error and degraded-state semantics

- **True errors** are reserved for invalid requests, auth failures, unsupported contract versions, or unsafe upstream dependency failures.
- **Degraded responses** should use successful contract envelopes with explicit degradation descriptors when the consumer can still render safely.
- **Empty results** are distinct from validation or auth failures and must remain machine-readable for analytics and UI behavior.

## 17. Events / Async Flows

The delivery layer should emit operational and analytics-supporting events such as:

- `recommendation.delivery.requested`
- `recommendation.delivery.completed`
- `recommendation.delivery.degraded`
- `recommendation.delivery.failed`
- `recommendation.batch.accepted`
- `recommendation.batch.completed`
- `recommendation.batch.item_failed`
- `recommendation.snapshot.expired`
- `recommendation.contract.version_deprecated`

### Interactive async flow

1. Request accepted and trace started.
2. Upstream recommendation payload retrieved.
3. Contract validation and field-visibility filtering applied.
4. Delivery completion or degradation event emitted with surface and version context.
5. Consumer telemetry later binds to the same identifiers.

### Batch async flow

1. Batch request accepted with idempotency key.
2. Job state stored and monitored.
3. Per-item or per-recipient outputs produced with stable identifiers.
4. Completion, partial-failure, or stale-result warnings emitted for operational handling.

## 18. UI / UX Design

This feature does not own the final end-user UI, but it must support safe rendering and operator usability.

### Consumer-facing UX requirements enabled by the contract

- loading, empty, and degraded states must be distinguishable
- grouped **outfit** responses must be renderable without consumers guessing slot or grouping semantics
- stale or freshness-sensitive results must be suppressible or clearly handled
- module labels should align with recommendation type rather than placement-only naming

### Developer / operator UX requirements

- contract documentation and examples must be easy to discover
- consumers need a compatibility and deprecation view before upgrading versions
- support teams need a snapshot lookup and trace-friendly response viewer

## 19. Main Screens / Components

- **API docs portal** - canonical request / response examples and compatibility notes
- **Contract changelog / version registry** - active and deprecated versions
- **Consumer onboarding checklist** - auth scopes, required telemetry, grouped-payload support, and fallback expectations
- **Batch job monitor** - status, freshness warnings, partial failures
- **Contract test dashboard** - fixture compatibility and consumer-driven contract-test status
- **Snapshot / support viewer** - immutable response lookup by `traceId` or `recommendationSetId`

## 20. Permissions / Security Rules

- Delivery access should be authenticated and least-privilege by consumer type.
- Public ecommerce surfaces may receive only consumer-safe metadata; clienteling and support flows may receive deeper trace detail based on scope.
- Sensitive profile reasoning, raw identity stitching evidence, and internal-only ranking details must not appear in public consumer responses.
- Snapshot retrieval requires stronger authorization than live public delivery.
- Request and response logs must minimize PII while retaining stable correlation identifiers.
- Batch and clienteling endpoints require stronger authz than anonymous interactive retrieval.

## 21. Notifications / Alerts / Side Effects

Operational side effects include:

- alert on contract validation failure spikes
- alert on version mismatch or unsupported-version request spikes
- alert on degradation or empty-result anomalies by surface
- alert on latency or upstream-timeout breaches once `DEC-002` is resolved
- warn batch / email workflows when freshness windows are exceeded

The delivery layer does not send customer notifications directly, but its state and freshness semantics determine whether downstream consumers should render, suppress, retry, or regenerate results.

## 22. Integrations / Dependencies

This feature depends on and integrates with:

- **recommendation decisioning and ranking** - upstream source of eligible typed recommendation outputs
- **complete-look orchestration** - grouped payload semantics for `outfit` responses
- **catalog and product intelligence** - product validity, imagery, and inventory-safe delivery metadata
- **identity and style profile** - customer-state and confidence-aware request context
- **merchandising governance and operator controls** - rule, campaign, and override references
- **analytics and experimentation** - downstream telemetry, experiment linkage, and attribution continuity
- **explainability and auditability** - trace retrieval and operator troubleshooting flows
- **auth / secret-management platform** - consumer authentication and scope enforcement

It also depends on `docs/project/api-standards.md`, `integration-standards.md`, and `data-standards.md` for contract, retry, idempotency, and identifier expectations.

## 23. Edge Cases / Failure Cases

- Consumer requests a contract version that is deprecated or unsupported.
- One recommendation type succeeds while another type in the same response must degrade or return empty.
- Anchor product becomes inventory-invalid between request normalization and payload delivery.
- Customer state resolves from anonymous to known after initial exposure; later telemetry must not rewrite the original delivery truth.
- Batch request partially fails because some recipients or markets cannot meet freshness or eligibility requirements.
- Consumer supports flat items but not grouped `outfit` payloads; compatibility must be explicit rather than silently flattened.
- Mobile and web surfaces lag on different contract versions; additive evolution must preserve backward compatibility.
- Support tries to retrieve an expired snapshot after retention limits.
- Trace identifiers are missing from downstream telemetry; analytics must record loss of attribution continuity rather than silently assuming linkage.

## 24. Non-Functional Requirements

- **Latency / availability:** interactive targets are architecture-critical and tracked in `DEC-002`; the feature requires those targets to be explicit before production hardening.
- **Version safety:** additive evolution first; breaking changes require explicit versioning and migration support.
- **Observability:** correlation identifiers, latency, error class, freshness, and degradation metrics must be captured.
- **Graceful degradation:** slow, stale, or partial upstream dependencies must produce explicit safe outcomes rather than opaque failures where consumer rendering remains possible.
- **Idempotency:** batch or write-like interactions must follow integration standards and support safe retries.
- **Security:** least-privilege access and PII minimization are mandatory.
- **Cross-surface consistency:** recommendation meaning must not change by consumer even if rendering differs.

## 25. Analytics / Auditability Requirements

- Every delivered response must record `traceId`, contract version, consumer context, and set-level identifiers.
- Recommendation telemetry must preserve `recommendationSetId`, `traceId`, recommendation type, placement, experiment context, and relevant rule or campaign references.
- Contract version changes, deprecations, and consumer compatibility exceptions must be auditable.
- Snapshot retrieval must support support and investigation workflows without reconstructing payloads from partial telemetry alone.
- Degraded and stale responses must remain visible in reporting rather than collapsed into generic success counts.

## 26. Testing Requirements

- schema validation tests for every supported contract version
- consumer-driven contract tests for key consuming surfaces
- golden fixtures for each recommendation type and grouped payload pattern
- backward-compatibility tests for additive and deprecated-field scenarios
- auth and field-visibility tests across anonymous, batch, clienteling, and support contexts
- batch idempotency and partial-failure tests
- upstream timeout and degradation-path tests
- snapshot retrieval consistency tests
- compatibility tests for grouped payload support and explicit empty / degraded handling

## 27. Recommended Architecture

Implement a dedicated **Recommendation Delivery** service or layer as a façade over upstream decisioning and orchestration.

Recommended capabilities inside that layer:

- request normalization
- consumer auth and scope enforcement
- contract version selection and validation
- response packaging and field-visibility filtering
- snapshot persistence for support and attribution continuity
- batch orchestration for non-interactive consumers
- degradation and error classification

Consumer-specific BFFs are acceptable only when they do not change recommendation meaning, identifiers, or delivery-state semantics.

## 28. Recommended Technical Design

- Keep the delivery contract schema-first in the repository using OpenAPI and / or JSON Schema, aligned with `DEC-001` once transport is finalized.
- Generate fixtures and compatibility tests from the canonical schema rather than duplicating ad hoc examples.
- Introduce a shared validation library for contract version checks, error envelope creation, and degradation descriptors.
- Store immutable delivery snapshots keyed by stable identifiers with retention metadata.
- Use a consumer registry to track allowed versions, grouped-payload support, auth scopes, and deprecation impact.
- Propagate `traceId` through request handling, response emission, operational events, and downstream telemetry hooks.

## 29. Suggested Implementation Phasing

### Phase 1

- synchronous ecommerce PDP and cart delivery
- explicit `outfit`, `cross-sell`, and `upsell` response support
- stable `traceId` and `recommendationSetId` propagation
- minimal but structured degradation and empty-result semantics
- contract version discovery and basic compatibility checks

### Phase 2

- batch-oriented email and campaign delivery workflows
- freshness metadata and regeneration signaling tied to `DEC-010`
- expanded ecommerce placements using the same contract
- richer deprecation and compatibility tooling

### Phase 3

- clienteling role-aware delivery depth
- support snapshot tooling and broader future API-consumer onboarding
- stronger consumer capability registry and contract-test automation

## 30. Summary

Shared contracts and delivery API is the platform boundary that makes cross-surface recommendation delivery coherent, measurable, and governable. It is not only a transport detail. It defines how recommendation meaning, stable identifiers, freshness, degradation, and traceability survive from internal decisioning to every consuming surface. Phase 1 must prove this boundary on PDP and cart; later phases extend the same contract to email, clienteling, and future consumers without forking the product into channel-specific recommendation systems.
