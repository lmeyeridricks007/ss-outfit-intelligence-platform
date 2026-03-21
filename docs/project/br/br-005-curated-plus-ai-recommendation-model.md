# Business requirements: BR-005 Curated plus AI recommendation model

## Metadata

- **BR ID:** BR-005
- **Issue:** #79
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent item:** none
- **Phase:** Phase 2
- **Approval mode:** HUMAN_REQUIRED
- **Source artifacts:** `docs/project/business-requirements.md`, `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/standards.md`, `docs/project/roadmap.md`, `docs/project/product-overview.md`, `docs/project/data-standards.md`
- **Next stage:** Feature breakdown board item to be created after BR review and approval

## Problem statement

SuitSupply needs a recommendation model that blends curated looks, rule-based compatibility, and AI ranking so customers receive complete-look recommendations that feel brand-right, context-aware, and commercially relevant instead of generic item-similarity suggestions. Today, the platform vision and top-level business requirements establish that curation, compatibility logic, and AI optimization must coexist, but they do not yet define the business boundaries for how those sources should interact, when each source should take precedence, or how internal teams keep control as personalization expands.

Without explicit business requirements for this blended model, downstream feature, architecture, and implementation work would make inconsistent assumptions about recommendation assembly, merchandising overrides, optimization freedom, and acceptable AI behavior. That creates risk across customer trust, brand safety, operational governance, and measurement, especially as the platform expands from RTW-first digital surfaces into richer contextual, personalized, and CM-aware experiences.

## Target users

### Primary customer users
- Shoppers on PDP, cart, homepage, and style-inspiration surfaces who need help completing an outfit around an anchor product, occasion, or seasonal context
- Returning customers whose recommendations should reflect prior purchases, browsing patterns, and profile signals where permitted
- Customers exploring premium or occasion-led purchases who need confidence that recommended items work together as a complete look

### Primary internal users
- Merchandisers who author curated looks, define overrides, and protect brand styling standards
- Styling and clienteling teams who need recommendation outputs they can trust in customer interactions
- Product and optimization teams responsible for ranking goals, experimentation, and measurable business lift

### Secondary internal users
- Marketing teams using recommendation outputs in email or campaign activation
- Analytics and operations teams who need traceability, telemetry, and audit context for recommendation decisions

## Business value

The curated-plus-AI recommendation model must create value in three layers:

### Customer value
- Reduce outfit-building friction by turning an anchor product or intent into a complete, coherent outfit recommendation
- Improve confidence that recommended items are compatible, purchasable, and appropriate for the customer context
- Make personalization feel helpful without appearing random, off-brand, or inconsistent across surfaces

### Commercial value
- Increase conversion by improving relevance on high-intent surfaces
- Increase basket size and attachment rate by recommending complementary products across categories
- Improve AOV by allowing upsell and premium suggestions only when compatibility and brand standards are preserved
- Improve repeat engagement and lifetime value by making recommendations more useful across repeat visits and channels

### Operational value
- Scale merchandising expertise through reusable curated looks and governed rules rather than fully manual surface-by-surface curation
- Allow optimization teams to improve ranking performance without breaking hard compatibility, governance, or campaign controls
- Create a shared recommendation policy that downstream teams can build against without re-deciding source precedence

## Recommendation and channel mapping

### Recommendation types in scope
- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Style bundles
- Occasion-based recommendations
- Contextual recommendations
- Personal recommendations

### Consuming surfaces in scope
- PDP
- Cart
- Homepage and web personalization surfaces
- Style inspiration and look-builder experiences
- Email activation outputs
- Clienteling and stylist-facing surfaces

### Recommendation sources in scope
- **Curated:** merchandiser-authored or merchandiser-approved looks, bundles, campaigns, or hero combinations
- **Rule-based:** compatibility, eligibility, business constraints, exclusions, inventory constraints, campaign priorities, and policy rules
- **AI-ranked:** ranking and ordering logic that optimizes among eligible candidates using customer, context, and performance signals

## Blended model principles

The business requirement for this capability is not that all three sources have equal weight. The requirement is that they have distinct roles, explicit precedence, and measurable contribution to the final result.

### Principle 1: curated content defines brand-safe candidate direction
Curated looks and bundles must provide high-confidence starting points for complete-look recommendations, campaign storytelling, and premium brand expression. Curated content may seed candidate sets, define hero looks, or constrain which combinations are allowed for a given context.

### Principle 2: rule-based logic defines hard boundaries
Rule-based compatibility and governance logic must determine whether products, looks, or recommendation candidates are eligible to appear together. Hard rules take precedence over ranking and may block otherwise high-scoring recommendations when style, inventory, legal, or campaign constraints are violated.

