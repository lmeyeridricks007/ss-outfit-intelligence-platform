# BR-011: Explainability and auditability

## Traceability

- **Board item:** BR-011
- **GitHub issue:** #118
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #118 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`, `docs/project/industry-standards.md`
- **Related inputs:** recommendation trace context, rule and campaign provenance, experiment visibility, override history, and operations needs
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs explainability and auditability for recommendation decisions so internal teams can reconstruct why a recommendation set was produced, what governed inputs shaped it, whether experiments or overrides changed the outcome, and how to investigate quality issues without relying on guesswork or tribal knowledge. The platform must preserve traceable recommendation context across request inputs, candidate sources, rules, campaigns, experiments, ranking mode, and governance actions so operators can review, audit, and troubleshoot recommendation behavior confidently.

This business requirement defines:

- the business questions explainability must answer for operators and downstream teams
- the recommendation decision layers that must remain traceable
- the minimum provenance and audit context required for recommendation sets
- the review, investigation, and troubleshooting expectations for internal operations
- the boundaries between internal explainability and customer-facing explanation

This BR does not define:

- the final admin UI design or exact screen layout for internal operator tools
- the low-level storage schema, log pipeline, or observability vendor implementation
- the exact model feature weights, scoring formulas, or algorithm internals for every ranking method
- the final retention policy duration or legal archive implementation details
- customer-facing copy for any future explanation messaging

## 2. Problem and opportunity

Recommendation systems fail operationally when teams can see what was shown but cannot explain why it was shown. A premium retail recommendation platform needs more than click metrics. Merchandisers, analysts, stylists, support teams, and platform operators need to understand whether a recommendation set came from curated looks, compatibility rules, campaign priorities, active experiments, fallback behavior, or AI-ranked candidate selection. Without that visibility, teams may suppress symptoms without fixing root causes, lose trust in the recommendation engine, or create manual workarounds that weaken governance.

Without a clear explainability and auditability requirement:

- operators may not be able to tell whether a recommendation was curated, rule-driven, campaign-driven, or AI-ranked
- debugging may depend on raw logs or engineering intervention rather than a usable internal trace
- experiments may change recommendation behavior without sufficient visibility into which variant shaped the result
- overrides or fallbacks may remain active without teams understanding their downstream impact
- customer-facing or support incidents may take too long to investigate because the decision path cannot be reconstructed
- governance and optimization work may become opaque as recommendation logic expands across surfaces and channels

The opportunity is to establish a recommendation traceability standard that:

- makes recommendation behavior inspectable enough for daily operations
- preserves trust in a blended curated, rule-based, and AI-ranked recommendation model
- gives downstream feature and architecture work clear trace and audit requirements
- reduces time spent diagnosing recommendation incidents, mismatches, and policy questions
- supports later experimentation, personalization, and governance expansion without making the system operationally opaque

## 3. Business outcomes

This requirement must support these outcomes:

1. **Reconstructable recommendation decisions** so internal teams can determine why a recommendation set appeared, changed, or failed to appear.
2. **Operational trust** so merchandisers, stylists, analytics teams, and platform owners can use recommendation outputs with confidence instead of treating them as opaque black boxes.
3. **Faster troubleshooting and incident review** so poor outputs, unexpected suppressions, missing campaign influence, or unstable variants can be diagnosed quickly.
4. **Auditable governance and experimentation** so teams can see how overrides, campaign priorities, curated looks, and experiment variants affected live recommendation behavior.
5. **Cross-channel continuity of explanation** so ecommerce, email, and clienteling consumers can preserve enough shared trace context for later review and comparison.

## 4. Guiding business principles

All downstream work must preserve these principles:

### 4.1 Internal explainability is required even when customer-facing explanation is limited

The platform must be explainable enough for internal operators to review decisions, even if customer-facing surfaces expose little or no direct recommendation rationale.

### 4.2 Traceability must cover the blended decision path, not just the final result

Recommendation explainability is incomplete if it only records the final ordered items. Internal teams must be able to see the important decision layers that shaped the final set, including source provenance, eligibility constraints, governance actions, and experiment context.

