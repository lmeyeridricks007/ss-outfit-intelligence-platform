# BR-012: Identity and profile foundation

## Purpose
Define the business requirements for customer identity resolution and style profile foundations so downstream feature, architecture, and implementation work can personalize recommendations, apply suppressions safely, and keep recommendation behavior consistent across ecommerce, marketing, and clienteling channels.

## Practical usage
Use this artifact to guide downstream feature breakdown for canonical customer identity handling, source-system mapping, confidence-aware profile activation, suppression logic, profile-service contracts, and cross-channel consistency rules that support personalization and activation without hiding uncertainty.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #149
- **Board item:** BR-012
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for identity resolution, profile-service behavior, suppression and consent-safe activation, cross-channel profile consistency, and confidence-aware personalization controls

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/goals.md`
- `docs/project/architecture-overview.md`
- `docs/project/data-standards.md`
- `docs/project/domain-model.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/standards.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must maintain a stable canonical customer identity and a usable style profile that can be shared across recommendation surfaces without pretending certainty where identity, consent, freshness, or provenance are weak.

For BR-012, identity and profile foundation means the platform must provide all of the following:
- **stable canonical customer IDs with preserved source-system mappings**
- **explicit identity-resolution confidence and provenance**
- **a style profile separated from raw identity so uncertainty and consent can be managed safely**
- **profile-service behavior that exposes usable recommendation context, not channel-specific guesswork**
- **suppression logic for duplicates, opt-outs, unsuitable content, and low-confidence activation**
- **cross-channel consistency rules so ecommerce, email, and clienteling use one governed customer foundation**
- **graceful degradation when identity or profile certainty is limited**

The identity and profile foundation must answer all of the following for a recommendation decision:
- who the platform believes the customer is, if known
- which source-system identifiers contributed to that belief
- how confident the platform is in the resolved identity
- which style-profile elements are safe and current enough to use
- which suppressions or activation boundaries apply
- how the same customer context should remain consistent across ecommerce, marketing, and clienteling surfaces

Identity and profile foundation is therefore a core business requirement for Phase 2 personalization expansion, not an implementation detail to improvise later within each channel.

## Business problem
SuitSupply wants to deliver more relevant complete-look, contextual, and personal recommendations to returning customers and assisted-selling journeys, but personalization becomes unsafe and inconsistent if each surface invents its own customer identity logic or profile interpretation.

Without explicit identity and profile requirements:
- ecommerce, email, and clienteling may apply different customer mappings and produce contradictory recommendations
- channels may over-trust a weak identity match and use the wrong purchase or style history
- personalization quality may look inconsistent because profile freshness, provenance, and suppression rules differ by channel
- operators may not know whether a recommendation came from durable profile context, session intent, or fallback defaults
- opt-outs, suppression rules, and profile-safe activation may be enforced in one channel but bypassed in another
- downstream teams may flatten identity and profile into one opaque record, making confidence and consent impossible to manage explicitly
- cross-channel activation may happen before the identity foundation is dependable enough to support it safely

## Users and stakeholders
### Primary customer-facing beneficiaries
- **Persona P2: Returning style-profile customer** who expects recommendations to reflect prior purchases, preferences, and current context consistently across ecommerce, email, and clienteling touchpoints
- **Persona P1: Anchor-product shopper** who benefits when the platform can recognize known-customer context safely without breaking complete-look quality when certainty is weak
- **Persona P3: Occasion-led shopper** who benefits when profile context complements occasion and seasonal signals rather than conflicting with them unpredictably

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs customer profiles and suppressions to be dependable enough for assisted selling without relying on hidden or stale assumptions
- **Persona S2: Merchandiser** who needs personalization to honor suppression and governance rules consistently rather than drifting by channel
- **Persona S4: Product, analytics, and optimization team member** who needs profile activation, confidence states, and degraded behavior to be measurable and explainable
- **Privacy, governance, and CRM stakeholders** who need identity confidence, consent boundaries, and source provenance preserved rather than flattened away

