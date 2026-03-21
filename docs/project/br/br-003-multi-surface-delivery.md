# Business requirements: BR-003 Multi-surface delivery

## Metadata
- **BR ID:** BR-003
- **Title:** Multi-surface delivery
- **Trigger:** issue-created automation from GitHub issue #140
- **Board Item ID:** BR-003
- **Parent Item:** none
- **Stage:** workflow:br
- **Phase:** Phase 1
- **Approval Mode:** AUTO_APPROVE_ALLOWED
- **Primary output:** `docs/project/br/br-003-multi-surface-delivery.md`
- **Downstream boards:** feature breakdown and architecture planning

## Problem statement
SuitSupply needs recommendation capabilities that can reach multiple customer and operator touchpoints without fragmenting into separate channel-specific products. Ecommerce surfaces need complete-look and attachment recommendations in high-intent shopping moments, email programs need reusable recommendation payloads that can support personalized activation, and clienteling teams need recommendation sets they can trust during stylist-assisted selling. Future API consumers, including mobile or partner experiences, must be able to use the same governed recommendation capability instead of requiring new business logic for each new surface.

Without a shared multi-surface delivery requirement, each surface would define its own output shape, fallback behavior, governance rules, and ranking expectations. That would reduce consistency, increase implementation cost, weaken telemetry continuity, and make it difficult to preserve merchandising control and auditability across channels. The business requirement is therefore to deliver recommendations through a shared, API-first contract with explicit surface-specific expectations and a phased rollout order.

## Target users
### Primary user groups
- ecommerce shoppers on PDP, cart, homepage, and inspiration-led journeys
- returning customers receiving profile-aware recommendations through digital channels
- stylists and clienteling associates retrieving recommendations for assisted selling

### Secondary user groups
- email and CRM teams activating recommendation content in outbound programs
- merchandisers managing campaign priorities, curated looks, and rule boundaries across channels
- product, analytics, and experimentation teams measuring recommendation performance across surfaces
- future internal or external API consumers that need governed recommendation access

## Business value
- increase conversion by making complete-look and attachment recommendations available in the highest-value surfaces first
- increase average order value by extending recommendation reach from onsite commerce to outbound and assisted channels
- reduce duplicated channel-specific business logic by standardizing on a shared delivery contract
- improve operator trust through consistent governance, traceability, and surface-aware fallback behavior
- enable phased channel expansion without redefining recommendation types, identity handling, or telemetry for each consumer

## Recommendation and channel mapping
### Recommendation types in scope
- outfit
- cross-sell
- upsell
- style bundle
- occasion-based
- contextual
- personal

### Consuming surfaces in scope
- ecommerce PDP
- ecommerce cart
- ecommerce homepage and inspiration surfaces
- email and CRM activation surfaces
- clienteling and stylist-assisted surfaces
- future API consumers such as mobile apps, partner experiences, and internal tooling

### Recommendation source expectations
- **Curated:** merchandiser-authored looks and campaign-driven selections remain usable across all surfaces
- **Rule-based:** compatibility, inventory, assortment, and policy controls apply consistently regardless of consumer
- **AI-ranked:** ranking may adapt by surface context, but only within shared governance and contract boundaries

## Shared delivery expectations
The multi-surface capability must preserve a shared delivery foundation even when rendering patterns differ by channel.

### Shared contract expectations
- Recommendation delivery must be API-first so every consuming surface integrates with a governed shared contract.
- The contract must support multiple recommendation types in a way that does not require a separate business definition per surface.
- Responses must use stable canonical identifiers for recommendation set, product, customer when available, look, rule, campaign, experiment, and trace context.
- Recommendation payloads must carry enough metadata for surfaces to render appropriately without recreating decisioning logic locally.
- Contract semantics for eligibility, suppression, fallback, and no-result handling must remain consistent across consumers.
- Recommendation requests must support context inputs such as surface, placement, anchor product, customer identity confidence, market, and occasion when available.
- The system must degrade gracefully when identity, context, or inventory inputs are weak, while still preserving governance and traceability.

