# BR-010: Analytics and experimentation

## Traceability

- **Board item:** BR-010
- **GitHub issue:** #117
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #117 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/roadmap.md`
- **Related inputs:** recommendation telemetry, success metrics, experiment hooks, impression and outcome events, and reporting expectations
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs an analytics and experimentation foundation that makes recommendation performance measurable, comparable, and safe to optimize. The platform must define which recommendation events are required, what attribution context must travel with those events, which success metrics matter by surface and recommendation type, how experiments can change recommendation behavior without bypassing governance, and what reporting views internal teams need to improve complete-look outcomes over time.

This business requirement defines:

- the minimum telemetry required to evaluate recommendation usefulness and commercial influence
- the shared attribution context that must connect recommendation impressions to downstream outcomes
- the experimentation hooks and guardrails needed to test ranking, source-blend, and presentation choices responsibly
- the reporting expectations for product, analytics, merchandising, and operational teams
- the success metrics and interpretation rules that determine whether recommendation optimization is helping

This BR does not define:

- the final event-streaming, warehouse, or dashboard vendor implementation
- the exact statistical method, traffic-allocation algorithm, or experimentation platform design
- channel-specific UI instrumentation code
- the detailed schema registry, storage partitions, or service-level ownership model
- business approval workflows for every future experiment or report consumer

## 2. Problem and opportunity

Recommendation capability creates business value only when its influence can be measured. Without clear telemetry, teams may know that recommendations were shown but not whether they improved attachment, conversion, or complete-look usefulness. Without shared attribution, different surfaces may report success inconsistently. Without experimentation hooks, the platform can ship recommendation logic but remain unable to prove whether curated, rule-based, or AI-ranked changes are actually improving outcomes.

The business problem is therefore broader than event logging alone:

- impression and outcome events need to remain connected through stable recommendation identifiers
- recommendation performance needs to be comparable across PDP, cart, future homepage, email, and clienteling consumers
- optimization teams need to test ranking and presentation changes without bypassing compatibility, merchandising, consent, or brand constraints
- internal teams need reporting views that separate commercial uplift from telemetry gaps, operational failures, or governance changes
- Phase 1 needs a measurement baseline strong enough to support later personalization, context, and multi-channel expansion

The opportunity is to establish a measurement and experimentation foundation that:

- proves whether complete-look recommendations are influencing basket growth and conversion
- gives product and analytics teams a reliable optimization loop instead of one-off readouts
- gives merchandising teams visibility into whether curated and governed changes are helping or hurting outcomes
- makes later contextual and personal recommendation work comparable against a trusted baseline
- prevents opaque optimization by requiring traceable event context, experiment visibility, and operational guardrails

## 3. Business outcomes

This requirement must support these outcomes:

1. **Measurable recommendation influence** so SuitSupply can determine whether recommendation sets drive attachment, basket growth, and conversion instead of merely being displayed.
2. **Comparable performance across surfaces and recommendation types** so PDP, cart, later homepage, email, and clienteling consumers can be evaluated with shared definitions and stable attribution.
3. **Safe optimization loops** so ranking, source-blend, fallback, and presentation changes can be tested without bypassing merchandising governance, compatibility rules, consent boundaries, or brand safety.
4. **Operational visibility** so teams can distinguish poor recommendation quality from instrumentation gaps, stale data, weak coverage, or degraded delivery.
5. **Downstream readiness** for feature, architecture, and implementation work around telemetry contracts, experimentation controls, dashboards, and optimization workflows.

## 4. Guiding business principles

All downstream work must preserve these principles:

### 4.1 Measurement is a product requirement, not an afterthought

Recommendation telemetry must be treated as part of the product capability. If impression and outcome tracking are incomplete, the recommendation loop is incomplete.

### 4.2 Attribution must survive across consumers

Recommendation performance should be measurable across ecommerce, email, and clienteling consumers through shared identifiers and shared event semantics, even when the interaction pattern differs by channel.

