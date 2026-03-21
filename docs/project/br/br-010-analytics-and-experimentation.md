# BR-010: Analytics and experimentation

## Purpose
Define the business requirements for recommendation telemetry, attribution continuity, experiment support, reporting expectations, and optimization success measures so downstream feature, architecture, and implementation work can measure recommendation value reliably and improve the platform without weakening governance, privacy, or brand coherence.

## Practical usage
Use this artifact to guide feature breakdown for telemetry contracts, experiment design, attribution handling, reporting definitions, operator dashboards, optimization review workflows, and analytics dependencies across ecommerce, email, clienteling, and future recommendation-consuming surfaces.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #147
- **Board item:** BR-010
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for telemetry contracts, attribution and reporting models, experimentation workflows, optimization review routines, and analytics-governance handling

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/goals.md`
- `docs/project/roadmap.md`
- `docs/project/data-standards.md`
- `docs/project/architecture-overview.md`
- `docs/project/product-overview.md`
- `docs/project/glossary.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must provide a trustworthy analytics and experimentation foundation that allows SuitSupply to understand how recommendation behavior performs, attribute downstream outcomes to recommendation exposure, and improve recommendation quality through controlled experimentation rather than intuition alone.

For BR-010, analytics and experimentation means the platform must make all of the following available across recommendation-consuming surfaces:
- **consistent recommendation telemetry**
- **attribution continuity from impression to outcome**
- **stable experiment and variant hooks**
- **reporting that separates source, type, surface, and governance effects**
- **optimization measures that balance commercial value, customer usefulness, and operator trust**
- **auditable linkage between delivered recommendation sets and later business outcomes**

The analytics layer must answer all of the following for meaningful recommendation activity:
- what recommendation set was delivered
- where and when it was delivered
- which recommendation type and source mix were present
- which customer or session context was known at delivery time
- which experiment and variant, if any, influenced behavior
- what the customer or operator did next
- whether later outcomes can be attributed to that recommendation set with stated confidence
- whether performance changes came from experimentation, governance changes, catalog shifts, or unrelated traffic changes

Analytics and experimentation are therefore production requirements, not post-launch nice-to-have instrumentation.

## Business problem
SuitSupply needs recommendation performance to be measurable and improvable from the first production rollout. The platform cannot responsibly optimize complete-look, cross-sell, upsell, contextual, or personal recommendations if teams cannot tell whether a recommendation was seen, whether it influenced behavior, or whether a reported uplift came from a recommendation change versus a campaign, rule update, or traffic mix shift.

Without explicit analytics and experimentation requirements:
- recommendation performance may be judged from incomplete click data rather than full impression-to-outcome behavior
- ecommerce, email, and clienteling surfaces may instrument different event shapes and make cross-surface reporting unreliable
- experiments may be launched without variant persistence or attribution continuity, creating misleading lift claims
- curated, rule-based, and AI-ranked influences may be blended together in reporting so operators cannot see what actually changed
- optimization may reward shallow click-through improvements that reduce outfit quality, margin, governance compliance, or brand coherence
- merchandising overrides, campaigns, or emergency controls may materially affect results without being visible in experiment or reporting views
- downstream teams may guess at attribution windows, event identity, or success measures and create incompatible implementations

## Users and stakeholders
### Primary customer-facing beneficiaries
- **Persona P1: Anchor-product shopper** who benefits when recommendation quality is measured beyond clicks so complete-look modules keep improving
- **Persona P2: Returning customer** who benefits when personalized recommendations are optimized through trustworthy telemetry rather than overfit assumptions
- **Persona P3: Occasion-led shopper** who benefits when context-aware recommendation changes are evaluated against actual outfit relevance and conversion outcomes

### Primary operators
- **Persona S2: Merchandiser** who needs reporting that separates campaign, curated, and baseline recommendation effects so control changes can be evaluated responsibly
- **Persona S1: In-store stylist or clienteling associate** who needs confidence that recommendation changes are measured consistently across assisted and self-service contexts
- **Persona S4: Product, analytics, and optimization team member** who needs experiment hooks, attribution continuity, and outcome dashboards to guide prioritization and optimization decisions
- **Marketing and CRM operators** who need recommendation exposure and downstream outcome data that can be compared across onsite and outbound channels without inventing their own measurement logic

