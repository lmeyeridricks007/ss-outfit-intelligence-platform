# BR-002: Multi-type recommendation support

## Purpose
Define the business requirements for supporting multiple recommendation types so downstream feature, API, and delivery work can implement a shared taxonomy, consistent boundaries, and phased rollout behavior.

## Practical usage
Use this artifact to guide feature breakdown, recommendation API contract design, surface-specific rendering requirements, ranking policy definition, and rollout sequencing for recommendation types.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #139
- **Board item:** BR-002
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for typed recommendation delivery, ranking policy, and surface integration work

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/product-overview.md`
- `docs/project/goals.md`
- `docs/project/roadmap.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must support multiple recommendation types, not a single generic list, so each consuming surface can request, rank, render, measure, and govern the right recommendation intent for the customer moment.

The supported recommendation taxonomy for this BR is:
- outfit
- cross-sell
- upsell
- style bundle
- occasion-based
- contextual
- personal

Recommendation responses may contain one type or multiple types in the same request, but each returned set must preserve an explicit recommendation type, ranking intent, traceability context, and surface-appropriate output rules.

## Business problem
SuitSupply needs recommendation outputs that match distinct shopping intents rather than forcing every surface into one generic recommendation pattern. Product detail pages, carts, occasion-led discovery, homepage placements, email, and clienteling flows each need different recommendation behaviors, yet the platform must keep shared governance, telemetry, and taxonomy across all of them.

Without a typed recommendation model:
- surfaces would need custom interpretation logic for each placement
- ranking goals would drift between teams and channels
- merchandising controls would be harder to audit consistently
- experimentation and telemetry would not compare like-for-like recommendation outcomes
- roadmap sequencing would be unclear because early phases need narrower recommendation types than later phases

## Users and stakeholders
### Primary users
- shoppers looking for a complete outfit from an anchor product
- shoppers adding complementary products from cart or PDP journeys
- returning customers expecting recommendations aligned with wardrobe, style profile, and current context
- occasion-led shoppers browsing for a specific event or seasonal need

### Secondary users
- merchandisers defining controlled recommendation behavior by type
- marketers using recommendation outputs in email and lifecycle programs
- stylists and clienteling teams retrieving recommendation sets for assisted selling
- product and analytics teams measuring recommendation performance by type and surface

## Desired outcomes
- Surfaces can request recommendation outputs by explicit type instead of inferring intent from placement alone.
- Recommendation APIs and downstream consumers share a stable recommendation taxonomy.
- Merchandising, compatibility, and ranking policies can vary by type without fragmenting the platform.
- Telemetry and experimentation can measure business impact by recommendation type and surface.
- Early phases can launch only the highest-value types while leaving later types explicitly sequenced and bounded.

## Recommendation taxonomy
### Taxonomy principles
- Every recommendation set must declare one primary recommendation type.
- A single response may contain multiple recommendation sets when the surface needs more than one type.
- Recommendation type names must remain stable across API contracts, telemetry, experimentation, governance, and analytics.
- Recommendation types define the intent of the set, not only the product category composition.
- Each type must specify request context, output shape expectations, ranking objective, and fallback behavior.

### Recommendation type definitions
| Type | Primary customer intent | Typical trigger | Expected output shape | Ranking emphasis | Core boundaries |
| --- | --- | --- | --- | --- | --- |
| outfit | Help the customer complete a coherent look around an anchor product or entry point | PDP anchor product, saved look, stylist anchor, occasion seed | Multi-item complete-look set spanning relevant categories | Compatibility, style coherence, inventory validity, commercial usefulness | Not limited to similar items; must preserve complete-look credibility |
| cross-sell | Add complementary products that increase basket completion | PDP, cart, post-add-to-cart, stylist session | One or more complementary item groups or lightweight add-on sets | Complementarity, attach likelihood, inventory validity, price appropriateness | Must not substitute for full outfit logic when the surface requires a complete look |
| upsell | Encourage a higher-value or premium alternative | PDP, cart, known-premium preference, stylist guidance | Alternative product or small set of higher-tier options | Value uplift, brand fit, customer appropriateness, margin-aware relevance | Must not aggressively displace compatibility or create incoherent premium jumps |
| style bundle | Present curated or generated grouped looks built for inspiration and shop-the-look behavior | Inspiration page, homepage, email, campaign, stylist sharing | Named or identifiable look or bundle with grouped products | Style-story coherence, curation quality, campaign alignment | Distinct from raw outfit completion because the bundle is a packaged look presentation |
| occasion-based | Match a specific event or use case | Occasion-led page, campaign, search entry, stylist brief | Complete look or look set framed for the occasion | Occasion relevance, seasonality, market appropriateness, brand fit | Occasion intent leads ranking; anchor-product similarity is secondary |
| contextual | Adapt recommendations to environmental or session context | Weather, country, season, holiday, session signals | Context-adjusted item or look sets | Context relevance, fallback safety, availability in market | Must degrade gracefully when context is weak, missing, or conflicting |
| personal | Tailor outputs to the known customer profile and history | Known customer, email journey, homepage personalization, clienteling profile | Personalized item or look sets, potentially mixed with other types | Profile fit, wardrobe complementarity, suppression logic, identity confidence | Must respect consent, profile confidence, and privacy-safe explanation boundaries |

