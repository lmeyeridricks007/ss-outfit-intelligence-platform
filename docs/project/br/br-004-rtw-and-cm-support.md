# BR-004: RTW and CM support

## Metadata

- **Board item ID:** BR-004
- **Issue:** #53
- **Parent item:** None
- **Stage:** workflow:br
- **Approval mode:** autonomous
- **Trigger:** issue-created automation
- **Source artifacts:** `docs/project/business-requirements.md`, `docs/project/product-overview.md`, `docs/project/personas.md`, `docs/project/roadmap.md`

## Problem statement

SuitSupply needs outfit intelligence that serves both Ready-to-Wear (RTW) and Custom Made (CM) without forcing them into one flattened journey. RTW customers usually need fast, purchasable, complete-look guidance around finished products, while CM customers move through a higher-consideration journey shaped by configuration state, premium choices, and often stylist or appointment support. If the platform treats RTW and CM as interchangeable, RTW experiences lose speed and clarity, while CM recommendations become unreliable because they ignore fabric, detail, palette, and premium-option compatibility. The business requirement is therefore to define a shared platform scope with explicit boundaries for where RTW and CM can share recommendation infrastructure and where they must remain differentiated.

## Target users

### Primary personas

- **Occasion-led online shopper:** needs fast RTW complete-look guidance that reduces styling friction and helps complete an outfit from an anchor item.
- **Style-aware returning customer:** expects relevance to improve over time and may move between RTW and CM journeys depending on occasion and purchase intent.
- **Custom Made customer:** needs recommendations that respect in-progress garment configuration, premium choices, and look coherence.

### Secondary personas

- **In-store stylist / clienteling associate:** needs credible RTW and CM outfit suggestions that support live conversations without hiding judgment or brand rules.
- **Merchandiser / look curator:** needs separate governance and compatibility controls for RTW and CM so recommendations stay brand-safe and operationally manageable.

## Business value

- Increase RTW conversion and attachment by reducing the effort required to build a coherent outfit from finished products.
- Improve CM trust and premium attach by recommending complementary items that respect current configuration choices instead of generic product similarity.
- Preserve SuitSupply brand integrity by making recommendation differences between RTW and CM explicit, governable, and auditable.
- Allow the platform roadmap to validate commercial value quickly through RTW-first rollout while still establishing the business contract for deeper CM support.

## Recommendation and channel mapping

### Recommendation types

- **RTW:** outfit, cross-sell, upsell, occasion-based, and contextual recommendations on high-signal ecommerce surfaces.
- **CM:** configuration-aware outfit guidance, complementary-item cross-sell, premium upsell, and stylist-assisted recommendation sets for configured garments.

### Consuming surfaces

- **RTW first:** PDP, cart, and other early digital surfaces aligned to the Phase 1 recommendation loop.
- **CM later depth:** clienteling and appointment-assisted flows first where human support matters, then broader customer-facing expansion once configuration-aware logic is reliable.

### Recommendation sources

- **Curated:** branded looks, premium styling guidance, and merchandising-approved combinations.
- **Rule-based:** compatibility constraints for fabric, color palette, style details, assortment, and eligibility.
- **AI-ranked:** ranking that personalizes and prioritizes outputs only after curated and compatibility controls are satisfied.

## Scope boundaries

### In scope

- Define RTW and CM as related but distinct recommendation journeys within one outfit intelligence platform.
- Make RTW the first rollout path for high-confidence anchor-product and complete-look flows.
- Define CM support requirements at the business level now, including configuration-aware compatibility, premium styling needs, and stylist-assisted workflows, even where deeper implementation arrives later.
- Specify which decision factors must remain distinct across RTW and CM, including immediacy, configuration state, premium-option handling, compatibility rules, and governance expectations.
- Require governance that separates curated, rule-based, and AI-ranked recommendation behavior for RTW and CM.
- Require phased rollout assumptions so downstream planning does not over-scope early releases or hide CM complexity.

### Out of scope

- Technical architecture, API contracts, or data-model design for RTW and CM logic.
- Full CM sophistication in the first rollout, including exhaustive configuration coverage or fully automated premium styling.
- A single customer experience or schema that forces RTW and CM to expose the same steps, controls, or compatibility assumptions.
- Broad multi-channel launch for both RTW and CM at once before RTW recommendation quality, telemetry, and governance are stable.

## RTW and CM scope comparison

