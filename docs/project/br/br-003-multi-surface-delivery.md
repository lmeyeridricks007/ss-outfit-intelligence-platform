# BR-003: Multi-surface delivery

## Purpose
Define the business requirements for delivering recommendation outputs across ecommerce, email, clienteling, and future API-driven consumers so downstream feature, architecture, and implementation work can preserve one shared delivery model while honoring each surface's specific business needs.

## Practical usage
Use this artifact to guide feature breakdown for surface enablement, recommendation delivery contract design, channel-specific integration planning, rollout sequencing, fallback behavior, telemetry continuity, and governance expectations for cross-surface recommendation delivery.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #155
- **Board item:** BR-003
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for shared delivery contracts, ecommerce placement enablement, email activation, clienteling delivery, and future API-consumer onboarding

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/goals.md`
- `docs/project/api-standards.md`
- `docs/project/integration-standards.md`
- `docs/project/data-standards.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must deliver recommendation outputs to multiple consuming surfaces without fragmenting the core recommendation logic into channel-specific systems. Ecommerce, email, clienteling, and future API consumers all need recommendations that reflect the same governed business intent, but each surface also has distinct rendering, latency, freshness, explainability, and interaction requirements.

For BR-003, multi-surface delivery means:
- one shared recommendation decisioning capability can serve multiple surfaces
- surface-specific presentation and orchestration may vary without changing core recommendation meaning
- recommendation contracts remain explicit, typed, traceable, and versioned across consumers
- rollout starts with high-intent ecommerce surfaces and expands later to email, clienteling, and future API consumers
- downstream work must preserve contract, telemetry, governance, and fallback consistency across every surface

This business requirement defines the shared delivery expectations, surface-specific needs, rollout order, and contract assumptions needed for downstream feature and architecture work. It does not define final endpoint shapes, UI designs, or infrastructure topology.

## Business problem
SuitSupply needs recommendation delivery to feel consistent across channels while still matching the unique job of each surface. A PDP customer, a cart customer, an email recipient, a clienteling associate, and a future API consumer should all benefit from the same recommendation platform rather than from disconnected channel-specific recommendation stacks.

Without explicit multi-surface delivery requirements:
- each surface team could invent its own request semantics, naming, and fallback behavior
- recommendation meaning could drift between ecommerce, email, and clienteling channels
- telemetry and experimentation would become difficult to compare across consumers
- governance controls could behave differently depending on which channel requested the recommendation
- future API consumers would require rework because the platform was optimized only for the first web placements
- rollout sequencing would become unclear, increasing the risk of over-scoping early phases or under-specifying later channels

## Users and stakeholders
### Primary end users
- **Persona P1: Anchor-product shopper** who expects coherent recommendations on ecommerce PDP and cart surfaces
- **Persona P2: Returning customer** who may later encounter recommendations in email, personalized ecommerce placements, or other owned-channel experiences
- **Persona P3: Occasion-led shopper** who may reach recommendation outputs through inspiration, homepage, or outbound journeys after the initial ecommerce rollout

### Primary operators and stakeholders
- **Persona S2: Merchandiser** who needs the same governed recommendation behavior to carry across multiple channels
- **Persona S1: In-store stylist or clienteling associate** who needs recommendation outputs that can be trusted, interpreted, and adapted during assisted selling
- **Persona S3: Marketing manager** who needs recommendation outputs usable in email and lifecycle programs without breaking governance or attribution
- **Persona S4: Product, analytics, and optimization team member** who needs cross-surface telemetry, traceability, and rollout sequencing that can be measured consistently
- **Future internal or partner API consumers** who need a stable, documented contract rather than bespoke logic negotiated one surface at a time

## Desired outcomes
- Recommendation delivery remains API-first and reusable rather than channel-specific and duplicated.
- Ecommerce, email, clienteling, and future API consumers receive recommendation outputs that preserve shared meaning, identifiers, and governance context.
- Each surface can request and render recommendations appropriate to its user moment without redefining the core recommendation contract.
- Rollout sequencing is explicit, with ecommerce RTW surfaces first and later channels added only after the shared contract proves dependable.
- Telemetry, experimentation, and troubleshooting remain comparable across surfaces.
- Future channels can onboard by adopting the shared contract instead of demanding a new recommendation engine.

