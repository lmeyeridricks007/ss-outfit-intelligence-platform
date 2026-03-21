# Analytics and experimentation

## Traceability / sources

| Kind | Reference |
|------|-----------|
| Canonical product | `docs/project/goals.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md` (BR-10), `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md` |
| Business requirement | `docs/project/br/br-010-analytics-and-experimentation.md` |
| Adjacent BR (governance, source blend) | `docs/project/br/br-009-merchandising-governance.md`, `docs/project/br/br-005-curated-plus-ai-recommendation-model.md` |
| Delivery & review | `docs/project/agent-operating-model.md`, `docs/project/review-rubrics.md` |
| Data & identity (events) | `docs/project/data-standards.md` (where event and ID conventions apply) |

This feature deep-dive implements **BR-10** and **business-requirements.md §BR-10**. It must remain consistent with **BR-009** (governed changes, overrides, campaign influence in telemetry) and **BR-005** (curated / rule-based / AI-ranked context in events and experiments).

---

## 1. Purpose

Define how the platform captures **recommendation telemetry**, preserves **attribution continuity** from impression through outcomes, supports **experimentation** within governance guardrails, and exposes **metrics and reporting views** so product, analytics, merchandising, and operations can measure influence, compare surfaces, and detect operational or measurement degradation.

---

## 2. Core Concept

Recommendation value is only provable when **exposure, engagement, commerce outcomes, and governance signals** share stable identifiers and semantics. Analytics and experimentation are a **cross-cutting capability**: they bind the delivery API, channel consumers, event pipeline, and reporting layer into one measurable loop, with **experiment classes** that never bypass hard compatibility, consent, or policy boundaries.

---

## 3. Why This Feature Exists

Without shared events and attribution, teams cannot tell whether recommendations improved attachment and conversion or merely appeared on the page. Without guardrailed experiments, optimization risks opaque trade-offs or governance bypass. Phase 1 roadmap themes explicitly require **telemetry for impressions, clicks, add-to-cart, and purchases** and **basic experimentation and analytics instrumentation** before broader rollout (`docs/project/roadmap.md`).

---

## 4. User / Business Problems Solved

- **Attribution gaps:** Surfaces report success inconsistently; outcomes cannot be tied to recommendation sets.
- **Non-comparable optimization:** Experiments lack stable variant context or break trend continuity.
- **False confidence:** Uplift is interpreted while telemetry is incomplete or degraded modes are invisible.
- **Governance blind spots:** Overrides, fallbacks, and campaign influence are invisible in performance analysis.
- **Operational blindness:** API degradation or coverage drops are mistaken for poor ranking.

---

## 5. Scope

**In scope:** Event semantics and required fields for recommendation analytics; attribution continuity; experiment visibility and guardrails; metric definitions and reporting cuts; telemetry-quality and operational health signals; cross-channel comparability where the same delivery contract applies.

**Boundary:** This document specifies *what* must be measured and *which context* must flow; it does not mandate a specific warehouse, stream processor, or dashboard vendor.

---

## 6. In Scope

- Impression, interaction, commerce outcome, governance, and degradation-related events (where applicable per surface).
- Minimum attribution context (recommendation set ID, trace ID, type, surface, channel, source blend, experiment variant, governance identifiers when material).
- Experiment classes aligned with BR-010 §9 and guardrails in §9.4.
- Reporting views: funnel, surface/channel, experiment, merchandising/governance impact, telemetry quality, operational health.
- Success metrics and interpretation rules per BR-010 §8 and `docs/project/goals.md` success criteria.

---

## 7. Out of Scope

- Final choice of analytics stack, BI tool, or experimentation SaaS.
- Statistical design (power analysis, sequential testing) beyond business guardrails.
- Channel-specific UI widget code (covered under channel build artifacts).
- Full legal retention schedules (retention expectations for traces overlap with explainability BR-011; exact durations remain a policy decision).

---

## 8. Main User Personas

- **Product & analytics:** Measure performance, run experiments, segment by surface and type.
- **Merchandising & governance:** See impact of curated looks, campaigns, overrides, fallbacks.
- **Marketing & lifecycle:** Compare recommendation-enabled activations with shared semantics.
- **Clienteling leaders:** Assess assisted-selling credibility with comparable signals where workflows allow.
- **Platform & data ops:** Monitor telemetry completeness, attribution health, experiment exposure, API SLO impact on measurement.