### Principle 3: AI ranking optimizes within permitted boundaries
AI ranking must personalize and order eligible recommendation candidates using customer, context, and performance signals, but only after curated and rule-based constraints establish the allowed decision space. AI may choose among valid options; it must not override brand safety, compatibility, consent, or explicit merchandising restrictions.

### Principle 4: explainability must survive blending
Every delivered recommendation set must remain traceable enough that internal teams can answer:
- which curated look, if any, influenced the result
- which rules admitted or rejected candidates
- which ranking factors or experiment context influenced ordering

## Functional business requirements

### BR-005.1 Source blending model
The platform must support recommendation assembly in which curated looks, rule-based compatibility, and AI ranking each contribute to the final recommendation set through explicitly defined roles rather than ad hoc mixing.

### BR-005.2 Curated seeding and override support
The platform must allow merchandisers to define curated looks, featured combinations, and campaign-led recommendations that can seed or constrain recommendation candidates for relevant surfaces, categories, or occasions.

### BR-005.3 Hard-rule precedence
The platform must enforce hard compatibility, eligibility, inventory, policy, and governance rules before AI ranking is allowed to influence final recommendation ordering.

### BR-005.4 AI optimization boundaries
The platform must allow AI ranking to optimize relevance, ordering, and selection among eligible candidates using customer history, context, and performance signals, but it must not bypass curated exclusions, hard compatibility rules, or restricted governance controls.

### BR-005.5 Variable blend by surface and use case
The platform must support different blends by recommendation type and surface, such as more curated emphasis for campaign-led inspiration, more rule-based emphasis for compatibility-critical combinations, and more AI-ranking influence for personalization-heavy surfaces.

### BR-005.6 RTW and CM distinction
The platform must support blended recommendation logic for RTW and CM while preserving different business boundaries where necessary, including stronger compatibility constraints for CM configuration-aware scenarios and immediate purchasability emphasis for RTW ecommerce flows.

### BR-005.7 Governance controls
The platform must provide internal controls for enabling, disabling, or limiting curated, rule-based, and AI-ranked contribution by surface, market, campaign, and recommendation type.

### BR-005.8 Fallback behavior
The platform must degrade gracefully when one source is unavailable or weak. If personalization data is limited, recommendations should still rely on curated and rule-based logic; if curated coverage is sparse, eligible rule-based and AI-ranked recommendations may still serve; if AI ranking is unavailable, deterministic ordering must preserve safe and coherent outputs.

### BR-005.9 Traceability and telemetry
The platform must emit recommendation set IDs, trace IDs, source contribution context, rule context, and experiment metadata so teams can audit recommendation composition and measure business outcomes.

### BR-005.10 Optimization guardrails
The platform must optimize for business lift only within approved guardrails so experiments and ranking changes do not increase volume, diversity, or premium bias at the expense of style coherence, brand trust, or operational validity.

## Scope boundaries

### In scope
- Defining the business roles of curated, rule-based, and AI-ranked sources
- Defining source precedence and optimization boundaries
- Defining internal governance expectations for overrides, controls, and auditability
- Defining how the blended model supports major recommendation types and surfaces
- Defining fallback and degradation expectations when source inputs are incomplete
- Defining how RTW and CM differ at the business-rule level
- Defining measurement expectations for source contribution and business outcomes

### Out of scope
- Technical architecture for ranking services, APIs, feature stores, or model pipelines
- Detailed scoring formulas, model choices, or machine-learning implementation details
- Surface-specific UI design or content presentation rules
- Detailed authoring workflow design for merchandising tools beyond stating the business need for governance controls
- Exact experimentation framework implementation
- Final legal or policy decisions for sensitive data classes; those remain governed by policy owners

## RTW / CM considerations

### RTW
- Prioritize immediate purchasability, inventory-aware eligibility, and fast complete-look completion on ecommerce surfaces
- Allow AI ranking to tune ordering more aggressively where inventory, compatibility, and merchandising constraints are already satisfied
- Support curated campaign looks that can be reused broadly across digital surfaces

### CM
- Preserve stronger compatibility and governance constraints because recommendation quality depends on active configuration choices such as fabric, color family, style details, and premium options
- Require that AI ranking operate within a narrower eligible set whenever CM configuration state materially changes what is compatible
- Maintain room for human-in-the-loop styling and clienteling guidance, especially for premium or appointment-led journeys

## Business rules for source precedence

The blended recommendation model must follow these business precedence expectations:

1. **Policy and consent constraints first**  
   Customer data usage, regional restrictions, and activation permissions determine whether personalization inputs may be used.

