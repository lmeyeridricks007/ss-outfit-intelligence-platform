# Business requirements: BR-004 RTW and CM support

## 1. Metadata and traceability

- **Board Item ID:** BR-004
- **Issue:** #78
- **Title:** RTW and CM support
- **Trigger:** issue-created automation
- **Parent Item:** none
- **Stage:** workflow:br
- **Phase Context:** Phase 4 roadmap input with dependencies on earlier RTW, telemetry, and governance foundations
- **Primary inputs:** `docs/project/business-requirements.md`, `docs/project/personas.md`, `docs/project/product-overview.md`, `docs/project/roadmap.md`
- **Next stage:** `boards/features.md`
- **Approval mode:** HUMAN_REQUIRED

## 2. Problem statement

The AI Outfit Intelligence Platform must support both Ready-to-Wear (RTW) and Custom Made (CM) recommendation journeys without flattening the important differences between them. RTW customers usually need immediate, purchasable outfit recommendations around stocked products and quick decision-making. CM customers are in a higher-consideration journey where recommendation quality depends on in-progress garment configuration, fabric and detail compatibility, premium styling credibility, and often stylist-assisted interactions.

Without explicit RTW and CM business requirements, downstream feature and architecture work will either overfit to the faster RTW journey or overgeneralize CM as a standard product recommendation problem. That would create poor customer guidance, weak premium styling trust, avoidable merchandising risk, and governance gaps around compatibility logic and stylist-assisted experiences.

This requirement defines the scope boundaries, differentiated outcomes, governance expectations, and phased rollout assumptions needed so the platform can deliver complete-look recommendations that are commercially useful, brand-safe, and operationally governable across both RTW and CM.

## 3. Recommendation and channel mapping

### Recommendation types in scope

- outfit
- cross-sell
- upsell
- occasion-based
- contextual
- personal
- style bundle

### Consuming surfaces in scope

- PDP
- cart
- homepage and web personalization
- style inspiration or look-builder experiences
- email activation
- in-store clienteling and appointment workflows

### Recommendation sources in scope

- curated looks
- rule-based compatibility logic
- AI-ranked recommendation sets

## 4. Target users

### Primary customer personas

- **Occasion-led online shopper:** needs immediate, coherent outfits around an event, anchor item, or seasonal need.
- **Style-aware returning customer:** expects recommendations to reflect prior purchases, preferences, and channel history.
- **Custom Made customer:** needs configuration-aware guidance that respects fabric, color palette, fit intent, premium options, and in-progress garment decisions.

### Internal and operational personas

- **In-store stylist or clienteling associate:** needs credible starting-point looks that can be adapted during live interactions.
- **Merchandiser or look curator:** needs control over compatibility logic, curated looks, premium eligibility, and overrides.
- **Marketing and CRM manager:** needs reusable recommendation outputs that can activate complete looks beyond ecommerce.
- **Product, analytics, and optimization lead:** needs measurable and auditable recommendation behavior across RTW and CM tracks.

## 5. Business value

Supporting RTW and CM as distinct but connected recommendation modes must create business value in four ways:

1. **Protect conversion and attachment in RTW journeys** by helping customers assemble purchasable outfits quickly from available inventory.
2. **Increase CM confidence and premium conversion** by ensuring that recommendations remain credible as customers explore fabrics, details, and premium options.
3. **Preserve brand styling integrity** by making compatibility, premium styling, and merchandising control explicit rather than relying on opaque ranking alone.
4. **Enable cross-channel consistency** so digital, marketing, and clienteling teams can operate from the same governed recommendation foundation while still respecting RTW and CM journey differences.

## 6. RTW versus CM journey differences

| Dimension | RTW journey | CM journey | Business requirement implication |
|-----------|-------------|------------|----------------------------------|
| Shopping mode | Immediate or near-immediate product purchase | Iterative configuration and higher-consideration purchase | The platform must support different recommendation latency, explanation, and decision-state needs. |
| Anchor object | Stocked product or occasion | Configured garment state plus occasion or stylist intent | CM recommendations must use configuration state as an input, not just category similarity. |
| Compatibility basis | Product attributes, availability, season, occasion, price tier | Fabric, color family, lapel or detail choices, premium options, occasion, and stylist rules | CM requires additional compatibility models beyond standard RTW rules. |
| Customer tolerance for error | Moderate; poor recommendations reduce convenience | Low; poor recommendations undermine trust and premium credibility quickly | CM recommendations need tighter governance and more conservative eligibility. |
| Channel pattern | Ecommerce-first with broader digital surfaces | Digital plus stylist-assisted and appointment-led workflows | Clienteling and appointment support are more critical for CM than for RTW. |
| Recommendation explanation need | Helpful but often lightweight | Higher need for rationale, premium credibility, and coherence as choices evolve | Internal explanation and traceability must be stronger for CM-sensitive logic. |
| Fulfillment expectation | Immediate purchasability and inventory awareness | Configuration completion, appointment flow, or later production | RTW must prioritize in-stock purchasability; CM must prioritize coherent configuration guidance. |

