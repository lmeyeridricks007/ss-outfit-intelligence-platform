# Feature: RTW and CM mode support

**Upstream traceability:** `docs/project/business-requirements.md` (BR-004, BR-008, BR-005, BR-011); `docs/project/br/br-004-rtw-and-cm-support.md`, `br-008-product-and-inventory-awareness.md`, `br-005-curated-plus-ai-recommendation-model.md`, `br-011-explainability-and-auditability.md`; `docs/project/product-overview.md`; `docs/project/vision.md`; `docs/project/goals.md`; `docs/project/personas.md`; `docs/project/roadmap.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-012`, `DEC-015`, `DEC-016`, `DEC-017`, `DEC-025`, `DEC-027`, `DEC-036`).

---

## 1. Purpose

Define how the platform supports both **RTW** and **CM** recommendation behavior without collapsing them into one generic shopping mode.

This feature exists to keep mode differences explicit across:

- request and delivery contracts
- candidate eligibility and compatibility logic
- governance and operator involvement
- UI and copy expectations
- telemetry, experimentation, and auditability
- phased rollout sequencing

The platform should share one recommendation stack, but that shared stack must still respect that **RTW** and **CM** represent materially different customer missions, operational risks, and trust requirements.

## 2. Core Concept

`mode` is a first-class recommendation dimension that travels end-to-end through the platform.

In practical terms:

- **RTW** optimizes immediate, purchasable, inventory-valid **outfits** and complementary attachments on ecommerce-first surfaces.
- **CM** optimizes configuration-aware, premium-credible guidance that respects garment choices, fabric and palette compatibility, and higher operator-trust requirements.

The core product rule is:

> Shared contracts, governance, and telemetry should remain common across the platform, but eligibility, fallback, explanation depth, and rollout boundaries must remain mode-aware.

Mode therefore affects:

- what data is required before recommendations are allowed
- which recommendation types are appropriate on each surface
- how much AI ranking freedom is allowed
- when the result must degrade to curated or stylist-assisted guidance
- how operators and analytics teams interpret outcomes

## 3. Why This Feature Exists

The product vision explicitly calls for one recommendation platform that serves both RTW and CM journeys. That creates value only if the system preserves the real business differences between them.

Without this feature:

- RTW ecommerce flows would inherit too much CM caution and lose speed, attach quality, and simplicity
- CM experiences would inherit RTW-style shortcuts and surface recommendations that are visually plausible but configuration-unsafe
- governance would be too weak for premium styling and assisted-selling contexts
- analytics would blend unlike journeys and make rollout decisions misleading
- downstream architecture would guess at where mode differences belong, producing contract and surface drift

This feature turns BR-004 from a high-level requirement into an implementation-oriented operating model.

## 4. User / Business Problems Solved

| User / stakeholder | Problem | What this feature enables |
| --- | --- | --- |
| `P1` anchor-product shopper | Needs immediate, trustworthy outfit completion from an RTW product page or cart | Fast mode-aware RTW recommendations that stay inventory-valid and purchase-forward |
| RTW ecommerce customer | Gets confused if premium or configuration-heavy logic shows up in a self-serve shopping context | RTW-first behaviors that stay simple, explicit, and operationally valid |
| CM customer | Needs guidance that respects configured garment choices, fabrics, palettes, and premium styling rules | Configuration-aware recommendation gating and safer fallback behavior |
| `S1` stylist / clienteling associate | Cannot trust CM guidance if recommendation logic hides uncertainty or overstates compatibility | Operator-safe explanation, bounded automation, and stronger governance for CM |
| `S2` merchandiser | Needs different degrees of control for RTW attachment versus CM premium styling | Mode-specific rule strictness, curated-order policy, and rollout gating |
| `S4` analytics / optimization | Cannot evaluate rollout quality if RTW and CM are measured together as one behavior | Mode-sliced telemetry, experiment analysis, and auditability |

Business outcomes supported here:

- faster Phase 1 value on RTW ecommerce surfaces
- lower premium-trust risk during later CM expansion
- clearer rollout gates for assisted versus self-serve CM
- stronger cross-channel consistency in how RTW and CM semantics are represented

## 5. Scope

This feature defines the mode-specific product behavior that sits between shared recommendation capabilities and consuming surfaces.

It covers:

- explicit `mode` handling in requests, responses, and stored recommendation traces
- the extra data and compatibility requirements needed for CM recommendation support
- the stricter governance and explanation posture required for CM
- the RTW-first roadmap sequencing that keeps early releases measurable and safe
- surface behavior differences across ecommerce, clienteling, and later CM-enabled experiences

### Tracked open decisions

This feature depends on portfolio-level decisions already recorded in `docs/features/open-decisions.md`:

- `DEC-012` - CM digital self-service scope vs stylist-assisted scope in early phases
- `DEC-015` - category- and surface-specific readiness thresholds before recommendation eligibility
- `DEC-016` - inventory freshness windows and bounded fallback policy by surface
- `DEC-017` - minimum CM field groups and compatibility evidence required before customer-facing CM recommendations
- `DEC-025` - customer-facing explanation scope and copy boundaries
- `DEC-027` - role matrix for summary explanation, deep trace detail, and audit-history access
- `DEC-036` - curated ordering freedom by surface and mode

These remain explicit so downstream architecture and planning do not silently invent policy.

## 6. In Scope

- shared delivery-contract support for `mode: RTW | CM`
- mode-aware candidate generation, compatibility filtering, and ranking-policy selection
- RTW-first PDP and cart behavior in early phases
- CM recommendation usage in stylist-assisted or bounded digital contexts once prerequisite evidence exists
- mode-specific fallback behavior, especially when CM inputs are incomplete
- surface guidance for ecommerce, clienteling, and future channel consumers
- mode-aware telemetry, traceability, and recommendation explanation constraints
- configuration and governance rules that control when CM automation is allowed

## 7. Out of Scope

- manufacturing or tailoring execution systems
- full bespoke tailoring operations beyond recommendation support
- final CM configurator UX design or final field-level workflow behavior
- final architecture choices for serving topology, caches, or storage
- checkout, appointment-booking, or CRM redesign unrelated to mode-aware recommendations
- board-state changes, final approval claims, or downstream issue fan-out

## 8. Main User Personas

| Persona | Why this feature matters |
| --- | --- |
| `P1` Anchor-product shopper | Needs immediate RTW outfit completion that feels coherent and purchasable |
| `P2` Returning style-profile customer | May receive better RTW or later bounded CM guidance only when identity and policy allow |
| `P3` Occasion-led shopper | May start in either RTW or premium/CM intent, so mode boundaries must remain clear |
| `S1` Stylist / clienteling associate | Needs CM guidance that is explainable enough to trust and adapt in-session |
| `S2` Merchandiser | Needs stricter governance and curated control for premium or CM contexts |
| `S4` Product / analytics / optimization | Needs mode-separated telemetry and rollout evidence |

## 9. Main User Journeys

### Journey 1: RTW PDP complete-look request

1. Customer opens a PDP for an RTW anchor product.
2. Surface requests recommendations with `mode=RTW`, market, placement, and anchor-product context.
3. Shared recommendation logic applies RTW-compatible eligibility, inventory, and duplicate rules.
4. The result returns `outfit`, `cross-sell`, or `upsell` sets optimized for immediate shopping.
5. Telemetry and purchases remain tagged with `mode=RTW`.

### Journey 2: RTW cart completion flow

1. Customer mutates the cart with RTW items.
2. Cart request resolves one or more RTW anchors and current basket context.
3. The platform suppresses duplicates and ranks complementary RTW items.
4. If inventory or compatibility coverage is thin, the cart shows a smaller safe set rather than speculative attachments.

### Journey 3: Stylist-assisted CM appointment

