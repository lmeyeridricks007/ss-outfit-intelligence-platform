# BR-002: Multi-type recommendation support

## 1. Metadata

- BR ID: BR-002
- Issue: #109
- Stage: workflow:br
- Approval Mode: AUTO_APPROVE_ALLOWED
- Trigger: issue-created automation for workflow:br
- Parent Item: none
- Downstream stage: workflow:feature-spec
- Promotes to: boards/features.md
- Phase: Phase 1 - Foundation and first recommendation loop
- Upstream Sources:
  - docs/project/business-requirements.md
  - docs/project/product-overview.md
  - docs/project/goals.md
- Downstream Consumers:
  - feature breakdown artifacts for recommendation-type delivery
  - architecture and API contract definition for recommendation responses
  - downstream surface-specific build planning for ecommerce, email, and clienteling

## 2. Purpose

Define the business requirements for supporting multiple recommendation types in a shared recommendation platform so downstream feature, architecture, and API work can distinguish what each type means, where each type is allowed to appear, what data and governance boundaries apply, and what rollout order should be followed.

## 3. Scope summary

The platform must support a recommendation taxonomy that covers outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendation types. These types must be usable across multiple surfaces and channels without collapsing important differences in business goal, user expectation, or operational constraints.

This BR defines:
- the taxonomy and business meaning of each recommendation type
- the boundaries between recommendation types so downstream teams do not overload one type with another type's behavior
- surface and channel usage expectations
- baseline contract expectations that later API work must preserve
- rollout order for Phase 1 and later phases

This BR does not define:
- detailed ranking algorithms or model selection
- UI layouts for each surface
- low-level payload schemas or event schemas
- exact experimentation plans for each channel

## 4. Business problem

SuitSupply needs a recommendation platform that can drive complete-look and context-aware decisions across ecommerce, email, and clienteling surfaces. A single undifferentiated recommendation bucket is not sufficient because each recommendation type has a different business intent:
- outfit recommendations help customers complete a coherent look
- cross-sell recommendations drive category attachment
- upsell recommendations increase value while preserving compatibility
- style bundles package reusable looks or grouped combinations
- occasion-based recommendations align to explicit event or use-case intent
- contextual recommendations adapt to the active environment or session
- personal recommendations use customer profile and behavior to tailor outputs

Without a shared taxonomy, downstream feature teams and API consumers may produce inconsistent labels, conflicting placement rules, poor measurement, or recommendation sets that blur business intent and degrade trust.

## 5. Target users and stakeholders

### Primary user groups
- Digital shoppers on PDP, cart, homepage, and style inspiration surfaces
- Returning customers whose known profile or history may influence recommendations
- Occasion-led shoppers looking for complete looks for weddings, business formal, travel, seasonal needs, or similar events

### Secondary user groups
- Merchandisers who curate looks, define rules, and control recommendation boundaries
- Marketing teams that activate recommendation outputs in email
- In-store stylists and clienteling teams who need reusable recommendation sets
- Product, analytics, and experimentation teams measuring performance by recommendation type

## 6. Recommendation taxonomy

### 6.1 Taxonomy principles

- Recommendation type must describe the primary business intent of the set, not only the retrieval source.
- One recommendation set may include curated, rule-based, and AI-ranked sources, but it must expose a single primary recommendation type for downstream consumption.
- Recommendation type must remain distinct from surface and channel. The same type may appear on multiple surfaces, but with different boundaries and presentation expectations.
- Recommendation type must remain distinct from merchandising source labels such as curated or campaign-driven.

### 6.2 Recommendation type definitions

| Recommendation type | Primary purpose | Primary input context | Typical output shape | Core business value | Key exclusions |
|---|---|---|---|---|---|
| Outfit | Assemble a coherent complete-look recommendation around an anchor item, explicit intent, or starting point | Anchor product, compatibility rules, look composition, current journey context | Multi-item outfit or look-oriented set across categories | Increase complete-look conversion and reduce styling friction | Not a generic premium alternative set; not limited to same-category products |
| Cross-sell | Add compatible complementary items that increase attachment | Anchor item, cart contents, category gaps, compatibility rules | Complementary items or small grouped add-ons | Increase basket size and attachment rate | Should not replace the main outfit assembly flow when a full look is expected |
| Upsell | Present higher-value or more premium compatible alternatives | Current product, price tier, premium assortment, compatibility and availability | Alternative or premium-compatible products, sometimes with add-on premium options | Increase AOV without breaking style or fit expectations | Should not recommend incompatible premium items or masquerade as cross-sell |
| Style bundle | Present reusable grouped combinations or curated looks that can be activated as a unit | Curated looks, merchandising campaigns, reusable look definitions | Named grouped look, bundle, or reusable composition | Reuse styling knowledge across surfaces and campaigns | Should not require full personalization to be valid |
| Occasion-based | Match a use case such as wedding, business formal, travel, or seasonal event | Occasion intent, event context, category priorities, style rules | Occasion-aligned look or product set | Improve discovery for intent-led shopping journeys | Should not trigger solely because a customer is known; requires occasion framing |
| Contextual | Adapt recommendations to immediate environment or journey context | Location, country, season, weather, inventory, device, session state | Context-shaped set that can refine another type or stand alone on eligible surfaces | Improve relevance in the active moment | Must not override hard compatibility or consent boundaries |
| Personal | Tailor outputs using customer profile, history, affinity, and exclusions | Identity, orders, browsing, preferences, profile signals, consent status | Customer-specific recommendation set or ranking overlay | Improve repeat engagement, repeat purchase, and trust | Must degrade gracefully when identity confidence or consent is low |