## Desired outcomes
- The platform uses one canonical customer identity model across ecommerce, email, and clienteling surfaces.
- Cross-system customer mappings preserve source IDs, provenance, and confidence rather than assuming one identifier is globally trustworthy.
- Style profile data is usable for recommendation ranking and suppression while remaining distinct from raw identity resolution mechanics.
- Low-confidence or conflicting identity states trigger bounded personalization or non-personalized fallback instead of unsafe cross-channel activation.
- Suppression logic for duplicates, opt-outs, and unsuitable recommendations stays consistent across channels.
- Downstream teams can consume a profile service with shared semantics rather than reinventing identity or profile interpretation locally.
- Profile-aware recommendation behavior remains privacy-safe, consent-aware, and auditable.

## Identity and profile scope
This BR defines the business semantics for how customer identity is resolved, how a style profile should behave, when that profile may be used for personalization or suppression, and how customer context remains consistent across delivery channels.

For BR-012, identity and profile foundation includes:
- canonical customer identity and source-system mapping requirements
- confidence-aware identity resolution behavior
- style profile composition and usable profile domains
- profile-service expectations for downstream consumers
- suppression and activation boundaries tied to identity and profile state
- cross-channel consistency rules across ecommerce, email, and clienteling
- graceful degradation when identity, consent, freshness, or provenance is weak

This BR does not define:
- final identity-resolution algorithm or probabilistic matching implementation
- final storage design for profile-serving infrastructure
- final RBAC implementation or identity-provider choice
- exact machine-learning feature engineering for style-profile attributes
- final UI design for CRM, clienteling, or operator profile views

## Canonical customer identity requirements
### Core identity principle
The platform must maintain a stable canonical customer identity that can represent one customer across multiple source systems while preserving enough provenance and confidence metadata that downstream recommendation logic never has to guess whether the mapping is trustworthy.

### Required identity layers
At minimum, the identity foundation must support the following layers:

| Identity layer | What it represents | Minimum business requirement |
| --- | --- | --- |
| Canonical customer ID | the stable internal identity used by recommendation and telemetry flows | one durable customer identifier that survives channel and system changes |
| Source identity mappings | the links from source systems to the canonical customer ID | preserve source-system identifier, source type, linkage timing, and mapping state |
| Identity-confidence state | how trustworthy the merged identity is for personalization | expose confidence explicitly rather than burying it inside the profile |
| Identity provenance | why the mapping exists and what systems contributed | keep enough source and linkage history for audit and troubleshooting |
| Anonymous or session state | current-session identity when no trusted canonical customer is known | support session continuity without pretending anonymous activity is a confirmed customer profile |

### Stable identity expectations
The platform must preserve stable identity rules strongly enough that downstream teams can rely on them across channels:
- canonical customer ID must remain the primary customer identifier for recommendation delivery, telemetry, and profile retrieval
- source-system mappings must be preserved alongside the canonical customer ID rather than overwritten
- customer identity must remain stable across ecommerce, marketing, CRM, POS, loyalty, and clienteling sources when the platform decides those identities belong together
- the platform must distinguish unresolved, singly sourced, merged, conflicted, and deprecated identity states
- downstream teams must not be forced to choose one source-system identifier as the truth when the canonical ID already exists

### Required source-mapping metadata
Every meaningful source identity mapping must preserve at least:
- source system and source identifier
- mapping status such as active, superseded, conflicted, or revoked
- first-seen and last-confirmed timing
- linkage confidence or trust tier
- region, market, or channel relevance where it affects usage
- reason or linkage class when mappings were formed through explicit known-customer association versus weaker inferred association

## Identity-confidence requirements
### Confidence principle
Identity resolution confidence is a business control, not a hidden technical score. Recommendation activation, suppression, and cross-channel use must change behavior when confidence is weak or conflicting.

