# BR-007: Context-aware logic

## Purpose
Define the business requirements for using environmental, market, calendar, and request-time context to improve complete-look and related recommendations while preserving deterministic precedence, graceful fallback behavior, and measurable relevance expectations for downstream feature, architecture, and implementation work.

## Practical usage
Use this artifact to guide downstream feature breakdown for context input normalization, precedence policy, fallback design, recommendation delivery contracts, and measurement of context-aware recommendation quality across ecommerce, marketing, and clienteling surfaces.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #144
- **Board item:** BR-007
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for context input normalization, precedence policy, fallback handling, delivery metadata, and context-relevance measurement

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/vision.md`
- `docs/project/roadmap.md`
- `docs/project/product-overview.md`
- `docs/project/architecture-overview.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must incorporate a governed set of contextual inputs into recommendation decisions so outputs feel appropriate for where, when, and why the customer is shopping, not only for what product they are viewing.

Context-aware logic for this BR must cover:
- **location** and **country or market** context
- **weather** and weather-adjacent environmental conditions
- **season** and seasonal merchandising direction
- **holiday and event calendars**
- **session context** such as current surface, anchor product, cart state, search, and request-time journey signals
- **occasion-led entry points** such as explicit landing pages, selected occasion intents, or campaign-led discovery
- **fallback expectations** when one or more context inputs are missing, stale, conflicting, or low-confidence

The platform must not treat all context inputs as equal. It must distinguish:
- explicit context versus inferred context
- current request context versus baseline market defaults
- high-confidence local conditions versus broad seasonal assumptions
- safe hard boundaries versus soft ranking preferences

The resulting recommendation behavior must remain:
- complete-look oriented rather than generic item similarity
- consistent across surfaces that use the same context evidence
- governed by deterministic precedence and explainable fallback behavior
- measurable for both context fit and commercial value

## Business problem
SuitSupply wants recommendations to feel like a stylist understood the customer's current need: a warm-weather wedding, a rainy city commute, a holiday gifting moment, or a formal business trip. That requires more than customer history or anchor-product matching alone.

Without explicit context-aware logic:
- recommendations may feel seasonally or situationally wrong even if they are product-compatible
- different surfaces may interpret the same context differently, producing inconsistent experiences
- holiday or campaign logic may override stronger customer intent without clear governance
- weather and location data may be used opportunistically rather than safely, causing erratic ranking behavior
- downstream teams may implement their own local heuristics instead of one shared precedence model
- fallback behavior may become opaque, causing recommendation quality to swing when context services degrade
- relevance gains from context may be impossible to measure because context usage and degraded states are not tracked consistently

## Users and stakeholders
### Primary customer-facing users
- **Persona P1: Anchor-product shopper** who expects recommendations to reflect the current product, session, and local conditions
- **Persona P3: Occasion-led shopper** who starts from an event or dress-code need and expects the recommendation set to match that intent
- **Persona P4: Context-sensitive shopper** who may not have a strong history profile but still expects weather-, season-, and market-appropriate recommendations

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs recommendations that fit appointment, event, and local context without manual correction
- **Persona S2: Merchandiser** who needs seasonal, holiday, and market context to influence ranking without breaking governance or curated intent
- **Persona S3: Marketing team member** who needs occasion- and calendar-aware recommendations for campaigns and lifecycle entry points
- **Persona S4: Product, analytics, and optimization team member** who needs measurable evidence that context improves relevance and that degraded behavior remains safe

## Desired outcomes
- Recommendations reflect the customer's current situation, not only the product or category being viewed.
- Explicit occasion and session intent are not diluted by weaker inferred context.
- Weather and local market conditions adjust recommendation ranking and composition when confidence is high.
- Holiday and event calendars shape recommendation relevance without inventing intent when evidence is weak.
- Missing or conflicting context produces predictable, smaller, and safer outputs rather than erratic personalization.
- Context-aware logic is shared across surfaces and reported in a measurable way for experimentation and operations.

## Context scope and business boundary
This BR defines **request-time contextual logic**, not full customer-profile personalization. Session context belongs here because it describes the current request and journey state. Durable cross-session customer history, consent, and identity-confidence behavior are governed primarily by `BR-006`.

For BR-007, context-aware logic includes:
- current market and local environment
- current date and calendar overlays
- current request journey and entry-point intent
- explicit occasion signals associated with the request