## Desired outcomes
- Every recommendation-consuming surface emits a consistent minimum telemetry set tied to recommendation set IDs and trace IDs.
- Recommendation outcomes can be analyzed from impression through click, save, add-to-cart, purchase, dismiss, and override behavior rather than from isolated interaction events.
- Experiments can be run with explicit population, variant, and exposure handling so reported lift is defensible.
- Reporting can separate performance by recommendation type, surface, channel, source mix, campaign context, rule context, and experiment context.
- Attribution logic remains continuous enough that downstream teams can connect delayed outcomes back to the recommendation set that likely influenced them.
- Optimization decisions reward commercial and customer-value improvements without encouraging recommendation spam, misleading impressions, or brand-incoherent ranking.
- Merchandising, governance, and experimentation changes can be analyzed together rather than producing conflicting local dashboards.

## Analytics and experimentation scope
This BR defines the business semantics for measuring recommendation behavior, attributing downstream outcomes, structuring experiment support, and reporting business value.

For BR-010, analytics and experimentation includes:
- recommendation event taxonomy and minimum required events
- event identity and trace linkage expectations
- exposure, interaction, and downstream-outcome continuity
- experiment enrollment, variant, and holdout visibility
- reporting dimensions, aggregates, and comparison expectations
- optimization success measures and guardrails
- measurement visibility for curated, rule-based, AI-ranked, and overridden recommendation behavior
- privacy-aware handling of customer, anonymous-session, and cross-surface attribution context

This BR does not define:
- final warehouse schema or analytics-tool vendor selection
- final statistical methods, significance thresholds, or experiment-analysis package
- final dashboard layouts or BI tool implementation
- final API payload details beyond the required business semantics they must preserve
- exact organizational ownership split between product analytics, data engineering, and experimentation platform teams

## Telemetry foundation requirements
### Required event families
The platform must preserve a minimum recommendation telemetry foundation across all supported surfaces. At minimum, downstream systems must support these event families where applicable:
- **impression**
- **click**
- **save**
- **add-to-cart**
- **purchase**
- **dismiss**
- **override**

The event model must treat these as business-distinct signals rather than one generic interaction stream because each signal answers a different optimization question:
- **impression** confirms exposure opportunity
- **click** confirms immediate engagement
- **save** indicates deferred intent or stylistic interest
- **add-to-cart** indicates stronger shopping progression
- **purchase** indicates realized business value
- **dismiss** indicates explicit negative feedback or irrelevance
- **override** indicates operator or governance intervention that materially changes the baseline recommendation outcome

### Minimum event context
Per `docs/project/data-standards.md`, every recommendation event must preserve enough context to make analysis and attribution consistent. At minimum, the measurement model must support:
- event timestamp
- canonical customer ID where known, otherwise anonymous or session identifier
- surface and channel
- anchor product ID or look ID where relevant
- recommendation set ID
- trace ID
- recommendation type
- experiment and variant context
- rule context

For BR-010, the business requirement extends that baseline so reporting can also preserve, where applicable:
- recommendation item ID and position within the set
- curated, rule-based, or AI-ranked source contribution context
- campaign ID and campaign priority context
- override or suppression context
- RTW or CM mode
- market or country
- identity-confidence indicator where customer resolution is uncertain

### Event completeness expectations
Telemetry must not be considered production-ready if it only captures successful clicks or purchases. The platform must be able to answer all of the following:
- how many recommendation modules were actually rendered
- how many items within those modules were visible or eligible for interaction
- which exposures produced no engagement
- which interactions failed to progress to cart or purchase
- which recommendations were dismissed or suppressed
- which outputs were changed by operator override or emergency governance behavior

Recommendation analytics must therefore preserve negative and null-result visibility, not only positive interactions.

## Attribution continuity requirements
### Core attribution principle
Recommendation outcomes often happen after the original impression and may span multiple page views, devices, or channels. The platform must therefore preserve attribution continuity strongly enough that downstream teams can connect later behavior to the recommendation set that plausibly influenced it rather than losing all context after the first interaction.

### Required attribution continuity
Downstream implementations must preserve continuity across at least:
- impression to click
- impression to add-to-cart
- impression to purchase
- click to later add-to-cart or purchase
- recommendation exposure to later email or clienteling follow-up analysis where source context is retained
- operator override or governance change to subsequent performance shifts

Attribution continuity must remain possible even when:
- customer identity is not yet known at impression time
- multiple recommendation types are shown in one response
- the same product appears in more than one module or surface
- outcomes occur after a delay rather than in the same session
- a recommendation set mixes curated, rule-based, and AI-ranked contributions