### 4.3 Explainability must be useful for operations, not a dump of raw internals

Operators need decision context that answers practical business questions. Explainability should identify the meaningful causes of recommendation behavior without requiring every user to parse low-level model internals or provider payloads.

### 4.4 Auditability must connect recommendation generation to governance history

Recommendation traces and governance audit history must work together so teams can tell not only what the engine did, but also which authored or approved changes influenced that behavior.

### 4.5 Hard constraints and policy boundaries must remain visible

If eligibility, inventory, compatibility, region, consent, or governance rules prevented a recommendation outcome, that fact should be visible in internal explanation context rather than hidden behind generic ranking output.

### 4.6 Experiments and fallbacks must never be invisible

If an experiment, fallback mode, campaign priority, or override materially changed recommendation behavior, operators must be able to see that without forensic engineering effort.

### 4.7 Explanation must not expose sensitive reasoning in customer-facing outputs

Internal traceability may include customer, identity, or policy context where permitted, but customer-facing explanations must avoid sensitive, invasive, or overly technical reasoning.

## 5. Operators and audit users

This BR must support the explanation and audit needs of these internal users:

### 5.1 Merchandisers and governance operators

These users need to:

- understand why a look or product was included, excluded, boosted, protected, or suppressed
- confirm whether curated looks, campaign priorities, or overrides influenced the final set
- review whether repeated overrides indicate a deeper recommendation-quality issue
- compare expected merchandising behavior against actual recommendation behavior

### 5.2 Product, analytics, and optimization teams

These users need to:

- interpret recommendation performance changes by source blend, experiment, and fallback mode
- compare recommendation variants without losing the decision context behind the outcome
- distinguish weak recommendation quality from weak measurement or degraded traceability
- understand when ranking changes are helping versus when governance or campaign logic is the stronger driver

### 5.3 Clienteling leaders, stylists, and support teams

These users need to:

- review enough recommendation provenance to trust the platform in assisted-selling workflows
- explain unexpected recommendation behavior in customer or store-support contexts
- identify whether a recommendation mismatch came from stale context, missing curation, policy restrictions, or an active override

### 5.4 Platform, data, and operations teams

These users need to:

- troubleshoot recommendation incidents quickly
- detect broken trace continuity, missing provenance, or incomplete attribution
- determine whether degraded behavior came from data freshness, rule changes, experiment variants, fallback activation, or delivery problems
- support audit review without manually reconstructing the full decision path from scattered logs

### 5.5 Governance, policy, and audit stakeholders

These users need to:

- review whether recommendation behavior stayed inside approved governance and policy boundaries
- confirm that material recommendation changes can be tied back to an identifiable actor, artifact, or controlled experiment
- inspect how recommendation behavior changed over time when investigating incidents or policy questions

## 6. Recommendation decision layers that must remain traceable

Recommendation explainability must cover more than one layer of decisioning.

### 6.1 Request and journey context

Internal explanation must preserve enough context to reconstruct the recommendation moment, including:

- recommendation type
- surface and channel
- anchor product, cart, or active journey state where relevant
- market or region context
- RTW versus CM mode where materially relevant
- active customer or anonymous-session context as permitted

### 6.2 Candidate source provenance

Internal explanation must preserve whether final candidates came from:

- curated looks
- compatibility or rule-based generation
- graph or retrieval logic
- AI-ranked or model-assisted retrieval
- fallback recommendation modes

Operators do not need every internal scoring detail in every view, but they must be able to tell which source families contributed to the final set.

### 6.3 Eligibility and filtering context

Internal explanation must preserve the important constraints that affected candidate eligibility or ordering, including:

- hard compatibility decisions
- inventory or assortment ineligibility
- regional or policy restrictions
- suppression rules
- protected placements or governed campaign priorities

### 6.4 Ranking and assembly context

Internal explanation must preserve enough context to show:

- whether ordering was primarily curated, rule-based, blended, AI-ranked, or fallback-driven
- whether ranking occurred inside a constrained candidate set
- whether set assembly or slotting rules changed the final presentation relative to earlier candidate order

### 6.5 Experiment and variant context

