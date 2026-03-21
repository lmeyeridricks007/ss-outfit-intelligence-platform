# BR-001: Complete-look recommendation capability

## Purpose
Define the business requirements for complete-look recommendation capability so downstream feature, architecture, and implementation work can deliver coherent outfit recommendations from anchor-product and occasion-led entry points without collapsing the problem into generic item similarity.

## Practical usage
Use this artifact to guide feature breakdown for complete-look journeys, recommendation-set composition, surface behavior, ranking expectations, governance controls, success measurement, and phased rollout boundaries for complete-look recommendation delivery.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #151
- **Board item:** BR-001
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for complete-look journeys, outfit composition logic, surface delivery behavior, ranking policy, and telemetry requirements

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/vision.md`
- `docs/project/problem-statement.md`
- `docs/project/goals.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must recommend complete looks, not only adjacent items, so SuitSupply customers can answer "what goes with this?" from high-intent shopping moments and occasion-led discovery journeys.

Complete-look recommendations must:
- start from an anchor product or an occasion-led entry point
- assemble coherent outfit recommendations across relevant categories
- preserve brand taste, compatibility, and operational validity
- support both immediate shopping actions and inspiration-led discovery
- provide measurable business value through attach, conversion, and outfit-completion outcomes

This business requirement defines the complete-look outcome and boundaries. It does not define the final algorithm, UI, or API schema, but it does require downstream work to treat the complete look as a first-class recommendation set with its own business goals, composition rules, and governance.

## Business problem
SuitSupply customers often know the product or occasion they care about, but they do not know how to complete the rest of the outfit with confidence. Standard recommendation patterns such as similar products, frequently bought together, or popularity-based suggestions do not reliably solve that problem because they underrepresent style coherence, cross-category coordination, and brand-approved outfit composition.

Without an explicit complete-look capability:
- PDP and cart experiences would continue to answer narrow adjacency questions instead of outfit-completion questions
- occasion-led shoppers would struggle to translate intent into a purchasable look
- recommendation quality would drift toward item-level optimization rather than outfit-level credibility
- merchandisers and stylists would lack a scalable way to operationalize complete-look knowledge
- downstream teams would guess how many products, categories, and decision rules define a complete look

## Users and stakeholders
### Primary users
- **Persona P1: Anchor-product shopper** who wants to see what other items complete a look from a specific product
- **Persona P2: Returning style-profile customer** who expects a complete look that complements owned wardrobe context and current needs
- **Persona P3: Occasion-led shopper** who wants a full outfit for a wedding, interview, business meeting, travel need, or seasonal refresh

### Secondary stakeholders
- **Persona S1: In-store stylist or clienteling associate** who needs complete-look outputs that can be trusted and adapted during assisted selling
- **Persona S2: Merchandiser** who needs complete-look behavior to reflect brand standards, curated looks, and campaign priorities
- **Persona S3: Marketing manager** who may later reuse complete-look outputs in email and lifecycle activation
- **Persona S4: Product, analytics, and optimization team member** who needs measurable outfit-level outcomes and comparable telemetry

## Desired outcomes
- Customers can move from one product or one occasion intent to a credible, purchasable, complete outfit.
- Complete-look recommendation sets feel stylistically coherent rather than assembled from unrelated item suggestions.
- Priority ecommerce surfaces increase attach and basket-completion behavior without undermining brand coherence.
- Occasion-led journeys create a stronger path from inspiration to conversion instead of forcing the customer to manually assemble a look.
- Operators can govern complete-look behavior through curated looks, compatibility rules, and audit-friendly recommendation traces.
- Downstream delivery teams can implement complete-look features with explicit scope boundaries instead of inferring them from generic recommendation requirements.

## What a complete look means in this product
### Core definition
A complete look is a recommendation set that helps the customer assemble a coherent outfit around an explicit shopping intent. The intent may come from:
- an **anchor product** such as a suit, jacket, shirt, trouser, shoe, or outerwear item
- an **occasion-led entry point** such as wedding, interview, business travel, or seasonal wardrobe update

The set must aim to answer the outfit question as a grouped decision, not as unrelated single-item suggestions.