---

## 9. Main User Journeys

1. **Baseline measurement:** Surface renders recommendations → impression fired with set/trace context → user clicks → ATC/purchase attributed where rules allow → funnel and influence reports updated.
2. **Experiment review:** Operator assigns or inherits variant → telemetry carries experiment/variant → reporting compares baseline vs variant with guardrail metrics (dismiss, coverage, fallback rate).
3. **Governance impact analysis:** Override or campaign activates → events or joined governance signals show material influence → merchandising report ties performance shift to governance objects.
4. **Operational triage:** Drop in conversion coincides with spike in partial attribution or API errors → operational dashboard flags telemetry or delivery degradation vs ranking quality.

---

## 10. Triggering Events / Inputs

- **Delivery:** Successful recommendation API response (and optionally “empty” or fallback responses per standards).
- **Consumer:** Module rendered or otherwise exposed (impression), user interactions (click, save, dismiss, channel equivalents).
- **Commerce:** Add-to-cart, purchase, or channel-specific influenced outcomes.
- **Governance:** Override applied, fallback activated, campaign priority materially affecting set (per BR-010 §6.4).
- **System:** Attribution degraded, missing IDs, latency SLO breach affecting exposure.

---

## 11. States / Lifecycle

- **Instrumentation lifecycle:** `not_instrumented` → `instrumented_beta` → `stable_semantics` (schema versioned when semantics change).
- **Attribution lifecycle:** `exposure_recorded` → `interaction_optional` → `outcome_attributed` / `outcome_not_attributable` / `attribution_degraded` (explicit state for partial joins).
- **Experiment lifecycle:** `draft` → `running` → `paused` → `completed`; telemetry must reflect active vs historical experiments for trend analysis.
- **Reporting freshness:** `real_time_operational` vs `batch_analytical` — expectations should be documented per report type (open decision where not yet fixed).

---

## 12. Business Rules

- Every customer-facing recommendation feature must include telemetry for **impression, click, add-to-cart, purchase, dismiss** where applicable (`docs/project/standards.md` §5).
- Experiments must **not** bypass hard compatibility, consent, privacy, inventory, or merchandising safety rules (BR-010 §9.4; `docs/project/standards.md` §5).
- Success interpretation must balance **commercial, product, telemetry-quality, and guardrail** outcomes (BR-010 §8.6).
- Core event semantics must remain **stable enough for trend analysis**; breaking changes require explicit reporting treatment (BR-010 §4.5, §9.4).
- Source-blend context (**curated / rule-based / AI-ranked / blended / fallback**) must be representable in analytics to align with BR-005 and BR-009.

---

## 13. Configuration Model

- **Event schema registry:** Versioned event types and required fields; deprecation policy for semantic changes.
- **Attribution windows:** Per-surface or per-channel configuration (values TBD — listed under open questions).
- **Experiment definitions:** Experiment ID, variant IDs, eligibility scope, guardrail metric thresholds (owned jointly with governance).
- **Reporting catalogs:** Curated dimensions (surface, channel, recommendation type, market, experiment, source mode).
- **Feature flags:** Safe rollout of instrumentation fixes without conflating with ranking experiments.

---

## 14. Data Model

**Conceptual entities (logical, not physical tables):**

- **RecommendationEvent:** `eventType`, `timestamp`, `recommendationSetId`, `traceId`, `recommendationType`, `surface`, `channel`, `customerOrSessionRef`, `productIds`, `lookIds`, `experimentId`, `variantId`, `sourceMode`, `governanceRefs` (override, campaign, rule ids when material), `degradationFlags`, `schemaVersion`.
- **OutcomeEvent:** Same attribution keys where influenced-outcome logic applies; `attributionStatus`.
- **ExperimentAssignment:** Stable assignment record within scope (implementation detail).
- **TelemetryQualitySnapshot:** Aggregates on ID completeness, join rates, latency buckets.

Align field naming and identity rules with `docs/project/data-standards.md` where it defines recommendation telemetry expectations.

