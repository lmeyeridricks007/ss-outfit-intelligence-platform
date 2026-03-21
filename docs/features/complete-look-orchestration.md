# Feature: Complete-look orchestration

**Upstream traceability:** `docs/project/business-requirements.md` (BR-001, BR-002, BR-005, BR-008); `docs/project/br/br-001-complete-look-recommendation-capability.md`, `br-002-multi-type-recommendation-support.md`, `br-005-curated-plus-ai-recommendation-model.md`, `br-008-product-and-inventory-awareness.md`, `br-011-explainability-and-auditability.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md` (**look** vs **outfit**); `docs/project/roadmap.md` (Phase 1 PDP/cart).

---

## 1. Purpose

Define the feature that turns anchor-product or occasion intent into a customer-facing **outfit** recommendation set that feels like a coherent styled answer rather than a flat list of adjacent products. Complete-look orchestration owns the final grouped assembly, anchor preservation, slot coverage, fallback behavior, and delivery-ready trace metadata for BR-001.

## 2. Core Concept

A **look** is the internal grouping of compatible products; an **outfit** is the shopper-facing complete-look presentation. Orchestration sits after candidate generation and governance filtering to:

1. resolve the request intent and lead anchor
2. choose an outfit template for the surface, mode, and market
3. assemble slot candidates into a grouped look
4. validate coherence and inventory readiness
5. return a typed `outfit` recommendation set with explicit slot semantics and fallback indicators

The key distinction from generic ranking is that orchestration owns the grouped answer. Ranking can order candidates, but orchestration decides whether the final result still qualifies as a credible complete look.

## 3. Why This Feature Exists

The core customer problem is "what goes with this?" not "show me similar items" (`problem-statement.md`, `vision.md`). Without explicit orchestration:

- PDP and cart surfaces drift into cross-sell-only behavior
- curated looks cannot be safely blended with live inventory and rule enforcement
- occasion-led journeys lack a structured path from intent to purchasable outfit
- downstream teams have no stable definition of what makes a recommendation set a complete look

This feature is the main product differentiator because it operationalizes SuitSupply styling knowledge as a grouped, governed recommendation outcome rather than item adjacency.

## 4. User / Business Problems Solved

- **Persona P1: Anchor-product shopper** gets a coherent outfit centered on the item already under consideration.
- **Persona P3: Occasion-led shopper** gets a complete-look answer tied to event intent instead of disconnected category results.
- **Persona P2: Returning customer** can later receive complete looks that complement prior purchases without breaking outfit coherence when profile quality is weak.
- **Persona S1: Stylist** can reuse the same grouped look semantics in assisted-selling flows.
- **Persona S2: Merchandiser** can see curated stories, rules, and campaign intent preserved in the assembled look.
- **Business goals:** higher attach, higher AOV, stronger outfit-completion confidence, and a differentiated Phase 1 ecommerce experience (`goals.md`).

## 5. Scope

This feature covers the orchestration layer for complete-look requests across PDP, cart, and later occasion-led/clienteling surfaces. It includes request normalization, anchor resolution, template selection, slot-filling, grouped validation, degraded-output policy, and traceable response packaging.

It does **not** own raw candidate generation, compatibility-graph authoring, or final surface rendering contracts; it consumes those capabilities and turns them into a grouped `outfit` result.

**Assumptions:**

- candidate generation and governance produce an eligible pool before final assembly
- grouped look semantics can be carried through the shared delivery contract
- Phase 1 prioritizes RTW PDP and cart before broader occasion-led or CM depth

**Open decisions tracked in `docs/features/open-decisions.md`:**

- `DEC-018` - complete-look composition policy by anchor, surface, and mode
- `DEC-019` - slot substitution vs omission policy and minimum acceptable degraded look
- `DEC-020` - primary-anchor resolution for cart and occasion flows with multiple plausible leads

## 6. In Scope

- anchor preservation for PDP and anchor-aware cart flows
- surface-aware complete-look assembly for PDP, cart, and later occasion/clienteling flows
- category-slot templates for suits, jackets, shirts, shoes, outerwear, and other eligible anchors
- distinction between core outfit slots and optional accessory-expansion slots
- duplicate suppression against cart contents and repeated slot fills
- degraded-output logic that preserves complete-look intent when inventory or compatibility is thin
- explicit slot labels and grouped-member metadata for delivery/UI
- look-level traceability for explainability, analytics, and operator review

## 7. Out of Scope

