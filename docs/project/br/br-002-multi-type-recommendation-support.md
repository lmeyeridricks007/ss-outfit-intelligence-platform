# BR-002: Multi-type recommendation support

## 1. Metadata and traceability

- **BR ID:** BR-002
- **Title:** Multi-type recommendation support
- **Trigger:** issue-created automation for GitHub issue #76
- **Parent item:** none
- **Source artifacts:**
  - `docs/project/business-requirements.md`
  - `docs/project/product-overview.md`
  - `docs/project/goals.md`
  - `docs/project/roadmap.md`
- **Output artifact:** `docs/project/br/br-002-multi-type-recommendation-support.md`
- **Board:** `boards/business-requirements.md`
- **Downstream stage:** feature breakdown for recommendation types, surfaces, ranking inputs, and API contracts
- **Approval mode:** AUTO_APPROVE_ALLOWED

## 2. Problem statement

SuitSupply needs one recommendation platform that can serve different recommendation intents without fragmenting business logic by surface or channel. The current product vision requires support for outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendations, but downstream teams still need a common taxonomy that explains how those recommendation types differ, where each one can be used, what should not be mixed together, and which types should launch first.

Without a shared taxonomy, feature teams can interpret "recommendation" differently across ecommerce, email, and clienteling surfaces. That creates risk for inconsistent API contracts, overlapping business rules, weak experimentation design, and recommendation sets that are confusing to customers or hard for merchandisers to govern. This BR defines the business framing for recommendation types so later feature specs and contracts can be explicit about recommendation intent, surface fit, governance boundaries, and rollout sequencing.

## 3. Target users

### Primary users

- Ecommerce customers browsing RTW products on PDP, cart, homepage, and style inspiration flows
- Returning customers whose purchase, browsing, and engagement history may shape recommendation ranking
- Customers shopping with a clear event, seasonal, travel, or occasion intent

### Secondary users

- Merchandisers who curate looks, define recommendation boundaries, and manage campaign or override logic
- In-store stylists and clienteling teams who need reusable complete-look outputs in assisted selling flows
- CRM and lifecycle marketing teams activating recommendation sets in email
- Product, analytics, and optimization teams defining measurement and experimentation
- Downstream feature, API, and implementation teams that need unambiguous recommendation-type semantics

## 4. Business value

This requirement supports the platform's business goals by:

- increasing conversion through recommendation sets that match the customer's decision state
- increasing basket size and attachment by distinguishing complementary recommendations from premium trade-up suggestions
- improving reuse across surfaces by giving channels a shared recommendation vocabulary
- reducing implementation ambiguity for feature and API teams by standardizing recommendation intent
- preserving merchandising control by defining where curated, rule-based, and AI-ranked logic can shape each type
- enabling phased rollout by identifying which recommendation types are foundational versus later-stage enrichments

## 5. Business requirement summary

The platform must support a controlled taxonomy of recommendation types across outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendation modes. The taxonomy must define:

- what each recommendation type means in business terms
- which surfaces and channels can consume each type
- which recommendation types are primary decision intents versus overlays that modify ranking or selection
- where RTW and CM expectations differ
- the governance boundaries that prevent type misuse or customer confusion
- the rollout order used to stage downstream feature specs, contracts, and activation plans

## 6. Taxonomy model

### 6.1 Taxonomy structure

This BR defines recommendation taxonomy using two axes so downstream teams do not collapse unlike concepts into one field.

#### Axis A: primary recommendation intent

These types define the main customer-facing decision the recommendation set is trying to support:

1. **Outfit**
   - Purpose: assemble a coherent complete look around an anchor product, an entry point, or a styling journey.
   - Typical output: coordinated multi-item look or look components.
   - Core question answered: "How do I complete this outfit?"

2. **Cross-sell**
   - Purpose: attach complementary products that fit the current item, cart, or look.
   - Typical output: adjacent categories or add-on pieces that increase attachment.
   - Core question answered: "What goes well with this?"

3. **Upsell**
   - Purpose: present a higher-value alternative, premium substitution, or premium-compatible addition without breaking compatibility.
   - Typical output: higher-tier items, premium fabrics, upgraded accessories, or elevated combinations.
   - Core question answered: "What is a better or more premium version of this choice?"

