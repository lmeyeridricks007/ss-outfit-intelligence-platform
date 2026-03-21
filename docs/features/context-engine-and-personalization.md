# Feature: Context engine and personalization

**Upstream traceability:** `docs/project/business-requirements.md` (BR-007, BR-006, BR-012, BR-002); `docs/project/br/br-007-context-aware-logic.md`, `br-006-customer-signal-usage.md`, `br-012-identity-and-profile-foundation.md`, `br-002-multi-type-recommendation-support.md`; `docs/project/vision.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md` (`context engine`, `style profile`, `recommendation type`, `trace ID`); `docs/project/roadmap.md` (Phase 2 expansion, Phase 3 channel scale).

---

## 1. Purpose

Resolve request-time context and bounded personalization inputs into a consistent decision payload that makes recommendations feel appropriate for the customer's current situation without collapsing **contextual**, **occasion-based**, and **personal** logic into one opaque signal.

This feature exists to ensure the recommendation stack can answer questions such as:

- "What should I wear to a summer wedding in Madrid?"
- "What complements this navy suit in rainy weather?"
- "What is appropriate for this known customer's wardrobe and current season?"

The feature is therefore the bridge between:

- environmental and market context
- explicit occasion and session intent
- allowed customer-profile personalization
- governed recommendation delivery across ecommerce, email, and clienteling

## 2. Core Concept

The platform must produce two related but distinct artifacts before ranking:

1. a **context snapshot** that describes what is true about the current request
2. a **personalization envelope** that describes how much customer-specific data may safely influence the result

Those artifacts are then combined through deterministic precedence:

1. hard market and governance boundaries
2. explicit occasion intent
3. current session intent
4. high-confidence local environmental context
5. holiday and event overlays
6. seasonal baseline
7. allowed personal profile adjustments
8. market-safe defaults when richer evidence is weak

The key idea is that personalization is not allowed to bypass context truth, and context is not allowed to masquerade as customer profile truth.

## 3. Why This Feature Exists

The platform vision depends on recommendations that feel like a stylist understood both the customer and the situation. Generic recommendation systems fail here because they:

- treat weather, season, and occasion as afterthoughts
- let weak inferred context override strong explicit intent
- over-personalize from weak identity or stale profile signals
- behave differently by surface because each channel invents its own heuristics

This feature exists so Phase 2 and later channels can use one shared interpretation of context and personalization rather than scattering that logic across ranking models, frontend code, and campaign tooling.

## 4. User / Business Problems Solved

### Customer problems solved

- **P1 anchor-product shopper:** gets climate-appropriate outfit completion instead of generic adjacent items.
- **P2 returning customer:** receives recommendations that complement existing wardrobe context without exposing private reasoning or over-trusting weak identity matches.
- **P3 occasion-led shopper:** gets looks shaped by explicit event intent, season, and market relevance rather than a loose product list.

### Operator problems solved

- **S1 stylist / clienteling associate:** can trust that appointment context, market conditions, and known customer state were applied consistently.
- **S2 merchandiser:** can influence seasonal, holiday, and campaign overlays without breaking recommendation precedence.
- **S3 marketing manager:** can reuse one context and personalization model for email or lifecycle activation instead of re-creating segmentation logic.
- **S4 product / analytics / optimization:** can measure whether a recommendation was context-aware, profile-aware, both, or degraded.

### Business problems solved

- reduces seasonally or situationally absurd recommendations
- enables Phase 2 roadmap goals for context and personalization expansion
- keeps cross-channel recommendation behavior explainable and auditable
- preserves governance and privacy while still improving relevance

## 5. Scope

This feature covers the shared decision-preparation layer that turns request-time evidence and allowed customer context into reusable ranking inputs.

### Core responsibilities

- normalize market, location, weather, season, holiday, session, and occasion inputs
- evaluate personalization eligibility using consent, identity confidence, freshness, and provenance
- publish context and personalization summaries to ranking, delivery, and telemetry paths
- define fallback behavior when inputs are missing, stale, conflicting, or prohibited
- ensure downstream consumers understand whether a recommendation set is contextual, occasion-based, personal, or degraded

