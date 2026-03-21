# Feature: Analytics and experimentation

**Upstream traceability:** `docs/project/business-requirements.md` (BR-010); `docs/project/br/br-010-analytics-and-experimentation.md`, `br-003-multi-surface-delivery.md`, `br-002-multi-type-recommendation-support.md`, `br-011-explainability-and-auditability.md`; `docs/project/data-standards.md`; `docs/project/goals.md`; `docs/project/architecture-overview.md`; `docs/features/ecommerce-surface-experiences.md`; `docs/features/explainability-and-auditability.md`; `docs/features/open-decisions.md` (DEC-006, DEC-007).

---

## 1. Purpose

Define the shared measurement and experimentation layer for recommendation behavior so every recommendation-consuming surface can answer:

- what was shown
- where and when it was shown
- which recommendation type and source mix was involved
- which experiment or governance context applied
- what the customer or operator did next
- whether later cart and purchase outcomes can be attributed with stated confidence

This feature exists to make optimization trustworthy. It is not a reporting add-on after launch. Phase 1 ecommerce delivery depends on recommendation telemetry, attribution continuity, and experiment hooks being stable enough that product, analytics, and merchandising teams can improve recommendation quality without inventing local event definitions.

## 2. Core Concept

Analytics and experimentation is the platform's shared measurement plane across ecommerce, email, clienteling, and future consumers. It connects:

1. **Delivery context** from the shared recommendation contract (`recommendationSetId`, `traceId`, recommendation type, placement, source mix, experiment context)
2. **Behavioral telemetry** from impression through downstream actions
3. **Outcome linkage** to cart, purchase, dismiss, and override behavior
4. **Experiment assignment** so uplift claims are defensible
5. **Governance annotations** so operators can distinguish model lift from campaign, rule, or override changes

The minimum event families are fixed by `docs/project/data-standards.md` and BR-010:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Every event family must preserve stable recommendation identifiers and enough context to support both reporting and trace reconstruction.

## 3. Why This Feature Exists

Without a shared analytics layer:

- channel teams create inconsistent event shapes
- clicks are mistaken for recommendation quality
- experiment results cannot be separated from campaign or merchandising changes
- delayed purchases lose their recommendation context
- governance changes silently distort performance reporting
- product teams optimize for local dashboards instead of durable business outcomes

The product goals explicitly require telemetry, experimentation, and auditability as operational foundations. Recommendation changes must be measurable from the first production rollout so Phase 1 ecommerce can improve safely before broader channel expansion.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| S4 product, analytics, optimization | Cannot prove whether a ranking change improved performance | Controlled experiments, stable variant linkage, comparable funnel reporting |
| S2 merchandiser | Cannot tell whether lift came from model changes, campaigns, or overrides | Governance-aware reporting with campaign and override dimensions |
| S3 marketing / CRM | Onsite and outbound recommendation performance are incomparable | Shared event taxonomy and channel-consistent reporting semantics |
| S1 stylist / clienteling operator | Assisted-selling outcomes are hidden inside local tools | Cross-channel telemetry and operator-vs-customer action separation |
| Engineering / architecture | Downstream teams guess at event requirements and attribution rules | Stable contracts, versioned schemas, and explicit pipeline expectations |
| Business leadership | Uplift is reported without confidence or guardrails | Conversion, AOV, attach-rate, and guardrail views by surface and recommendation type |

## 5. Scope

This feature covers the implementation-oriented requirements for:

- event taxonomy and required fields
- client and server-side collection responsibilities
- experiment assignment and exposure capture
- attribution linkage from impression to downstream outcomes
- reporting semantics and read models
- governance annotations and operational guardrails
- internal operator workflows for experiment review and telemetry health

This feature does **not** freeze the final warehouse tool, experimentation vendor, or BI implementation. Those remain architecture-stage choices as long as they preserve the business semantics defined here.

**Primary missing decisions:** `open-decisions.md` decision `DEC-007` (attribution windows, experiment stickiness policy, experimentation platform ownership) and `DEC-006` (server-side impression fallback policy details).

## 6. In Scope

