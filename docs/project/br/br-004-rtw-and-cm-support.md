# BR-004: RTW and CM support

## 1. Metadata

- BR ID: BR-004
- Issue: #111
- Stage: workflow:br
- Approval Mode: AUTO_APPROVE_ALLOWED
- Trigger: issue-created automation for workflow:br
- Parent Item: none
- Downstream stage: workflow:feature-spec
- Promotes to: boards/features.md
- Phase: Phase 1 - Foundation and first recommendation loop
- Upstream Sources:
  - docs/project/business-requirements.md
  - docs/project/personas.md
  - docs/project/product-overview.md
- Related Inputs:
  - RTW versus CM journey differences
  - compatibility constraints
  - premium styling needs
  - docs/project/roadmap.md
- Downstream Consumers:
  - feature breakdown artifacts for RTW-first and CM-aware recommendation scope
  - architecture and API contract work for recommendation mode, compatibility metadata, and governance
  - operational planning for merchandising, clienteling, and premium styling controls

## 2. Purpose

Define the business requirements for supporting both Ready-to-Wear (RTW) and Custom Made (CM) recommendation workflows without collapsing the important differences between them. This BR establishes the scope boundaries, differentiated user outcomes, governance expectations, and rollout assumptions that downstream feature and architecture work must preserve.

## 3. Scope summary

The platform must support both RTW and CM journeys as part of one shared recommendation product, but it must do so through mode-aware business rules rather than by assuming that one recommendation flow can serve both equally.

This BR defines:
- where RTW and CM can share recommendation capabilities and data foundations
- where RTW and CM must remain distinct because the customer journey, compatibility logic, or governance needs differ
- what outcomes matter for RTW shoppers versus CM customers
- what merchandising, stylist, and premium-brand governance is required before deeper CM activation
- how rollout should phase RTW-first delivery while preserving CM readiness

This BR does not define:
- low-level configuration schemas for CM garments
- exact recommendation algorithms or ranking strategies
- channel-specific UI interaction designs
- appointment workflow implementation details beyond the business constraints they impose

## 4. Business problem and opportunity

SuitSupply serves customers in both RTW and CM journeys, but those journeys do not create the same recommendation problem:

- **RTW** customers often need fast, purchasable complete-look guidance around a finished product with immediate ecommerce actions.
- **CM** customers often need recommendation support while a garment is still being configured, which means compatibility depends on in-progress fabric, color, detail, fit, and premium-option choices.

If the product treats CM as a simple extension of RTW, recommendations can become misleading, incompatible, or insufficiently premium. If the product treats CM as entirely separate, SuitSupply loses the benefit of a shared recommendation platform, shared governance model, and shared analytics foundation.

The opportunity is to define a shared platform with explicit mode boundaries:
- RTW can validate the first recommendation loop quickly on ecommerce surfaces.
- CM can inherit the same recommendation foundation later, but with stricter compatibility, explainability, and human-in-the-loop expectations.
- Merchandising and styling teams can govern both modes without rebuilding the product twice.

## 5. Target users and differentiated outcomes

### 5.1 RTW users and outcomes

#### RTW primary users
- anchor-product shoppers on PDP and cart
- occasion-led online shoppers who need a complete look quickly
- style-aware returning customers browsing finished RTW products

#### RTW desired outcomes
RTW recommendation support must help these users:
1. complete a coherent look around a purchasable anchor product
2. reduce styling friction and decision time
3. add compatible complementary products to cart with confidence
4. discover premium but still immediately purchasable options when relevant

#### RTW business success pattern
RTW is the fastest path to validating:
- recommendation-influenced conversion
- attachment rate across categories
- AOV lift through cross-sell and compatible upsell
- telemetry quality on digital surfaces

### 5.2 CM users and outcomes

#### CM primary users
- custom made customers configuring garments
- premium customers evaluating styling trade-offs across fabrics and details
- in-store stylists or clienteling associates supporting CM appointments

#### CM desired outcomes
CM recommendation support must help these users:
1. receive look guidance that respects the current garment configuration state
2. understand what shirts, ties, shoes, and accessories remain compatible as choices evolve
3. evaluate premium combinations without undermining trust in the tailoring journey
4. preserve confidence that the recommendation logic reflects premium styling standards rather than generic ecommerce logic