## 7. Scope boundaries

### 7.1 In scope

- Define separate business requirements for RTW and CM recommendation journeys while preserving one shared recommendation platform.
- Support RTW complete-look, cross-sell, and upsell recommendations around stocked anchor products.
- Support CM-aware recommendations that react to configured garment state, including fabric, palette, style details, and premium options.
- Define compatibility constraints that prevent invalid or brand-inappropriate RTW and CM pairings.
- Define premium styling expectations so upsell and premium combinations remain credible and not merely higher priced.
- Support recommendation use across ecommerce, marketing, and clienteling surfaces where RTW and CM outputs are consumed differently.
- Define governance requirements for curated looks, compatibility rules, premium logic, overrides, approvals, and auditability.
- Define phased rollout assumptions so RTW and CM scope is sequenced according to the roadmap rather than released as one undifferentiated capability.
- Establish explicit differentiated outcomes for customer-facing and internal personas.

### 7.2 Out of scope

- Technical architecture for compatibility engines, APIs, model design, or interface implementation.
- Detailed UI requirements for configurators, clienteling apps, or recommendation modules.
- Production workflow redesign for tailoring operations outside recommendation decisioning.
- Full CM order management, pricing logic, manufacturing workflow, or appointment scheduling ownership.
- Replacing stylist judgment with automation; human assistance remains an intended part of CM and premium journeys.
- Broad rollout of every surface at launch; sequencing remains phased.

## 8. Differentiated user outcomes

### 8.1 RTW user outcomes

The platform must enable RTW customers to:

- start from a stocked anchor item and quickly reach a coherent outfit
- see complementary products that are immediately purchasable and relevant to occasion or context
- receive premium or upsell suggestions only when they remain compatible and brand-aligned
- experience recommendations consistently across PDP, cart, and broader personalization surfaces

### 8.2 CM user outcomes

The platform must enable CM customers to:

- receive recommendations that respect the current garment configuration and do not ignore in-progress choices
- understand premium combinations and complementary products that reinforce the configured garment rather than conflict with it
- continue the journey across digital and stylist-assisted touchpoints without losing coherence
- maintain trust that recommendations reflect tailoring logic and premium styling standards rather than generic cross-sell behavior

### 8.3 Internal user outcomes

The platform must enable internal teams to:

- author, review, and override RTW and CM compatibility logic separately where needed
- identify which curated looks, rules, and ranking inputs shaped a recommendation set
- govern premium styling logic with tighter review and change control than routine RTW attachment logic
- measure whether RTW and CM strategies perform differently by channel, region, and recommendation type

## 9. Compatibility and premium styling requirements

### 9.1 RTW compatibility requirements

The platform must:

- prioritize in-stock and operationally purchasable combinations
- use product attributes, seasonality, occasion, color, pattern, and fit compatibility to assemble looks
- avoid incompatible price or styling jumps that feel arbitrary to customers
- support curated looks and merchandising overrides where brand direction needs to supersede ranking behavior

### 9.2 CM compatibility requirements

The platform must:

- use garment configuration state as a first-class input
- account for fabric, palette, detail, and premium option interactions when deciding recommendation eligibility
- avoid suggesting complements or premium additions that conflict with the current configured garment
- support configuration-change awareness so recommendation sets remain coherent as customer choices change
- preserve a stricter eligibility threshold for premium styling suggestions than for generic RTW attachment logic

### 9.3 Premium styling requirements

The platform must:

- treat premium recommendations as credibility-sensitive, not only margin-sensitive
- distinguish between valid premium upsell, premium complement, and premium style bundle scenarios
- allow merchandising and styling teams to restrict or approve sensitive premium pairings, especially in CM
- preserve explanation and traceability for why a premium suggestion appeared, including rule, curated-look, or ranking context

## 10. Governance needs

The platform must support the following governance model:

### 10.1 Merchandising and styling governance