- Cross-surface event naming and field requirements
- Experiment and variant identifiers on delivery responses and downstream events
- Assignment storage for control, treatment, and holdout visibility
- Attribution joins for impression -> click -> add-to-cart -> purchase analysis
- Reporting slices by recommendation type, surface, source mix, governance context, experiment, and market
- Dashboards and alerts for telemetry health, experiment outcomes, and guardrails
- Explicit linkage to trace and audit artifacts for investigation workflows
- Consent-aware and confidence-aware identity handling for analytics

## 7. Out of Scope

- Final statistical significance framework or experiment-analysis library
- Media / ad network attribution
- Multi-touch marketing mix modeling
- Final visual design of dashboards
- Executive business review cadence and org ownership model
- Automated decision-making that bypasses governance or legal review

## 8. Main User Personas

- **S4: Product, analytics, and optimization team member** - primary owner of experiment design, interpretation, and rollout decisions
- **S2: Merchandiser** - needs governance-aware reporting and visibility into override or campaign effects
- **S3: Marketing / CRM operator** - needs cross-channel comparison for onsite vs outbound recommendation performance
- **S1: Stylist / clienteling operator** - needs confidence that assisted and self-service recommendation behaviors are measured consistently
- **Engineering integrators** - need stable contracts and validation rules for producers and consumers of telemetry

## 9. Main User Journeys

### Journey A: Launch and evaluate a ranking experiment
1. Product defines an experiment comparing baseline ranking vs a new source mix policy.
2. Delivery responses include `experimentId`, `variantId`, and `assignmentKey`.
3. Ecommerce surfaces emit impression, click, and add-to-cart events tied to the same `recommendationSetId` and `traceId`.
4. Orders arrive later and are linked back to exposed recommendation sets within the configured attribution policy.
5. Analysts review funnel, uplift, guardrails, and governance annotations before rollout.

### Journey B: Investigate a performance dip
1. Guardrail alert shows rising dismiss rate on PDP complete-look modules.
2. Analyst filters dashboards by recommendation type, market, and campaign period.
3. Trace drilldown reveals a governance override and recent campaign change on the same placement.
4. Team separates governance-driven change from ranking-driven change and avoids reverting the wrong subsystem.

### Journey C: Compare channels
1. Marketing compares onsite recommendation performance with email recommendation performance for the same campaign family.
2. Shared measurement definitions keep exposure and interaction semantics consistent.
3. Longer attribution windows and lower certainty for email are visible rather than hidden.
4. Teams make channel decisions from comparable metrics instead of locally defined dashboards.

## 10. Triggering Events / Inputs

Analytics and experimentation logic is triggered by:

- recommendation response creation in the delivery API
- viewport-qualified module visibility on web surfaces
- user interactions such as clicks, saves, dismissals, and add-to-cart
- order-completion or order-update webhooks from commerce / OMS
- operator overrides, campaign activations, or suppressions from governance tools
- experiment assignment or reassignment events
- identity stitching when anonymous sessions later resolve to known customers
- email open and click events in later phases
- clienteling recommendation delivery and assisted action events in later phases

## 11. States / Lifecycle

### Telemetry event lifecycle
`generated -> validated -> enriched -> accepted -> warehoused -> aggregated -> retained -> expired`

- **generated:** client, server fallback, or backend producer creates event payload
- **validated:** schema, required fields, and enum values checked
- **enriched:** identity confidence, market, campaign, source mix, and catalog context attached where available
- **accepted:** event assigned idempotency key and admitted to the primary stream
- **warehoused:** raw and normalized forms persisted for replay and analytics
- **aggregated:** semantic metrics and dashboards updated
- **retained / expired:** lifecycle managed per environment and privacy policy

### Experiment lifecycle
`draft -> scheduled -> active -> paused -> stopped -> analyzed -> rolled out or reverted`

- assignment and exposure capture must remain possible for every active state
- paused or stopped experiments remain reportable; historical events are never re-labeled
- rollout decisions must preserve a governance annotation so post-rollout performance shifts remain explainable

## 12. Business Rules

