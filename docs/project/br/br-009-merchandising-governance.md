# BR-009: Merchandising governance

## Purpose
Define the business requirements for governing curated looks, merchandising rules, overrides, campaign priorities, approval boundaries, and auditability so downstream feature, architecture, and implementation work can preserve operator control without weakening recommendation quality, brand coherence, or traceability.

## Practical usage
Use this artifact to guide feature breakdown for governance control taxonomy, rule and override workflows, campaign-priority handling, approval models, audit tooling, rollback behavior, and operating boundaries across ecommerce, marketing, clienteling, and admin surfaces.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #146
- **Board item:** BR-009
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for merchandising-control taxonomy, override workflows, campaign governance, approval-boundary handling, admin tooling, and audit review workflows

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/goals.md`
- `docs/project/industry-standards.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/data-standards.md`
- `docs/project/glossary.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must provide a governed merchandising control layer that lets authorized operators influence recommendation behavior without relying on ad hoc engineering changes and without allowing optimization systems to bypass business intent.

For BR-009, merchandising governance means the platform must make all recommendation-affecting controls explicit across:
- **curated looks and curated priorities**
- **compatibility, policy, and eligibility rules**
- **campaign priorities and scheduled activations**
- **manual and automated overrides**
- **approval boundaries by control risk**
- **audit history, traceability, and rollback**

The governance layer must answer all of the following for every meaningful control:
- who can create or change it
- where it applies by market, channel, surface, recommendation type, and mode
- when it starts, ends, or expires
- whether it is a hard rule, a soft preference, a campaign influence, or an override
- what it is allowed to outrank
- what approval path is required before activation
- how operators can audit, explain, and reverse it

Recommendation behavior must remain governed even when the platform uses AI ranking, customer signals, contextual inputs, experimentation, or later channel expansion. Governance is therefore a production requirement, not an admin convenience feature.

## Business problem
SuitSupply needs recommendation outputs to feel curated, brand-safe, and operationally intentional even as the platform expands into more surfaces, more context-aware ranking, and stronger personalization. That outcome is not sustainable if every campaign or exception requires engineering intervention, and it is not trustworthy if merchandisers cannot see or control how recommendations were shaped.

Without explicit merchandising governance:
- recommendation behavior may drift away from brand or campaign intent
- curated looks may conflict with rules, inventory, or personalization without a clear resolution model
- operators may use manual overrides that are invisible, overbroad, or never retired
- campaign priorities may conflict across surfaces or markets with no deterministic tie-breaker
- premium and CM scenarios may receive the same control flexibility as low-risk RTW attachment flows when they need stricter review
- downstream teams may implement inconsistent approval, precedence, and rollback behavior across APIs and tooling
- audits may show that a recommendation changed, but not who changed it, why it changed, or when the change should have expired

## Users and stakeholders
### Primary customer-facing beneficiaries
- **Persona P1: Anchor-product shopper** who benefits when recommendations remain coherent, sellable, and aligned with current merchandising intent
- **Persona P2: Returning customer** who benefits when personalization operates inside brand-safe and campaign-safe boundaries
- **Persona P3: Occasion-led shopper** who benefits when seasonal and campaign direction remain deliberate rather than arbitrary

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs recommendation behavior that can be trusted, explained, and overridden only through visible governed paths
- **Persona S2: Merchandiser** who needs curated look management, rule controls, campaign priorities, exclusions, and override tools without relying on engineering-only workflows
- **Marketing and CRM operators** who need campaign influence on recommendation outputs with clear scope, schedule, and precedence boundaries
- **Persona S4: Product, analytics, and optimization team member** who needs measurable visibility into governance effects, override frequency, and recommendation changes caused by operator controls

## Desired outcomes
- Merchandisers can guide recommendation behavior through explicit governed controls rather than hidden process knowledge or repeated engineering requests.
- Curated looks, rules, campaigns, and overrides remain distinguishable so operators understand the control stack.
- Campaign and override behavior follow deterministic precedence rather than case-by-case interpretation.
- Higher-risk recommendation changes require stronger review and narrower permissions than routine low-risk adjustments.
- Overrides are bounded, attributable, reviewable, and reversible rather than permanent undocumented exceptions.
- Recommendation set traces show which governance controls affected eligibility, ranking, suppression, pinning, or fallback.
- Downstream feature and admin tooling work can implement governance controls without guessing which actors, approvals, and scopes apply.

## Governance scope and business boundary
This BR defines how merchandising control operates over recommendation behavior. It governs the business semantics of controls, approvals, precedence, traceability, expiry, and rollback.

