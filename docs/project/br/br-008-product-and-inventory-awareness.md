# BR-008: Product and inventory awareness

## Traceability

- **Board item:** BR-008
- **GitHub issue:** #115
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #115 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md`
- **Related inputs:** canonical product attributes, assortment eligibility, RTW and CM fields, inventory constraints, and imagery inputs
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs a recommendation-ready product and inventory foundation so complete-look outputs stay coherent, purchasable, and operationally valid. The platform must define which product attributes are required, how assortment and sellability constraints shape eligibility, how RTW and CM fields differ, what inventory states are safe for recommendation use, and how imagery supports recommendation quality without becoming a substitute for missing product data.

This business requirement defines:

- the recommendation-critical product data domains that must be normalized and governed
- which product, assortment, inventory, imagery, RTW, and CM inputs are required for Phase 1 recommendation use
- how eligibility and inventory constraints should limit what can be recommended
- how missing, stale, or conflicting product data should degrade recommendation behavior
- what traceability and data-quality visibility downstream teams need to operate safely

This BR does not define:

- the final physical catalog schema, database design, or source-system integration topology
- the exact ranking model features or compatibility scoring formulas
- the final OMS, ERP, or inventory-reservation implementation details
- the full CM configuration schema for every tailoring option

## 2. Problem and opportunity

Complete-look recommendations depend on more than stylistic similarity. To be credible, the platform needs products that are described consistently, grouped correctly, eligible for the current assortment, supported by usable imagery, and checked against inventory and sellability constraints before they are shown.

Without a clear business requirement for product and inventory awareness:

- recommendations may pair items that are stylistically inconsistent because attribute quality is weak or uneven
- recommendations may show products that are not sellable in the shopper's region, channel, season, or assortment
- RTW and CM journeys may be mixed incorrectly, leading to outputs that are confusing or operationally misleading
- low-stock, unavailable, or stale items may continue to appear and undermine trust
- imagery gaps may cause surfaces to show incomplete or low-confidence looks even when the underlying product could be eligible
- downstream teams may optimize ranking before the product foundation is reliable enough to support safe recommendation decisions

The opportunity is to establish a business-ready product and inventory contract that:

- gives Phase 1 ecommerce surfaces a reliable RTW-first recommendation foundation
- preserves room for later CM-aware expansion without collapsing RTW and CM into one identical product model
- keeps assortment, inventory, and sellability constraints explicit instead of leaving them as hidden implementation details
- makes recommendation quality, fallback behavior, and data gaps auditable for operators and downstream teams

## 3. Business outcomes

This requirement must support these outcomes:

1. **More coherent outfits and attachments** because recommendation logic receives dependable product attributes rather than thin item labels alone.
2. **Higher purchasability and operational trust** because assortment and inventory constraints are part of recommendation eligibility, not a late presentation fix.
3. **Safer rollout of Phase 1 surfaces** because PDP and cart recommendations can rely on explicit product-data minimums and fallback behavior.
4. **Better downstream readiness** for feature, architecture, and delivery work around catalog normalization, compatibility, eligibility, and traceability.
5. **Clearer RTW and CM evolution** because shared product foundations are defined without hiding the data differences that later CM journeys require.

## 4. Guiding business principles for product and inventory awareness

All downstream work must preserve these principles:

### 4.1 Recommendation quality starts with governed product truth

Recommendation outputs should not infer core product meaning from ad hoc text or imagery alone. Category, fabric, color, pattern, fit, season, occasion, style tags, price tier, assortment eligibility, inventory state, and RTW or CM attributes must be explicit, governed fields where they affect recommendation logic.

### 4.2 Eligibility is part of recommendation generation, not only rendering

Products that are not sellable, not assortment-eligible, or not operationally safe for the current recommendation moment must be filtered or deprioritized before final recommendation assembly. A product is not recommendation-ready just because it exists in the catalog.

### 4.3 Hard operational constraints take precedence over ranking

AI-ranked, curated, and rule-based recommendation sources may compete on relevance, but none of them may bypass hard inventory, assortment, suppression, or compatibility constraints.

