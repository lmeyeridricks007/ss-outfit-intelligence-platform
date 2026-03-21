# BR-012: Identity and profile foundation

## Traceability

- **Board item:** BR-012
- **GitHub issue:** #119
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #119 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/architecture-overview.md`
- **Related inputs:** stable customer IDs, source-system mappings, identity confidence, profile service expectations, and cross-channel consistency needs
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs an identity and customer-profile foundation that lets recommendation behavior remain coherent across ecommerce, email, and later clienteling or assisted-selling surfaces without assuming that any single upstream system already has the full customer truth. The platform must define how stable customer identities are formed, how source-system identifiers map into those identities, how identity-confidence affects activation, what profile service behaviors downstream consumers can rely on, and how cross-channel consistency is preserved when different surfaces have different levels of context, freshness, and consent.

This business requirement defines:

- the business meaning of a stable canonical customer identity
- the minimum source-mapping and identity-confidence expectations needed for trustworthy personalization
- the profile-service behaviors required for recommendations and activation use cases
- the cross-channel consistency rules that keep recommendations from feeling disconnected or contradictory
- the fallback and governance expectations when identity, consent, or profile quality is weak

This BR does not define:

- the exact matching algorithm, vendor, or master-data implementation
- the final database schema, event-stream topology, or service deployment model
- the precise API payload fields or storage contracts for every profile attribute
- the detailed operational workflow for identity dispute handling or manual merge correction
- the final UI or CRM workflow for profile review by internal teams

## 2. Problem and opportunity

Personalized recommendation quality depends on having a trustworthy understanding of who the customer is. In practice, customer information comes from multiple systems, each with different identifiers, freshness, and reliability. Ecommerce may know a logged-in account or browser session, email may know a campaign recipient, loyalty may know a member identifier, and store systems may know an appointment or stylist relationship. If those identifiers are not mapped into a stable customer foundation, recommendations can become fragmented, repetitive, or inconsistent across channels.

The business problem is therefore broader than account lookup alone:

- the platform cannot assume one source-system identifier is globally reliable
- recommendation activation needs to know whether two records likely represent the same customer and how confident that conclusion is
- customer profiles need to preserve provenance, recency, and consent state rather than flattening all inputs into an unqualified profile
- different channels need a shared profile interpretation even when the available request context is different
- low-confidence identity should reduce or suppress profile-based personalization rather than silently producing assertive but unreliable outputs

The opportunity is to establish an identity and profile foundation that:

- makes complete-look recommendations more consistent for returning and cross-channel customers
- gives ecommerce, email, and later clienteling surfaces a shared profile baseline instead of competing customer interpretations
- improves trust in personal recommendation types by making identity confidence explicit
- reduces duplicate or contradictory recommendation behavior across channels
- creates a reusable customer foundation for later signal usage, experimentation, and activation work

## 3. Business outcomes

This requirement must support these outcomes:

1. **Stable customer continuity** so returning customers can be recognized across permitted systems without depending on one channel-specific identifier.
2. **Trustworthy profile-based personalization** so recommendation logic uses customer history and preferences only when identity confidence and consent justify it.
3. **Cross-channel recommendation consistency** so ecommerce, email, and clienteling consumers can draw from the same core customer understanding even when the presentation differs.
4. **Safer activation and fallback behavior** so low-confidence or low-quality identity states do not produce surprising, invasive, or contradictory personalization.
5. **Downstream readiness** for feature, architecture, and implementation work on identity-aware recommendation requests, profile retrieval, customer-signal usage, and activation governance.

## 4. Guiding business principles

All downstream work must preserve these principles:

### 4.1 Canonical customer identity is required, not optional

The recommendation platform must use a stable canonical customer identity model rather than assuming that account ID, email address, cookie, loyalty ID, or store-system ID alone is sufficient across all use cases.

### 4.2 Source mappings must remain explicit

When customer identities are linked across systems, the platform must preserve which source identifiers contributed to that linkage. Identity logic should be inspectable, not hidden inside opaque downstream behavior.

### 4.3 Identity confidence must shape activation

The platform must treat identity confidence as a business control. Lower-confidence identity may support continuity hints or cautious ranking influence, but it must not trigger strong cross-channel personalization as if certainty were established.

### 4.4 Profile data must preserve provenance and recency