#### CM business success pattern
CM value is less about rapid digital attachment alone and more about:
- increasing confidence in premium styling decisions
- improving configuration coherence across the full look
- supporting stylist-assisted selling and appointment workflows
- protecting brand trust in a higher-consideration purchase journey

### 5.3 Internal users and outcomes

#### Merchandisers and look curators
Need to define mode-aware compatibility, premium styling boundaries, and overrides without forcing engineering-only workflows.

#### Stylists and clienteling associates
Need recommendation outputs that can accelerate live conversations while still preserving human judgment, especially in CM workflows.

#### Product, analytics, and optimization teams
Need performance measurement that can compare RTW and CM outcomes without assuming identical conversion patterns or success metrics.

## 6. Shared foundation versus mode-specific boundaries

### 6.1 Shared cross-mode foundation

RTW and CM should share these business foundations:
- a common recommendation platform and API-first delivery model
- shared recommendation taxonomy such as outfit, cross-sell, upsell, and style bundle
- common governance concepts for curated looks, rule-based compatibility, overrides, and traceability
- common telemetry concepts including recommendation set ID, trace ID, and outcome attribution
- common product and identity standards where stable canonical IDs are available

### 6.2 RTW-specific boundaries

RTW support must assume:
- the anchor product is a finished, directly purchasable item
- compatibility is driven primarily by known product attributes, assortment eligibility, and inventory
- the dominant surfaces are ecommerce flows such as PDP and cart
- user expectation favors speed, convenience, and direct add-to-cart actions

RTW support must not depend on:
- full representation of garment configuration state
- appointment-only interactions
- premium-detail compatibility models that are unique to CM tailoring decisions

### 6.3 CM-specific boundaries

CM support must assume:
- the anchor item may be partially configured and not yet represented as a finished sellable product
- compatibility depends on in-progress choices such as fabric, color family, construction details, and premium options
- internal assistance may be part of the journey even when digital surfaces are involved
- recommendation mistakes carry higher trust and brand risk because the journey is more premium and more considered

CM support must not be reduced to:
- generic RTW cross-sell logic
- static same-category product similarity
- blind premium upsell without configuration compatibility

### 6.4 Mixed-mode guardrail

The platform may reuse shared recommendation components across RTW and CM, but downstream features and contracts must preserve whether a recommendation set is RTW, CM, or mixed-eligibility when that distinction affects compatibility, explanation, or surface behavior.

## 7. Journey differences that downstream work must preserve

### 7.1 RTW journey characteristics

RTW journeys are typically:
- anchor-product-led or cart-led
- immediate and ecommerce-oriented
- centered on finished assortments with direct inventory and purchasability checks
- measured by low-friction conversion and attachment outcomes

Typical RTW recommendation flow:
1. Customer views or adds an RTW anchor product.
2. The platform identifies compatible outfit components and attachment opportunities.
3. PDP or cart presents outfit, cross-sell, and upsell outputs.
4. Customer adds complementary items directly to cart.
5. Telemetry measures impression, click, add-to-cart, and purchase influence.

### 7.2 CM journey characteristics

CM journeys are typically:
- configuration-led rather than finished-product-led
- iterative, with compatibility changing as customer choices evolve
- higher consideration and more explanation-sensitive
- more likely to involve stylists, appointments, or assisted selling
- measured by coherence, confidence, premium credibility, and assisted conversion support

Typical CM recommendation flow:
1. Customer begins configuring a garment or enters a CM consultation flow.
2. The platform interprets the current configuration state and compatible styling space.
3. Recommendations adapt as fabric, color, and premium details change.
4. Customer or stylist evaluates complementary pieces that reinforce the configured garment.
5. The system preserves traceability for why recommendations changed or remained valid.

### 7.3 Business interpretation of the difference

Downstream teams must treat the RTW versus CM distinction as a recommendation mode difference, not only a catalog-category difference. The mode changes:
- what counts as a valid anchor state
- what compatibility means
- what explanation and governance are required
- what success looks like on the surface and in reporting

## 8. Functional business requirements

### 8.1 Shared platform requirement

The platform must support both RTW and CM within a shared recommendation product so that downstream surfaces, analytics, and governance do not fragment into unrelated systems.

