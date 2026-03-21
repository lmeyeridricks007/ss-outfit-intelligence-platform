# BR-009: Merchandising governance

## Traceability

- **Board item:** BR-009
- **GitHub issue:** #116
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #116 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/industry-standards.md`
- **Related inputs:** curated looks, overrides, compatibility rules, campaign priorities, governance controls, and audit expectations
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs a merchandising-governance model that lets internal teams shape recommendation behavior without depending on engineering for every operational adjustment. The platform must define which recommendation inputs merchandisers can author or override, how campaign and curation priorities are applied, what operating boundaries protect compatibility and brand standards, and what audit evidence is required so recommendation changes remain explainable, reversible, and safe to operate.

This business requirement defines:

- the governance layers that shape recommendation outputs
- the override models merchandisers need for day-to-day control
- the operating boundaries between merchandising self-service and engineering-owned platform changes
- the review, publication, and rollback expectations for governed recommendation changes
- the audit and traceability expectations that make recommendation operations trustworthy

This BR does not define:

- the final admin UI design or workflow screen layouts
- the exact permission model implementation or identity provider integration
- the low-level rule syntax, storage schema, or event payloads
- the specific ranking algorithms or model deployment process
- the detailed service architecture for authoring, approval, or publishing

## 2. Problem and opportunity

Recommendation quality depends on more than algorithms. In premium retail, merchandising teams need to express styling intent, protect brand standards, respond to campaign timing, and correct bad outputs quickly. If every change requires engineering intervention, the platform becomes too slow for operational use and too expensive to maintain. If merchandising teams can change anything without guardrails, recommendation quality becomes inconsistent, hard to audit, and risky across channels.

The business problem is therefore a governance problem as much as a ranking problem:

- curated looks need clear ownership and publication controls
- compatibility rules need to be adjustable without bypassing brand or safety constraints
- campaign priorities need predictable precedence over generic ranking when business moments matter
- overrides need to exist for urgent fixes without turning the platform into an unmanaged manual system
- audit expectations need to show who changed recommendation behavior, why, when, and with what downstream effect

The opportunity is to create a governed operating model that:

- gives merchandisers practical self-service control over recommendation behavior
- protects engineering-owned platform guardrails, quality, and reliability
- preserves traceability for recommendation changes across ecommerce, email, and clienteling use cases
- makes recommendation operations fast enough for seasonal, campaign, and assortment change cycles
- reduces the need for engineering-only workflows to handle normal merchandising decisions

## 3. Business outcomes

This requirement must support these outcomes:

1. **Merchandising self-service within guardrails** so curated looks, campaign emphasis, and recommendation overrides can be managed without engineering tickets for normal operational work.
2. **Governed recommendation quality** so internal teams can change recommendation behavior while preserving compatibility, brand integrity, and operational validity.
3. **Faster response to business moments** such as launches, promotions, seasonal shifts, inventory realities, and quality corrections.
4. **Clear separation of responsibilities** so merchandising owns recommendation intent and operational controls while engineering owns core platform capabilities, hard guardrails, and technical reliability.
5. **Auditable recommendation operations** so downstream teams can reconstruct what changed, who approved it, and why a recommendation set behaved as it did.

## 4. Guiding governance principles

All downstream work must preserve these principles:

### 4.1 Merchandising control must be real, but bounded

Merchandising teams must be able to shape recommendation outcomes through curated looks, rules, campaign priorities, and overrides. That control must live inside explicit boundaries rather than informal manual intervention.

### 4.2 Hard safety and compatibility controls outrank local preference

No self-service governance action may bypass hard compatibility rules, policy restrictions, assortment eligibility, consent constraints, or other safety-critical recommendation boundaries.

### 4.3 Operational changes must be visible and reversible

If a governance action can materially change recommendation behavior, it must be traceable, reviewable, and capable of rollback without emergency engineering work.

### 4.4 Campaign intent and curated presentation need explicit precedence

Campaign priorities and protected curated looks must not depend on implicit ranking behavior. The governance model must define how priority and protection work so business intent is predictable.