### Composition principles
- A complete look must include the anchor product or an equivalent intentional lead item when the journey starts from an anchor product.
- A complete look should span the categories needed to make the recommendation feel complete for the use case, not only one adjacent category.
- Category composition may vary by journey, but common categories include suit, jacket, trouser, shirt, tie, shoes, belt, outerwear, and accessories.
- The system may return a smaller set when the full category spread is not appropriate, but it must still preserve complete-look intent rather than degrade into generic adjacency.
- A complete look may include optional add-on items, but optionality must not obscure which items are the core outfit recommendation versus accessory expansion.

### Quality expectations
A valid complete-look recommendation must be:
- style coherent
- category appropriate for the journey
- compatible by fit, formality, color, pattern, and season where relevant
- operationally valid for market and inventory constraints
- commercially usable, meaning it supports realistic browse, save, add-to-cart, or assisted-selling actions

## Entry-point journeys
### Journey 1: Anchor-product PDP outfit completion
1. A customer views a specific RTW anchor product on PDP.
2. The platform identifies compatible look candidates, relevant categories, and supporting context.
3. The platform returns a complete-look recommendation set centered on the anchor product.
4. The surface presents the look in a way that supports confident exploration and add-to-cart behavior.
5. Telemetry captures look impressions, engagement, and downstream outcome events.

Business expectation:
- This is the highest-priority Phase 1 complete-look journey.

### Journey 2: Cart-based outfit completion
1. A customer adds one or more anchor items to cart.
2. The platform interprets the current basket as the styling starting point.
3. The platform returns a complete-look or look-extension set that complements what is already in cart.
4. The experience emphasizes attach and outfit completion without duplicating items already selected.

Business expectation:
- Cart is a Phase 1 priority alongside PDP, but the complete look may be narrower and more action-oriented than PDP.

### Journey 3: Occasion-led discovery
1. A customer begins from an occasion-led, inspiration-led, or search-led journey.
2. The platform interprets the event, season, market, and formality context.
3. Candidate looks are selected and ranked for that occasion rather than for a single viewed product.
4. The customer receives one or more complete looks that can be browsed and shopped.

Business expectation:
- This journey is required in the business requirement and preserved for downstream planning, but broader production activation follows after Phase 1 RTW ecommerce foundations.

### Journey 4: Known-customer complete look
1. A returning customer browses while identified or arrives from a known journey.
2. The platform uses customer profile and owned-wardrobe context to adjust complete-look recommendations.
3. The customer sees looks that complement prior purchases or likely preferences without repeating owned items unnecessarily.

Business expectation:
- This is an expansion path that depends on identity and customer signal maturity, not a prerequisite for initial complete-look delivery.

### Journey 5: Assisted-selling complete look
1. A stylist or associate opens a customer, appointment, or product context.
2. The platform returns complete-look recommendations informed by curated logic, compatibility, and customer context.
3. The associate can review, tailor, and explain the recommended look.

Business expectation:
- This journey matters for downstream reuse and quality expectations, but early production priority remains ecommerce RTW flows.

## Surface expectations
### PDP
- Must support a clearly identifiable complete-look module for anchor-product journeys.
- Must present grouped outfit logic rather than a flat list that looks like generic product recommendations.
- Must preserve the anchor item's role in the complete look.
- Must support inventory-valid shopping actions on the visible products.

### Cart
- Must support complete-look extension behavior anchored to current cart contents.
- Must avoid recommending exact duplicates of in-cart items unless substitution is the explicit goal.
- Must prioritize practical attach opportunities that still preserve overall look coherence.

### Occasion-led or inspiration surfaces
- Must support complete looks where the leading intent is the occasion rather than the anchor product.
- Must preserve the occasion framing in ranking, copy, and measurement rather than falling back to generic category suggestions.

### Clienteling and assisted-selling surfaces
- Must preserve enough look-level context for an associate to understand and adapt the recommendation.
- Must not require the operator to infer how the outfit was assembled from disconnected item recommendations.