### 4.4 Imagery supports trust, not product identity replacement

Imagery is required for customer-facing recommendation quality, but images must reinforce a valid recommendation decision rather than compensate for missing canonical product data. Recommendation logic should not rely on imagery alone to determine product meaning or eligibility.

### 4.5 RTW and CM share foundations, but not all data semantics

RTW and CM can share canonical identifiers, descriptive attribute standards, and traceability expectations, but downstream work must preserve the fact that CM recommendations depend on configuration-aware fields that go beyond finished RTW product data.

### 4.6 Missing or stale data should reduce confidence, not silently distort outputs

If recommendation-critical product, assortment, imagery, or inventory data is incomplete, conflicting, or stale, the platform must degrade to safer recommendation behavior rather than present low-trust outputs as if they were fully valid.

## 5. Recommendation-critical product data domains

The normalized product model must preserve the following business-level domains for recommendation use.

### 5.1 Canonical product identity and source mapping

Every recommendation-eligible product must preserve:

- a stable canonical product ID
- source-system identifier mappings
- enough identity structure to distinguish the recommendation target when it matters, such as a product style, sellable variant, or CM candidate
- lifecycle visibility so inactive, suppressed, or retired products are not treated as current recommendation options

Business expectation:

- Recommendation traces, telemetry, and downstream contracts must reference stable canonical product identities.
- Source-system mappings must remain explicit so catalog, inventory, imagery, and assortment records can be reconciled without ambiguity.
- Downstream work must not assume that one upstream source identifier is globally reliable by itself.

### 5.2 Core descriptive product attributes

The minimum descriptive attribute set for recommendation quality must include, where relevant:

- category
- fabric
- color
- pattern
- fit
- season
- occasion
- style tags
- price tier

Business expectation:

- These attributes are recommendation-critical because they influence compatibility, look assembly, explanation, and ranking behavior.
- Products missing too many core descriptive attributes must not be treated as full-confidence candidates for complete-look recommendations.
- Downstream teams must define required versus optional fields by product class, but they must not reduce the product foundation to category alone.

### 5.3 Assortment and sellability attributes

Recommendation-eligible products must preserve the business constraints that determine whether they can actually be shown or sold in the relevant context, including:

- regional or market eligibility
- channel or surface eligibility when assortments differ
- brand, campaign, or merchandising suppressions
- product lifecycle state, launch state, or retirement state
- assortment boundaries relevant to the current season, collection, or operating window

Business expectation:

- Assortment eligibility is not optional metadata. It is a recommendation filter and prioritization input.
- A product that is valid in one region, channel, or collection window must not be assumed valid everywhere else.
- Recommendation traces must preserve whether a candidate was eligible, suppressed, or excluded due to assortment conditions.

### 5.4 Inventory and purchasability attributes

Recommendation-eligible products must preserve operational fields that support sellability and customer trust, including:

- inventory availability state
- low-stock or out-of-stock status where relevant
- backorder, preorder, or delayed-availability state where applicable
- inventory freshness or update timestamp
- any business-level suppression state that marks a product as unsafe to recommend despite catalog presence

Business expectation:

- Inventory and availability are recommendation-critical operational inputs, especially for PDP and cart.
- The platform must distinguish between descriptive product quality and operational sellability. A beautifully described product is still unsafe to recommend if current inventory or availability does not support the journey.
- Downstream work must preserve the difference between inventory-aware deprioritization and hard ineligibility.

### 5.5 Imagery inputs

Customer-facing recommendation surfaces must have usable imagery references for recommendation candidates and look presentation, including:

- primary product imagery
- imagery references that support variant understanding where color or finish affects trust
- sufficient image quality and completeness to render recommendations credibly on the target surface
- look or grouped-imagery support where curated looks or outfit storytelling depend on more than isolated product thumbnails

Business expectation:

- Imagery is required to make recommendation outputs actionable and trustworthy on digital surfaces.
- Products with missing or unusable imagery may remain in internal candidate pools for some flows, but customer-facing outputs must degrade gracefully instead of displaying broken or misleading presentation.
- Imagery gaps must be visible in data-quality monitoring rather than discovered only after surface rendering fails.