## Delivery model principles
### Principle 1: One core recommendation meaning across surfaces
Recommendation sets must preserve the same business meaning regardless of consuming surface. An outfit recommendation delivered to PDP, email, or clienteling may be rendered differently, but it must not become a different recommendation concept merely because the consumer changes.

### Principle 2: API-first delivery
The platform must expose recommendation outputs through shared delivery interfaces so future channels can reuse the same core decisioning and traceability patterns. New surfaces should adapt the shared contract rather than bypass it.

### Principle 3: Surface-specific presentation, shared decisioning
Surface teams may vary layout, copy, pacing, and interaction design, but the underlying recommendation type, identifiers, governance context, and fallback semantics must remain shared.

### Principle 4: Explicit degraded-state behavior
When identity, context, inventory, consent, freshness, or upstream dependencies are weak, the system must expose explicit fallback or degraded-state behavior rather than returning ambiguous or misleading outputs.

### Principle 5: Cross-surface telemetry continuity
Every surface must preserve recommendation set IDs, trace IDs, recommendation type, and channel context strongly enough that performance, experiments, and troubleshooting can be compared across consumers.

### Principle 6: Governance consistency
Merchandising rules, campaign priorities, suppressions, overrides, and explainability expectations must apply consistently across surfaces unless a surface-specific exception is explicitly defined downstream.

### Principle 7: Phase-aware rollout
The platform must optimize first for dependable ecommerce business value, then expand to other surfaces using the same contract and governance foundations.

## Shared delivery expectations
### Shared expectation 1: Stable surface identity
Every recommendation request must identify the consuming context clearly enough that downstream systems can distinguish:
- channel
- surface
- placement or use case
- RTW or CM mode where relevant
- known or anonymous customer state
- anchor product, look, cart, occasion, or campaign context where applicable

### Shared expectation 2: Shared typed recommendation outputs
All consumers must receive typed recommendation sets rather than unlabeled product lists. Surface-specific rendering may differ, but consumers must not need to infer recommendation intent from placement alone.

### Shared expectation 3: Actionable outputs
Recommendation outputs must remain actionable for the surface using them. That may mean browse and add-to-cart for ecommerce, content assembly for email, associate review for clienteling, or machine-readable consumption for future APIs.

### Shared expectation 4: Consistent identifiers and traceability
Per project data standards, every meaningful recommendation delivery must preserve stable canonical IDs, recommendation set IDs, and trace IDs so later events, audits, and support investigations can be linked back to the delivered output.

### Shared expectation 5: Explicit freshness and fallback handling
Consumers must know when recommendations are current, partial, or degraded enough to require safer rendering or suppression. This is especially important for email packaging, clienteling review, and future API consumers that may cache or orchestrate results.

### Shared expectation 6: Consumer-safe contract evolution
Shared delivery contracts must version changes explicitly and favor additive evolution so later channels can onboard without breaking earlier consumers.

## Surface matrix
| Surface | Primary business goal | Required delivery behavior | Surface-specific needs | Earliest rollout phase |
| --- | --- | --- | --- | --- |
| Ecommerce PDP | Help customers complete or improve a look from an anchor product | Interactive, inventory-valid, anchor-aware recommendations with clear recommendation type and shopping actions | Fast response, anchor preservation, grouped look rendering where needed, traceable telemetry | Phase 1 |
| Ecommerce cart | Increase basket completion and attachment | Recommendations informed by current cart state, duplicate avoidance, explicit fallback when cart context is weak | Cart-state awareness, substitution boundaries, strong add-to-cart usability | Phase 1 |
| Expanded ecommerce placements | Extend relevance into homepage, inspiration, or occasion-led surfaces | Same shared contract with different placement intent and stronger context or profile use | Broader context inputs, placement-level experimentation, identity-safe fallback | Phase 2 |
| Email | Reuse recommendations in outbound or lifecycle programs | Recommendation outputs that preserve type, freshness handling, campaign attribution, and suppression-safe behavior | Packaging for send windows, stale-data safeguards, consent and identity checks, measurement continuity | Phase 2 |
| Clienteling | Support assisted selling by stylists or associates | Trustworthy, interpretable recommendation sets with enough trace context for human adaptation | Authenticated access, appointment or profile context, operator explanation needs, shareable output | Phase 3 |
| Future API consumers | Let new channels or internal products onboard quickly | Stable, versioned, machine-readable recommendation contract with explicit degraded states | Clear onboarding contract, versioning, auth boundaries, consumer-owned presentation logic | Phase 3 and beyond |

