# BR-002: Multi-type recommendation support

## Traceability

- Board Item ID: BR-002
- Source Issue: #51
- Trigger: issue-created automation
- Stage: workflow:br
- Parent Item: none
- Source Artifacts:
  - `docs/project/business-requirements.md`
  - `docs/project/product-overview.md`
  - `docs/project/goals.md`
  - `docs/project/roadmap.md`
  - `docs/project/personas.md`
  - `docs/project/problem-statement.md`
- Intended downstream stage: feature breakdown in `boards/features.md` (item ID TBD)

## Problem statement

SuitSupply needs a recommendation layer that can serve more than one recommendation intent without collapsing every decision into a single "similar items" or "complete the look" pattern. Customers and internal teams need distinct recommendation types because the business is trying to solve multiple adjacent problems at once:

- help a shopper complete a coherent outfit around an anchor item
- increase attachment across categories with complementary items
- surface higher-value compatible alternatives or premium additions
- adapt recommendations to season, weather, location, and journey context
- improve relevance for returning customers with known preferences
- package reusable looks that merchandising, marketing, and clienteling teams can activate consistently

Without an explicit taxonomy, rollout order, and boundary definition, downstream feature and implementation work would blur recommendation types together, making it harder to measure commercial impact, define success criteria, and preserve merchandising control.

## Target users

### Primary customer users

- Occasion-led online shoppers who start with an anchor product or event and need help building a complete outfit
- Style-aware returning customers who expect recommendations to reflect prior purchases, browsing history, and taste
- Customers shopping across RTW journeys where outfit completion, attachment selling, and premium guidance directly affect conversion

### Secondary internal users

- Merchandisers and look curators who need reusable recommendation types with explicit controls and boundaries
- Marketing and CRM teams who need recommendation outputs that can be activated beyond ecommerce surfaces
- In-store stylists and clienteling associates who need recommendation sets that are credible, explainable, and operationally usable
- Product, analytics, and optimization teams who need recommendation types to be measurable separately rather than blended into one undifferentiated module

## Business value

Multi-type recommendation support is required to deliver the commercial goals already defined in the project docs:

- increase conversion by matching recommendation intent to the customer decision point instead of overusing one generic module
- increase basket size and AOV by separating complementary attachment logic from premium or alternative-item logic
- improve repeat purchase and retention by allowing personal recommendation depth to grow over time
- scale SuitSupply merchandising knowledge into reusable recommendation artifacts such as curated style bundles and governed compatibility rules
- support multi-channel activation across PDP, cart, homepage, email, and clienteling without reinventing recommendation logic per surface
- preserve brand safety and governance by defining where curated, rule-based, and AI-ranked logic should dominate for each recommendation type

## Recommendation type taxonomy and business boundaries

This BR defines six required recommendation types for phased delivery. Source docs also mention occasion-based recommendations. For BR-002, occasion-led intent is treated as a contextual driver that can be broken out into a more explicit downstream feature if later planning requires it.

