# Feature index

Sub-feature capability index generated from the feature deep-dives in `docs/features/`. The feature deep-dives remain the source of truth; this index records the capability-level breakdown for downstream architecture and implementation planning.

## Coverage summary

- **Feature count:** 12
- **Sub-feature specification count:** 71
- **Primary source:** `docs/features/feature-spec-index.md`
- **Generated artifact root:** `docs/features/sub-features/`

## Feature table

| Feature | Feature slug | Description | Priority | Dependencies | Source deep-dive | Sub-feature count | Sub-feature folder |
| --- | --- | --- | --- | --- | --- | ---: | --- |
| Catalog and Eligibility Foundation | `catalog-and-eligibility-foundation` | Canonical product modeling, normalization, and recommendation-time eligibility for catalog-aware recommendation flows. | P0 | Source catalog and inventory systems; docs/project/data-standards.md; docs/project/business-requirements.md (BR-8) | `docs/features/catalog-and-eligibility-foundation.md` | 6 | `docs/features/sub-features/catalog-and-eligibility-foundation/` |
| Customer Identity and Profile | `customer-identity-and-profile` | Canonical customer identity, profile projection, and consent-aware activation for recommendation scenarios. | P0 | Event and session identifiers; Privacy and consent policy; docs/project/business-requirements.md (BR-12) | `docs/features/customer-identity-and-profile.md` | 6 | `docs/features/sub-features/customer-identity-and-profile/` |
| Customer Signal Activation | `customer-signal-activation` | Ingest, classify, and activate customer signals within governance, freshness, and traceability bounds. | P1 | Customer identity and profile; Event pipeline; docs/project/br/br-006-customer-signal-usage.md | `docs/features/customer-signal-activation.md` | 6 | `docs/features/sub-features/customer-signal-activation/` |
| Context Engine | `context-engine` | Normalize contextual inputs such as market, weather, season, and occasion into recommendation-ready signals with precedence and traceability. | P1 | Catalog and eligibility foundation; Delivery request shape; docs/project/br/br-007-context-aware-logic.md | `docs/features/context-engine.md` | 6 | `docs/features/sub-features/context-engine/` |
| Look Graph and Compatibility | `look-graph-and-compatibility` | Curated looks, compatibility graph edges, and rule evaluation that produce safe candidate relationships for recommendation assembly. | P0 | Catalog and eligibility foundation; Merchandising governance; docs/project/br/br-001-complete-look-recommendation-capability.md | `docs/features/look-graph-and-compatibility.md` | 5 | `docs/features/sub-features/look-graph-and-compatibility/` |
| Recommendation Orchestration and Types | `recommendation-orchestration-and-types` | Assemble curated, rule-based, and AI-ranked recommendation sets across multiple recommendation types with safe fallback behavior. | P0 | Look graph and compatibility; Catalog and eligibility foundation; Context and signals as phased | `docs/features/recommendation-orchestration-and-types.md` | 6 | `docs/features/sub-features/recommendation-orchestration-and-types/` |
| RTW and CM Mode Orchestration | `rtw-and-cm-mode-orchestration` | Keep ready-to-wear and custom-made recommendation journeys distinct while sharing a governed orchestration backbone. | P1 | Recommendation orchestration; Look graph and compatibility; docs/project/br/br-004-rtw-and-cm-support.md | `docs/features/rtw-and-cm-mode-orchestration.md` | 6 | `docs/features/sub-features/rtw-and-cm-mode-orchestration/` |
| Delivery API and Channel Adapters | `delivery-api-and-channel-adapters` | Provide versioned delivery contracts and per-channel adapters that expose recommendation outputs without forking core decision logic. | P0 | Recommendation orchestration outputs; Telemetry IDs; docs/project/br/br-003-multi-surface-delivery.md | `docs/features/delivery-api-and-channel-adapters.md` | 6 | `docs/features/sub-features/delivery-api-and-channel-adapters/` |
| Ecommerce Surface Activation | `ecommerce-surface-activation` | Activate recommendation experiences across ecommerce surfaces with channel-specific module behavior, telemetry, and degradation UX. | P0/P1 | Delivery API and channel adapters; UI standards as applicable; docs/project/br/br-003-multi-surface-delivery.md | `docs/features/ecommerce-surface-activation.md` | 6 | `docs/features/sub-features/ecommerce-surface-activation/` |
| Merchandising Governance | `merchandising-governance` | Govern curated looks, rules, campaigns, and overrides so merchandising can steer outcomes with explicit approvals and auditability. | P1 | Look graph and compatibility; Recommendation orchestration; docs/project/br/br-009-merchandising-governance.md | `docs/features/merchandising-governance.md` | 6 | `docs/features/sub-features/merchandising-governance/` |
| Analytics and Experimentation | `analytics-and-experimentation` | Measure recommendation performance and govern experiments using stable telemetry, attribution logic, and data quality controls. | P0/P1 | Delivery and event contracts; docs/project/br/br-010-analytics-and-experimentation.md | `docs/features/analytics-and-experimentation.md` | 6 | `docs/features/sub-features/analytics-and-experimentation/` |
| Explainability and Auditability | `explainability-and-auditability` | Expose recommendation reasoning, provenance, and governance lineage to internal operators without leaking unsafe detail to customer-facing surfaces. | P1 | Analytics events; Merchandising governance; docs/project/br/br-011-explainability-and-auditability.md | `docs/features/explainability-and-auditability.md` | 6 | `docs/features/sub-features/explainability-and-auditability/` |

