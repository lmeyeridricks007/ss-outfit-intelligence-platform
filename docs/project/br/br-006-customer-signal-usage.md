# BR-006: Customer signal usage

## Purpose
Define the business requirements for using customer signals to improve complete-look and related recommendations while preserving consent, privacy boundaries, provenance, and graceful fallback behavior across ecommerce, marketing, and clienteling surfaces.

## Practical usage
Use this artifact to guide downstream feature breakdown for signal eligibility, profile usage, freshness handling, provenance tracking, privacy-safe activation, and graceful-degradation rules for personalization.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #143
- **Board item:** BR-006
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for signal eligibility, freshness policy, consent-safe activation, identity-confidence gating, and personalization fallback behavior

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/goals.md`
- `docs/project/architecture-overview.md`
- `docs/project/product-overview.md`
- `docs/project/data-standards.md`
- `docs/project/standards.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must use a defined and governed set of customer signals to improve outfit, cross-sell, upsell, contextual, and personal recommendations without treating every signal as equally trustworthy or equally permitted.

Customer signal usage must distinguish between:
- **short-lived high-intent signals** such as browsing, product views, add-to-cart, and search
- **durable customer-history signals** such as orders and loyalty participation
- **channel and operator signals** such as email engagement, store interactions, and stylist notes
- **activation safeguards** such as consent state, permitted use, regional policy, and identity-resolution confidence

Every signal used for personalization must meet four business conditions:
1. it is an explicitly permitted signal type for the surface and region
2. it is fresh enough for the recommendation decision being made
3. it carries sufficient provenance to be trusted and audited
4. it can be ignored safely without breaking complete-look delivery when consent, quality, or identity confidence is weak

## Business problem
SuitSupply wants recommendations that feel more relevant for returning customers and high-intent shoppers, but personalization quality and customer trust will suffer if the platform uses stale, weakly attributable, or privacy-sensitive data without clear boundaries.

Without an explicit signal-usage requirement:
- recommendation behavior may overfit to noisy or outdated behavior
- channels may use different customer signals inconsistently, producing mismatched recommendations
- operators may be unable to explain why a recommendation was personalized
- store and stylist workflows may rely on notes or interactions that are not governed for customer-facing activation
- low-confidence identity matching may cause the wrong customer history to influence recommendations
- privacy, consent, and regional policy boundaries may be bypassed by convenience rather than design
- downstream teams may build personalization features that fail hard when customer signals are missing

## Users and stakeholders
### Primary customer-facing users
- **Persona P1: Anchor-product shopper** who benefits from short-term intent signals during the active session
- **Persona P2: Returning style-profile customer** who expects recommendations to reflect prior purchases, preferences, and recent engagement when consent allows
- **Persona P3: Occasion-led shopper** who may show intent through search, browsing, email, or assisted-selling interactions rather than through one anchor product alone

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs store and stylist-entered signals to be usable, trustworthy, and reviewable
- **Persona S2: Merchandiser** who needs personalization boundaries that do not override curated looks, campaign controls, or governance
- **Persona S4: Product, analytics, and optimization team member** who needs signal provenance, freshness handling, and degraded-state visibility to evaluate performance safely

## Desired outcomes
- Recommendations become more relevant when reliable customer signals are available and permitted.
- Personalization remains optional rather than mandatory for serving coherent recommendation sets.
- Channels share one governed signal vocabulary instead of inventing surface-specific shortcuts.
- Operators can tell which signal families influenced a recommendation set and whether the result used degraded logic.
- Weak, stale, or low-confidence signals do not produce over-personalized or privacy-risky behavior.
- Email, ecommerce, and clienteling surfaces use customer signals differently where appropriate, but within shared business rules.

## Signal taxonomy and permitted use
### Signal categories
The platform may use the following customer signal families for recommendation decisions when the applicable consent, identity-confidence, and provenance requirements are satisfied.