1. A stylist opens a customer and appointment context tied to a CM journey.
2. Clienteling requests recommendations with `mode=CM` plus customer, appointment, and configuration inputs.
3. The platform validates whether enough CM evidence exists to produce configuration-aware guidance.
4. If valid, it returns curated-first or tightly governed mixed-source CM recommendations.
5. If evidence is weak, the result degrades to safer curated guidance with explicit warnings and operator visibility.

### Journey 4: Bounded digital CM flow

1. A customer uses a CM or premium advisor flow where the journey is explicitly marked as `mode=CM`.
2. Configurator selections create a `CMConfigurationSnapshot`.
3. The platform checks whether the current combination meets customer-facing CM recommendation requirements.
4. If yes, it returns bounded recommendations consistent with the selected garment state.
5. If not, it narrows the result set, asks for more input, or suppresses automation rather than overclaiming support.

### Journey 5: Cross-mode measurement and governance review

1. Merchandisers or analytics teams inspect recommendation outcomes by mode.
2. They compare RTW ecommerce attach behavior against CM-assisted guidance quality separately.
3. They review whether CM recommendations are too often degraded or manually overridden.
4. Rollout decisions use explicit mode evidence instead of blended averages.

## 10. Triggering Events / Inputs

| Trigger | Required inputs | Notes |
| --- | --- | --- |
| PDP route load | anchor product ID, market, placement, `mode` | Primary RTW Phase 1 request |
| Cart load or mutation | cart lines, market, placement, `mode` | RTW-focused early use case |
| Appointment open | customer ref, appointment ID, associate ID, `mode=CM` | Primary assisted CM request |
| CM configurator change | selected garment, fabric, palette, options, snapshot ID | May invalidate prior CM results |
| Clienteling manual refresh | customer, appointment, operator, current selections | Produces a new set and trace lineage |
| Governance snapshot change | rule IDs, campaign IDs, override context, ordering policy | May alter allowed behavior by mode |
| Identity or consent update | customer ref, confidence state, permitted-use flags | Can constrain profile-aware ranking in either mode |

Important input bundles:

- `mode`
- anchor product or cart context
- customer, appointment, and operator context where relevant
- CM configuration snapshot when present
- market, channel, and surface
- inventory freshness and catalog-readiness state
- governance snapshot and curated-order policy
- experiment and variant context

## 11. States / Lifecycle

Mode-aware recommendation behavior should preserve a reconstructable lifecycle.

### Shared recommendation lifecycle

`mode_resolved -> context_validated -> candidates_scoped -> compatibility_checked -> recommendation_ready -> degraded | suppressed -> delivered`

### CM configuration sub-lifecycle

`not_started -> partial -> validated_for_assisted_use -> validated_for_customer_facing_use -> invalidated_by_change`

State meanings:

- **`mode_resolved`** - request explicitly classified as RTW or CM
- **`context_validated`** - the platform confirms the request has enough surface and policy context to continue
- **`candidates_scoped`** - candidate pool narrowed using mode, catalog, and governance constraints
- **`compatibility_checked`** - RTW or CM mode-specific validation rules applied
- **`recommendation_ready`** - output is safe to package for the surface
- **`degraded`** - output is allowed but narrower, more curated, or less automated than ideal
- **`suppressed`** - output should not be shown because policy or evidence is insufficient
- **`validated_for_assisted_use`** - okay for stylist or operator mediation but not yet safe for direct customer-facing CM automation
- **`validated_for_customer_facing_use`** - meets the stronger bar for bounded self-serve CM exposure
- **`invalidated_by_change`** - a configuration, inventory, or governance change invalidates prior CM guidance

## 12. Business Rules

