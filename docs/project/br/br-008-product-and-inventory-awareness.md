# BR-008: Product and inventory awareness

## Purpose
Define the business requirements for the product, assortment, compatibility, imagery, and inventory data needed to keep complete-look and related recommendations coherent, purchasable, and operationally valid across ecommerce, marketing, and clienteling surfaces.

## Practical usage
Use this artifact to guide downstream feature breakdown for catalog normalization, assortment eligibility, compatibility coverage, inventory-aware filtering, imagery-quality gating, freshness handling, and degraded-state measurement.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #145
- **Board item:** BR-008
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for catalog readiness rules, inventory validity handling, compatibility coverage, imagery-quality policy, freshness policy, and recommendation fallback behavior

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/data-standards.md`
- `docs/project/domain-model.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must treat product and inventory awareness as a hard business foundation for recommendation quality, not as a downstream implementation detail.

For BR-008, product and inventory awareness means recommendation logic must only rely on products, looks, and combinations that are sufficiently:
- **attribute-complete** for styling and compatibility decisions
- **assortment-eligible** for the active market, channel, and journey
- **inventory-valid** for the recommendation use case and delivery surface
- **imagery-ready** enough to support credible customer-facing presentation
- **compatibility-covered** enough to form coherent complete looks
- **fresh enough** that recommendation decisions do not use stale or withdrawn catalog truth
- **mode-aware** across RTW and CM so mode-specific fields and constraints remain explicit

Recommendation logic must not surface items that are merely adjacent in the catalog but missing the product truth required to support complete-look credibility and operational validity.

The platform must distinguish between:
- hard readiness failures that make a product or look ineligible for customer-facing recommendation
- bounded partial readiness where a product may remain usable only in narrower recommendation types or operator-assisted contexts
- freshness degradation where the safest behavior is to reduce specificity rather than pretend the catalog is fully current

## Business problem
SuitSupply needs recommendations to feel like they came from a trustworthy stylist and a trustworthy commerce operation at the same time. A recommendation is not successful if it is visually appealing but cannot be bought, is no longer in assortment, lacks the imagery needed for confidence, or depends on compatibility assumptions the platform cannot actually validate.

Without explicit product and inventory awareness requirements:
- recommendations may contain items with incomplete attributes, causing incoherent outfit composition
- PDP and cart experiences may surface items that are unavailable, invalid for the market, or no longer operationally sellable
- different surfaces may apply inconsistent eligibility rules and create customer confusion
- CM recommendations may overstate compatibility when configuration-specific fields are incomplete
- imagery gaps may allow products to rank highly even when customers cannot evaluate them credibly
- stale catalog or inventory data may make telemetry look healthy while customers encounter invalid recommendation sets
- downstream teams may optimize ranking before foundational catalog trust is established

## Users and stakeholders
### Primary customer-facing users
- **Persona P1: Anchor-product shopper** who expects outfit recommendations to match the visible product and remain purchasable now
- **Persona P2: Returning customer** who expects recommendations to complement prior purchases without surfacing unavailable or low-confidence catalog items
- **Persona P3: Occasion-led shopper** who expects recommendations to be stylistically complete and market-appropriate, not just loosely related products

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs recommendations that respect valid product truth and do not require manual cleanup during premium interactions
- **Persona S2: Merchandiser** who needs recommendation eligibility to reflect assortment intent, campaign boundaries, and imagery standards
- **Persona S4: Product, analytics, and optimization team member** who needs measurable visibility into catalog readiness, degraded states, and inventory-invalid suppression so optimization does not outrun data quality

## Desired outcomes
- Recommendation sets are built from products and looks with enough canonical data to support complete-look reasoning.
- Inventory-invalid, withdrawn, or assortment-ineligible items do not appear in customer-facing outputs unless an explicitly governed fallback policy allows a narrower use.
- RTW recommendation outputs remain immediately purchasable for the active market and channel.
- CM recommendation outputs only use configuration-aware fields when the required compatibility coverage exists.
- Product imagery quality is strong enough that recommended items can be rendered credibly on customer-facing surfaces.
- Catalog and inventory freshness are visible, measurable, and used to trigger safer fallback behavior when data is stale.
- Downstream teams can distinguish ranking quality issues from catalog-readiness failures.

## Product and inventory scope and business boundary
This BR governs whether a product, look, or recommendation candidate is trustworthy enough to participate in recommendation logic. It focuses on product truth and operational validity, not final ranking formulas or UI rendering design.