- **Impression means visible exposure**, not API success alone. For web surfaces this must map to a policy-defined visibility threshold; for server fallback it must record the fallback basis and source.
- **No recommendation analytics on non-permitted data.** Consent, regional use restrictions, and low-confidence identity states from BR-006 and BR-012 must constrain both tracking enrichment and reporting slices.
- **Stable IDs are mandatory.** `recommendationSetId`, `traceId`, experiment IDs, campaign IDs, rule IDs, and product IDs must persist across delivery and outcome paths.
- **Local dashboard definitions are not allowed to redefine core events.** Teams can create derived views, but impression, click, add-to-cart, purchase, dismiss, and override semantics remain shared platform definitions.
- **Override and suppression behavior is analytically meaningful.** Governance interventions must emit or annotate analytics context rather than silently mutating baseline results.
- **Attribution confidence must remain honest.** Missing identifiers, delayed orders, or overlapping exposures can reduce certainty; reporting must preserve that distinction.
- **Late-arriving events are valid.** Downstream pipelines must handle delayed orders and asynchronous channel behavior without dropping attribution context.
- **Duplicate event protection is required.** Retries, page re-renders, or webhook replays must not inflate counts.
- **Experiment assignment cannot bypass governance.** Hard safety, suppression, and privacy rules outrank experiment treatment.
- **Fallback paths must stay schema-compatible.** When browser telemetry is blocked, ecommerce surfaces must use the server-side impression fallback described in `ecommerce-surface-experiences.md` and preserve the same core identifiers and placement metadata.

## 13. Configuration Model

The feature needs a configuration layer that supports:

- event schema versioning
- per-surface placement definitions and visibility policy
- attribution windows by channel or recommendation type (subject to `DEC-007`)
- experiment assignment unit and stickiness policy (subject to `DEC-007`)
- sampling controls for high-volume debug-only events
- PII redaction and field masking by role and region
- alert thresholds for empty rate, dismiss rate, attribution confidence, and ingestion lag
- retention settings by environment and data class
- feature flags for introducing new dimensions or dashboard tiles

Configurations must be versioned so experiment results and governance changes can be interpreted against the definitions active at the time of exposure.

## 14. Data Model

### Core entities

| Entity | Purpose | Required core fields |
| --- | --- | --- |
| `RecommendationEvent` | Canonical telemetry event | `eventId`, `eventType`, `eventTs`, `channel`, `surface`, `placement`, `recommendationSetId`, `traceId`, `recommendationType`, `itemId`, `position`, `customerIdOrSessionId`, `identityConfidence`, `experimentId`, `variantId`, `ruleContext`, `campaignId`, `sourceMix`, `eventSource`, `schemaVersion` |
| `ExperimentAssignment` | Stable subject assignment for comparison | `assignmentId`, `experimentId`, `variantId`, `assignmentKey`, `assignmentUnit`, `assignedAt`, `eligibilityContext`, `holdoutFlag`, `stickyUntil` |
| `OutcomeAttribution` | Link between exposures and downstream outcomes | `attributionId`, `outcomeEventId`, `recommendationSetId`, `traceId`, `attributionWindowId`, `confidence`, `outcomeType`, `linkedOrderId`, `linkedItemId` |
| `GovernanceAnnotation` | Campaign, override, or suppression context that affects interpretation | `annotationId`, `effectiveFrom`, `effectiveTo`, `campaignId`, `ruleIds`, `overrideFlag`, `suppressionFlag`, `governanceSnapshotId` |
| `MetricSnapshot` | Pre-aggregated read model for dashboards | metric keys plus dimensions for type, surface, channel, experiment, market, and governance context |

### Example event payload