## Surface-specific requirements
### Ecommerce PDP
The PDP is the highest-priority surface for initial delivery because it represents a high-intent moment where customers want help answering "what goes with this?"

PDP delivery must:
- support anchor-product-driven recommendation requests
- preserve recommendation type and grouped recommendation-set meaning
- return inventory-valid and operationally safe products
- support immediate shopping actions without forcing the customer into another channel
- carry recommendation set ID, trace ID, and placement context into telemetry

PDP delivery must not:
- flatten complete-look recommendations into indistinguishable similar-item lists
- hide degraded-state behavior when product, inventory, or context quality is weak
- require channel-specific logic that rewrites core recommendation meaning

### Ecommerce cart
Cart delivery serves a narrower but highly commercial use case: complete the outfit, extend the basket, or suggest credible upgrades without disrupting what is already in cart.

Cart delivery must:
- accept current basket context as a first-class request input
- avoid recommending exact duplicates unless substitution is the explicit recommendation intent
- preserve typed recommendation behavior for outfit completion, cross-sell, or upsell use cases
- remain explicit when cart state is insufficient and a safer fallback is used
- keep measurement continuity with add-to-cart and purchase outcomes

### Expanded ecommerce surfaces
Homepage, inspiration, and occasion-led surfaces matter for later expansion but should not force the Phase 1 contract to overfit early placements. These surfaces should still use the shared contract once identity, context, and telemetry foundations are dependable.

Expanded ecommerce delivery must:
- support placement-specific context without fragmenting the contract
- preserve explicit recommendation type and recommendation-set identity
- respect identity confidence and consent boundaries before strong personalization appears
- allow richer surface storytelling without requiring a separate recommendation taxonomy

### Email
Email is a later-phase consumer because it depends on stronger identity, freshness, suppression, and attribution handling than Phase 1 ecommerce placements.

Email delivery must:
- preserve recommendation type, recommendation set ID, trace ID, and campaign linkage
- support a freshness-aware packaging model so outdated or invalid products are not sent silently
- respect consent, suppression, and permitted-use boundaries before personalization is applied
- fall back safely when profile, inventory, or product freshness is weak for the send context
- remain attributable so downstream teams can compare email outcomes with web or clienteling outcomes

Email delivery must not:
- depend on hidden channel-specific ranking logic that diverges from the shared platform
- expose customer-sensitive explanation detail in outbound content
- treat stale recommendations as equivalent to fresh interactive results

### Clienteling
Clienteling is a later-phase delivery surface because the output must be trustworthy for assisted selling and interpretable enough for associates to adapt confidently.

Clienteling delivery must:
- support authenticated, role-appropriate access
- accept customer, appointment, stylist, or anchor context where available
- preserve enough trace and explanation context for operator understanding
- support recommendation outputs that can be reviewed, adapted, and shared during assisted selling
- keep governance, override, and recommendation-type behavior aligned with the shared platform

Clienteling delivery must not:
- expose internal raw trace or sensitive profile reasoning beyond role-appropriate boundaries
- require stylists to infer recommendation intent from disconnected product lists
- become a special-case recommendation engine separate from the shared platform

### Future API consumers
Future channels, internal products, or partner-owned experiences should be able to onboard by consuming the shared recommendation contract rather than requesting a one-off delivery format.

Future API-consumer delivery must:
- provide explicit versioning and consumer-safe contract evolution
- keep recommendation types, identifiers, and fallback semantics stable
- document auth, authorization, and error expectations clearly
- expose machine-readable degraded-state indicators and partial-result conditions
- let consumers own presentation details while reusing the same recommendation meaning and telemetry linkage

## Shared contract assumptions for downstream work
This BR does not define the final endpoint schema, but downstream feature and architecture work must assume the shared contract preserves at least the following business concepts:

| Contract area | Required business assumption |
| --- | --- |
| Request identity | Requests identify consumer channel, surface, placement, and relevant journey context such as product, cart, occasion, or campaign |
| Customer state | Requests distinguish known, anonymous, low-confidence, or suppressed customer states rather than pretending all personalization contexts are equal |
| Recommendation meaning | Responses preserve explicit recommendation type and recommendation-set boundaries |
| Stable identifiers | Responses preserve recommendation set ID, trace ID, and canonical entity IDs needed for telemetry and auditability |
| Grouped outputs | The contract can represent grouped looks or multi-item recommendation sets where needed, not only flat item lists |
| Source visibility category | The contract preserves whether the result is curated, rule-based, AI-ranked, mixed-source, or degraded fallback at a business-readable level |
| Fallback status | The contract indicates partial, degraded, stale, empty, or suppressed outcomes explicitly |
| Surface safety | The contract provides enough metadata for the consumer to render, suppress, or defer display safely |
| Experiment linkage | Responses can be linked to experiment and variant context where applicable |
| Rule and governance linkage | Responses can be connected to business rules, campaigns, suppressions, and overrides for audit and troubleshooting |
| Freshness | Consumers can determine whether the recommendation data is fresh enough for their interaction model |
| Error handling | Errors and degraded results remain structured and correlation-friendly without leaking sensitive internals |

### Additional contract expectations
- The contract must support additive versioning so new surfaces do not break older consumers.
- Consumers must not need custom type names or channel-specific identifier schemes.
- Surface-specific hints may exist, but they must not replace the shared recommendation meaning.
- Trace IDs must flow through request, response, and telemetry paths wherever practical.
- Degraded or partial results must be distinguishable from successful full recommendations.

## Cross-surface governance and measurement requirements
### Governance consistency
All surfaces must remain subject to the same governed recommendation boundaries:
- merchandising rules
- curated look precedence where applicable
- campaign priorities
- exclusions and suppressions
- override and audit expectations
- privacy and consent boundaries

If a later surface needs an exception, that exception must be explicit and auditable rather than hidden inside channel-specific logic.

### Measurement consistency
All surfaces must support recommendation telemetry strongly enough to preserve, where applicable:
- event timestamp
- channel and surface
- anchor product ID or look ID
- recommendation set ID
- trace ID
- recommendation type
- experiment and variant context
- rule or governance context

### Explainability and support continuity
Operators must be able to trace a delivered recommendation set back to its source and governance context even when that set appeared in different surfaces. Email, ecommerce, clienteling, and future API consumers must not each invent incompatible support models.

## Rollout sequencing
### Phase 1: Core ecommerce RTW delivery
In scope first:
- ecommerce PDP delivery
- ecommerce cart delivery
- shared recommendation contract foundations needed for interactive web use
- recommendation set identifiers, traceability, fallback signaling, and telemetry continuity

Phase 1 business intent:
- prove measurable value on high-intent ecommerce surfaces
- validate that shared contract assumptions hold under interactive delivery
- avoid over-scoping later surfaces before core delivery quality is dependable

Phase 1 boundaries:
- no requirement to productionize email or clienteling delivery yet
- future API-consumer onboarding is not blocked conceptually, but broad enablement is not the first success milestone
- context-heavy, profile-heavy, or outbound-specific delivery needs should not redefine the initial contract prematurely

### Phase 2: Expanded ecommerce and email activation
Add next:
- homepage or inspiration-style ecommerce placements
- occasion-led or profile-aware ecommerce delivery where supporting dependencies are ready
- email activation using the shared contract

Phase 2 prerequisites:
- dependable Phase 1 telemetry
- clear identity-confidence and consent handling
- freshness-safe packaging for non-interactive delivery
- explicit fallback behavior for weaker profile or inventory conditions

### Phase 3: Clienteling and broader API reuse
Add next:
- clienteling delivery
- stronger operator-facing explanation and troubleshooting support for surfaced recommendations
- selected future API consumers that can adopt the shared contract safely

Phase 3 emphasis:
- human-in-the-loop trust
- authenticated access and role-aware explanation depth
- broader cross-surface measurement and governance consistency

### Phase 4: Further API-consumer expansion and deeper mode coverage
Expand toward:
- broader future channel and API-consumer onboarding
- deeper CM-aware or premium-context delivery needs
- more advanced cross-surface optimization once earlier surfaces are stable