For BR-008, product and inventory awareness includes:
- canonical product attribute completeness
- market, channel, and assortment eligibility
- RTW and CM mode-specific field readiness
- inventory and operational sellability validity
- imagery readiness for recommendation presentation
- compatibility data coverage for complete-look assembly
- freshness and provenance of catalog and inventory entities

This BR does not require final implementation schemas or numeric service-level objectives, but it does require downstream work to preserve explicit readiness states, degraded behavior, and traceability.

## Product truth taxonomy and required roles
### Product-readiness input families
The platform must recognize the following input families as distinct business requirements for recommendation eligibility.

| Input family | What counts | Primary business role | Readiness expectation | Fallback if weak or missing |
| --- | --- | --- | --- | --- |
| Canonical product attributes | category, fabric, color, pattern, fit, season, occasion, style tags, price tier, brand-safe naming, size or variant context | support look composition, style coherence, filtering, and ranking | required for any customer-facing recommendation usage | suppress from recommendation use or restrict to non-customer-facing review contexts |
| Assortment eligibility | market availability, channel eligibility, active assortment state, lifecycle status, launch or withdrawal timing | ensure recommended items belong in the current selling context | required for all live customer-facing use | fall back to eligible alternatives; do not expose ineligible items |
| RTW and CM mode-specific fields | RTW sellable SKU state; CM garment, fabric, palette, shirt, tie, premium-option, or service fields | preserve mode-aware recommendation logic and compatibility scope | required when the item participates in RTW or CM recommendation behavior for that mode | narrow to the mode with validated fields or suppress unsupported mode usage |
| Inventory validity | in-stock state, sellable state, reservation or hold state, discontinuation, operational availability | keep recommendations purchasable and operationally valid | required for RTW ecommerce recommendation exposure; bounded rules may differ for assisted contexts | demote, replace, or suppress according to governed fallback policy |
| Imagery quality | primary image presence, image clarity, variant accuracy, look completeness, channel-usable presentation assets | support customer trust and outfit comprehension | required for customer-facing surfaces; stricter for ecommerce than operator-only contexts | use alternative eligible products or narrower surfaces; do not rely on text-only product truth where imagery is essential |
| Compatibility coverage | curated look links, compatibility graph edges, rule coverage, category coordination logic, mode-specific compatibility attributes | ensure complete-look coherence and safe combination logic | required at the level needed by the recommendation type and mode | degrade to safer curated or narrower recommendations rather than invent unsupported combinations |
| Catalog freshness and provenance | source timestamps, source-system mappings, lifecycle changes, transformation ownership, refresh recency | keep recommendation logic aligned with current product truth | freshness and provenance metadata must exist for important entities | treat stale or unproven data as lower-trust and reduce recommendation specificity |

### Role definitions
#### Canonical product attributes
Canonical product attributes are the minimum shared language the platform uses to decide whether products belong in the same outfit, recommendation type, or market experience. Missing or low-quality attributes should be treated as recommendation-readiness failures, not merely as ranking inconveniences.

#### Assortment eligibility
Assortment eligibility determines whether a product should participate in recommendation logic for a given market, channel, and journey. Eligibility exists to enforce business intent and operational truth before ranking is allowed to optimize.

#### RTW and CM mode-specific fields
Mode-specific fields prevent the platform from pretending RTW and CM are interchangeable. RTW relies on concrete sellable products and immediate availability. CM relies on validated compatibility fields for garments, fabrics, palettes, shirt and tie styles, premium options, and service scope.

#### Inventory validity
Inventory validity is the business requirement that keeps recommendation outputs purchasable and operationally credible. For high-intent ecommerce surfaces, this is a hard readiness gate. In assisted-selling contexts, bounded alternatives may be acceptable only if explicitly governed.

#### Imagery quality
Imagery quality is a recommendation-readiness requirement because customers often evaluate outfit credibility visually. Products that cannot be understood or trusted visually should not be treated as equal to imagery-ready products in customer-facing recommendation sets.

#### Compatibility coverage
Compatibility coverage determines whether the platform knows enough to form a coherent complete look or valid related recommendation. The system must not invent compatibility from broad similarity when curated or rule-based support is absent.

#### Catalog freshness and provenance
Freshness and provenance distinguish current trusted catalog truth from stale or weakly attributable data. Product and inventory entities without freshness visibility must not behave like fully current authoritative sources.

