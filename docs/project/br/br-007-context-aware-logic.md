# BR-007: Context-aware logic

## Traceability

- **Board item:** BR-007
- **GitHub issue:** #114
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #114 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/vision.md`, `docs/project/roadmap.md`
- **Related inputs:** location, country, weather, season, holiday or event calendars, and session context for occasion-led recommendations
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 2 - Personalization and context enrichment

## 1. Requirement summary

SuitSupply needs a governed way to use contextual signals so recommendation sets feel locally relevant, seasonally appropriate, and occasion-aware without becoming unstable, opaque, or too dependent on noisy third-party enrichments. The platform must define which context inputs are in scope, how they should be normalized, where they are allowed to influence candidate selection or ranking, and what measurable outcomes should prove that contextual logic is improving relevance rather than adding noise.

This business requirement defines:

- the contextual input classes that may influence recommendation behavior
- the difference between explicit, durable, and derived context signals
- the decision boundaries for when context may guide retrieval, ranking, suppression, or fallback
- the surface-specific expectations for context-aware activation
- the measurable relevance, traceability, and operational expectations for contextual recommendation behavior

This BR does not define:

- the final weather-provider, calendar-provider, or geo-resolution implementation
- exact model features, weights, or ranking formulas
- the final API field schema for every context attribute
- the UI design for occasion selectors, weather messaging, or customer-facing explanations
- region-specific legal or policy text beyond the requirement to respect those constraints

## 2. Problem and opportunity

Recommendation quality degrades when the platform ignores obvious context. A heavy winter look shown during hot weather, a holiday-oriented outfit shown after the event window, or a business-formal recommendation shown in a strongly occasion-led wedding journey all reduce trust because they feel detached from the customer's real situation.

At the same time, contextual logic can also become harmful if it is used without clear boundaries:

- third-party weather data may be stale or wrong
- inferred location may be too imprecise for strong decisioning
- event calendars may be culturally or regionally incomplete
- session cues may be noisy and overreact to weak signals
- contextual ranking may create unstable results if it overrides stronger compatibility or merchandising rules

The opportunity is to create a context-aware logic policy that:

- improves complete-look relevance for local conditions and occasion-led journeys
- keeps explicit customer intent and hard compatibility rules ahead of weak inferred context
- gives downstream teams clear rules for confidence, freshness, fallback, and traceability
- preserves brand styling integrity while still adapting recommendation sets to country, season, weather, holiday timing, and live session cues

## 3. Business outcomes

This requirement must support these outcomes:

1. **More locally relevant recommendations** across ecommerce, email, and clienteling surfaces where country, season, or regional context materially affects outfit usefulness.
2. **Stronger occasion-led relevance** when session context or calendar windows suggest a wedding, holiday, travel, or business-formal need.
3. **Fewer obvious contextual mismatches** such as seasonally inappropriate or event-misaligned recommendations.
4. **Safer contextual adaptation** because noisy, stale, or weak context signals degrade gracefully instead of driving assertive recommendation changes.
5. **Clear downstream readiness** for feature, architecture, telemetry, and experimentation work around contextual recommendation behavior.

## 4. Guiding business principles for context-aware logic

All downstream work must preserve these principles:

### 4.1 Context improves relevance, but does not replace compatibility

Context may influence which eligible looks or products are emphasized, but it must not override hard compatibility rules, inventory and assortment constraints, protected curated placements, or required merchandising governance.

### 4.2 Explicit intent is stronger than inferred context

An explicit customer choice such as a selected occasion, chosen market, preferred store, active cart composition, or clearly stated journey intent is stronger than weakly inferred weather, location, or seasonal assumptions.

### 4.3 Context should be normalized before it is used

Downstream systems should not make recommendation decisions directly from raw provider payloads. Country, location, weather, season, holiday or event context, and session context must be normalized into recommendation-ready categories with provenance and timestamp information.

### 4.4 Weak context should bias ranking softly, not force hard decisions