### 5.6 RTW-specific fields

RTW recommendation support must preserve fields that keep finished-product recommendations coherent and purchasable, including:

- finished category and product type
- fit, fabric, color, pattern, and style attributes needed for compatibility
- assortment and inventory state for immediate sellability
- size or variant-level sellability signals where the downstream surface depends on them

Business expectation:

- Phase 1 depends primarily on RTW-first product foundations for PDP and cart.
- RTW recommendations must favor direct actionability and purchasability rather than abstract style similarity alone.

### 5.7 CM-specific fields

CM recommendation readiness must preserve additional fields that may affect compatibility for configured garments, including:

- current garment type or configuration context
- fabric and color-family context
- styling-detail context where compatibility changes materially
- premium-option or tailoring-option context where it affects credible recommendation behavior

Business expectation:

- CM fields are part of the long-term product foundation even if Phase 1 remains RTW-first.
- CM recommendation outputs must not be approximated using only RTW finished-product data when in-progress configuration choices materially change compatibility.
- If CM configuration state is incomplete or ambiguous, downstream logic must reduce confidence or fall back rather than pretending full compatibility certainty.

## 6. Product data completeness and recommendation readiness

Not every product record is equally safe for recommendation use. Downstream work must preserve business-level readiness tiers so product gaps do not silently degrade customer trust.

### 6.1 Full-confidence recommendation candidates

Products may be treated as full-confidence candidates when they have:

- stable canonical identity and source mapping
- the required descriptive attributes for their class
- valid assortment eligibility for the current recommendation context
- usable imagery for the target customer-facing surface
- inventory and sellability states current enough for the surface

Business expectation:

- Full-confidence candidates are appropriate for outfit assembly, cross-sell, upsell, and curated-plus-ranked recommendation sets.

### 6.2 Limited-confidence recommendation candidates

Products may remain in limited-confidence candidate pools when they are missing some non-critical fields but still preserve enough governed information to be operationally safe.

Business expectation:

- Limited-confidence products may appear in narrower or fallback recommendation paths.
- Downstream features must define which gaps are tolerable by category and surface, but they must not silently treat a limited-confidence item as equivalent to a full-confidence item.

### 6.3 Ineligible recommendation candidates

Products must be excluded from customer-facing recommendation outputs when they are missing critical identity, compatibility, assortment, imagery, or operational fields to a degree that makes the output unsafe or misleading.

Examples include:

- products with ambiguous or conflicting canonical identity
- products not eligible for the current region, channel, or assortment
- products with stale or invalid inventory state on a surface that requires live purchasability
- products with imagery gaps that make customer-facing rendering broken or deceptive

## 7. Assortment eligibility requirements

Assortment awareness is part of product awareness. Downstream work must preserve how recommendation logic interprets assortment context.

### 7.1 Region and market eligibility

Recommendations must reflect the shopper's region or market so items outside the relevant assortment are not surfaced as if they were locally valid.

### 7.2 Channel and surface eligibility

Products may be eligible in one channel or surface but not another due to assortment, launch sequencing, or operational constraints. Recommendation delivery must preserve this distinction.

### 7.3 Seasonal and collection boundaries

Seasonal and collection boundaries must be available where they materially affect styling coherence or assortment availability. Recommendation logic should not continue surfacing expired or off-window products as if they were still active assortments.

### 7.4 Merchandising suppressions and overrides

Suppression states, exclusions, and explicit overrides must be treated as authoritative business inputs. Recommendation ranking must not reintroduce products that merchandising or operations has deliberately suppressed.

### 7.5 Assortment traceability expectation

Internal teams must be able to see:

- whether a product was eligible for the active context
- which assortment dimension caused exclusion or suppression
- whether the exclusion was hard or a ranking de-prioritization decision

## 8. Inventory-awareness requirements

### 8.1 Inventory is a recommendation constraint, not only a commerce detail

