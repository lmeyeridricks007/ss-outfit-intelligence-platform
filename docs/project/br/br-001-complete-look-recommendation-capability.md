# BR-001: Complete-look recommendation capability

## 1. Metadata and traceability

- **Board Item ID:** BR-001
- **Issue:** #75
- **Parent Item:** None
- **Stage:** workflow:br
- **Phase:** Phase 1
- **Trigger:** issue-created automation
- **Approval Mode:** AUTO_APPROVE_ALLOWED
- **Primary source artifacts:**
  - `docs/project/business-requirements.md`
  - `docs/project/product-overview.md`
  - `docs/project/problem-statement.md`
- **Supporting inputs:**
  - `docs/project/vision.md`
  - `docs/project/goals.md`
  - `docs/project/personas.md`
  - `docs/project/roadmap.md`
- **Downstream target:** feature breakdown in `boards/features.md` and follow-on feature artifacts derived from this BR

## 2. Business requirement summary

SuitSupply needs a business-defined complete-look recommendation capability that helps customers move from an anchor item or occasion into a coherent outfit, rather than receiving isolated product suggestions. The capability must define who it serves, where it appears, which recommendation outcomes matter, and how rollout is phased so downstream product and build work can implement it without guessing scope.

This BR covers two core journeys that already appear in the project source material:

1. **Anchor-product journey:** a customer lands on a suit, jacket, shirt, or other anchor product and needs help completing the rest of the outfit.
2. **Occasion-led journey:** a customer starts with an event or intent such as wedding, interview, business travel, or seasonal refresh and needs recommendations that assemble an appropriate look.

## 3. Problem statement

SuitSupply customers frequently know the first item they want or the occasion they are shopping for, but they still need help deciding what completes the look. Existing ecommerce recommendation patterns are too narrow because they emphasize similar items, popularity, or co-occurrence instead of styling coherence, occasion fit, and customer relevance.

That gap creates three business problems:

- customers face friction and uncertainty when trying to build a full outfit
- commercial surfaces miss cross-category attachment and upsell opportunities
- internal teams cannot consistently apply SuitSupply styling expertise across ecommerce, marketing, and in-store journeys

The required capability is therefore not a generic recommender widget. It is a governed outfit intelligence capability that turns curated looks, compatibility rules, customer context, and AI ranking into complete-look recommendations across prioritized surfaces.

## 4. Desired outcomes

The complete-look recommendation capability must deliver these outcomes:

- help customers complete a coherent outfit with more confidence and less decision effort
- increase conversion and basket size by presenting compatible complementary products at high-intent moments
- improve discovery for occasion-led shopping by translating intent into relevant looks and products
- make recommendations more personal and context-aware for returning customers without breaking brand styling integrity
- give merchandising, marketing, styling, and analytics teams a reusable recommendation capability instead of disconnected channel-specific logic

## 5. Target users

## 5.1 Primary users

### Occasion-led online shopper

This user needs help translating an event or need into a complete outfit. They are highly relevant for occasion-led discovery surfaces and for any experience that starts from intent rather than a single SKU.

### Style-aware returning customer

This user expects recommendations to reflect prior purchases, browsing behavior, and known taste. They are especially important for personalization expansion after the first recommendation loop is proven.

### Anchor-product shopper

This is the customer who lands on a product detail page with a clear anchor item in mind and needs the rest of the outfit assembled around it. This is the most immediate Phase 1 customer target.

## 5.2 Secondary users

### Custom Made customer

This user is part of the long-term capability boundary, but full CM-aware recommendation depth is not a Phase 1 requirement. CM must be accounted for in phase planning so later work does not assume RTW-only architecture forever.

### In-store stylist and clienteling associate

This user consumes recommendation outputs as decision support in customer conversations. They are not a Phase 1 launch consumer, but they are in the capability boundary.

### Merchandiser and look curator

This internal user must be able to shape curated looks, compatibility rules, and overrides so the capability remains brand-safe and governable.

### Marketing, CRM, product, and analytics teams

These internal users need reusable outputs, telemetry, and measurable business lift so the capability can expand across channels and experiments.

## 6. Recommendation scope definition