### Explicitly tracked open decisions

This feature depends on existing portfolio decisions rather than inventing new untracked ones:

- `DEC-004` - homepage / inspiration / occasion-led placement timing
- `DEC-008` - campaign versus personalization/context precedence
- `DEC-009` - weather provider, holiday-calendar ownership, and geo-consent handling by market

## 6. In Scope

- all BR-007 context families: market, location, weather, season, holiday or event calendar, session context, and occasion-led entry points
- bounded integration with BR-006 and BR-012 profile logic so personal recommendations activate only when allowed
- request-level context resolution for ecommerce, email packaging, and clienteling retrieval flows
- degradation states when exact context is missing or profile use is restricted
- snapshot and trace metadata needed by delivery contracts, experimentation, and audit tooling
- operator-facing policy controls for market baselines, seasonal definitions, and safe context overlays

## 7. Out of Scope

- full identity-resolution algorithms or customer graph internals
- full CDP or CRM roadmap
- final vendor selection for weather, calendar, or experimentation infrastructure
- precise indoor venue climate prediction, itinerary inference, or travel-intent modeling
- final channel-specific UI design for homepage, email, or clienteling surfaces
- ranking-model implementation details that belong to `recommendation-decisioning-and-ranking.md`

## 8. Main User Personas

| Persona | Why this feature matters |
| --- | --- |
| **P1 anchor-product shopper** | Needs recommendations that stay faithful to the anchor while adapting to weather, season, and market. |
| **P2 returning style-profile customer** | Needs bounded personalization that complements current request context rather than overriding it. |
| **P3 occasion-led shopper** | Needs explicit event intent to outrank weak inferred context and generic popularity. |
| **S1 stylist / clienteling associate** | Needs appointment-aware and customer-aware recommendations with visible fallback behavior. |
| **S3 marketing manager** | Needs reusable context and personalization semantics for lifecycle and campaign activation. |
| **S4 product / analytics stakeholder** | Needs measurable degraded-state, context-used, and personalization-mode signals. |

## 9. Main User Journeys

### Journey 1: Occasion-led anonymous shopper

1. Customer lands on a "summer wedding" page.
2. Market is known from storefront; weather is resolved from coarse location if permitted.
3. Occasion intent becomes the strongest recommendation input after market boundaries.
4. Ranking favors lightweight formalwear, breathable shirts, and appropriate footwear.
5. Response is marked as `occasion-based` and `contextual`, but not `personal`.

### Journey 2: Known customer on PDP

1. A known customer opens a navy suit PDP.
2. Session context identifies the anchor product and surface intent.
3. Context service resolves season, market, and weather.
4. Personalization eligibility confirms high-confidence identity and permitted use.
5. Ranking uses personal wardrobe-complement signals inside the allowed pool while still preserving the anchor-product mission.

### Journey 3: Email packaging before send

1. Lifecycle orchestration requests recommendation packaging for a known customer.
2. No live browsing session exists, so current-session context is weak.
3. Market, season, calendar overlays, and durable profile context are used if fresh and permitted.
4. If weather is stale or unavailable, the package falls back to season plus occasion-safe defaults.
5. Package metadata records which context families were applied and which were defaulted.

### Journey 4: Clienteling appointment retrieval

1. Associate opens an appointment tagged as "business travel wardrobe refresh."
2. Appointment reason becomes explicit occasion context.
3. Known customer profile is retrieved with confidence and suppression state.
4. Local market and weather refine layering and accessory choices.
5. Associate sees explanation-safe labels such as "occasion-led" and "weather-adjusted" without raw personal signal exposure.

## 10. Triggering Events / Inputs

### Request-time triggers

- recommendation API request from PDP, cart, homepage, occasion page, email packaging flow, or clienteling surface
- occasion selection by customer or associate
- campaign or landing-page context that explicitly frames the shopping mission
- cart updates, anchor-product changes, or search/filter changes that materially alter session intent

### Input sources