For RTW-first ecommerce surfaces, inventory state must influence which products are allowed into the final recommendation set and how they are prioritized.

### 8.2 Surface-specific interpretation

- **PDP:** inventory awareness must keep recommended complements and alternatives purchasable in the active shopping moment.
- **Cart:** inventory awareness must keep attachment suggestions operationally credible because add-to-cart intent is already strong.
- **Homepage and later surfaces:** inventory may support broader prioritization or suppression, even when real-time sellability pressure is slightly lower than cart.
- **Clienteling and later CM-assisted flows:** inventory awareness may include broader operator judgment, but recommendation traces must still preserve the operational state used.

### 8.3 Inventory freshness requirement

Inventory data used for recommendation eligibility must have explicit freshness visibility. Downstream teams must define the exact thresholds per surface, but the business requirement is that stale inventory must reduce recommendation confidence or eligibility rather than remain invisible.

### 8.4 Low-stock and partial-availability behavior

When inventory is constrained but not fully unavailable, the platform must preserve room for governed behaviors such as:

- de-prioritizing fragile inventory for broad recommendation exposure
- allowing exceptions only when business rules explicitly support them
- falling back to alternative compatible products when operational trust would otherwise be harmed

### 8.5 Hard ineligibility behavior

Out-of-stock, suppressed, or operationally invalid products must not appear in customer-facing recommendation outputs when the active surface depends on current purchasability.

### 8.6 Inventory failure fallback

If inventory freshness is unknown or the inventory feed is degraded, downstream implementations must:

1. reduce confidence in operationally sensitive recommendation paths
2. fall back to safer governed alternatives where possible
3. preserve internal visibility that inventory quality, not pure relevance, caused the fallback
4. avoid presenting uncertain inventory as if it were reliable

## 9. Imagery requirements

### 9.1 Customer-facing imagery minimum

Digital recommendation surfaces need imagery that helps customers understand and trust the recommendation. At minimum, customer-facing products should have a usable primary image and enough variant or contextual imagery support to avoid misleading presentation when color or finish materially affects selection.

### 9.2 Look-level imagery support

Because the product is a complete-look platform, downstream work must support imagery references that let curated looks and grouped recommendations feel like coherent outfits rather than disconnected product tiles.

### 9.3 Imagery quality and fallback

If imagery is missing or degraded:

- customer-facing surfaces should prefer alternate eligible products with usable imagery where appropriate
- internal systems should flag the product-data gap explicitly
- recommendation logic should not assume an image-less item is presentation-ready just because it passed compatibility rules

### 9.4 Imagery is not a substitute for data quality

Products should not enter full-confidence recommendation paths based only on strong imagery when recommendation-critical descriptive, assortment, or operational fields are missing.

## 10. RTW and CM product-data boundaries

### 10.1 Shared foundations

RTW and CM should share:

- canonical product and source identifiers
- descriptive attribute governance
- assortment and suppression visibility
- traceability and recommendation-set auditability

### 10.2 RTW-first Phase 1 boundary

Phase 1 should focus on RTW-ready product and inventory awareness for PDP and cart because that is the fastest path to proving coherent and purchasable recommendations.

### 10.3 CM-readiness boundary

CM-specific data expectations must be recorded now so downstream teams do not design a product foundation that later blocks configuration-aware recommendation support. However, this BR does not require Phase 1 to launch deep CM recommendation logic.

### 10.4 Mixed-eligibility visibility

When future recommendation sets blend RTW, CM, or mixed-eligibility outputs, downstream contracts must preserve that distinction so surfaces and operators do not misread the product state or sellability expectations.

## 11. Traceability and data-quality requirements

Recommendation-safe product awareness depends on being able to reconstruct why a product was considered eligible, risky, or excluded.

### 11.1 Minimum product traceability fields

Recommendation traces must preserve enough context to reconstruct:

- canonical product ID
- relevant source-system mappings or source references
- recommendation type, surface, and channel
- product readiness or confidence state where used
- assortment eligibility outcome
- inventory eligibility or freshness state
- imagery readiness state for customer-facing use
- RTW or CM mode where it affects compatibility or explanation
- applied suppressions, overrides, rules, campaigns, or experiments where relevant

