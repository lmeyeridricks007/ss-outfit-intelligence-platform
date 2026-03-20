# Business requirements: BR-001 Complete-look recommendation capability

## Metadata

- **Board Item ID:** BR-001
- **Parent Item:** None
- **Stage:** workflow:br
- **Trigger:** GitHub issue #50 via issue-intake automation
- **Source artifacts:** `docs/project/business-requirements.md` (BR-1), `docs/project/product-overview.md`, `docs/project/problem-statement.md`, `docs/project/vision.md`, `docs/project/personas.md`, `docs/project/roadmap.md`
- **Downstream stage:** `boards/features.md` (`FEAT-001`, to be created during feature breakdown)

## Problem statement

SuitSupply customers often start with an anchor product or an occasion in mind, but they still need help building the rest of the outfit. Existing recommendation patterns based on similarity, popularity, or frequently-bought-together logic do not consistently solve the styling problem because they do not reliably account for product compatibility, occasion, season, customer profile, or merchandising intent. SuitSupply needs a shared recommendation capability that can turn styling expertise into governed complete-look outcomes across ecommerce and later channels, while remaining commercially measurable and controllable.

## Business outcomes

This capability must deliver the following outcomes:

- Help customers complete a coherent outfit faster and with more confidence.
- Increase cross-category attachment and average order value by recommending compatible complementary items.
- Improve conversion on high-intent journeys where styling friction currently slows purchase decisions.
- Give merchandisers and stylists a governed way to shape recommendation behavior without losing AI-assisted optimization.
- Establish the canonical complete-look recommendation foundation that later phases can reuse across additional surfaces and channels.

## Target users

### Primary users

- **Occasion-led online shoppers** who need a complete outfit for a near-term event or use case.
- **Anchor-product shoppers** who land on a suit, jacket, shirt, or other core garment and need guidance for the rest of the look.
- **Style-aware returning customers** who expect recommendations to reflect prior purchases, browsing, and known preferences when available.

### Secondary users

- **Merchandisers and look curators** who need recommendations to align with brand styling rules, curated looks, and campaigns.
- **Product, analytics, and optimization leads** who need measurable recommendation performance and experimentation hooks.
- **In-store stylists and clienteling associates** who will consume the capability in later phases after digital validation.
- **Marketing and CRM teams** who will activate recommendation outputs in later phases after the first digital surfaces are proven.

## Recommendation and surface mapping

### Recommendation types in scope for this BR

- **Outfit recommendations:** complete outfits built around an anchor product, customer intent, or occasion.
- **Cross-sell recommendations:** complementary items that help finish the outfit across categories.
- **Upsell recommendations:** premium or higher-value compatible alternatives.
- **Occasion-based recommendations:** phased in after the first anchor-product surfaces are validated.
- **Contextual recommendations:** phased in after the first surface telemetry and governance loop are established.
- **Personal recommendations:** phased in after stronger customer-signal and identity foundations are in place.

### Surface and channel mapping

- **Phase 1 in-scope surfaces:** PDP and cart on ecommerce, focused on high-signal RTW journeys.
- **Phase 2 candidate surfaces:** homepage or web personalization surfaces and broader occasion-led discovery experiences.
- **Phase 3 candidate channels:** email and in-store clienteling once recommendation contracts, governance, and telemetry are stable.
- **Future surfaces:** additional API-driven or mobile experiences after the shared capability is proven.

### Recommendation source model

The business requirement assumes a blended recommendation model:

- **Curated** looks and merchandising inputs define style intent and brand-safe combinations.
- **Rule-based** logic enforces compatibility, eligibility, and governance constraints.
- **AI-ranked** logic orders and personalizes eligible candidates once the core governance loop is reliable.

## Scope boundaries

### In scope

- Define the complete-look recommendation capability as a shared business requirement rather than a single widget.
- Support outfit assembly around an anchor product, a customer need, or a defined occasion.
- Start with **Phase 1 RTW PDP and cart journeys** because they offer high purchase intent and fast commercial signal.
- Cover the recommendation outcomes needed on those initial surfaces:
  - show a coherent outfit anchored on the active product or cart context
  - suggest complementary items from adjacent categories
  - surface premium compatible options where relevant
- Include the business need for merchandising controls, compatibility governance, telemetry, and experimentation so downstream work does not treat them as optional.
- Preserve traceability from recommendation set to outcome so teams can measure influence and iterate safely.
- Define downstream phase boundaries so later work can expand to occasion-led discovery, personalization, email, clienteling, and CM without reopening the core business goal.

### Out of scope for Phase 1 delivery

- Broad multi-channel rollout before PDP and cart prove recommendation quality and measurable lift.
- Deep CM configuration-aware recommendation logic in the first release.
- Full homepage, email, clienteling, or mobile activation in the first release.
- Replacing commerce, POS, OMS, ESP, or analytics systems.
- Detailed architecture, API contracts, data pipelines, or implementation-level decisions.

## User journeys and required outcomes

### 1. Anchor-product PDP journey