| Signal family | What counts | Allowed recommendation uses | Freshness expectation | Provenance and safeguard minimum |
| --- | --- | --- | --- | --- |
| Orders | completed purchases, returns, exchanges, and fulfilled order history from commerce and OMS systems | complement prior wardrobe, suppress obvious duplicates, infer durable category or formality preferences, support repeat-customer email and clienteling recommendations | durable history remains useful across weeks and seasons, but recent order state and return status should refresh at least daily | order or line-item source IDs, timestamps, market, fulfillment state, return state, canonical customer mapping |
| Browsing | category exploration, list views, filter use, navigation patterns, and in-session engagement | short-term intent ranking on ecommerce surfaces, context for adjacent product categories, session-aware reordering | near-real-time for active session use; decays quickly after the session ends | session ID or known-customer mapping, event timestamp, surface, locale or market, consent state |
| Product views | PDP views, repeat views, and recent product exploration | reinforce anchor-product intent, identify complementary products or looks, support recent-interest follow-up where permitted | near-real-time to recent; strongest in the active session and shortly after | product ID, timestamp, session or customer mapping, surface, consent state |
| Add-to-cart | cart adds, cart removals, and active cart contents | outfit completion, cross-sell, duplicate suppression, cart-aware upsell, bundle completion | near-real-time while cart state is current; stale cart state should not drive confident personalization | cart ID, product ID, timestamp, market, session or customer mapping |
| Search | on-site search queries, search result interactions, and filters chosen from search | infer explicit short-term occasion, style, category, or product intent; rank contextually relevant recommendations | near-real-time in the active session; loses value quickly if not reinforced | raw and normalized query context, timestamp, locale, session or customer mapping, consent state |
| Loyalty | membership status, tier, tenure, and explicitly permitted loyalty-profile attributes | support repeat-customer context, loyalty-aware follow-up, premium-service readiness, and retention-oriented personalization inside policy limits | current-state attributes should refresh daily or per program update cycle; older profile signals remain supporting context only | loyalty source ID, effective date, program status, country or market, canonical customer mapping |
| Email engagement | sends, opens, clicks, unsubscribes, and campaign responses | personalize lifecycle and email recommendation content, suppress irrelevant follow-up, adapt recommendation timing or entry-point relevance | same day to daily for active campaigns; decays across campaign cycles | campaign ID, event timestamp, subscription state, channel identifier mapping, consent state |
| Store signals | store visits, appointments, POS-linked activity, and assisted-selling interactions | prepare appointment-aware recommendations, support follow-up looks, use store context in clienteling, blend digital and assisted-selling signals when identity confidence allows | upcoming and recent interactions should be current the same day or daily; older store activity becomes a weaker profile hint | store or appointment ID, associate or system attribution, timestamp, event type, canonical customer mapping, market |
| Stylist notes | approved preference tags, fit notes, disliked combinations, and explicitly customer-stated styling preferences | enrich clienteling and high-touch personalization, preserve premium styling context, support clienteling follow-up and suppression logic | must carry last-reviewed or last-confirmed timing; stale notes degrade to weak hints or are ignored | note ID, author, timestamp, review state, permitted note taxonomy, canonical customer mapping |

### Permitted-use principles by signal family
#### Orders
- Order history is the strongest durable customer signal for wardrobe complementarity and repeat-customer personalization.
- Order signals should help avoid obviously redundant recommendations and should support outfit completion around what the customer already owns.
- Recent order state, returns, exchanges, and cancellations must temper positive purchase signals so the platform does not personalize from outdated assumptions.
- Order history is valuable across ecommerce, email, and clienteling, but it should not be treated as proof of current short-term intent without reinforcing recent activity.

#### Browsing, product views, add-to-cart, and search
- These signals are the strongest indicators of current intent for PDP, cart, and active-session recommendation requests.
- They should have greater influence than older durable signals when the customer is clearly showing fresh in-session intent.
- Anonymous or session-only use is allowed only within the current session and only where consent and regional policy permit that behavior.
- These signals must not be silently promoted into long-lived cross-channel profile truth without explicit identity confidence and permitted-use rules.