### 6.3 Type hierarchy and composition rules

- Outfit is the primary complete-look type and anchors Phase 1 delivery.
- Cross-sell and upsell are secondary commercial types that may accompany outfit recommendations on the same surface, but must remain labeled separately in downstream contracts and analytics.
- Style bundle is a reusable packaging type that can supply candidate looks to outfit or occasion-based experiences but still needs explicit labeling when exposed to consumers or downstream tools.
- Occasion-based, contextual, and personal types may operate as standalone recommendation sets on eligible surfaces, or as ranking overlays that refine another primary type. When used as overlays, the downstream contract must preserve both the primary type and applied context modifiers.

## 7. Usage boundaries by type

### 7.1 Outfit

- Use when the user needs a complete-look decision around an anchor product, explicit intent, or configurable garment.
- Must support both RTW and CM journeys, with CM respecting configuration compatibility.
- Must prioritize style coherence and compatibility over pure revenue optimization.

### 7.2 Cross-sell

- Use when the business goal is to add complementary items without redefining the full look.
- Best suited to PDP and cart surfaces where attachment opportunities are immediate.
- Must not introduce contradictory items that compete with the current anchor product.

### 7.3 Upsell

- Use when the business goal is to move a customer toward a more premium or higher-value compatible option.
- Must be constrained by compatibility, assortment eligibility, and brand trust.
- Must not be the dominant recommendation mode on surfaces where complete-look guidance is the primary expectation.

### 7.4 Style bundle

- Use when curated or reusable look groupings should be reactivated consistently across channels.
- Suitable for style inspiration, campaign, and email use cases where a named look or grouped composition is meaningful.
- Must remain traceable to the underlying look or curated source artifact.

### 7.5 Occasion-based

- Use when the customer intent is event-led or use-case-led rather than product-led.
- Suitable for homepage, style inspiration, email, and clienteling surfaces where occasion framing can be explicit.
- Must preserve the distinction between occasion intent and personal preference.

### 7.6 Contextual

- Use when immediate context such as season, weather, location, inventory, or session state changes what is relevant.
- May refine outfit, cross-sell, upsell, style bundle, or occasion-based sets when context materially improves relevance.
- Must not be treated as a substitute for personal recommendations when customer-specific data is unavailable.

### 7.7 Personal

- Use when identity, consent, and signal quality are sufficient to personalize recommendations responsibly.
- May appear on homepage, PDP, cart, email, and clienteling surfaces where profile-aware relevance is valuable.
- Must degrade to non-personalized types or lower-confidence defaults when consent, profile quality, or identity resolution confidence is insufficient.

## 8. Surface and channel expectations

### 8.1 Surface versus channel distinction

- Surface means a specific placement such as PDP, cart, homepage, style inspiration, email module, or clienteling screen.
- Channel means the broader experience family such as ecommerce, email, or clienteling.
- Downstream contracts and docs must identify both the recommendation type and the consuming surface.

### 8.2 Surface-by-type guidance

| Surface | Primary types | Secondary types | Notable boundaries |
|---|---|---|---|
| PDP | Outfit, cross-sell, upsell | Contextual, personal | Outfit should anchor complete-look flows; upsell must stay compatible with the viewed product; personal use is optional based on identity confidence |
| Cart | Cross-sell, upsell, outfit | Contextual, personal | Cart should favor attachment and compatible completion; avoid large inspirational bundles that distract from purchase completion |
| Homepage / web personalization | Occasion-based, personal, style bundle | Contextual, outfit | Homepage may introduce intent-led or profile-led sets even without a single anchor product |
| Style inspiration / look-builder | Outfit, style bundle, occasion-based | Contextual, personal | These surfaces may carry richer grouped looks and exploration flows |
| Email | Style bundle, occasion-based, personal | Outfit, contextual | Email should use recommendation types that survive delayed consumption and campaign context |
| Clienteling | Outfit, occasion-based, personal | Style bundle, cross-sell, upsell, contextual | Clienteling may mix types, but the underlying recommendation intent must remain explicit for stylist trust and follow-up |

### 8.3 Channel expectations

- Ecommerce channels must prioritize low-friction recommendations that are directly actionable and purchasable.
- Email channels must prefer recommendation types that remain understandable outside the original browsing session.
- Clienteling channels must preserve traceability and enough explanation for internal users to trust and adapt outputs.
- Future API-driven channels must not require a new taxonomy; they should consume the same shared type system and metadata.