### Outbound and future surfaces
- Must preserve the complete-look set as a reusable recommendation entity rather than flattening it into isolated products.
- May use narrower or richer visual presentations, but the business meaning of the complete-look set must remain intact.

## Business requirements for complete-look outcomes
### Outcome requirement 1: Outfit-first recommendation intent
- The platform must optimize for helping the customer complete an outfit, not only for showing related products.
- Complete-look recommendation sets must remain distinct from simple cross-sell or upsell modules even when they coexist on the same surface.

### Outcome requirement 2: Multi-category composition
- Complete-look recommendations must be able to include products from multiple categories when needed to form a coherent outfit.
- Downstream work must preserve grouped look semantics so the system can represent which items belong to the same complete-look set.

### Outcome requirement 3: Anchor preservation
- Anchor-product journeys must preserve the viewed or selected product as the lead item unless the experience explicitly shifts into a different recommendation mode.
- The customer should be able to understand why the look is relevant to the item they started from.

### Outcome requirement 4: Occasion-led capability
- The platform must support complete-look requests that begin from occasion intent rather than from a browsed product.
- Occasion intent must influence which looks are eligible and how they are ranked.

### Outcome requirement 5: Look coherence before optimization
- Complete-look ranking must preserve brand and styling coherence before optimizing for click or attach outcomes.
- Complete looks must not combine products in ways that undermine formality, compatibility, or premium styling credibility.

### Outcome requirement 6: Operational validity
- Complete-look outputs must remain inventory-aware, market-appropriate, and catalog-valid.
- When the full ideal look is not available, the system must degrade to a smaller but still coherent recommendation rather than return invalid combinations.

### Outcome requirement 7: Explainable look composition
- Internal users must be able to understand the general basis of why a complete look was produced, including anchor, occasion, curated influence, compatibility logic, and applicable governance controls.
- Customer-facing explanation, if introduced later, must stay high level and privacy-safe.

### Outcome requirement 8: Telemetry and business measurement
- Complete-look recommendations must be measurable as look-level recommendation sets, not only as item-level impressions.
- Downstream work must preserve recommendation set IDs, trace IDs, surface context, and outcome events needed to evaluate complete-look effectiveness.

## Success measures
### Primary business success measures
- Conversion uplift on eligible complete-look placements should align with the program target of +5% to +10% on eligible surfaces.
- Average order value uplift on journeys exposed to complete-look recommendations should align with the program target of +10% to +25%.
- Cross-category attach rates should increase on PDP and cart flows where complete-look modules are enabled.

### Product success measures
- Customers can receive coherent complete-look recommendations from both anchor-product and occasion-led entry points.
- Complete-look sets maintain grouped outfit integrity across downstream surfaces and telemetry.
- Recommendation quality reviews against curated examples show acceptable outfit coherence before scale expansion.
- Later personalization and context expansion improve look relevance without breaking complete-look coherence.

### Operational success measures
- Merchandising and styling teams can influence complete-look outputs through curated looks and governed rules.
- Telemetry captures impression, click, save, add-to-cart, purchase, dismiss, and override outcomes at the recommendation-set level.
- Downstream teams can build feature breakdowns and contracts without guessing what qualifies as a complete look.

## Phased rollout sequencing
### Phase 1: Core ecommerce RTW complete looks
In scope first:
- anchor-product complete looks on PDP
- cart-based look completion on RTW ecommerce surfaces
- grouped look behavior that preserves complete-look intent
- inventory-valid and governance-safe outfit composition

Phase 1 boundaries:
- priority is RTW ecommerce rather than deeper CM or cross-channel expansion
- occasion-led journeys should be specified now but may follow after the first PDP and cart release path is stable
- broader personalization should not redefine the core complete-look experience before foundational quality is dependable

### Phase 2: Occasion, context, and personalization expansion
Expand next:
- occasion-led ecommerce or inspiration experiences
- stronger customer-signal and context-aware complete-look behavior
- homepage or outbound complete-look reuse where contracts and telemetry are ready

### Phase 3: Channel and operator expansion
Expand usage across:
- clienteling and assisted-selling tools
- richer inspiration and campaign experiences
- stronger operator review and tuning workflows for complete-look quality