### 4.3 Optimization stays inside governance boundaries

Experiments may change ranking, source-blend, candidate emphasis, or presentation choices only within the limits established by compatibility rules, merchandising controls, policy boundaries, and approved fallback behavior.

### 4.4 Business impact and operational quality both matter

A recommendation variant that improves click-through rate but breaks traceability, increases dismissals, or weakens complete-look coherence is not a clear success. Measurement must include business, product, and operational outcomes together.

### 4.5 Event definitions must stay stable enough for trend analysis

Recommendation analytics should not require teams to reinterpret historical performance every time a new surface or experiment is launched. Core event semantics and attribution fields must remain comparable over time.

### 4.6 Phase expansion depends on measurable foundations

Later personalization, contextual logic, and broader channel rollout should build on Phase 1 telemetry completeness rather than assuming richer optimization can compensate for weak measurement.

### 4.7 Reporting should explain change, not only summarize volume

Internal teams need reporting that connects performance changes to recommendation type, surface, campaign, experiment, curation, and fallback conditions so optimization decisions are explainable and auditable.

## 5. Analytics users and decisions supported

This BR must support the information needs of these business users:

### 5.1 Product and analytics teams

These users need to:

- measure recommendation performance by surface, recommendation type, cohort, and variant
- compare baseline behavior against experiments and later optimization changes
- identify whether performance changes are driven by engagement, attachment, conversion, or data-quality shifts
- evaluate whether complete-look usefulness is improving enough to justify broader rollout

### 5.2 Merchandising and governance teams

These users need to:

- understand whether curated looks, overrides, campaign priorities, or source-blend changes improve recommendation outcomes
- distinguish strong recommendation sets from ones that require repeated suppression or manual correction
- see whether governed changes affected business performance or simply changed exposure volume

### 5.3 Marketing and lifecycle operators

These users need to:

- compare recommendation performance across channel activations
- understand whether recommendation-enabled messaging is improving engagement and downstream conversion
- evaluate campaign-specific recommendation influence without losing shared attribution standards

### 5.4 Styling and clienteling leaders

These users need to:

- assess whether assisted-selling recommendations are credible, actionable, and commercially useful
- compare digital and assisted-surface performance without assuming identical workflows
- understand where recommendation gaps may require stronger curated support

### 5.5 Platform, data, and operations teams

These users need to:

- detect missing telemetry, attribution breaks, or degraded recommendation coverage
- monitor experiment health, event quality, and reporting trustworthiness
- identify whether recommendation logic changes caused operational regressions

## 6. Telemetry scope and event expectations

The analytics foundation must cover the full recommendation loop from exposure through outcome.

### 6.1 Recommendation exposure and impression events

Downstream work must preserve a business-recognizable event for when a recommendation set or recommendation module was actually exposed on a surface where a customer or internal operator could interact with it.

Business expectations:

- impression tracking must be available on first-release recommendation surfaces
- impression counts must remain attributable to recommendation type, surface, and recommendation set
- recommendation exposure should distinguish between a module being returned by the platform and a module being displayed or otherwise made available to the user
- impression semantics should be stable enough that downstream teams can compare performance across phases and consumers

### 6.2 Interaction events

The telemetry model must support recommendation interactions where relevant, including:

- click
- save
- dismiss
- comparable channel-specific interaction outcomes when the surface does not literally use clicks

Business expectations:

- interaction events must preserve enough context to identify which recommended product, look, or slot was acted on
- interaction reporting must remain segmentable by recommendation type, surface, and experiment variant
- dismiss or low-interest signals should be measurable because they help distinguish noise from relevance

### 6.3 Commerce outcome events

The telemetry model must connect recommendations to downstream commercial outcomes where relevant, including:

- add-to-cart
- purchase
- other comparable influenced-outcome events for channels that do not have an immediate cart pattern

Business expectations:

- outcome events must preserve attribution to the originating recommendation set where feasible
- performance reporting must distinguish between exposure, engagement, and commercial influence
- downstream teams must be able to evaluate attachment and conversion impact for recommendation-influenced sessions

### 6.4 Governance and operator events

Recommendation analytics must include measurable events or equivalent trace points for:

- override application
- fallback activation
- campaign-priority influence
- significant recommendation-mode changes caused by governance actions

Business expectations:

- internal teams must be able to see when governed changes materially affected recommendation behavior
- reporting must support analysis of whether overrides or fallback modes are helping, masking, or degrading performance

### 6.5 Traceability and continuity events

The telemetry model must preserve enough continuity to reconstruct the path from recommendation generation to outcome analysis.

Business expectations:

- recommendation set IDs and trace IDs must remain usable from exposure through outcome analysis
- downstream reporting must be able to join recommendation context to later events without relying on fragile surface-specific logic
- telemetry continuity should survive multi-surface delivery and experimentation contexts

### 6.6 Failure and degradation visibility

Recommendation analytics is incomplete if it only records healthy paths. Downstream work must make measurable when:

- recommendation modules fail to render or are unavailable
- fallback behavior replaces a richer recommendation mode
- event context is incomplete or attribution is degraded
- coverage drops for an important recommendation type or surface

## 7. Minimum attribution context

Every recommendation-related event should preserve the minimum business context required for trustworthy reporting and experimentation. Exact field names may differ downstream, but the business meaning must remain intact.

### 7.1 Shared identifiers

Downstream telemetry must preserve:

- recommendation set ID
- trace ID
- stable product IDs and look IDs where relevant
- customer ID or anonymous session ID as permitted
- experiment ID and variant where applicable
- campaign, curated-look, rule, or override identifiers where those materially influenced the set

### 7.2 Recommendation context

Downstream telemetry must preserve:

- recommendation type
- surface
- channel
- anchor product, cart, or journey context where relevant
- RTW versus CM mode where the distinction materially affects interpretation
- ranking or source-mode context such as curated, rule-based, AI-ranked, blended, or fallback behavior

### 7.3 Journey and presentation context

Downstream telemetry must preserve enough context to interpret where the recommendation was encountered, such as:

- module or placement identity
- slot or position where relevant
- market or region context
- device or session context where materially relevant to reporting
- timestamp and event sequence continuity

### 7.4 Data and quality context

Where materially relevant, downstream telemetry must preserve enough context to show:

- whether key inputs were fresh, stale, missing, or degraded
- whether recommendation logic ran in a normal or fallback mode
- whether attribution was complete or partial

### 7.5 Privacy and policy context

Telemetry and reporting must preserve policy-safe attribution. Downstream work must ensure:

- customer-level analysis stays inside consent and regional policy boundaries
- sensitive internal signals are not exposed in customer-facing contexts
- analytics can explain decision sources without revealing sensitive profile reasoning

## 8. Success metrics and interpretation

Recommendation analytics must support a measurement framework that distinguishes commercial value, recommendation usefulness, telemetry quality, and experiment health.

### 8.1 Commercial measures

Downstream teams must be able to measure:

- conversion uplift on recommendation-enabled surfaces
- average order value uplift for recommendation-influenced sessions
- category attachment and basket-expansion performance
- repeat engagement or repeat purchase improvement where later phases support that interpretation

### 8.2 Recommendation product measures

Downstream teams must be able to measure:

- impression volume by recommendation type, surface, and channel
- click-through rate or equivalent interaction rate
- add-to-cart rate from recommendation interactions
- purchase influence from recommendation-exposed sessions
- complete-look engagement rate
- dismiss rate or comparable negative-signal rate
- recommendation coverage by category, surface, market, and eligible journey

### 8.3 Telemetry-quality measures

Downstream teams must be able to measure:

- percentage of recommendation impressions with valid recommendation set ID and trace ID
- percentage of outcome events attributable to a prior recommendation set where attribution is expected
- percentage of recommendation events with complete experiment, source, and surface context
- rate of broken, late, or partial telemetry on priority surfaces