A profile is not just a bag of attributes. Recommendation behavior must be able to distinguish durable preferences, recent behavior, operational state, and source provenance so downstream use remains trustworthy.

### 4.5 Shared profile interpretation matters more than identical channel behavior

Cross-channel consistency does not mean every surface shows the same recommendation module or the same exact payload. It means channels interpret the same customer foundation consistently within their own context, latency, and permission constraints.

### 4.6 Consent and regional policy outrank identity convenience

Being able to link a customer record does not automatically make every linked signal usable. Identity and profile capabilities must remain subordinate to consent, privacy, and regional policy boundaries.

### 4.7 Graceful degradation is part of the product

When identity is uncertain, stale, anonymous, or disallowed for activation, the platform must degrade gracefully to contextual, curated, or rule-based recommendation behavior rather than forcing profile-based personalization.

## 5. Scope and actor expectations

This BR must support the business needs of these actors:

### 5.1 Customers

Customers should experience:

- more continuity across repeat visits and channels when they are confidently recognized
- less repetition of obviously irrelevant or already-owned recommendations where profile knowledge permits suppression
- recommendations that feel coherent with prior purchases, preferences, and recent behavior without feeling invasive
- appropriate fallback to non-personalized recommendations when recognition is weak or unavailable

### 5.2 Ecommerce and digital teams

These teams need:

- a reliable way to request recommendation behavior for known, returning, and anonymous visitors
- confidence-aware access to profile context without recreating identity logic in each surface
- consistent customer interpretation across PDP, cart, and later homepage personalization

### 5.3 Marketing and lifecycle teams

These teams need:

- profile continuity strong enough to activate recommendation content in email and related journeys
- predictable boundaries for when cross-channel profile usage is allowed
- confidence that asynchronous activations are using durable and consented profile information rather than fragile session-only identity

### 5.4 Styling and clienteling teams

These teams need:

- customer continuity that can connect store context to broader recommendation behavior when policy allows
- a profile foundation that distinguishes structured relationship or appointment signals from more sensitive inputs
- traceability when profile-driven recommendations are used in assisted-selling contexts

### 5.5 Platform, data, and governance owners

These teams remain responsible for:

- maintaining the canonical customer identity foundation and source mappings
- enforcing confidence-aware activation and consent boundaries
- exposing profile-service behaviors that downstream consumers can depend on
- making profile freshness, provenance, and conflict states visible enough for safe operation

## 6. Canonical identity and source-mapping expectations

The platform must treat customer identity as a governed, canonical business object.

### 6.1 Stable canonical customer ID

Downstream work must preserve a durable customer identifier that represents the platform's best business-recognizable understanding of a customer across permitted systems.

Business expectations:

- the canonical customer ID must remain stable enough to support recommendation continuity, telemetry, and auditability
- downstream consumers should request recommendation behavior using the canonical customer ID when available rather than choosing their own source identifier precedence
- anonymous journeys may still exist, but the platform must clearly distinguish anonymous or session-only context from known-customer identity

### 6.2 Explicit source-system mappings

The identity foundation must preserve source mappings for identifiers such as:

- ecommerce account identifiers
- loyalty or CRM identifiers
- email platform recipient or subscriber identifiers where permitted
- store or appointment-system identifiers
- anonymous session or device-linked identifiers where relevant to continuity

Business expectations:

- source identifiers must remain attributable to the canonical customer identity
- conflicting or partial source mappings must remain visible as an identity-quality concern rather than being silently flattened
- downstream teams must be able to reason about which systems contributed to profile continuity

### 6.3 Identity state distinctions

The platform must distinguish at least these business-recognizable identity states:

- anonymous or session-only
- known in one source system only
- linked across multiple source systems with meaningful confidence
- disputed, conflicting, or uncertain identity where stronger personalization should be constrained

### 6.4 Identity confidence as a required profile attribute

Whenever profile continuity depends on linking multiple sources, the profile foundation must preserve identity-confidence or equivalent trust context.

Business expectations:

- confidence must be usable as an activation control, not only as an internal diagnostic
- confidence should influence whether recommendations can use broader historical or cross-channel profile data
- downstream reporting and traceability should show when lower-confidence identity influenced behavior

## 7. Customer profile service expectations

