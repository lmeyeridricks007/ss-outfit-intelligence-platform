# Feature: Recommendation decisioning and ranking

**Upstream traceability:** `docs/project/business-requirements.md` (BR-005, BR-002, BR-001, BR-008, BR-010, BR-011); `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`; `docs/project/br/br-002-multi-type-recommendation-support.md`; `docs/project/br/br-001-complete-look-recommendation-capability.md`; `docs/project/br/br-008-product-and-inventory-awareness.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/project/roadmap.md`; `docs/features/open-decisions.md` (`DEC-008`, `DEC-015`, `DEC-016`, `DEC-036`).

---

## 1. Purpose

Define the governed decisioning layer that turns catalog, governance, context, and customer inputs into ranked **recommendation sets** across recommendation types without allowing optimization to bypass brand, compatibility, inventory, consent, or operator-control boundaries.

This feature is the product's core decision stack for:

- blending **curated**, **rule-based**, and **AI-ranked** sources
- choosing what candidate pool is actually eligible to rank
- selecting the right ranking objective for each **recommendation type**
- preserving deterministic precedence and fallback behavior
- emitting the trace and telemetry context needed to explain why a set was shown

## 2. Core Concept

Recommendation decisioning is a staged pipeline, not a single score sort.

The canonical flow is:

1. resolve request context and recommendation mission
2. enumerate candidate sources
3. apply hard eligibility and policy gates
4. apply operator controls and campaign priorities
5. select the ranking objective for the requested type and surface
6. rank only the allowed pool
7. post-process with deterministic tie-breakers, pins, de-duplication, and bounded fallback
8. return typed recommendation sets with source lineage, `recommendationSetId`, and `traceId`

The most important design rule is that **AI ranking optimizes inside the governed envelope; it does not define the envelope**.

## 3. Why This Feature Exists

The product vision depends on delivering recommendations that feel like SuitSupply styling advice rather than generic ecommerce adjacency. That requires more than a model and more than manual curation:

- pure curation does not scale across anchors, markets, and surfaces
- pure rules can preserve safety but underuse customer and context relevance
- pure ML can optimize the wrong proxy and drift away from brand taste or operational truth

This feature exists to make the three-source blend operational:

- **curated** inputs provide taste, campaign direction, and premium-confidence examples
- **rule-based** logic defines compatibility, governance, inventory, and policy boundaries
- **AI-ranked** scoring improves ordering and candidate choice inside those boundaries

Without an explicit decisioning feature, each surface or downstream team would invent local precedence rules, source blending, and degraded behavior, which would break trust, measurement, and governance.

## 4. User / Business Problems Solved

| User / stakeholder | Problem | What this feature enables |
| --- | --- | --- |
| **P1 anchor-product shopper** | Generic "similar items" do not solve the outfit or complement question | Type-aware ranking that preserves **outfit**, cross-sell, and upsell intent |
| **P2 returning customer** | Personalization can feel random or repetitive when confidence is weak | Confidence-aware personalization inside governed candidate pools |
| **P3 occasion-led shopper** | Event-driven discovery can flatten into broad catalog browsing | Ranking objectives that prioritize occasion fit before raw popularity |
| **S2 merchandiser** | Curated looks and campaigns lose power if models silently overrule them | Deterministic source precedence, pins, suppressions, and controlled reordering |
| **S4 product / analytics / optimization** | Hard to tell whether a result came from curation, rules, or ranking | Explicit source lineage, policy versioning, and measurable degraded states |
| **Engineering / architecture** | Ranking logic drifts across channels if not centralized | Shared decisioning semantics for PDP, cart, homepage, email, and clienteling reuse |

Business outcomes supported here include:

- stronger attach and basket expansion
- better complete-look credibility
- safer rollout of personalization and contextual ranking
- measurable source-mix behavior across surfaces
- production-grade governance over optimization

## 5. Scope

This feature covers the serving-time and batch-usable decision pipeline that produces ranked recommendation candidates and recommendation sets for all supported recommendation types.

It includes:

- request interpretation and decision mission selection
- candidate-source blending and eligibility gating
- ranking-objective selection by type, surface, and mode
- deterministic precedence across curated, rules, campaigns, and AI ranking
- degraded-state handling when candidate quality, model health, or freshness is weak
- source lineage, trace fields, and policy-version capture

It does **not** own final customer-facing rendering, full model-training workflow design, or the final grouped **outfit** assembly semantics that belong to complete-look orchestration.

**Assumptions:**

- the shared delivery contract can carry set-level trace and source metadata
- catalog-readiness and governance snapshots are available before scoring executes
- Phase 1 focuses on RTW PDP and cart while later phases broaden surfaces and personalization depth

**Primary open decisions tracked in `docs/features/open-decisions.md`:**

- `DEC-008` - campaign vs personalization/context precedence on non-core ecommerce surfaces
- `DEC-015` - category- and surface-specific product-readiness thresholds
- `DEC-016` - inventory freshness windows and bounded fallback policy by surface
- `DEC-036` - default curated ordering policy by surface and mode

**Architecture-stage choices still open but not yet promoted as portfolio decisions:**

- model-serving stack and online feature-retrieval shape
- exploration versus exploitation policy for later experimentation
- exact scorer composition by recommendation type once architecture formalizes interfaces

## 6. In Scope

- candidate enumeration from curated looks, partial looks, rule-generated catalog candidates, and campaign-prioritized sets
- recommendation-type-specific ranking objectives for `outfit`, `cross-sell`, `upsell`, `style bundle`, `occasion-based`, `contextual`, and `personal`
- governed ordering windows for curated sets: fixed, partially reorderable, or fully reorderable within policy
- deterministic post-processing: de-duplication, cart suppression, pin handling, tie-breaks, and fallback
- degraded behavior when AI ranking, freshness, or candidate coverage is weak
- per-set trace capture for explainability and experimentation
- RTW-first behavior with explicit hooks for later CM-specific scoring constraints

## 7. Out of Scope

- full offline training-pipeline design, feature engineering implementation, or vendor selection
- search ranking, onsite search retrieval, or ad auction logic
- final admin-UI technology choices
- final grouped slot assembly for complete looks after ranking chooses candidate pools
- board-state changes, approval claims, or downstream architecture/build issue creation

## 8. Main User Personas

| Persona | How this feature serves them |
| --- | --- |
| `P1` Anchor-product shopper | Needs ranked outputs that match the current shopping mission instead of flat adjacency. |
| `P2` Returning customer | Needs profile-aware ordering only when identity confidence and consent permit it. |
| `P3` Occasion-led shopper | Needs occasion and context to shape ranking objectives, not only item similarity. |
| `S2` Merchandiser | Needs curation, campaigns, suppressions, and ordering freedom to remain explicit and enforceable. |
| `S4` Product / analytics / optimization | Needs interpretable ranking traces, source mix, policy versions, and experiment context. |
| Architecture / engineering | Needs a single definition of decision precedence and fallback semantics across channels. |

## 9. Main User Journeys

### Journey 1: PDP anchor-product request with multiple recommendation types

1. Shopper opens a PDP for an RTW anchor product.
2. Delivery API requests one or more recommendation types, typically `outfit`, `cross-sell`, and optionally `upsell`.
3. Decisioning resolves the anchor, market, mode, governance snapshot, and experiment variant.
4. Candidates are enumerated from curated looks, rule-eligible complements, and campaign-prioritized items.
5. Hard eligibility, compatibility, inventory, and suppression rules narrow the pool.
6. Type-specific ranking objectives order the remaining pools.
7. The system returns one or more recommendation sets with source mix, trace fields, and degraded-state indicators where needed.

### Journey 2: Cart-focused complement and completion ranking

1. Shopper changes cart state.
2. Decisioning resolves the basket mission: complete the look, avoid duplicates, and respect in-cart anchors.
3. The feature suppresses exact cart duplicates and invalid complements before scoring.
4. Cross-sell and outfit-completion candidates are ranked with stronger attach and utility emphasis than broad inspiration.
5. If the candidate pool is thin, the system returns a smaller safe set rather than padding with weak items.