- **Mode must be explicit.** Surfaces and downstream services must not infer RTW or CM only from category heuristics when the request or product model can state it directly.
- **RTW optimizes for immediacy.** RTW outputs must favor inventory-valid, purchasable recommendations on interactive ecommerce surfaces.
- **CM optimizes for compatibility confidence.** CM outputs must not claim configuration-aware support unless the required field groups and evidence exist.
- **Hard rules outrank AI ranking in both modes.** Compatibility, policy, inventory, consent, and market readiness always win.
- **CM governance is stricter than RTW governance.** Premium styling, curated ordering, and operator review boundaries are tighter for CM than routine RTW attach flows.
- **Fallback must preserve the right recommendation meaning.** When CM evidence is weak, degrade to curated or operator-assisted guidance; do not return generic adjacency disguised as CM intelligence.
- **Customer-facing explanation stays bounded.** Especially in CM, explanation should communicate confidence and limitations without exposing internal or sensitive reasoning.
- **Mixed-mode ambiguity must be resolved deterministically.** If a surface or basket includes both RTW and CM-relevant items, a clear governing mode or split-flow strategy is required; do not silently mix semantics.

### Required precedence implications

1. readiness and compatibility gates
2. hard suppressions and exclusions
3. emergency or high-priority operator controls
4. curated ordering policy by mode and surface
5. AI ranking only within the allowed pool
6. deterministic degraded fallback or suppression

## 13. Configuration Model

| Configuration area | What it controls |
| --- | --- |
| `modePolicy` | Enables or disables RTW and CM support by market, channel, and surface |
| `cmExposurePolicy` | Assisted-only, preview-only, or customer-facing CM behavior |
| `cmEvidencePolicy` | Required field groups, compatibility thresholds, and validation classes for CM |
| `orderingFreedomPolicy` | Fixed curated order vs bounded reorder vs broader ranking freedom by mode |
| `explanationPolicy` | Customer-facing and operator-facing explanation depth by mode and role |
| `fallbackPolicy` | Suppression, curated fallback, or partial-set rules by surface and mode |
| `telemetryPolicy` | Required mode, snapshot, and override fields in telemetry and trace output |
| `alertPolicy` | Thresholds for degraded CM rates, override spikes, or repeated invalidation |

Configuration must be versioned so teams can reconstruct what mode policy was active when a recommendation set was produced.

## 14. Data Model

### Core conceptual entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `ModeContext` | Normalized request-level mode state | `mode`, `surface`, `channel`, `market`, `anchorType`, `customerRef?`, `associateRef?` |
| `CMConfigurationSnapshot` | Structured CM selection state | `snapshotId`, `garmentType`, `fabricId`, `paletteId`, `selectedOptions[]`, `validationState`, `createdAt` |
| `ModeEligibilitySummary` | Surface-safe readiness result | `mode`, `eligible`, `eligibilityClass`, `readinessReasons[]`, `freshnessTier`, `customerFacingAllowed` |
| `ModePolicySnapshot` | Effective governance and exposure rules | `policyId`, `version`, `mode`, `surface`, `orderingFreedom`, `explanationTier`, `fallbackPolicy` |
| `ModeRecommendationExplanation` | High-level rationale summary | `mode`, `sourceMix`, `configurationWarnings[]`, `operatorReviewRequired`, `degradedState` |

### Example CM configuration payload

```json
{
  "snapshotId": "cmcfg_01JPDT2TQ6V7RW4X9AA2M1P9MM",
  "mode": "CM",
  "garmentType": "suit",
  "fabricId": "fab_italian_wool_221",
  "paletteId": "pal_midnight_blue",
  "selectedOptions": [
    { "name": "lapel", "value": "peak" },
    { "name": "buttons", "value": "double_breasted" }
  ],
  "validationState": "validated_for_assisted_use"
}
```

### Data-model notes

- `mode` must be preserved at recommendation-set level, not only buried in product metadata.
- CM snapshots should be structured and versionable, not free-form blobs only.
- Explanation and telemetry payloads need both `mode` and configuration snapshot linkage where applicable.
- Stable canonical IDs from `docs/project/data-standards.md` apply equally to products, looks, rules, recommendation sets, and CM snapshots.