| Input family | Example inputs | Primary use |
| --- | --- | --- |
| Market | country code, locale, storefront market, assortment market | establish legal, seasonal, and catalog baseline |
| Location | coarse geo, shipping destination, store region, appointment location | refine weather and local event relevance |
| Weather | temperature band, precipitation, wind, severe weather, freshness timestamp | climate-sensitive ranking adjustments |
| Season | hemisphere season, merchandising season, market seasonal default | baseline when weather is weak or absent |
| Calendar | public holiday, gifting window, market event, formalwear peak | enrich relevance when aligned with stronger intent |
| Session | surface, anchor product, cart contents, search terms, filters, referrer | strongest real-time intent after explicit occasion |
| Occasion | wedding, black tie, business travel, interview, appointment reason | explicit ranking and composition intent |
| Personalization | canonical customer ID, identity confidence, consent state, profile summary, suppressions | bounded customer-specific tuning |

## 11. States / Lifecycle

This feature has both a request lifecycle and a snapshot lifecycle.

### Request lifecycle

1. **input collection** - gather request, market, session, and available customer context
2. **normalization** - bucket values into shared context vocabulary
3. **trust evaluation** - score confidence, freshness, provenance, and consent eligibility
4. **precedence resolution** - resolve conflicts between explicit, inferred, and defaulted context
5. **snapshot creation** - emit immutable context and personalization artifacts
6. **decision handoff** - pass snapshot references and summaries into ranking
7. **trace emission** - attach IDs and degradation flags to delivery and telemetry

### Snapshot states

| State | Meaning | Downstream behavior |
| --- | --- | --- |
| `resolved` | required market/session context available and trusted | full context-aware ranking allowed |
| `resolved_with_defaults` | some non-critical inputs defaulted | ranking allowed with reduced specificity |
| `bounded_personalization` | context resolved, but personal profile use limited | use session or context only plus safe profile hints |
| `degraded_context` | one or more important context inputs stale, weak, or unavailable | fall back to market-safe or season-safe defaults |
| `expired` | snapshot no longer fresh enough for reuse | must be recomputed before interactive or send-time use |

## 12. Business Rules

### Context precedence rules

1. hard market and governance boundaries win first
2. explicit occasion intent outranks inferred season or calendar
3. current session intent outranks broad defaults when it is specific
4. high-confidence weather refines climate-sensitive choices
5. holiday overlays may reinforce but must not invent explicit occasion intent
6. personalization may tune ranking only inside the allowed and context-valid pool

### Personalization activation rules

| Personalization mode | Allowed when | Typical use |
| --- | --- | --- |
| `full_profile` | consent valid, identity high-confidence, profile fresh enough | known-customer ecommerce, email, clienteling |
| `bounded_profile` | customer known but some inputs stale or only partly trusted | light profile tuning with strong rule and context controls |
| `session_only` | session signals permitted but durable identity weak or unavailable | anonymous or low-confidence ecommerce flows |
| `none` | consent denied, identity conflicted, or provenance inadequate | governed default recommendations only |

### Additional business rules

- **contextual** is not synonymous with **personal**
- **personal** recommendations must still respect occasion, market, inventory, and compatibility truth
- weak location cannot pretend to be precise local weather
- degraded context must be measurable and visible internally
- campaign boosts cannot silently override explicit customer occasion intent without an explicit precedence policy decision (`DEC-008`)
- customer-facing surfaces must never expose raw location precision, private profile reasoning, or low-level eligibility failures

## 13. Configuration Model

This feature requires governed configuration, not hard-coded surface heuristics.

### Key configuration domains

- market-to-calendar mapping
- market-to-season mapping, including hemisphere rules
- weather freshness thresholds and permitted geo precision by surface
- surface activation policy for contextual, occasion-based, and personal recommendation types
- personalization eligibility thresholds by channel
- fallback policies for provider outages or low-confidence context
- operator-controlled occasion taxonomy and campaign overlay rules

### Example configuration objects