```json
{
  "eventId": "evt_01JPDPC6Q8J4G2P6Y5K1R1M4QX",
  "eventType": "impression",
  "eventTs": "2026-03-21T14:02:33Z",
  "channel": "web",
  "surface": "pdp",
  "placement": "complete_the_look_primary",
  "recommendationSetId": "recset_01JPDPC5YMM7V8TF7QF3D4P1Z9",
  "traceId": "trace_01JPDPC5W7H4YJ6R0N1S2T3U4V",
  "recommendationType": "outfit",
  "anchorProductId": "prod_12345",
  "itemId": "prod_67890",
  "position": 1,
  "customerIdOrSessionId": "sess_9b7d3",
  "identityConfidence": "anonymous",
  "experimentId": "exp_rank_mix_2026_03",
  "variantId": "treatment_b",
  "ruleContext": ["rule_inventory_guard", "rule_premium_suppression"],
  "campaignId": "camp_spring_wedding",
  "sourceMix": "curated_plus_ai_ranked",
  "eventSource": "browser",
  "schemaVersion": "1.0"
}
```

### Data-model notes

- `eventSource` distinguishes browser, server fallback, batch import, or operator source
- `identityConfidence` must preserve anonymous, low-confidence, or known-customer states
- `sourceMix` must distinguish curated, rule-based, AI-ranked, or mixed outputs
- downstream warehouses may normalize this model into multiple tables, but these semantic fields cannot disappear

## 15. Read Model / Projection Needs

The feature requires read models for at least the following views:

- **Exposure health dashboard** by channel, surface, placement, market, and recommendation type
- **Funnel performance view** from impression -> click -> add-to-cart -> purchase
- **Experiment scorecard** by experiment, variant, holdout flag, and cohort slices
- **Governance impact view** showing campaign, override, suppression, and emergency-control effects
- **Channel comparison view** for onsite, email, and clienteling performance
- **Trace-linked drilldown** from metric anomalies to sample recommendation sets and traces
- **Data quality view** for missing fields, ingestion lag, schema errors, and duplicate-rate trends

Daily aggregates are not sufficient on their own. Raw-event and normalized-event access is required for backfills, replay, and investigation workflows.

## 16. APIs / Contracts

This feature depends on stable contracts rather than one required transport. Acceptable implementations can use HTTPS ingestion, event buses, or managed collectors, but they must preserve the same semantics.

### Required contract surfaces

- **Recommendation delivery contract** must include `recommendationSetId`, `traceId`, recommendation type, surface / placement context, and experiment context where applicable
- **Telemetry ingestion contract** must accept the canonical event families with required IDs and schema version
- **Experiment assignment contract** must expose current experiment, variant, assignment key, and holdout information to delivery paths
- **Dashboard / semantic query contract** must provide stable definitions for core metrics so teams do not fork formulas

### Example implementation-facing interfaces

- `POST /analytics/recommendation-events`
- `GET /experiments/assignments/{assignmentKey}`
- `GET /analytics/metrics?surface=pdp&recommendationType=outfit&experimentId=...`
- stream topics such as `recommendation.events.raw`, `recommendation.events.validated`, `recommendation.attribution.links`

Wire-level details remain architecture work, but the field-level semantics above are mandatory for any implementation.

## 17. Events / Async Flows

### Flow A: Web impression
1. Delivery API returns recommendation payload with IDs and experiment metadata.
2. Frontend renders the module.
3. Visibility threshold is met.
4. Browser emits `impression`; if blocked, server fallback emits a schema-compatible event with `eventSource=server_fallback`.
5. Validation and enrichment pipeline adds campaign and identity context.
6. Dashboard exposure metrics update.

### Flow B: Purchase attribution
1. Customer interacts with recommended items and later purchases.
2. Commerce / OMS emits order event with order and line-item context.
3. Attribution job joins order lines to prior recommendation exposures and interactions using `recommendationSetId`, `traceId`, product IDs, session / customer mappings, and the configured attribution window.
4. `purchase` event and `OutcomeAttribution` record are written with confidence.
5. Experiment and commerce-impact views update.

### Flow C: Governance annotation
1. Merchandiser activates a campaign or operator applies an override.
2. Governance service emits an annotation or change event with snapshot ID and affected placement or recommendation scope.
3. Analytics pipeline records the change window.
4. Dashboards show performance shifts with governance context rather than blending them into baseline results.

### Reliability expectations

- invalid events route to quarantine / dead-letter processing
- replay must be possible after schema or downstream failures
- late-arriving events must backfill read models without corrupting idempotent counts

## 18. UI / UX Design