## 15. Read Model / Projection Needs

Required projections include:

- mode-aware product eligibility indexes
- RTW sellability and inventory freshness projections by market and surface
- CM compatibility coverage projections by garment, fabric, palette, and premium-option dimension
- customer-facing vs assisted-only CM readiness projections
- stylist-facing product and look cards enriched with mode and validation status
- governance snapshots keyed by mode and surface
- recent CM configuration history for clienteling and audit review

These projections should let serving-time logic avoid expensive raw validation for every request while still preserving accurate freshness and traceability.

## 16. APIs / Contracts

This feature depends on the shared delivery contract rather than inventing a separate RTW-only or CM-only contract family.

### Required request semantics

- `mode`
- `surface`
- `channel`
- `market`
- one of `anchorProductId`, `cart`, `occasionContext`, or `cmConfigurationSnapshot`
- `customerRef` and `identityConfidence` where permitted
- `associateRef` or `appointmentId` for assisted flows

### Required response semantics

- `recommendationSetId`
- `traceId`
- `mode`
- `recommendationType`
- `sourceMix`
- `degradedState`
- `configurationWarnings[]` where relevant
- `operatorReviewRequired` where relevant

### Example contract expectations

| Interaction | Purpose | Important semantics |
| --- | --- | --- |
| `POST /recommendations` | Standard delivery request | Must require explicit `mode` and preserve it in the response |
| `POST /recommendations/validate-mode-context` | Optional preflight validation for CM-heavy flows | Returns whether the current CM snapshot is eligible for assisted or customer-facing recommendation use |
| `POST /clienteling/recommendations` | Assisted-selling request | Supports `mode=CM`, appointment context, operator-safe explanation summary |

### Contract rules

- Consumers must not reinterpret CM degraded warnings as full-strength recommendation success.
- CM responses must not imply customer-facing validity when only assisted-use validation is met.
- RTW responses should remain lightweight enough for interactive surfaces while still preserving explicit mode.

## 17. Events / Async Flows

### Serving-time and async event families

- `mode_context.resolved`
- `cm_configuration.changed`
- `cm_configuration.validated`
- `mode_recommendation.invalidated`
- `mode_recommendation.delivered`
- `mode_recommendation.degraded`
- `mode_recommendation.suppressed`
- `clienteling_cm_recommendation.reviewed`
- `clienteling_cm_recommendation.adapted`

### Example CM invalidation flow

1. Customer or stylist changes a CM garment option.
2. The system emits `cm_configuration.changed`.
3. Existing CM recommendation sets referencing the older snapshot are marked stale.
4. Compatibility checks rerun against the new snapshot.
5. The next request either returns refreshed guidance or a degraded response with explicit warnings.

### Example RTW interactive flow

1. PDP or cart request resolves `mode=RTW`.
2. Inventory and compatibility filters run with RTW thresholds.
3. Ranked RTW recommendation sets return with trace metadata.
4. Impression, click, add-to-cart, and purchase events carry `mode=RTW`.

## 18. UI / UX Design

### RTW UX expectations

- purchase-forward module framing
- grouped **outfit** treatment on PDP and cart
- concise, shopper-facing copy
- minimal friction between recommendation and add-to-cart

### CM UX expectations

- stronger guidance that recommendation automation is bounded by current configuration evidence
- explicit distinction between stylist-reviewed and customer-facing-safe outputs
- warnings or limitation messaging when certain combinations are not validated
- restrained customer-facing explanation to avoid overclaiming confidence

### Shared UX principles

- recommendation meaning must stay explicit by type and mode
- degraded states must be honest
- surfaces must not visually flatten premium CM guidance into generic ecommerce upsell
- operator-facing views may show more context than customer-facing views, but only within allowed role boundaries

## 19. Main Screens / Components