### 4.5 Overrides are for control, not as a hidden replacement for the system

Overrides are necessary for urgent correction, premium presentation, and strategic emphasis, but the platform should not require constant manual overrides to stay usable. High override volume should indicate opportunities for rule, curation, or ranking improvement.

### 4.6 Governance must work across channels

Recommendation governance should support ecommerce, email, and clienteling activation through shared business rules and shared traceability, even when channel-specific presentation differs.

### 4.7 Governance actions need proportionate review

Not every merchandising change requires the same review depth. Routine curation and campaign updates should be fast, while broad suppressions, global priority changes, or high-risk premium overrides should require stronger review and clearer audit evidence.

## 5. Governance scope and actor expectations

The governance model must support these internal actors at a business level:

### 5.1 Merchandisers and styling teams

These users need to:

- author and maintain curated looks
- define or adjust recommendation priorities for campaigns and assortments
- suppress poor-quality or off-brand combinations
- pin or protect specific looks, products, or placements where presentation matters
- review recommendation output quality and apply targeted overrides

### 5.2 Campaign and marketing operators

These users need to:

- align recommendation emphasis to campaign windows and seasonal moments
- activate approved campaign priorities across relevant surfaces
- avoid conflicts between ongoing campaign logic and evergreen recommendation behavior

### 5.3 Clienteling or styling leaders

These users need to:

- trust the governed recommendation base for assisted selling
- escalate or request overrides for premium or appointment-driven scenarios
- understand why a look is being emphasized or suppressed

### 5.4 Engineering and platform owners

These users remain responsible for:

- enforcing hard constraints, safety boundaries, and technical reliability
- providing the governance tools, data contracts, and traceability foundation
- defining which controls are configurable versus code-level changes
- protecting against unauthorized or structurally unsafe governance actions

### 5.5 Governance administrators or operations owners

These users need to:

- manage publication workflows and approval routing where required
- monitor override volume, rollback frequency, and change quality
- ensure recommendation governance stays consistent across markets and channels

## 6. Governance objects in scope

The platform must treat the following as governed recommendation objects:

### 6.1 Curated looks

Governance must support:

- authoring and revision of curated looks
- association of curated looks to anchors, categories, occasions, campaigns, markets, or surfaces
- publication state and effective-date control
- ability to protect curated looks from displacement when business intent requires it

### 6.2 Compatibility and suppression rules

Governance must support:

- business-owned compatibility guidance within allowed rule types
- exclusions for known bad combinations
- category or assortment restrictions where merchandising intent is valid
- suppression of products, looks, or combinations that should not appear

### 6.3 Campaign priorities

Governance must support:

- start and end boundaries for campaign influence
- prioritization of campaign-associated looks, products, or recommendation modules
- coexistence rules between campaign priorities and evergreen recommendation behavior
- explicit handling of market-specific or surface-specific campaign emphasis

### 6.4 Overrides

Governance must support:

- temporary and durable overrides
- targeted and broad-scope overrides
- pin, boost, suppress, replace, and fallback-to-default patterns where appropriate
- expiration and review expectations for overrides that should not remain indefinitely

### 6.5 Governance policies and publication states

Governance must support:

- draft versus active recommendation controls
- approval or review status where the business process requires it
- effective dating for planned changes
- rollback or deactivation for problematic changes

## 7. Override models and business intent

Merchandising teams need more than one kind of override. Downstream work must preserve distinct override patterns so operators can choose the least invasive control that solves the business problem.

### 7.1 Pin or protect override

Purpose:

- keep a curated look, product, or placement visible when campaign or brand presentation requires it

Business expectation:

- protected results remain visible unless a higher hard-constraint layer makes them ineligible
- protected placement behavior should be explicit in recommendation traces

### 7.2 Boost or deprioritize override

Purpose:

- increase or reduce relative visibility without fully forcing or removing a result

Business expectation:

- this model should be used when merchants want controlled influence but still allow governed ranking among valid candidates
- the effect should be bounded and measurable rather than opaque