4. **Style bundle**
   - Purpose: present a reusable grouped look or merchandising package that can be reused across channels.
   - Typical output: curated look groupings, campaign-led style sets, or reusable pre-composed bundles.
   - Core question answered: "Show me a ready-made styling set I can adopt or explore."

5. **Occasion-based**
   - Purpose: optimize recommendations for a known event, use case, or dress-code context.
   - Typical output: looks and products aligned to wedding, business formal, travel, seasonal event, or other occasion needs.
   - Core question answered: "What should I wear for this occasion?"

#### Axis B: ranking and selection overlays

These are not stand-alone customer intents in every case. They modify how a primary recommendation intent is selected, ordered, or filtered.

6. **Contextual**
   - Purpose: adapt output using contextual signals such as weather, location, season, holiday, inventory, or session state.
   - Business role: overlay that can refine outfit, cross-sell, upsell, style bundle, or occasion-based recommendations.
   - Core question answered: "What is most relevant right now in this context?"

7. **Personal**
   - Purpose: adapt output using customer profile, purchase history, browsing, engagement, identity, and known preferences where allowed.
   - Business role: overlay that can refine outfit, cross-sell, upsell, style bundle, or occasion-based recommendations.
   - Core question answered: "What is most relevant for this customer?"

### 6.2 Taxonomy usage rule

Downstream contracts should treat recommendation type as a combination of:

- **primary intent**: one of outfit, cross-sell, upsell, style bundle, or occasion-based
- **active overlays**: contextual and/or personal when applied

This avoids confusing "personal" or "contextual" with separate, always-independent product modules. A recommendation set may therefore be:

- outfit + contextual
- cross-sell + personal
- occasion-based + contextual + personal

But it should not be modeled as multiple competing primary intents in one set.

## 7. Recommendation type definitions and boundaries

### 7.1 Outfit recommendations

**Definition**

Outfit recommendations produce a complete-look outcome centered on a product, look entry point, or style objective.

**Use when**

- the customer starts from an anchor product such as a suit, jacket, trouser, or shirt
- the surface is expected to help complete a full outfit
- styling coherence matters more than raw item relevance

**Do not use when**

- the surface only has space for narrow attachment suggestions
- the experience is intended to compare premium alternatives rather than complete a look

**Expected surfaces**

- PDP
- style inspiration and look-builder pages
- homepage modules focused on look discovery
- clienteling interfaces
- selected email modules with enough creative space

### 7.2 Cross-sell recommendations

**Definition**

Cross-sell recommendations propose complementary products that increase attachment without replacing the anchor item.

**Use when**

- the customer already has an anchor item or cart context
- adjacent-category attachment is the primary business goal
- the surface needs compact, actionable add-on suggestions

**Do not use when**

- the business goal is premium substitution or price-tier movement
- the output requires a full complete-look composition

**Expected surfaces**

- PDP
- cart
- mini-cart or cart drawer if added later
- clienteling
- transactional or lifecycle email slots where attachment is the primary goal

### 7.3 Upsell recommendations

**Definition**

Upsell recommendations propose a higher-value alternative or premium addition that remains compatible with the current decision state.

**Use when**

- the customer can credibly be shown a premium option
- the recommendation preserves style integrity and compatibility
- margin, premium mix, or upgraded styling is the main business objective

**Do not use when**

- the recommendation would confuse the customer by replacing a committed decision with an incompatible option
- the experience should stay focused on accessory attachment rather than upgrade logic

**Expected surfaces**

- PDP
- cart, where premium additions remain compatible
- clienteling, especially in guided styling and premium consultations
- CM-assisted experiences where premium combinations are explicit

### 7.4 Style bundle recommendations

**Definition**

Style bundle recommendations expose reusable grouped looks or merchandising-defined style sets that can be activated consistently across channels.

**Use when**

- merchandising wants a reusable look construct
- campaign or seasonal narratives need consistent grouped outputs
- the recommendation should preserve a specific curated combination

**Do not use when**

- the surface expects purely dynamic item-level attachment
- there is insufficient merchandising confidence or creative support for grouped presentation

**Expected surfaces**

- homepage
- style inspiration pages
- email
- clienteling
- selected PDP modules where curated bundles support exploration

### 7.5 Occasion-based recommendations

**Definition**