### Journey 3: Occasion-led or contextual ranking

1. Shopper enters from a context-rich path such as occasion, season, weather, or campaign.
2. Decisioning chooses a mission where occasion and context weigh more heavily than anchor similarity.
3. Curated and campaign-led candidates may be more prominent, but still remain subject to hard rules and inventory readiness.
4. The ranked output preserves explicit recommendation type and trace context so analytics can separate occasion-led performance from generic PDP behavior.

### Journey 4: Known-customer ranking inside governed bounds

1. A recognized customer arrives with sufficient consent and identity confidence.
2. Candidate generation remains governed by catalog, rules, and operator controls.
3. Personalization adjusts ordering and suppression inside the allowed pool.
4. If confidence is weak or policy disallows personal activation, ranking safely degrades to non-personal defaults without pretending the output is individualized.

### Journey 5: Operator troubleshooting of a surprising ranked output

1. Merchandiser or analyst inspects a delivered recommendation set through trace or debug tooling.
2. They can see source mix, effective governance snapshot, experiment variant, and degraded-state markers.
3. The tooling shows whether curation, rules, or AI ranking most influenced the final order.
4. If the output looks wrong, teams can distinguish a policy problem, catalog-readiness failure, or scorer-quality issue.

## 10. Triggering Events / Inputs

| Trigger | Required inputs | Important notes |
| --- | --- | --- |
| PDP recommendation request | `anchorProductId`, `surface`, `placement`, `market`, `mode`, session or customer ref | Primary Phase 1 use case |
| Cart recommendation request | cart lines, market, mode, customer/session ref | Requires duplicate suppression and basket-aware ranking |
| Occasion or inspiration request | occasion or context seed, surface, market, mode | Occasion fit may outweigh anchor similarity |
| Batch recommendation generation | audience segment or customer refs, effective date, surface/channel context | Used for email and asynchronous surfaces |
| Governance snapshot change | new snapshot ID, effective controls, affected scopes | May invalidate cached rank outputs |
| Catalog or readiness update | product/lookup changes, freshness state, suppression reasons | Alters candidate eligibility before ranking |

Typical input bundles include:

- request context: market, channel, surface, placement, mode
- recommendation type or types requested
- anchor product, occasion, or cart context
- customer profile summary and identity confidence where permitted
- context bundle: weather, season, country, campaign, session cues
- governance snapshot ID and policy versions
- experiment and variant context
- catalog-readiness or freshness markers relevant to the candidate pool

## 11. States / Lifecycle

Decisioning should preserve a reconstructable lifecycle for each set:

1. **`requested`** - request accepted with type, surface, mode, and context
2. **`mission_resolved`** - ranking mission and objective chosen for the type
3. **`candidates_enumerated`** - source pools loaded
4. **`hard_filtered`** - eligibility, compatibility, inventory, privacy, and suppression gates applied
5. **`controls_applied`** - curated priorities, campaign rules, pins, and allowed ordering freedom resolved
6. **`ranked`** - scorer or deterministic policy ordered the allowed pool
7. **`post_processed`** - tie-breakers, de-duplication, in-cart suppression, and quality thresholds applied
8. **`degraded`** - fallback path used due to weak candidates, stale data, or model unavailability
9. **`packaged`** - recommendation set assembled with `recommendationSetId`, `traceId`, and trace metadata
10. **`delivered`** - set returned through the shared delivery contract

`degraded` is not failure by default. It indicates the feature chose a smaller or less optimized but still governed result.

## 12. Business Rules