Internal explanation must preserve:

- whether an experiment was active
- which experiment and variant applied
- whether the experiment affected source blend, ranking mode, module behavior, or fallback behavior

### 6.6 Governance and override history

Internal explanation must preserve enough context to show:

- whether an override, campaign priority, protected placement, or fallback control materially shaped the set
- whether the influencing governance object was active, scheduled, expiring, or rolled back
- whether the behavior reflected a normal operating path or a temporary operational intervention

## 7. Explanation questions the platform must answer

This BR is not complete unless downstream work can support practical operator questions.

### 7.1 Set-level questions

Internal users must be able to answer questions such as:

- why was this recommendation set produced for this request and surface
- which source families contributed to the set
- whether the set was primarily curated, governed, AI-ranked, or fallback-driven
- whether an experiment or campaign materially changed the set

### 7.2 Result-level questions

Internal users must be able to answer questions such as:

- why did a specific look or product appear in the final set
- why was a seemingly relevant candidate excluded
- whether a recommendation was boosted, protected, replaced, or suppressed
- whether compatibility, assortment, or policy rules prevented a result

### 7.3 Change-over-time questions

Internal users must be able to answer questions such as:

- why did recommendation behavior change between two dates, sessions, or variants
- whether a new campaign, experiment, override, or curation change caused the shift
- whether a fallback mode or trace-quality regression made the output less trustworthy

### 7.4 Troubleshooting questions

Internal users must be able to answer questions such as:

- why did the expected campaign or curated look not appear
- why did a recommendation disappear after being present previously
- whether a recommendation mismatch was caused by stale data, an expired control, a rule conflict, or a broken trace
- whether repeated recommendation complaints point to ranking issues, governance gaps, or data-quality problems

## 8. Minimum traceability requirements

Every materially relevant recommendation set must preserve enough context for internal review.

### 8.1 Shared identifiers and continuity

Downstream systems must preserve:

- recommendation set ID
- trace ID
- stable product IDs and look IDs where relevant
- customer ID or anonymous session ID as permitted
- rule, campaign, override, curated-look, and experiment identifiers where they materially influenced the set

### 8.2 Request and recommendation context

Downstream systems must preserve:

- recommendation type
- surface
- channel
- anchor product, cart, or journey context where relevant
- market or region context
- RTW versus CM mode where relevant
- timestamp and sequence continuity needed for later reconstruction

### 8.3 Source and decision provenance

Downstream systems must preserve enough context to show:

- which candidate source families were available
- which candidate source families contributed to the final set
- whether the final set was curated, rule-based, AI-ranked, blended, or fallback-driven
- whether eligibility filtering removed otherwise plausible candidates
- whether set assembly or slot rules changed the final output

### 8.4 Governance and experiment provenance

Downstream systems must preserve enough context to show:

- which campaign, override, suppression, protection, or fallback control influenced the set
- which experiment and variant applied
- whether a governance action or experiment materially changed ordering, candidate inclusion, or fallback behavior
- whether the governing object was active, expiring, or recently changed

### 8.5 Data-quality and interpretation context

Where materially relevant, downstream systems must preserve enough context to show:

- freshness or staleness state for key context or signal classes used
- identity confidence where cross-system customer identity affected the result
- whether an important input was unavailable, degraded, or intentionally ignored
- whether traceability itself was partial or degraded for the recommendation set

## 9. Auditability requirements

Explainability is incomplete unless recommendation behavior and its influencing changes remain auditable over time.

### 9.1 Recommendation decision audit trail

The platform must preserve an auditable internal record or reconstructable trace for recommendation generation that supports later investigation of:

- recommendation-quality complaints
- missing or unexpected campaign influence
- unexplained suppressions or protected placements
- experiment-induced behavior changes
- fallback activation and degraded recommendation modes
- cross-channel differences in recommendation behavior

### 9.2 Governed-change audit trail

Material changes to recommendation-governing objects must preserve enough history to show:

- who created, edited, approved, activated, deactivated, or rolled back the change
- what changed and which object was affected
- why the change was made
- when the change became effective and when it ceased to apply
- which market, surface, recommendation type, category, or campaign scope was affected