---

## 15. Read Model / Projection Needs

- **Funnel projections:** Impression → interaction → ATC → purchase by slice.
- **Experiment projections:** Baseline vs variant with guardrails (dismiss rate, coverage, fallback rate).
- **Governance projections:** Performance correlated with override/campaign/fallback prevalence.
- **Operational projections:** API latency/availability vs impression volume and error rates.
- **Executive summaries:** Phase readiness (e.g., Phase 1 → Phase 2) using roadmap-style checkpoints.

---

## 16. APIs / Contracts

- **Delivery API:** Response payloads expose or imply **recommendation set ID**, **trace ID**, and **decision context** consumable by clients for event enrichment (`docs/project/architecture-overview.md`).
- **Ingestion contracts:** Normalized event envelope accepted from web, app, email, clienteling adapters with consistent core fields.
- **Query/reporting APIs (internal):** Read interfaces for dashboards (implementation phase); contracts must support dimensions in BR-010 §10.
- **Experiment service contract:** Expose active experiment + variant to callers or embed in response metadata per architecture split (TBD).

---

## 17. Events / Async Flows

- **Async publishing:** Events emitted to stream or batch landing with at-least-once semantics; idempotency keys on `(recommendationSetId, eventType, clientEventId)` where duplicates are likely.
- **Late events:** Rules for how late impressions/outcomes affect attribution windows.
- **Cross-channel:** Email open/click and clienteling interactions map to shared semantics where possible without forcing misleading equivalence (BR-010 open questions).
- **Governance side-effects:** Governance audit events (BR-009) may join to recommendation events for explainability; analytics consumes summarized linkage.

---

## 18. UI / UX Design

- **Internal dashboards:** Funnel, experiment, governance-impact, telemetry-quality, and operational panels with consistent definitions.
- **Drill-down:** From aggregate metric to dimensional breakdown (surface, type, market, experiment).
- **Trust cues:** Show data-quality warnings when attribution is partial or degraded.
- **Customer-facing:** No sensitive profile reasoning in analytics views surfaced to shoppers (`docs/project/business-requirements.md` §8 constraints).

---

## 19. Main Screens / Components

- Recommendation performance overview (by surface/channel/type).
- Experiment monitor (active experiments, variants, guardrails).
- Merchandising impact view (campaign/override/fallback correlation — with causal caution in copy).
- Telemetry health dashboard (ID completeness, join rates, schema violations).
- Operational health (API SLOs, error budgets, coverage gaps).

---

## 20. Permissions / Security Rules

- Customer-level analytics restricted by **consent and regional policy** (BR-010 §7.5; `docs/project/standards.md` §8).
- Role-based access: merchandising vs analytics vs support — detailed matrix deferred to security architecture.
- No exposure of raw internal trace payloads meant for operators in customer-facing surfaces.

---

## 21. Notifications / Alerts / Side Effects

- Alerts on **sustained attribution breakage**, **experiment exposure imbalance**, **spike in fallback rate**, or **schema violation rates**.
- Optional notifications to merchandising when experiments or overrides correlate with guardrail breaches (thresholds TBD).

---

## 22. Integrations / Dependencies

- **Recommendation engine & delivery API:** Source of set/trace IDs and decision context.
- **Channel consumers:** Instrumentation adapters (web, app, email, clienteling).
- **Commerce systems:** ATC and purchase events with join keys.
- **Governance services (BR-009):** Campaign, override, rule identifiers and audit timestamps for joins.
- **Identity service:** Customer vs anonymous session handling per `docs/project/architecture-overview.md`.
- **Explainability (BR-011):** Shared identifiers enable cross-tool investigation; analytics does not duplicate full trace UI.

---

## 23. Edge Cases / Failure Cases

- Multiple recommendation modules in one session → **attribution attribution rules** to avoid double-counting (open decision).
- Empty recommendation or fallback-only response → still emit **exposure/degradation** semantics.
- Client fails to fire impression → outcome-only signals risk misleading conversion rates; telemetry-quality metrics must surface this.
- Experiment assignment lost on reload → sticky assignment rules per channel.
- Consent withdrawal mid-journey → halt customer-level joins while preserving aggregate-safe reporting.