## Review and audit artifacts

- Review pass: [`docs/features/deep-dives/reviews/sub-feature-capability-specifications-review.md`](deep-dives/reviews/sub-feature-capability-specifications-review.md)
- Audit pass: [`docs/features/sub-features/audits/sub-feature-capability-specifications-audit.md`](sub-features/audits/sub-feature-capability-specifications-audit.md)

## Feature breakdown

## Catalog and Eligibility Foundation

- **Feature deep-dive:** `docs/features/catalog-and-eligibility-foundation.md`
- **Priority:** P0
- **Dependencies:** Source catalog and inventory systems; docs/project/data-standards.md; docs/project/business-requirements.md (BR-8)
- **Sub-feature folder:** `docs/features/sub-features/catalog-and-eligibility-foundation/`
- **Sub-features:**
  - [`canonical-product-and-mapping`](sub-features/catalog-and-eligibility-foundation/canonical-product-and-mapping.md) - Maintain stable canonical product identifiers and source-system mappings so every downstream recommendation path resolves the same product and variant entities.
  - [`governed-product-attributes`](sub-features/catalog-and-eligibility-foundation/governed-product-attributes.md) - Define the governed attribute taxonomy used by compatibility, context, ranking, and surface presentation logic.
  - [`inventory-eligibility-projection`](sub-features/catalog-and-eligibility-foundation/inventory-eligibility-projection.md) - Combine inventory, assortment, and market policy into a recommendation-ready eligibility projection with explicit reason codes.
  - [`catalog-ingestion-lifecycle`](sub-features/catalog-and-eligibility-foundation/catalog-ingestion-lifecycle.md) - Move source product data through raw, normalized, validated, and recommendation-ready lifecycle states with explicit quarantine handling.
  - [`catalog-read-apis-and-events`](sub-features/catalog-and-eligibility-foundation/catalog-read-apis-and-events.md) - Expose low-latency catalog and eligibility reads plus change events for graph builds, serving paths, and analytics consumers.
  - [`catalog-quality-monitoring`](sub-features/catalog-and-eligibility-foundation/catalog-quality-monitoring.md) - Track catalog quality, feed freshness, mapping conflicts, and recommendation-readiness so degraded modes are visible and actionable.

## Customer Identity and Profile

- **Feature deep-dive:** `docs/features/customer-identity-and-profile.md`
- **Priority:** P0
- **Dependencies:** Event and session identifiers; Privacy and consent policy; docs/project/business-requirements.md (BR-12)
- **Sub-feature folder:** `docs/features/sub-features/customer-identity-and-profile/`
- **Sub-features:**
  - [`canonical-customer-and-identifier-graph`](sub-features/customer-identity-and-profile/canonical-customer-and-identifier-graph.md) - Resolve source-specific customer identifiers into a canonical customer graph that downstream recommendation services can trust.
  - [`merge-confidence-and-gating`](sub-features/customer-identity-and-profile/merge-confidence-and-gating.md) - Assign confidence to identity merges and gate downstream personalization behavior based on that confidence.
  - [`consent-suppression-profile-facets`](sub-features/customer-identity-and-profile/consent-suppression-profile-facets.md) - Project only consent-approved and suppression-aware customer profile facets into recommendation-serving paths.
  - [`recommendation-profile-projection`](sub-features/customer-identity-and-profile/recommendation-profile-projection.md) - Serve recommendation-specific customer profile projections that contain only the fields needed for personalization and traceability.
  - [`session-anonymous-linking`](sub-features/customer-identity-and-profile/session-anonymous-linking.md) - Link anonymous session activity to canonical customers when allowed so recommendations can bridge pre-login and post-login behavior safely.
  - [`identity-profile-observability`](sub-features/customer-identity-and-profile/identity-profile-observability.md) - Measure identity coverage, merge quality, consent application, and projection freshness for downstream recommendation reliability.