### 8.2 Mode-aware recommendation requirement

Recommendation sets must preserve whether they are RTW, CM, or mixed-eligibility when the mode affects compatibility, surface behavior, or user trust.

### 8.3 RTW outcome requirement

RTW recommendation support must optimize for coherent, directly purchasable complete-look and attachment outcomes on high-signal ecommerce surfaces.

### 8.4 CM coherence requirement

CM recommendation support must honor the current garment configuration state and avoid recommendations that break compatibility across fabric, color palette, styling details, or premium-option selections.

### 8.5 Premium styling requirement

CM and premium recommendation flows must protect brand styling integrity by ensuring that premium suggestions remain credible, explainable, and aligned with SuitSupply styling standards rather than simply maximizing order value.

### 8.6 Human-assisted workflow requirement

CM-supporting features must preserve room for stylist and clienteling participation where the journey benefits from human judgment, even when the recommendation engine is the shared decisioning layer.

### 8.7 Governance requirement

Merchandising and styling teams must be able to define, review, and override RTW and CM compatibility boundaries separately where necessary, while still using a shared governance model.

### 8.8 Rollout-boundary requirement

Phase 1 delivery must validate RTW-first business value without forcing premature CM feature depth, but the artifact, contracts, and feature breakdown must leave explicit room for deeper CM enablement in later phases.

## 9. Compatibility and styling constraints

### 9.1 RTW compatibility expectations

RTW recommendations must account for:
- category compatibility
- fit and silhouette coherence where applicable
- color and pattern coordination
- occasion appropriateness
- assortment eligibility and inventory availability

### 9.2 CM compatibility expectations

CM recommendations must additionally account for:
- in-progress fabric choice
- color family and palette interactions
- style details such as lapel, buttons, construction, and other selected options where relevant
- premium-option combinations and exclusions
- whether a complementary item still fits the intended occasion and premium tone of the configured garment

### 9.3 Premium guardrails

Premium recommendation logic must:
- avoid recommending higher-value items that undermine styling coherence
- avoid surfacing incompatible premium combinations merely because they increase order value
- remain reviewable by internal teams responsible for brand and styling integrity

### 9.4 Failure-mode guardrails

Downstream implementations must define fallback behavior when:
- CM configuration state is incomplete or ambiguous
- required compatibility attributes are missing
- identity or context inputs are not reliable enough to personalize safely

Fallback behavior must prefer safe, governed defaults over speculative premium or incompatible recommendations.

## 10. Surface and operating model expectations

### 10.1 Phase 1 surfaces

Phase 1 should focus on RTW-first ecommerce surfaces:
- PDP
- cart

These surfaces provide the strongest early signal for validating complete-look attachment and recommendation telemetry.

### 10.2 Later surfaces for deeper CM support

Later phases should extend CM depth primarily through:
- clienteling interfaces
- assisted-selling and appointment contexts
- richer digital flows where configuration state can be represented safely

### 10.3 Surface-specific interpretation

- Ecommerce surfaces must prioritize immediate actionability and purchasability for RTW.
- Clienteling and assisted-selling surfaces must prioritize trust, explanation, and flexibility for CM.
- Shared recommendation contracts must not assume that every surface can or should expose the same level of CM complexity.

## 11. Governance and operating requirements

### 11.1 Mode-specific governance

Governance must distinguish between RTW and CM in at least these areas:
- compatibility rule authoring and review
- premium styling approval boundaries
- allowable upsell patterns
- exception handling and overrides
- audit expectations for recommendation changes

### 11.2 Human-in-the-loop expectations

Human review is especially important for:
- new CM compatibility rule sets
- premium styling logic with strong brand implications
- cases where configuration-aware recommendations are difficult to validate automatically

This does not block autonomous delivery of the BR artifact, but it must remain visible as a downstream governance requirement.

### 11.3 Explainability and auditability

Both modes require traceability, but CM needs stronger internal explainability because:
- recommendation validity may change as the configuration evolves
- stylists may need to explain or adapt the recommendation during appointments
- premium trust can be damaged quickly if a recommendation appears arbitrary