| Object | Purpose | Example fields |
| --- | --- | --- |
| `ContextPolicy` | surface and market behavior | `policyId`, `surface`, `market`, `weatherEnabled`, `occasionPriority`, `fallbackMode` |
| `CalendarPolicy` | holiday/event overlays | `market`, `calendarSource`, `supportedEvents[]`, `priorityRules[]` |
| `PersonalizationPolicy` | bounded activation rules | `channel`, `requiredConsent`, `minIdentityConfidence`, `allowedProfileDomains[]` |
| `SeasonDefinition` | market seasonal baseline | `market`, `seasonStartDates`, `seasonLabels`, `transitionRules` |

## 14. Data Model

### Core entities

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `ContextSnapshot` | immutable request-time context artifact | `contextSnapshotId`, `requestId`, `market`, `locationPrecision`, `weatherState`, `season`, `calendarOverlays[]`, `sessionSummary`, `occasionIntent`, `resolutionState`, `createdAt`, `expiresAt` |
| `ContextSignal` | one normalized context input | `signalType`, `sourceType`, `value`, `confidence`, `freshnessTs`, `isExplicit`, `isDefaulted` |
| `PersonalizationEnvelope` | allowed customer-specific scope for ranking | `personalizationEnvelopeId`, `canonicalCustomerId?`, `identityConfidence`, `consentState`, `mode`, `allowedDomains[]`, `suppressionSummary[]`, `profileSnapshotId?` |
| `ContextDecisionSummary` | trace-friendly explanation summary | `usedSignals[]`, `defaultedSignals[]`, `degradationCodes[]`, `policyVersion`, `ruleContext[]` |

### Example snapshot

```json
{
  "contextSnapshotId": "ctx_01HXYZ...",
  "requestId": "req_01HXYZ...",
  "market": "ES",
  "locationPrecision": "city",
  "weatherState": {
    "band": "hot",
    "precipitation": "none",
    "confidence": "high",
    "freshnessTs": "2026-03-21T09:58:00Z"
  },
  "season": "spring_summer",
  "calendarOverlays": ["wedding_peak"],
  "sessionSummary": {
    "surface": "occasion_page",
    "anchorProductId": null
  },
  "occasionIntent": "summer_wedding",
  "resolutionState": "resolved",
  "expiresAt": "2026-03-21T10:13:00Z"
}
```

## 15. Read Model / Projection Needs

- weather cache by geo tile or coarse location bucket with TTL and provider lineage
- yearly holiday and event tables by market
- market-season reference table with transition windows
- surface-specific policy projections for fast read-time evaluation
- lightweight profile-eligibility projection that includes consent, identity confidence, and allowed domains
- dashboards that aggregate context coverage, degradation rates, and personalization-mode usage by surface

## 16. APIs / Contracts

This feature should expose internal shared contracts rather than channel-specific heuristics.

### Internal service operations

- `POST /internal/context/resolve`
  - input: request, market, session, occasion, optional location hints
  - output: `ContextSnapshot`, `ContextDecisionSummary`
- `POST /internal/personalization/evaluate`
  - input: customer/session identifiers, channel, market, purpose
  - output: `PersonalizationEnvelope`
- `POST /internal/context/prepare-decision`
  - input: recommendation request plus optional customer/session context
  - output: combined references used by ranking

### Required delivery-contract metadata

Recommendation delivery should carry at minimum:

- `contextSnapshotId`
- `personalizationEnvelopeId`
- `recommendationSetId`
- `traceId`
- `recommendationType`
- `contextUsed[]`
- `degradationCodes[]`
- `identityConfidence`
- `personalizationMode`

### Example delivery metadata fragment

```json
{
  "recommendationSetId": "rs_01HXYZ...",
  "traceId": "tr_01HXYZ...",
  "recommendationType": "occasion-based",
  "contextSnapshotId": "ctx_01HXYZ...",
  "personalizationEnvelopeId": "pe_01HXYZ...",
  "contextUsed": ["market", "occasion", "weather", "season"],
  "degradationCodes": [],
  "identityConfidence": "unknown",
  "personalizationMode": "none"
}
```

## 17. Events / Async Flows

### Key events

- `context.snapshot.resolved`
- `context.snapshot.degraded`
- `context.provider.failed`
- `personalization.eligibility.evaluated`
- `personalization.mode.changed`
- `occasion.intent.selected`
- `weather.cache.refreshed`