| Dimension | RTW requirement | CM requirement |
|-----------|-----------------|----------------|
| Journey shape | Product-led, faster decisions, often anchored on a finished garment | Configuration-led, iterative decisions influenced by garment state and premium choices |
| Primary user outcome | Build a purchasable complete outfit quickly and confidently | Build a coherent premium look that remains compatible as configuration choices evolve |
| Compatibility drivers | Category, fit, color, pattern, season, occasion, inventory, and brand styling rules | Fabric, color family, style details, premium options, configuration state, and stylist guidance |
| Recommendation behavior | Favor speed, purchasability, and high-confidence attachment opportunities | Favor coherence, explanation, and safe guidance over aggressive automation |
| Human assistance | Optional and usually indirect | More likely through appointment, clienteling, or stylist-assisted workflows |
| Rollout priority | First rollout path | Deeper maturity in Phase 4 after shared platform controls are proven |

## Differentiated user outcomes

### RTW outcomes

- The shopper can start from an anchor item and add compatible complementary products with minimal effort.
- Recommendations emphasize immediate purchasability, stylistic coherence, and attach opportunities.
- Returning customers can receive more relevant RTW suggestions without slowing the core shopping flow.

### CM outcomes

- The customer receives guidance that stays aligned with the configured garment instead of breaking when options change.
- Premium suggestions feel credible, brand-safe, and appropriate to the customer journey.
- Stylists and clienteling teams can use the recommendation output as guidance for live conversations, not as an opaque replacement for judgment.

## Governance needs

- Maintain explicit **separation of compatibility rules** for RTW and CM where attributes and decision states differ.
- Require **merchandising-approved curated looks and premium guidance**, especially when recommendations influence premium CM combinations.
- Preserve **traceability** for whether a recommendation was driven by curation, compatibility rules, AI ranking, or a combination of these.
- Introduce **human-review expectations** for sensitive CM and premium styling logic before broad automation is expanded.
- Prevent rollout decisions from implying that CM is "supported" if the platform only handles RTW logic plus superficial premium labels.
- Keep **brand styling integrity and consent-aware personalization** as equal constraints alongside commercial optimization.

## Phased rollout assumptions

| Phase | Assumption | Business implication |
|------|------------|----------------------|
| Phase 1 | RTW anchor-product flows are the first release path on high-signal digital surfaces. | Early value should come from fast, measurable RTW complete-look recommendations. |
| Phase 2-3 | Shared customer, context, governance, and telemetry foundations expand before deeper CM sophistication. | The platform should improve relevance and control without pretending CM parity already exists. |
| Phase 4 | CM configuration-aware retrieval, ranking, premium guidance, and stylist-assisted depth mature here. | CM support becomes materially deeper only when configuration state and premium compatibility can be represented responsibly. |

## Success metrics

### RTW-oriented measures

- Recommendation click-through rate, add-to-cart rate, and purchase influence for RTW complete-look surfaces.
- Attachment rate and average order value uplift for sessions influenced by RTW recommendation sets.
- Recommendation coverage for RTW anchor products on prioritized launch surfaces.

### CM-oriented measures

- Stylist or customer engagement with CM complementary recommendations and premium suggestions.
- Reduction in incompatible or low-credibility recommendation outcomes observed during CM journeys.
- Premium attach or complementary-item attach for eligible CM journeys where recommendation guidance is active.

### Governance and rollout measures

- Percentage of recommendation sets with traceability to curated, rule-based, and AI-ranked inputs.
- Ability for merchandising teams to review and override RTW and CM guidance separately.
- Clear rollout reporting that distinguishes RTW launch success from later CM maturity rather than blending them into one metric set.

## Missing decisions

- **Missing decision:** Which CM surfaces should receive the earliest limited support before full Phase 4 depth: clienteling only, appointment tooling, or selected customer-facing journeys?
- **Missing decision:** Which CM attributes are mandatory for minimum viable compatibility evaluation, and which can remain advisory until later phases?
- **Missing decision:** How much premium guidance should be customer-facing versus stylist-facing in early CM releases?
- **Missing decision:** Are there region- or assortment-specific premium styling rules that require separate governance from the global baseline?

## Approval and milestone notes

- This BR is being drafted and pushed under autonomous issue-run rules; it should not block on manual "mark as ready" steps.
- Human review remains advisable before downstream implementation work for premium styling or sensitive CM guidance, but that review is a governance note rather than a stop condition for this BR run.
- The next stage should preserve the RTW-first rollout assumption and break out later CM sophistication so feature planning does not over-commit early phases.
