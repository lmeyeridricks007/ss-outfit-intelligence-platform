# BR-004: RTW and CM support

## Purpose
Define the business requirements for supporting both RTW and CM recommendation behavior so downstream feature, architecture, and implementation work can preserve clear scope boundaries, differentiated customer outcomes, governance controls, and rollout sequencing.

## Practical usage
Use this artifact to guide feature breakdown for recommendation journeys, compatibility modeling, governance controls, delivery surfaces, and phase-specific scope decisions where RTW and CM support diverge.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #141
- **Board item:** BR-004
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for RTW and CM journeys, compatibility rules, governance workflows, and phased delivery planning

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/personas.md`
- `docs/project/goals.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must support both RTW and CM recommendation logic, but it must not treat them as the same customer journey or the same operational problem.

RTW recommendations must prioritize immediate, inventory-valid complete-look and attachment outcomes on ecommerce surfaces. CM recommendations must prioritize configuration-aware compatibility, premium styling credibility, and stylist- or appointment-ready guidance where customer choices, fabrics, palettes, and premium options materially change what should be shown.

Shared platform capabilities may serve both modes, but the business requirements must keep the following explicit:
- RTW and CM have different journey expectations, conversion paths, and fallback behavior.
- Compatibility constraints are deeper for CM than for RTW.
- Premium styling and operator governance requirements are stricter for CM.
- RTW launches earlier; CM depth follows only after data readiness and operator trust are established.

## Business problem
SuitSupply needs one recommendation platform that can serve both its core RTW commerce flows and its higher-touch CM experience without collapsing the two into generic recommendation logic.

Without explicit RTW versus CM boundaries:
- ecommerce teams may optimize for immediate product attachment while ignoring CM configuration realities
- CM experiences may receive recommendations that are visually appealing but operationally or stylistically invalid
- governance may be too weak for premium styling and appointment-led journeys
- downstream teams may over-scope early phases by trying to deliver CM depth before RTW foundations are dependable
- telemetry and experimentation may compare outcomes that do not represent the same customer intent

## Users and stakeholders
### Primary RTW-facing users
- **Persona P1: Anchor-product shopper** who needs fast, credible outfit completion from a browsed RTW product
- **Persona P2: Returning style-profile customer** who expects recommendations that complement prior purchases and current context
- **Persona P3: Occasion-led shopper** when the flow is fulfilled through readily purchasable RTW products

### Primary CM-facing users
- customers exploring custom garments who need guidance that respects selected or candidate fabric, silhouette, palette, shirt, tie, and premium option choices
- customers in appointment or assisted-selling contexts where recommendation confidence must support a premium service interaction
- occasion-led shoppers when the intended outcome is a custom or elevated formal look rather than a standard RTW purchase

### Secondary stakeholders
- **Persona S1: In-store stylist or clienteling associate** who needs explainable recommendation support for higher-touch CM and premium styling conversations
- **Persona S2: Merchandiser** who needs mode-specific rules, curated looks, exclusions, and override visibility
- **Persona S4: Product, analytics, and optimization team member** who needs separate measurement and rollout controls for RTW and CM

## Desired outcomes
- RTW experiences produce coherent, purchasable complete looks and complementary attachments on priority ecommerce surfaces.
- CM experiences produce recommendation guidance that respects garment configuration, premium styling standards, and operator trust requirements.
- Shared platform capabilities remain reusable, but mode-specific constraints are first-class in downstream contracts and governance.
- Phase sequencing stays disciplined: RTW value lands first, CM depth expands later.
- Teams can measure RTW and CM recommendation effectiveness separately rather than blending dissimilar journeys.

## RTW versus CM operating model
### Side-by-side comparison
| Dimension | RTW | CM |
| --- | --- | --- |
| Primary customer motion | Immediate shopping and basket completion | Guided configuration, premium styling, and appointment-led decision support |
| Core surfaces first in scope | PDP and cart | Later clienteling, assisted selling, and eventually bounded digital CM experiences |
| Primary recommendation intent | Complete-look, cross-sell, and upsell with inventory-valid products | Configuration-aware outfit guidance, premium option support, and compatibility-safe styling recommendations |
| Decision horizon | Shorter session and faster conversion expectation | Longer consideration cycle with more consultation and comparison |
| Product truth | Concrete sellable SKUs and inventory state | Configurable garment options, fabric and trim choices, premium styling rules, and service workflow context |
| Compatibility burden | Category fit, color, pattern, occasion, price tier, inventory validity | Fabric and palette harmony, garment configuration compatibility, shirt and tie coordination, premium option suitability, and service feasibility |
| Fallback expectation | Return a smaller RTW set or adjacent compatible recommendations | Degrade to safer curated guidance, stylist-assisted options, or narrower compatible choices without pretending unsupported CM depth |
| Operator involvement | Governance is important but customer flow is more self-service | Governance and stylist trust are central because outputs may influence premium assisted selling |
| Commercial emphasis | Conversion, attach, and average order value on ecommerce | Premium credibility, appointment effectiveness, look confidence, and later commercial uplift |