When a customer lands on an RTW anchor product, the capability must present a believable complete outfit that helps answer "what goes with this?" The expected outcome is that customers can discover and add complementary products with minimal styling friction.

### 2. Cart completion journey

When a customer has one or more anchor items in cart, the capability must recommend missing outfit components or premium compatible additions that improve basket completeness without feeling random or repetitive. The expected outcome is higher attachment and basket value on an already high-intent journey.

### 3. Occasion-led discovery extension

After the initial anchor-product journeys are validated, the capability must support occasion-led discovery flows where the outfit starts from intent rather than a single anchor SKU. The expected outcome is better style discovery and broader relevance for shoppers who start from use case instead of product detail.

## RTW and CM considerations

- **Phase 1 focus:** RTW only for initial PDP and cart validation.
- **CM treatment in this BR:** CM remains part of the long-term capability definition, but CM-specific recommendation behavior is deferred beyond the first rollout because it requires configuration-aware compatibility logic, more human review, and deeper workflow support.
- **Business implication:** Downstream feature and architecture work must preserve a path for CM expansion without forcing Phase 1 to solve CM-specific complexity.

## Success metrics

### Commercial metrics

- Conversion uplift on PDP and cart sessions that receive complete-look recommendations.
- Average order value uplift for recommendation-influenced sessions.
- Cross-category attachment rate from anchor-product and cart journeys.

### Product metrics

- Recommendation click-through rate by surface and recommendation type.
- Add-to-cart rate from recommendation interactions.
- Purchase rate for sessions with recommendation engagement.
- Complete-look engagement rate, including interaction with outfit groupings rather than single items only.
- Recommendation coverage for prioritized RTW categories on PDP and cart.

### Operational and governance metrics

- Recommendation set traceability rate, including recommendation set ID and decision context.
- Freshness of product, inventory, and merchandising inputs on the initial surfaces.
- Override and governance adoption by merchandising teams for launch categories.
- Surface-level latency and availability that are acceptable for PDP and cart experiences.

## Phase boundaries

### Phase 1: Foundation and first recommendation loop

- Focus on **RTW PDP and cart**.
- Prioritize **outfit**, **cross-sell**, and **upsell** recommendation types.
- Use curated looks and compatibility rules as the reliability baseline, with AI ranking introduced only within governed constraints.
- Success means the capability produces coherent, purchasable outfits and measurable business signal on those first surfaces.

### Phase 2: Context and personalization expansion

- Extend to occasion-led discovery and broader web personalization surfaces.
- Add richer customer-signal usage, context awareness, and stronger personalization once Phase 1 telemetry is stable.

### Phase 3: Multi-channel activation

- Reuse the capability for email and clienteling after contracts, governance, and observability are proven on ecommerce surfaces.

### Phase 4 and beyond: CM and advanced outfit intelligence

- Expand into CM-specific configuration-aware recommendation logic and more complex assisted journeys after the foundational digital loop is trustworthy.

## Constraints and guardrails

- Recommendations must preserve brand styling integrity and not collapse into simple item similarity.
- Privacy, consent, and regional data-use constraints must be respected before personalization expands.
- Hard compatibility and eligibility rules take precedence over optimization or commercial pressure.
- Surfaces must degrade gracefully when personalization or contextual data is limited.
- Governance and measurement are part of the business requirement, not optional later enhancements.

## Assumptions

- SuitSupply has enough merchandising knowledge and product attributes to define initial compatible outfits for high-signal RTW categories.
- PDP and cart are the fastest surfaces for validating commercial value and recommendation quality.
- A phased rollout is preferred over broad launch because recommendation quality and governance need proof before expansion.
- Recommendation delivery will remain API-first even though this BR stays at the business requirement level.

## Open decisions

- **Missing decision:** Which RTW categories must be in the first launch cohort beyond the general anchor-product focus on suits and jackets.
- **Missing decision:** Whether Phase 1 should include any lightweight occasion-led entry points on ecommerce, or remain strictly PDP and cart.
- **Missing decision:** What baseline and target thresholds will be used for conversion, AOV, and attachment success metrics.
- **Missing decision:** What level of customer-facing explanation, if any, should appear on early recommendation surfaces versus internal-only traceability.

## Approval and milestone notes

- This artifact was produced by an autonomous issue-intake run and is intended to unblock downstream feature breakdown work without waiting for a manual "mark ready" step.
- Board tracking for this milestone should remain non-blocking (`In PR` after push) while preserving open decisions as notes rather than blockers.
- Downstream feature work should keep **Phase 1 RTW PDP and cart** scope fixed before expanding into additional surfaces or CM complexity.

## Recommended board update

Update `boards/business-requirements.md` for `BR-001` with:

- **Status:** `In PR`
- **Approval Mode:** `autonomous`
- **Trigger Source:** `docs/project/business-requirements.md (BR-1), docs/project/product-overview.md, docs/project/problem-statement.md`
- **Output:** `docs/project/br/br-001-complete-look-recommendation-capability.md`
- **Notes:** `Issue #50; Phase 1 focus on RTW PDP and cart; open decisions are non-blocking and documented in the BR artifact.`
