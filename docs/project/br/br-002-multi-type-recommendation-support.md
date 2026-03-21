# BR-002: Multi-type recommendation support

## Metadata

- **Board Item ID:** BR-002
- **Issue:** #101
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent Item:** none
- **Approval Mode:** AUTO_APPROVE_ALLOWED
- **Source Artifacts:** `docs/project/business-requirements.md`, `docs/project/product-overview.md`, `docs/project/goals.md`, `docs/project/vision.md`, `docs/project/roadmap.md`
- **Output Artifact:** `docs/project/br/br-002-multi-type-recommendation-support.md`
- **Promotes To:** `boards/features.md` rows to be created in the feature-spec stage

## 1. Purpose

Define the business requirements for supporting multiple recommendation types within the AI Outfit Intelligence Platform so downstream feature specifications and API contracts can describe recommendation behavior consistently across ecommerce, marketing, and clienteling surfaces.

This BR establishes:
- a canonical taxonomy for recommendation types
- the business boundaries for where each type should and should not be used
- shared expectations for surfaces and channels
- a phased rollout order that aligns with the roadmap and platform maturity

This BR does not define implementation details such as ranking algorithms, schema fields, or UI layouts. It defines the business-level contract that later feature, architecture, and API work must preserve.

## 2. Scope and business outcome

The platform must support recommendation outputs beyond a single "related products" pattern. It must distinguish between recommendation types because each type serves a different customer need, surface context, and commercial goal.

The desired business outcomes are:
- improve complete-look usefulness by matching recommendation type to shopper intent
- increase attachment, basket size, and premium conversion without weakening style coherence
- enable channels to request recommendation sets with clear business semantics rather than channel-specific ad hoc logic
- let merchandising, analytics, and downstream delivery teams reason about recommendation behavior using a shared vocabulary
- provide a rollout path that starts with high-confidence recommendation types and expands as data, context, and governance mature

## 3. In scope

- recommendation types: outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal
- business definitions and expected outcomes for each recommendation type
- usage boundaries by surface and channel
- distinctions between RTW and CM where they affect recommendation-type behavior
- dependencies on customer, context, product, inventory, and governance foundations
- rollout order for recommendation types across phases
- downstream implications for feature breakdown and API contract design

## 4. Out of scope

- ranking model design or algorithm selection
- detailed request or response schema design
- UI layout, placement design, or copywriting per surface
- experiment setup details
- low-level identity resolution or event-pipeline implementation
- merchandising authoring workflow design beyond the boundaries needed here

## 5. Users and stakeholders

### Primary user groups

- **Online shoppers:** need recommendation sets that help complete looks, compare higher-value options, and discover relevant complementary products.
- **Returning customers:** need recommendations that adapt to prior behavior, purchase history, and current context.
- **Occasion-led shoppers:** need recommendation sets that prioritize event or use-case fit over simple item similarity.

### Internal user groups

- **Merchandisers:** need explicit recommendation-type boundaries so curation, rules, and overrides remain intentional.
- **Stylists and clienteling teams:** need reusable recommendation types that fit assisted-selling conversations.
- **Marketing teams:** need recommendation outputs that can be activated in email and lifecycle messaging without redefining business meaning for each campaign.
- **Product, analytics, and platform teams:** need taxonomy and rollout clarity to define features, contracts, metrics, and dependencies consistently.

## 6. Recommendation-type taxonomy

### 6.1 Canonical taxonomy overview

The platform must treat the following recommendation types as distinct business concepts.