Low-confidence or stale context may inform softer ordering among already valid candidates, but it should not create aggressive filtering, suppression, or large recommendation swings.

### 4.5 Local relevance must remain respectful and brand-safe

Context-aware recommendations should feel helpful, not invasive. They must avoid unnecessary precision, surprising customer-facing rationale, or assumptions that would feel culturally insensitive, overly specific, or unsupported.

### 4.6 Asynchronous channels require more durable context

Transient context such as current weather or fleeting session behavior is more suitable for real-time surfaces than for email or delayed activation. Asynchronous channels should favor durable contextual signals such as country, season, approved event windows, and explicit occasion preferences.

## 5. Context input classes and normalization expectations

Context inputs are not equally strong, and they do not all deserve the same decision influence.

### 5.1 In-scope context classes

The platform must normalize and preserve these context classes for recommendation use:

| Context class | Examples in scope | Primary recommendation value | Default freshness tier | Normalization expectation | Boundary notes |
|---|---|---|---|---|---|
| Country | shipping market, selected locale, explicit country setting | legal and policy routing, regional assortment, holiday mapping, market-specific styling norms | Durable operational freshness | stable country code and market mapping | Should be treated as a strong default context when explicit or account-backed |
| Location or region | metro area, store market, coarse geo region, climate region | local climate approximation, assortment relevance, store-aware clienteling, regional event relevance | Operational freshness | coarse normalized region or store-market mapping rather than raw coordinates | Avoid unnecessary precision and customer-facing exposure of exact location reasoning |
| Weather | temperature band, precipitation condition, wind severity, heat or cold range | near-term wearability and local suitability on real-time surfaces | Active-session or near-real-time operational freshness | provider values normalized into recommendation-friendly bands and condition groups | Weather alone should not hard-exclude valid products unless another hard rule supports it |
| Season | regional season, merchandising season, climate-adjusted seasonality | seasonal styling, fabric emphasis, layered versus lightweight looks | Operational freshness | explicit season taxonomy that accounts for geography, not just calendar month | Must not assume one hemisphere or one climate model globally |
| Holiday or event calendar | public holidays, wedding season, travel peaks, gifting windows, local event periods | occasion-led look emphasis and timing-sensitive styling | Operational freshness | approved country or regional calendar IDs and event-window rules | Must distinguish broad approved event windows from speculative personal-event inference |
| Session context | surface, entry source, active anchor product, cart state, search terms, selected filters, explicit occasion choice, journey step | current intent interpretation and occasion-led recommendation assembly | Active-session freshness | normalized session attributes and journey-state labels | Must not rely on hidden fingerprinting or unsupported sensitive inference |

### 5.2 Explicit versus derived context

Downstream work must distinguish:

- **Explicit context:** customer-selected country, chosen store, selected occasion filter, active anchor product, current cart, or other directly observed journey state.
- **Derived context:** IP-based location, provider weather, inferred season mapping, event-window matching, or inferred journey intent from behavior.

Explicit context is generally stronger than derived context and should receive more decision weight and more stable treatment.

### 5.3 Durable versus transient context

Downstream work must also distinguish:

- **Durable context:** country, approved regional calendar mappings, regional season model, selected store, and other context unlikely to change minute to minute.
- **Transient context:** weather conditions, session step, active surface, active search/query context, and short-lived occasion cues from the current journey.

Durable context is more appropriate for asynchronous activation and cross-session continuity. Transient context is more appropriate for PDP, cart, homepage personalization, and live clienteling moments.

### 5.4 Disallowed contextual usage patterns

The following are out of scope for this BR:

- using precise location or derived location detail beyond what recommendation relevance materially needs
- inferring sensitive personal attributes from location, calendar, or behavioral context
- treating transient weather or session signals as durable truth across later channels
- assuming a customer-specific life event from weak calendar proximity alone
- allowing contextual cues to override hard compatibility, inventory, governance, or policy constraints

## 6. Context confidence and freshness expectations