The platform needs a shared profile capability that recommendation and activation consumers can rely on.

### 7.1 Shared profile baseline

The profile service must provide a customer view that can support recommendation generation across channels, including where permitted:

- stable canonical identity
- linked source identifiers
- consent and suppression state relevant to activation
- derived preference or affinity signals
- order and purchase history summaries
- recency-aware browsing or engagement summaries
- structured store or appointment context where allowed
- profile quality indicators such as freshness, coverage, or conflict state

### 7.2 Provenance and recency visibility

Profile consumers must be able to distinguish:

- durable profile attributes versus short-lived behavioral context
- source-system origin for important profile elements
- signal recency when recommendation interpretation depends on freshness
- incomplete, stale, or conflicting profile conditions that should limit activation

### 7.3 Read behavior expectations

Downstream consumers should be able to rely on the profile service for:

- a shared customer interpretation across recommendation surfaces
- profile retrieval that does not require each consumer to rebuild source-resolution logic
- enough profile context to support known-customer personalization, suppression of obvious repetition, and consistent activation decisions

### 7.4 Update behavior expectations

The profile foundation must support profile updates from multiple source systems without requiring every surface to wait for perfectly real-time synchronization.

Business expectations:

- recommendation behavior should tolerate mixed freshness across profile inputs
- recent customer activity should become visible quickly enough for priority use cases such as repeat browsing or purchase-aware suppression
- downstream teams must be able to tell when the profile may lag behind the latest source event

### 7.5 Profile conflict visibility

When profile inputs disagree or remain incomplete, the platform must preserve enough visibility for downstream systems to reduce personalization strength, fall back safely, or route the case into later operational handling.

## 8. Cross-channel consistency requirements

Cross-channel consistency is a business outcome, not a requirement that every channel operate identically.

### 8.1 Shared customer interpretation

Recommendation consumers across ecommerce, email, and later clienteling must use the same underlying customer identity and profile interpretation when the same customer is recognized with sufficient confidence.

### 8.2 Consistent recommendation boundaries

If a customer is recognized across channels, the platform should preserve consistency in business-relevant behaviors such as:

- avoiding contradictory style or preference assumptions across channels
- reducing repeated promotion of clearly irrelevant or already-purchased items where permitted
- honoring the same consent and suppression constraints in each activation path
- carrying forward stable customer attributes that should influence recommendation logic beyond one session

### 8.3 Channel-appropriate differentiation

Cross-channel consistency must still allow channels to differ in:

- recommendation surface format and placement
- response timing and freshness expectations
- reliance on active session context versus durable profile traits
- eligibility for asynchronous activation such as email
- operator-assisted interpretation in clienteling contexts

### 8.4 Recency and conflict handling across channels

The platform must define business behavior for when one channel has fresher context than another.

Business expectations:

- fresher active-session context may override older broad-profile tendencies for that session
- asynchronous channels should rely more on durable and consented profile information than on fragile recent-session context
- conflicting signals across channels should not create unstable recommendation swings without visible confidence or freshness handling

### 8.5 Suppression and continuity expectations

Where permitted, the shared profile should help channels behave consistently about:

- already purchased anchor categories or obvious duplicate-item exposure
- stable size, fit, or preference tendencies when those are trustworthy and relevant
- suppression of recommendations that would look repetitive or out of step with recent known customer actions

## 9. Confidence-aware activation and fallback

Identity foundation work is incomplete unless downstream systems know how to behave when certainty is weak.

### 9.1 High-confidence activation

When identity confidence and consent are strong, downstream recommendation behavior may use broader customer profile history and cross-channel continuity to influence ranking, suppression, and recommendation-type selection.

### 9.2 Medium-confidence activation

When identity confidence is meaningful but not strong enough for assertive cross-channel personalization, the platform should allow bounded personalization such as:

- weaker ranking influence from durable traits
- cautious suppression of obvious duplicates where the risk of error is low
- stronger reliance on current-session or contextual signals than on broad historical assumptions

### 9.3 Low-confidence or uncertain activation

When identity confidence is weak, conflicting, or policy-limited, the platform must:

- avoid strong customer-specific personalization
- prefer contextual, curated, or rule-based recommendation behavior
- preserve traceability that identity quality limited personalization depth

### 9.4 Anonymous fallback behavior