It does not require downstream teams to treat all context as personal data, nor does it permit them to collapse request-time context and customer-profile logic into one opaque ranking signal.

## Context taxonomy and required roles
### Context input families
The platform must recognize the following context families as distinct business inputs.

| Context family | What counts | Primary business role | Confidence expectation | Fallback if weak or missing |
| --- | --- | --- | --- | --- |
| Country or market | country code, market, locale, assortment market | set market defaults, legal or policy boundaries, holiday calendar scope, season baseline, and assortment relevance | should be present or derivable for most requests | use explicit channel market default; do not infer localized holiday behavior beyond known market |
| Location | city, region, postal area, store area, geolocation, shipping destination, appointment location | refine weather lookup and local event relevance; distinguish local climate within a country | may be absent, approximate, or low-confidence | fall back to country or market context without pretending to know local conditions |
| Weather | temperature band, precipitation, wind, humidity, severe weather, local forecast timing | adjust fabric, layering, outerwear, footwear, and seasonal weight decisions | must be current enough and location-linked to influence ranking strongly | fall back to seasonal baseline and occasion-safe defaults |
| Season | merchandising season, hemisphere season, climate seasonality, seasonal assortment timing | provide baseline styling direction when local conditions are unknown or stable | medium confidence; may be derived from market and date | fall back to market-level seasonal default or season-neutral looks |
| Holiday and event calendars | public holidays, gifting windows, formal event periods, market events, operator-defined key seasonal events | shape occasion relevance, promotional timing, gifting, and cultural-formality expectations | calendar source must be market-specific and date-valid | ignore the calendar overlay and use session plus season instead |
| Session context | current surface, anchor product, cart contents, selected filters, search query, landing page, referrer, journey step | reflect the immediate request and narrow recommendation intent in real time | highest confidence when derived from the active request | fall back to surface default behavior and available market context |
| Occasion-led entry points | explicit occasion selection, campaign landing page, appointment reason, user-chosen event, style-builder intent | provide explicit dress-code or use-case intent for look composition and ranking | highest confidence when explicitly declared by the customer or operator | fall back to session and calendar inference; do not fabricate occasion specificity |

### Context role definitions
#### Country or market context
Country or market context is the foundation for:
- choosing the correct holiday and event calendars
- selecting the right seasonal baseline for hemisphere and assortment timing
- constraining market-appropriate recommendations and merchandising logic

Country or market context is a required baseline even when more precise local context is unavailable.

#### Location context
Location context refines country or market context. It exists to improve local environmental relevance, not to replace market governance. Exact location is helpful but not mandatory; when precision is low, downstream logic must keep behavior broad and safe.

#### Weather context
Weather context is the strongest environmental signal for climate-sensitive recommendation choices such as:
- outerwear and layering needs
- lighter or heavier fabrics
- footwear and accessory suitability
- near-term weather practicality for occasion-based shopping

Weather must never be treated as universally authoritative. It is only strong when freshness and location linkage are trustworthy.

#### Season context
Season context provides the stable baseline that keeps recommendations regionally and commercially coherent when live weather is absent, stale, or unhelpful. Season is especially important for merchandising direction, assortment timing, and event windows that span weeks rather than hours.

#### Holiday and event calendars
Holiday and event calendars provide culturally and commercially important overlays such as gifting periods, formalwear peaks, travel seasons, and event-heavy windows. Calendar context should enrich relevance, but it must not invent explicit customer intent where none exists.

#### Session context
Session context is the current request-time evidence that explains what the customer is trying to do now. For BR-007, this includes:
- current surface such as PDP, cart, homepage, inspiration page, email clickthrough, or clienteling workflow
- current product anchor or cart composition
- current search or filter behavior that indicates an occasion, category, or style need
- entry path such as a campaign landing page or occasion-led route

Session context must be treated as stronger than broad seasonal or calendar defaults when it clearly indicates present intent.

#### Occasion-led entry points
Occasion-led entry points are explicit intent declarations and therefore carry the strongest recommendation relevance signal after hard market boundaries. They may come from:
- a customer selecting an occasion such as wedding, business travel, black tie, or holiday party
- a journey starting on a dedicated occasion page
- an operator selecting an appointment reason or stated event need
- a campaign or merchandising path that explicitly frames the shopping mission

Occasion-led entry points are not just marketing metadata. They are business inputs that must shape look composition, ranking, and fallback decisions.