## Minimum product-readiness requirements
Every product, look, and recommendation item used in live customer-facing delivery must preserve enough data to support trust, explainability, and operational validity.

### Minimum required metadata
At a business level, each product candidate used in recommendation logic must preserve:
- stable canonical product ID plus source-system identifiers
- explicit RTW or CM mode context where it changes recommendation behavior
- canonical product attributes used for compatibility and styling
- assortment eligibility state for the active market and channel
- inventory validity or sellability state relevant to the consuming surface
- imagery-readiness state for customer-facing rendering
- freshness timestamp or effective recency state for important catalog and inventory entities
- source provenance and accountable transformation ownership where normalization or derivation occurred

### Minimum attribute-completeness expectations
The platform must not treat all attributes as optional. At minimum:
- category and mode context are required for every recommendation item
- color, pattern, and fabric or material context must exist where they are needed for compatibility decisions
- season, occasion, and style tags must exist where the recommendation type or surface depends on them
- price tier or commercial tiering should exist where cross-sell and upsell logic depends on it
- imagery references must exist for customer-facing use, especially on ecommerce surfaces
- CM-specific compatibility fields must exist before CM recommendation logic claims configuration-aware support

## Eligibility and operational validity rules
### Core eligibility rules
- A product must be active and assortment-eligible for the target market and channel before it can be surfaced in a customer-facing recommendation set.
- A product or look that violates hard lifecycle, market, channel, or sellability constraints must be removed before ranking.
- A recommendation set must not rely on a product whose recommendation-readiness state is unknown when that missing state affects purchasability, compatibility, or customer trust.
- Curated content does not bypass hard assortment, inventory, or operational validity rules.

### Assortment eligibility requirements
- Assortment eligibility must be explicit rather than inferred from product existence in the source catalog.
- Market, channel, and lifecycle state must be distinguishable so downstream teams can tell why an item was eligible or suppressed.
- Products not yet launched, withdrawn, restricted, or otherwise intentionally withheld from a market or channel must not appear in customer-facing outputs for that market or channel.
- If assortment eligibility differs by surface or region, the stricter applicable boundary wins.

### Inventory validity requirements
- RTW ecommerce recommendations must prefer in-stock and operationally sellable items.
- Out-of-stock, unavailable, or operationally blocked products must not appear in top-ranked customer-facing recommendation sets as if they were normal sellable options.
- If a governed fallback policy allows a bounded exception, the system must visibly treat the item as degraded or replaceable in internal traces rather than as a normal success state.
- Inventory validity must be applied at the resolution needed for the surface, such as sellable SKU or variant context where applicable.

## Mode-specific readiness requirements
### RTW requirements
- RTW recommendation logic must rely on sellable catalog entities with valid assortment and inventory state for the target market and channel.
- RTW complete-look assembly must use enough canonical attributes and compatibility coverage to preserve outfit coherence.
- RTW ecommerce surfaces must suppress products whose imagery or inventory state is too weak for immediate shopping use.
- RTW fallback behavior must preserve purchasable relevance even if that reduces outfit breadth.

### CM requirements
- CM recommendation logic must not use garment, fabric, palette, shirt, tie, or premium-option compatibility unless the corresponding fields are available and trusted.
- CM outputs must not imply configuration-aware validity when only broad style similarity is available.
- CM compatibility gaps should degrade to safer curated guidance, narrower assisted-selling usage, or suppressed customer-facing exposure rather than overstate certainty.
- Market or service availability for CM must remain explicit where it limits what can actually be recommended.

### Shared requirements across both modes
- RTW and CM must share stable canonical IDs, provenance expectations, and readiness-state visibility where possible.
- Shared recommendation contracts must preserve which readiness constraints were applied so surfaces do not infer unsupported product truth.
- The system must distinguish product truth failures from ranking preferences in both modes.

## Compatibility and complete-look requirements
### Compatibility coverage expectations
- Recommendation logic must only form complete looks when sufficient compatibility coverage exists across the relevant categories.
- Compatibility coverage may come from curated looks, deterministic compatibility rules, or a governed compatibility graph, but the source must be distinguishable internally.
- Missing compatibility coverage must narrow or suppress the recommendation set rather than encourage speculative combinations.
- Compatibility coverage requirements may be stricter for outfit recommendations than for simple adjacent upsell or cross-sell recommendations.