This feature primarily serves internal operator surfaces rather than customer-facing UI. The UX should emphasize interpretation speed and guardrail clarity.

### UX principles

- start with business questions, not raw tables
- make recommendation type and surface explicit on every analytics view
- keep experiment, campaign, and override context visible together
- allow drilldown from aggregate metric to sample recommendation set and trace
- distinguish "no data", "low confidence", and "not applicable"
- make alert severity and recommended next action obvious

Dashboard UX should prioritize anomaly detection, comparison, and explanation rather than pixel-perfect BI customization at this stage.

## 19. Main Screens / Components

- **Telemetry health dashboard** - ingestion status, schema error rate, missing-ID rate, lag, and server-fallback usage
- **Experiment console** - experiment list, variant split, primary metrics, guardrails, and rollout recommendation summary
- **Metric explorer** - slice by recommendation type, source mix, market, placement, and campaign context
- **Attribution explorer** - order linkage, confidence buckets, delayed-outcome trends, and unattributed outcome analysis
- **Trace drilldown panel** - jump from aggregate anomaly to example `traceId` / `recommendationSetId`
- **Alert configuration UI** - threshold management for dismiss-rate spikes, exposure drops, attribution failures, and ingestion outages

## 20. Permissions / Security Rules

- dashboard access must be role-based and market-aware
- raw event access is more restricted than aggregate metric access
- personally identifying fields must be minimized, masked, or excluded based on role and region
- trace and analytics tools must log access to sensitive drilldowns
- identity confidence and consent state must be preserved so low-confidence or restricted data is not overused
- experiment creation or rollout actions must respect governance and approval boundaries from adjacent operator-control features

## 21. Notifications / Alerts / Side Effects

The feature must support alerts for:

- ingestion outage or lag above threshold
- sudden drop in impressions for a major placement
- abnormal duplicate or validation failure rate
- rising dismiss rate or empty-result rate
- attribution-confidence degradation
- statistically meaningful experiment guardrail regression

Optional side effects:

- open an incident or operator task when telemetry health fails on a critical surface
- annotate dashboards when campaign or override changes begin
- invoke experiment pause or auto-stop logic once governance policy is defined under `DEC-007`

Alerting should prefer annotation and escalation over autonomous rollout changes unless policy explicitly allows auto-stop behavior.

## 22. Integrations / Dependencies

- **Shared contracts and delivery API** - source of recommendation IDs, placement context, and experiment metadata
- **Ecommerce surface experiences** - browser and server-fallback telemetry producers
- **Explainability and auditability** - trace linkage and investigation workflows
- **Commerce / OMS** - order and cart outcome feeds
- **Identity and style profile** - customer mapping and confidence-aware joins
- **Merchandising governance and operator controls** - campaign, override, suppression, and snapshot annotations
- **Email and clienteling channels** - later-phase exposure and engagement events
- **Warehouse / semantic layer / BI tooling** - implementation choices must preserve the semantic contract, even if tools change

Cross-module consistency matters most at the contract boundary: analytics cannot repair missing IDs or ambiguous recommendation types after the fact.

## 23. Edge Cases / Failure Cases

- **Ad blockers or browser failures:** use server fallback where permitted, and mark event source clearly
- **Same product appears in multiple recommendation sets before purchase:** attribution confidence may drop or require tie-breaking policy under `DEC-007`
- **Anonymous impression becomes known customer later:** retain session linkage and confidence-aware identity stitching
- **Missing `traceId` on outcome events:** report unattributed or low-confidence outcomes explicitly rather than fabricating certainty
- **Page re-renders or retries emit duplicate impressions:** idempotency keys or dedupe policy required
- **Order arrives before delayed interaction events:** support reconciliation and late backfill
- **Campaign or override changes mid-experiment:** preserve both experiment and governance annotations in reporting
- **Clock skew across producers:** normalize timestamps and record ingestion time separately from event time
- **Partial system outage:** allow dashboards to surface data freshness warnings instead of silently showing stale confidence
- **Returns or cancellations after purchase:** downstream metric definitions must state whether commerce-impact views use gross or net outcomes

## 24. Non-Functional Requirements