- **Hard rules outrank everything.** Catalog readiness, compatibility, inventory validity, consent boundaries, and hard suppressions always win over curation and AI ranking.
- **Curated truth is first-class but not absolute.** Curated looks may seed or prioritize candidates, but customer-facing delivery cannot bypass hard readiness or policy gates.
- **AI ranking operates only inside allowed ordering windows.** It may not silently reorder fixed curated sets or pinned items when policy forbids it.
- **Recommendation type determines the objective.** `outfit` ranking optimizes for coherent complete looks; `cross-sell` emphasizes complementary attach; `upsell` emphasizes credible premium progression; other types follow their defined mission from BR-002.
- **Fallback must preserve recommendation intent.** If `outfit` quality is too weak, the system should return a smaller governed set or explicit degraded state, not a flat generic adjacency list.
- **Source lineage must survive packaging.** Downstream teams must be able to tell whether a set was curated-led, rule-led, mixed, or AI-ranked.
- **Campaign and personalization interaction must remain deterministic.** Where broader precedence is still open (`DEC-008`), Phase 1 surfaces must still implement a documented local order rather than ad hoc tie-breaks.
- **Weak identity or context must degrade safely.** Personal and contextual ranking cannot imply stronger certainty than inputs allow.

### Required precedence order

1. product-readiness, consent, market, and compatibility gates
2. hard suppressions and exclusions
3. emergency and high-priority operator overrides
4. fixed curated ordering and mandatory inclusions
5. campaign priorities and scoped boosts
6. AI ranking or deterministic scoring inside the remaining pool
7. deterministic fallback if quality or system health is insufficient

## 13. Configuration Model

| Configuration area | Description |
| --- | --- |
| `rankingObjectivePolicy` | Declares the primary objective per recommendation type, surface, mode, and market |
| `sourceBlendPolicy` | Declares which source families are allowed, preferred, or fixed in scope |
| `orderingFreedomPolicy` | Fixed order vs reorderable within curated set vs reorderable across eligible candidates |
| `fallbackPolicy` | Minimum candidate counts, degraded-state thresholds, empty-set behavior, and deterministic fallback order |
| `duplicatePolicy` | In-cart suppression, in-response de-duplication, and cross-set overlap limits |
| `qualityPolicy` | Golden fixtures, alert thresholds, rank-health guardrails, and shadow-evaluation sampling |
| `telemetryPolicy` | Required trace fields, experiment context, and degraded-state annotations |

Configuration must be versioned because traceability and experimentation require exact reconstruction of the effective ranking policy at decision time.

## 14. Data Model

### Core conceptual entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `DecisioningRequest` | Normalized ranking input | `requestId`, `surface`, `placement`, `market`, `mode`, `recommendationType`, `traceId`, anchor/cart/occasion inputs, session or customer ref |
| `CandidateSeed` | Source-level input before hard filtering | `candidateId`, `productId` or `lookId`, `sourceType`, `sourceRef`, `marketScope`, `mode`, freshness metadata |
| `EligibleCandidate` | Candidate remaining after hard filters | seed fields plus readiness state, compatibility summary, governance refs, duplicate flags |
| `RankingPolicySnapshot` | Effective ranking policy for this request | `policyId`, `version`, `objectiveType`, `orderingFreedom`, `governanceSnapshotId`, `experimentContext` |
| `RankTrace` | Internal trace for audit and debugging | candidate counts by stage, filtered reasons, scorer versions, fallback reason, winner basis |
| `DecisionedRecommendationSet` | Output ready for delivery packaging | `recommendationSetId`, `recommendationType`, ranked members, `traceId`, source mix, degraded-state marker |

### Illustrative internal candidate payload

```json
{
  "candidateId": "cand_1009",
  "productId": "prod_451",
  "lookId": null,
  "sourceType": "rule_generated",
  "sourceRef": "compatibility_graph:v4",
  "readiness": {
    "eligible": true,
    "inventoryState": "sellable",
    "freshnessTier": "immediate"
  },
  "governance": {
    "governanceSnapshotId": "gov_2026_03_21_01",
    "pinned": false,
    "campaignBoost": "spring_formalwear"
  },
  "rankingInputs": {
    "recommendationType": "cross-sell",
    "anchorProductId": "prod_001",
    "identityConfidence": "low"
  }
}
```

### Data-model notes