## Customer Signal Activation

- **Feature deep-dive:** `docs/features/customer-signal-activation.md`
- **Priority:** P1
- **Dependencies:** Customer identity and profile; Event pipeline; docs/project/br/br-006-customer-signal-usage.md
- **Sub-feature folder:** `docs/features/sub-features/customer-signal-activation/`
- **Sub-features:**
  - [`signal-ingestion-and-normalization`](sub-features/customer-signal-activation/signal-ingestion-and-normalization.md) - Normalize web, commerce, loyalty, and clienteling signals into a shared recommendation event model.
  - [`signal-classification-and-policy-gates`](sub-features/customer-signal-activation/signal-classification-and-policy-gates.md) - Classify customer signals by activation policy so only approved signals influence recommendations.
  - [`freshness-tiers-and-decay`](sub-features/customer-signal-activation/freshness-tiers-and-decay.md) - Group signals into freshness tiers and decay windows so recent behavior can influence recommendations without overpowering durable profile facts.
  - [`surface-channel-activation-matrix`](sub-features/customer-signal-activation/surface-channel-activation-matrix.md) - Define which signal classes can influence each surface and channel so personalization remains predictable and governable.
  - [`signal-trace-attribution`](sub-features/customer-signal-activation/signal-trace-attribution.md) - Record which customer signals were used, ignored, stale, or blocked so recommendation traces remain explainable and measurable.
  - [`signal-pipeline-operations`](sub-features/customer-signal-activation/signal-pipeline-operations.md) - Operate the customer signal pipeline with replay, dead-letter handling, freshness diagnostics, and SLA monitoring.

## Context Engine

- **Feature deep-dive:** `docs/features/context-engine.md`
- **Priority:** P1
- **Dependencies:** Catalog and eligibility foundation; Delivery request shape; docs/project/br/br-007-context-aware-logic.md
- **Sub-feature folder:** `docs/features/sub-features/context-engine/`
- **Sub-features:**
  - [`context-ingestion-and-taxonomies`](sub-features/context-engine/context-ingestion-and-taxonomies.md) - Ingest geographic, temporal, weather, and occasion context into shared taxonomies that recommendation services can use consistently.
  - [`context-snapshot-and-classification`](sub-features/context-engine/context-snapshot-and-classification.md) - Assemble a request-specific context snapshot that classifies context by durability, confidence, and recommendation relevance.
  - [`precedence-and-conflict-resolution`](sub-features/context-engine/precedence-and-conflict-resolution.md) - Resolve conflicting context signals with a deterministic precedence model that favors explicit and high-confidence inputs.
  - [`surface-channel-context-policies`](sub-features/context-engine/surface-channel-context-policies.md) - Define how strongly context can influence each surface and channel so context-aware recommendations remain appropriate.
  - [`context-provider-adapters`](sub-features/context-engine/context-provider-adapters.md) - Integrate external context providers through adapter contracts that isolate provider-specific schemas, availability, and retry logic.
  - [`context-telemetry-and-fallbacks`](sub-features/context-engine/context-telemetry-and-fallbacks.md) - Measure context influence, provider health, and fallback usage so context-aware recommendation behavior remains explainable and safe.

## Look Graph and Compatibility