| Surface / component | Mode relevance |
| --- | --- |
| PDP recommendation modules | Primary RTW Phase 1 consumer |
| Cart recommendation modules | RTW attach and complete-the-look behavior |
| Clienteling recommendation panel | Primary assisted CM consumer |
| CM advisor or configurator sidebar | Later-phase bounded self-serve CM surface |
| Explanation summary drawer | Operator-safe explanation for CM and premium contexts |
| Recommendation trace lookup | Cross-mode debugging and audit review |
| Governance policy inspector | Shows mode, curated-order policy, and fallback state |

## 20. Permissions / Security Rules

- CM configuration context and operator explanations may be more sensitive than anonymous RTW ecommerce traffic.
- Clienteling and CM trace access must be role-gated per `DEC-027`.
- Customer-facing surfaces must not expose internal validation states beyond approved copy boundaries.
- Associate adaptations, overrides, and share actions must be auditable.
- Cross-channel customer data usage for profile-aware ranking must respect consent and permitted-use rules in both modes.

## 21. Notifications / Alerts / Side Effects

Operational alerts should include:

- spikes in CM degraded or suppressed recommendation rates
- repeated invalidation caused by configuration changes
- unusual operator override volume in CM sessions
- stale inventory or readiness failures impacting RTW ecommerce quality
- attempts to expose CM recommendations on surfaces where policy forbids them

Side effects include:

- clienteling workflows may generate follow-up artifacts or share actions
- RTW and CM recommendation sets may need distinct dashboard slices and alert thresholds
- CM recommendation invalidation can require real-time or near-real-time refresh in assisted contexts

## 22. Integrations / Dependencies

- **Shared contracts and delivery API** - transports typed mode-aware recommendation sets
- **Catalog and product intelligence** - provides mode fields, readiness thresholds, inventory, and compatibility evidence
- **Recommendation decisioning and ranking** - applies ranking objectives and fallback rules inside mode boundaries
- **Merchandising governance and operator controls** - supplies curated-order policy, overrides, and stricter CM controls
- **Explainability and auditability** - preserves recommendation-set, snapshot, and override traceability
- **Channel expansion: email and clienteling** - consumes CM behavior primarily in assisted or later outbound contexts
- **Ecommerce surface experiences** - primary RTW surface consumer in early phases
- **Identity and style profile** - supports bounded personalization where policy allows
- **CM configurator or appointment context systems** - supply structured CM configuration state

## 23. Edge Cases / Failure Cases

- request contains mixed RTW and CM signals without an explicit governing mode
- RTW product is available but inventory freshness is stale for a high-intent surface
- CM configurator has partial selections that are good enough for stylist review but not customer-facing automation
- a curated CM look conflicts with current fabric or option selections
- a stylist and customer make conflicting changes in quick succession
- a product exists in both RTW and CM-adjacent contexts but has different readiness evidence
- identity confidence is low, but the surface still tries to use a profile-heavy recommendation objective
- policy says CM is assisted-only in a market, but a digital self-serve flow attempts to fetch CM results

Each case should result in explicit suppression, degradation, or operator review instead of silent semantic drift.

## 24. Non-Functional Requirements

- RTW interactive requests must meet ecommerce latency expectations without carrying unnecessary CM validation overhead
- CM assisted workflows may tolerate slightly higher latency if compatibility confidence materially improves
- recommendation behavior must remain deterministic for the same mode context, policy snapshot, and input state
- degraded and suppressed outcomes must be machine-readable and auditable
- freshness-sensitive checks must not be bypassed by caching or precomputation
- trace linkage between mode, configuration snapshot, and recommendation set must remain durable across systems

## 25. Analytics / Auditability Requirements

Mode-aware measurement is mandatory.

### Required analytics behaviors

- split recommendation performance by `mode`
- record separate degraded and suppressed rates for RTW and CM
- capture `configurationSnapshotId` or equivalent for CM recommendation traces
- record whether the result was customer-facing-safe or assisted-only
- preserve `recommendationSetId`, `traceId`, `mode`, `recommendationType`, rule context, and experiment context