- support high-volume ingestion across multiple surfaces without event loss as a normal operating mode
- preserve backward-compatible schema evolution for existing required fields
- provide observability for validation failures, ingestion lag, and enrichment dependencies
- keep read models queryable quickly enough for operational decision-making, especially on Phase 1 ecommerce surfaces
- support replay and backfill without corrupting idempotent metrics
- maintain timezone-safe timestamps and explicit event / ingestion times
- protect sensitive fields at rest and in transit

## 25. Analytics / Auditability Requirements

This feature is itself an analytics subsystem, but it also has auditability obligations:

- reconstruct a sample path from impression to purchase using `recommendationSetId` and `traceId`
- show which experiment, campaign, rules, and overrides were active for a recommendation set
- retain metric-definition lineage so teams know which formula and window produced a chart
- preserve enough context for `explainability-and-auditability.md` to answer "why did this set perform this way?"
- distinguish measured facts from inferred attribution
- keep dashboard annotations for rollout, pause, campaign launch, and emergency governance changes

## 26. Testing Requirements

- schema contract tests for every event family
- producer tests for ecommerce, server fallback, and later-phase channel emitters
- experiment assignment balance tests and stickiness checks
- load tests for peak ecommerce traffic and replay scenarios
- data-quality monitors for missing IDs, null critical fields, and duplicate rates
- attribution tests using synthetic order timelines, anonymous-to-known stitching, and overlapping exposures
- privacy and permissions tests for row-level security and masked fields
- dashboard acceptance tests for metric consistency across surfaces

## 27. Recommended Architecture

Recommended logical flow:

`producers (web, server fallback, backend, channel integrations) -> validation / enrichment -> event stream -> warehouse raw + normalized layers -> semantic metric layer -> BI dashboards / alerts / experiment analysis`

Supporting services:

- experiment assignment service or integrated experimentation platform
- governance annotation feed
- trace lookup service for drilldown
- data quality and replay tooling

The architecture should keep event semantics centralized even if physical transport differs by producer. Analytics must remain a shared subsystem, not channel-specific logic duplicated inside every consumer.

## 28. Recommended Technical Design

- propagate `recommendationSetId` and `traceId` as first-class fields in all delivery and telemetry helpers
- use schema versioning and compatibility checks before rollout of new event fields
- assign idempotency keys to prevent duplicate counts during retries and re-renders
- capture `eventSource` so browser vs server-fallback behavior can be measured instead of hidden
- preserve experiment metadata at exposure time rather than reconstructing it later from mutable configs
- build a semantic metric layer for definitions such as conversion uplift, attach rate, dismiss rate, and low-confidence attribution rate
- support replay from raw accepted events rather than depending only on aggregated tables
- annotate metric changes and dashboard definitions when formulas or attribution windows change

## 29. Suggested Implementation Phasing

- **Phase 1:** PDP and cart telemetry foundation for RTW ecommerce; canonical event families; server fallback path for impressions; purchase linkage; basic experiment hooks; telemetry health dashboard
- **Phase 2:** Expanded ecommerce placements plus email measurement; stronger cohort slicing; richer attribution and governance views
- **Phase 3:** Clienteling and cross-channel comparison; operator-facing experiment console maturity; broader anomaly and guardrail workflows
- **Later maturity:** more advanced causal analysis, richer baseline policy, and automated governance-aware experiment controls after `DEC-007` decisions are resolved

Phase 1 should optimize for trustworthy telemetry coverage and schema stability rather than advanced statistical sophistication.

## 30. Summary

Analytics and experimentation is a production-critical platform feature, not optional instrumentation. The implementation bar is:

- stable recommendation identifiers across delivery and outcomes
- consistent event definitions across surfaces
- honest attribution with visible confidence
- experiment context preserved at exposure time
- governance changes visible in analysis
- enough trace linkage that teams can debug and improve recommendation behavior responsibly

The remaining open items are real downstream decisions, not excuses to delay the foundational schema and telemetry contract. Phase 1 should lock the semantic event model early, then let architecture resolve transport, assignment, and attribution-policy details through `DEC-006` and `DEC-007`.