- full stylist booking or appointment workflows
- AR try-on, fit visualization, or editorial lookbook presentation systems
- detailed compatibility scoring formulas or model-training workflows
- custom-made garment configuration logic beyond the phased hooks defined here
- final consumer copywriting for every surface

## 8. Main User Personas

| Persona | How this feature serves them |
| --- | --- |
| `P1` Anchor-product shopper | Needs a complete look that clearly includes the viewed product and answers what else completes it. |
| `P3` Occasion-led shopper | Needs a grouped outfit recommendation driven by event intent and formality rather than a single product. |
| `P2` Returning customer | Later phases allow the same grouped assembly to reflect wardrobe/profile context without losing anchor or occasion logic. |
| `S1` Stylist / clienteling associate | Needs grouped outfit outputs that can be reviewed, adapted, and explained during assisted selling. |
| `S2` Merchandiser | Needs curated looks, campaign rules, and quality-review feedback reflected in live outfit assembly. |
| `S4` Product / analytics | Needs look-level IDs, fallback indicators, and slot attribution to measure the feature safely. |

## 9. Main User Journeys

### Journey 1: PDP anchor-product outfit completion

1. Shopper opens a PDP for an RTW anchor product.
2. Request context identifies the anchor product, market, mode, placement, and session state.
3. Orchestration selects a template appropriate for the anchor class, such as suit-led or shoe-led.
4. Candidate looks and fill candidates are assembled into a grouped outfit that preserves the anchor.
5. UI renders the grouped outfit with clear shopping actions and outcome telemetry.

### Journey 2: Cart-based complete-the-look

1. Shopper adds one or more compatible anchor items to cart.
2. Orchestration resolves the primary outfit lead and suppresses exact duplicates already in cart.
3. The feature returns a narrower but still grouped outfit-extension set optimized for practical attach.
4. UI presents the look as a coherent extension rather than isolated add-ons.

### Journey 3: Occasion-led discovery

1. Shopper enters through an inspiration or occasion context.
2. Orchestration treats the occasion as the lead intent when there is no single anchor product.
3. It selects complete looks matching event, season, and market constraints.
4. The result remains an `outfit` set with grouped semantics even if multiple alternatives are shown.

### Journey 4: Known-customer complete look

1. Shopper is known with sufficient profile confidence.
2. Personalization and owned-wardrobe suppression refine the candidate pool.
3. Orchestration still preserves the lead anchor or occasion mission before applying profile-aware variation.
4. If profile confidence is weak, the result degrades safely to anchor-aware or context-aware outfit logic.

### Journey 5: Assisted-selling reuse

1. A stylist opens a product, customer, or appointment context.
2. Orchestration returns grouped looks with more trace depth than customer-facing surfaces.
3. Operator can inspect slot provenance, fallbacks, and curated influence before sharing or adapting the look.

## 10. Triggering Events / Inputs

| Trigger | Required inputs | Important notes |
| --- | --- | --- |
| PDP render / refresh | `anchorProductId`, `surface`, `placement`, `market`, `mode`, session or customer ref | Highest-priority Phase 1 path. |
| Cart change | cart lines, market, mode, session/customer ref | Requires duplicate suppression and primary-anchor resolution. |
| Occasion entry | occasion ID or context bundle, market, mode | No single product anchor may be present. |
| Clienteling refresh | customer ref, optional product or appointment context | Later phase; richer operator trace allowed. |
| Cache pre-warm | anchor or occasion seed, market, mode | Used for hot anchors or campaigns. |

Additional optional inputs:

- profile summary and identity confidence
- context bundle (weather, season, country, holiday, session cues)
- governance snapshot version
- experiment context
- candidate pool references from decisioning or curated-look services

## 11. States / Lifecycle

The orchestration lifecycle should be explicit and reconstructable:

1. **`requested`** - request accepted with surface, mode, and trigger context
2. **`intent_resolved`** - anchor or occasion mission determined
3. **`template_selected`** - category-slot template chosen
4. **`candidate_pool_built`** - eligible look and slot candidates loaded
5. **`assembled`** - slots filled into one or more grouped outfits
6. **`validated`** - hard rules, inventory, duplicates, and minimum-quality checks applied
7. **`degraded`** - fallback path used because ideal coverage was not possible
8. **`delivered`** - grouped response emitted with recommendation-set and trace identifiers
9. **`sampled_for_review`** - optional async quality-review sampling for operator audit

`degraded` is not equivalent to failure. It means the service returned the best safe grouped answer while recording why the stronger path did not fully succeed.

## 12. Business Rules