### Journey differences that downstream work must preserve
#### RTW journey expectations
- The customer often starts from a visible anchor product on ecommerce.
- Recommendation latency and visual credibility matter because the customer is deciding in-session.
- Outputs must emphasize inventory-valid products that can be purchased now.
- PDP and cart placements are the earliest measurable-value surfaces.
- Recommendation types center on outfit, cross-sell, and upsell in the first release phases.

#### CM journey expectations
- The customer may start from an appointment, stylist conversation, configurator state, or premium occasion need rather than from a single sellable SKU.
- Recommendations must respond to selected or candidate garment options, not just static catalog similarity.
- Outputs may need to support explanation, save/share, or stylist-assisted review before conversion.
- Immediate self-service conversion is less reliable as the sole success model than for RTW.
- Recommendation confidence must be high enough for premium service usage and brand-safe presentation.

## Mode-specific business requirements
### RTW requirements
- RTW recommendations must support standard product outfit completion around RTW anchor products.
- RTW outputs must remain inventory-valid and operationally purchasable for the active market.
- RTW flows must prioritize ecommerce complete-look, cross-sell, and upsell outcomes in early phases.
- RTW recommendations must work in shorter decision windows and support clear add-to-cart behavior.
- RTW fallback behavior must preserve purchasable relevance when full outfit completeness is not possible.

### CM requirements
- CM recommendations must respect compatibility with configured garments, fabrics, palettes, shirt and tie styles, and premium options.
- CM outputs must not imply configuration support that the platform cannot validate.
- CM recommendation behavior must preserve premium styling standards and support assisted-selling trust.
- CM recommendations must degrade to safer curated or stylist-led guidance when compatibility certainty is insufficient.
- CM recommendation usage must expose enough traceability for stylists and operators to understand the basis of the output.

### Shared requirements across both modes
- RTW and CM must share stable recommendation taxonomy, governance concepts, telemetry standards, and traceability patterns where possible.
- Shared delivery contracts must carry explicit mode context so downstream surfaces do not infer RTW or CM behavior incorrectly.
- Curated, rule-based, and AI-ranked recommendation sources must stay distinguishable in both modes.
- Identity, consent, and privacy constraints must apply consistently, even when CM is more assisted than self-service.

## Compatibility requirements
### RTW compatibility expectations
- Category coordination must remain credible across suit, shirt, tie, shoes, belt, outerwear, and accessories where relevant.
- Recommendations must respect occasion, season, market, and price-tier coherence.
- Inventory and assortment eligibility must prevent non-purchasable or withdrawn products from being surfaced.
- RTW compatibility should support quick customer confidence rather than exhaustive configuration logic.

### CM compatibility expectations
- Fabric and color palette compatibility must be explicit rather than assumed from broad style similarity.
- Garment selections and candidate options must constrain downstream shirt, tie, footwear, and accessory recommendations when relevant.
- Premium options and formalwear rules must be enforceable through business controls, not left solely to AI ranking.
- Market or service availability constraints for CM options must be modeled before customer-facing recommendation exposure.
- If a compatibility dimension is unknown, the system must narrow or suppress the recommendation set rather than overstate confidence.

## Premium styling requirements
- CM recommendations must preserve a premium styling standard that is at least as strict as current stylist or merchandiser expectations.
- Premium recommendation quality is not only a conversion concern; it is a brand and service-governance concern.
- Curated premium looks must remain a first-class input for CM, especially where high-formality, eventwear, or luxury presentation matters.
- AI ranking for CM must operate inside curated and rule-based boundaries and must not create aggressive premium jumps that undermine credibility.
- Customer-facing presentation for CM should avoid exposing uncertain or overly technical recommendation reasoning.

## Surface and persona implications
### Ecommerce RTW surfaces
- PDP and cart are the first priority surfaces for RTW recommendation delivery.
- RTW flows should primarily serve Personas P1, P2, and P3 in self-service digital contexts.
- Surface behavior should favor immediate shopping actions such as add-to-cart, bundle completion, or premium substitute evaluation.

### Assisted and clienteling surfaces
- Stylist and clienteling workflows become more important as CM depth expands.
- Persona S1 must be able to retrieve, tailor, and explain CM-oriented outputs with confidence.
- CM support should not require stylists to decode opaque model logic during premium customer interactions.

### Outbound and contextual channels
- Personal, contextual, and occasion-based recommendations may apply to both RTW and CM later, but mode awareness must remain explicit.
- Until CM data readiness is dependable, outbound or automated channels should not imply fully validated CM compatibility where it has not been modeled.

## Governance requirements
### Shared governance needs
- Both RTW and CM must support merchandising overrides, curated look inputs, exclusions, and audit visibility.
- Recommendation set decisions must remain explainable at an internal-operational level.
- Telemetry must separate RTW and CM performance, rule application, and override behavior.

### CM-specific governance needs
- CM compatibility rules require tighter operator control than standard RTW attachment rules.
- Premium styling outputs must be reviewable against curated examples and brand standards before wider rollout.
- Governance must define who can activate, override, or suppress CM recommendation behaviors in assisted and customer-facing flows.
- Rollout of CM recommendation behavior must be gated by data readiness, compatibility confidence, and operator trust rather than by roadmap ambition alone.