### Minimum confidence states
The identity foundation must expose business-usable confidence states that are at least this expressive:
- **high confidence:** trusted enough for cross-channel history, profile use, and durable personalization within consent and freshness boundaries
- **bounded confidence:** identity appears likely enough for limited known-customer handling, but some cross-channel or sensitive inputs should be restricted
- **low confidence:** identity is too uncertain for durable profile activation and must not pull in broader customer history as if confirmed
- **conflicted identity:** source mappings disagree materially and require conservative behavior or operator review paths
- **unknown identity:** no trusted known-customer identity is available; only anonymous or session-safe behavior is allowed

### Required confidence behavior
- Confidence state must be visible to profile consumers and recommendation traces.
- Confidence state must gate whether order history, loyalty attributes, store history, stylist notes, and broader cross-channel suppressions may be used.
- Low-confidence or conflicted identity must not activate durable profile-aware recommendations as if the customer were confirmed.
- Session-aware personalization may still occur when allowed, but it must remain bounded to current-session or surface-safe inputs.
- Confidence must be preserved through telemetry and audit paths so operators can explain why personalization depth changed.

### Confidence-sensitive activation examples
| Identity state | Allowed behavior | Restricted behavior |
| --- | --- | --- |
| High confidence | use durable purchase history, style profile, reviewed suppressions, and channel-safe activation across ecommerce, email, and clienteling | still subject to consent, freshness, and policy limits |
| Bounded confidence | use low-risk profile summaries and obvious duplicate suppression when provenance is strong | do not activate broader cross-channel marketing or sensitive operator-entered profile inputs unless policy allows |
| Low confidence | limit to session-aware or anchor-aware personalization only | do not merge durable purchase history, loyalty state, or stylist notes into live recommendation logic |
| Conflicted identity | fall back to conservative governed outputs and flag degraded known-customer handling internally | do not treat competing source mappings as one confirmed customer |
| Unknown identity | use anonymous, session-safe, and curated defaults only | do not infer durable style profile or cross-channel activation |

## Style profile requirements
### Profile principle
The style profile must be a usable recommendation artifact derived from governed signals, not a vague customer blob. It must remain separate from raw identity resolution so the platform can manage uncertainty, freshness, consent, and suppression explicitly.

### Required style profile domains
At minimum, the style profile must be able to express the following business domains when supported by permitted and trustworthy source data:

| Profile domain | What it describes | Primary business uses |
| --- | --- | --- |
| Preference signals | brand-safe style tendencies such as formality, color, fit, fabric, and silhouette leanings | ranking, tie-breaking, look relevance, clienteling support |
| Purchase affinities | durable wardrobe and ownership context from prior orders | complementarity, duplicate suppression, repeat-customer recommendations |
| Occasion tendencies | likely occasion interests such as business, wedding, travel, or seasonal refresh | occasion-based ranking and email activation |
| Fit and configuration tendencies | known size, fit, or CM-relevant preferences where permitted | reduce unsuitable suggestions and support assisted selling |
| Price and assortment orientation | price-tier comfort or assortment affinity in a bounded, governance-safe way | rank appropriate products without violating merchandising controls |
| Suppression cues | signals that certain products, looks, categories, or messages should be withheld or reduced | duplicate avoidance, unsuitable content suppression, channel-safe activation |
| Freshness and confidence context | how current and trustworthy each profile domain is | profile gating and degraded-state handling |

### Required profile quality rules
- Style profile fields used for recommendation logic must preserve lineage to permitted source signal families.
- Profile domains must be allowed to differ in freshness, confidence, and completeness rather than pretending the entire profile is equally trustworthy.
- Lack of profile evidence must remain distinct from negative preference.
- Temporary session intent must not silently rewrite durable profile truth without governance.
- Profile attributes used for customer-facing activation must remain explainable in business terms and privacy-safe.