- A surface promising a complete look must receive an `outfit` recommendation set, not only cross-sell items (BR-001, BR-002).
- Anchor-product requests must preserve the viewed or selected anchor unless the experience explicitly changes modes.
- Cart flows must not recommend exact duplicates of items already in cart unless substitution is the explicit policy.
- Hard compatibility, market, inventory, and governance rules apply before a look can be considered deliverable (BR-005, BR-008).
- Curated looks are first-class inputs, but curated members that violate hard rules must be repaired, substituted under policy, or blocked.
- Core outfit slots and optional accessory slots must be distinguishable in the response.
- The minimum acceptable degraded result must still feel like a complete-look answer, not a flat adjacency list (`DEC-019`).
- Multiple alternative outfits may be returned, but each alternative must preserve grouped-member integrity and its own look rationale.
- Occasion-led requests must prioritize occasion coherence before anchor similarity when no explicit anchor is present.
- Personalization may reorder or refine candidate pools later, but it must not collapse or distort the complete-look mission.

## 13. Configuration Model

| Configuration area | Description |
| --- | --- |
| `templatePolicy` | Surface-, market-, and mode-specific category templates by anchor class or occasion family. |
| `slotPolicy` | Required vs optional slots, allowed substitutes, max variants per slot, duplicate rules. |
| `surfacePolicy` | Number of outfits to return, whether accessory-only expansion is allowed, UI grouping expectations. |
| `governancePolicy` | Campaign pins, exclusions, seasonal priorities, curated-look precedence, blocked combinations. |
| `fallbackPolicy` | Slot-drop vs substitute behavior, acceptable degraded composition, empty-state thresholds. |
| `qualityPolicy` | Golden-look review set, alert thresholds, sampling rate for manual/operator review. |

Configuration should be versioned so the same request context and policy snapshot can be replayed in support and audit workflows.

## 14. Data Model

### Conceptual entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `OutfitAssemblyRequest` | Normalized input to the orchestration layer | `requestId`, `surface`, `placement`, `market`, `mode`, `triggerType`, anchor or occasion inputs, `sessionId` or `customerRef`, `traceId` |
| `AssemblyTemplate` | Slot blueprint used for a request | `templateId`, `surface`, `anchorClass` or `occasionClass`, `requiredSlots[]`, `optionalSlots[]`, policy version |
| `LookCandidate` | Curated or generated grouped candidate | `lookId`, `sourceType`, member products, occasion/formality tags, inventory summary |
| `SlotCandidate` | Candidate for a specific slot | `slotName`, `productId`, source lineage, compatibility attributes, inventory state |
| `OutfitAssembly` | Final grouped result | `outfitId`, `anchorLineage`, `slots`, `degradation`, `sourceMix`, `templateId` |
| `AssemblyTrace` | Audit/debug context | policy versions, rule refs, fallback reason, candidate counts, operator-visible summary |

### Illustrative assembly payload

```json
{
  "outfitId": "OUTFIT-1001",
  "templateId": "tpl-pdp-suit-v3",
  "anchorLineage": {
    "anchorProductId": "P-001",
    "anchorReason": "pdp_anchor"
  },
  "slots": {
    "anchor": { "productId": "P-001", "source": "anchor" },
    "shirt": { "productId": "P-210", "source": "curated_look" },
    "tie": { "productId": "P-330", "source": "rule_fill" },
    "shoes": { "productId": "P-450", "source": "rule_fill" }
  },
  "optionalSlots": {
    "belt": { "productId": "P-512", "source": "generated_fill" }
  },
  "degradation": null,
  "sourceMix": ["curated", "rule-based"],
  "recommendationSetId": "RS-9001",
  "traceId": "TR-12345"
}
```

## 15. Read Model / Projection Needs

Orchestration benefits from lightweight serving projections rather than raw source traversal on every request:

- hot-anchor look neighborhoods by anchor product and market
- curated look membership with latest governance eligibility
- slot-template lookup by anchor class, surface, market, and mode
- cart duplicate-suppression projections
- optional "looks per occasion" and "looks per campaign" indexes
- inventory-ready slot candidate summaries for high-traffic anchors

These projections may be batch or near-real-time depending on freshness requirements, but they must preserve source provenance and policy versions.

## 16. APIs / Contracts

The shared delivery API remains the customer-facing contract; orchestration exposes an internal assembly contract that the delivery layer can call.

### Internal orchestration contract

`assembleOutfit(requestContext, candidatePool, policySnapshot) -> outfitAssemblies`