### Attribution identity expectations
The platform must support attribution using stable identifiers rather than brittle page-local context. At minimum:
- recommendation set IDs and trace IDs must persist into downstream interaction and outcome paths
- product IDs, look IDs, campaign IDs, rule IDs, and experiment IDs must remain stable
- customer identity mappings must preserve confidence when multiple source identities are merged
- anonymous sessions must still preserve enough continuity to support pre-login attribution and later identity stitching where permitted

### Attribution quality boundaries
Reporting must not overstate certainty. When attribution is partial, delayed, or low confidence, the system must preserve that distinction rather than presenting all outcomes as equally certain. The business requirement is not perfect omniscience; it is honest, auditable continuity with confidence-aware interpretation.

## Experimentation requirements
### Experiment support principle
The platform must support controlled experimentation so recommendation changes can be evaluated through disciplined comparison rather than anecdotal observation or one-off snapshots.

### Required experiment hooks
The recommendation stack must support business-visible experiment context for:
- recommendation strategy comparisons
- ranking-policy or source-mix comparisons
- surface-layout or module-order comparisons when recommendation logic is affected
- campaign versus baseline recommendation behavior
- holdout or reduced-treatment groups for incremental-lift measurement
- context-aware and personal recommendation expansions in later phases

At minimum, experiment handling must preserve:
- stable experiment ID
- stable variant ID
- assignment or enrollment timing
- exposure visibility by recommendation set
- holdout or control designation where applicable
- linkage to downstream events and outcomes

### Experiment boundary rules
Experiments must not operate outside governance, consent, or policy boundaries. Therefore:
- hard eligibility, privacy, and governance constraints must outrank experiment intent
- experiment variants must remain visible in reporting and trace context
- experiment treatment must not silently bypass merchandising rules, suppressions, or premium-context restrictions
- experiments that affect recommendation behavior must be distinguishable from unrelated site experiments in reporting

### Required experiment comparability
Experiment reporting must support comparison at least by:
- recommendation type
- surface and channel
- market or region
- RTW or CM mode where relevant
- customer-known versus anonymous cohorts
- curated, rule-based, AI-ranked, or mixed-source recommendation behavior
- campaign-influenced versus baseline behavior

### Holdout and baseline expectations
The platform must support some business-safe baseline or holdout comparison path for material optimization changes. Not every recommendation change requires a new experiment, but the business must be able to measure incremental value rather than only reporting absolute outcome counts.

## Reporting requirements
### Required reporting perspectives
Reporting must allow teams to answer questions from multiple viewpoints rather than one aggregate dashboard. At minimum, downstream reporting must support:

| Reporting perspective | Business question it answers | Minimum required dimensions |
| --- | --- | --- |
| Exposure health | Are recommendation modules actually being shown and seen? | surface, channel, recommendation type, module placement, market |
| Engagement quality | Are customers interacting with recommendations? | impression, click, save, dismiss, item position, source mix |
| Commerce impact | Do recommendations influence cart and purchase outcomes? | add-to-cart, purchase, revenue, units, attach rate, AOV impact |
| Outfit completion quality | Are complete-look and cross-category recommendations creating coherent basket expansion? | anchor category, attached categories, outfit completion rate, basket mix |
| Experiment performance | Did a variant outperform baseline or holdout? | experiment, variant, surface, type, segment, governance context |
| Governance and operator impact | Did campaigns, overrides, suppressions, or curated controls change results? | campaign ID, rule context, override context, curated influence |
| Channel comparison | How do ecommerce, email, and clienteling recommendation outcomes differ? | channel, surface, customer state, latency to outcome |
| Optimization guardrails | Did lift come at the cost of lower trust or weaker recommendation quality? | dismiss rate, override rate, low-confidence attribution rate, outlier behavior indicators |

### Reporting slices that must be possible
Reporting must be able to segment performance by:
- recommendation type
- surface and channel
- campaign and non-campaign periods
- experiment and variant
- market, country, and season where relevant
- anchor product category and look family
- customer-known, anonymous, and confidence-limited identity states
- curated, rule-based, AI-ranked, and mixed-source outputs
- governance context such as override, suppression, or pinned behavior
- RTW versus CM mode where applicable

### Reporting consistency requirement
Different teams may consume different dashboards, but the underlying definitions for impressions, clicks, attributed outcomes, and experiment exposure must remain consistent. Local reporting convenience must not create multiple conflicting definitions of recommendation success.