### Suppression cues within the profile
The style profile must support suppression cues that can be used consistently across channels, including:
- already-owned or recently purchased item or category suppression
- do-not-repeat campaign or message suppression
- unsuitable category or fit suppression where reliable evidence exists
- opt-out or channel suppression linkage where activation is not allowed
- low-confidence profile suppression where profile use should be reduced or ignored rather than trusted

## Profile-service expectations
### Service principle
Downstream channels need a shared profile service contract that returns business-usable customer context with explicit uncertainty and activation boundaries. The profile service must not require each channel to recreate identity logic, profile semantics, or suppression handling independently.

### Minimum service expectations
The profile service must provide, directly or through a governed shared contract, at least:
- canonical customer ID when known
- source-mapping awareness sufficient for traceability and troubleshooting
- identity-confidence state
- consent and activation-safe profile eligibility summary
- usable style-profile summaries for ranking and suppression
- freshness and trust indicators for important profile domains
- degraded-state indicators when profile use is limited
- suppression cues relevant to recommendation delivery and activation

### Channel-consumption requirements
The profile service must behave consistently enough that:
- ecommerce can retrieve known-customer context without inventing separate profile semantics
- email and lifecycle activation can determine whether durable profile-based activation is allowed
- clienteling and assisted-selling flows can use richer but still governed profile context where provenance and permission are stronger
- analytics and explainability flows can reconstruct which profile state was used without reverse-engineering channel-specific logic

### Shared contract expectations
The profile service contract must support a shared interpretation of:
- known versus anonymous customer state
- confidence-limited versus fully trusted profile use
- durable profile history versus current-session intent
- suppression applicability by channel, surface, and recommendation type
- degraded or non-personalized fallback when customer context is weak

## Suppression and activation requirements
### Suppression principle
Suppression logic tied to customer identity and profile must be treated as a first-class business requirement so channels do not repeatedly recommend unsuitable, already-owned, opted-out, or otherwise disallowed content.

### Required suppression categories
At minimum, the identity and profile foundation must support suppression decisions for:
- **duplicate ownership suppression:** avoid recommending items or looks that are obviously redundant with known owned products where confidence and freshness are sufficient
- **recent-purchase and return-aware suppression:** reduce or suppress recommendations that ignore recent purchases, returns, or exchanges
- **channel opt-out suppression:** prevent personalized activation in channels where the customer has unsubscribed or opted out
- **profile-unsuitable suppression:** reduce recommendations that conflict with highly trusted fit, category, or explicit preference boundaries
- **low-confidence suppression:** suppress use of uncertain profile features rather than pretending they are reliable
- **cross-channel fatigue or repetition suppression:** avoid delivering materially repetitive profile-driven recommendations across channels within inappropriate windows once later-stage policy defines those windows

### Required suppression behavior
- Suppression decisions must depend on confidence, freshness, and consent, not only on raw signal existence.
- Suppression should be able to operate at product, look, category, message, and channel scopes where appropriate.
- Channels must not invent incompatible local suppression definitions for the same customer context.
- If suppression evidence is weak or stale, the system should prefer conservative demotion or bounded use rather than overconfident hard blocks unless policy requires a hard block.
- Opt-out and channel-permission suppressions are hard constraints, not ranking hints.

## Cross-channel consistency requirements
### Consistency principle
The customer should not be treated as one person on ecommerce, a different person in email, and an opaque record in clienteling. Cross-channel consistency means the same governed identity and profile semantics apply everywhere, even when each channel uses a different subset of the profile.

### Required consistency outcomes
- Ecommerce, email, and clienteling must share the same canonical customer ID and identity-confidence interpretation where the customer is known.
- Cross-channel recommendation activation must use the same suppression and consent boundaries for the same customer state.
- Profile summaries should be derived from shared business semantics even if channel-specific ranking uses different subsets.
- Recommendation traces must make cross-channel identity state visible enough to explain why two channels behaved similarly or differently.
- Anonymous-session personalization must be clearly distinguished from known-customer personalization so later channel stitching does not misrepresent what the system knew at the time.