## 9. Shared contract expectations for downstream API work

Later API and feature specs must preserve these business-level contract expectations:
- Every recommendation set must declare a primary recommendation type.
- Recommendation responses must identify consuming surface and channel context.
- Responses must preserve whether the set is RTW, CM, or mixed-eligibility where that affects downstream behavior.
- Responses must preserve traceability to recommendation set ID and decision trace context.
- Responses must allow indication of applied overlays or modifiers such as contextual refinement or personal ranking.
- Responses must distinguish presentation grouping from recommendation type so a style bundle is not confused with a carousel layout.
- Analytics and experimentation must be able to attribute impressions and outcomes by recommendation type, surface, and channel.

## 10. Governance and operational boundaries

- Merchandising teams must be able to shape or override recommendation behavior by type, especially for outfit, style bundle, and occasion-based sets.
- Hard compatibility, assortment, and inventory constraints must take precedence over ranking optimization for every type.
- Personal recommendations must respect consent, regional data policy, and identity confidence boundaries.
- Contextual recommendations must use approved context inputs only and must not expose sensitive reasoning on customer-facing surfaces.
- Cross-sell and upsell flows must avoid aggressive monetization that breaks styling integrity or customer trust.
- All types must support auditability through stable IDs for looks, rules, campaigns, experiments, and recommendation sets.

## 11. Rollout order

### 11.1 Phase 1 rollout

Phase 1 should establish the foundational recommendation loop with:
1. Outfit recommendations as the primary complete-look capability
2. Cross-sell recommendations for complementary attachment on PDP and cart
3. Upsell recommendations for premium-compatible alternatives where business value is clear

Phase 1 focus areas:
- PDP and cart as the first production surfaces
- RTW-first implementation, while preserving CM compatibility requirements in the taxonomy and contracts
- shared type labeling and analytics hooks from the start so later types do not require contract redesign

### 11.2 Phase 2 expansion

After the Phase 1 loop is stable, expand to:
4. Contextual recommendations that refine relevance using season, weather, location, inventory, and session context
5. Personal recommendations that use identity, profile, and behavioral signals where consent and data quality support them
6. Occasion-based recommendations for explicit intent-led discovery journeys

Phase 2 focus areas:
- richer homepage and discovery experiences
- stronger profile-aware ranking overlays
- clearer distinction between context-driven and profile-driven logic

### 11.3 Phase 3 and later expansion

Later phases should broaden:
7. Style bundle activation as a reusable packaged recommendation type across email, inspiration, campaign, and clienteling use cases
8. Wider channel adoption across email, clienteling, and future API-driven consumers
9. richer multi-type orchestration where surfaces can request multiple recommendation types in a governed way

### 11.4 Rollout sequencing rules

- Do not introduce additional recommendation types on a surface until type-level measurement and traceability are already available for the existing ones.
- Add new types only when governance controls and fallback behavior are defined.
- Preserve backward-compatible type labels so downstream consumers do not need to reinterpret historical telemetry.

## 12. Success measures

The business requirements for multi-type support are met when downstream teams can build on a stable, explicit taxonomy and measure business performance by type.

Key measures:
- recommendation coverage by type across planned Phase 1 surfaces
- click-through, add-to-cart, purchase, and attachment metrics segmented by recommendation type
- AOV and conversion lift attributable to outfit, cross-sell, and upsell in early rollout
- reuse of the same type system across ecommerce, email, and clienteling consumers
- percentage of recommendation events with valid type, surface, and trace metadata

## 13. Assumptions

- Phase 1 can create value before the full recommendation taxonomy is active on every channel.
- The shared delivery API can expose recommendation-type metadata without forcing surface-specific logic into the core contract.
- Merchandising teams can provide enough curated look and compatibility guidance to distinguish outfit, style bundle, and occasion-based behavior.
- Identity resolution and consent handling will be sufficient later to support personal recommendations, but these capabilities are not prerequisites for all Phase 1 types.

## 14. Open questions and non-blocking follow-ups

- Which surfaces need multi-type response support in the first API contract versus single-type requests with shared metadata?
- Should style bundles be exposed as a first-class customer-facing type in all channels, or mainly as a reusable internal and campaign packaging construct?
- What minimum identity confidence threshold should gate personal recommendation activation on each surface?
- How should CM-specific upsell and outfit logic be labeled when configuration changes create hybrid recommendation sets?
- Which regional or legal constraints limit personal and contextual recommendation activation in email or clienteling workflows?

## 15. Review pass

Trigger: issue-created automation

Artifact under review: docs/project/br/br-002-multi-type-recommendation-support.md

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
- No milestone human gate is identified for completing this BR artifact.

Residual risks and open questions:
- Personal and contextual recommendation types still depend on later decisions about consent handling, identity confidence thresholds, and regional activation policy.
- Style bundle exposure may need refinement in later feature and API work depending on channel-specific merchandising strategy.