For BR-009, merchandising governance includes:
- curated look authoring, activation, and priority handling
- hard and soft merchandising rules
- exclusions, suppressions, pinning, boosts, and mandatory inclusions
- campaign scheduling and conflict resolution
- operator and system override models
- approval boundaries based on risk, scope, and permanence
- audit expectations for all recommendation-affecting changes
- rollback and expiration expectations for temporary or emergency controls

This BR does not define:
- final admin UI screens or workflow layouts
- final API schemas for governance objects
- exact organizational role names in every market
- exact numeric boost formulas or scoring functions
- final database design for control storage

## Governance input taxonomy
### Control families
The platform must treat the following governance inputs as distinct business control families with explicit semantics.

| Control family | What it governs | Typical operator intent | Control nature | Minimum governance expectation | If absent or weak |
| --- | --- | --- | --- | --- | --- |
| Curated looks and curated priorities | brand-approved looks, grouped items, fixed or reorderable presentation, premium examples, seasonal direction | keep recommendation outputs aligned with styling intent and storytelling | curated source control | explicit scope, owner, activation window, and reorder policy | fall back to rule-safe defaults or catalog completion; do not pretend curation exists |
| Compatibility and policy rules | category compatibility, color or pattern limits, market policy, premium boundaries, exclusions, assortment constraints | protect recommendation safety, validity, and brand fit | hard rule or soft rule | rules must declare whether they are blocking, demoting, or advisory | treat missing rule coverage as reduced confidence and narrower outputs, not unrestricted ranking freedom |
| Campaign priorities | seasonal pushes, launches, event-driven focus, channel campaigns, market-specific emphasis | influence recommendation emphasis for a time-bounded business objective | scheduled priority control | explicit start and end windows, scope, approval, and precedence class | campaign behavior should not be simulated through undocumented manual changes |
| Overrides and suppressions | emergency removals, temporary pins, bounded replacements, operator-directed exceptions | correct live recommendation behavior quickly without code changes | temporary exception control | reason, actor, scope, expiry, and post-change review are required | use standard governed rules and campaign priorities; do not leave unknown exceptions in effect |
| Approval boundaries | who can activate, review, or approve changes by risk level | keep higher-risk controls from activating without adequate oversight | workflow governance control | risk class, approver requirement, and emergency path must be explicit | teams drift into inconsistent approval practices across channels |
| Audit and rollback controls | version history, change diff, trace linkage, revert path, review visibility | explain what changed and safely undo it | accountability control | before/after state, timestamps, actor, rationale, and effective window must be retained | behavior becomes hard to troubleshoot and impossible to govern consistently |

### Required distinctions
Governance controls must not be collapsed into one generic "rule" concept. At minimum the system must distinguish:
- curated content from rule-based controls
- hard rules from soft rules
- campaign priorities from ongoing baseline rules
- temporary overrides from persistent configuration
- emergency actions from routine planned changes
- approved controls from draft or inactive controls

## Governance control model
### Curated look governance
Curated looks are first-class business controls, not static content decorations. Governance must support:
- explicit ownership of each curated look or curated look set
- scope by market, channel, surface, recommendation type, and RTW or CM mode
- activation windows for seasonal, event, and campaign relevance
- fixed-order versus reorderable-within-set behavior
- eligibility for use as seed content, fallback content, or pinned output
- retirement and archive behavior so stale curation does not silently persist

Curated look governance must also define whether a curated look:
- can be completed with non-curated compatible items
- can be reordered by AI ranking
- can outrank broader campaign boosts
- is limited to premium, CM, assisted-selling, or high-trust contexts

### Rule governance
Merchandising rules must declare their business role rather than relying on informal operator knowledge.

At minimum, each rule must preserve:
- stable rule ID
- control type
- hard or soft designation
- scope
- owner
- rationale
- effective window
- approval state
- linked campaign or business context where relevant

The rule model must distinguish among:
- **hard exclusions:** items or combinations that must not surface
- **hard inclusions or mandatory constraints:** requirements that must hold for exposure
- **soft preferences:** scoring or tie-breaking guidance
- **boosts or demotions:** controlled directional influence
- **pins or fixed placements:** items or looks that must appear in a governed position

### Override governance
Overrides exist to change normal recommendation behavior deliberately and visibly. The platform must support at least these override classes:
- **manual override:** operator-directed exception for a defined scope and duration
- **scheduled override:** future-dated exception tied to a planned event or campaign
- **emergency override:** immediate suppress, replace, or pin action used to contain brand, operational, or recommendation-quality risk
- **system-applied override:** deterministic non-human control triggered from a governed policy, such as auto-suppressing expired campaign content or low-trust outputs