### 7.3 Suppression override

Purpose:

- remove a product, look, or combination from recommendation eligibility because of quality, brand, assortment, or campaign conflict reasons

Business expectation:

- suppressions must take effect quickly enough for operational use
- suppressions need a reason code or equivalent audit context
- broad suppressions should be more visible and reviewable than narrow targeted suppressions

### 7.4 Replacement override

Purpose:

- substitute one governed result for another when a specific output is unacceptable or a preferred alternative is required

Business expectation:

- replacement should preserve compatibility and operating boundaries
- this should be used selectively for high-value corrections rather than as the default operating model

### 7.5 Fallback override

Purpose:

- force safer curated or rule-based behavior when confidence, campaign needs, or operational issues require temporary reduction of AI influence

Business expectation:

- fallback behavior should be available at a controlled scope such as a market, campaign, category, or surface
- fallback use must remain auditable because it materially changes the recommendation operating mode

### 7.6 Expiring emergency override

Purpose:

- support urgent operational correction without leaving permanent hidden logic behind

Business expectation:

- emergency overrides should have an expiration or explicit review trigger
- unresolved emergency controls should surface to operators as clean-up work rather than silently persisting

## 8. Precedence and operating boundaries

The governance model is incomplete unless downstream work preserves clear precedence between hard constraints, merchandising controls, and optimization layers.

### 8.1 Required precedence order

Downstream feature and architecture work must preserve this business interpretation of recommendation precedence:

1. **Hard eligibility and safety constraints:** policy restrictions, consent boundaries, inventory and assortment validity, and non-negotiable compatibility rules.
2. **Explicit customer and journey intent:** active anchor product, cart state, selected occasion, and other strong current-context signals.
3. **Governed merchandising controls:** suppressions, protected placements, campaign priorities, and approved overrides.
4. **Curated and rule-generated candidate composition:** governed curation and allowed compatibility logic define the candidate pool.
5. **AI-ranked optimization:** ranking operates only inside the candidate and control boundaries created above.
6. **Surface assembly and fallback behavior:** channel-specific assembly occurs after the earlier layers are applied.

### 8.2 What merchandising may control without engineering-only workflows

The governance model must allow authorized business operators to change, within guardrails:

- curated look content and activation
- approved compatibility or suppression rules within supported rule classes
- campaign priority windows and protected campaign emphasis
- targeted overrides and recommendation corrections
- fallback to safer governed recommendation behavior when operationally justified

### 8.3 What remains engineering-owned

The governance model must make clear that engineering still owns:

- the definition of supported control types and rule classes
- hard platform guardrails and non-bypassable constraints
- system reliability, latency, publication plumbing, and access controls
- core ranking methods, model deployment, and technical experimentation infrastructure
- changes that require new capabilities rather than new governed business inputs

### 8.4 Disallowed governance actions

Business self-service must not allow:

- bypassing hard compatibility or policy constraints
- creating hidden logic that cannot be traced back to an actor or reason
- permanent broad overrides without review or visibility
- market, surface, or campaign changes that exceed the supported governance scope without engineering support
- unmanaged direct edits that skip publication or audit pathways

## 9. Publication, review, and rollback expectations

Governance is not only about authoring controls; it is also about safely moving changes into production behavior.

### 9.1 Publication states

Downstream work must support business-recognizable change states such as draft, scheduled, active, expired, and rolled back, even if the exact technical representation differs.

### 9.2 Proportionate review model

The governance process should distinguish between:

- low-risk updates such as narrow curated-look edits or scheduled campaign activation
- medium-risk changes such as broader boost or suppression logic
- high-risk changes such as cross-market suppressions, premium-placement overrides, or changes that materially reduce AI influence

Higher-risk changes should require stronger review, clearer audit notes, or broader visibility, but routine operations should remain fast enough for merchandising use.

### 9.3 Rollback expectation

Operators must be able to deactivate or roll back problematic governance changes quickly enough to protect customer-facing recommendation quality without waiting for a full engineering release cycle.