### Async flows

1. **Email packaging refresh**
   - package flow requests fresh context snapshot
   - stale or expired weather/calendar inputs trigger async refresh
   - if refresh fails, packaging uses season-safe defaults and emits degradation events

2. **Policy change propagation**
   - updated market or calendar policies invalidate projections
   - next request uses new policy version
   - traces preserve the policy version used at decision time

3. **Provider outage handling**
   - provider failure emits operational event
   - downstream decisioning automatically switches to fallback mode
   - analytics can separate degraded-provider behavior from ordinary season-only behavior

## 18. UI / UX Design

### Customer-facing expectations

- occasion entry points should be explicit and understandable, such as "wedding" or "business travel"
- copy may acknowledge high-level context like "picked for warm-weather formal dressing"
- UI must not expose raw location, identity-confidence, or sensitive profile reasoning
- degraded states should fail gracefully, not display technical explanations

### Operator-facing expectations

- campaign and merchandising tools need clear labels for which context layers are active
- clienteling surfaces should show summary badges like `occasion-led`, `weather-adjusted`, or `profile-bounded`
- debugging views need enough internal detail to understand why context or personalization was reduced

## 19. Main Screens / Components

- occasion landing pages and occasion selectors
- homepage or inspiration placement configuration for contextual and personal modules
- clienteling appointment context panel
- internal context policy console for markets, seasons, and calendars
- trace and troubleshooting drawer showing used/defaulted context families
- experiment dashboard slices for context-aware versus degraded recommendations

## 20. Permissions / Security Rules

- precise geo use must respect market-specific consent and policy requirements
- profile-driven personalization requires explicit permitted-use checks before ranking
- operator-facing tooling must enforce role-based access to customer-context summaries
- raw provider payloads and precise location data should not be exposed to general operator roles
- logs and traces must preserve utility while minimizing unnecessary sensitive detail

## 21. Notifications / Alerts / Side Effects

- alert when weather or calendar provider failure materially increases degraded-context rates
- alert when personalization eligibility drops unexpectedly for a surface or market
- emit operational notices when policy changes invalidate cached projections
- surface degradation flags to experimentation and analytics so performance comparisons remain honest

## 22. Integrations / Dependencies

### Direct dependencies

- `shared-contracts-and-delivery-api.md` for recommendation-set metadata
- `identity-and-style-profile.md` for identity confidence, style profile, and suppression inputs
- `customer-signal-ingestion.md` for fresh and provenance-aware customer signals
- `recommendation-decisioning-and-ranking.md` for final candidate selection and ordering
- `analytics-and-experimentation.md` for context-used and personalization-mode telemetry
- `explainability-and-auditability.md` for trace reconstruction and internal explanation boundaries
- `ecommerce-surface-experiences.md` and `channel-expansion-email-and-clienteling.md` for channel behaviors

### External integrations

- weather provider or internal weather service
- holiday or event-calendar source
- storefront or market configuration service
- session signal sources from ecommerce surfaces
- clienteling appointment context source

## 23. Edge Cases / Failure Cases

- traveler browsing from one market while shopping for another delivery market
- explicit occasion conflicts with search or filter behavior
- high-confidence market but low-confidence location
- severe weather signal that does not align with current assortment depth
- known customer with valid identity but expired profile freshness
- email packaging created earlier than send time, causing context staleness
- clienteling session with reviewed stylist context but no reliable local weather
- campaign overlay pushing seasonal content that conflicts with explicit occasion intent

### Failure-handling expectations

- explicit occasion wins over inferred calendar intent
- high-confidence market remains even when local weather fails
- low-confidence identity reduces personalization depth instead of blocking delivery
- provider outage must degrade to season-safe or market-safe defaults rather than inconsistent behavior

## 24. Non-Functional Requirements

- interactive ecommerce resolution must fit within a tight request-time latency budget
- email packaging may allow asynchronous refresh, but still needs freshness controls before send
- snapshot generation must be reproducible enough for audit and experimentation analysis
- policies and projections must support multi-market scale without channel-specific forks
- degraded operation must be first-class, not an error-path afterthought