Override behavior must never be silent. Every override must preserve:
- initiating actor or system process
- reason code and human-readable rationale
- effective start time
- expiry or review deadline
- affected scope
- affected control family
- approval path used
- rollback capability

## Campaign governance and precedence
### Campaign control expectations
Campaigns must be governable as explicit recommendation influences rather than informal marketing requests. Campaign controls must support:
- market- and surface-specific scope
- recommendation-type specificity
- bounded start and end dates
- priority level relative to other campaigns and baseline logic
- relationship to curated looks, pins, boosts, and suppressions
- visibility into whether the campaign can influence ranking, candidate inclusion, or only presentation order

Campaign controls must not be allowed to behave like permanent baseline rules unless they are formally promoted into a persistent governed control.

### Required precedence principles
- Hard safety, policy, compatibility, and eligibility boundaries always outrank campaign goals.
- Explicit suppressions and exclusions outrank boosts and generalized campaign pressure.
- Temporary emergency overrides may outrank normal campaign behavior only for the duration of the documented risk response.
- Pinned or mandatory campaign controls must be explicit; broad campaign boosts must not behave like hidden pins.
- AI ranking may optimize inside the remaining allowed set but must not invent campaign authority that was not granted by governance.

### Required campaign and control precedence order
Downstream work must preserve a deterministic precedence model at least this strong:

1. **Hard eligibility, policy, and compatibility gates**
   - consent boundaries, market and assortment rules, inventory validity, premium restrictions, and rule-based disqualifiers
2. **Hard suppressions and hard exclusions**
   - blocked products, blocked looks, blocked combinations, and governance-enforced removals
3. **Emergency overrides and incident-response controls**
   - time-bounded actions used to stop harmful, invalid, or brand-risking output
4. **Approved mandatory inclusions, fixed pins, and curated fixed-order controls**
   - campaign pins, curated must-show items, or approved fixed-order look controls
5. **Approved campaign priorities and scoped boosts**
   - seasonal, launch, market, or channel priorities that influence what eligible candidates rise higher
6. **Soft preferences and AI ranking within allowed freedom**
   - personalization, context weighting, commercial optimization, or softer merchandising guidance
7. **Deterministic fallback behavior**
   - safer governed defaults when the control stack still cannot produce a strong recommendation set

### Conflict resolution rules
When multiple active campaign or governance controls conflict at the same precedence class:
- the more specific scope wins over the broader scope
- explicit fixed pinning wins over generic boosting
- the higher approved business priority wins over lower priority
- if priority is equal, the more recent approved effective version may win only as a deterministic tie-breaker and must remain auditable

No downstream implementation may rely on undefined campaign tie behavior in production recommendation delivery.

## Approval boundaries and risk model
### Governance risk classes
Not all recommendation controls carry the same business risk. The platform must distinguish low-, medium-, high-, and emergency-risk changes so approvals, permissions, and audit requirements stay proportional.

| Risk class | Typical examples | Why it matters | Minimum approval boundary |
| --- | --- | --- | --- |
| Low | reorder curated items within an already approved set; schedule a scoped campaign boost within an approved window; adjust a soft preference for one surface | limited blast radius and reversible without violating hard policy | authorized operator may activate if scope and rationale are recorded |
| Medium | create or materially reprioritize a campaign across a market; add or remove notable exclusions for a recommendation type; change reorderability of curated content on a major surface | broader customer impact and higher risk of conflicting business intent | second reviewer or named approver required before activation |
| High | change hard compatibility or brand rules; alter approval boundaries; grant broader override permissions; change premium or CM control behavior for customer-facing use | can change safety, brand, policy, or premium trust boundaries | named approver required; rollout and rollback path must be documented |
| Emergency | immediate suppressions or forced replacements to contain live brand, catalog, or recommendation-quality incidents | rapid containment is necessary but misuse is risky | may bypass normal pre-approval only with strict expiry, rationale, and post-change review requirements |

### Approval requirements
Approval boundaries must be explicit for:
- persistent versus temporary controls
- broad versus narrow scope
- customer-facing versus operator-only usage
- RTW standard flows versus CM or premium flows
- routine merchandising changes versus incident response

At minimum, downstream tooling and workflows must preserve:
- draft versus approved versus active states
- approver identity when approval is required
- scheduled activation without bypassing the recorded approval path
- post-hoc review for emergency actions
- automatic expiration or review reminders for temporary controls