### 9.4 Time-bound controls

Campaign priorities, emergency overrides, and seasonal adjustments should support explicit effective dates or expiration behavior so outdated controls do not silently distort recommendation outputs.

## 10. Auditability and traceability requirements

Recommendation governance must remain inspectable after the fact.

### 10.1 Minimum audit expectations

For each material governance action, downstream systems must preserve enough information to reconstruct:

- who created, edited, approved, activated, deactivated, or rolled back the change
- what object changed, including whether it was a look, rule, campaign priority, or override
- what scope the change affected, such as market, surface, category, anchor family, or campaign
- when the change became effective and when it ceased to apply
- why the change was made, including reason context or business intent
- whether the change was temporary, durable, emergency, or scheduled

### 10.2 Recommendation trace expectations

Each recommendation set materially shaped by governance must preserve enough trace context to show:

- whether curated looks contributed to the final result
- which campaign priority or override influenced the set
- whether a suppression or protection rule changed candidate eligibility or ordering
- whether AI ranking operated normally, under bounded override, or under fallback conditions
- recommendation set ID and trace ID continuity for downstream analysis

### 10.3 Audit interpretation expectation

Internal teams must be able to answer operational questions such as:

- why a recommended look appeared or disappeared
- whether a campaign priority overrode generic ranking
- whether an override was still active after its intended window
- whether repeated overrides indicate weak underlying rules or curation gaps
- whether governance changes caused measurable uplift or measurable quality regressions

## 11. Functional business requirements

### 11.1 Governed-self-service requirement

The platform must support merchandising self-service for curated looks, campaign priorities, compatibility or suppression inputs, and recommendation overrides within explicit platform guardrails.

### 11.2 Override-model requirement

The platform must support multiple override patterns, including protected placement, boost or deprioritize, suppression, replacement, and fallback-to-safer behavior, so operators can choose proportionate controls instead of relying on one blunt mechanism.

### 11.3 Governance-precedence requirement

Merchandising controls must take precedence over generic AI optimization, while still remaining subordinate to hard compatibility, policy, and eligibility constraints.

### 11.4 Campaign-priority requirement

The platform must support explicit campaign-priority behavior with effective dating, predictable precedence, and clear coexistence rules relative to evergreen recommendation logic.

### 11.5 Publication-lifecycle requirement

Governed recommendation changes must support a publication lifecycle that distinguishes draft, scheduled, active, expired, and rolled-back states or equivalent business-operable states.

### 11.6 Rollback-and-expiration requirement

The platform must allow rapid rollback and time-bound expiration of overrides, campaign priorities, and other material governance controls so outdated manual logic does not persist unnoticed.

### 11.7 Audit-trail requirement

Material governance actions must preserve an audit trail that records actor, scope, change type, effective time, reason context, and change lifecycle.

### 11.8 Recommendation-trace requirement

Each recommendation set materially affected by merchandising governance must preserve enough trace context to show which governance objects influenced the final output and how they interacted with ranking.

### 11.9 Operating-boundary requirement

Downstream designs must make explicit which recommendation controls are business-configurable and which remain engineering-owned platform capabilities.

### 11.10 Governance-health requirement

The platform must make override usage, rollback frequency, and recurring suppression patterns measurable so operators can distinguish healthy governance from over-manualization.

## 12. Success measures

### 12.1 Operational control measures

Downstream teams must be able to measure:

- percentage of routine merchandising changes completed without engineering-only workflows
- time to activate or correct campaign and curation changes
- time to suppress or correct poor recommendation outputs
- percentage of overrides that expire or are cleaned up as intended

### 12.2 Governance quality measures

Downstream teams must be able to measure:

- recommendation-quality incidents attributable to missing or incorrect governance
- frequency of broad versus narrow overrides
- rollback frequency after governance changes
- rate of repeated overrides on the same product families, looks, or surfaces

### 12.3 Audit and trust measures

Downstream teams must be able to measure:

- percentage of governed recommendation sets with valid recommendation set ID and trace ID
- percentage of governance actions with complete audit context
- percentage of active overrides with identifiable owner, reason, and effective window
- ability to attribute recommendation behavior changes to campaign, override, curation, or ranking causes

### 12.4 Business impact measures

Downstream teams must be able to measure:

- performance lift or protection during campaign-led recommendation moments
- quality improvement after targeted suppressions or replacements
- adoption of governance controls by merchandising teams across priority surfaces
- reduction in engineering involvement for routine recommendation operations

## 13. Phase expectations

### 13.1 Phase 1 foundation

Phase 1 should establish the minimum governance foundation required for the first recommendation loop:

- curated look management boundaries
- basic suppression and protected-placement controls
- campaign-priority behavior for important business moments
- audit visibility for material recommendation changes
- a clear distinction between business-operated controls and engineering-operated platform changes

### 13.2 Phase 2 expansion

Phase 2 should strengthen:

- richer override targeting by surface, market, and customer-context segment
- clearer governance reporting and health metrics
- stronger interaction rules between personalization and merchandising controls

### 13.3 Phase 3 maturity

Phase 3 should expand toward:

- broader multi-channel governance consistency
- more advanced workflow controls, review routing, and policy enforcement
- deeper governance analytics showing when manual controls are helping versus masking systemic quality gaps

## 14. Constraints and guardrails

- Governance controls must not allow business users to bypass hard compatibility, consent, privacy, or policy constraints.
- Recommendation governance must remain traceable at the level needed for operational and audit review.
- Campaign and override controls should not silently persist beyond their intended duration.
- Self-service governance must be strong enough for merchandising ownership without turning recommendation behavior into opaque manual logic.
- Governance design must support both RTW and later CM evolution, even if Phase 1 focuses on RTW-first recommendation flows.
- Customer-facing outputs must not expose internal governance reasoning in ways that are confusing or overly operational.

## 15. Assumptions

- Merchandising teams can own routine recommendation controls if the platform provides bounded, auditable self-service.
- Most day-to-day recommendation corrections should be possible through governed curation, suppression, campaign priorities, or targeted overrides rather than code changes.
- High override volume should be treated as a signal that underlying curation, rules, or ranking need improvement.
- Phase 1 can start with a narrower governance scope and still deliver meaningful business control if the core precedence, rollback, and audit expectations are explicit.

## 16. Open questions for downstream feature breakdown

- Which governance actions require explicit second-person review versus direct publication by authorized merchandisers?
- What scopes are needed first for override targeting: product, look, category, campaign, market, surface, or anchor family?
- Which override types should be temporary by default, and what expiration windows are acceptable by use case?
- How should campaign priorities interact with protected curated placements when both apply to the same recommendation slot?
- What governance-health thresholds should trigger review because manual controls appear to be masking deeper recommendation issues?
- What minimum audit fields are required to satisfy operational, legal, and regional policy expectations?

## 17. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for governed authoring and publication states for curated looks, campaign priorities, and overrides
2. feature scope for override types, targeting rules, expiration behavior, and rollback handling
3. feature scope for precedence rules between hard constraints, merchandising controls, curation, and AI ranking
4. feature scope for audit logging, recommendation traceability, and governance-health reporting
5. feature scope for role boundaries and business-operated versus engineering-operated control surfaces

## 18. Exit criteria check

This BR is complete when downstream teams can see:

- which governance objects merchandisers must be able to control
- which override models are needed and what business problem each solves
- what operating boundaries keep merchandising control inside safe platform guardrails
- how campaign priorities, curated protection, and AI ranking should interact
- what auditability and rollback expectations make recommendation governance trustworthy without engineering-only workflows

## 19. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-009-merchandising-governance.md`

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
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define exact permission boundaries, publication workflow detail, and override-targeting granularity.

Residual risks and open questions:

- Exact governance-role segmentation and publication workflow depth still require downstream feature and architecture decisions.
- Override overuse could mask deeper recommendation quality issues unless later artifacts define governance-health monitoring explicitly.