Occasion-based recommendations shape output around a specific event, dress code, or use case rather than around a single anchor product.

**Use when**

- the customer's need is clearly occasion-led
- the journey begins from an event or mission rather than an item
- relevance should optimize for scenario fit and styling coherence

**Do not use when**

- the journey is strictly product-led and narrow attachment is enough
- the occasion signal is weak and would add more noise than clarity

**Expected surfaces**

- homepage
- landing pages
- style inspiration pages
- email
- clienteling
- future guided discovery experiences

### 7.6 Contextual recommendations

**Definition**

Contextual recommendations apply current-environment or session-aware logic to a primary recommendation intent.

**Use when**

- location, season, weather, inventory, holiday, or session context materially changes what is relevant
- the business wants regional or situational variation without redefining the primary customer need

**Do not use when**

- contextual signals are low-confidence, stale, or operationally unsafe
- the context would override hard compatibility or brand rules

**Expected surfaces**

- PDP
- cart
- homepage
- email
- clienteling

**Boundary**

Contextual is an overlay, not a substitute for defining the primary recommendation intent.

### 7.7 Personal recommendations

**Definition**

Personal recommendations apply customer-aware logic using permitted identity, preference, purchase, browsing, engagement, and affinity signals.

**Use when**

- the platform has allowed, high-confidence customer signals
- personalization can improve ranking, exclusions, or styling relevance
- the channel can benefit from customer continuity across sessions

**Do not use when**

- identity is anonymous or low-confidence and personalization would be misleading
- consent, regional policy, or data quality constraints make customer-specific adaptation unsafe

**Expected surfaces**

- homepage
- PDP
- cart
- email
- clienteling

**Boundary**

Personal is an overlay, not a replacement for the primary recommendation intent.

## 8. Surface and channel mapping

### 8.1 Surface expectations by recommendation type

| Primary surface | Outfit | Cross-sell | Upsell | Style bundle | Occasion-based | Contextual overlay | Personal overlay |
|---|---|---|---|---|---|---|---|
| PDP | Primary | Primary | Primary | Secondary | Secondary | Supported | Supported |
| Cart | Limited | Primary | Primary | Rare | Rare | Supported | Supported |
| Homepage / web personalization | Secondary | Secondary | Limited | Primary | Primary | Supported | Supported |
| Style inspiration / look-builder | Primary | Secondary | Limited | Primary | Primary | Supported | Supported |
| Email | Secondary | Secondary | Secondary | Primary | Primary | Supported | Supported |
| Clienteling | Primary | Primary | Primary | Primary | Primary | Supported | Supported |

### 8.2 Channel guidance

- **Ecommerce** should prioritize outfit, cross-sell, and upsell on high-signal surfaces first.
- **Email** should prefer style bundle and occasion-based outputs once reusable look packaging and contract stability exist.
- **Clienteling** can consume almost all recommendation types, but premium and CM-sensitive suggestions require stronger governance and traceability.
- **Future mobile and API-driven channels** should inherit this taxonomy rather than introducing channel-specific type names.

## 9. RTW and CM considerations

### RTW expectations

- RTW is the first rollout path for outfit, cross-sell, and upsell recommendations.
- RTW recommendation sets can rely more heavily on immediate purchasability, inventory, and fast surface feedback loops.
- RTW surfaces should be the proving ground for early taxonomy adoption and telemetry definitions.

### CM expectations

- CM uses the same taxonomy but requires stronger compatibility boundaries.
- Upsell in CM may include premium fabrics, finishing details, or premium combinations that depend on configuration state.
- Outfit and cross-sell in CM should not ignore configuration-specific compatibility.
- Occasion-based and style bundle concepts can apply to CM, but later rollout is preferred until configuration state and stylist workflow needs are represented explicitly.

## 10. Governance and usage boundaries

### 10.1 General governance rules

- Every recommendation set must declare one primary intent.
- Contextual and personal logic may be applied only as overlays.
- Hard compatibility, availability, and merchandising safety rules override ranking.
- Recommendation labels and groupings on customer-facing surfaces should avoid exposing sensitive customer reasoning.
- The same recommendation type should mean the same business concept across channels.

### 10.2 Merchandising control boundaries