- **Feature deep-dive:** `docs/features/look-graph-and-compatibility.md`
- **Priority:** P0
- **Dependencies:** Catalog and eligibility foundation; Merchandising governance; docs/project/br/br-001-complete-look-recommendation-capability.md
- **Sub-feature folder:** `docs/features/sub-features/look-graph-and-compatibility/`
- **Sub-features:**
  - [`curated-look-authoring`](sub-features/look-graph-and-compatibility/curated-look-authoring.md) - Author complete-look definitions with stable IDs, slots, alternates, and lifecycle control for downstream recommendation assembly.
  - [`outfit-graph-and-relationships`](sub-features/look-graph-and-compatibility/outfit-graph-and-relationships.md) - Represent product-to-product, product-to-look, and slot relationship edges for low-latency retrieval of compatible outfit candidates.
  - [`compatibility-and-exclusion-rules`](sub-features/look-graph-and-compatibility/compatibility-and-exclusion-rules.md) - Apply hard and soft compatibility rules so invalid combinations are blocked and valid combinations carry explicit rationale.
  - [`assembly-read-models`](sub-features/look-graph-and-compatibility/assembly-read-models.md) - Publish low-latency read models that expose eligible complements, active looks, and compatibility annotations to orchestration services.
  - [`graph-lifecycle-and-events`](sub-features/look-graph-and-compatibility/graph-lifecycle-and-events.md) - Operate look graph publication, rebuild jobs, and downstream notifications so compatible candidate retrieval remains current and auditable.

## Recommendation Orchestration and Types

- **Feature deep-dive:** `docs/features/recommendation-orchestration-and-types.md`
- **Priority:** P0
- **Dependencies:** Look graph and compatibility; Catalog and eligibility foundation; Context and signals as phased
- **Sub-feature folder:** `docs/features/sub-features/recommendation-orchestration-and-types/`
- **Sub-features:**
  - [`recommendation-type-taxonomy`](sub-features/recommendation-orchestration-and-types/recommendation-type-taxonomy.md) - Maintain the governed taxonomy of recommendation types and overlays so each response has explicit semantic meaning across surfaces and analytics.
  - [`candidate-provider-orchestration`](sub-features/recommendation-orchestration-and-types/candidate-provider-orchestration.md) - Coordinate candidate providers across curated, graph, rule, context, and behavioral sources into a common retrieval flow.
  - [`governance-eligibility-ranking-assembly`](sub-features/recommendation-orchestration-and-types/governance-eligibility-ranking-assembly.md) - Apply eligibility, governance, ranking, and set assembly in the required order so downstream responses remain safe and explainable.
  - [`multi-type-response-policies`](sub-features/recommendation-orchestration-and-types/multi-type-response-policies.md) - Control how multiple recommendation types can be requested and returned in a single response without semantic ambiguity.
  - [`fallback-and-empty-states`](sub-features/recommendation-orchestration-and-types/fallback-and-empty-states.md) - Define the fallback ladder and explicit empty-state behavior for recommendation sets when data, providers, or policies prevent ideal results.
  - [`trace-and-decision-metadata`](sub-features/recommendation-orchestration-and-types/trace-and-decision-metadata.md) - Attach durable recommendation set identifiers and decision metadata so outputs remain measurable, auditable, and explainable.

## RTW and CM Mode Orchestration

- **Feature deep-dive:** `docs/features/rtw-and-cm-mode-orchestration.md`
- **Priority:** P1
- **Dependencies:** Recommendation orchestration; Look graph and compatibility; docs/project/br/br-004-rtw-and-cm-support.md
- **Sub-feature folder:** `docs/features/sub-features/rtw-and-cm-mode-orchestration/`
- **Sub-features:**
  - [`mode-contracts-and-labeling`](sub-features/rtw-and-cm-mode-orchestration/mode-contracts-and-labeling.md) - Represent RTW, CM, and mixed eligibility as explicit request and response fields so downstream surfaces and analytics do not guess journey mode.
  - [`configuration-snapshot-integration`](sub-features/rtw-and-cm-mode-orchestration/configuration-snapshot-integration.md) - Consume immutable CM configuration snapshots so recommendations match the customer's in-progress custom selections.
  - [`phase-gated-cm-capabilities`](sub-features/rtw-and-cm-mode-orchestration/phase-gated-cm-capabilities.md) - Roll out CM recommendation depth progressively by phase without breaking shared recommendation contracts.
  - [`premium-guardrail-profiles`](sub-features/rtw-and-cm-mode-orchestration/premium-guardrail-profiles.md) - Constrain premium and bespoke recommendation behavior so CM suggestions remain appropriate to customer context and brand policy.
  - [`mode-aware-provider-strategies`](sub-features/rtw-and-cm-mode-orchestration/mode-aware-provider-strategies.md) - Choose provider mixes and ordering differently for RTW and CM journeys while preserving shared orchestration contracts.
  - [`cm-invalidation-and-traces`](sub-features/rtw-and-cm-mode-orchestration/cm-invalidation-and-traces.md) - Invalidate CM recommendation context when customer configuration changes and record mode-specific trace fields for audit and debugging.