### Shared governance expectations
- Merchandising rules, curated look precedence, exclusions, and campaign priorities must remain enforceable across every delivery surface.
- Privacy, consent, and regional policy constraints must apply consistently to personalized delivery regardless of consumer channel.
- Internal teams must be able to audit why a recommendation set was returned, what rules applied, and which surface context was used.
- Surface teams must not bypass shared governance by hardcoding recommendation logic outside the shared delivery contract.

### Shared measurement expectations
- All surfaces must emit a consistent telemetry baseline that supports impression, click or engagement, save where relevant, add-to-cart where relevant, purchase or conversion outcome, dismiss where relevant, and override for operator workflows.
- Outcome events must preserve recommendation set ID, trace ID, surface, placement, recommendation type, and experiment or rule context so cross-surface reporting stays comparable.
- Measurement continuity must allow analytics teams to compare quality, adoption, and business lift by surface without redefining key metrics.

## Surface-specific needs
### Ecommerce surfaces
#### PDP
- Must support anchor-product recommendation delivery with complete-look, cross-sell, and upsell outputs.
- Must prioritize low-latency delivery because recommendation display occurs in-session during product browsing.
- Must return enough product and look metadata for merchandising-safe rendering, product detail linking, and inventory-aware suppression.

#### Cart
- Must support basket-aware attachment opportunities and outfit completion without repeating items already present in the cart.
- Must preserve inventory validity and commercial relevance at checkout-adjacent moments.
- Must support suppression or demotion when cart context makes a recommendation redundant or incompatible.

#### Homepage and inspiration surfaces
- Must support contextual and personal recommendation sets when identity or session context is available.
- Must allow broader discovery-oriented modules than PDP or cart while still using the shared contract.
- Can tolerate more exploratory recommendations than checkout-adjacent placements, but still require clear fallback behavior when personalization confidence is weak.

### Email and CRM surfaces
- Must support recommendation payloads that can be generated ahead of send time or retrieved near send time depending campaign workflow needs.
- Must preserve identity confidence, consent boundaries, and suppression rules for personalized activation.
- Must allow recommendation outputs to be mapped into template-friendly structures without redefining ranking logic in the email platform.
- Must support traceability between delivered recommendation sets and downstream engagement outcomes such as open, click, and purchase attribution.

### Clienteling surfaces
- Must support recommendations for stylist-assisted sessions, including appointment context and known-customer profile signals where permitted.
- Must expose enough explanation and provenance for stylists to trust, tailor, and communicate recommendations during assisted selling.
- Must support manual operator judgment on top of governed recommendations without losing auditability of overrides or shared contract lineage.
- Must account for different interaction patterns than self-service ecommerce, including customer profile review and potentially longer recommendation sessions.

### Future API consumers
- Must be able to use the same delivery primitives without requiring a new recommendation product or a separate rules engine.
- Must integrate through documented contract assumptions, stable identifiers, and explicit capability flags rather than implicit surface-specific behavior.
- Must inherit existing governance, telemetry, and fallback semantics by default.

## Scope boundaries
### In scope
- define the shared delivery expectations that apply across ecommerce, email, clienteling, and future API consumers
- define the minimum surface-specific needs that downstream feature and architecture work must respect
- define phased rollout order for surfaces and the rationale for that sequence
- define contract assumptions that keep channel implementations aligned to a shared API-first model
- define cross-surface governance, telemetry, and fallback expectations

### Out of scope
- detailed API schema design, endpoint definitions, or transport protocol decisions
- final UI layouts or rendering specifications for any specific surface
- channel-specific implementation backlog decomposition
- exact vendor or platform integration mechanics for email, clienteling, or future partner consumers

