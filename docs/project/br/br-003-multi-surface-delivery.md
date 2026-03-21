# Business requirements: BR-003 Multi-surface delivery

**Board Item ID:** BR-003  
**Issue:** #77  
**Parent Item:** None  
**Stage:** workflow:br  
**Trigger:** issue-created automation  
**Primary sources:** `docs/project/business-requirements.md`, `docs/project/product-overview.md`, `docs/project/roadmap.md`, `docs/project/goals.md`, `docs/project/api-standards.md`, `docs/project/ui-standards.md`, `docs/project/integration-standards.md`

## Problem statement

SuitSupply needs one recommendation capability that can serve ecommerce, email, clienteling, and future API consumers without each surface inventing separate recommendation logic, data assumptions, or operating rules. Today, the product strategy expects complete-look, context-aware recommendations to be reusable across channels, but the business requirement for how those channels differ and what they must share is not yet captured in one place. Without a clear multi-surface delivery requirement, downstream feature and implementation work could overfit ecommerce needs, under-serve email and in-store workflows, or fragment the API contract and telemetry model in ways that make recommendations inconsistent, hard to govern, and difficult to scale to future consumers.

This matters now because Phase 3 explicitly expands the platform from foundational ecommerce loops into merchandising control and multi-channel activation. The business requirement must therefore define which surfaces are in scope, what each surface needs from shared recommendation delivery, how rollout should sequence across surfaces, and which delivery expectations remain common regardless of consumer.

## Target users

### Primary users
- Ecommerce shoppers on PDP, cart, homepage, and style-discovery surfaces who need complete-look recommendations that are actionable in-session.
- Marketing and CRM teams who need reusable recommendation outputs for lifecycle and campaign email content.
- In-store stylists and clienteling teams who need recommendation sets they can trust during assisted selling, appointment preparation, and follow-up.
- Future product or partner teams consuming the recommendation API for mobile or other API-driven experiences.

### Secondary users
- Merchandisers defining curated looks, campaign priorities, and override rules that must apply consistently across consumers.
- Analytics and optimization teams measuring recommendation effectiveness across surfaces.
- Product and delivery teams responsible for phased rollout, governance, and operational reliability.

## Business value

BR-003 supports the following business outcomes:
- Increase conversion and average order value by reusing complete-look recommendations at multiple decision points instead of limiting value to a single ecommerce module.
- Improve campaign and CRM effectiveness by giving email teams recommendation outputs that match product, customer, and campaign context.
- Improve clienteling effectiveness by giving stylists and store teams governed recommendation sets that reflect the same compatibility and merchandising logic used online.
- Reduce duplicated channel-specific logic so recommendation quality, governance, and measurement improve centrally rather than being rebuilt per surface.
- Create an API-first delivery model that can support future consumers faster and with lower operational risk.

## Recommendation and channel mapping

### Recommendation types involved
- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Style bundles
- Occasion-based recommendations
- Contextual recommendations
- Personal recommendations

### Consuming surfaces in scope
- Ecommerce: PDP, cart, homepage or web personalization, and style inspiration or look-building surfaces
- Email campaigns and lifecycle communications
- Clienteling interfaces for stylists and store teams
- Future API consumers such as mobile or partner-operated experiences

### Recommendation sources that must remain explicit
- Curated looks and campaign selections
- Rule-based compatibility and business constraints
- AI-ranked ordering and personalization

## Scope boundaries

### In scope
- Define the shared business requirement for a single recommendation delivery pattern serving ecommerce, email, clienteling, and future API consumers.
- Define surface-specific business needs for recommendation payload shape, freshness, context usage, fallback behavior, and explainability.
- Define shared delivery expectations for canonical IDs, traceability, recommendation set metadata, telemetry, governance, and API-first contracts.
- Define rollout sequencing across surfaces, including why ecommerce surfaces precede email and clienteling activation.
- Define how recommendations should stay consistent while allowing each surface to present them differently.
- Define how non-core enrichments and degraded inputs should reduce recommendation richness without breaking the consumer contract.
- Define business constraints for shared delivery across regions, consent boundaries, and internal versus customer-facing trust domains.

### Out of scope
- Technical API architecture, service decomposition, or infrastructure design.
- Detailed UI specifications for each consumer surface.
- ESP, POS, CRM, OMS, or commerce platform replacement.
- Detailed backlog fan-out for downstream feature, architecture, or implementation items.
- Exact SLA, latency, or experimentation threshold values where the business source material only establishes directional expectations.