### Type boundaries and overlap rules
- **Outfit** is the complete-look decision type and may include multiple categories in one set.
- **Cross-sell** is additive and complementary; it should not be the only type returned when the surface promise is full outfit completion.
- **Upsell** is substitute-oriented and should present better or more premium options rather than accessories-only attachment.
- **Style bundle** is a merchandisable grouped look for inspiration or campaign-led presentation; it can reuse outfit logic but has its own presentation intent.
- **Occasion-based** is driven by event relevance first and may contain outfit or style-bundle shaped outputs.
- **Contextual** modifies recommendations using context such as weather, location, season, or session state; it is not a synonym for personal.
- **Personal** uses customer-specific signals and should remain explicit even when combined with contextual or occasion-based logic.

### Combination rules
- Recommendation responses may include more than one type only when the consuming surface can clearly distinguish the sets.
- If multiple types are returned together, each set must preserve its own recommendation set ID, trace ID, type, and ranking rationale category.
- Surfaces must not silently merge different types into one undifferentiated carousel if that would obscure intent or measurement.
- Business rules, experiment variants, and telemetry must be attributable at the recommendation-set level, even when one API call returns multiple types.

## Surface expectations
### Ecommerce PDP
- Must support outfit as the primary recommendation type for anchor-product journeys.
- Must support cross-sell and upsell as secondary modules where the placement strategy calls for them.
- Must not render a generic recommendation label when the module is intended as a complete-look recommendation.
- Must preserve inventory validity and category coherence for all visible products.

### Cart
- Must prioritize cross-sell and outfit completion behavior for high-intent basket expansion.
- May use upsell where a premium substitution remains relevant to the cart state.
- Must avoid conflicting recommendations that duplicate items already in cart unless the explicit intent is substitution.

### Homepage and inspiration surfaces
- Should emphasize style bundle, occasion-based, contextual, and personal outputs once those phases are enabled.
- Must allow differentiated rendering between inspirational grouped looks and narrower item recommendations.
- Must avoid exposing undeclared personalization behavior where consent or identity confidence is insufficient.

### Email and lifecycle marketing
- Should support personal, occasion-based, contextual, and style bundle outputs in later phases.
- Must preserve recommendation type metadata for campaign measurement and troubleshooting.
- Must support suppression and fallback behavior when customer identity, consent, or freshness is weak.

### Clienteling and assisted selling
- Must support outfit, personal, occasion-based, and later CM-aware recommendation modes.
- Should preserve enough trace context for stylists to understand the recommendation intent and adapt the output.
- Must not expose opaque profile reasoning that is unsuitable for associate or customer explanation.

### Future API consumers
- Must receive stable recommendation type names, set-level metadata, and clear empty or degraded-state behavior.
- Must not require custom type names or channel-specific taxonomies that fragment the core platform.

## Output expectations for downstream API and feature work
Downstream feature and architecture artifacts must assume that each recommendation set needs:
- recommendation type
- recommendation set ID
- trace ID
- source mix visibility category such as curated, rule-based, or AI-ranked
- request context summary sufficient for auditing
- ordered products or grouped look members
- ranking rationale category suitable for internal audit
- surface or placement identifier
- experiment and rule context linkage
- fallback or degraded-state indicator when applicable

The business requirement does not define the final wire contract, but it requires the downstream API to preserve typed recommendation sets as first-class entities rather than flattened item lists.

## Ranking and governance expectations by type
### Shared expectations
- All types must operate inside merchandising governance, compatibility constraints, and inventory validity rules.
- AI ranking may reorder within allowed candidates but must not bypass governed exclusions or curated priorities.
- Telemetry must be comparable by recommendation type across surfaces.
- Fallback behavior must be explicit rather than silently returning mismatched recommendation intent.

### Type-specific expectations
- **Outfit:** optimize for stylistic coherence and purchasable look completion, not only click likelihood.
- **Cross-sell:** optimize for complementary attachment and basket completion without duplicating existing cart or anchor intent.
- **Upsell:** optimize for credible premium progression with customer-appropriate price and quality jumps.
- **Style bundle:** optimize for inspiration quality, curated story coherence, and campaign alignment.
- **Occasion-based:** optimize for event appropriateness, seasonality, and market relevance.
- **Contextual:** optimize for context fit while retaining safe fallback when context signals are incomplete.
- **Personal:** optimize for profile fit, repeat relevance, suppression, and complementarity to known wardrobe signals.