## Context normalization and trust requirements
Every context input used in recommendation logic must preserve enough metadata for downstream teams to trust and explain it.

### Minimum trust metadata
At a business level, each context family used in live ranking must preserve:
- source or derivation type
- resolved value or bucket used by the recommendation decision
- timestamp or effective date
- confidence or trust state
- whether the value was explicit, inferred, or defaulted

### Trust rules
- Context without usable source or freshness information must not behave like high-confidence context.
- Derived context must preserve the lineage of the inputs it depends on, such as location-derived weather or country-derived seasonal baselines.
- Fallback and default states must remain visible in internal traces so teams can distinguish rich context decisions from safe default behavior.
- If two context sources disagree materially, the system must choose the higher-precedence input or degrade to a safer broader context rather than blending contradictory assumptions invisibly.

## Precedence principles and conflict resolution
### Precedence principles
- Hard market and governance boundaries come before contextual optimization.
- Explicit occasion and request intent outrank inferred seasonal or calendar assumptions.
- Live local conditions may refine or override broad seasonal assumptions for climate-sensitive choices.
- Calendar context may reinforce or narrow relevance, but it must not overrule explicit customer intent.
- When confidence is weak, the system should become less specific rather than more speculative.

### Required precedence order
Downstream feature and architecture work must preserve the following business precedence stack:

1. **Hard market and delivery boundaries**
   - country or market, channel scope, assortment eligibility, and other non-negotiable delivery constraints
2. **Explicit occasion-led intent**
   - explicit occasion selection, appointment reason, or occasion-led entry point associated with the current request
3. **Current session context**
   - anchor product, cart state, search, filters, landing path, and active surface behavior
4. **High-confidence local environmental context**
   - resolved location plus current weather when freshness and trust are sufficient
5. **Holiday and event calendar overlays**
   - market-relevant calendar windows and event periods that shape ranking only when stronger intent is absent or aligned
6. **Seasonal baseline**
   - country- or hemisphere-appropriate season and merchandising direction
7. **Global or market-safe defaults**
   - brand-safe, broadly relevant look logic when richer context is not available

### Conflict-resolution rules
The platform must apply at least the following conflict rules:

#### Country or market versus location
- Country or market sets the base calendar and assortment domain.
- Location may refine local weather or event relevance only when it is consistent with the market and sufficiently trustworthy.
- If location confidence is weak, the system must keep market-level behavior instead of fabricating local specificity.

#### Weather versus season
- High-confidence current weather may override seasonal assumptions for climate-sensitive categories and styling choices.
- Season still provides the baseline for assortment direction and should remain the fallback when weather is stale, missing, or ambiguous.
- Weather should not force highly localized decisions that the available assortment cannot support.

#### Explicit occasion versus holiday or event calendar
- Explicit occasion intent always outranks inferred holiday or event context.
- Calendar context may reinforce an explicit occasion but must not redirect the recommendation set toward a different use case.

#### Session context versus broad defaults
- Current session context outranks seasonal and calendar defaults when it clearly indicates what the customer is trying to accomplish now.
- Broad defaults may still guide tie-breaking when session context is sparse or generic.

#### Multiple contextual signals pointing to different intents
- If one signal is explicit and the other is inferred, the explicit signal wins.
- If both are inferred and neither is clearly stronger, the system should prefer the safer, broader recommendation set and record a degraded-context state.
- The system must not combine contradictory contexts in a way that makes the recommendation set internally inconsistent.

## Required context-aware behaviors
### Candidate generation and ranking behavior
Context-aware logic must influence both candidate generation and ranking, not only final tie-breaking.

The platform must be able to:
- narrow look and product candidates by explicit occasion when present
- apply weather- and season-aware filtering or boosting for climate-sensitive categories
- use country or market context to select the right calendars, assortment assumptions, and merchandising defaults
- use session context to distinguish exploratory browsing from focused anchor-product or cart completion behavior
- apply holiday or event overlays to surface relevant looks when they align with market and request context

### Hard versus soft context effects
Downstream work must distinguish between:
- **hard context effects:** constraints that should suppress clearly unsuitable results, such as market-inappropriate or explicitly off-occasion recommendations
- **soft context effects:** boosts or ordering preferences, such as reinforcing seasonal colors or holiday-adjacent looks when the request remains otherwise broad