## Surface-specific business requirements

### Ecommerce requirements
- Ecommerce surfaces must receive recommendation sets that are immediately purchasable, coherent, and aligned to the active shopping context.
- PDP and cart must prioritize high-confidence outfit, cross-sell, and upsell recommendations around an anchor product or cart state.
- Homepage and style-discovery surfaces may emphasize contextual, occasion-based, and personal recommendations where anchor-product context is weaker.
- Ecommerce consumers must preserve shared recommendation labels and grouping semantics so complete looks remain understandable across web surfaces.
- Ecommerce fallback behavior must handle missing personalization or partial availability without rendering broken or misleading looks.

### Email requirements
- Email consumers must receive recommendation outputs that can be embedded into campaign and lifecycle content without redefining recommendation logic in the ESP.
- Email recommendations must support campaign-aware and audience-aware selection while still respecting the same compatibility, merchandising, and consent controls as ecommerce.
- Email delivery must tolerate longer content production or send windows than request-time ecommerce delivery, while still using stable recommendation set semantics and canonical identifiers.
- Email teams need reusable recommendation outputs and metadata that support campaign assembly, experimentation, and outcome measurement without exposing sensitive internal reasoning to customers.
- Email fallbacks must allow graceful degradation when customer-specific or context-specific inputs are unavailable at send or render time.

### Clienteling requirements
- Clienteling consumers must receive recommendation sets that support assisted selling, store appointments, and follow-up outreach rather than only self-serve browsing.
- Clienteling outputs must expose more decision context than customer-facing ecommerce surfaces, including recommendation source, compatible alternatives, and relevant eligibility or override signals where appropriate for internal users.
- Clienteling recommendations must support both RTW and future deeper CM-guided workflows without collapsing their distinct decision states into one generic output.
- Stylists must be able to trust that recommendation sets reflect merchandising controls, compatibility logic, and inventory-aware constraints before they are used in customer interactions.
- Clienteling fallbacks must preserve operational usefulness when some enrichment signals are delayed, partial, or unavailable.

### Future API consumer requirements
- The recommendation API must remain consumer-agnostic so new surfaces can reuse the core contract without fragmenting the platform into per-surface logic silos.
- Future consumers must be able to declare explicit context such as customer, product, surface, locale, and session state rather than relying on opaque or hard-coded assumptions.
- Versioning and extension patterns must let future consumers add consumer-specific needs through adapters or versioned fields instead of breaking the shared contract.
- New consumers must inherit the same governance, traceability, telemetry, and canonical ID expectations established for initial surfaces.

## Shared delivery expectations

### API-first delivery expectations
- Recommendation delivery must be API-first, with a consumer-agnostic core contract that separates recommendation decisioning from surface rendering.
- Requests must support explicit context inputs relevant to recommendation quality, including customer, product, surface, locale, and other useful situational context.
- Responses must preserve recommendation set ID, recommendation type, ordered looks or items, and experiment or trace metadata needed for downstream measurement and support.
- No-recommendation cases must return an explicit empty-result outcome rather than an ambiguous failure.
- Consumer-specific differences should be handled through documented adapters or versioned extensions, not through divergent business logic.

### Surface-versus-channel standards
- Surface presentation may vary, but recommendation meaning, grouping intent, and action semantics must stay consistent across consumers unless a documented workflow exception exists.
- Customer-facing surfaces should show only the level of reasoning appropriate for trust and clarity, while internal surfaces may expose additional rule, source, and eligibility context.
- Shared recommendation terminology must remain consistent across ecommerce, email, clienteling, and future consumers.
- Partial availability, missing context, and degraded enrichments must lead to explicit fallback behavior instead of broken experiences or silent contract changes.

### Governance and telemetry expectations
- All consuming surfaces must preserve recommendation set ID and trace context so downstream events can be tied back to the originating recommendation decision.
- Customer-facing consumers should emit impression, click, add-to-cart, purchase, and dismiss telemetry where relevant.
- Internal consumers should emit override, curation, and rule-inspection telemetry where relevant.
- Shared delivery must distinguish curated, rule-based, and AI-ranked contributions when needed for internal governance and optimization.
- Delivery across surfaces must respect consent, privacy, and region-specific data-use constraints, especially when customer identity or stylist notes are involved.