### 11.2 Data-quality visibility expectation

Internal teams must be able to see:

- which product fields are most often missing or inconsistent
- which recommendation exclusions are caused by assortment or inventory constraints
- which products are structurally eligible but blocked by imagery gaps
- which surfaces are most affected by stale or incomplete operational data

### 11.3 Operational monitoring expectation

Product and inventory quality monitoring must distinguish:

- descriptive-attribute issues
- identity or source-mapping issues
- assortment eligibility issues
- imagery readiness issues
- inventory freshness or availability issues

This distinction matters because the correct business response differs for each failure mode.

## 12. Functional business requirements

### 12.1 Canonical-product-foundation requirement

The platform must maintain stable canonical product identities with explicit source mappings so recommendation logic, telemetry, and downstream contracts can reconcile catalog, assortment, imagery, and inventory inputs safely.

### 12.2 Product-attribute requirement

The platform must preserve recommendation-critical product attributes including category, fabric, color, pattern, fit, season, occasion, style tags, price tier, and RTW or CM fields where those attributes affect compatibility, ranking, or explanation.

### 12.3 Assortment-eligibility requirement

The platform must evaluate region, channel, surface, seasonal, and suppression-based assortment eligibility as part of recommendation candidate selection and final assembly.

### 12.4 Inventory-awareness requirement

The platform must treat inventory and sellability constraints as recommendation-critical operational inputs so final outputs remain purchasable and operationally trustworthy.

### 12.5 Imagery-readiness requirement

Customer-facing recommendation outputs must use imagery references that are sufficient for credible presentation, and the platform must degrade gracefully when imagery quality is not adequate.

### 12.6 RTW-and-CM data-boundary requirement

The platform must support shared product-data foundations across RTW and CM while preserving the additional CM fields needed when configured-garment compatibility differs from finished RTW product logic.

### 12.7 Data-readiness requirement

The platform must distinguish full-confidence, limited-confidence, and ineligible recommendation candidates based on product, assortment, imagery, and inventory completeness rather than treating every catalog record as equally recommendation-ready.

### 12.8 Stale-data fallback requirement

When product, assortment, imagery, or inventory inputs are stale, conflicting, or incomplete, the platform must reduce confidence, fall back to safer governed behavior, or exclude affected products instead of silently producing low-trust outputs.

### 12.9 Product-traceability requirement

Each recommendation set must preserve enough trace context to explain how product identity, assortment eligibility, inventory state, imagery readiness, and RTW or CM mode influenced the output.

## 13. Surface and phase expectations

### 13.1 Phase 1 scope

Phase 1 should establish the first reliable product and inventory foundation for:

- RTW-first PDP recommendations
- RTW-first cart recommendations
- outfit, cross-sell, and upsell recommendation types
- curated, rule-based, and AI-ranked flows that all depend on the same governed product and inventory truth

### 13.2 Later-phase expansion

Later phases should extend this foundation into:

- broader homepage and contextual recommendation flows
- richer customer-signal and context-aware ranking
- email and clienteling consumers
- deeper CM and premium configuration-aware recommendation support

### 13.3 Surface interpretation

- **PDP:** prioritize coherence plus immediate sellability around an anchor product.
- **Cart:** prioritize attachment and complete-look opportunities that remain operationally valid at high intent.
- **Homepage / web personalization:** use the same governed product foundation, even when recommendation presentation is broader and less anchor-driven.
- **Email:** preserve product and imagery readiness for asynchronous activation.
- **Clienteling / CM-assisted flows:** preserve stronger traceability and mode-aware interpretation when human guidance is part of the journey.

## 14. Success measures

### 14.1 Product-foundation measures

- percentage of recommendation-eligible products with complete canonical identity and source mapping
- percentage of recommendation-critical products with required descriptive attributes by class
- percentage of customer-facing recommendation products with usable imagery coverage

### 14.2 Operational validity measures