Context-aware logic must not treat every context family as a hard exclusion source. Most context should guide relevance before it suppresses inventory-valid complete looks entirely.

## Fallback behavior
### Fallback principles
- Fallbacks must preserve complete-look credibility and brand coherence.
- A smaller and safer set is preferable to a larger but weakly justified one.
- The system must not pretend to know more context than it actually knows.
- Fallback state must be visible internally for measurement and troubleshooting.

### Required fallback scenarios
#### Missing exact location
- Use country or market defaults for season and calendar selection.
- Do not apply highly localized weather or city-event assumptions.

#### Weather missing, stale, or low-confidence
- Fall back to season plus occasion and session context.
- Avoid aggressive climate-sensitive reordering that depends on untrusted weather inputs.

#### Holiday or event calendar unavailable
- Ignore the calendar overlay rather than inferring unsupported event intent.
- Continue with session, occasion, market, and season context.

#### No explicit occasion and weak session context
- Use season- and market-safe curated or governed defaults.
- If a relevant holiday window exists, it may gently shape ranking, but it must not create an overly narrow recommendation set.

#### Conflicting explicit and inferred context
- Prioritize the explicit occasion or entry-point context.
- Use inferred context only when it does not conflict with the explicit need.

#### Sparse or contradictory inferred context
- Prefer broader complete-look defaults and reduce context-specific boosts.
- Mark the recommendation set as degraded or low-context-confidence in internal traces.

#### Context service or provider degradation
- Continue serving recommendations using the highest-confidence remaining context layers.
- Preserve traceability that a provider-backed context family was unavailable and fallback logic was used.

## Measurable relevance expectations
Context-aware logic is only useful if downstream teams can measure whether it improved recommendation relevance without creating hidden instability.

### Required measurement categories
Downstream delivery and analytics work must support measurement of:
- **context coverage:** how often each context family was available and trusted by surface, market, and request type
- **context application:** which context families actually influenced candidate generation or ranking
- **fallback rate:** how often recommendations were served with degraded or defaulted context logic
- **context fit:** whether the top recommendation set aligned with the highest-precedence context for the request
- **commercial impact:** whether context-aware logic improved click-through, add-to-cart, attach, conversion, or other agreed business outcomes versus safer defaults

### Minimum business relevance expectations
The following expectations must hold for downstream work:
- Recommendation sets must not contradict high-confidence explicit occasion intent.
- Recommendation sets must not contradict high-confidence hard weather suitability rules for climate-sensitive items.
- When explicit occasion intent exists, the leading complete look or top-ranked recommendation set must reflect that occasion.
- When live weather is trusted, weather-aware logic should materially influence climate-sensitive ranking decisions rather than being collected and ignored.
- When only broad seasonal or calendar context exists, recommendations should remain helpful but less specific, and the degraded specificity should be measurable.
- Fallback behavior must be measurable separately from fully context-aware behavior so experiments do not hide degraded-state performance.

### Recommended evaluation views for downstream work
To support feature and architecture decomposition, downstream work should preserve the ability to evaluate:
- explicit occasion fit versus inferred calendar fit
- weather-aware performance versus season-only performance
- market-level defaults versus location-refined context
- session-rich requests versus low-context requests
- context-aware recommendation lift by surface, recommendation type, and market

## Surface implications
### Ecommerce PDP and cart
- Session context and anchor-product intent should be the strongest request-time signals after market boundaries.
- Weather and season should refine completion choices without replacing the anchor-product mission.

### Homepage and inspiration surfaces
- Occasion-led entry points, holiday windows, and season may play a larger role because the request is often broader.
- When the session is weak, context-aware logic should remain inspirational but not over-specific.

### Email and lifecycle marketing
- Calendar and occasion context may shape relevance windows, but stale or weak session context should not be treated like active shopping intent.
- Market and seasonal correctness are especially important because the interaction is not synchronous with a live browsing session.

### Clienteling and assisted selling
- Appointment reason, explicit event context, and local market conditions should carry high weight.
- Operators need transparent fallback behavior when local weather or event context is unavailable.

## Phase and rollout expectations
### Phase 1 prerequisite expectations
Phase 1 work should establish:
- shared recommendation telemetry and trace metadata
- deterministic rule and governance behavior
- enough product and market metadata to support later context-aware decisions safely