## Phased rollout assumptions
### Phase 1: Core ecommerce RTW recommendations
In scope:
- RTW complete-look, cross-sell, and upsell support on PDP and cart
- explicit mode handling in shared contracts, even if only RTW is enabled in production
- governance, telemetry, and compatibility foundations that do not block later CM modeling

Out of scope:
- production-grade CM recommendation depth
- self-service digital CM journeys that imply validated configuration-aware compatibility

### Phase 2: Context and personalization expansion
In scope:
- stronger RTW personalization and context usage
- preserving mode-awareness in contracts, identity handling, and telemetry

Boundary:
- CM may benefit from shared infrastructure maturation, but Phase 2 does not require broad CM recommendation launch behavior

### Phase 3: Operator scale and channel expansion
In scope:
- clienteling and governance improvements that prepare the platform for richer assisted workflows
- stronger auditability and cross-channel consistency

Boundary:
- these operator capabilities may prepare for CM, but they do not by themselves mean CM recommendation depth is complete

### Phase 4: CM depth and advanced optimization
In scope:
- configuration-aware CM logic
- premium option and fabric recommendation support
- broader stylist-assisted and potentially bounded customer-facing CM recommendation behavior
- advanced optimization once compatibility confidence and operator trust are established

Prerequisites:
- RTW operational maturity
- dependable CM data readiness
- explicit compatibility modeling
- operator review confidence

## Scope boundaries
### In scope
- explicit differentiation between RTW and CM recommendation journeys
- mode-specific outcomes, constraints, and fallback expectations
- compatibility and premium-styling requirements for CM
- RTW-first rollout sequencing with CM later-phase expansion
- governance and measurement needs that differ by mode
- persona implications for self-service ecommerce versus assisted selling

### Out of scope
- final CM configurator UX or field-level workflow design
- final API schema for mode context and compatibility payloads
- exact model architecture for compatibility or ranking
- final market-by-market rollout plan for CM enablement
- implementation tickets for specific surfaces or services

## Dependencies
- `BR-001` complete-look recommendation capability for outfit-centered journeys in both modes
- `BR-003` multi-surface delivery for ecommerce, clienteling, and future mode-specific consumers
- `BR-005` curated plus AI recommendation model for source precedence and premium-governance boundaries
- `BR-008` product and inventory awareness for RTW sellability and CM attribute completeness
- `BR-009` merchandising governance for overrides, exclusions, and premium rule control
- `BR-010` analytics and experimentation for separate RTW and CM measurement
- `BR-011` explainability and auditability for stylist and operator trust
- `BR-012` identity and profile foundation for later personalization across both modes

## Constraints
- RTW and CM must not be represented as one generic recommendation mode when downstream decisions differ materially.
- RTW recommendations must remain purchasable and inventory-valid for the active channel and market.
- CM recommendations must not overstate compatibility when configuration data, service availability, or premium styling rules are incomplete.
- Shared platform reuse must not erase necessary mode-specific governance and audit boundaries.
- Early delivery must prioritize dependable RTW value and operational trust over premature CM breadth.

## Assumptions
- RTW catalog and inventory foundations are sufficiently mature to support Phase 1 recommendation delivery.
- CM data can eventually expose the compatibility attributes needed for fabrics, palettes, shirt and tie styles, and premium options, even if not all are ready in early phases.
- Clienteling and styling teams will remain important operators for CM recommendation review and adoption.
- Shared telemetry can distinguish recommendation mode, source mix, and surface context.
- The roadmap sequence in `docs/project/roadmap.md` remains the baseline for RTW-first and CM-later rollout.

## Missing decisions
- Missing decision: which CM experiences should launch first once Phase 4 begins - stylist-only, appointment-led digital support, or bounded self-service customer flows.
- Missing decision: what minimum compatibility confidence is required before a CM recommendation can be shown customer-facing without stylist mediation.
- Missing decision: which CM premium options and formality tiers require curated-only control versus allowing AI-ranked variation.
- Missing decision: how far RTW and CM recommendation sets may mix in one experience before the customer experience becomes confusing.
- Missing decision: which markets and service models are eligible for early CM recommendation rollout.

## Downstream implications
- Feature breakdown work must separate RTW and CM flows where their outcomes, constraints, or governance differ.
- Architecture work must preserve explicit mode context and compatibility-rule enforcement paths.
- Delivery work must define different fallback behavior for RTW self-service versus CM assisted or premium flows.
- Governance tooling must allow tighter review and override controls for CM than for standard RTW attachment use cases.
- Analytics work must report RTW and CM outcomes separately so phased rollout decisions remain evidence-based.

## Review snapshot
Trigger: issue-created automation from GitHub issue #141.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, product overview, roadmap, goals, and personas provide enough context to define RTW-versus-CM boundaries, phased sequencing, governance needs, and missing decisions without inventing implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before locking CM rollout specifics.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-004 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for CM rollout readiness.