### Premium and CM boundaries
CM, premium, and high-trust clienteling contexts require stricter governance than routine RTW attachment flows. Governance must define:
- who may activate or override premium recommendation behavior
- whether curated content in premium contexts is fixed-order, curated-first, or mixed-source
- what degree of manual override is allowed in assisted-selling versus customer-facing experiences
- how CM-specific compatibility or styling exceptions are reviewed and retired

## Auditability and accountability requirements
### Minimum audit record
Every recommendation-affecting governance change must preserve enough information for operators to reconstruct what changed and why. At minimum, audit records must include:
- stable control ID and version
- control family and precedence class
- actor or system process
- approval actor where applicable
- created, approved, activated, expired, and revoked timestamps
- scope by market, channel, surface, recommendation type, and mode
- reason code and rationale
- before and after values or an equivalent change diff
- linked campaign, look, or rule IDs where relevant

### Recommendation trace linkage
Governance audit history must be connectable to live recommendation behavior. Downstream systems must preserve enough linkage to determine:
- which control IDs affected a recommendation set
- whether the set was influenced by curated control, campaign pressure, override, or baseline rule logic
- whether the result came from normal governed operation or an emergency or degraded path
- which recommendation set ID and trace ID correspond to the affected output and downstream events

### Review and rollback expectations
- Operators must be able to see active and recently expired overrides separately from baseline configuration.
- Expired controls must stop affecting delivery automatically unless explicitly renewed through a governed path.
- Rollback must restore prior governed state rather than require manual reconstruction from memory.
- Governance history must support internal review of recommendation shifts when performance, trust, or brand outcomes change.

## Operating boundaries for recommendation behavior
### Non-negotiable boundaries
- AI ranking, experimentation, or personalization must not bypass approved merchandising governance.
- No control may silently operate outside its declared scope.
- Customer-facing recommendation behavior must not depend on undocumented operator knowledge or off-platform instructions.
- Temporary overrides must not become permanent baseline behavior by neglect.
- Campaign intent must not override hard safety, compatibility, operational validity, consent, or premium-governance boundaries.

### Boundary between governance and optimization
Governance defines the allowed operating envelope. Optimization operates inside that envelope. Therefore:
- governance decides what is allowed, pinned, suppressed, fixed, or review-gated
- optimization decides how to order or choose among the remaining allowed candidates
- analytics measures the effect of both without confusing one for the other

### Boundary between governance and implementation
Downstream architecture and admin-tooling work must not change the meaning of control types. The business requirement is for stable semantics first; implementation may vary only if it preserves:
- control family distinction
- precedence determinism
- approval-boundary enforcement
- audit completeness
- rollback and expiry behavior

## Cross-surface and cross-mode implications
### Ecommerce PDP and cart
- Governance must prioritize dependable customer-facing control behavior for Phase 1 RTW flows.
- Curated look control, exclusions, campaign priorities, and overrides must apply consistently enough that operators can reason about recommendation changes on high-intent surfaces.
- Emergency suppressions must be fast, visible, and bounded because these surfaces have immediate revenue and brand impact.

### Homepage, inspiration, and occasion-led experiences
- Campaign and seasonal priorities may be more influential here than on PDP or cart, but they still require explicit precedence and expiry.
- Broad inspiration behavior must not become an excuse for weak governance or hidden boosts.

### Email and lifecycle marketing
- Campaign governance must reflect scheduled send timing and the risk that products, context, or priorities change between generation and exposure.
- Marketing influence must remain bounded by consent, suppression, and merchandising-control rules.

### Clienteling and assisted selling
- Operators may need narrower controlled flexibility, but recommendation changes still require visible auditability.
- Stylist-facing and customer-facing override freedoms must remain distinguishable.

### RTW and CM
- RTW may allow broader low-risk routine merchandising control where compatibility and availability are well governed.
- CM and premium scenarios require stricter review, narrower override freedom, and stronger curated or rule-based control visibility.

## Phase and rollout expectations
### Phase 1: Core ecommerce RTW governance foundation
Phase 1 should establish:
- curated look governance as a first-class control
- hard-rule versus soft-rule distinction
- campaign scheduling and priority handling for early ecommerce surfaces
- visible override classes with expiry and rationale
- audit records linked to recommendation set IDs and trace IDs
- risk-based approval boundaries for routine versus emergency changes

### Phase 2: Context and personalization expansion
Governance must expand to:
- explicitly bound how personal and contextual ranking interact with campaigns and curated priorities
- prevent personalization from silently overpowering campaign or brand intent
- keep approval and audit visibility as more recommendation inputs influence ranking