## RTW / CM considerations
- Phase 1 rollout should prioritize RTW ecommerce surfaces because they provide the fastest path to measurable recommendation value and clearer operational validation.
- Clienteling and future expansion must preserve the ability to support both RTW and CM over time, but CM-specific delivery depth is not a prerequisite for the first multi-surface rollout.
- Any future CM delivery surface must still conform to the same shared contract principles while carrying additional compatibility context as needed.

## Rollout order
### Phase 1: Core ecommerce delivery
- Priority surfaces: PDP and cart
- Rationale: highest-intent journeys, fastest measurable value, strongest alignment with roadmap Phase 1
- Required focus: low-latency delivery, inventory-aware outputs, baseline telemetry, governance-safe rendering support

### Phase 2: Broader ecommerce and email activation
- Priority surfaces: homepage or inspiration placements and personalized email
- Rationale: expand channel reach once shared telemetry, identity handling, and fallback behaviors are dependable
- Required focus: context-aware and personal recommendations, consent-safe activation, cross-surface reporting continuity

### Phase 3: Clienteling and operator scale
- Priority surfaces: stylist-assisted clienteling experiences
- Rationale: add higher-trust assisted workflows after shared contracts and governance have proven dependable in digital channels
- Required focus: operator explainability, override traceability, profile-informed assisted sessions

### Phase 4: Future API consumer expansion
- Priority surfaces: mobile, partner, and other API-driven consumers
- Rationale: reuse the mature shared contract once core digital and operator surfaces validate the delivery model
- Required focus: explicit consumer capability expectations, stable versioning assumptions, inherited governance defaults

## Contract assumptions for downstream work
- Downstream feature and architecture work should assume one shared recommendation domain contract with surface and placement context, not separate recommendation engines per channel.
- Surface-specific presentation concerns should be handled at the integration layer, while recommendation eligibility, ranking provenance, and governance remain centralized.
- Consumers should assume stable identifiers and trace context are mandatory parts of the delivery contract.
- Surfaces should assume shared fallback semantics for empty, weak-confidence, or suppressed results instead of inventing local behaviors.
- Personalization-dependent consumers should assume confidence-aware identity handling and consent enforcement are part of the contract boundary.
- Downstream telemetry design should assume cross-surface comparability is a core requirement, not an optional analytics enhancement.

## Success metrics
- measurable recommendation-driven conversion lift on eligible ecommerce surfaces
- measurable attach-rate and average-order-value lift for cart and PDP recommendation placements
- adoption of shared recommendation contract across initial target surfaces without separate channel-specific decisioning logic
- telemetry continuity across ecommerce, email, and clienteling that supports comparable reporting by surface and recommendation type
- reduction in duplicated delivery logic or one-off channel rule implementations
- operator confidence that recommendation outputs remain governed, explainable, and overrideable across surfaces

## Missing decisions
- Missing decision: exact service-level expectations for each surface, especially low-latency ecommerce requests versus precomputed email workflows.
- Missing decision: how much surface-specific presentation metadata belongs in the shared contract versus consumer-owned mapping layers.
- Missing decision: what minimum recommendation set should be required for homepage and inspiration placements before those surfaces move into active rollout.
- Missing decision: which clienteling workflows are mandatory first, such as appointment prep, in-session styling, or follow-up outreach.
- Missing decision: versioning and backward-compatibility policy for future API consumers.

## Approval / milestone-gate notes
- Approval mode for this BR stage is **AUTO_APPROVE_ALLOWED** per issue context.
- Trigger source is automation-driven issue intake and is recorded explicitly in this artifact.
- No milestone human gate is defined for this BR artifact, but downstream feature and architecture work should preserve the rollout ordering and contract assumptions defined here.
- This branch required creation of the `docs/project/` and `boards/` paths because they were not present on `br/issue-140`; treat that as a repository-seeding assumption rather than a scope change.

## Recommended board update
Add or update `BR-003` in `boards/business-requirements.md` with status `DONE` after branch push. The board note should record that this autonomous run produced the BR artifact, captured shared and surface-specific delivery expectations, and noted non-blocking follow-ups for latency, payload-shape, and versioning decisions.