| Recommendation type | Primary business intent | Typical surfaces | Primary decision sources | Initial rollout priority | Boundaries and guardrails | Primary success metrics |
|---|---|---|---|---|---|---|
| Outfit | Build a complete outfit around an anchor product, look, or intent | PDP, cart, style inspiration, clienteling | Curated looks, rule-based compatibility, AI-ranked assembly | Phase 1 | Must produce a coherent cross-category outfit; must respect compatibility, inventory, and brand rules; is not a mandatory checkout bundle | Outfit click-through rate, complete-look add-to-cart rate, recommendation-influenced conversion, average items per influenced order |
| Cross-sell | Increase complementary attachment across categories | PDP, cart, email, clienteling | Rule-based complements, curated associations, AI ranking | Phase 1 | Must prioritize complementary items over redundant substitutes; must remain compatible with anchor product and current basket | Attach rate, recommendation add-to-cart rate, cross-category penetration, AOV uplift for influenced sessions |
| Upsell | Surface higher-value alternatives or premium additions that remain compatible | PDP, cart, clienteling, later CM journeys | Merchandising rules, eligibility logic, AI ranking | Phase 1 | Must not recommend incompatible or unjustified price jumps; must keep brand credibility and inventory reality intact | Upsell acceptance rate, premium mix shift, AOV uplift, margin-oriented proxy metrics where approved |
| Contextual | Adapt recommendation sets to season, weather, location, regional assortment, session state, and occasion-like context | Homepage, PDP, cart, email | Context rules, inventory awareness, AI ranking with context features | Phase 2, with broader depth in Phase 3 | Must degrade gracefully when context is missing; must not depend on personal identity; must expose coarse context reasoning internally only | CTR lift versus non-contextual baseline, influenced conversion by context cohort, context coverage rate, fallback rate when context is unavailable |
| Personal | Improve relevance using permitted customer profile, preference, and behavior signals | Homepage, PDP, cart, email, clienteling | Customer profile signals, curated exclusions, AI ranking, governance rules | Phase 2, with broader depth in Phase 3 | Must respect consent and regional policy; must support anonymous fallback; must not expose sensitive profile reasoning on customer-facing surfaces | Returning-customer CTR lift, repeat purchase lift, recommendation-influenced revenue per returning customer, dismiss rate reduction versus non-personal baseline |
| Style bundle | Reuse grouped looks or curated combinations as a merchandising asset across channels | Style inspiration, homepage, PDP, email, clienteling | Curated look bundles, rule-based eligibility, AI-ranked ordering of bundle options | Internal foundation in Phase 1, customer-visible rollout in Phases 2-3 | Is a reusable look artifact, not a required bundle discount or checkout mechanic; item-level eligibility, inventory, and substitution rules still apply | Bundle engagement rate, multi-item add-to-cart from bundle exposure, bundle-driven outfit completion rate, reuse/adoption by merchandising and marketing teams |

## Phase sequencing and rollout priorities

| Phase | Recommendation types in scope | Primary surfaces | Commercial purpose | Key boundaries |
|---|---|---|---|---|
| Phase 1 - foundation and first recommendation loop | Outfit, cross-sell, upsell | PDP and cart, RTW-first | Validate complete-look usefulness, attachment selling, and premium guidance on high-signal surfaces | Limit scope to high-confidence RTW anchor-product flows; style bundle support may exist as an internal curated artifact, but not yet as a broadly activated customer-facing type |
| Phase 2 - personalization and context enrichment | Contextual, personal, early customer-visible style bundle activation; ongoing optimization of Phase 1 types | Homepage, web personalization, selected inspiration surfaces, PDP/cart expansion | Improve relevance for repeat visitors and context-rich sessions while broadening reusable look activation | Context and personal logic must build on Phase 1 telemetry and governance; anonymous and low-context fallbacks remain mandatory |
| Phase 3 - multi-channel activation and operational scale | Deeper contextual, personal, and style-bundle activation across channels; continued outfit, cross-sell, and upsell optimization | Email, clienteling, broader ecommerce surfaces | Reuse recommendation outputs across channels and internal workflows with measurable governance | Channel expansion should only occur after recommendation quality, telemetry, and override controls are stable |
| Phase 4 - CM-aware extension | CM-specific extensions across outfit, upsell, contextual, and personal logic | CM flows, appointment support, advanced clienteling | Expand commercial value into higher-consideration tailoring journeys without oversimplifying CM compatibility | CM rollout must preserve configuration-aware compatibility and may require stronger human-in-the-loop review |

## Scope boundaries

### In scope

- Define the supported business taxonomy for outfit, cross-sell, upsell, contextual, personal, and style-bundle recommendations
- Define phase sequencing and commercial priority for those recommendation types
- Define business boundaries so downstream work can distinguish recommendation types clearly
- Define success metrics and common telemetry expectations for each recommendation type
- Define RTW-first rollout expectations and later CM extension boundaries
- Define how curated, rule-based, and AI-ranked decision sources should coexist at the business-requirement level