| Recommendation type | Primary shopper need | Primary business value | Typical starting point | Main decision lens |
|---|---|---|---|---|
| Outfit | Build a coherent complete look | Increase attachment and complete-look conversion | Anchor product, occasion, or look intent | Style compatibility and look completeness |
| Cross-sell | Add complementary items | Increase basket size and cross-category attachment | Anchor product or cart contents | Complementarity and missing look components |
| Upsell | Trade up to a better or higher-value option | Increase AOV and premium mix | Anchor product or chosen item | Premium fit, compatibility, and price ladder |
| Style bundle | Explore curated grouped combinations | Increase discovery, inspiration, and reuse of proven looks | Curated look, campaign, or reusable bundle | Cohesion, reuse, and campaign intent |
| Occasion-based | Solve for a specific event or use case | Increase relevance for intent-led journeys | Occasion, event, season, or explicit mission | Occasion fit and dress-code relevance |
| Contextual | Adapt recommendations to present circumstances | Improve situational relevance and conversion | Location, weather, season, inventory, session state | Real-time or near-real-time context fit |
| Personal | Adapt to the customer's profile and history | Improve repeat engagement, conversion, and lifetime value | Known customer identity and profile | Preference, history, and customer affinity |

### 6.2 Business definition and boundaries by type

#### Outfit recommendations

Outfit recommendations assemble a complete-look concept around an anchor product, occasion, or styling intent. They should emphasize compatibility across categories and help the customer understand how to complete the look.

Required boundaries:
- must prioritize stylistic coherence over raw popularity
- may include multiple categories in one set
- must remain valid for RTW and, when applicable, CM-compatible combinations
- should not be reduced to "customers also bought" behavior

#### Cross-sell recommendations

Cross-sell recommendations propose complementary items that increase category attachment around a current product or cart state.

Required boundaries:
- must complement the current anchor item or selected set
- should focus on missing or strengthening components of a look
- must not introduce incompatible or distracting alternatives that break the customer's current intent
- should be purchase-oriented rather than purely inspirational

#### Upsell recommendations

Upsell recommendations propose higher-value alternatives or premium additions that remain compatible with the customer's current intent.

Required boundaries:
- must preserve intent and compatibility while increasing value
- may recommend premium alternatives within the same category or premium companion items
- should not behave like broad substitution logic that removes the complete-look frame
- should avoid showing implausible price jumps or incompatible premium options

#### Style bundle recommendations

Style bundle recommendations present curated grouped combinations that can be reused across surfaces and campaigns as proven looks or themed sets.

Required boundaries:
- must preserve the integrity of curated or governed grouped looks
- may be campaign-aware or merchandising-led
- should support inspiration and shortcut selection, not only item-level attachment
- must not imply full bundle purchasability if inventory or availability breaks the bundle

#### Occasion-based recommendations

Occasion-based recommendations optimize around a specific event, dress code, or use case such as wedding, business formal, travel, or seasonal dressing.

Required boundaries:
- must prioritize occasion fit above generic complementarity
- may begin without a specific anchor item
- should translate broad intent into complete looks or key components
- must not ignore region, season, or assortment constraints when they materially affect relevance

#### Contextual recommendations

Contextual recommendations adapt outputs to current situational conditions such as weather, location, season, regional assortment, inventory state, device/session context, or current journey state.

Required boundaries:
- must use context only when it materially improves relevance
- should not be treated as synonymous with personalization
- may shape other recommendation types rather than always appearing as a separate customer-facing label
- must remain explainable to internal operators even when the context is not exposed to customers

#### Personal recommendations

Personal recommendations adapt outputs to the identified customer's profile, behavior, purchase history, and affinities where permitted by consent and regional policy.

Required boundaries:
- require sufficient identity confidence and permitted data usage
- must remain safe for privacy and customer-facing explanation limits
- should complement current intent instead of overriding it blindly
- may modify ranking or selection within other recommendation types, but the business meaning of the recommendation set must remain clear

## 7. Shared usage rules across recommendation types

The platform must apply the following business rules across all recommendation types:

- every recommendation set must have a clear primary type, even if multiple signals influence assembly or ranking
- surfaces may combine types, but the business purpose of each set must remain distinct
- recommendation types must be stable enough to support analytics, experimentation, and merchandising governance
- recommendation types must be requestable or identifiable in downstream API contracts
- every type must respect product compatibility, assortment eligibility, inventory constraints, and regional or consent boundaries
- RTW and CM may share taxonomy labels, but downstream features must preserve workflow-specific compatibility logic where the journeys differ