- `lookId` and `productId` must both be supported because some ranking paths order grouped looks while others order item candidates.
- Source lineage is mandatory so explainability can distinguish curated, rule-based, and AI-ranked influence.
- Internal score details may be richer than delivery payloads, but must still map back to stable rationale categories.

## 15. Read Model / Projection Needs

Decisioning should rely on serving-ready projections instead of expensive raw joins at request time.

Required projections include:

- eligible candidate neighborhoods by anchor product, market, and recommendation type
- curated look and partial-look memberships with effective governance status
- campaign and override projections keyed by scope and recommendation type
- product-readiness summaries with freshness and suppression reasons
- customer profile summaries and identity confidence projections where permitted
- context bundles normalized for ranking consumption
- experiment bucket assignment or decision context for deterministic replay

These projections may be batch, near-real-time, or mixed, but each must preserve stable IDs, source provenance, and effective timestamps.

## 16. APIs / Contracts

Customer-facing surfaces should continue to use the shared delivery API. This feature defines the internal decisioning semantics that the delivery layer calls.

### Internal decisioning contract

`decide(requestContext, candidateInputs?, policySnapshot?) -> decisionedRecommendationSet[]`

### Minimum required internal request semantics

- request metadata: `surface`, `placement`, `market`, `mode`, `traceId`
- recommendation type or ordered list of requested types
- one or more anchors: `anchorProductId`, `cart`, or `occasionContext`
- optional customer summary: `customerRef`, `identityConfidence`, profile summary
- optional context summary: weather, season, market, campaign, session cues
- effective `governanceSnapshotId`, policy version, and experiment context

### Required response semantics

- one or more typed recommendation sets
- stable `recommendationSetId` and `traceId`
- source-mix summary
- degraded-state code where applicable
- ranking-policy or governance references needed for explainability and telemetry
- deterministic ordering already resolved; delivery should not re-rank locally

### Contract constraints

- delivery consumers must not infer source type from item order alone
- downstream surfaces must preserve recommendation type and set-level IDs
- local frontend logic must not reinterpret precedence or silently reorder results

## 17. Events / Async Flows

### Serving-time flows

- `recommendation.decision.requested`
- `recommendation.decision.completed`
- `recommendation.decision.degraded`
- `recommendation.decision.empty_pool`

### Supporting async flows

- governance snapshot publication invalidates or recomputes affected decision projections
- catalog-readiness updates change candidate eligibility and suppression lists
- shadow ranking runs compare new scorer output against live policy without exposing it
- batch recommendation generation for email or lifecycle journeys reuses the same policy semantics with asynchronous execution

### Example operational flow: governance change

1. Merchandiser publishes a new campaign or ordering policy.
2. Governance emits a new `governanceSnapshotId`.
3. Candidate or policy projections refresh for affected surfaces and recommendation types.
4. Subsequent decision requests reference the new snapshot in trace and telemetry.
5. Analytics can compare pre- and post-change behavior without guessing what changed.

### Reliability expectations

- degraded results must remain measurable, not silent
- snapshot and projection refresh must be idempotent
- cached or batch decision outputs must revalidate freshness-sensitive constraints before delivery

## 18. UI / UX Design

This feature is mostly backend decision logic, but it directly shapes both customer and operator experience.

### Customer-facing implications

- different recommendation types must feel distinct because they are ranked for different missions
- `outfit` results should preserve grouped integrity rather than looking like a generic ranked list
- degraded outputs should remain honest; do not present weak or low-confidence results as fully optimized personalization

### Operator-facing UX expectations

- merchandisers should be able to understand whether a set is fixed curated, mixed-source, or AI-ranked
- analysts should be able to inspect the reason a candidate was filtered, demoted, pinned, or chosen
- debug views should emphasize high-level rationale categories, not sensitive raw model internals

## 19. Main Screens / Components

| Component | Purpose |
| --- | --- |
| Ranking policy matrix | Shows objective and ordering freedom by type, surface, mode, and market |
| Source-mix simulator | Lets operators preview curated vs rule-based vs AI-ranked behavior within policy bounds |
| Decision trace viewer | Reconstructs how a set moved from candidates to delivered order |
| Fallback monitor | Highlights degraded pools, empty results, or frequent deterministic fallback |
| Rank-health dashboard | Tracks latency, candidate-pool size, suppression reasons, and score drift |
| Experiment comparison view | Compares ranking-policy variants and source-mix outcomes safely |