### Required compatibility behaviors
- The platform must support category coordination strong enough to form complete-look recommendations that are stylistically coherent.
- Compatibility logic must account for category, color, pattern, fabric, fit, occasion, season, and price-tier relationships where relevant.
- RTW and CM compatibility boundaries must remain explicit so deeper CM logic is not assumed from RTW data.
- If a required compatibility dimension is unknown, recommendation logic must choose a safer alternative or a smaller recommendation set.

## Imagery-quality requirements
### Customer-facing imagery expectations
- Customer-facing recommendation surfaces must not rely on products whose imagery is absent, misleading, or too weak to support outfit evaluation.
- Products recommended in a complete-look context should have imagery that allows the customer to understand the item's visual role in the outfit.
- Variant or product imagery must be accurate enough that recommended color or material claims are not contradicted visually.
- Imagery quality rules must be stricter on ecommerce browsing surfaces than on operator-only review contexts.

### Imagery fallback rules
- If a high-ranking product lacks sufficient imagery, the platform should prefer an eligible alternative with acceptable imagery over a visually unusable item.
- If imagery gaps affect too many items in a look, the platform should reduce recommendation breadth rather than present a visually incoherent outfit.
- The platform must not rely exclusively on imagery to infer compatibility; imagery is a readiness requirement, not the sole source of product truth.

## Freshness and staleness expectations
The platform must treat freshness as a business requirement for catalog and inventory entities, not merely as a pipeline concern.

### Freshness tiers
| Freshness tier | Entity families | Business expectation | Degradation rule |
| --- | --- | --- | --- |
| Immediate | inventory availability, sellable state, reservation-sensitive availability | current enough for active-session ecommerce recommendation decisions | if recency is unknown or stale, suppress aggressive inventory-sensitive ranking and prefer safer eligible defaults |
| Current | assortment eligibility, product launch or withdrawal state, market and channel readiness | updated in time to prevent market or channel invalid exposure | if outdated or uncertain, treat products as lower-trust or ineligible for customer-facing use |
| Durable | canonical attributes, curated look membership, stable compatibility mappings | refreshed whenever source changes and preserved with clear ownership | if old but still attributable, use cautiously only where the affected attributes are not time-critical |
| Reviewed | CM-specific compatibility definitions, premium curation, manually governed product mappings | usable only when review or confirmation state remains valid | if review timing is absent or outdated, demote to narrower assisted use or suppress |

### Required staleness handling
- Products or inventory states with unknown freshness must not behave like current authoritative truth.
- Derived product-readiness states inherit the most restrictive freshness expectation of the source entities they depend on.
- Inventory-sensitive recommendation behaviors should decay much faster than broad catalog-shape assumptions.
- A product may remain visible for analytics longer than it remains eligible for live recommendation exposure.
- When freshness is borderline, the system should prefer safer eligibility and ranking behavior rather than maximum coverage.

## Provenance and traceability expectations
Every product, compatibility link, and inventory state used in recommendation logic must be attributable enough for internal teams to understand why it was trusted.

### Minimum provenance requirements
- source system and source record identifier for product, inventory, or compatibility entities
- effective timestamp or refresh timestamp normalized for timezone-safe interpretation
- market, channel, and mode context where they affect eligibility
- transformation ownership for normalized attributes, derived readiness states, or compatibility summaries
- traceable recommendation-set-level visibility into which readiness checks suppressed, demoted, or allowed items

### Provenance requirements by usage
- Product data without usable provenance may still inform reporting but must not drive customer-facing recommendation exposure.
- Compatibility mappings must preserve whether they were curated, rule-based, or derived.
- Inventory state used in recommendation filtering must preserve enough lineage to explain why an item was considered valid or invalid.
- Recommendation traces must make it possible to distinguish catalog-readiness degradation from intentional ranking choices.

## Graceful degradation and fallback behavior
Product and inventory awareness must degrade safely rather than failing open.

### Fallback principles
- A smaller valid recommendation set is preferable to a larger but operationally invalid one.
- Hard readiness failures must not be hidden behind ranking.
- The system must not pretend to know product truth it cannot actually validate.
- Degraded state must remain visible for measurement and troubleshooting.

### Required fallback scenarios
#### Missing canonical attributes
- Suppress the affected product from recommendation types that depend on those attributes.
- Use only safer recommendation types or eligible alternatives with adequate product truth.

#### Inventory missing, stale, or low-trust
- Prefer current eligible alternatives or narrower complete-look sets.
- Do not treat unverified availability as normal RTW ecommerce sellability.