---

## 24. Non-Functional Requirements

- **Completeness:** Track % of impressions with valid `recommendationSetId` and `traceId` (BR-010 §8.3).
- **Latency:** Operational dashboards within agreed freshness; analytical warehouse may lag (explicitly documented).
- **Reliability:** Event pipeline resilient to bursts (e.g., campaigns); dead-letter handling for poison events.
- **Scalability:** Handle growth in surfaces, markets, and experiment cardinality without unbounded cardinality explosions in key dimensions (governance on custom dimensions).

---

## 25. Analytics / Auditability Requirements

This feature *is* the analytics backbone; auditability complements **BR-011**:

- Events must support reconstruction of **which experiment, source mode, and governance objects** correlated with performance (not necessarily full trace dump).
- Immutable or append-only raw event store recommended for forensic replay.
- Changes to semantic definitions require **version stamps** and migration notes for analysts.

---

## 26. Testing Requirements

- Contract tests on event payloads against schema registry.
- End-to-end tests: API response → impression → interaction → outcome join within attribution window.
- Experiment tests: variant context present in all required events.
- Chaos or failure injection: pipeline degradation surfaces in telemetry-quality metrics.
- Regression tests when governance identifiers change shape.

---

## 27. Recommended Architecture

- **Instrumentation SDK** shared across channels wrapping delivery metadata.
- **Event normalization service** mapping source-specific events to canonical model.
- **Experiment assignment service** integrated at API edge or client per performance and consistency tradeoffs.
- **Analytics store** (warehouse/lake) with curated marts for funnels, experiments, and ops.
- **Governance correlation** via batch joins or streaming enrichments.

---

## 28. Recommended Technical Design

- Standard envelope: `eventId`, `occurredAt`, `schemaVersion`, `payload`, `ingestionMetadata`.
- Strongly typed `sourceMode` enum: `curated`, `rule_based`, `ai_ranked`, `blended`, `fallback`.
- **Attribution graph:** exposure fact table + outcome fact table + bridge on `recommendationSetId`/`traceId` within window.
- **Guardrail dashboard queries** pre-aggregated to avoid analyst error.

---

## 29. Suggested Implementation Phasing

1. **Phase 1:** PDP/cart RTW loop — impression, click, ATC, purchase; set/trace continuity; minimal experiment hooks; baseline dashboards and telemetry-quality panel.
2. **Phase 2:** Richer segmentation (known customer where permitted); contextual/personal recommendation reporting.
3. **Phase 3:** Email and clienteling event mapping; merchandising-focused governance correlation views; mature experiment operations.

Aligned with `docs/project/roadmap.md` phases.

---

## 30. Summary

Analytics and experimentation make recommendation investment **measurable, comparable, and safely optimizable**. The capability rests on **stable IDs**, **rich but policy-safe context**, **guardrailed experiment classes**, and **reporting that separates true uplift from measurement or operational failure**—as specified in BR-010 and reinforced by governance (BR-009) and source-blend (BR-005) context.

---

## 31. Assumptions

- Phase 1 surfaces generate sufficient volume for meaningful baselines (BR-010 §14).
- Delivery API can consistently return or propagate **recommendation set ID** and **trace ID** to all first-party consumers.
- A shared schema registry can be owned by platform/data engineering with product governance on semantic changes.
- Warehouse/stream technology will support joins between recommendation events and commerce events within defined windows.
- Internal users accept separate **operational real-time** vs **analytical batch** freshness for some reports.

---

## 32. Open Questions / Missing Decisions

- **Attribution windows** per surface and outcome type (BR-010 §15).
- **Non-click interaction** equivalents (save, dismiss) on clienteling and email (BR-010 §15).
- **Multi-module attribution** when several recommendation blocks appear in one session.
- **Minimum reporting latency** for daily optimization vs executive reporting (BR-010 §15).
- **First experiment classes** to implement (ranking-only vs source-blend vs presentation vs fallback) (BR-010 §15).
- **Holdout / baseline model** balancing risk and statistical trust (BR-010 §15).
- **Exact ownership** of experiment configuration UI vs API-only configuration.
- **Cardinality and PII policies** for custom breakdown dimensions in self-serve analytics.