The capability defined by this BR must support complete-look recommendation as a business outcome, not just product adjacency.

### 6.1 Recommendation types in capability scope

- **Outfit recommendations:** customer-facing complete looks assembled around an anchor item, intent, or occasion
- **Cross-sell recommendations:** compatible complementary items that increase category attachment
- **Upsell recommendations:** premium or higher-value alternatives that still preserve outfit coherence
- **Occasion-based recommendations:** looks shaped by event or use-case intent
- **Contextual recommendations:** outputs influenced by season, location, weather, or session context
- **Personal recommendations:** outputs influenced by known customer history and preferences
- **Style bundles / curated looks:** reusable curated groupings that can seed or constrain recommendations

### 6.2 Recommendation sources in capability scope

- curated looks authored or approved by merchandising teams
- rule-based compatibility and eligibility logic
- AI-ranked ordering and selection that optimizes relevance within governance boundaries

## 7. In-scope surfaces and channel boundaries

This section defines which surfaces belong to the capability boundary and how they phase in.

### 7.1 Phase 1 in-scope launch surfaces

- **Product detail page (PDP):** primary surface for anchor-product complete-look recommendations
- **Cart:** secondary high-intent surface for compatible add-on and outfit-completion recommendations

These are the first required surfaces because they offer the clearest commercial signal and align with the roadmap guidance to validate recommendation quality on one or two high-signal digital surfaces first.

### 7.2 Phase 2 expansion surfaces

- **Homepage / web personalization surfaces**
- **Style inspiration or look-builder pages**
- **Occasion-led discovery entry points**

These surfaces are in capability scope, but they follow after the Phase 1 loop proves recommendation quality, telemetry completeness, and governance reliability.

### 7.3 Phase 3 expansion channels

- **Email and lifecycle marketing placements**
- **In-store clienteling interfaces**

These are part of the complete-look capability boundary because the product vision is multi-channel, but they are not required for Phase 1 completion.

### 7.4 Out of scope for Phase 1

- mobile-native or partner surfaces
- broad cross-channel rollout before PDP and cart quality is proven
- channel-specific UI implementation details
- replacement of checkout, ESP, POS, OMS, or other core systems

## 8. Scope boundaries

### 8.1 In scope for this BR

- define complete-look recommendation outcomes for anchor-product and occasion-led journeys
- define target user groups and how priority differs by phase
- define recommendation types and sources the capability must support
- define in-scope surfaces and channel expansion order
- define success measures for business, product, and operational evaluation
- define phase boundaries that separate the first recommendation loop from later personalization, multi-channel, and CM expansion
- preserve merchandising governance, telemetry, and explainability as first-class business requirements

### 8.2 Out of scope for this BR

- technical architecture, APIs, data models, or implementation design
- page layouts, component designs, or surface-specific UI specifications
- experiment design details beyond business success intent
- downstream feature decomposition or engineering task breakdown

## 9. RTW and CM considerations

### 9.1 RTW expectations

Phase 1 is centered on RTW anchor-product journeys because they provide the clearest path to a first recommendation loop on PDP and cart. RTW recommendations must support immediate compatibility decisions across suits, jackets, shirts, knitwear, shoes, and accessories.

### 9.2 CM expectations

CM remains inside the long-term business boundary of the capability, but deep CM configuration-aware logic is not part of Phase 1 delivery. Downstream planning must preserve room for later CM requirements including:

- fabric and palette compatibility
- premium option compatibility
- configuration-state-aware recommendation logic
- stylist-assisted and appointment-led workflows

### 9.3 Boundary decision

This BR does **not** require full CM delivery in Phase 1. It does require later stages to avoid defining the capability as permanently RTW-only.

## 10. Phase boundaries

## 10.1 Phase 1 boundary: foundation and first recommendation loop

Phase 1 must establish the minimum business scope required to prove complete-look recommendation value:

- focus on RTW anchor-product journeys first
- deliver recommendations on PDP and cart
- support outfit, cross-sell, and upsell recommendation types first
- use curated looks and compatibility logic with measurable telemetry
- prove that recommendation outputs are coherent, purchasable, and commercially meaningful

## 10.2 Phase 2 boundary: personalization and context enrichment