## Delivery API and Channel Adapters

- **Feature deep-dive:** `docs/features/delivery-api-and-channel-adapters.md`
- **Priority:** P0
- **Dependencies:** Recommendation orchestration outputs; Telemetry IDs; docs/project/br/br-003-multi-surface-delivery.md
- **Sub-feature folder:** `docs/features/sub-features/delivery-api-and-channel-adapters/`
- **Sub-features:**
  - [`versioned-core-delivery-contract`](sub-features/delivery-api-and-channel-adapters/versioned-core-delivery-contract.md) - Expose the versioned core API contract that client channels use to request and receive recommendation results safely.
  - [`core-request-response-model`](sub-features/delivery-api-and-channel-adapters/core-request-response-model.md) - Define the canonical request and response DTOs used by all channel adapters to exchange recommendation data.
  - [`channel-adapter-layer`](sub-features/delivery-api-and-channel-adapters/channel-adapter-layer.md) - Translate canonical delivery payloads into ecommerce, email, clienteling, and future channel-specific envelopes without re-deciding recommendation logic.
  - [`fallback-timeout-degradation`](sub-features/delivery-api-and-channel-adapters/fallback-timeout-degradation.md) - Return explicit degraded responses when timeouts, empty sets, or upstream failures occur so clients can react predictably.
  - [`idempotency-caching-semantics`](sub-features/delivery-api-and-channel-adapters/idempotency-caching-semantics.md) - Define request deduplication, cache keys, and freshness semantics so repeated recommendation requests behave predictably.
  - [`integration-security-and-trace-redaction`](sub-features/delivery-api-and-channel-adapters/integration-security-and-trace-redaction.md) - Authenticate channel callers and redact internal-only trace detail so delivery remains secure and appropriately transparent.

## Ecommerce Surface Activation

- **Feature deep-dive:** `docs/features/ecommerce-surface-activation.md`
- **Priority:** P0/P1
- **Dependencies:** Delivery API and channel adapters; UI standards as applicable; docs/project/br/br-003-multi-surface-delivery.md
- **Sub-feature folder:** `docs/features/sub-features/ecommerce-surface-activation/`
- **Sub-features:**
  - [`pdp-phase1-modules`](sub-features/ecommerce-surface-activation/pdp-phase1-modules.md) - Define the product detail page recommendation modules for complete-look, cross-sell, and upsell activation in the first ecommerce phase.
  - [`cart-phase1-modules`](sub-features/ecommerce-surface-activation/cart-phase1-modules.md) - Render cart recommendation modules that complement existing basket contents without disrupting checkout intent.
  - [`homepage-phase2-modules`](sub-features/ecommerce-surface-activation/homepage-phase2-modules.md) - Support context-aware and personalized homepage recommendation modules once broader ecommerce activation is introduced.
  - [`inspiration-look-builder-handoff`](sub-features/ecommerce-surface-activation/inspiration-look-builder-handoff.md) - Carry recommendation context across inspiration and look-builder experiences into anchor commerce journeys without losing trace continuity.
  - [`ecommerce-telemetry-client-contract`](sub-features/ecommerce-surface-activation/ecommerce-telemetry-client-contract.md) - Define the client-side telemetry contract that keeps ecommerce impression and outcome events joinable with recommendation decisions.
  - [`consent-and-degradation-ux`](sub-features/ecommerce-surface-activation/consent-and-degradation-ux.md) - Render consent-aware and degraded recommendation experiences in ecommerce without exposing internal-only reasoning or breaking shopper trust.

## Merchandising Governance