### 8.4 Experiment-health measures

Downstream teams must be able to measure:

- performance difference between baseline and variant populations
- sample availability and exposure coverage for active experiments
- guardrail outcomes such as increased dismissals, weak attachment, or degraded coverage
- whether a positive top-line metric was achieved by shifting volume, suppressing coverage, or increasing fallback behavior

### 8.5 Governance and operational measures

Downstream teams must be able to measure:

- recommendation API availability and latency in relation to exposure and outcome performance
- fallback rate by surface, market, and recommendation type
- override frequency and whether overrides correlate with improved or degraded results
- reporting lag and telemetry freshness for optimization-critical dashboards

### 8.6 Measurement interpretation rule

Recommendation optimization should be judged against a balanced interpretation:

- a recommendation change is not clearly successful unless it improves or protects business value without creating unacceptable traceability, coverage, governance, or quality regressions
- a surface should not expand to later optimization depth if measurement gaps prevent teams from trusting the observed results
- higher engagement without stronger attachment, conversion, or complete-look usefulness should be treated cautiously rather than assumed to be progress

## 9. Experimentation needs and guardrails

The platform must support controlled experimentation for recommendation behavior, while keeping business and governance constraints explicit.

### 9.1 In-scope experiment classes

Downstream experimentation must be able to compare, where appropriate:

- ranking strategies
- curated versus blended versus AI-ranked source emphasis
- recommendation-type selection or emphasis
- fallback versus richer recommendation modes
- placement or presentation variants where measurement remains attributable
- campaign-aware or context-aware recommendation behaviors in later phases

### 9.2 Variant assignment and visibility

Business expectations:

- active experiments must be visible in recommendation telemetry through stable experiment and variant identifiers
- downstream teams must be able to compare baseline and variant behavior by surface and recommendation type
- experiment assignment should remain consistent enough within the intended decision scope to make reporting trustworthy

### 9.3 Holdout and baseline expectations

Recommendation experimentation must support trustworthy comparison against safer governed baselines, including:

- a control or baseline condition that preserves business-recognizable recommendation behavior
- the ability to compare richer variants against fallback or prior-state behavior where appropriate
- measurement that distinguishes no-change baselines from degraded instrumentation

### 9.4 Guardrails and non-bypass rules

Experiments must not:

- bypass hard compatibility, consent, privacy, or policy boundaries
- hide whether fallback, override, or campaign-priority logic materially affected the set
- redefine event semantics in a way that breaks trend continuity without explicit reporting treatment
- optimize solely for shallow engagement if brand coherence, purchasability, or governance quality regresses

### 9.5 Segmentation expectations

Downstream teams must be able to segment experiment results by:

- surface and channel
- recommendation type
- market or region
- anonymous versus known-customer context where permitted
- RTW versus later CM scenarios when those modes are materially different

### 9.6 Experiment-readiness rule

Later optimization layers should only expand when the surface has:

- reliable impression and outcome telemetry
- stable recommendation set and trace ID continuity
- enough reporting trust to compare variants responsibly
- clear interpretation of whether measured changes came from recommendation quality or measurement instability

## 10. Reporting expectations

Recommendation reporting must support daily operational use as well as longer-horizon business optimization. Exact dashboard shapes may vary downstream, but the business outputs must remain available.

### 10.1 Surface and channel reporting

Internal teams must be able to report recommendation performance by:

- surface
- channel
- recommendation type
- market or region
- device or comparable usage segment where relevant

### 10.2 Funnel reporting

Internal teams must be able to see the recommendation funnel from:

- impression
- interaction
- add-to-cart or equivalent influenced step
- purchase or downstream conversion outcome

This reporting must preserve the ability to compare drop-off and conversion patterns across variants and surfaces.

### 10.3 Business and merchandising reporting

Internal teams must be able to report:

- which recommendation types and surfaces are contributing most to attachment and conversion
- which curated looks, campaigns, or governed changes correlate with stronger or weaker performance
- where repeated overrides, suppressions, or fallback behavior indicate systemic recommendation issues

### 10.4 Experiment reporting

Internal teams must be able to report:

- active and historical experiment performance
- baseline versus variant comparisons
- results segmented by recommendation type, surface, and market
- guardrail outcomes and notable regressions, not only winning metrics

### 10.5 Operational reporting

Internal teams must be able to report:

- telemetry completeness and attribution health
- coverage gaps by recommendation type and surface
- recommendation delivery degradation, fallback rates, and reporting lag
- whether missing data is undermining confidence in measured results

### 10.6 Executive and roadmap reporting

The reporting model should support summary views that help leadership answer:

- whether recommendation investment is improving conversion, AOV, and attachment on priority surfaces
- whether Phase 1 is strong enough to justify Phase 2 personalization and contextual expansion
- which surfaces, recommendation types, or markets deserve deeper optimization next

## 11. Functional business requirements

### 11.1 Shared-telemetry requirement

The platform must use a shared recommendation telemetry model that supports impression, interaction, add-to-cart, purchase, dismiss, override, and related outcome reporting across consumers where those events are applicable.

### 11.2 Attribution-continuity requirement

Recommendation telemetry must preserve recommendation set ID and trace ID continuity from exposure through outcome analysis so downstream teams can attribute performance to specific recommendation decisions.

### 11.3 Recommendation-context requirement

Each recommendation-related event must preserve enough business context to identify recommendation type, surface, channel, and relevant source or fallback mode so reporting remains interpretable.

### 11.4 Experiment-visibility requirement

Active experiments must be visible in telemetry and reporting through stable experiment and variant context that supports baseline-versus-variant analysis.

### 11.5 Outcome-measurement requirement

The analytics model must distinguish impression, engagement, add-to-cart, purchase, and equivalent commercial outcomes so recommendation usefulness is not inferred from one shallow metric alone.

### 11.6 Governance-impact requirement

Reporting and telemetry must preserve enough context to show whether overrides, campaign priorities, protected curation, or fallback modes materially influenced recommendation behavior and measured outcomes.

### 11.7 Reporting-readiness requirement

The platform must support reporting cuts by surface, channel, recommendation type, market, cohort, and experiment state so internal teams can evaluate recommendation performance without ad hoc reinterpretation of telemetry.

### 11.8 Telemetry-quality requirement

The platform must make telemetry completeness, attribution health, coverage gaps, and degraded recommendation modes measurable so teams can determine whether observed performance is trustworthy.

### 11.9 Guardrailed-experimentation requirement

Recommendation experiments must operate within compatibility, consent, privacy, and merchandising guardrails and must not bypass non-negotiable recommendation constraints in pursuit of uplift.

### 11.10 Optimization-baseline requirement

Phase expansion and optimization decisions must compare richer recommendation behavior against stable governed baselines rather than assuming more complex logic is automatically better.

## 12. Surface and phase expectations

### 12.1 Phase 1 foundation

Phase 1 should establish the minimum analytics and experimentation loop for the first recommendation surfaces:

- impression telemetry on initial recommendation-enabled ecommerce surfaces
- click, add-to-cart, and purchase attribution for the first RTW anchor-product recommendation loop
- stable recommendation set ID and trace ID continuity
- baseline reporting for conversion, AOV influence, attachment, and complete-look engagement
- experiment hooks sufficient to compare foundational recommendation variants without breaking governance or measurement trust

### 12.2 Phase 1 focus rule

Phase 1 should prioritize trustworthy telemetry and clear baseline reporting over broad experimentation breadth. The first goal is to prove that recommendation influence can be measured reliably on high-signal surfaces such as PDP and cart.

### 12.3 Phase 2 expansion

Phase 2 should strengthen:

- segmentation for known versus anonymous users where permitted
- reporting for contextual and personal recommendation variants
- experiment analysis for richer ranking and customer-signal usage
- stronger interpretation of repeat engagement and relevance over time

### 12.4 Phase 3 maturity

Phase 3 should expand toward:

- broader multi-channel reporting across email and clienteling consumers
- richer internal dashboards for merchandising, governance, and campaign performance
- more mature experimentation controls and optimization workflows

### 12.5 Phase sequencing rule

Later phases should expand only when the earlier surfaces can preserve:

- complete enough impression and outcome telemetry
- stable shared event semantics
- trustworthy attribution continuity
- visible fallback and governance context
- reporting confidence strong enough to interpret uplift responsibly

## 13. Constraints and guardrails

- Recommendation telemetry must respect privacy, consent, and regional policy boundaries.
- Event and reporting definitions should remain stable enough for historical trend comparison.
- Experimentation must not bypass hard compatibility, assortment, inventory, campaign, or policy constraints.
- Reporting must distinguish observed business change from telemetry incompleteness or degraded attribution.
- Analytics outputs should not expose sensitive customer reasoning in customer-facing experiences.
- Recommendation success should not be judged solely on click volume when attachment, purchasability, or complete-look quality deteriorates.

## 14. Assumptions

- Phase 1 recommendation surfaces will produce enough interaction volume to establish an initial optimization baseline.
- Stable recommendation set IDs, trace IDs, and experiment identifiers can be preserved across core recommendation consumers.
- Product, analytics, and merchandising teams will need shared reporting views rather than separate incompatible definitions of recommendation success.
- A narrower but trustworthy experimentation capability is more valuable in Phase 1 than a broad but weakly attributable optimization program.

## 15. Open questions for downstream feature breakdown

- What attribution window should connect recommendation exposure to add-to-cart and purchase outcomes on each priority surface?
- Which interactions count as the first equivalent of "save" or "dismiss" on non-ecommerce or assisted-selling surfaces?
- What minimum reporting latency is required for daily optimization workflows versus executive or periodic reporting?
- Which experiment classes should be available first: ranking-only, source-blend, module presentation, or fallback-mode comparisons?
- What baseline or holdout model best balances trustworthy comparison with commercial risk on Phase 1 surfaces?
- How should downstream reporting distinguish direct recommendation influence from broader session uplift when multiple recommendation modules are present?

## 16. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for shared recommendation event semantics and attribution continuity across consumers
2. feature scope for impression, interaction, add-to-cart, purchase, dismiss, and override measurement rules
3. feature scope for experiment assignment visibility, baseline handling, and guardrail reporting
4. feature scope for recommendation-performance dashboards, funnel views, and telemetry-quality reporting
5. feature scope for segmentation by surface, recommendation type, market, and customer or session context

## 17. Exit criteria check

This BR is complete when downstream teams can see:

- which recommendation events must be captured to measure the first optimization loop
- what attribution context must persist from recommendation exposure to downstream outcomes
- what success metrics define recommendation usefulness, commercial influence, and telemetry trustworthiness
- what experimentation hooks and guardrails are required for safe optimization
- what reporting views internal teams need to decide whether recommendation changes are helping or hurting

## 18. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-010-analytics-and-experimentation.md`

Approval mode: `AUTO_APPROVE_ALLOWED`

Blockers: none

Required edits: none

Scored dimensions:

- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5

Overall disposition: `APPROVED`

Confidence: HIGH

Approval-mode interpretation:

- This artifact exceeds the promotion threshold in the repo rubric.
- `AUTO_APPROVE_ALLOWED` is explicitly recorded on the board and in this artifact.
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define exact attribution windows, report latency expectations, and experiment-governance operating details.

Residual risks and open questions:

- Attribution windows and influenced-outcome interpretation need downstream feature and data-contract decisions to stay consistent across surfaces.
- Phase 1 reporting may still need surface-specific nuance so assisted or non-click interactions do not get forced into ecommerce-only semantics.