Phase 2 expands the capability once the first loop is proven:

- introduce stronger customer-history and identity-based relevance
- extend into occasion-led and contextual recommendation depth
- expand to homepage, web personalization, and broader discovery surfaces

## 10.3 Phase 3 boundary: operational activation across channels

Phase 3 broadens business consumption of the capability:

- support email and clienteling consumers
- increase merchandising controls, override workflows, and campaign-aware activation
- make recommendation outputs reusable for internal teams beyond ecommerce

## 10.4 Phase 4 boundary: CM and advanced outfit intelligence

Phase 4 extends the capability into deeper CM and premium outfit-building journeys:

- support configuration-aware recommendation logic
- handle more complex compatibility decisions
- support stylist-assisted premium workflows without oversimplifying CM

## 11. Business value and success measures

## 11.1 Business value

This capability is expected to create value through:

- higher conversion on targeted high-intent surfaces
- higher basket size and average order value through cross-category attachment
- stronger repeat relevance for returning customers
- stronger differentiation versus standard ecommerce recommendation patterns
- better reuse of styling intelligence across channels and internal teams

## 11.2 Success measures

### Commercial measures

- conversion uplift on targeted recommendation surfaces, using the project goal range of **5% to 10%** where validated
- average order value uplift for recommendation-influenced sessions, using the project goal range of **10% to 25%** where validated
- improvement in cross-category attachment for recommendation-influenced sessions

### Product and experience measures

- complete-look engagement rate on PDP and cart
- click-through rate on recommendation modules
- add-to-cart rate from recommendation interactions
- purchase conversion from recommendation-influenced sessions
- progression from occasion-led entry points into purchasable looks in later phases

### Operational and governance measures

- telemetry completeness for impression, click, add-to-cart, purchase, dismiss, and override events where applicable
- recommendation coverage across priority categories and launch surfaces
- ability for internal teams to understand why a recommendation set was shown
- measurable use of merchandising controls and overrides without breaking recommendation performance

### Phase 1 success interpretation

Phase 1 is successful when PDP and cart recommendations consistently produce coherent outfits, generate measurable commercial lift, and provide enough telemetry and governance evidence to justify expansion into richer personalization and additional surfaces.

## 12. Business requirements for downstream feature work

Downstream feature work derived from this BR must preserve these business requirements:

1. The capability must optimize for **complete-look usefulness**, not recommendation volume.
2. Recommendations must remain **stylistically coherent, purchasable, and brand-safe**.
3. Merchandising control and compatibility rules must remain explicit even when AI ranking is added.
4. Surface rollout must be **phased**, not treated as a simultaneous all-channel launch.
5. Phase 1 must prove value on PDP and cart before broader surface expansion.
6. Occasion-led discovery is part of the business scope, even if the first launch centers on anchor-product flows.
7. Customer data usage must respect consent and regional policy boundaries.
8. Telemetry and recommendation traceability are mandatory business requirements, not optional instrumentation.

## 13. Open decisions

- **Missing decision:** what exact regional rollout is included in the first launch, and whether region-specific assortment constraints materially change the Phase 1 scope
- **Missing decision:** whether Phase 2 surface expansion should prioritize homepage personalization or style inspiration / look-builder experiences first
- **Missing decision:** how much occasion-led discovery should be delivered in the first feature breakdown versus held for the second phase
- **Missing decision:** what customer signals are approved for cross-channel personalization in each region, especially for stylist notes, appointments, and identity linking
- **Missing decision:** how recommendation explanations should differ between customer-facing surfaces and internal tools

## 14. Non-blocking notes for follow-on stages

- The feature breakdown stage should split this BR into capability slices for anchor-product recommendation retrieval, occasion-led discovery, merchandising governance, telemetry, and phased surface expansion.
- Phase 1 should not overextend into broad multi-channel delivery before PDP and cart performance is measurable.
- CM should remain visible in follow-on planning even though deep CM implementation is a later phase concern.

## 15. Recommended board update

Add or update `BR-001` in `boards/business-requirements.md` with a non-blocking status for autonomous workflow completion, referencing issue #75 and this artifact as the output of the BR stage.