Downstream work must preserve:
- recommendation set ID
- trace ID
- relevant rule, look, campaign, and experiment context
- mode indicator and compatibility rationale context where supported

## 12. Phased rollout assumptions

### 12.1 Phase 1 - Foundation and first recommendation loop

Phase 1 must:
- focus on RTW anchor-product and cart journeys
- validate outfit, cross-sell, and upsell recommendation value on PDP and cart
- establish shared governance, telemetry, and contract patterns that later CM work can inherit

Phase 1 must not require:
- full CM configuration-aware retrieval or ranking
- full appointment workflow integration
- deep premium-option compatibility orchestration

### 12.2 Phase 2 - Personalization and context enrichment

Phase 2 should:
- improve RTW relevance with richer personal and contextual inputs
- preserve mode-aware contracts so RTW gains do not force CM assumptions
- prepare stronger data and identity foundations that later CM and clienteling work can reuse

### 12.3 Phase 3 - Merchandising control and multi-channel activation

Phase 3 should:
- expand governance workflows, overrides, and internal operating controls
- expose recommendation outputs to email and clienteling consumers where appropriate
- strengthen the internal workflow patterns needed before deeper CM rollout

### 12.4 Phase 4 - CM and advanced premium outfit intelligence

Phase 4 is the primary phase for deeper CM support and should introduce:
- CM-aware recommendation retrieval and ranking
- compatibility logic that accounts for evolving configuration state
- premium styling guidance that is explicitly governed
- stronger stylist-assisted and appointment-aware workflows

### 12.5 Rollout sequencing rule

CM depth should not be expanded broadly until:
- shared telemetry and traceability are already reliable
- governance controls can distinguish RTW-safe from CM-sensitive logic
- configuration state can be represented with enough fidelity to avoid misleading recommendations

## 13. Success measures

### 13.1 RTW measures

- conversion uplift on RTW recommendation-influenced PDP and cart sessions
- category attachment rate for RTW anchor-product journeys
- AOV uplift from compatible cross-sell and upsell
- recommendation telemetry completeness on first-release surfaces

### 13.2 CM measures

- percentage of CM recommendation scenarios that maintain compatibility as configuration choices change
- stylist or clienteling trust in recommendation usefulness for assisted selling
- premium look coherence for configured-garment journeys
- reduction in recommendation errors that would undermine CM trust

### 13.3 Shared operational measures

- percentage of recommendation sets with valid mode labeling
- ability to attribute outcomes by RTW versus CM journey type
- governance coverage for mode-specific compatibility and premium rules
- traceability completeness for recommendation set, rule, and decision context

## 14. Assumptions

- RTW is the correct first rollout path because it offers faster validation on PDP and cart.
- CM support is strategically required, but deeper CM sophistication belongs after the shared foundation is proven.
- Merchandising and styling teams can help define premium compatibility guardrails for later CM phases.
- The shared platform can preserve mode distinctions in contracts and telemetry without forcing fully separate systems.

## 15. Open questions and non-blocking follow-ups

- What minimum CM configuration state must be captured before recommendation outputs can be considered reliable?
- Which premium styling decisions require mandatory human review before broader automation is acceptable?
- How should mixed journeys be labeled when a known customer moves between RTW browsing and CM consultation contexts?
- What degree of customer-facing explanation, if any, should be exposed for CM recommendations versus retained for internal use only?
- Which clienteling and appointment surfaces are the first priority once Phase 4 CM depth begins?

## 16. Review pass

Trigger: issue-created automation

Artifact under review: docs/project/br/br-004-rtw-and-cm-support.md

Approval mode: AUTO_APPROVE_ALLOWED

Blockers: none

Required edits: none

Scored dimensions:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5

Overall disposition: APPROVED

Confidence: HIGH

Approval-mode interpretation:
- This artifact exceeds the promotion threshold in the repo rubric.
- AUTO_APPROVE_ALLOWED is explicitly recorded on the board and in this artifact.
- No milestone human gate blocks completing this BR artifact, though downstream CM feature work should preserve human-in-the-loop notes for premium styling governance.

Residual risks and open questions:
- CM-specific configuration representation remains a downstream dependency and is intentionally not fixed in this BR.
- Premium styling governance will need more exact operational rules before Phase 4 CM rollout expands broadly.