### Allowed channel differences
Cross-channel consistency does not mean identical behavior in every channel. The platform may still allow:
- ecommerce to emphasize immediate session intent more heavily
- email to require stronger identity certainty and channel permission before activation
- clienteling to use reviewed store or stylist context where provenance and permission are stronger

Those differences must still operate within one shared identity and profile foundation rather than separate channel-specific customer models.

## Personalization operating levels
The identity and profile foundation must support clear operating levels for downstream recommendation logic:

### Level 1: Fully profile-aware known customer
Allowed when:
- identity confidence is high
- consent and permitted use are valid
- important profile domains are fresh and trustworthy

Behavior:
- use durable profile domains and suppressions across appropriate channels
- support personal, outfit, cross-sell, upsell, contextual, and occasion-based tuning within governed bounds

### Level 2: Bounded known-customer use
Allowed when:
- customer identity is known but not fully trusted for all cross-channel inputs
- only some profile domains are current or strongly attributable

Behavior:
- use lower-risk durable profile summaries and obvious suppressions
- favor curated and rule-safe defaults with light profile influence

### Level 3: Session-aware or anchor-aware personalization
Allowed when:
- current-session intent is available and permitted
- canonical identity is weak, unknown, or not activation-safe

Behavior:
- rely on session, anchor-product, cart, or immediate occasion context
- avoid claiming durable personal knowledge

### Level 4: Governed non-personalized fallback
Required when:
- identity is unknown, low-confidence, or conflicted
- consent or permitted use is absent
- profile freshness or provenance is inadequate

Behavior:
- return curated, rule-based, inventory-valid, and context-safe recommendations
- suppress unsafe profile use and mark degraded status internally

## Channel and surface implications
### Ecommerce
- Ecommerce can benefit from both durable profile context and immediate session intent, but must not let weak identity matching pull in unsafe cross-channel history.
- Known-customer PDP, cart, homepage, and inspiration flows should use the shared profile service rather than channel-local profile logic.

### Email and lifecycle marketing
- Email requires stronger confidence and permission boundaries than anonymous web recommendations.
- Cross-channel activation from profile context must honor opt-outs, marketing permissions, and suppression logic consistently.

### Clienteling and assisted selling
- Clienteling may use richer reviewed store and stylist context where provenance and policy allow.
- Assisted-selling flows still require explicit confidence state and should not bypass suppression or consent-safe activation rules just because the interaction is human-assisted.

### RTW and CM
- Phase 2 should prioritize RTW profile consistency and safe personalization expansion.
- Later CM depth may require additional reviewed profile domains, but the same identity-confidence and suppression principles still apply.

## Phase and rollout expectations
### Phase 1 prerequisite foundation
Earlier work must already provide:
- stable telemetry identifiers
- core customer-signal ingestion
- basic governance and explainability patterns

### Phase 2 identity and profile expansion
Phase 2 should establish:
- confidence-aware canonical customer identity across major source systems
- shared style-profile semantics for recommendation ranking and suppression
- profile-service behavior usable by ecommerce, occasion-led experiences, and email activation
- cross-channel consistency for consent and suppression boundaries
- degraded known-customer handling when identity quality is weak

### Phase 3 operator and channel scale
Later work should expand:
- clienteling use of reviewed profile context
- stronger operator visibility into profile freshness, confidence, and suppression state
- richer cross-channel consistency checks and reporting

### Phase 4 CM depth and advanced optimization
Later work may add:
- richer configuration-aware style-profile domains
- more nuanced premium or appointment-context profile handling
- broader optimization only after identity and suppression quality is trustworthy

## Scope boundaries
### In scope
- defining canonical customer identity and source-mapping expectations
- defining confidence-aware profile activation and fallback behavior
- defining style-profile domains relevant to recommendation ranking and suppression
- defining profile-service and cross-channel consistency expectations
- defining suppression logic requirements linked to identity and profile state
- defining business boundaries for consent-safe, privacy-safe profile usage