### Out of scope

- API contract design, service decomposition, ranking algorithms, or implementation architecture beyond what canonical project docs already cover
- Channel-specific UI design or exact module layouts
- Final numeric KPI targets by region, market, or surface when baselines are not yet available
- Mandatory bundle pricing, checkout bundling, or promotion-engine behavior
- Detailed CM implementation requirements for every recommendation type in this BR stage
- Formal downstream breakdown of occasion-based recommendations as a separate feature unless later planning decides it needs its own work item

## RTW and CM considerations

- Phase 1 is RTW-first because it is the fastest path to validating outfit completion, cross-category attachment, and premium guidance on PDP and cart.
- CM is not excluded from the long-term taxonomy, but CM-specific recommendation depth should arrive only after the platform can represent configuration state, fabric compatibility, detail interactions, and premium option logic safely.
- Every recommendation type defined here must remain extensible to CM, but downstream planning should not assume Phase 1 parity between RTW and CM.
- Upsell and outfit logic for CM require extra scrutiny because premium guidance and compatibility mistakes can damage trust more quickly in higher-consideration journeys.

## Success metrics

### Shared measurement requirements

All recommendation types must use shared recommendation telemetry where applicable:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Each event should remain attributable through recommendation set ID, trace ID, recommendation type, surface, channel, relevant product or look IDs, and experiment or rule context where available.

### Type-specific outcome metrics

| Recommendation type | Core business metrics | Supporting operational metrics |
|---|---|---|
| Outfit | Recommendation-influenced conversion, complete-look add-to-cart rate, average items per influenced order | Coverage by anchor category, compatibility pass rate, full telemetry traceability |
| Cross-sell | Attach rate, cross-category penetration, AOV uplift | Coverage by anchor and basket state, inventory-valid recommendation rate |
| Upsell | Upsell acceptance rate, premium mix shift, AOV uplift | Guardrail compliance, stock-aware premium recommendation rate |
| Contextual | CTR lift by context cohort, influenced conversion by season/weather/location cohort | Context availability rate, fallback rate, freshness of external context inputs |
| Personal | Returning-customer CTR lift, repeat purchase lift, influenced revenue per returning customer | Identity confidence coverage, consent-compliant activation rate, anonymous fallback rate |
| Style bundle | Bundle engagement rate, multi-item add-to-cart from bundle exposure, bundle-driven outfit completion | Bundle freshness, reusable bundle coverage by campaign or season, bundle traceability |

## Open decisions

- Missing decision: whether occasion-based recommendations should remain modeled as a contextual sub-mode or become a first-class downstream feature alongside the six core types in this BR.
- Missing decision: which customer-facing surface should receive the first visible style-bundle experience in Phase 2.
- Missing decision: which premium thresholds or pricing guardrails should constrain upsell behavior by market or category.
- Missing decision: which customer signals are approved for early personal recommendations by region, especially where stylist notes, appointments, or cross-channel identity linking may be sensitive.
- Missing decision: what numeric baseline and target ranges should be set per recommendation type once initial telemetry exists on the first rollout surfaces.

## Approval and milestone-gate notes

- Approval mode for the BR stage is not explicitly recorded on an existing board in this repo, so this artifact uses the conservative default of `HUMAN_REQUIRED` for board metadata.
- This run is autonomous, so commit, push, and PR creation are completed without waiting for a human approval click.
- No separate BR-stage milestone gate is defined beyond normal review of the artifact and board row.

## Recommended board update

Add or update `BR-002` in `boards/business-requirements.md` with:

- Status: `In PR` once the branch is pushed
- Approval Mode: `HUMAN_REQUIRED`
- Trigger Source: GitHub issue #51 plus the canonical source docs listed above
- Output: `docs/project/br/br-002-multi-type-recommendation-support.md`
- Notes: autonomous issue-created run completed commit, push, and PR without blocking on manual sign-off