- **Feature deep-dive:** `docs/features/merchandising-governance.md`
- **Priority:** P1
- **Dependencies:** Look graph and compatibility; Recommendation orchestration; docs/project/br/br-009-merchandising-governance.md
- **Sub-feature folder:** `docs/features/sub-features/merchandising-governance/`
- **Sub-features:**
  - [`governance-object-lifecycle`](sub-features/merchandising-governance/governance-object-lifecycle.md) - Manage the draft, review, scheduled, active, and retired lifecycle of merchandising governance objects.
  - [`override-taxonomy-and-emergency-controls`](sub-features/merchandising-governance/override-taxonomy-and-emergency-controls.md) - Define override types, emergency controls, and rollback semantics for situations where merchandising needs rapid intervention.
  - [`precedence-and-conflict-resolution`](sub-features/merchandising-governance/precedence-and-conflict-resolution.md) - Resolve conflicts between campaigns, overrides, curated looks, and evergreen rules with deterministic precedence.
  - [`governance-snapshot-for-execution`](sub-features/merchandising-governance/governance-snapshot-for-execution.md) - Compile active governance objects into a low-latency snapshot that serving paths can evaluate without reconstructing lifecycle logic.
  - [`operator-impact-and-health-ux`](sub-features/merchandising-governance/operator-impact-and-health-ux.md) - Provide operator tools that preview governance impact, highlight risky changes, and surface governance health metrics.
  - [`governance-events-and-audit-pipeline`](sub-features/merchandising-governance/governance-events-and-audit-pipeline.md) - Emit governance events and immutable audit records so recommendation traces can explain who changed what, when, and why.

## Analytics and Experimentation

- **Feature deep-dive:** `docs/features/analytics-and-experimentation.md`
- **Priority:** P0/P1
- **Dependencies:** Delivery and event contracts; docs/project/br/br-010-analytics-and-experimentation.md
- **Sub-feature folder:** `docs/features/sub-features/analytics-and-experimentation/`
- **Sub-features:**
  - [`recommendation-event-model-and-registry`](sub-features/analytics-and-experimentation/recommendation-event-model-and-registry.md) - Define the canonical event model and registry used for recommendation impressions, interactions, and outcomes.
  - [`attribution-continuity-and-windows`](sub-features/analytics-and-experimentation/attribution-continuity-and-windows.md) - Link recommendation impressions and interactions to downstream outcomes using explicit attribution windows and continuity rules.
  - [`experimentation-classes-and-guardrails`](sub-features/analytics-and-experimentation/experimentation-classes-and-guardrails.md) - Run recommendation experiments within guardrails that preserve compatibility, privacy, governance, and brand safety constraints.
  - [`reporting-projections-and-dashboards`](sub-features/analytics-and-experimentation/reporting-projections-and-dashboards.md) - Project recommendation telemetry into dashboards and reports for funnel health, experiment results, governance effects, and operational quality.
  - [`cross-channel-ingestion-envelope`](sub-features/analytics-and-experimentation/cross-channel-ingestion-envelope.md) - Normalize telemetry from ecommerce, email, app, and clienteling into a shared ingestion envelope without erasing channel nuance.
  - [`telemetry-quality-and-ops-signals`](sub-features/analytics-and-experimentation/telemetry-quality-and-ops-signals.md) - Measure telemetry completeness, join quality, and pipeline health so business interpretation is not confused with data failure.

## Explainability and Auditability

- **Feature deep-dive:** `docs/features/explainability-and-auditability.md`
- **Priority:** P1
- **Dependencies:** Analytics events; Merchandising governance; docs/project/br/br-011-explainability-and-auditability.md
- **Sub-feature folder:** `docs/features/sub-features/explainability-and-auditability/`
- **Sub-features:**
  - [`decision-trace-spine-and-schema`](sub-features/explainability-and-auditability/decision-trace-spine-and-schema.md) - Define the canonical recommendation trace schema that captures request context, candidate flow, governance, experimentation, and degradation details.
  - [`delivery-trace-handles-and-summary`](sub-features/explainability-and-auditability/delivery-trace-handles-and-summary.md) - Expose delivery-safe trace handles and compact summaries so downstream systems can correlate recommendation behavior without receiving internal-only reasoning.
  - [`internal-trace-lookup-and-operator-ux`](sub-features/explainability-and-auditability/internal-trace-lookup-and-operator-ux.md) - Provide operator-facing trace lookup and progressive disclosure so support, merchandising, and engineering teams can inspect recommendation decisions responsibly.
  - [`result-level-inclusion-exclusion`](sub-features/explainability-and-auditability/result-level-inclusion-exclusion.md) - Capture result-level inclusion and exclusion rationale so operators can understand why specific items appeared or were removed.
  - [`governance-audit-linkage`](sub-features/explainability-and-auditability/governance-audit-linkage.md) - Link recommendation traces to governance audit history so operators can move from an outcome to the exact merchandising change history behind it.
  - [`trace-quality-retention-and-redaction`](sub-features/explainability-and-auditability/trace-quality-retention-and-redaction.md) - Measure trace completeness, enforce retention classes, and redact sensitive data so explainability remains useful and compliant.