#### Loyalty and email engagement
- Loyalty signals may support customer-stage, service-level, and repeat-engagement context, but they should not become a backdoor for unfair exclusion or opaque treatment differences.
- Email engagement may shape outbound relevance and timing, but it is a weaker style signal than orders or strong in-session behavior.
- Unsubscribe and suppression states must override recommendation activation in email and must be respected when building follow-up journeys.

#### Store signals and stylist notes
- Store interactions and stylist-entered preferences are valuable for assisted selling and premium recommendation contexts, especially for appointments and clienteling follow-up.
- These signal families require stronger provenance and governance because they may be operator-entered, manually curated, or market-specific.
- Stylist notes must favor approved structured preference capture over unreviewed free-form text when used for customer-facing recommendation activation.
- If store or stylist signals conflict with fresher explicit customer activity, the system should prefer the fresher explicit intent unless business policy defines a higher-trust operator context.

## Freshness and staleness expectations
### Freshness tiers
The platform must treat freshness as a business requirement, not a downstream implementation detail. Signals should be grouped into the following freshness tiers:

| Freshness tier | Signal families | Business expectation | Degradation rule |
| --- | --- | --- | --- |
| Immediate | browsing, product views, add-to-cart, search | available in near-real-time for active-session personalization and cart or PDP decisions | if recency is unknown or clearly stale, do not use as high-intent input |
| Current | email engagement, store appointments, store interactions | updated the same day or daily when used for follow-up or assisted-selling activation | if outdated, reduce to weak contextual support or ignore |
| Durable | orders, loyalty state | refreshed at least daily or per source update cycle, with recency-aware weighting across weeks and seasons | if historical depth exists but recent state is missing, use only as background preference rather than current intent |
| Reviewed | stylist notes and human-entered preferences | usable only when a last-reviewed or last-confirmed state exists | if review timing is missing or too old, demote to weak hints or suppress entirely |

### Required staleness handling
- Signals with unknown freshness must not drive personalized ranking.
- Derived profile features inherit the most restrictive freshness expectation of their underlying signals.
- Session-intent signals should decay much faster than durable preference signals.
- A signal may stay available for analytics longer than it remains eligible for live recommendation personalization.
- Seasonal and occasion-sensitive behaviors should decay when the season, market context, or event context materially changes.
- When freshness is borderline, the system should prefer safer ranking behavior rather than attempting to preserve maximum personalization depth.

## Provenance and traceability expectations
Every signal used for personalization must be attributable enough for internal teams to reconstruct why it was trusted.

### Minimum provenance requirements
- stable canonical customer ID or anonymous session ID, plus source-system mappings where relevant
- event or note timestamp normalized for timezone-safe interpretation
- source system and source record identifier, or operator attribution for human-entered signals
- channel, surface, store, market, or locale context where it affects interpretation
- transformation ownership for derived features or normalized signal summaries
- consent state and identity-confidence state relevant to activation

### Provenance requirements by usage
- Signals without usable provenance may still inform aggregate reporting, but they must not drive customer-specific ranking.
- Derived profile summaries must preserve lineage to the source signal families they summarize.
- Store and stylist signals must preserve whether they were system-generated, operator-entered, customer-confirmed, or later reviewed.
- Recommendation traces must make it possible to determine whether a recommendation set used durable profile history, current-session intent, store-assisted context, or degraded defaults.
- If provenance is partial but not absent, downstream logic should treat the signal as lower-trust rather than silently as equal to fully attributable data.

## Privacy, consent, and profile safeguards
### Core privacy requirements
- Use only customer signals permitted for the recommendation use case, channel, and region.
- Consent and opt-out states must be enforced before personal recommendation activation, not only after delivery.
- Identity resolution confidence must be explicit wherever cross-system customer history is merged.
- Data minimization must apply: only use signal content that is relevant to outfit and recommendation decisions.
- Customer-facing surfaces must not expose sensitive profile reasoning or raw note content.