#### Assortment eligibility unknown
- Treat the product as ineligible for customer-facing recommendation exposure until a valid eligibility state is available.
- Do not infer eligibility from adjacent products or prior market presence.

#### Imagery missing or too weak
- Replace the item with an imagery-ready eligible alternative where possible.
- If replacement is not possible, return a smaller but credible recommendation set.

#### Compatibility coverage incomplete
- Narrow to recommendation types or categories with sufficient rule or curated support.
- Avoid assembling full outfits from unsupported combinations.

#### CM-specific fields incomplete
- Suppress customer-facing CM-specific recommendation claims.
- Degrade to safer curated or operator-assisted guidance without implying full compatibility validation.

#### Catalog provider or ingestion degradation
- Continue serving recommendations only from the highest-confidence remaining product truth.
- Preserve internal traceability that degraded catalog or inventory inputs changed the recommendation behavior.

## Measurable operational-quality expectations
Product and inventory awareness is only useful if downstream teams can measure whether recommendation quality is limited by ranking or by catalog readiness.

### Required measurement categories
Downstream delivery and analytics work must support measurement of:
- **catalog coverage:** how often products considered for recommendation meet minimum attribute-readiness requirements
- **assortment eligibility coverage:** how often recommendation candidates are eligible for the target market and channel
- **inventory validity coverage:** how often RTW recommendation candidates are current and sellable for the active journey
- **imagery readiness rate:** how often top-ranked items meet customer-facing imagery standards
- **compatibility coverage rate:** how often sufficient compatibility support exists for complete-look assembly by recommendation type and mode
- **freshness degradation rate:** how often stale or unknown product truth forces fallback behavior
- **suppression and replacement reasons:** why products or looks were removed, demoted, or replaced before delivery

### Minimum business expectations
The following expectations must hold for downstream work:
- Customer-facing recommendation sets must not contain products known to be invalid for the active market, channel, or operational state.
- RTW ecommerce recommendation sets must not appear healthy if they depend on stale or unknown inventory truth.
- Complete-look recommendations must not claim outfit coherence when compatibility coverage is materially incomplete.
- CM recommendation sets must not imply validated configuration-aware compatibility without the required CM fields.
- Imagery quality failures must be measurable separately from catalog or inventory failures.
- Fallback behavior must be measurable separately from fully ready recommendation behavior so degraded performance is not hidden.

### Recommended evaluation views for downstream work
To support feature and architecture decomposition, downstream work should preserve the ability to evaluate:
- catalog-readiness failures versus ranking misses
- inventory-aware recommendation performance versus broad catalog-only performance
- imagery-ready recommendation performance versus imagery-degraded fallback behavior
- RTW immediate-sellability performance versus CM compatibility-confidence behavior
- recommendation suppression and replacement by market, surface, recommendation type, and mode

## Surface implications
### Ecommerce PDP and cart
- Product and inventory awareness is a hard gate because these are high-intent, immediate-shopping surfaces.
- Inventory validity, imagery readiness, and compatibility coverage should be strongest here.
- Recommendation breadth may shrink when data quality is weak, but operational trust must be preserved.

### Homepage and inspiration surfaces
- These surfaces may tolerate broader exploratory candidate pools, but customer-facing outputs still require assortment eligibility and imagery readiness.
- Product freshness and compatibility quality remain important so inspiration does not become misleading or off-assortment.

### Email and lifecycle marketing
- Eligibility and freshness must reflect the risk of delay between recommendation generation and customer interaction.
- If product truth may age materially before exposure, the system should prefer safer, higher-confidence products and looks.

### Clienteling and assisted selling
- Operators may work with narrower bounded exceptions, but recommendation traces must still show when a product, look, or compatibility decision is degraded.
- CM and premium interactions especially require clear visibility into missing fields, compatibility confidence, and service availability boundaries.

## Phase and rollout expectations
### Phase 1 prerequisite expectations
Phase 1 work should establish:
- canonical product normalization and stable IDs
- market and channel assortment eligibility states
- inventory-aware filtering for RTW ecommerce recommendations
- minimum imagery-readiness policy for customer-facing surfaces
- compatibility coverage sufficient for early RTW complete-look delivery
- freshness and degradation visibility for catalog and inventory data