2. **Eligibility and compatibility second**  
   Product availability, category rules, style compatibility, CM configuration compatibility, exclusions, and campaign constraints determine the valid candidate pool.

3. **Curated direction third**  
   Curated looks, featured bundles, and merchandising priorities shape which valid combinations should be emphasized or protected for the use case.

4. **AI ranking fourth**  
   AI ranking orders or selects among permitted candidates using customer, context, and performance signals.

5. **Fallback ordering last**  
   Deterministic fallback logic applies when ranking signals or source coverage are insufficient.

## Governance and controls

The platform must preserve merchandising governance as a first-class business capability, including:

- the ability to pin, boost, suppress, or exclude curated looks and products
- the ability to define hard compatibility and exclusion rules that ranking cannot override
- the ability to set campaign or market priorities
- the ability to control where AI ranking is active, limited, or disabled
- the ability to review why a recommendation set was produced
- the ability to audit changes to looks, rules, and campaign context over time

Governance must support safe experimentation. Optimization teams may test ranking strategies, but experiments must respect hard rules, consent boundaries, and brand standards.

## Optimization boundaries

AI ranking and experimentation may optimize for outcomes such as conversion, attachment, AOV, repeat engagement, and recommendation interaction, but the following boundaries apply:

- Do not optimize for click-through rate alone if it harms outfit coherence or downstream conversion quality.
- Do not prioritize premium or high-margin products when compatibility, context relevance, or customer trust would be weakened.
- Do not allow opaque ranking changes that cannot be traced to source context, experiment context, or rule context.
- Do not use restricted customer data classes unless policy, consent, and regional allowances are explicitly satisfied.
- Do not optimize recommendation diversity in a way that creates visually or stylistically incoherent outfits.

## Success metrics

### Commercial metrics
- Conversion uplift on surfaces using the blended model
- AOV uplift for recommendation-influenced sessions
- Attachment rate across complementary categories
- Upsell conversion where premium recommendations remain compatibility-safe

### Product metrics
- Recommendation click-through rate by source blend and surface
- Add-to-cart rate and purchase rate from recommendation-influenced sessions
- Coverage of complete-look recommendations by surface, category, and market
- Percentage of recommendation sets with traceable source contribution context
- Fallback rate when AI ranking or curated coverage is unavailable

### Governance and quality metrics
- Override usage and override resolution rates by internal teams
- Percentage of recommendation sets blocked or adjusted by compatibility and governance rules
- Auditability completeness for recommendation set IDs, trace IDs, rule context, and experiment context
- Incidence of off-brand or incompatible recommendation defects discovered in review or operations

## Assumptions

- Merchandising teams can provide enough curated looks and campaign inputs to seed high-value recommendation scenarios.
- Compatibility rules can be expressed clearly enough to form a hard eligibility layer before ranking.
- AI ranking goals will be defined as business outcome optimization within governance constraints rather than unconstrained model autonomy.
- Stable canonical IDs and telemetry standards from project standards and data standards will be available to support auditability.
- Surface teams can consume recommendation source context where needed for internal diagnostics even if customer-facing explanations stay limited.

## Missing decisions / open questions

- **Missing decision:** Which surfaces in the first release require curated-first behavior versus AI-personalized-first behavior?
- **Missing decision:** What minimum curated coverage is required by category, market, and campaign before a surface is considered launch-ready?
- **Missing decision:** Which internal users may override AI ranking behavior, and at what granularity: global, regional, campaign, or surface level?
- **Missing decision:** Which sensitive signal classes, such as stylist notes or appointment data, are permitted in ranking by region and consent state?
- **Missing decision:** What level of explanation should be exposed in internal tooling for ranking influence versus source contribution?
- **Missing decision:** What business thresholds define acceptable fallback behavior when curated coverage or AI ranking quality is insufficient?

## Approval / milestone-gate notes

- **Approval mode for BR stage:** HUMAN_REQUIRED
- **Current run behavior:** Triggered by issue-created automation in autonomous mode; artifact and board update may be committed and pushed without waiting for human approval.
- **Milestone gate notes:** No additional milestone gate is defined at BR stage in the available source docs. If later stages introduce gating for sensitive CM or data-policy decisions, those gates should inherit the governance constraints documented here rather than re-deciding source precedence.

## Recommended board update

Update `boards/business-requirements.md` row for `BR-005` / issue `#79` with:
- status `Pushed` after branch push
- approval mode `HUMAN_REQUIRED`
- trigger source referencing issue-created automation and the canonical project docs
- note that the BR artifact defines source blending, governance controls, and optimization boundaries for curated, rule-based, and AI-ranked recommendations