## 8. Surface and channel expectations

### 8.1 Surface-by-type guidance

| Surface or channel | Expected primary types | Secondary or optional types | Notable boundaries |
|---|---|---|---|
| PDP | Outfit, cross-sell, upsell | Contextual, personal | Must stay anchored to the viewed product and avoid overwhelming the product decision |
| Cart | Cross-sell, upsell, outfit | Contextual, personal | Must prioritize checkout-adjacent relevance and purchasable add-ons |
| Homepage / web personalization | Personal, occasion-based, contextual | Style bundle, outfit | May start without an anchor product; should emphasize discovery and returning-customer relevance |
| Style inspiration / look-builder | Outfit, style bundle, occasion-based | Contextual, personal | Should preserve complete-look framing rather than degrade to generic item carousels |
| Email campaigns | Personal, style bundle, occasion-based | Outfit, contextual | Must support reusable set definitions and campaign-safe governance |
| In-store clienteling | Outfit, personal, occasion-based | Upsell, style bundle, contextual | Must support conversation-led styling and assisted selling rather than self-serve browsing patterns |
| Future API consumers / mobile | Any type supported by contract | Any type supported by contract | Must use the canonical taxonomy rather than inventing channel-specific aliases |

### 8.2 Channel-specific business boundaries

- **Ecommerce surfaces** should prioritize product-linked recommendation types first because they are closest to purchase intent.
- **Marketing surfaces** should favor reusable, campaign-safe types such as personal, style bundle, and occasion-based recommendations.
- **Clienteling surfaces** should support assisted-selling use cases where personal and occasion context carry more weight.
- **API-first consumers** must receive stable recommendation-type semantics so channels do not independently redefine outfit, cross-sell, or personal logic.

## 9. Type interaction model

Recommendation types may interact, but they must not collapse into an undefined mixed set.

Required interaction model:
- outfit may contain cross-sell and upsell opportunities within the broader complete-look frame
- contextual and personal signals may shape ranking inside outfit, cross-sell, occasion-based, or style bundle recommendations
- occasion-based flows may produce outfit or style bundle outputs, but the initiating business intent remains occasion-led
- surfaces must avoid presenting multiple sets that compete with each other using nearly identical business meaning

Implication for downstream work:
- feature specs and API contracts must distinguish the **primary recommendation type** from **supporting influences** such as personalization or context

## 10. Usage boundaries and exclusions

The following boundaries are required for downstream design:

- do not treat all recommendations as one interchangeable "related products" response
- do not use personal recommendations where consent, identity confidence, or regional policy is insufficient
- do not use contextual adjustments when the available context is too weak, stale, or noisy to improve outcomes
- do not present upsell logic that undermines trust by appearing incompatible or purely margin-driven
- do not present style bundles as guaranteed buyable bundles when inventory, sizing, or CM state makes the bundle partially invalid
- do not let occasion-based flows ignore anchor-product compatibility once the customer has moved into a specific look or product path
- do not expose internal reasoning or sensitive profile detail in customer-facing explanations

## 11. RTW and CM considerations

The taxonomy applies to both RTW and CM, but downstream features must preserve the following business distinctions:

- RTW supports the earliest rollout for outfit, cross-sell, and upsell because compatibility and purchase flow are simpler
- CM requires stronger compatibility checks for fabrics, details, palettes, premium options, and appointment-led selling
- personal and contextual types may be valuable in CM, but only after configuration state and premium-governance needs are represented clearly
- style bundles and occasion-based recommendations may bridge RTW and CM, but downstream features must specify where mixed-assortment outputs are allowed

## 12. Rollout order

### 12.1 Recommended rollout sequence

#### Phase 1: Foundation and first recommendation loop

Prioritize:
- outfit
- cross-sell
- upsell