## Phased rollout sequencing
### Phase 1: Core ecommerce RTW
In scope first:
- outfit
- cross-sell
- upsell

Phase 1 surface expectations:
- PDP and cart are the priority surfaces
- RTW flows are prioritized over deeper CM behavior
- typed recommendation sets must already be explicit in downstream contracts even if only three types are initially enabled

Phase 1 boundaries:
- no requirement to fully support occasion-based, contextual, personal, or style bundle delivery in production
- any early experiments for later types must remain bounded and not redefine the shared taxonomy

### Phase 2: Context and personalization expansion
Add next:
- occasion-based
- contextual
- personal

Phase 2 prerequisites:
- dependable telemetry from Phase 1
- identity confidence handling
- consent-safe profile usage
- clear fallback rules for context inputs

### Phase 3: Surface and operator expansion
Expand usage of enabled types across:
- homepage
- email
- clienteling
- richer inspirational surfaces

Phase 3 emphasis:
- stronger operational controls
- surface-specific rendering patterns using the shared taxonomy
- cross-channel measurement consistency

### Phase 4: CM depth and advanced optimization
Deepen support for:
- CM-aware outfit behavior
- premium and configuration-aware upsell
- richer stylist-assisted and occasion-driven recommendation logic
- more advanced optimization across recommendation types

## Scope boundaries
### In scope
- A canonical taxonomy for the seven recommendation types named in the source requirements
- Boundaries between recommendation types and how they may coexist in one response
- Surface expectations for the main current and planned channels
- Phased rollout order tied to roadmap sequencing
- Output expectations that downstream API and feature work must preserve

### Out of scope
- Final API schema and field-level contract definitions
- UI copy, layouts, or design-system decisions for each recommendation module
- Detailed ranking algorithm or model architecture choices
- Channel-specific implementation tickets or engineering task breakdown
- Final business thresholds for when a placement is enabled in each market

## Dependencies
- `BR-001` complete-look recommendation capability for outfit-centered journeys
- `BR-003` multi-surface delivery for channel expansion behavior
- `BR-005` curated plus AI recommendation model for source precedence and ranking controls
- `BR-006` customer signal usage for personal recommendations
- `BR-007` context-aware logic for contextual and occasion-sensitive outputs
- `BR-008` product and inventory awareness for coherent and purchasable recommendation outputs
- `BR-009` merchandising governance for type-level controls and override behavior
- `BR-010` analytics and experimentation for set-level measurement by type
- `BR-011` explainability and auditability for traceability across types
- `BR-012` identity and profile foundation for personal recommendation expansion

## Constraints
- Recommendation type support must not fragment into channel-specific vocabularies.
- Typed outputs must preserve brand coherence and SuitSupply styling credibility.
- Personal recommendations must respect consent, regional governance, and identity confidence.
- Contextual and occasion-based logic must degrade gracefully when upstream context quality is weak.
- Early rollout must favor dependable ecommerce value over maximum type breadth.

## Assumptions
- Downstream surfaces can render multiple recommendation modules when the response includes multiple types.
- Product and look data can support grouped outputs for outfit and style bundle use cases.
- Telemetry systems can attribute performance to recommendation set IDs and types.
- Merchandising and analytics teams need recommendation-type visibility as a first-class reporting dimension.
- The roadmap sequence in `docs/project/roadmap.md` remains the baseline for rollout ordering.

## Missing decisions
- Missing decision: which exact homepage and inspiration placements are mandatory for the first launch of style bundle, contextual, or personal recommendations.
- Missing decision: whether occasion-based recommendations should first appear as a dedicated discovery surface or as a ranking mode inside existing ecommerce placements.
- Missing decision: what customer-facing language should distinguish outfit, style bundle, and personal modules across surfaces.
- Missing decision: how many recommendation types a single surface may show simultaneously before the experience becomes cluttered.
- Missing decision: what minimum identity confidence threshold is required before personal recommendations can replace non-personal defaults on owned channels.

## Downstream implications
- Feature breakdown work must preserve each recommendation type as its own feature or sub-feature concern, even if some share API infrastructure.
- Architecture work must define typed recommendation-set contracts and set-level telemetry linkage.
- Delivery work must support rendering, fallback, and experimentation by recommendation type.
- Governance tooling must support rule, override, and audit visibility by recommendation type.

## Review snapshot
Trigger: issue-created automation from GitHub issue #139.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - source documents and roadmap give enough context to define taxonomy, boundaries, outputs, and sequencing without inventing implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream work should resolve the listed missing decisions before surface-specific implementation locks.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-002 to `APPROVED` after artifact review, then `DONE` once branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence.