## Optimization success measures
### Primary success measures
The platform must support optimization against business and product outcomes, not only engagement proxies. At minimum, BR-010 requires reporting and experiment analysis to support:
- conversion uplift on eligible recommendation surfaces
- average order value uplift
- attach-rate improvement across relevant categories
- complete-look or outfit completion uptake
- click-through and add-to-cart progression from exposed recommendation sets
- repeat engagement with recommendation-driven experiences where relevant

### Guardrail measures
Optimization must not treat every increase in clicks as positive. The analytics foundation must also support guardrails such as:
- dismiss-rate increase
- override-rate increase
- recommendation-set performance degradation after campaign or rule changes
- reduced relevance or increased low-confidence attribution
- signals that recommendation outcomes are being concentrated in a narrow or repetitive assortment
- evidence that one surface improved by shifting value away from another surface rather than creating net value

### Success-measure interpretation rules
- Success metrics must be interpretable by recommendation type and surface, not only as one blended platform average.
- Reporting must distinguish commercial uplift from operational side effects caused by stronger campaign pressure, suppressions, or governance interventions.
- Optimization decisions should favor durable business value and customer usefulness over short-lived interaction spikes.
- Phase 1 prioritizes dependable exposure, attribution, and baseline measurement quality before more advanced multi-touch optimization claims.

## Measurement of source and governance effects
### Source attribution in reporting
Because the product intentionally blends curated, rule-based, and AI-ranked recommendation sources, analytics must support visibility into source influence. Downstream analysis must be able to distinguish at least:
- fully curated outputs
- curated outputs reordered or completed by AI-ranked logic
- rule-based safe fallbacks
- predominantly AI-ranked outputs within governed bounds
- outputs materially changed by campaigns, pins, suppressions, or overrides

### Governance-aware measurement
Reporting must support analysis of:
- campaign influence on recommendation outcomes
- override frequency and business impact
- emergency-control usage and resulting performance shifts
- suppression or exclusion effects on recommendation availability
- differences between baseline governed behavior and experiment-driven behavior

Optimization reporting must therefore show not only whether performance changed, but also what business-control context changed with it.

## Cross-surface and cross-mode implications
### Ecommerce PDP and cart
- Phase 1 reporting must prioritize PDP and cart because these are the earliest high-intent RTW surfaces in scope.
- Impression, click, add-to-cart, purchase, and attach-rate continuity must be dependable enough to judge direct commercial impact.
- Recommendation reporting must distinguish complete-look modules from narrower cross-sell or upsell modules on the same surface.

### Homepage, inspiration, and occasion-led experiences
- Reporting must support broader engagement and downstream conversion analysis because the path from exposure to purchase may be less immediate than on PDP or cart.
- Experimentation must separate context and ranking effects from merchandising or seasonal campaign effects.

### Email and lifecycle marketing
- Measurement must support delayed outcome analysis because recommendation generation, send time, open time, click time, and purchase time may all differ.
- Recommendation reporting must remain consistent with onsite measurement so teams can compare channel effectiveness without redefining exposure semantics.

### Clienteling and assisted selling
- Reporting must distinguish customer action from operator-assisted action where possible.
- Experimentation in stylist-assisted contexts must remain visible and governed rather than hidden inside local tooling changes.

### RTW and CM
- Phase 1 focuses on RTW measurement quality.
- CM and premium scenarios may later require stricter interpretation because purchase journeys and assisted selling patterns differ from standard RTW ecommerce flows.

## Phase and rollout expectations
### Phase 1: Core ecommerce RTW measurement foundation
Phase 1 should establish:
- impression-to-outcome telemetry on PDP and cart
- recommendation set ID and trace ID continuity
- event context for recommendation type, surface, and experiment exposure
- reporting for commercial, engagement, and attach-rate outcomes
- baseline experiment hooks and holdout support for recommendation changes
- visibility into curated, rule-based, AI-ranked, and governance-influenced behavior

### Phase 2: Context and personalization expansion
Analytics must expand to:
- compare context-aware and personal recommendation outcomes against Phase 1 baselines
- support stronger identity-aware attribution where confidence permits
- measure incremental value from occasion, location, weather, and profile-aware recommendation changes

### Phase 3: Operator scale and channel expansion
Analytics should expand to:
- support cross-channel reporting for email and clienteling
- compare campaign and governance effects across surfaces
- expose richer operator-facing reporting for override, suppression, and experiment review