### Phase 4: CM depth and advanced optimization
Expand toward:
- CM-aware complete-look logic
- premium, configuration-aware complete-look assembly
- more advanced ranking and optimization once RTW quality and governance are dependable

## Dependencies
- `BR-002` multi-type recommendation support for keeping complete-look recommendations distinct from cross-sell, upsell, personal, contextual, and other recommendation types
- `BR-003` multi-surface delivery for reusable complete-look behavior across ecommerce, clienteling, and future channels
- `BR-004` RTW and CM support for phase boundaries and future CM expansion
- `BR-005` curated plus AI recommendation model for complete-look source blending and precedence
- `BR-007` context-aware logic for occasion, season, weather, and market-aware look ranking
- `BR-008` product and inventory awareness for look validity and category completeness
- `BR-009` merchandising governance for curated looks, overrides, and campaign controls
- `BR-010` analytics and experimentation for look-level telemetry and optimization
- `BR-011` explainability and auditability for traceable look composition
- `BR-012` identity and profile foundation for later personalized complete-look experiences

## Scope boundaries
### In scope
- definition of the complete-look business outcome
- anchor-product and occasion-led complete-look journeys
- look-level success measures and operational expectations
- grouped recommendation-set expectations needed for downstream feature and API work
- rollout boundaries that prioritize RTW PDP and cart before broader expansion
- assumptions and missing decisions needed for downstream breakdown

### Out of scope
- final API schema or field-level look contract
- final ranking model architecture or algorithm selection
- final UI layout, visual treatment, or copywriting for each surface
- detailed implementation tickets for services or frontend modules
- final market-by-market rollout thresholds

## Constraints
- Complete-look recommendations must preserve SuitSupply brand coherence and styling credibility.
- Look quality must not be sacrificed for click-through or simplistic basket-attach optimization.
- The platform must not treat complete looks as a thin wrapper around generic similar-item logic.
- Early rollout must favor dependable RTW PDP and cart value over broader but lower-trust expansion.
- Occasion-led and future CM expansion boundaries must remain explicit so downstream work does not over-scope Phase 1.

## Assumptions
- Catalog data, curated looks, and compatibility logic can support grouped outfit recommendations across the most important RTW categories.
- Downstream surfaces can render grouped look recommendations distinctly from generic product lists.
- Telemetry and recommendation identifiers can represent complete-look sets as first-class recommendation outputs.
- Occasion-led journeys will reuse the same core complete-look capability rather than requiring a separate disconnected recommendation engine.
- Phase 1 delivery will focus on RTW PDP and cart, while occasion-led breadth, personalization depth, and CM complexity expand later.

## Missing decisions
- Missing decision: which exact product categories are mandatory versus optional in the minimum viable complete-look composition for each primary surface.
- Missing decision: whether occasion-led complete-look discovery first appears on a dedicated inspiration surface, inside existing ecommerce placements, or both.
- Missing decision: how many complete-look alternatives a surface should present before choice overload reduces confidence.
- Missing decision: what customer-facing language should distinguish a complete look from cross-sell, upsell, or curated style-bundle modules.
- Missing decision: what minimum quality-review threshold or operator sign-off is required before expanding complete-look behavior from PDP and cart into broader surfaces.

## Downstream implications
- Feature breakdown work must preserve complete-look recommendations as their own feature area, not only as a subtype of generic recommendations.
- Architecture work must represent grouped look outputs, traceability context, and fallback behavior explicitly.
- Delivery work must define how complete-look sets are rendered, interacted with, and measured on PDP, cart, and later occasion-led surfaces.
- Governance work must preserve curated look influence, override controls, and quality-review workflows for complete-look outputs.
- Analytics work must measure look-level performance and not collapse the entire capability into item-level CTR reporting.

## Review snapshot
Trigger: issue-created automation from GitHub issue #151.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, vision, problem statement, goals, personas, product overview, and roadmap provide enough context to define complete-look outcomes, journeys, sequencing, dependencies, and missing decisions without inventing implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before locking full surface behavior and composition thresholds.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-001 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence.