### Required safeguards
- No personal recommendation behavior may activate when the customer has opted out of the applicable use or channel.
- Low-confidence identity matches must not pull in cross-channel purchase history, loyalty state, or stylist notes as if the mapping were certain.
- Anonymous-session behavior may inform current-session recommendations only within the allowed consent and regional envelope.
- Stylist notes and store-entered data must not be used as unrestricted raw text features for ranking if they can contain sensitive or ungoverned information.
- Signals that imply protected, intimate, or otherwise sensitive personal information unrelated to outfitting must not be used for recommendation personalization.
- Email engagement and loyalty data must not become a proxy for opaque customer treatment that cannot be explained operationally.

### Signal-use boundaries
The following are outside the permitted scope for BR-006 personalization:
- unapproved third-party purchased audience data
- hidden inference about sensitive personal traits unrelated to styling
- raw unreviewed operator notes used directly in customer-facing ranking
- profile activation when consent, permitted use, or regional policy status is unknown
- cross-customer association logic that assumes one person from another person's behavior

## Personalization operating levels and graceful degradation
Personalization must degrade gracefully rather than fail closed or over-personalize when customer context is weak.

### Level 1: Full profile-aware personalization
Allowed when:
- consent and permitted use are valid for the surface and region
- identity confidence is high enough to trust cross-channel customer history
- freshness is sufficient for the signal families used

Behavior:
- blend durable signals such as orders and loyalty with current-session or recent engagement signals
- support outfit, cross-sell, upsell, contextual, and personal recommendation ranking
- preserve traceability about which signal families contributed most

### Level 2: Bounded known-customer personalization
Allowed when:
- the customer is known, but some signals are stale, sparse, or only partly attributable

Behavior:
- use the most trustworthy durable signals first
- avoid aggressive short-term personalization if recent-intent data is weak
- bias toward curated and rule-safe defaults with light profile tuning

### Level 3: Session-aware or surface-aware intent personalization
Allowed when:
- current-session behavior is available and permitted
- identity confidence is low or cross-channel profile use is not allowed

Behavior:
- rely on browsing, product views, search, and add-to-cart within the current session
- do not claim or simulate durable personal knowledge about the customer
- keep outputs close to anchor-product, cart, or session intent

### Level 4: Non-personalized governed fallback
Required when:
- consent is absent or denied
- identity confidence is too weak for trusted personalization
- signal freshness or provenance is inadequate
- relevant signal sources are unavailable or degraded

Behavior:
- return curated, rule-based, inventory-valid, and context-safe recommendation sets
- preserve complete-look credibility without using unsafe personal assumptions
- mark the output as degraded or non-personalized in internal traces

### Required degradation scenarios
#### Consent unavailable, denied, or regionally restricted
- Do not use customer-history signals for personalization.
- Use only allowed non-personalized complete-look, contextual, or curated defaults for the surface.

#### Identity confidence weak or conflicting
- Do not merge in orders, loyalty, store signals, or stylist notes from uncertain identity matches.
- If current-session signals are allowed, limit behavior to session-aware personalization only.

#### Freshness missing or signal clearly stale
- Suppress the affected signal family from ranking inputs.
- Prefer durable and better-attributed signals, or fall back to curated and rule-safe defaults.

#### Provenance incomplete or source quality degraded
- Treat the signal as lower-trust or ineligible for customer-specific ranking.
- Preserve delivery by using unaffected signal families or non-personalized governed outputs.

#### Sparse customer history
- Avoid overfitting to one weak signal.
- Use curated looks, compatibility rules, and current anchor or session context to maintain recommendation quality.

#### Store or stylist data unavailable
- Continue serving recommendations without assisted-selling context.
- Do not fabricate premium personalization depth when those signals are missing.

## Channel and surface implications
### Ecommerce surfaces
- PDP, cart, homepage, and inspiration surfaces may use active-session signals as the primary short-term input when permitted.
- When the customer is known and consented, ecommerce may blend orders and loyalty with current intent, but recent session behavior should remain the stronger guide for immediate shopping decisions.

### Email and lifecycle marketing
- Email recommendations require active channel permission and stronger identity certainty than anonymous web-session personalization.
- Outbound personalization should favor durable and freshness-safe signals over ephemeral session behavior unless recent behavior is explicitly permitted and attributable.

