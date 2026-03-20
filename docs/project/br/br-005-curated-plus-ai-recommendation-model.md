# Business requirements: BR-005 curated plus AI recommendation model

## Metadata

- **Board Item ID:** BR-005
- **Issue:** #54
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Primary sources:** `docs/project/business-requirements.md` (BR-5), `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/product-overview.md`, `docs/project/standards.md`
- **Output artifact:** `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- **Next stage:** feature breakdown for the blended recommendation model capability

## Problem statement

SuitSupply needs a recommendation model that can turn brand styling expertise into scalable, measurable decisioning across ecommerce, email, and clienteling surfaces. Today, a complete-look recommendation cannot rely on a single source of truth. Purely curated looks do not scale across the full assortment or every shopper context. Purely rule-based logic protects compatibility, but it does not optimize for relevance or business lift on its own. Purely AI-ranked recommendations can improve personalization, but they are not acceptable as a black-box system when merchandising teams need explicit control over brand standards, campaign priorities, and compatibility safety.

The business problem is therefore not only to "rank products better." It is to define how curated looks, rule-based compatibility, and AI ranking should blend into one governed recommendation model that:
- preserves merchandising control and explainability
- scales beyond manual curation alone
- optimizes for conversion, attachment, and complete-look usefulness
- respects RTW and CM differences, regional policies, and consent constraints
- remains auditable enough for operational teams to trust and improve

## Target users

### Primary users
- **Occasion-led online shoppers** who need help turning an anchor garment or occasion into a full outfit
- **Style-aware returning customers** who expect recommendations to reflect prior preferences, purchases, and current intent
- **Custom Made customers** whose in-progress configuration must shape compatible complementary recommendations

### Secondary users
- **In-store stylists and clienteling associates** who need credible, adaptable outfit recommendations during live selling
- **Merchandisers and look curators** who need direct control over curated looks, business rules, campaigns, and overrides
- **Marketing and CRM managers** who need reusable recommendation outputs for campaigns and lifecycle messages
- **Product, analytics, and optimization leads** who need measurable outcomes, experimentation hooks, and traceability

## Business value

This blended recommendation model must create value in three ways:

1. **Commercial value**
   - Increase conversion by reducing outfit-building friction on key surfaces such as PDP, cart, and occasion-led experiences.
   - Increase basket size and attachment rate by recommending compatible complementary items across categories.
   - Improve upsell performance by allowing higher-value options to enter ranking without breaking styling coherence.

2. **Brand and operating value**
   - Scale merchandising expertise beyond manually curated look pages or isolated campaign work.
   - Preserve brand styling integrity through explicit controls rather than allowing opaque ranking logic to override merchandising intent.
   - Support RTW and CM use cases with a common operating model that still respects domain-specific compatibility differences.

3. **Optimization value**
   - Enable AI ranking to improve recommendation order, coverage, and personalization within controlled business boundaries.
   - Create reusable decisioning that can serve ecommerce, email, and clienteling channels consistently.
   - Produce traceable telemetry so teams can measure impact, run experiments, and improve the blend over time.

## Recommendation and channel mapping

### Recommendation types in scope
- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Style bundles
- Occasion-based recommendations
- Contextual recommendations
- Personal recommendations

### Surfaces and channels in scope
- PDP
- Cart
- Homepage and style inspiration experiences where a look-led recommendation is needed
- Email and lifecycle campaign consumption of recommendation outputs
- In-store clienteling and stylist workflows

### Recommendation sources in scope
- **Curated:** merchant-authored or merchant-approved looks, bundles, and campaign-led recommendations
- **Rule-based:** compatibility logic, exclusions, eligibility rules, inventory constraints, regional constraints, and campaign priorities
- **AI-ranked:** scoring and ordering logic that uses customer, context, and performance signals to optimize eligible candidates

## Blended model requirements

### 1. Source roles must be explicit

The platform must treat curated, rule-based, and AI-ranked recommendation sources as distinct layers with separate business responsibilities:
- **Curated layer:** defines approved looks, seed outfits, hero combinations, campaign emphasis, and strategic style intent
- **Rule-based layer:** enforces compatibility, eligibility, exclusions, inventory awareness, consent-aware usage, and operational safeguards
- **AI-ranked layer:** prioritizes among eligible candidates based on customer relevance, context, and performance goals

The model must not collapse these layers into a single opaque ranking output.

### 2. Curated content must have first-class control

Merchandising teams must be able to:
- create or approve canonical looks and style bundles
- pin, boost, suppress, or exclude products, looks, or categories
- define campaign or seasonal priorities
- designate surfaces or regions where curated looks should take precedence
- protect brand-critical combinations from being displaced by purely performance-driven ranking

Curated recommendations may act as:
- a complete recommendation output on their own for select campaigns or hero looks
- a seed set for AI ranking to reorder or personalize within merchant-approved boundaries
- a fallback when customer data is limited or ranking confidence is low

### 3. Rule-based compatibility must gate eligibility before ranking

Hard constraints must be applied before AI ranking is allowed to optimize results. These hard constraints include, at minimum:
- style and category compatibility
- RTW versus CM logic differences
- configuration-aware constraints for CM journeys
- inventory and assortment availability
- regional, seasonal, or campaign eligibility rules
- explicit suppressions, exclusions, and brand-safety rules

If a recommendation candidate violates a hard rule, AI ranking must not surface it.

### 4. AI ranking must optimize within explainable business boundaries

AI ranking must improve the final ordering, coverage, and personalization of eligible recommendation candidates by using signals such as:
- current surface and session intent
- customer history and preference patterns where permitted
- regional and contextual factors such as season, weather, and location
- aggregate performance signals such as click-through, add-to-cart, purchase, and attachment outcomes

AI ranking must remain explainable enough for internal users to understand:
- which curated source or rule set constrained the result
- why a candidate or look was included, boosted, or suppressed
- which high-level signals contributed to the ranking decision

The business requirement is explainable optimization, not black-box autonomy.

### 5. The blend must support multiple operating modes

The blended model must support different operating modes by surface, journey, and business need:
- **Curated-dominant mode:** merchant-led hero looks or campaign experiences where AI personalization is constrained
- **Rules-dominant mode:** high-risk or high-complexity flows such as CM compatibility where safety and validity matter most
- **AI-assisted mode:** curated and rule-safe candidates are reordered or expanded for better relevance
- **Fallback mode:** when customer or context signals are sparse, the system can rely more on curated and rule-based logic without failing the surface

### 6. RTW and CM behavior must remain distinct where needed

For RTW, the blend should emphasize broad outfit completion, attachment, and inventory-aware ranking.

For CM, the blend must account for configuration state, premium options, and compatibility dependencies that make incorrect recommendations more damaging to trust. CM flows may require tighter rules and more constrained AI ranking than RTW flows.

### 7. Governance and auditability are mandatory

The blended model must preserve an internal audit trail that records:
- the recommendation set ID and trace context for each recommendation set
- the curated source, rule set, campaign, or experiment that influenced the result
- the ranking strategy or variant used
- any override, suppression, or fallback condition applied

Internal teams must be able to inspect why an output was produced without exposing sensitive profile reasoning to customers.

## Scope boundaries

### In scope
- Defining the business role of curated, rule-based, and AI-ranked sources in recommendation generation
- Defining precedence and interaction rules between those sources
- Defining merchandising control expectations, override capabilities, and explainability needs
- Defining business-facing success criteria for the blended model
- Defining RTW and CM business differences relevant to source blending
- Defining governance, traceability, experimentation, and measurement expectations for this model

### Out of scope
- Detailed model architecture, feature engineering, API contracts, or service decomposition
- Specific machine learning algorithms or vendor/tool choices
- UI design for merchant authoring tools or customer-facing recommendation modules
- Final threshold values for ranking confidence, score weights, or experiment significance
- Downstream implementation sequencing beyond noting the next-stage need for feature breakdown

## Business controls and governance expectations

The blended model must include the following business controls:
- merchant-defined pins, boosts, suppressions, and exclusions
- campaign and seasonal priority controls
- surface-specific and region-specific control of source precedence
- rule versioning and traceability for recommendation-impacting changes
- experimentation controls that keep hard compatibility and brand-safety rules in force
- fallback behavior when AI confidence, customer identity confidence, or context quality is insufficient
- internal explanation views that show source contribution and decision context

Governance expectations include:
- no black-box ranking that merchandisers cannot inspect or constrain
- no AI optimization that overrides hard compatibility or policy constraints
- auditable linkage between recommendation outputs and their contributing curated assets, rules, and experiments
- explicit handling of privacy, consent, and regional data usage boundaries

## Success criteria

### Business outcome criteria
- The blended model improves conversion on targeted recommendation surfaces relative to non-blended or less governed approaches.
- The model improves attachment rate and AOV for recommendation-influenced sessions by increasing complete-look usefulness.
- Merchandising teams can shape recommendation outcomes without requiring engineering intervention for routine campaign and assortment adjustments.

### Product outcome criteria
- Recommendation outputs can clearly identify whether the result was driven by curated, rule-based, AI-ranked, or blended logic.
- The system can support curated-dominant, rules-dominant, AI-assisted, and fallback modes without redefining the business model per surface.
- RTW and CM recommendation flows can use the same blended framework while preserving their required compatibility differences.

### Operational outcome criteria
- Recommendation telemetry captures recommendation set ID, trace context, impression, click, add-to-cart, purchase, dismiss, and override events for this model.
- Internal teams can inspect the source contributions and business controls that affected a recommendation set.
- Experimentation can compare alternative blending strategies without bypassing governance controls.

### Initial measurable targets

Where the goals document already provides directional targets, this BR inherits them as initial success targets for downstream planning:
- conversion uplift of **5% to 10%** on targeted surfaces
- AOV uplift of **10% to 25%** for recommendation-influenced sessions
- improved repeat purchase and engagement behavior for customers exposed to personalized outfit recommendations

Additional operational baselines and threshold targets remain a missing decision for downstream feature and analytics work.

## Assumptions

- Merchandising teams can provide enough curated looks, compatibility rules, and campaign intent to seed the blended model.
- Customer, product, inventory, and context inputs are available at sufficient quality for AI ranking to operate within governance boundaries.
- Not every surface will use the same source blend; surface-specific operating modes are acceptable and expected.
- Explainability for internal users is required even when customer-facing explanations remain minimal.

## Open decisions

- **Missing decision:** Which surfaces should launch first for the blended model: PDP only, PDP plus cart, or a broader set including email and clienteling?
- **Missing decision:** What level of merchant control is required at launch: boosts and suppressions only, or full curated look authoring and campaign precedence controls?
- **Missing decision:** What is the initial fallback policy when AI ranking confidence is low or customer identity confidence is weak?
- **Missing decision:** Which CM recommendation scenarios are in first-release scope versus deferred to later phases?
- **Missing decision:** What internal explanation detail is required for merchandisers versus analytics users versus stylists?
- **Missing decision:** What baseline and target operational thresholds should be used for coverage, override usage, and recommendation freshness?

## Approval and milestone-gate notes

- **Approval mode:** `autonomous` for this milestone per repository bootstrap guidance.
- **Human gate note:** Human review remains relevant for sensitive future decisions involving CM policy, data usage, and major merchandising-control changes, but it does not block this autonomous BR run from being committed, pushed, or placed into PR.

## Recommended board update

Add or update `boards/business-requirements.md` with BR-005 pointing to this artifact, using a non-blocking status once the branch is pushed and PR is open.