### Data and integration expectations
- Canonical IDs and source mappings must remain stable across ecommerce, email, clienteling, and future consumers.
- Shared delivery must rely on normalized source data rather than surface-specific reinterpretation of upstream schemas.
- Critical dependencies include catalog, inventory, commerce, customer, identity, and telemetry feeds; enrichment inputs such as weather or calendar context should improve recommendation richness without breaking the core response when degraded.
- Each new consuming surface must define its business purpose, freshness needs, and failure behavior before it is added to the rollout sequence.

## RTW / CM considerations

- Initial rollout should prioritize RTW ecommerce flows because they provide the fastest validation loop for complete-look, cross-sell, and upsell effectiveness.
- Email and clienteling must be designed so they can support RTW first without preventing later CM-aware recommendations.
- CM-specific recommendation depth is later in the roadmap, but BR-003 must preserve contract flexibility for configuration-aware and stylist-assisted journeys.
- Clienteling is the most likely early surface to need differentiated RTW versus CM context because assisted selling may involve appointments, stylist notes, and premium configuration discussions.

## Rollout sequence

### Sequence
1. **Ecommerce foundation surfaces:** PDP and cart first, because they provide high-signal anchor-product flows and the fastest commercial validation.
2. **Expanded ecommerce surfaces:** homepage, web personalization, and style-discovery surfaces after initial recommendation quality, telemetry, and fallback behavior are stable.
3. **Email activation:** reusable recommendation outputs for campaign and lifecycle programs once API contracts, telemetry semantics, and campaign-aware governance are stable.
4. **Clienteling activation:** internal stylist and store workflows once recommendation traceability, override clarity, and operational trust are sufficient for assisted selling.
5. **Future API consumers:** mobile or partner-operated surfaces after the shared contract proves stable across the earlier consumer set.

### Rollout guardrails
- Broader surface expansion must not occur before telemetry completeness and recommendation traceability are reliable.
- Non-ecommerce consumers must not require bespoke recommendation logic that breaks the shared API-first model.
- Clienteling and future CM-sensitive use cases should follow after governance and operational controls are strong enough for internal decision support.

## Success metrics

- Recommendation coverage across ecommerce, email, clienteling, and onboarded API consumers.
- Consistency of recommendation telemetry across surfaces, including preservation of recommendation set ID and trace context.
- Conversion, attachment, and AOV uplift on ecommerce surfaces influenced by shared recommendation delivery.
- Engagement and downstream performance improvement for recommendation-enabled email programs.
- Adoption and trust of recommendation outputs by clienteling teams, measured through usage and override patterns.
- Reduction in surface-specific rework or duplicated recommendation logic for new consumers.

## Constraints

- Shared delivery must respect privacy, consent, and region-specific data handling constraints.
- Internal and customer-facing consumers operate under different trust and explanation needs.
- Recommendation quality cannot depend on every enrichment signal being present in real time.
- Surface expansion must follow phased rollout discipline rather than broad simultaneous launch.
- The business requirement must stay API-first without prescribing technical implementation details.

## Open decisions

- Missing decision: which ecommerce surfaces beyond PDP and cart are part of the first production activation sequence.
- Missing decision: what freshness expectations email requires for precomputed versus render-time recommendation selection.
- Missing decision: which clienteling workflows are first in scope, such as live assisted selling, appointment preparation, or follow-up outreach.
- Missing decision: whether future mobile experiences should be treated as a distinct early consumer or part of a later general API-consumer phase.
- Missing decision: what regional consent and policy constraints apply to cross-channel identity usage for email and clienteling.

## Approval / milestone-gate notes

- Approval Mode: `HUMAN_REQUIRED` by default because no explicit BR-stage auto-approval setting is recorded in the source artifacts.
- Trigger: issue-created automation; this artifact is drafted and pushed autonomously per workflow instructions.
- Milestone note: downstream feature and architecture work should preserve the phased rollout and API-first contract expectations recorded here.

## Recommended board update

Add or update `BR-003` in `boards/business-requirements.md` with:
- Status: `Pushed`
- Approval Mode: `HUMAN_REQUIRED`
- Trigger Source: `issue #77; docs/project/business-requirements.md; docs/project/product-overview.md; docs/project/roadmap.md`
- Output: `docs/project/br/br-003-multi-surface-delivery.md`
- Notes: autonomous issue-created BR draft pushed; follow-up decisions remain non-blocking for feature breakdown.