### Required audit questions

Operators must be able to answer:

- why a request was treated as RTW or CM
- what CM evidence or validation state was present
- whether a set was degraded because of missing configuration evidence, freshness issues, or governance policy
- whether curated-order policy or operator overrides changed the final result
- whether customer-facing explanation stayed within allowed bounds

## 26. Testing Requirements

- mode-resolution tests for PDP, cart, clienteling, and CM-configurator requests
- RTW golden scenarios for PDP and cart outfit completion
- CM golden scenarios for assisted configuration-aware guidance
- contract tests ensuring `mode` survives request, response, telemetry, and trace paths
- degraded-path tests for partial CM configuration, stale inventory, and policy-blocked surfaces
- override and curated-order-policy tests by mode
- explanation-boundary tests for customer-facing vs operator-facing views
- stylist UAT for CM-assisted workflows
- regression tests when toggling market or surface enablement flags

## 27. Recommended Architecture

Recommended logical shape:

`shared request normalizer -> mode resolver -> mode policy snapshot -> mode-specific readiness and compatibility validators -> governed ranking pipeline -> trace writer -> shared delivery packager`

Key architecture principles:

- keep one shared recommendation pipeline, not separate RTW and CM products
- isolate mode-specific rules in explicit strategy or validator components
- preserve one shared telemetry and trace model with mode-aware fields
- support assisted-use and customer-facing-use validation as distinct CM outcomes
- let surfaces consume explicit mode semantics instead of inferring them locally

## 28. Recommended Technical Design

- use an explicit `mode` enum in all core request and response contracts
- implement mode-aware validation through a `ModeStrategy` or equivalent interface rather than scattered conditional logic
- model `CMConfigurationSnapshot` as a first-class structured object with versionable validation state
- keep `ModePolicySnapshot` versioned so explanation and audits can reconstruct the effective rules
- store degraded-state codes that distinguish readiness, compatibility, freshness, and policy suppression causes
- treat customer-facing CM eligibility as a stricter subset of assisted-use CM eligibility

Example logical strategy interface:

```text
ModeStrategy
  - validateContext(...)
  - eligibleCandidates(...)
  - rankingObjective(...)
  - fallbackBehavior(...)
  - explanationTier(...)
```

## 29. Suggested Implementation Phasing

### Phase 1

- RTW ecommerce support on PDP and cart
- explicit `mode` fields in shared contracts for forward compatibility
- telemetry, trace, and governance policies already carrying mode
- no broad customer-facing CM automation

### Phase 2

- preserve forward-compatible mode-aware infrastructure while personalization and context mature for RTW
- continue collecting the readiness and governance evidence needed for future CM activation

### Phase 3

- clienteling and assisted CM support with curated-first or tightly governed mixed-source logic
- operator-safe explanation, adaptation, and audit flows

### Phase 4

- deeper CM configuration-aware support
- bounded self-serve CM experiences only where `DEC-012` and `DEC-017` are resolved
- more advanced ranking once operator trust and readiness quality are established

## 30. Summary

RTW and CM mode support is the feature that keeps one recommendation platform from becoming one oversimplified recommendation behavior.

Its job is to preserve the right trade-offs:

- **RTW** should stay fast, purchasable, and ecommerce-friendly
- **CM** should stay configuration-aware, premium-safe, and governance-heavy
- both modes should still share one contract vocabulary, telemetry model, and traceability standard

The most important unresolved items are already explicit rather than hidden: early CM self-serve scope (`DEC-012`), readiness and freshness thresholds (`DEC-015`, `DEC-016`, `DEC-017`), explanation and access boundaries (`DEC-025`, `DEC-027`), and curated ordering freedom (`DEC-036`).

With those decisions tracked, this feature deep-dive is concrete enough for downstream architecture and planning to preserve RTW-first delivery while building a safe path toward richer CM support.