## 20. Permissions / Security Rules

- access to detailed rank traces must be role-gated; not all operators need raw scorer detail
- customer-facing surfaces must never expose sensitive profile reasoning or internal governance details
- model artifacts, policy editing, and experiment controls require stronger access than general dashboard viewing
- recommendation traces may contain customer identifiers only in the bounded, permitted forms defined by data standards
- audit exports should preserve stable IDs and reason codes rather than free-text explanations only

## 21. Notifications / Alerts / Side Effects

Decisioning should emit alerts or operational signals for:

- spikes in degraded or empty recommendation sets by surface or type
- sudden shifts in candidate-pool size after governance or catalog changes
- model-latency regressions or rank-timeouts on interactive surfaces
- unusual suppression bursts driven by inventory or policy updates
- rank-distribution drift indicating scorer or feature quality changes
- experiment bucket imbalance or missing variant propagation

Side effects include:

- invalidation of cached ranked sets when policies or catalog readiness change
- downstream analytics markers for new scorer or policy versions
- support and operator workflows triggered by repeated degraded-state patterns

## 22. Integrations / Dependencies

- **Catalog and product intelligence** - candidate eligibility, readiness, freshness, and suppression reasons
- **Complete-look orchestration** - consumes ranked grouped candidates and remains authoritative for final outfit assembly
- **Merchandising governance and operator controls** - provides snapshot-based pins, suppressions, campaign priorities, and ordering policies
- **Shared contracts and delivery API** - transports typed recommendation sets and trace metadata to surfaces
- **Analytics and experimentation** - measures source mix, ranking outcomes, and degraded-state behavior
- **Explainability and auditability** - reconstructs why sets were ranked and delivered
- **Identity and style profile** - provides confidence-aware profile summaries for later personal ranking
- **Context engine and personalization** - provides contextual inputs and later-phase personalization features
- **RTW and CM mode support** - introduces mode-specific objective and compatibility constraints

This feature depends on those systems exposing stable IDs, versioned policy context, and enough freshness visibility to keep ranking inside safe operational bounds.

## 23. Edge Cases / Failure Cases

- **Empty pool after hard filters:** return safe fallback set or explicit empty result with degraded marker rather than padding with invalid candidates.
- **Curated set conflicts with hard rules:** remove violating members, substitute within policy if allowed, or suppress the set.
- **Campaign boost collides with personalization:** apply deterministic precedence and capture the winning basis in trace context.
- **Model timeout or unavailability:** degrade to governed deterministic ordering, preserving telemetry that the model path failed.
- **Identity-confidence drop mid-request:** disable personal ranking and continue with non-personal scoring.
- **Freshness uncertainty on inventory-sensitive surfaces:** prefer safer eligible defaults or narrower set breadth.
- **Duplicate leakage across multiple types:** suppress repeated items according to duplicate policy rather than allowing uncontrolled cross-module overlap.
- **Equal scores between candidates:** use deterministic tie-breakers such as policy priority, curated precedence, freshness confidence, and canonical ID order.
- **Batch output becomes stale before send:** rerun or revalidate against current eligibility before outbound delivery.

## 24. Non-Functional Requirements

- interactive ecommerce requests must meet an interactive latency budget consistent with PDP and cart expectations
- decisioning must be deterministic for the same input bundle, policy snapshot, and candidate projection
- the system must scale horizontally for seasonal and campaign traffic spikes
- degraded behavior must be machine-readable and easy to audit
- ranking inputs and outputs must remain replayable enough for experiment and support analysis
- cached or precomputed results must not bypass freshness-sensitive guardrails

## 25. Analytics / Auditability Requirements

Decisioning must preserve enough evidence to answer:

- which source families contributed to a recommendation set
- which rules or governance snapshots constrained the candidate pool
- whether the set was model-ranked, deterministically ranked, or degraded
- how ranking differed by recommendation type, surface, market, or mode
- whether a performance shift came from source mix, policy change, or scorer behavior

Minimum telemetry and trace expectations:

- preserve `recommendationSetId` and `traceId`
- record `recommendationType`, `surface`, `market`, `mode`, and `placement`
- record `governanceSnapshotId`, policy version, and scorer version or deterministic fallback marker
- record experiment and variant context
- keep source-mix and degraded-state annotations available to both telemetry and trace flows
- preserve suppression and fallback reason categories in operator-facing audit paths

## 26. Testing Requirements

- precedence-invariant tests confirming hard rules always outrank curation and AI ranking
- fixture-based ranking tests for each recommendation type and primary surface
- regression tests for degraded paths: model unavailable, sparse pool, stale readiness state, and weak identity confidence
- deterministic replay tests using fixed inputs, policy snapshot, and candidate projections
- contract tests ensuring type, set IDs, trace IDs, and degraded-state markers survive packaging
- shadow evaluation tests for new scorers or policies before promotion
- load and latency tests on high-traffic PDP and cart workloads
- telemetry tests confirming source mix, snapshot IDs, and experiment context propagate correctly

## 27. Recommended Architecture

Recommended logical shape:

`request normalizer -> candidate enumerator -> hard filter / governance gate -> objective selector -> scorer ensemble or deterministic ranker -> post-processor -> trace writer -> delivery packager`

Supporting components:

- candidate and policy projection store
- governance snapshot resolver
- scorer registry by recommendation type and mode
- deterministic fallback ranker
- decision trace store or trace emitter
- experiment assignment integration

This feature should be separate from the final outfit-assembly layer so ranking can remain reusable across recommendation types while complete-look orchestration preserves grouped outfit semantics.

## 28. Recommended Technical Design

- represent ranking work as explicit pipeline stages rather than one opaque scorer call
- use stable rationale categories for internal explainability, such as `curated_priority`, `rule_filtered`, `campaign_boosted`, `profile_refined`, `fallback_ranked`
- model ordering freedom explicitly in policy instead of inferring it from source type
- keep deterministic tie-breakers standardized so replay remains reliable
- isolate freshness-sensitive eligibility checks from slower long-lived scoring inputs
- capture stage-level candidate counts in trace output for debugging and optimization
- support both synchronous interactive ranking and asynchronous batch ranking through the same policy semantics

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW PDP and cart decisioning for `outfit`, `cross-sell`, and `upsell`; explicit precedence stack; curated plus rules plus bounded AI reorder; deterministic degraded fallback; full trace and telemetry linkage
- **Phase 2:** stronger contextual and personal ranking inside the same governed envelope; broader type support for `occasion-based`, `contextual`, and `personal`
- **Phase 3:** richer operator tooling, source-mix simulation, experiment comparison, and broader multi-surface reuse across homepage, email, and clienteling
- **Phase 4:** deeper CM-aware scoring constraints, premium-context policies, and more advanced scorer composition once governance trust and product-readiness quality are mature

Phase 1 should prioritize correctness, determinism, and measurable degraded behavior over maximum model sophistication.

## 30. Summary

Recommendation decisioning and ranking is the product's governed optimization layer. It decides what can be ranked, how it should be ranked for the current recommendation mission, and how to fall back safely when data or model confidence is weak.

The non-negotiable rules are:

- hard readiness, governance, and compatibility boundaries win first
- curated and operator intent remain explicit first-class inputs
- AI ranking optimizes only within allowed ordering freedom
- recommendation type defines the ranking objective
- degraded behavior must stay honest, deterministic, and measurable

The most important unresolved items are already visible rather than hidden: campaign-versus-personalization precedence (`DEC-008`), readiness thresholds (`DEC-015`), freshness windows (`DEC-016`), and curated ordering freedom (`DEC-036`). With those decisions tracked explicitly, this deep-dive is concrete enough for downstream architecture and implementation-planning work without guessing at the platform's decision semantics.