### Phase 3: Operator scale and channel expansion
Governance should expand to:
- richer admin workflows and role-based control management
- broader cross-channel consistency for campaign and override behavior
- stronger visibility into cross-surface control effects and operational review

### Phase 4: CM depth and advanced optimization
Later work should:
- apply stricter premium and CM approval boundaries
- support tighter curated-first or governed mixed-source policies for premium contexts
- allow more advanced optimization only after governance and audit behavior are proven trustworthy

## Scope boundaries
### In scope
- business definitions for governance control families
- precedence and conflict-resolution expectations
- override models and their required guardrails
- approval boundaries by control risk and scope
- audit, expiry, and rollback expectations
- operating boundaries between governance, optimization, and downstream tooling

### Out of scope
- final UI designs for governance consoles
- final RBAC implementation or identity-provider choice
- exact API schema for rule, campaign, or override payloads
- exact numeric campaign boost strengths
- final incident-management process outside recommendation-governance effects

## Dependencies
- `BR-001` complete-look recommendation capability for the customer-facing outcomes governance is protecting
- `BR-002` multi-type recommendation support for type-level control scope and override behavior
- `BR-003` multi-surface delivery for consistent governance semantics across channels
- `BR-004` RTW and CM support for mode-specific approval and override boundaries
- `BR-005` curated plus AI recommendation model for source precedence and allowed ranking freedom
- `BR-006` customer signal usage for personalization-suppression and consent-safe governance boundaries
- `BR-007` context-aware logic for campaign, season, and contextual precedence interactions
- `BR-008` product and inventory awareness for hard operational and assortment constraints
- `BR-010` analytics and experimentation for measuring override usage, campaign impact, and governance outcomes
- `BR-011` explainability and auditability for recommendation-trace reconstruction and operator review
- `BR-012` identity and profile foundation for confidence-aware personalization controls and suppression handling

## Constraints
- Merchandising governance must remain stronger than any optimization strategy that seeks more relevance or conversion.
- Control semantics must remain stable enough that downstream tooling and delivery surfaces do not invent local interpretations.
- Temporary overrides must be bounded by time, scope, and review rather than acting as invisible permanent configuration.
- Cross-surface consistency matters, but premium and CM contexts may require stricter control than standard RTW flows.
- Auditability must exist from the first production release, not only after operator tooling matures.

## Assumptions
- Merchandising, styling, and marketing teams are willing to maintain curated looks, campaign controls, and override workflows as part of normal operations.
- The platform can assign stable IDs to rules, campaigns, looks, controls, and recommendation traces.
- Downstream contracts can carry recommendation set IDs, trace IDs, and enough governance metadata for audit and troubleshooting.
- Phase 1 prioritizes dependable control and visibility over sophisticated control-authoring UX.
- Emergency overrides will be rare and should therefore be strongly bounded rather than optimized for everyday use.

## Missing decisions
- Missing decision: which operator roles may self-approve medium-risk campaign and curation changes versus requiring a second approver.
- Missing decision: what maximum duration or renewal policy should apply to emergency overrides before automatic expiration.
- Missing decision: which surfaces should default to fixed curated order versus reorderable-within-curated-set behavior.
- Missing decision: how campaign priority should interact with stronger personalization on homepage or occasion-led surfaces in later phases.
- Missing decision: what exact review requirements should apply before CM or premium customer-facing overrides can go live.

## Downstream implications
- Feature breakdown work must separate governance control families so admin and delivery work do not collapse rules, campaigns, and overrides into one ambiguous model.
- Architecture work must preserve deterministic precedence evaluation, control versioning, expiry handling, and trace linkage to recommendation set IDs and trace IDs.
- Admin-tooling work must support scope selection, approval-state visibility, expiry, rollback, and audit diff review as first-class capabilities.
- Delivery contracts must expose enough metadata that operators can tell whether results were baseline governed behavior, campaign-influenced behavior, or override-driven behavior.
- Analytics work must measure recommendation outcomes alongside campaign influence, override usage, suppression reasons, and emergency-control frequency so optimization does not reward poorly governed behavior.

## Review snapshot
Trigger: issue-created automation from GitHub issue #146.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, goals, industry standards, product overview, roadmap, data standards, and existing BR artifacts provide enough context to define governance controls, override models, campaign precedence, audit expectations, and approval boundaries without inventing implementation-specific UI or storage details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before finalizing role-specific approvals, emergency-override TTLs, and premium or CM review mechanics.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-009 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for role-specific approval policy, emergency-override duration, and premium or CM governance workflow details.