## Scope boundaries
### In scope
- shared delivery expectations across ecommerce, email, clienteling, and future API consumers
- surface-specific business needs that downstream work must preserve
- rollout order tied to the project roadmap
- contract assumptions for request context, identifiers, fallback handling, and telemetry continuity
- governance and measurement expectations that apply across surfaces

### Out of scope
- final API path design, payload fields, or transport selection
- final UI layouts, visual treatment, or channel copy
- exact latency budgets, cache design, or infrastructure topology
- implementation tickets for each surface team
- final commercial thresholds for when each placement or channel launches in each market

## Dependencies
- `BR-001` complete-look recommendation capability for grouped recommendation-set behavior and anchor-product journeys
- `BR-002` multi-type recommendation support for typed outputs across different surfaces
- `BR-004` RTW and CM support for phase boundaries and later CM-aware delivery differences
- `BR-005` curated plus AI recommendation model for source blending and governance-safe ranking behavior
- `BR-006` customer signal usage for identity-aware and consent-safe delivery expansion
- `BR-007` context-aware logic for later contextual, occasion-led, and market-aware surfaces
- `BR-008` product and inventory awareness for operationally valid delivery across channels
- `BR-009` merchandising governance for cross-surface rule, campaign, and override consistency
- `BR-010` analytics and experimentation for cross-surface telemetry and attribution continuity
- `BR-011` explainability and auditability for traceability, operator review, and support workflows
- `BR-012` identity and profile foundation for email, clienteling, and later personalized surface expansion

## Constraints
- Shared delivery must not collapse into channel-specific recommendation engines.
- Surface-specific rendering flexibility must not break typed recommendation meaning, identifiers, or governance context.
- Outbound and assisted-selling delivery must respect consent, privacy, and role boundaries more strictly than anonymous web delivery, not less.
- Early rollout must favor dependable ecommerce value over premature channel breadth.
- Future API consumers must be able to onboard through versioned contracts rather than undocumented one-off integrations.

## Assumptions
- Ecommerce, email, and clienteling teams can consume a shared recommendation contract even if their rendering patterns differ.
- Canonical IDs, recommendation set IDs, and trace IDs can flow through delivery and telemetry paths across surfaces.
- Later-phase channels such as email and clienteling can adopt the same core recommendation types rather than redefining recommendation meaning.
- The roadmap sequence in `docs/project/roadmap.md` remains the baseline for when new surfaces expand.
- Surface teams can implement consumer-specific presentation choices without forcing separate core recommendation logic.

## Missing decisions
- Missing decision: which homepage, inspiration, or occasion-led ecommerce placements are mandatory in the first expansion beyond PDP and cart.
- Missing decision: what freshness threshold makes an email recommendation package too stale to send without regeneration or suppression.
- Missing decision: how much internal explanation detail clienteling users need in the first rollout versus later operator tooling phases.
- Missing decision: which future API consumers are expected first after clienteling and whether any require stricter contract or authentication guarantees.
- Missing decision: whether certain campaign-led email or merchandising scenarios need explicit surface-level exceptions to default recommendation fallback behavior.

## Downstream implications
- Feature breakdown work must separate shared delivery-contract capabilities from surface-specific integration capabilities.
- Architecture work must represent recommendation delivery as a reusable contract layer with explicit degraded-state, traceability, and versioning behavior.
- Ecommerce feature work must preserve typed recommendation-set behavior, trace continuity, and surface-safe fallback handling from Phase 1 onward.
- Email feature work must define freshness, suppression, and attribution behavior without inventing a separate recommendation taxonomy.
- Clienteling feature work must preserve operator explanation needs and authenticated delivery boundaries while reusing the shared contract.
- Future API-consumer onboarding work must treat contract stability, auth boundaries, and additive versioning as first-class requirements.

## Review snapshot
Trigger: issue-created automation from GitHub issue #155.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the business requirements, product overview, goals, roadmap, and platform standards provide enough context to define the shared delivery model, surface-specific expectations, rollout order, and contract assumptions without inventing implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before locking broader surface rollout and final contract details.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-003 to `Pushed` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence.