## 25. Analytics / Auditability Requirements

### Required telemetry

- context coverage by family, surface, market, and channel
- personalization mode by request and recommendation set
- degradation rate and degradation reason by surface
- context families actually used in ranking
- identity-confidence state attached to recommendation outcomes when a customer is known

### Required audit fields

- `recommendationSetId`
- `traceId`
- `contextSnapshotId`
- `personalizationEnvelopeId`
- `policyVersion`
- `contextUsed[]`
- `defaultedSignals[]`
- `degradationCodes[]`
- `identityConfidence`
- `experimentId` and `variantId`

### Measurement expectations

- compare weather-aware versus season-only behavior
- compare explicit-occasion versus defaulted-context performance
- separate full-profile, bounded-profile, session-only, and non-personalized outcomes
- preserve lineage so teams can reconstruct whether poor performance came from weak context, weak profile trust, or ranking quality

## 26. Testing Requirements

### Functional tests

- precedence tests for occasion versus calendar versus weather versus session intent
- surface tests for PDP, cart, homepage, email packaging, and clienteling retrieval
- personalization mode tests across consent and identity-confidence states
- degradation tests when provider or policy inputs are missing or stale

### Data and contract tests

- schema tests for snapshot and personalization-envelope payloads
- policy projection tests by market and season
- trace-field completeness tests for delivery and telemetry paths

### Scenario tests

- summer wedding in hot weather
- rainy commuter context with anchor-product suit
- anonymous session with search-led occasion hints
- known customer with bounded identity confidence
- stale email package regenerated before send

## 27. Recommended Architecture

- a dedicated **context resolution service** that owns request-time context normalization
- a separate but adjacent **personalization eligibility component** that evaluates consent, identity confidence, freshness, and allowed profile domains
- immutable snapshot storage or snapshot serialization so downstream ranking and telemetry reference stable artifacts
- provider adapters with timeouts, retries, and circuit breakers for weather and calendar sources
- shared policy store and read-optimized projections for market, season, and activation rules

This architecture keeps context resolution, profile eligibility, and ranking distinct while allowing them to interoperate through stable contracts.

## 28. Recommended Technical Design

- generate immutable `contextSnapshotId` and `personalizationEnvelopeId` per decision-preparation step
- version normalization rules and policy projections so traces can be reconstructed later
- use coarse location buckets for most ranking use cases unless higher precision is explicitly justified and permitted
- encode degradation codes explicitly rather than relying on null fields alone
- keep `ContextSignal` and `PersonalizationEnvelope` separate so downstream systems can tell whether a recommendation was context-aware, personal, or both
- support expiry semantics so reused snapshots in email or batch packaging cannot silently become stale

## 29. Suggested Implementation Phasing

### Phase 1

- market, surface, anchor-product, cart, and season baselines
- no deep personal recommendation activation beyond session-safe behavior
- trace fields prepared for later Phase 2 expansion

### Phase 2

- weather, holiday, and explicit occasion activation
- bounded profile-aware personalization for ecommerce and selected owned channels
- shared snapshot and degradation semantics across delivery and analytics

### Phase 3

- clienteling appointment-context enrichment
- richer homepage and inspiration contextualization where product decisions confirm placement scope (`DEC-004`)
- stronger operator-facing policy and troubleshooting tooling

### Phase 4 and later

- deeper CM-aware contextualization
- more nuanced cross-channel optimization once precedence, consent, and trust boundaries are proven

## 30. Summary

The context engine and personalization feature is the platform's shared interpretation layer for "what is happening now?" and "how much do we safely know about this customer?" It makes **contextual**, **occasion-based**, and **personal** recommendation types trustworthy by:

- separating request-time context from durable profile logic
- enforcing deterministic precedence and bounded personalization
- preserving snapshot, trace, and degraded-state semantics across channels
- enabling Phase 2 roadmap expansion without channel-specific reinvention

The remaining major uncertainties are already tracked in the portfolio decision register (`DEC-004`, `DEC-008`, `DEC-009`) rather than being hidden inside the feature spec.
