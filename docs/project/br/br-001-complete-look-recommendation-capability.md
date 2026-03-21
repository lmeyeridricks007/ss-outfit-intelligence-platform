# BR-001: Complete-look recommendation capability

## Traceability

- **Board item:** BR-001
- **GitHub issue:** #108
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #108 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/product-overview.md`, `docs/project/problem-statement.md`
- **Related inputs:** `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/personas.md`, anchor-product journey, occasion-led journey
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs a recommendation capability that helps customers and internal teams build complete looks instead of relying on isolated product suggestions. The capability must turn an anchor product, shopper intent, or occasion into a coherent outfit recommendation that reflects brand styling knowledge, commercial priorities, and measurable outcomes.

This business requirement defines the expected outcomes, target users, in-scope surfaces, success measures, and phase boundaries for the first complete-look recommendation loop and its later expansion.

## 2. Problem and opportunity

Current recommendation approaches over-index on similar items, popularity, and co-occurrence. That helps discovery, but it does not reliably answer the styling questions customers actually have when they are trying to complete an outfit:

- what complements this anchor product
- what completes the look for a specific occasion
- which additions are both compatible and worth buying
- how recommendations should reflect prior purchases, taste, and context

SuitSupply already has merchandising and styling expertise that can shape these decisions. The opportunity is to productize that expertise into a governed recommendation capability that improves outfit confidence, attachment across categories, and consistency across surfaces.

## 3. Business outcomes

The complete-look recommendation capability must support these business outcomes:

1. **Reduce outfit-building friction** for customers who start with a suit, jacket, shirt, or occasion but need help completing the look.
2. **Increase conversion and basket size** by presenting complementary items that are coherent, purchasable, and contextually relevant.
3. **Scale SuitSupply styling expertise** so recommendations reflect brand standards rather than generic ecommerce logic.
4. **Create a reusable recommendation capability** that can serve multiple digital and internal surfaces from a shared business definition.
5. **Preserve merchandising control and measurement** so recommendation outputs can be governed, evaluated, and improved over time.

## 4. Target users

### Primary user groups

### 4.1 Occasion-led online shopper

This user shops with a near-term purpose such as a wedding, interview, business trip, or seasonal need. They often start with either one anchor product or a specific occasion and need confidence that the full outfit works together.

### 4.2 Style-aware returning customer

This user has prior purchases, browsing history, or account signals and expects recommendations to improve as SuitSupply learns their style, category preferences, and repeat patterns.

### 4.3 Anchor-product shopper

This user arrives on a product detail page or reaches cart with a high-intent anchor product already selected. They want fast help completing the outfit with compatible complementary items.

### Secondary user groups

### 4.4 In-store stylist or clienteling associate

Needs recommendation outputs that are credible, fast to act on, and aligned with live customer conversations.

### 4.5 Merchandiser or look curator

Needs the recommendation capability to respect curated looks, compatibility rules, campaign intent, and brand standards.

### 4.6 Marketing and CRM manager

Needs reusable look recommendations for lifecycle and campaign communications.

### 4.7 Product, analytics, and optimization lead

Needs measurable recommendation outputs and the ability to compare performance across surfaces and strategies.

## 5. Capability definition

The complete-look recommendation capability must:

1. Generate a **customer-facing outfit recommendation** around an anchor product, customer intent, or occasion.
2. Present the outfit as a **coherent look**, not as an unrelated set of suggested items.
3. Support **complementary recommendation types** within the same experience, especially outfit, cross-sell, and upsell recommendations.
4. Balance **curated**, **rule-based**, and **AI-ranked** inputs without losing merchandising control.
5. Prefer products that are **compatible, purchasable, and relevant** to the active journey.
6. Produce outputs that are **measurable and explainable enough** for optimization, governance, and downstream feature work.

## 6. In-scope surfaces

### 6.1 Capability-level surfaces

The broader capability definition must account for these consuming surfaces because the business requirement should support downstream feature breakdown across them:

- product detail page (PDP)
- cart
- homepage and web personalization surfaces
- style inspiration or look-builder experiences
- email and lifecycle marketing surfaces
- in-store clienteling interfaces

### 6.2 Phase 1 delivery surfaces

Phase 1 delivery is intentionally narrower than the long-term capability:

- **In scope now:** PDP and cart
- **Primary journey now:** RTW anchor-product journey
- **Reason for scope:** these surfaces provide the fastest validation loop for complete-look usefulness, category attachment, and recommendation measurability

### 6.3 Later-phase expansion surfaces

- **Phase 2:** homepage or other web personalization surfaces; more explicit occasion-led discovery support
- **Phase 3:** email and clienteling activation
- **Later phases:** broader look-builder, mobile, partner, and deeper assisted-selling surfaces

## 7. User journeys in scope

### 7.1 Phase 1 in-scope journey: anchor-product complete-look flow

Phase 1 must support the core product-led journey:

1. Customer lands on or adds an anchor RTW product.
2. The business rules for complete-look recommendation determine what additional categories should be considered to complete the outfit.
3. The surface presents a coherent outfit recommendation plus complementary cross-sell and upsell opportunities.
4. The customer can add compatible items with less guesswork.
5. The business can measure whether the recommendation influenced engagement, attachment, and purchase behavior.

### 7.2 Informing journey for later phases: occasion-led discovery flow