### Minimum internal request shape

- request metadata: `surface`, `placement`, `market`, `mode`, `traceId`
- one of: `anchorProductId`, `cart`, or `occasion`
- optional: `customerRef`, `profileSummary`, `contextBundle`
- governance refs: `policyVersion`, `campaignContext`, `experimentContext`
- candidate refs: curated look IDs, generated candidate groups, slot candidate pools

### Required response semantics

- one or more grouped `outfit` assemblies
- slot labels and core-vs-optional designation
- preserved `recommendationSetId` and `traceId`
- `degradation` summary where applicable
- source mix and high-level provenance for explainability

The delivery layer should not have to infer outfit grouping from item order alone.

## 17. Events / Async Flows

- **Serving-time assembly:** synchronous for PDP and cart in Phase 1
- **Hot-anchor precomputation:** optional warm path for high-traffic anchors, campaigns, or seasonal refreshes
- **Quality-review sampling:** emit sampled assembly traces for merchandising review
- **Curated-look invalidation:** re-run assembly eligibility when curated look members change or go out of stock
- **Fallback monitoring:** emit signals when degraded looks or empty sets spike for key anchors or categories
- **Later batch flows:** email/inspiration surfaces may reuse the same assembly engine in asynchronous pipelines

Example event families:

- `outfit.assembly.completed`
- `outfit.assembly.degraded`
- `outfit.assembly.sampled_for_review`
- `outfit.template.miss_detected`

## 18. UI / UX Design

This feature constrains UI behavior even though the final rendering belongs to surface teams:

- grouped products must look like a single outfit answer, not a carousel of unrelated products
- anchor item should be visually identifiable
- core outfit items and optional additions should be visually distinguishable
- surfaces should support loading, empty, degraded, and partial-slot states
- if multiple outfits are returned, the boundaries between grouped alternatives must be explicit
- cart flows should emphasize "complete the look" or equivalent intent, not generic recommendation language
- degraded results should remain visually honest; avoid presenting a materially incomplete output as a full look

## 19. Main Screens / Components

| Surface | Component expectation |
| --- | --- |
| PDP | "Complete the look" grouped module with anchor badge, slot-aware shopping actions, and grouped telemetry hooks |
| Cart | Compact grouped extension module that suppresses in-cart duplicates and emphasizes attach-ready items |
| Occasion / inspiration | Look cards or grouped grids where occasion framing leads the module |
| Clienteling | Operator-facing grouped outfit card with richer provenance and adaptation options |

## 20. Permissions / Security Rules

- Orchestration logs and traces must not expose more customer data than permitted IDs and confidence-safe summaries.
- Customer-facing surfaces should not reveal sensitive profile reasoning.
- Operator-facing trace depth should be role-gated in later phases.
- Service-to-service access to orchestration inputs and traces must follow platform authentication and authorization rules.
- Audit artifacts should preserve rule, campaign, and curated-look identifiers rather than ad hoc free-text explanations.

## 21. Notifications / Alerts / Side Effects

- alert when degraded or empty outfit rates spike for key anchors, markets, or categories
- alert when template selection fails or no template matches a common anchor class
- provide merchandising digest or dashboard slices for failed curated looks and frequent slot gaps
- flag repeated substitution or slot-drop patterns that indicate catalog or rule-quality problems
- record quality-review samples for operator follow-up without generating customer-facing notifications

## 22. Integrations / Dependencies

- **Catalog and product intelligence:** eligibility, inventory, imagery, category, formality, and compatibility-critical attributes
- **Shared contracts and delivery API:** transport and multi-surface response packaging
- **Recommendation decisioning and ranking:** candidate generation, candidate ordering, source mixing
- **Merchandising governance:** curated looks, pins, exclusions, overrides, seasonal rules
- **Explainability and auditability:** trace schema, rule context, operator troubleshooting
- **Analytics and experimentation:** look-level telemetry, experiment context, fallback measurement
- **Context engine and personalization:** occasion, season, weather, and profile-aware refinements in later phases
- **RTW and CM mode support:** mode-specific templates and phased CM depth boundaries

## 23. Edge Cases / Failure Cases