- percentage of recommendation sets that pass assortment and inventory eligibility checks
- rate of recommendation exposures that include unavailable, suppressed, or non-sellable items
- freshness compliance for inventory and other operational product inputs on Phase 1 surfaces

### 14.3 Recommendation-quality measures

- reduction in recommendation errors caused by incompatible or under-described products
- improvement in coherent complete-look attachment on PDP and cart once governed product foundations are in place
- lower rate of broken or low-trust recommendation presentation caused by imagery or product-data gaps

### 14.4 Auditability measures

- percentage of recommendation sets with traceable product eligibility and inventory state
- visibility into the top exclusion reasons across assortment, inventory, imagery, and data completeness failures
- ability for internal teams to distinguish product-data quality issues from ranking-quality issues during review

## 15. Constraints and guardrails

- Product recommendations must not bypass hard assortment, suppression, inventory, or compatibility controls.
- Imagery must not be treated as a substitute for missing canonical product data.
- Phase 1 must stay focused on RTW-first recommendation readiness rather than broad CM feature depth.
- Data freshness expectations must be explicit for inventory and other recommendation-critical operational inputs.
- Downstream work must tolerate mixed latency and quality across source systems without hiding degraded inputs.

## 16. Assumptions

- Reliable product attributes and inventory feeds are a foundational dependency for every later recommendation phase.
- RTW-first ecommerce surfaces are the correct first place to prove product and inventory awareness value.
- Canonical product IDs and source mappings can be maintained across catalog, inventory, imagery, and assortment inputs.
- Some product classes or surfaces will tolerate limited-confidence candidates better than others, but complete-look quality still depends on explicit readiness tiers.
- CM support will require additional configuration-aware data beyond the minimum RTW finished-product model.

## 17. Open questions for downstream feature breakdown

- What exact required-versus-optional field matrix should apply by product class for Phase 1 recommendation eligibility?
- What inventory freshness thresholds should PDP, cart, homepage, email, and clienteling surfaces enforce?
- Which assortment dimensions are authoritative first for Phase 1: region, channel, collection window, lifecycle state, or all of them together?
- What minimum imagery standard should qualify a product for customer-facing recommendation use on each surface?
- How should limited-confidence products be handled when they are operationally sellable but missing some descriptive or presentation fields?
- Which CM configuration fields must be represented first so future CM recommendation work does not need a product-model redesign?

## 18. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for canonical product identity, source mapping, and recommendation-ready product normalization
2. feature scope for recommendation-critical attribute governance and product-readiness classification
3. feature scope for assortment eligibility and suppression handling across surfaces
4. feature scope for inventory freshness, sellability checks, and fallback behavior
5. feature scope for imagery readiness and customer-facing recommendation presentation safety
6. feature scope for RTW-first rollout with explicit CM-readiness boundaries

## 19. Exit criteria check

This BR is complete when downstream teams can see:

- which product, assortment, inventory, imagery, RTW, and CM inputs are required for recommendation quality
- how assortment and inventory constraints keep recommendation outputs purchasable and operationally valid
- how missing, stale, or conflicting product data must reduce confidence or trigger fallback behavior
- how imagery supports customer trust without replacing canonical product truth
- how the shared product foundation must support RTW-first delivery while preserving room for later CM-aware expansion

## 20. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-008-product-and-inventory-awareness.md`

Approval mode: `AUTO_APPROVE_ALLOWED`

Blockers: none

Required edits: none

Scored dimensions:

- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5

Overall disposition: `APPROVED`

Confidence: HIGH

Approval-mode interpretation:

- This artifact exceeds the promotion threshold in the repo rubric.
- `AUTO_APPROVE_ALLOWED` is explicitly recorded on the board and in this artifact.
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define exact field matrices, inventory freshness thresholds, and CM configuration-field priorities.

Residual risks and open questions:

- Product-class-specific required field matrices remain a downstream feature decision.
- Exact surface-level inventory freshness thresholds still need feature and architecture definition.
- CM readiness is intentionally preserved as a boundary, not fully specified as a Phase 1 implementation scope.