The occasion-led journey is an input to this requirement, but it is not part of the first delivery loop. This requirement still must preserve room for that expansion:

1. Customer starts from an occasion, season, or contextual need rather than a single product.
2. The system maps the need to one or more suitable looks.
3. The customer explores and refines outfit options across products and surfaces.

This flow becomes a primary expansion area after the Phase 1 foundation proves recommendation quality and measurability.

## 8. Phase boundaries

### 8.1 Phase 1 must include

- RTW anchor-product recommendation flows
- PDP and cart as the first delivery surfaces
- outfit, cross-sell, and upsell outputs within the complete-look experience
- enough curated and rule-based compatibility to produce coherent looks
- measurable recommendation telemetry for impression, click, add-to-cart, and purchase outcomes
- clear merchandising review and override expectations for the foundational recommendation logic

### 8.2 Phase 1 must not depend on

- broad cross-channel rollout before core quality is proven
- full occasion-led discovery across all surfaces
- deep customer-history personalization
- advanced context enrichment such as weather-driven or location-driven ranking
- full CM configuration-aware recommendation logic
- heavy internal workflow automation before governance is stable

### 8.3 Planned later-phase expansion

- **Phase 2:** richer customer signals, contextual relevance, occasion-led look generation, and broader web personalization surfaces
- **Phase 3:** stronger merchandising control workflows, email activation, clienteling activation, and richer reporting
- **Phase 4:** CM-specific compatibility and premium styling guidance
- **Phase 5+:** broader channel expansion, advanced optimization, and deeper operational maturity

## 9. Functional business requirements

### 9.1 Complete-look outcome requirement

The capability must help customers move from a single item or styling need to a complete outfit with clear next actions.

### 9.2 Outfit coherence requirement

Recommended items must feel like one look that respects category compatibility, style integrity, and brand standards.

### 9.3 Surface readiness requirement

The capability definition must support reuse across multiple surfaces even when delivery begins with PDP and cart only.

### 9.4 Merchandising control requirement

Merchandising teams must be able to shape the look outcomes through curated looks, compatibility rules, and business priorities.

### 9.5 Measurement requirement

Recommendation outputs must be instrumented so the business can evaluate recommendation influence, category attachment, and conversion impact.

### 9.6 Expansion readiness requirement

The Phase 1 definition must leave clear boundaries for later expansion into occasion-led, contextual, personalized, and CM-aware experiences without redefining the core outcome.

## 10. Success measures

### 10.1 Customer and commercial measures

- conversion uplift on PDP and cart experiences influenced by complete-look recommendations, with an initial target range of 5% to 10% on targeted surfaces
- average order value uplift for recommendation-influenced sessions, with an initial target range of 10% to 25%
- category attachment rate from anchor-product sessions
- add-to-cart rate from complete-look recommendation interactions
- engagement with complete-look modules, such as click-through into look components

### 10.2 Capability adoption measures

- coverage of high-priority RTW anchor products with a valid complete-look recommendation path
- share of recommendation sets that present a coherent multi-category outfit rather than isolated same-category items
- merchandising adoption of curated look and compatibility inputs for the initial rollout

### 10.3 Operational and governance measures

- telemetry completeness for recommendation impression and outcome events
- ability to attribute outcomes to a recommendation set and decision trace
- recommendation freshness and surface availability at PDP and cart
- percentage of foundational recommendation logic that is reviewable by merchandising stakeholders

## 11. Constraints and guardrails

- Recommendations must respect privacy, consent, and regional data-use boundaries.
- Customer-facing surfaces must not expose sensitive profile reasoning.
- Recommendation quality must prioritize style coherence and brand fit, not only short-term click optimization.
- Phase 1 must stay narrow enough to validate commercial signal before broad channel rollout.
- The business requirement must keep RTW and CM distinct where their journeys diverge, even though Phase 1 focuses on RTW.

## 12. Assumptions

- SuitSupply can provide enough curated styling knowledge and compatibility logic to support an initial RTW complete-look experience.
- PDP and cart are the most practical first surfaces for validating the first recommendation loop.
- Reliable product and inventory data will be available for Phase 1 recommendation eligibility.
- Occasion-led and personalized expansion can build on the same core complete-look definition once the first loop is stable.

## 13. Open questions for downstream feature breakdown

- Which RTW categories must be covered in the first complete-look definition for Phase 1 launch readiness?
- What minimum level of merchandising override is required before the first rollout is considered safe?
- How should recommendation set success be segmented between anonymous anchor-product shoppers and known returning customers in Phase 1 reporting?
- Which recommendation explanation, if any, should be visible to customers versus retained only for internal analysis?
- What exact completeness standard defines a valid look on PDP and cart for the first rollout?

## 14. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for PDP complete-look delivery
2. feature scope for cart complete-look delivery
3. feature scope for foundational recommendation composition and compatibility governance
4. feature scope for recommendation telemetry and success measurement
5. explicit expansion hooks for occasion-led, personalization, and CM phases without pulling them into Phase 1 delivery

## 15. Exit criteria check

This BR is complete when downstream teams can see:

- the required complete-look recommendation outcomes
- the target users and internal stakeholders
- the in-scope surfaces for both the capability and the Phase 1 rollout
- the success measures that define whether the first loop is working
- the phase boundaries that separate Phase 1 from later personalization, occasion-led, channel, and CM expansion