### Phase 2: Context and personalization expansion
This BR remains a prerequisite for richer context and personalization work because:
- context-aware logic cannot safely refine products that are not recommendation-ready
- personalization should not amplify low-quality product truth
- richer recommendation behavior depends on dependable catalog and compatibility coverage

### Later phases
- Phase 3 should extend the same product-readiness rules across broader channels and operator tooling.
- Phase 4 should add deeper CM-specific data requirements and premium compatibility controls without weakening the Phase 1 operational-validity baseline.

## Scope boundaries
### In scope
- defining the product-readiness inputs required for recommendation eligibility
- defining assortment, inventory, imagery, compatibility, and freshness expectations
- defining safe fallback behavior when product truth is incomplete or stale
- defining RTW and CM differences where product or compatibility data requirements diverge
- defining measurable operational-quality expectations for downstream work

### Out of scope
- exact field-level schemas for every product, inventory, or compatibility source
- exact numeric inventory freshness SLAs or attribute completeness thresholds
- final API schema for readiness-state payloads
- final model-weighting formulas for ranking once eligibility gates are satisfied
- detailed UI presentation rules for low-inventory badges, imagery placeholders, or operator dashboards

## Dependencies
- `BR-001` complete-look recommendation capability for outfit-centered quality expectations
- `BR-003` multi-surface delivery for shared eligibility and freshness behavior across consuming surfaces
- `BR-004` RTW and CM support for mode-specific field and compatibility requirements
- `BR-005` curated plus AI recommendation model for preserving hard readiness gates over optimization
- `BR-007` context-aware logic for ensuring context only acts on assortment-valid and inventory-valid candidates
- `BR-009` merchandising governance for assortment controls, curated look oversight, and override policy
- `BR-010` analytics and experimentation for catalog-readiness and degraded-state measurement
- `BR-011` explainability and auditability for product-truth trace reconstruction

## Constraints
- Product and inventory awareness must remain a hard boundary before ranking optimization, not a soft preference.
- Inventory-invalid items must not be presented without an intentional, governed fallback policy.
- Shared recommendation contracts must preserve readiness and degradation states so surfaces do not drift into inconsistent eligibility logic.
- Imagery quality cannot be ignored for customer-facing recommendations, but imagery alone must not replace explicit compatibility and product attributes.
- CM recommendation claims must remain bounded by the actual compatibility fields and service constraints that can be validated.

## Assumptions
- Product, inventory, and assortment systems can expose the required source identifiers, timestamps, and lifecycle states.
- Catalog attributes can be normalized sufficiently to support complete-look compatibility and product-readiness decisions.
- Recommendation delivery and telemetry contracts can carry readiness-state, suppression-reason, recommendation-set ID, and trace metadata.
- Phase 1 data-quality work will prioritize RTW ecommerce sellability before broader channel and CM expansion.
- Merchandising and styling teams can help define the imagery and compatibility quality bars for customer-facing use.

## Missing decisions
- Missing decision: what numeric completeness thresholds should apply by product category, recommendation type, and surface before a product is considered recommendation-ready.
- Missing decision: what precise inventory freshness windows should govern PDP, cart, email, and clienteling recommendation exposure.
- Missing decision: which imagery defects are hard-blocking versus demotion-only for different surfaces and recommendation types.
- Missing decision: what minimum compatibility coverage is required before a look qualifies as customer-facing complete-look output.
- Missing decision: which CM field groups are mandatory before any customer-facing CM recommendation can claim configuration-aware validity.

## Downstream implications
- Feature breakdown work must separate hard product-readiness gates from later ranking and optimization behaviors.
- Architecture work must preserve stable readiness states, freshness metadata, and provenance across catalog, compatibility, and inventory flows.
- Delivery contracts must indicate whether a recommendation set used fully ready products or required degraded fallback behavior.
- Governance tooling must support visibility into suppression reasons, imagery exceptions, and assortment or inventory overrides where allowed.
- Analytics work must measure recommendation outcomes against readiness quality so teams can tell when poor commercial outcomes are caused by product truth limitations instead of ranking logic.

## Review snapshot
Trigger: issue-created automation from GitHub issue #145.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, architecture overview, standards, product overview, roadmap, data standards, and domain model provide enough context to define product-readiness, inventory-validity, imagery-quality, compatibility-coverage, and freshness expectations without inventing implementation-specific schemas or thresholds.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before locking numeric thresholds, imagery policies, and CM field-group requirements.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-008 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for numeric readiness thresholds, imagery policy, and CM-specific field minimums.