### Clienteling and assisted selling
- Clienteling may use store signals and stylist notes when provenance, review state, and customer eligibility are clear.
- Premium recommendation contexts should prefer reviewed operator-entered preferences and durable purchase history over weak digital noise.

## Scope boundaries
### In scope
- defining permitted customer signal families for recommendation usage
- establishing business freshness expectations and staleness handling
- defining provenance requirements for trustworthy personalization
- setting privacy, consent, and identity-confidence boundaries
- defining graceful-degradation levels for missing, weak, or unpermitted signals
- clarifying channel-specific activation differences across ecommerce, email, and clienteling

### Out of scope
- exact feature engineering or model-weighting formulas
- field-level schema design for every signal source
- final legal-policy interpretation for every region
- exact SLA numbers for each ingestion pipeline
- final admin workflow design for note review, consent auditing, or operator tooling

## Dependencies
- `BR-001` complete-look recommendation capability for preserving coherent recommendations even when personalization degrades
- `BR-003` multi-surface delivery for applying signal policies consistently across ecommerce, email, and clienteling
- `BR-005` curated plus AI recommendation model for precedence between governed defaults and personalized ranking
- `BR-007` context-aware logic for separating customer signals from contextual signals while allowing safe combination
- `BR-010` analytics and experimentation for signal-family attribution, degraded-state measurement, and outcome analysis
- `BR-011` explainability and auditability for provenance visibility and recommendation trace reconstruction
- `BR-012` identity and profile foundation for identity-confidence handling and cross-system profile safety

## Constraints
- Personalization must remain optional; recommendation delivery must still work safely when customer signals are unusable.
- Consent, permitted use, and regional policy boundaries are hard constraints, not ranking preferences.
- Identity confidence must stay explicit rather than hidden inside profile-building logic.
- Store and stylist-entered signals require stronger governance than passive digital event signals.
- Freshness and provenance metadata are required inputs for personalized activation, not operational nice-to-haves.

## Assumptions
- Commerce, CRM, loyalty, marketing, POS, and clienteling systems can expose the signal families listed in this BR with source timestamps and identifiers.
- Recommendation delivery and telemetry paths can carry degraded-state, recommendation-set ID, and trace metadata.
- Phase 1 telemetry and data quality improvements provide the operational foundation needed for broader Phase 2 personalization work.
- Consent and suppression rules can be evaluated before personalized recommendation delivery on each relevant surface.
- Clienteling workflows can support reviewed or structured stylist preference capture rather than relying only on raw free-form notes.

## Missing decisions
- Missing decision: what exact regional consent matrix applies to each signal family across ecommerce, email, and clienteling activation.
- Missing decision: what numeric staleness thresholds should apply to each signal family by surface and recommendation type.
- Missing decision: which loyalty attributes are acceptable personalization inputs versus metadata that should stay operational only.
- Missing decision: whether stylist notes must be fully structured before any ranking use, or whether bounded reviewed free text is ever acceptable.
- Missing decision: how returns, exchanges, and cancellations should quantitatively adjust order-derived profile signals.

## Downstream implications
- Feature breakdown work must define signal eligibility and fallback behavior separately from recommendation-type taxonomy so teams do not treat all personal recommendations as one mode.
- Architecture work must preserve freshness, provenance, consent, and identity-confidence metadata alongside signal ingestion and profile-building flows.
- Delivery contracts must indicate whether a recommendation set used full personalization, bounded personalization, session-only personalization, or non-personalized fallback.
- Governance tooling must support signal-family suppression, degraded-state visibility, and operator review for store and stylist-entered data.
- Analytics work must measure recommendation outcomes by signal family, freshness tier, and degradation level so unsafe personalization does not look artificially successful.

## Review snapshot
Trigger: issue-created automation from GitHub issue #143.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, goals, architecture overview, product overview, data standards, and platform standards provide enough context to define permitted signal families, freshness expectations, provenance gates, privacy boundaries, and graceful degradation without inventing implementation-specific ranking logic.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before finalizing regional policy matrices, numeric freshness thresholds, and note-governance mechanics.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-006 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for regional consent policy details and operator-note governance.