### Out of scope
- final entity schema for all profile attributes
- final identity-stitching algorithm or deterministic matching rules
- final infrastructure choice for serving profile data
- final UI workflows for customer-360 or associate tooling
- final legal policy wording by region beyond the business constraints captured here

## Dependencies
- `BR-001` complete-look recommendation capability for preserving coherent recommendations when profile-aware behavior degrades
- `BR-003` multi-surface delivery for applying one identity and profile foundation across ecommerce, email, clienteling, and future consumers
- `BR-006` customer signal usage for the governed signal families that feed profile formation and activation
- `BR-007` context-aware logic for combining customer context with occasion, weather, season, and market context safely
- `BR-009` merchandising governance for suppression, overrides, and policy boundaries that profile-aware recommendations must honor
- `BR-010` analytics and experimentation for identity-state measurement, cross-channel attribution, and degraded-state analysis
- `BR-011` explainability and auditability for exposing profile-confidence and suppression decisions in operator review paths

## Constraints
- Identity confidence must remain explicit rather than buried inside downstream profile outputs.
- Profile use must respect consent, permitted use, and regional policy boundaries before activation, not only after delivery.
- Channels must share profile semantics and suppression logic even when they emphasize different inputs.
- Weak identity, stale profile domains, or incomplete provenance must reduce personalization depth rather than encourage guesswork.
- The identity foundation must support safe fallback behavior so recommendation quality does not depend on every customer being fully known.

## Assumptions
- Commerce, CRM, loyalty, marketing, POS, and clienteling systems can expose source identifiers and timestamps needed for canonical mapping.
- Downstream recommendation delivery and telemetry paths can carry canonical customer ID, confidence state, degraded-state, recommendation-set ID, and trace metadata where appropriate.
- Source-signal governance from BR-006 will provide the permitted and provenance-aware inputs needed to build style profiles safely.
- Phase 1 telemetry, explainability, and governance work provides enough operational foundation for Phase 2 profile expansion.
- Privacy and marketing-governance stakeholders accept that profile-driven activation must remain bounded by explicit suppression and consent controls.

## Missing decisions
- Missing decision: what exact business thresholds distinguish high-confidence, bounded-confidence, and low-confidence identity states for each activation channel.
- Missing decision: which profile domains are safe for email activation versus ecommerce-only or clienteling-only use.
- Missing decision: what repetition and fatigue windows should govern cross-channel suppression of materially similar recommendations.
- Missing decision: how returns, exchanges, and partial fulfillment should quantitatively affect ownership and duplicate-suppression logic.
- Missing decision: what operator review path should exist when source mappings are conflicted but high-value clienteling workflows still need a recommendation session.

## Downstream implications
- Feature breakdown work must separate identity resolution, profile-service behavior, and suppression handling into distinct capabilities rather than one generic personalization feature.
- Architecture work must preserve canonical customer IDs, source mappings, confidence states, and profile freshness metadata across ingestion, serving, delivery, and telemetry flows.
- Delivery contracts must indicate whether recommendation sets used full known-customer profile context, bounded profile use, session-only personalization, or non-personalized fallback.
- Governance and admin tooling must support review of profile suppressions, confidence-limited activation, and channel-safe profile usage without exposing unnecessary sensitive detail.
- Analytics work must measure recommendation outcomes by identity state, profile operating level, and suppression path so weak identity handling does not masquerade as successful personalization.

## Review snapshot
Trigger: issue-created automation from GitHub issue #149.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, goals, architecture overview, data standards, domain model, roadmap, and adjacent BR artifacts provide enough context to define canonical identity, profile-service expectations, confidence-aware activation, suppression handling, and cross-channel consistency requirements without inventing final identity-matching algorithms or infrastructure details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before finalizing confidence thresholds, channel-by-channel profile-domain eligibility, repetition windows, and conflicted-identity operator workflows.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-012 to `Pushed` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for numeric confidence thresholds, channel-specific profile-domain policies, and conflicted-identity handling.