- **Single-slot inventory hole:** required slot cannot be filled; service must substitute, drop, or suppress according to `DEC-019`.
- **Multiple plausible anchors in cart:** cart contains suit and shoes, or several formal anchors; service must resolve a primary look mission (`DEC-020`).
- **Curated look partially invalid:** one or more curated members fail current eligibility or market rules.
- **Conflicting context:** occasion suggests formal wedding while active cart or campaign suggests casual add-ons.
- **Low-confidence identity:** personalization inputs are too weak; outfit should revert to anchor- or occasion-safe logic.
- **Template miss:** anchor class or market has no template; service should use a bounded default template or return an explicit empty/degraded state.
- **Duplicate leakage:** same product appears in two slots or as both in-cart and recommended item.
- **CM boundary violation:** self-service digital flow requests CM depth that the mode policy does not yet allow.

## 24. Non-Functional Requirements

- interactive response time must fit Phase 1 ecommerce expectations for PDP and cart
- assembly should be deterministic for a given input bundle, policy version, and candidate set
- degraded behavior must be machine-readable and operator-auditable
- serving path should scale horizontally for high-traffic anchors and campaigns
- slot selection must be reproducible enough for support and experiment analysis
- inventory and curated-look freshness should be sufficient to avoid visibly stale grouped outfits

## 25. Analytics / Auditability Requirements

Outfit orchestration must be measurable at the look level, not only at the item level.

Required telemetry and trace expectations:

- preserve `recommendationSetId` and `traceId` on every delivered outfit set
- emit impression, click, save, add-to-cart, purchase, dismiss, and override outcomes per `data-standards.md`
- include `recommendationType = outfit`
- capture anchor product ID or occasion seed, template ID, source mix, and degradation code
- record slot-level provenance so teams can distinguish curated, rule-filled, and generated members
- preserve rule context, experiment context, and policy versions in operator/audit paths

This feature should make it possible to answer:

- how often a requested complete look was delivered vs degraded vs empty
- which slots most frequently fail to fill
- whether curated looks survive live eligibility checks
- which surface and anchor classes produce the strongest attach or conversion outcomes

## 26. Testing Requirements

- golden complete-look fixtures per market, anchor class, and major occasion type
- invariants: anchor preserved, no exact cart duplicates, no duplicate slot fills, grouped response always labeled as `outfit`
- regression tests for degraded paths, especially slot substitution and slot-drop rules
- contract tests ensuring grouped slot metadata survives delivery packaging
- UI tests verifying grouped rendering is distinct from flat product carousels
- telemetry tests confirming recommendation-set and trace IDs propagate to outcome events
- load tests for hot-anchor traffic spikes and cache warm paths

## 27. Recommended Architecture

Use a dedicated orchestration service or orchestration module between candidate providers and the delivery facade.

Recommended stages:

1. **Intent resolver** - identifies anchor/occasion mission
2. **Template resolver** - selects the slot blueprint
3. **Candidate assembler** - combines curated/grouped candidates with slot-level fill candidates
4. **Validator** - enforces compatibility, governance, inventory, and duplicate rules
5. **Fallback controller** - applies bounded degraded-output policy
6. **Trace writer** - emits assembly metadata for analytics and explainability

This service should consume decisioning outputs rather than replicate ranking logic, but it must be authoritative for the final grouped outfit result.

## 28. Recommended Technical Design

- represent the working assembly as an explicit `assemblyPlan` object rather than an ordered list of items
- use stable slot names (`anchor`, `shirt`, `tie`, `shoes`, `outerwear`, etc.) with support for optional slots
- prefer deterministic tie-breakers after ranking, such as policy priority, curated precedence, and canonical ID order
- keep slot-filling pluggable so RTW and later CM templates can share a core engine
- store an `assemblyTrace` with candidate counts, chosen template, fallback reason, and source lineage
- isolate surface configuration from core assembly logic so PDP/cart/email/clienteling can reuse the same orchestration engine with different packaging rules

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW PDP and cart complete-look orchestration, grouped `outfit` sets, anchor preservation, duplicate suppression, minimal degraded-state handling
- **Phase 2:** occasion-led ecommerce and stronger context/profile-aware refinement inside the same grouped orchestration model
- **Phase 3:** clienteling reuse, operator tooling for assembly review, richer quality dashboards
- **Phase 4:** deeper CM-aware templates, configuration-sensitive slot policies, premium assembly constraints

## 30. Summary

Complete-look orchestration is the feature that makes the platform answer the right question: not "what products are adjacent?" but "what outfit should I wear with this?" It must preserve grouped semantics, anchor fidelity, inventory-safe composition, and honest degraded behavior. The biggest unresolved implementation-shaping choices are the composition template policy, degraded-look policy, and multi-anchor resolution model, which are explicitly tracked as `DEC-018` through `DEC-020`.