- Separate governance of RTW and CM compatibility knowledge where rules materially differ.
- Explicit curation and override controls for look composition, premium eligibility, and campaign priorities.
- Human-in-the-loop review for sensitive CM and premium styling logic, consistent with the roadmap dependency for Phase 4.

### 10.2 Operational governance

- Recommendation changes must be observable, reviewable, and reversible.
- Internal users must be able to identify whether a recommendation came from curated, rule-based, or AI-ranked logic.
- Governance must preserve channel-specific suitability so a recommendation valid for clienteling is not assumed valid for every digital surface.

### 10.3 Data and policy governance

- Customer data use must respect regional privacy and consent requirements.
- The platform must not expose sensitive profile reasoning or internal styling logic in customer-facing explanations.
- Identity and telemetry must remain traceable so RTW and CM outcomes can be analyzed separately without losing shared-platform accountability.

## 11. Success metrics

### Commercial metrics

- RTW attachment rate uplift on supported anchor-product surfaces
- RTW conversion and AOV uplift for recommendation-influenced sessions
- CM premium attachment and conversion influence where recommendation exposure is present
- Incremental engagement or conversion in stylist-assisted journeys influenced by CM-aware recommendations

### Customer and product metrics

- recommendation click-through rate by RTW versus CM journey
- add-to-cart or configuration-progress rate from recommendation interactions
- complete-look engagement rate by recommendation type and surface
- recommendation coverage for RTW anchor flows and CM configuration states
- recommendation invalidation rate after CM configuration changes

### Governance and operational metrics

- percentage of recommendation sets with full traceability to curated looks, rules, and ranking context
- override rate and override reasons by RTW versus CM track
- approval coverage for premium styling rules and sensitive CM logic
- recommendation freshness and latency for journey-critical surfaces

## 12. Phased rollout assumptions

The rollout must follow the roadmap principle that RTW and CM are related but distinct tracks.

### Phase 1 assumption

- RTW anchor-product flows on high-signal surfaces such as PDP and cart form the first recommendation loop.
- CM-specific logic is not expected to be fully delivered in this phase.

### Phase 2 assumption

- Personalization and contextual enrichment improve RTW quality first and establish capabilities that later benefit CM.
- Identity, telemetry, and context foundations must be mature enough before more advanced CM guidance is attempted.

### Phase 3 assumption

- Governance, curated look operations, campaign controls, and multi-channel delivery mature before deep CM rollout.
- Internal workflow readiness for merchandisers, CRM, and stylists is a dependency for later CM quality.

### Phase 4 assumption

- CM-aware retrieval, ranking, premium logic, and stylist-assisted workflows become first-class scope.
- Human-in-the-loop review remains necessary for sensitive premium styling and compatibility logic.
- CM expansion should deepen clienteling and appointment support where live assistance materially improves outcome quality.

### Phase 5 assumption

- Broader expansion happens only after RTW and CM recommendation quality is coherent, measurable, and governable.
- Full CM sophistication is later than foundational RTW validation and should not be forced into earlier phases.

## 13. Missing decisions

- **Missing decision:** Which digital surfaces are mandatory for the first CM-aware release beyond clienteling support.
- **Missing decision:** What level of customer-facing explanation is appropriate for CM and premium recommendations versus internal-only reasoning.
- **Missing decision:** Which source system defines the canonical CM configuration state for recommendation eligibility.
- **Missing decision:** What review and sign-off policy applies to premium styling rule changes by region.
- **Missing decision:** Which regions or assortments require localized compatibility logic for RTW versus CM.

## 14. Approval and milestone-gate notes

- **Approval mode:** HUMAN_REQUIRED, because no board evidence exists for AUTO_APPROVE_ALLOWED.
- **Milestone-gate note:** Human-in-the-loop review for sensitive premium styling logic remains a governance note from the roadmap and should be carried into downstream feature and architecture work.
- **Automation note:** Trigger source is issue-created automation, but this run is autonomous and must complete branch updates without waiting for a PR workflow.

## 15. Recommended board update

Update `boards/business-requirements.md` for `BR-004` to `DONE` once the branch push includes:

- `docs/project/br/br-004-rtw-and-cm-support.md`
- the linked source docs under `docs/project/`
- non-blocking notes for approval mode and CM premium-governance follow-ups

## 16. Exit criteria coverage

This artifact satisfies the stated stop condition by defining:

- **RTW and CM scope boundaries** in Sections 6 and 7
- **differentiated user outcomes** in Section 8
- **governance needs** in Sections 9 and 10
- **phased rollout assumptions** in Section 12