- Merchandisers must be able to influence eligibility, exclusions, curated look inputs, and campaign priorities by recommendation type.
- Style bundle and occasion-based recommendations should allow stronger curated influence than narrow cross-sell slots.
- Upsell logic must be governable so premium suggestions remain credible and brand-safe.
- Personal and contextual overlays must remain observable, explainable, and reversible.

### 10.3 API and downstream specification implications

Downstream feature and API work must preserve these business distinctions:

- one primary recommendation intent per set
- zero or more overlays
- explicit consuming surface and channel context
- explicit source composition where relevant: curated, rule-based, AI-ranked
- traceability for recommendation set ID, trace ID, experiment context, and override context

This BR intentionally stops short of defining the technical schema, but it requires later API contracts to expose enough semantics to support these distinctions.

## 11. Rollout order

The rollout order follows `docs/project/roadmap.md` and is intended to minimize business risk while creating reusable contracts.

### Phase 1: foundation and first recommendation loop

**Recommendation types**

- outfit
- cross-sell
- upsell

**Surface focus**

- PDP
- cart

**Why first**

- validates core commercial value on high-signal ecommerce surfaces
- establishes the primary-intent taxonomy on the simplest high-confidence types
- creates the first telemetry and API contract baseline

### Phase 2: personalization and context enrichment

**Recommendation overlays and expanded primary intent**

- contextual overlay
- personal overlay
- occasion-based as an explicit primary intent where scenario-led journeys exist

**Surface focus**

- homepage / web personalization
- expanded PDP and cart ranking logic
- occasion-led discovery pages where available

**Why second**

- depends on stronger identity, data governance, and context quality
- should build on measured baseline performance from Phase 1

### Phase 3: merchandising control and multi-channel activation

**Recommendation types**

- style bundle as reusable grouped output
- broader activation of occasion-based outputs
- continued use of contextual and personal overlays

**Surface focus**

- email
- clienteling
- campaign-aware internal activation flows

**Why third**

- depends on stable recommendation contracts, internal workflow definitions, and governance tooling

### Phase 4: CM and advanced outfit intelligence

**Recommendation types**

- CM-aware outfit
- CM-aware cross-sell
- CM-aware upsell
- later expansion of occasion-based and style bundle support for CM contexts

**Surface focus**

- CM-assisted clienteling
- configured-garment journeys

**Why fourth**

- depends on explicit representation of CM configuration state and premium compatibility logic

### Phase 5: broader optimization and expansion

**Recommendation scope**

- expand all supported recommendation types to additional regions, surfaces, and future API consumers
- deepen optimization, experimentation, and governance maturity

## 12. In scope

- define the business taxonomy for the seven named recommendation modes
- distinguish primary intents from contextual and personal overlays
- define usage boundaries by surface and channel
- define RTW versus CM business implications where they affect rollout or governance
- define rollout sequencing needed for downstream feature specs and API contracts
- define the governance expectations required before broader activation

## 13. Out of scope

- technical API schema design
- ranking-model architecture or retrieval implementation
- UI copy, placement, and presentation design for specific surfaces
- detailed experiment designs
- downstream backlog fan-out beyond identifying what later stages must specify
- final approval of privacy, consent, or regional policy interpretation beyond noting business constraints

## 14. Success criteria

This BR is complete when downstream teams can use it to draft feature and API artifacts without guessing:

- the set of supported recommendation types
- which types are primary intents versus overlays
- where each type can and cannot be used
- which surfaces and channels should receive each type first
- which phases introduce each type
- what governance constraints must apply to recommendation-type usage

## 15. Open decisions and non-blocking notes

### Missing decisions

- What exact naming should customer-facing surfaces use when recommendation type labels are shown?
- Should style bundle be exposed as a distinct API primary intent, or as a packaged form of outfit with curated source metadata?
- What minimum confidence threshold is required before personal overlay logic may be activated on anonymous-to-known stitched profiles?
- Which regional contexts need tailored occasion taxonomies beyond the shared global baseline?

### Non-blocking notes for downstream stages

- Feature breakdown should define concrete scenarios and acceptance criteria per recommendation type and surface.
- API contracts should make the primary intent plus overlay model explicit.
- Clienteling and CM feature work should preserve stronger governance and traceability requirements for premium or assisted-selling flows.
- Privacy and consent enforcement remains a cross-cutting dependency for personal recommendations.