Why first:
- these types map directly to PDP and cart journeys already prioritized in the roadmap
- they offer the clearest early commercial signal
- they can be supported with curated looks, compatibility rules, product attributes, and baseline telemetry before richer identity and context maturity

#### Phase 2: Personalization and context enrichment

Expand to:
- occasion-based
- contextual
- personal

Why next:
- these types depend on stronger context interpretation, identity confidence, customer signal ingestion, and governance for permitted data use
- they improve relevance once a measurable baseline exists from Phase 1

#### Phase 3: Merchandising control and multi-channel activation

Broaden operational use of:
- style bundle
- personal
- occasion-based
- contextual

Why here:
- style bundles become more valuable when reusable across campaigns, email, and clienteling workflows
- internal teams need stable contracts, controls, and reporting before broad multi-channel activation

#### Phase 4 and later: CM and advanced outfit intelligence

Deepen:
- CM-aware outfit
- CM-aware upsell
- clienteling-oriented personal and occasion-based recommendations

Why later:
- these rely on explicit CM configuration state, premium compatibility rules, and stronger assisted-selling governance

### 12.2 Rollout gating conditions

Recommendation types should expand only when the following conditions are satisfied:

- product and inventory data are reliable enough to keep outputs coherent and purchasable
- recommendation telemetry can measure type-specific performance
- merchandising controls and override paths exist for the types being launched
- identity and consent handling are sufficient for personal recommendations
- contextual data quality is strong enough to improve outcomes without introducing noise
- API contracts can identify recommendation type and preserve traceability for downstream consumers

## 13. Requirements for downstream feature specs and API contracts

This BR establishes the following non-negotiable downstream requirements:

1. **Taxonomy support:** downstream artifacts must use the canonical recommendation-type names from this BR.
2. **Primary type clarity:** each recommendation set must declare or imply a single primary business type.
3. **Influence separation:** personal and contextual influences must be separable from the primary type in contracts and telemetry.
4. **Surface-aware boundaries:** feature specs must document which types are enabled per surface and why.
5. **Governance readiness:** each supported type must identify where curated, rule-based, or AI-ranked sources can influence output.
6. **Traceability:** analytics and operations must be able to evaluate performance and provenance by recommendation type.
7. **Rollout alignment:** early feature work must not depend on later-phase recommendation types unless explicitly called out as future scope.

## 14. Success measures

The business should consider this capability successful when:

- the platform can distinguish and describe recommendation sets by type across surfaces without ambiguity
- teams can define downstream feature work and contracts without re-debating basic taxonomy
- primary surfaces can use high-confidence recommendation types matched to their shopper context
- later-phase personalization and context work has explicit boundaries instead of being bolted onto generic recommendation flows
- analytics can compare performance by recommendation type and surface

## 15. Risks and non-blocking notes

- The boundary between outfit and style bundle must stay explicit in later feature work so curated grouped looks do not become interchangeable with dynamically assembled outfits.
- Personal and contextual recommendation labels may not always be customer-facing; downstream design should distinguish internal semantics from customer presentation.
- Some surfaces may consume the same underlying set through different presentation patterns, but the recommendation type should remain stable for analytics and governance.
- CM-specific recommendation-type expansion should remain a later-stage follow-up unless configuration-state representation is available.

## 16. Open decisions for later stages

- Which recommendation types must be directly requestable by API clients versus inferred server-side from surface context?
- Should surfaces receive one mixed response containing multiple typed sets or multiple separately requested sets?
- Which recommendation types need distinct merchandising override workflows versus shared controls?
- How should anonymous-session personalization be classified when identity confidence is partial?
- Which occasion taxonomy should be canonical across regions and campaigns?

## 17. Exit criteria check

This BR is complete when it provides:
- a recommendation-type taxonomy for outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendations
- usage boundaries by surface and channel
- a rollout order aligned to roadmap phases
- guidance sufficient for downstream feature specs and API contracts to proceed without redefining recommendation semantics