Context-aware recommendation behavior must preserve business-level expectations for confidence and freshness rather than treating all context as equally valid.

### 6.1 Strong contextual signals

The following generally qualify as stronger context signals:

- explicit country or locale selection
- explicit store or market selection
- explicit occasion choice in the session
- current anchor product, active cart, and surface state
- approved calendar windows mapped to a supported market

Business expectation:

- These signals may influence candidate selection, contextual prioritization, and surface-specific module behavior when they are current and permitted.
- They should be visible in trace context as explicit or high-confidence inputs.

### 6.2 Medium-strength contextual signals

The following usually qualify as medium-strength context signals:

- coarse location or regional mapping
- normalized regional season
- current weather from an approved provider
- query or browse-derived occasion cues when they are reinforced by the active session

Business expectation:

- These signals may shape ranking or candidate emphasis when they are fresh and materially relevant to the surface.
- They should be treated more cautiously when they conflict with explicit customer intent or durable profile context.

### 6.3 Weak or ambiguous contextual signals

The following generally qualify as weak or ambiguous context:

- imprecise geo resolution
- stale weather data
- thin session context with only one weak clue
- broad event calendars that do not clearly match the journey
- inferred occasion logic with low supporting evidence

Business expectation:

- These signals should bias ranking softly, if at all.
- They should not trigger hard suppression, strong occasion labeling, or large ordering changes by themselves.

### 6.4 Freshness tiers

#### Active-session freshness

This tier applies to:

- session context
- current weather on real-time surfaces
- active search, browse, and occasion-selection state

Business expectation:

- These signals should be available in near-real-time for PDP, cart, homepage personalization, and live clienteling use.
- If they are stale, delayed, or unavailable, the platform must fall back to durable context, curated defaults, or rule-based recommendation behavior.

#### Operational freshness

This tier applies to:

- country and market mapping
- coarse location or store-market context
- holiday and event calendar windows
- season mappings

Business expectation:

- These signals should be refreshed reliably enough to preserve contextual trust across supported markets.
- Multi-day drift may be acceptable for some inputs such as season models, but not if it causes obvious event-window or regional-context errors.

### 6.5 Freshness failure behavior

If a context input is stale, missing, or below the confidence needed for strong use, downstream implementations must:

1. mark the context input as stale, weak, or unavailable in decision trace context
2. reduce or remove its influence from candidate selection or ranking
3. fall back to stronger explicit context, durable context, or governed non-contextual recommendation behavior
4. avoid silently applying low-quality context in a way that makes the recommendation reasoning unreconstructable

## 7. Decision boundaries and precedence rules

Context-aware logic must remain subordinate to stronger product, governance, and intent controls.

### 7.1 Required precedence order

Downstream feature and architecture work must preserve this business interpretation of decision precedence:

1. **Hard eligibility and safety constraints:** inventory, assortment eligibility, region and policy restrictions, and compatibility rules.
2. **Explicit customer and journey intent:** selected occasion, active anchor product, active cart state, chosen locale or store, and strong current-session actions.
3. **Governance and merchandising controls:** curated protections, pinned placements, campaign priorities, suppressions, and operator overrides.
4. **Durable contextual relevance:** country, approved region, season model, and approved holiday or event windows.
5. **Transient contextual relevance:** current weather and softer session-derived occasion or journey cues.
6. **AI-ranked optimization:** ordering and selection within the boundaries created by the earlier layers.

### 7.2 What context may influence

When confidence and freshness are sufficient, context may influence:

- which valid looks or products are prioritized for the current market or season
- which occasion-led look families are emphasized
- how ranking differentiates among already eligible complements
- whether real-time surfaces emphasize lighter, heavier, more formal, or more event-relevant options
- which recommendation type or module variant is most appropriate for the active surface

### 7.3 What context must not do

Context must not:

- override hard compatibility, inventory, assortment, or suppression rules
- unseat protected curated placements that are intentionally pinned or required
- contradict explicit customer choices without stronger business justification
- create customer-facing messaging that exposes precise location or speculative event assumptions
- create unstable recommendation oscillation because weather or session noise changed moment to moment
- become the only basis for asynchronous campaign activation when the signal is too transient

### 7.4 Soft versus strong contextual influence

Downstream work must distinguish between:

- **Strong contextual influence:** candidate emphasis, occasion-family prioritization, or visible module adaptation when explicit or high-confidence context supports it.
- **Soft contextual influence:** ordering bias among valid candidates when context is helpful but not strong enough to justify more assertive changes.

Hard exclusion or suppression should only occur when a non-context hard rule already supports it, such as regional assortment unavailability or a governance-based restriction.

### 7.5 Conflict handling expectation

If contextual signals conflict, downstream logic should resolve them in this order:

1. explicit customer choice over inferred context
2. active-session intent over weaker ambient context
3. durable market rules over third-party enrichment
4. curated or governance-protected behavior over contextual ranking preference

Examples:

- an explicit wedding occasion choice should outrank generic seasonal assumptions
- a known summer climate region should not be overridden by a stale cold-weather feed
- a protected campaign look should not disappear simply because weak session context suggests a different style direction

## 8. Surface-specific interpretation

Different surfaces need different levels of contextual sensitivity.

### 8.1 PDP

PDP should emphasize:

- active anchor-product context
- explicit occasion cues from the session
- current weather and season only when they materially improve the immediate recommendation moment
- local market and assortment reality

PDP should avoid:

- overreacting to weak geo or weather signals when anchor compatibility is the stronger determinant
- introducing large recommendation swings that make the module feel inconsistent during a single product-view journey

### 8.2 Cart

Cart should emphasize:

- current cart composition
- strong session intent
- immediate contextual relevance for complementary items
- local assortment and season fit

Cart should avoid:

- replacing obviously compatible complete-look attachments with weakly contextual but less relevant items
- treating weather as stronger than the actual cart composition

### 8.3 Homepage and web personalization

Homepage and broader web personalization surfaces may use:

- country and region
- season
- holiday or event windows
- current weather where freshness is good
- session context and current journey pattern

These surfaces have more room for contextual storytelling and module selection, but they must still preserve graceful fallback when context is missing or ambiguous.

### 8.4 Email

Email should prioritize:

- durable country and market context
- season and approved event windows
- explicit occasion preferences if captured and permitted

Email should avoid:

- dependence on rapidly changing weather or thin session context
- customer-facing claims that imply exact real-time local knowledge unless the activation path is explicitly designed for that use

### 8.5 Clienteling

Clienteling may use richer context where policy and workflow support it, including:

- store market or appointment context
- local event timing
- strong active-session or assisted-selling context

Clienteling still must preserve:

- structured and auditable context inputs
- respect for explicit stylist or customer direction
- careful treatment of context that may be helpful operationally but too weak for assertive recommendation changes

### 8.6 RTW versus CM nuance

- **RTW:** may react more directly to current weather, season, and immediate session context because many decisions are near-term and inventory-backed.
- **CM:** should use current context more cautiously, emphasizing occasion intent, appointment context, and durable styling direction over transient weather shifts, because the garment journey can extend beyond the immediate moment.

## 9. Traceability requirements for contextual logic

Context-aware recommendation sets must remain auditable.

### 9.1 Minimum traceability fields

Every recommendation set influenced by context must preserve enough metadata to reconstruct:

- recommendation set ID
- trace ID
- recommendation type, surface, and channel
- country and market context used, when available
- location or regional context used, at the normalized level
- weather input used, including freshness state and source reference where applicable
- season context used
- holiday or event-window context used
- session-context classes used
- whether each context input was explicit, derived, durable, or transient
- whether each context input was used, ignored, or degraded because of low confidence or staleness
- applied rule, campaign, experiment, and override context where relevant

### 9.2 Context attribution expectation

Internal teams do not need every raw provider payload in the trace, but they must be able to see:

- which context classes were available
- which context classes materially influenced the recommendation set
- which context classes were suppressed because they were stale, weak, conflicting, or not appropriate for the surface
- whether the result was primarily shaped by explicit intent, durable context, or transient context

### 9.3 Auditability expectation

The trace model must support later investigation of:

- obvious seasonal or weather mismatches
- incorrect holiday or event-window activation
- unstable results caused by noisy session context
- country or region misclassification
- differences between contextual and non-contextual recommendation variants

## 10. Functional business requirements

### 10.1 Normalized-context requirement

The platform must support recommendation behavior that uses normalized context inputs for country, location or region, weather, season, holiday or event calendars, and session context.

### 10.2 Context-classification requirement

Downstream work must distinguish explicit versus derived context and durable versus transient context so the same signal is not treated as equally strong in every channel or decision.

### 10.3 Context-precedence requirement

Context-aware logic must operate below hard eligibility, compatibility, governance, and explicit customer-intent controls.

### 10.4 Explicit-intent protection requirement

When explicit customer or journey intent conflicts with weaker inferred context, the platform must favor the explicit signal unless a stronger governed rule requires otherwise.

### 10.5 Confidence-and-freshness requirement

The platform must preserve explicit confidence and freshness handling for contextual inputs, with graceful fallback when signals are stale, missing, or weak.

### 10.6 Surface-appropriate activation requirement

The platform must apply contextual inputs differently by surface, using transient context mainly on real-time surfaces and more durable context on asynchronous channels.

### 10.7 Respectful-location requirement

The platform must use only the level of location precision needed for recommendation relevance and must avoid customer-facing outputs that expose precise or surprising location reasoning.

### 10.8 Occasion-led context requirement

The platform must support context-aware recommendation behavior that improves occasion-led journeys through explicit occasion cues, approved holiday or event windows, and session context where those signals materially improve complete-look relevance.

### 10.9 Context-traceability requirement

Each recommendation set influenced by context must preserve enough trace context to show which contextual inputs were available, which were used, and which were degraded or ignored.

### 10.10 Measurable-relevance requirement

Context-aware logic must be measurable by surface and recommendation type so internal teams can determine whether contextual inputs improved recommendation usefulness relative to governed non-contextual baselines.

## 11. Surface and phase expectations

### 11.1 Phase 2 scope

Phase 2 is where contextual logic becomes materially richer:

- more explicit occasion-led discovery and homepage personalization
- stronger adaptation to season, weather, and local market context
- more deliberate use of holiday and event windows
- clearer traceability and fallback behavior for contextual recommendation sets

### 11.2 Phase sequencing rule

Richer contextual logic should expand only when the platform can preserve:

- normalized context classes and source provenance
- freshness visibility for weather and session-driven context
- strong fallback paths when external context is missing or degraded
- recommendation set and trace ID continuity for measurement
- consistent governance so contextual logic does not bypass compatibility or protected curation

### 11.3 Recommended downstream focus

The next stage should convert this BR into feature-level requirements for:

- context normalization and classification
- decision precedence and conflict handling
- surface-specific contextual activation
- event-window and seasonal logic governance
- contextual telemetry and experimentability

## 12. Measurable relevance expectations

This BR is not complete unless contextual logic can be evaluated with measurable outcomes instead of subjective impressions alone.

### 12.1 Recommendation quality measures

Downstream teams must be able to measure whether context-aware recommendation sets improve:

- recommendation click-through rate on surfaces where context is active
- add-to-cart and purchase influence for context-aware recommendation sets
- complete-look engagement for occasion-led and seasonally relevant experiences
- reduction in obvious mismatch signals such as dismissals or low engagement on contextually adapted modules

### 12.2 Context-specific relevance measures

Downstream teams must be able to measure:

- performance uplift of context-aware variants versus governed non-contextual baselines
- improvement for sessions with explicit occasion or strong contextual cues versus generic journeys
- difference in engagement when weather or seasonal context is available and fresh versus when fallback logic is used
- quality of holiday or event-window activation, including whether those recommendation sets outperform generic alternatives during active windows

### 12.3 Decision-quality and governance measures

Downstream teams must be able to measure:

- percentage of context-aware recommendation sets with valid recommendation set ID and trace ID
- percentage of context-aware recommendation sets with recorded context attribution, freshness state, and context classification
- percentage of context-aware recommendation sets that used fallback because context was stale, weak, or unavailable
- rate of recommendation-quality issues attributable to incorrect, stale, or overly aggressive contextual logic

### 12.4 Operational measures

Downstream teams must be able to measure:

- freshness compliance for weather and active-session context on real-time surfaces
- coverage of country, season, and approved event-window mappings across supported markets
- availability of context inputs by surface and market
- ability to compare contextual and non-contextual recommendation variants in analytics and experimentation workflows

### 12.5 Measurement interpretation rule

Context-aware logic should only expand when measured relevance is positive or neutral relative to safer governed baselines. If contextual enrichment adds noise, instability, or poor traceability, the system should prefer narrower contextual use rather than assuming more context is always better.

## 13. Constraints and guardrails

- Context must not bypass hard compatibility, inventory, assortment, campaign, or merchandising controls.
- Recommendation decisions must tolerate partial or degraded context availability.
- Weather and session context must not be assumed to be durable across channels.
- Context normalization must account for regional and seasonal variation rather than assuming one global pattern.
- Customer-facing outputs must not expose precise location detail or speculative event assumptions.
- Holiday and event-window logic must use approved calendar mappings rather than ad hoc or culturally unreviewed assumptions.

## 14. Assumptions

- Supported markets will have enough country, regional, weather, season, and calendar coverage to make contextual recommendation behavior meaningfully better than generic fallback behavior.
- Phase 2 is the correct stage to strengthen contextual adaptation after foundational recommendation quality, telemetry, and governance are already in place.
- Session context can provide strong occasion-led cues when the surface captures explicit filters, search terms, anchor products, or cart state clearly enough.
- Merchandising and optimization teams can define which contextual adaptations should be strong, soft, or disabled by surface and market.

## 15. Open questions for downstream feature breakdown

- What location granularity is acceptable by market and surface: country, region, metro, store market, or a narrower level?
- What weather freshness threshold is required for PDP, cart, homepage, and clienteling surfaces?
- Which holiday and event taxonomies are approved first, and who governs market-specific calendar quality?
- How should downstream work reconcile merchandising season tags with climate-based or hemisphere-based season interpretation?
- Which contextual triggers merit dedicated recommendation modules versus softer ranking bias only?
- What evidence threshold should distinguish an explicit occasion-led journey from a weak inferred occasion signal?

## 16. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for context normalization, classification, and provenance handling
2. feature scope for decision precedence, conflict resolution, and strong-versus-soft contextual influence
3. feature scope for surface-specific contextual activation and fallback behavior
4. feature scope for weather, season, and holiday or event-window freshness handling
5. feature scope for contextual traceability, experimentation, and relevance measurement

## 17. Exit criteria check

This BR is complete when downstream teams can see:

- which contextual input classes are in scope for recommendation use
- how explicit, durable, derived, and transient context differ in decision strength
- what decision boundaries prevent contextual logic from overriding harder controls
- how contextual relevance should be measured by surface, traceability, and fallback behavior
- where context-aware recommendation logic must degrade gracefully instead of forcing noisy personalization

## 18. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-007-context-aware-logic.md`

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
- No milestone human gate blocks completing this BR artifact, though downstream feature work must still define market-specific calendar governance, freshness thresholds, and surface-level conflict resolution rules.

Residual risks and open questions:

- Exact weather freshness thresholds and location granularity still require downstream feature and architecture decisions.
- Holiday and event-window taxonomies may need market-specific review to avoid culturally incomplete or overly broad assumptions.