### Phase 2: Context and personalization expansion
This BR becomes a primary scope item in Phase 2. In scope:
- shared context input taxonomy and precedence policy
- context normalization and fallback states
- weather, season, holiday, and market-aware recommendation behavior
- occasion-led experience support across relevant surfaces

### Later phases
- Phase 3 should extend the same context logic consistently into broader channel and operator workflows.
- Phase 4 may introduce deeper CM and premium-specific context nuances, but it must preserve the same precedence and fallback principles.

## Scope boundaries
### In scope
- defining the business context families used in recommendation logic
- defining precedence and conflict-resolution rules among those context families
- defining fallback behavior when context is weak, missing, stale, or contradictory
- defining measurable expectations for context fit, fallback rate, and business impact
- clarifying how context should influence recommendation behavior across surfaces

### Out of scope
- exact provider selection for weather, holiday, or event data
- exact numeric thresholds for weather bands, freshness windows, or confidence scoring
- final API schema for the context payload returned by recommendation services
- final ranking formulas that combine context with customer profile and merchandising signals
- detailed UI design for context-driven entry points or operator tooling

## Dependencies
- `BR-001` complete-look recommendation capability for preserving outfit-centered quality while applying context
- `BR-003` multi-surface delivery for consistent context behavior across ecommerce, email, and clienteling
- `BR-005` curated plus AI recommendation model for blending context with governed ranking and curated intent
- `BR-006` customer signal usage for separation between request-time context and durable customer profile usage
- `BR-008` product and inventory awareness for context-safe filtering and assortment validity
- `BR-009` merchandising governance for seasonal, holiday, and campaign controls that interact with context logic
- `BR-010` analytics and experimentation for measuring context fit, fallback frequency, and business impact
- `BR-011` explainability and auditability for traceability of context inputs, defaults, and degraded states
- `BR-012` identity and profile foundation for safe combination of request-time context with later personalization work

## Constraints
- Context-aware logic must remain subordinate to hard market, governance, compatibility, and operational validity constraints.
- Explicit customer or operator intent must not be silently overridden by weaker inferred context.
- The same request context should not produce materially different recommendation behavior across surfaces unless the surface intentionally defines different business rules.
- Rich context cannot be assumed to be always present; the recommendation experience must still work with safe defaults.
- Context-aware behavior must be auditable enough that operators can tell whether recommendations were driven by explicit, inferred, or defaulted context.

## Assumptions
- The platform can reliably determine at least a country or market context for most recommendation requests.
- Weather and calendar inputs can be obtained from dependable internal or external services, but those services may degrade and therefore require explicit fallback behavior.
- Merchandising and catalog metadata are sufficient to distinguish context-sensitive products, looks, and seasonal direction.
- Downstream delivery and telemetry contracts can carry context-used and fallback-state metadata at recommendation-set level.
- Phase 1 foundational telemetry and governance work will exist before broad Phase 2 context expansion is activated.

## Missing decisions
- Missing decision: what numeric freshness and confidence thresholds should govern weather and location usage by surface.
- Missing decision: which holiday and event calendars are mandatory by market, and how local versus national events should be prioritized.
- Missing decision: how much operator control merchandisers should have over context weighting for specific surfaces or campaigns.
- Missing decision: which context-driven recommendation behaviors should be mandatory in the first Phase 2 release versus later expansions.
- Missing decision: how downstream teams should evaluate context fit for nuanced cases where multiple occasions or mixed climates are plausible.

## Downstream implications
- Feature breakdown work must separate context input handling from customer-profile handling so request-time context does not become an opaque personalization proxy.
- Architecture work must preserve a shared context engine or equivalent shared context contract with explicit trust, precedence, and fallback semantics.
- Delivery contracts must indicate which context families were used, which were defaulted, and whether the recommendation set was produced in a degraded-context mode.
- Governance work must define which holiday, seasonal, and occasion overlays are operator-controlled versus system-derived.
- Analytics work must compare context-aware behavior against season-only or default baselines so apparent uplift is not confused with simple market or campaign effects.

## Review snapshot
Trigger: issue-created automation from GitHub issue #144.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the business requirements, vision, roadmap, product overview, and architecture overview provide enough context to define the required context families, precedence stack, fallback behavior, and measurement expectations without inventing implementation-specific schemas or ranking formulas.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before finalizing numeric trust thresholds, provider scope, and operator controls.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-007 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for provider choices, numeric thresholds, and operator controls.