Anonymous visitors should still receive high-quality recommendation behavior through anchor-product, context-aware, curated, and rule-based logic. Identity foundation must improve known-customer continuity without making anonymous recommendation quality an afterthought.

### 9.5 Respectful customer experience requirement

Confidence-aware activation must prevent recommendation behavior that feels invasive, overly certain, or inconsistent with the actual quality of recognition.

## 10. Functional business requirements

### 10.1 Canonical-identity requirement

The platform must support a stable canonical customer identity that can unify permitted source-system identifiers for recommendation, telemetry, and activation use cases.

### 10.2 Source-mapping requirement

The platform must preserve explicit mappings between canonical customer identity and relevant source-system identifiers rather than assuming one upstream identifier is universally sufficient.

### 10.3 Identity-confidence requirement

The platform must preserve identity-confidence or equivalent trust context whenever customer continuity depends on cross-source linkage, and that confidence must influence personalization depth and activation eligibility.

### 10.4 Shared-profile requirement

The platform must provide a shared profile capability that recommendation consumers can use to access canonical identity, relevant history, derived customer traits, consent state, and profile quality context.

### 10.5 Provenance-and-recency requirement

Customer profiles must preserve enough provenance and recency context to distinguish durable traits, recent behavior, stale signals, and incomplete profile conditions.

### 10.6 Cross-channel-consistency requirement

When the same customer is recognized with sufficient confidence, recommendation and activation consumers must rely on a shared customer interpretation that supports consistent profile-based behavior across channels.

### 10.7 Consent-and-policy-boundary requirement

Identity and profile usage must remain bounded by consent, regional policy, and allowed-signal rules; linked identity does not automatically make every linked signal activation-ready.

### 10.8 Confidence-aware-fallback requirement

When identity is anonymous, weak, conflicting, stale, or policy-limited, the platform must reduce or suppress profile-based personalization and fall back to contextual, curated, or rule-based recommendation behavior.

### 10.9 Profile-quality-visibility requirement

The platform must make profile freshness, coverage, and conflict state visible enough for downstream teams to understand when recommendation behavior is operating on incomplete or degraded customer understanding.

### 10.10 Traceability requirement

Recommendation traces and downstream analytics must preserve enough identity and profile context to show whether canonical identity, source linkage, confidence, or fallback state materially affected recommendation behavior.

## 11. Surface and phase expectations

### 11.1 Phase 1 foundation

Phase 1 should establish the minimum identity and profile foundation needed for the first recommendation loop:

- stable canonical customer IDs for known-customer continuity
- explicit source-system identifier mappings
- identity-confidence visibility for cross-source linking
- a profile baseline strong enough for first personalization and activation decisions
- safe fallback behavior for anonymous, uncertain, or policy-limited identity states

### 11.2 Phase 1 surface interpretation

- **PDP and cart:** use active session and anchor context first, with known-customer profile influence only when identity confidence and freshness support it.
- **Homepage / web personalization:** expand profile-driven continuity only when the identity foundation is strong enough to support returning-customer interpretation consistently.
- **Email:** rely on durable, consented, and confidence-appropriate profile traits rather than fragile short-lived session assumptions.
- **Clienteling:** introduce richer profile continuity later with strong attention to structured store context, identity confidence, and policy-safe use.

### 11.3 Phase 2 expansion

Phase 2 should strengthen:

- richer cross-channel profile activation beyond the first ecommerce loop
- stronger suppression and continuity logic based on reliable known-customer history
- broader use of profile-driven recommendation types where identity confidence is strong
- clearer operational visibility into profile conflicts, freshness issues, and activation coverage

### 11.4 Phase 3 maturity

Phase 3 should expand toward:

- deeper multi-channel profile consistency across ecommerce, email, and clienteling
- more mature profile-quality operations and identity-governance handling
- stronger downstream analytics for measuring the business value of identity-linked continuity

### 11.5 Phase sequencing rule

Later-phase personalization and activation should expand only when earlier phases can preserve:

- stable canonical customer IDs
- explicit source mappings
- visible identity confidence
- consent-aware activation boundaries
- trustworthy fallback behavior when identity quality is not strong enough

## 12. Success measures

### 12.1 Continuity and activation measures

Downstream teams must be able to measure:

- percentage of known-customer recommendation requests resolved to a stable canonical customer ID
- percentage of cross-channel recommendation activations using an explicit identity-confidence state
- coverage of source-system mappings for priority customer systems
- rate of profile-based recommendation requests that must fall back because identity quality or consent is insufficient

### 12.2 Recommendation-quality measures

Downstream teams must be able to measure:

- improved engagement, attachment, or conversion for confidently recognized returning customers versus weaker-identity baselines
- reduction in clearly repetitive or contradictory recommendation behavior for known customers
- consistency of recommendation behavior across priority channels for the same recognized customer segments

### 12.3 Operational trust measures

Downstream teams must be able to measure:

- percentage of identity-linked recommendation sets with valid recommendation set ID and trace ID
- percentage of profile-driven recommendation decisions with recorded identity-confidence and fallback context
- visibility into profile freshness, conflict, or coverage issues that limit activation quality
- rate of recommendation issues attributable to incorrect linkage, stale profile context, or profile-policy violations

### 12.4 Governance and privacy measures

Downstream teams must be able to measure:

- percentage of profile-based activations that respected consent and suppression rules
- rate of profile-driven recommendation incidents involving policy-gated or disallowed signals
- percentage of downstream activation paths using the shared customer interpretation rather than channel-local identity logic

## 13. Constraints and guardrails

- Identity foundation must not assume one channel or source-system identifier is globally authoritative without explicit mapping.
- Profile-based personalization must not bypass compatibility, merchandising, consent, privacy, or regional policy constraints.
- Low-confidence or conflicting identity must not be treated as certain merely to increase personalization coverage.
- Cross-channel consistency should not force every surface to use identical payloads or timing when their context differs materially.
- Customer-facing experiences must not expose sensitive profile reasoning or identity uncertainty in ways that feel invasive or confusing.
- Downstream designs must tolerate mixed latency and uneven profile completeness across source systems.

## 14. Assumptions

- Priority source systems can provide enough stable identifiers to support an initial canonical customer foundation.
- Identity-confidence can be exposed in a way that business rules and recommendation logic can act on safely.
- Phase 1 does not need perfect real-time profile unification across every system in order to produce meaningful continuity improvements.
- Shared customer interpretation is more valuable than channel-specific identity shortcuts when the goal is durable personalization and activation.
- Anonymous and low-confidence journeys will remain important and must continue to receive strong non-personalized recommendation behavior.

## 15. Open questions for downstream feature breakdown

- Which source systems form the Phase 1 identity graph of record: ecommerce account, CRM, loyalty, email, store appointment, or some narrower subset?
- What confidence thresholds should distinguish high-confidence, bounded, and low-confidence personalization on each priority surface?
- Which profile attributes are considered durable enough for asynchronous channels such as email, and which should stay limited to active digital sessions?
- How should downstream systems handle identity conflicts or split/merge corrections when prior recommendation telemetry already exists?
- Which structured store and appointment signals are approved first for profile use, and which remain policy-gated?
- What minimum freshness expectations apply to profile summaries that suppress already-purchased or already-viewed items across channels?

## 16. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for canonical customer ID creation, source-system mapping, and identity-state handling
2. feature scope for identity-confidence-aware personalization gating and fallback rules
3. feature scope for shared customer profile retrieval, provenance, recency, and quality indicators
4. feature scope for cross-channel consistency rules across ecommerce, email, and later clienteling consumers
5. feature scope for profile traceability, consent-aware activation, and identity-related operational reporting

## 17. Exit criteria check

This BR is complete when downstream teams can see:

- what stable canonical customer identity means for the recommendation platform
- how source-system mappings and identity confidence must support personalization and activation safely
- what behaviors downstream consumers should expect from the shared customer profile capability
- what cross-channel consistency means and does not mean for recommendation behavior
- how the platform must fall back when identity or profile quality is weak, conflicting, or policy-limited

## 18. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-012-identity-and-profile-foundation.md`

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
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define exact source-system scope, confidence thresholds, and profile-conflict operating details.

Residual risks and open questions:

- Cross-channel consistency still needs downstream feature and architecture decisions about freshness windows and conflict resolution so channels do not overfit stale profile assumptions.
- The business value of broader profile activation depends on disciplined consent handling and clear decisions about which store or marketing signals are approved first.