### 9.3 Linkage between decision trace and change history

Operators must be able to connect a recommendation set back to the governing artifacts or experiments that influenced it. It must be possible to move from a recommendation trace to the relevant rule, campaign, curated look, override, or experiment history without relying on guesswork.

### 9.4 Retention and retrieval expectation

Auditability requires that recommendation traces and governed-change history remain retrievable for operational review, experiment comparison, incident analysis, and policy or support investigations. Exact retention durations are a downstream policy decision, but the business requirement is that useful historical reconstruction must be possible for the periods the business treats as operationally or policy-relevant.

## 10. Internal explanation presentation expectations

The platform does not need to expose the same explanation depth to every audience.

### 10.1 Operator-focused explanation

Internal tools should present explanation context in a way that helps users review:

- why the set was produced
- which sources and controls influenced it
- what constrained or changed the output
- whether the result reflects normal ranking, governed intervention, or fallback behavior

### 10.2 Progressive detail expectation

Internal explainability should support progressive detail rather than a single monolithic dump. Users should be able to start with a concise set-level explanation and then inspect deeper provenance, experiment, rule, or override context when needed.

### 10.3 Customer-facing boundary

Customer-facing surfaces must not expose sensitive profile reasoning, internal audit fields, or overly technical operational logic. If customer-facing explanation is added later, it should translate recommendation reasoning into respectful, high-level guidance rather than reveal internal trace details.

## 11. Functional business requirements

### 11.1 Recommendation-trace requirement

Each recommendation set must preserve enough trace context to show why it was produced and which decision layers materially shaped the final output.

### 11.2 Source-provenance requirement

The platform must preserve whether a recommendation set and its results came from curated, rule-based, AI-ranked, blended, or fallback recommendation paths.

### 11.3 Eligibility-visibility requirement

The platform must preserve enough internal explanation context to show when hard eligibility, compatibility, inventory, policy, or suppression rules changed candidate availability or ordering.

### 11.4 Experiment-visibility requirement

If an experiment materially affects recommendation behavior, the platform must preserve experiment and variant visibility in the recommendation trace and downstream analytics context.

### 11.5 Governance-linkage requirement

If a campaign priority, override, protection rule, suppression, or fallback control influenced the set, the recommendation trace must preserve that linkage clearly enough for internal review.

### 11.6 Audit-history requirement

Material recommendation-governing changes must preserve actor, reason, scope, lifecycle, and effective-time history so later audits can reconstruct what changed and why.

### 11.7 Troubleshooting-support requirement

The platform must support operator troubleshooting of recommendation-quality issues by preserving enough trace and audit context to diagnose missing outputs, unexpected outputs, degraded modes, and recommendation changes over time.

### 11.8 Cross-channel continuity requirement

Recommendation explainability must preserve stable enough identifiers and provenance across ecommerce, email, and clienteling consumers that internal teams can compare and investigate behavior across channels.

### 11.9 Customer-facing-boundary requirement

Internal explainability must remain richer than customer-facing explanation, and customer-facing outputs must not expose sensitive profile reasoning, raw audit fields, or internal operational logic.

### 11.10 Explainability-quality requirement

Downstream teams must be able to measure whether recommendation traces are complete enough, linked enough, and stable enough to support operational review without routine engineering-only reconstruction.

## 12. Success measures

### 12.1 Trace completeness measures

Downstream teams must be able to measure:

- percentage of recommendation sets with valid recommendation set ID and trace ID
- percentage of recommendation sets with recorded source provenance, governance context, and experiment visibility where applicable
- percentage of recommendation sets whose trace remains usable through downstream outcome analysis

### 12.2 Troubleshooting effectiveness measures

Downstream teams must be able to measure:

- time required to diagnose recommendation-quality incidents or complaints
- percentage of common investigation questions answerable without ad hoc engineering log reconstruction
- rate of incidents where trace context is missing, partial, or misleading

### 12.3 Governance and audit measures

Downstream teams must be able to measure:

- percentage of material governance changes with complete actor, reason, scope, and lifecycle history
- percentage of active overrides or campaign controls that can be linked directly to affected recommendation traces
- percentage of recommendation behavior changes that can be attributed to curation, rule, campaign, override, experiment, or ranking causes

### 12.4 Trust and adoption measures

Downstream teams must be able to measure:

- operator adoption of explanation or audit views in merchandising, analytics, and support workflows
- reduction in recommendation issues labeled as opaque or unexplained
- reduction in repeated manual interventions caused by poor visibility into recommendation causes

## 13. Phase expectations

### 13.1 Phase 1 foundation

Phase 1 should establish the minimum explainability and auditability foundation required for the first recommendation loop:

- recommendation set ID and trace ID continuity
- source-family provenance for curated, rule-based, AI-ranked, blended, and fallback behavior
- visibility into rule, campaign, experiment, and override influence when applicable
- enough operator-facing trace context to troubleshoot recommendation mismatches and missing outputs
- linkage between recommendation traces and governed-change history for material controls

### 13.2 Phase 2 expansion

Phase 2 should strengthen:

- richer traceability for customer-signal and context-driven recommendation paths
- clearer attribution of personalization and contextual influence
- better comparison views between baseline, experimental, and governed recommendation variants

### 13.3 Phase 3 maturity

Phase 3 should expand toward:

- deeper multi-channel operator tooling
- stronger historical comparison and audit workflows
- richer explainability for advanced ranking and governance interactions without losing operator usability

## 14. Constraints and guardrails

- Explainability must prioritize internal operational usefulness over exhaustive raw technical detail.
- Recommendation traces must remain linked to governed artifacts and experiments through stable identifiers.
- Traceability must not expose sensitive customer reasoning in customer-facing outputs.
- Explainability requirements must not imply that hard constraints, policy controls, or governance actions are optional or secondary.
- The recommendation platform must remain usable even when some trace detail is degraded, but degraded trace quality must itself be visible.
- Phase 1 should deliver enough explainability for operational trust without requiring fully mature investigative tooling before first release.

## 15. Assumptions

- Operators need explainability at the recommendation-set and result level even when customers do not see explicit explanation.
- The blended recommendation model will remain easier to operate if curated, rule-based, AI-ranked, and fallback paths are all distinguishable in traces.
- Stable identifiers for looks, rules, campaigns, experiments, and recommendation sets can be preserved across core recommendation consumers.
- Recommendation trace quality is a prerequisite for trustworthy experimentation, governance, and later personalization expansion.

## 16. Open questions for downstream feature breakdown

- What is the minimum operator-facing explanation view needed first: set-level summary, result-level drill-down, or both?
- Which ranking or model details are necessary for operational usefulness without overwhelming non-technical users?
- What retention periods are required for operational incident review versus policy or audit review?
- Which user roles need direct access to detailed recommendation traces versus summarized explanation views?
- How should downstream tooling distinguish between normal governance influence and temporary emergency intervention?
- What evidence threshold should mark a trace as incomplete, degraded, or unsafe for decision comparison?

## 17. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for recommendation trace capture, retrieval, and operator-facing explanation summaries
2. feature scope for source provenance, eligibility visibility, and result-level explanation detail
3. feature scope for experiment visibility, fallback visibility, and variant comparison
4. feature scope for linkage between recommendation traces and governance audit history
5. feature scope for troubleshooting workflows, degraded-trace handling, and operational reporting of explainability quality

## 18. Exit criteria check

This BR is complete when downstream teams can see:

- what business questions explainability must answer about recommendation sets
- which decision layers and provenance fields must remain traceable
- how operators should review, audit, and troubleshoot recommendation behavior
- how experiments, overrides, rules, campaigns, and fallbacks must remain visible
- where internal explanation must stay richer than customer-facing explanation

## 19. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-011-explainability-and-auditability.md`

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
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define exact trace access patterns, retention details, and operator tooling depth.

Residual risks and open questions:

- Exact operator-tool presentation and role-based access control still require downstream feature and architecture decisions.
- Advanced ranking explainability could become too technical or too shallow unless downstream work preserves an operator-first interpretation layer.