### Phase 4: CM depth and advanced optimization
Later work should:
- support CM-specific and premium-context recommendation analysis
- allow more advanced optimization only after attribution continuity and governance visibility are proven dependable

## Scope boundaries
### In scope
- business definitions for recommendation telemetry and outcome measurement
- attribution continuity requirements
- experiment hook and comparison expectations
- reporting perspectives, slices, and consistency rules
- optimization success measures and guardrails
- governance-aware analytics requirements

### Out of scope
- final experimentation platform implementation
- final statistical significance framework
- final dashboard UX
- final data warehouse modeling choices
- final event transport or storage technology

## Dependencies
- `BR-001` complete-look recommendation capability for the customer-facing behaviors and outfit outcomes that measurement must evaluate
- `BR-002` multi-type recommendation support for type-level telemetry, reporting, and experiment comparison
- `BR-003` multi-surface delivery for cross-surface instrumentation consistency and reporting comparability
- `BR-004` RTW and CM support for mode-specific measurement boundaries and later CM reporting differences
- `BR-005` curated plus AI recommendation model for source-mix analysis and experiment comparison of curated, rule-based, and AI-ranked behavior
- `BR-006` customer signal usage for identity-aware attribution, privacy-safe personalization measurement, and outcome analysis
- `BR-007` context-aware logic for evaluating weather-, season-, location-, and occasion-driven recommendation changes
- `BR-008` product and inventory awareness for interpreting recommendation availability, attach outcomes, and invalid-output suppression
- `BR-009` merchandising governance for measuring campaign, override, suppression, and control-driven effects
- `BR-011` explainability and auditability for connecting analytics outputs to trace context and recommendation-decision reconstruction
- `BR-012` identity and profile foundation for confidence-aware customer mapping and cross-channel attribution continuity

## Constraints
- Recommendation analytics must remain privacy-safe and consent-aware across regions and channels.
- Measurement definitions must stay consistent across surfaces even when rendering implementations differ.
- Attribution claims must not imply certainty beyond the continuity and confidence actually preserved.
- Experimentation must remain inside governance and policy boundaries rather than bypassing them in pursuit of lift.
- Phase 1 should optimize for trustworthy telemetry coverage and business interpretability before advanced causal modeling.

## Assumptions
- Downstream delivery paths can carry recommendation set IDs, trace IDs, and experiment context through interaction and outcome events.
- Ecommerce Phase 1 surfaces can emit the minimum telemetry event set reliably enough to support baseline reporting and experimentation.
- Existing commerce, marketing, and analytics systems can preserve or ingest recommendation-context metadata without redefining the business event semantics.
- Teams are willing to treat recommendation reporting definitions as shared platform standards rather than channel-local conventions.
- Some attribution outcomes will remain partial or delayed, and the organization accepts confidence-aware reporting rather than demanding false precision.

## Missing decisions
- Missing decision: what attribution window or set of windows should be treated as the canonical default for recommendation purchase influence by surface and channel.
- Missing decision: what experiment unit should be primary for major recommendation tests in Phase 1 and Phase 2, such as session, customer, request, or surface module.
- Missing decision: what baseline or holdout policy is required before high-impact ranking changes can be promoted broadly.
- Missing decision: which reporting metrics are mandatory for executive review versus operator workflow review.
- Missing decision: how recommendation attribution should be handled when the same product is exposed across multiple recommendation sets and channels before purchase.

## Downstream implications
- Feature breakdown work must define the telemetry contract so all required event families, event context, and attribution linkage are preserved across surfaces.
- Architecture work must preserve recommendation set ID, trace ID, experiment context, and governance context through delivery and event pipelines.
- Analytics and experimentation workflows must define consistent reporting dimensions and success metrics before teams create local dashboards.
- Delivery work must expose enough metadata that downstream systems can distinguish recommendation type, source mix, campaign influence, and variant context.
- Governance and optimization reviews must use shared reporting so campaign or override effects are not mistaken for model or ranking improvements.

## Review snapshot
Trigger: issue-created automation from GitHub issue #147.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, goals, roadmap, data standards, architecture overview, product overview, glossary, and adjacent BR artifacts provide enough context to define recommendation telemetry, attribution continuity, experiment support, reporting expectations, and optimization measures without inventing final tooling or statistical implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before finalizing attribution windows, primary experiment units, holdout policy, and multi-touch recommendation attribution rules.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-010 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for attribution-window policy, experiment-governance standards, and cross-channel multi-touch attribution interpretation.
