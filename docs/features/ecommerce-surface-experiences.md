# Feature: Ecommerce surface experiences

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003, BR-001, BR-002, BR-010); `docs/project/br/br-003-multi-surface-delivery.md`, `br-001-complete-look-recommendation-capability.md`, `br-010-analytics-and-experimentation.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/standards.md` (UI assumptions); `docs/project/glossary.md`; `docs/project/roadmap.md`; `docs/features/shared-contracts-and-delivery-api.md`; `docs/features/complete-look-orchestration.md`; `docs/features/analytics-and-experimentation.md`; `docs/features/open-decisions.md` (`DEC-002`, `DEC-004`, `DEC-005`, `DEC-006`, `DEC-016`).

---

## 1. Purpose

Define how ecommerce web surfaces consume the shared recommendation contract and turn it into clear, performant, measurable shopping experiences on PDP, cart, and later homepage or inspiration placements.

This feature owns the surface-side responsibilities for:

- requesting typed recommendation sets from the shared delivery layer
- rendering recommendation types with distinct UX treatment
- coordinating loading, empty, degraded, and retry states
- preserving `recommendationSetId` and `traceId` through telemetry and commerce actions
- keeping decision logic server-side while still giving web teams a reusable implementation model

It is the ecommerce presentation and integration layer for the recommendation platform, not a separate recommendation engine.

## 2. Core Concept

Ecommerce surfaces are thin but important consumers of the recommendation platform.

The core model is:

1. A storefront route, placement, or cart mutation produces a request context.
2. The web layer or storefront BFF calls the shared delivery contract with explicit surface metadata.
3. The contract returns one or more typed recommendation sets such as `outfit`, `cross-sell`, `upsell`, `contextual`, or `personal`.
4. The surface renders each set using the right visual treatment and shopping actions.
5. Telemetry records impression, click, save, add-to-cart, dismiss, and purchase continuity using the same stable identifiers.

The most important distinction is that ecommerce surfaces must **render recommendation meaning explicitly**:

- an **outfit** is shown as a grouped complete-look answer
- **cross-sell** is shown as complementary attachment
- **upsell** is shown as a premium or higher-value alternative

They must not collapse all recommendation types into one generic product carousel.

## 3. Why This Feature Exists

The roadmap makes Phase 1 ecommerce RTW delivery the first place the platform proves measurable value. That value is only realized if storefronts can:

- show recommendation sets in high-intent contexts without confusing the shopper
- preserve complete-look semantics on PDP and cart
- handle latency, inventory drift, and degraded recommendations honestly
- emit telemetry strong enough for experimentation and optimization

Without this feature, the platform could have strong backend decisioning but still fail at the customer moment where recommendations are monetized.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| `P1` anchor-product shopper | Wants a clear answer to "what goes with this?" on PDP | A grouped `outfit` module centered on the viewed anchor product |
| `P1` cart shopper | Needs relevant add-ons without noise or duplicate clutter | Cart-aware complete-the-look and attachment modules |
| `P2` returning customer | Later expects more relevant homepage or revisit experiences | Phase 2 surface hooks for profile- and context-aware placements |
| `P3` occasion-led shopper | Needs inspiration translated into shoppable modules | Homepage / inspiration placements that reuse the same contract and recommendation semantics |
| `S2` merchandiser | Needs controlled recommendation presentation across placements | Distinct module types, governed placement rules, and safe degraded handling |
| `S4` analytics / optimization | Needs trustworthy event continuity across commerce surfaces | Stable telemetry with placement, recommendation type, and trace linkage |

Business outcomes supported by this feature:

- higher attach rates on PDP and cart
- stronger average order value through coherent add-on behavior
- recommendation measurement that is comparable across placements
- reusable storefront patterns that avoid one-off recommendation implementations

## 5. Scope

This feature covers ecommerce web experiences that consume recommendation sets on customer-facing storefront surfaces.

It includes:

- PDP and cart in Phase 1
- homepage, inspiration, and occasion-led ecommerce placements in later phases
- request-context assembly on the client or storefront BFF
- rendering patterns, state handling, and placement behavior
- commerce action coordination such as add-to-cart and duplicate suppression
- frontend and server-fallback telemetry responsibilities

It does **not** cover:

- recommendation ranking or orchestration logic itself
- email or clienteling channel behavior
- native mobile implementations
- checkout redesign outside recommendation modules

Primary open decisions for this feature are already tracked in `docs/features/open-decisions.md`:

- `DEC-002` - interactive latency and availability targets
- `DEC-004` - expansion timing for homepage, inspiration, and occasion-led surfaces
- `DEC-005` - customer-facing copy conventions for recommendation types
- `DEC-006` - exact server-side impression fallback policy
- `DEC-016` - inventory freshness windows and bounded fallback policy by surface

## 6. In Scope

- PDP recommendation modules for `outfit`, `cross-sell`, and `upsell`
- cart recommendation modules for complete-the-look, complementary attachment, and premium alternatives
- shared storefront component patterns for typed recommendation modules
- placement-level configuration for which modules are enabled, ordered, or suppressed
- visual grouping and action treatment for grouped outfits vs flat item sets
- module lifecycle states: loading, ready, empty, degraded, hidden, error, retrying
- browser telemetry and server-side fallback telemetry for ecommerce placements
- client-side and BFF integration guidance for identity, consent, context, and experiments
- responsive and accessible rendering for desktop and mobile web
- safe inventory, duplicate, and variant-state handling at the surface layer

## 7. Out of Scope

- native iOS or Android experiences
- recommendation-serving infrastructure or model architecture
- admin, merchandising, or operator tooling
- campaign email rendering or clienteling experiences
- checkout-wide merchandising and funnel redesign unrelated to recommendation modules
- final design-system component ownership decisions outside the recommendation surface contract

## 8. Main User Personas

| Persona | How this feature serves them |
| --- | --- |
| `P1` anchor-product shopper | Sees grouped outfit and attachment modules that help complete the current shopping mission |
| `P1` cart shopper | Sees relevant add-ons that respect current cart contents and do not duplicate obvious selections |
| `P2` returning customer | Later receives homepage or revisit experiences that remain transparent and context-safe |
| `P3` occasion-led shopper | Later encounters ecommerce modules that translate occasion intent into shoppable recommendations |
| `S2` merchandiser | Gains predictable placement behavior and recommendation-type distinction on storefronts |
| `S4` analytics / optimization | Gets stable placement IDs, event continuity, and experiment-aware telemetry |

## 9. Main User Journeys

### Journey 1: PDP anchor-product complete look

1. Shopper opens a PDP for a supported anchor product.
2. Storefront prepares a recommendation request with `channel=web`, `surface=pdp`, placement ID, market, mode, and anchor product ID.
3. Shared delivery API returns an `outfit` set and optionally `cross-sell` or `upsell` sets.
4. PDP renders the complete-look module as a grouped answer, not a generic carousel.
5. Shopper clicks a recommended item or adds it to cart.
6. Events preserve `recommendationSetId`, `traceId`, recommendation type, and placement.

### Journey 2: Cart complete-the-look

1. Shopper lands on cart or mutates cart contents.
2. Storefront derives a cart request context from line items, quantities, mode, and market.
3. Shared delivery API returns cart-aware recommendation sets.
4. UI suppresses obvious duplicates already present in cart and emphasizes relevant attach actions.
5. Cart add-to-cart and purchase telemetry remains linked to the originating set.

### Journey 3: Homepage or inspiration placement

1. Shopper lands on homepage or inspiration entry.
2. Placement configuration determines which recommendation types are allowed for this surface.
3. Delivery request includes placement intent plus session or customer context where permitted.
4. Surface renders contextual or personal modules using the same typed contract.
5. Telemetry and degradation rules remain consistent with PDP and cart, even if the journey is less immediate.

### Journey 4: Anonymous degraded path

1. Shopper is anonymous or has low-confidence identity.
2. Surface still requests recommendations, but request context omits or bounds personal fields.
3. API may return contextual or non-personal fallback sets, or explicit degraded flags.
4. UI shows a safe module, a smaller module, or suppresses the placement depending on policy.

## 10. Triggering Events / Inputs

| Trigger | Inputs | Notes |
| --- | --- | --- |
| PDP route load | `anchorProductId`, market, mode, placement ID, session/customer ref | Primary Phase 1 entry point |
| PDP variant change | selected variant / size / color, anchor product ID | May require revalidation or refetch |
| Cart load | cart lines, market, mode, placement ID | Primary Phase 1 attachment path |
| Cart mutation | updated cart contents, added or removed line items | Refetch or locally invalidate current modules |
| Homepage / inspiration route load | placement definition, session/customer ref, optional context bundle | Phase 2 expansion |
| Consent or identity update | consent state, customer state, identity confidence | Can change personalization eligibility |
| Visibility threshold reached | module DOM state, viewport state | Triggers impression event semantics |
| Experiment assignment | experiment and variant IDs | Must persist through rendering and telemetry |

Important input classes:

- surface metadata: `channel`, `surface`, `placement`, market, mode
- shopping context: anchor product, cart contents, page category, occasion or inspiration seed
- customer state: anonymous session, known customer ref, identity confidence, consent flags
- rendering context: device type, locale, currency, viewport size
- recommendation metadata returned by API: `recommendationSetId`, `traceId`, `recommendationType`, source mix, degradation flags

## 11. States / Lifecycle

### Module lifecycle

Each storefront recommendation module should follow an explicit lifecycle:

`disabled -> requested -> loading -> ready -> degraded | empty | error -> retrying -> hidden_after_policy`

State meanings:

- **`disabled`** - placement not enabled for this market, experiment, or route
- **`requested`** - request context is assembled but fetch has not started
- **`loading`** - request in flight, placeholder or skeleton allowed
- **`ready`** - valid recommendation set available for rendering
- **`degraded`** - recommendation set returned with fallback reason or partial-strength recommendation
- **`empty`** - no eligible module should be shown
- **`error`** - request failed or timed out without a safe degraded response
- **`retrying`** - bounded automatic or user-triggered retry path
- **`hidden_after_policy`** - placement intentionally suppressed after evaluating module state

### Commerce interaction lifecycle

For recommended products that support shopping actions:

`rendered -> interacted -> add_to_cart_attempted -> add_to_cart_succeeded | add_to_cart_failed`

The surface must preserve recommendation lineage across these transitions.

## 12. Business Rules

- The storefront must render recommendation types distinctly; it must not infer type only from placement position.
- `outfit` modules must preserve grouped complete-look semantics from `complete-look-orchestration.md`.
- Cart modules must suppress or clearly avoid exact duplicates already in cart unless substitution is explicitly intended.
- Surfaces must honor API degradation flags and not present degraded outputs as full-strength recommendations.
- Browser-side logic may refine rendering and state behavior, but it must not replace platform decision logic with its own ranking rules.
- If identity confidence or consent is weak, the surface must not imply deeply personalized behavior.
- If inventory or variant availability changes between render and add-to-cart, commerce truth wins; the surface must reconcile gracefully.
- A placement may be suppressed after policy evaluation even when a response exists, for example because the set is empty, too degraded, or blocked by freshness rules.
- Impression events must map to actual visibility or the approved fallback policy, not mere response receipt.
- Module ordering is configurable, but recommendation meaning cannot depend on hidden local heuristics.

## 13. Configuration Model

The ecommerce surface layer needs a controlled configuration model rather than hardcoded placement behavior.

| Configuration area | What it controls |
| --- | --- |
| `placementRegistry` | Which placements exist on PDP, cart, homepage, inspiration, and by market |
| `modulePolicy` | Allowed recommendation types, ordering, maximum set count, and hide/show behavior |
| `copyKeys` | Placement-level copy tokens for module heading, empty copy, and degraded messaging |
| `telemetryPolicy` | Visibility threshold, fallback policy flag, event batching, and sampling settings |
| `freshnessPolicy` | Cache TTL, refetch-on-focus, and inventory staleness handling by surface |
| `experimentPolicy` | Which placements participate in which experiments and where variant IDs are consumed |
| `performancePolicy` | Timeout thresholds, skeleton behavior, and whether stale-but-safe UI can be shown |
| `accessibilityPolicy` | Heading level, focus order, keyboard affordances, and screen-reader labeling |

Configuration should be versioned and environment-aware so support and analytics can reconstruct which storefront policy was active when a set was shown.

## 14. Data Model

### Core surface entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `SurfaceRequestContext` | Normalized recommendation request from a storefront surface | `channel`, `surface`, `placement`, `market`, `mode`, one of `anchorProductId`, `cart`, or `placementIntent`, plus `sessionId` or `customerRef` |
| `PlacementDefinition` | Storefront placement configuration | `placementId`, `surface`, enabled recommendation types, hide/show policy, copy keys, experiment hooks |
| `RecommendationModuleViewModel` | UI-ready module state | `placementId`, `recommendationSetId`, `traceId`, `recommendationType`, `title`, `items` or grouped members, `state`, `degradation`, `sourceMix` |
| `ModuleTelemetryEnvelope` | Event payload seed used by interaction tracking | `surface`, `placement`, `recommendationSetId`, `traceId`, `recommendationType`, `itemIds`, `experimentContext`, `eventSource` |
| `CommerceActionContext` | Add-to-cart lineage data | `productId`, `variantId`, `recommendationSetId`, `traceId`, `placementId`, `recommendationType` |

### Example module view model

```json
{
  "placementId": "pdp_complete_the_look_primary",
  "surface": "pdp",
  "recommendationSetId": "recset_01JPDS0R7T7G4Y8JFA5N9R2Q1E",
  "traceId": "trace_01JPDS0QNZP0M8JK2V3D4F5G6H",
  "recommendationType": "outfit",
  "title": "Complete the look",
  "state": "ready",
  "sourceMix": "curated_plus_ai_ranked",
  "degradation": null,
  "items": [
    {
      "groupRole": "anchor",
      "productId": "prod_suit_001"
    },
    {
      "groupRole": "shirt",
      "productId": "prod_shirt_210"
    },
    {
      "groupRole": "shoes",
      "productId": "prod_shoe_450"
    }
  ]
}
```

## 15. Read Model / Projection Needs

The storefront does not need to own deep recommendation projections, but it benefits from surface-specific read models:

- placement registry keyed by page type, market, and mode
- optional edge or CDN cache policy for anonymous PDP recommendations
- hydration-safe module state for SSR / ISR / CSR storefront patterns
- cart summary projection usable for duplicate suppression and refetch decisions
- experiment assignment snapshot available before first render
- inventory freshness hints and degrade flags exposed by the delivery layer

The surface layer should consume these projections rather than compute recommendation eligibility itself.

## 16. APIs / Contracts

Ecommerce surfaces should integrate through the shared delivery contract or a storefront BFF that preserves the same semantics.

### Minimum request expectations

Every request must carry enough context to distinguish:

- `channel=web`
- surface such as `pdp`, `cart`, `homepage`, or `inspiration`
- placement ID
- market and mode
- anchor product, cart context, or placement intent
- anonymous vs known customer state
- experiment context where the storefront owns assignment

### Example interactions

| Interaction | Purpose | Required request concepts | Required response concepts |
| --- | --- | --- | --- |
| `POST /recommendations` | Interactive PDP or cart fetch | surface metadata, market, mode, anchor product or cart, session/customer state | `traceId`, one or more recommendation sets, recommendation types, degradation fields |
| `POST /recommendations/refresh` | Optional cart or PDP refresh after mutation | prior request context plus changed cart or product state | fresh set IDs or explicit no-change / degraded result |
| `GET /placements/{placementId}/config` | Optional storefront placement bootstrap | placement ID, locale, market, experiment inputs | enabled types, copy keys, hide/show policy, telemetry config |

### Telemetry fallback contract

When browser analytics are blocked, ecommerce consumers must support a server-side impression fallback path that records at minimum:

- `surface`
- `placement`
- `recommendationSetId`
- `traceId`
- `recommendationType`
- visibility basis or fallback basis
- request timestamp
- `eventSource=server_fallback`

This fallback must remain schema-compatible with `analytics-and-experimentation.md`.

## 17. Events / Async Flows

### Flow A: PDP module render

1. PDP resolves request context.
2. API returns one or more recommendation sets.
3. Surface maps those sets into module view models.
4. Module becomes visible.
5. Browser emits `impression`, or server fallback does if browser delivery fails.

### Flow B: Cart mutation refetch

1. Shopper changes cart.
2. Surface invalidates current cart recommendation modules.
3. BFF or client refetches cart-aware recommendation sets.
4. New modules replace stale ones, with new `recommendationSetId` values where applicable.
5. Old module state is not reused for new analytics events.

### Flow C: Add-to-cart from recommendation module

1. Shopper clicks add-to-cart on a recommended item.
2. Surface sends product and variant data to commerce APIs while preserving recommendation lineage.
3. Success or failure is recorded with the originating set and placement.
4. Cart may refresh, which can trigger a downstream recommendation refetch.

### Flow D: Degraded telemetry fallback

1. Browser cannot emit telemetry because of network, script, or blocker constraints.
2. Storefront or BFF emits the approved server-side fallback event.
3. Analytics pipeline stores the same identifiers but marks `eventSource=server_fallback`.
4. Reporting can distinguish fallback usage rather than blending it invisibly.

## 18. UI / UX Design

Ecommerce UX must preserve recommendation meaning and honesty.

### UX principles

- show grouped outfits as grouped answers
- keep module titles aligned with recommendation type
- keep the anchor item visually apparent in outfit experiences
- do not overfill pages with multiple competing recommendation modules
- preserve strong loading, empty, degraded, and error states
- keep mobile and desktop parity on recommendation meaning, not necessarily exact layout
- avoid dark patterns that make recommendations look editorially certain when the platform returned a degraded result

### Recommended interaction patterns

- skeleton loaders for predicted placements
- module-level headings and accessible descriptions
- grouped product cards for `outfit`
- flat but labeled carousels or grids for `cross-sell` and `upsell`
- clear action buttons for view details, save, or add-to-cart where allowed
- bounded retry behavior for transient failures

Customer-facing copy conventions for distinguishing recommendation types remain subject to `DEC-005`.

## 19. Main Screens / Components

| Surface | Core component expectations |
| --- | --- |
| PDP | `CompleteLookModule`, `CrossSellModule`, `UpsellModule`, module heading, grouped product cards, recommendation-aware add-to-cart buttons |
| Cart | `CartRecommendationModule`, duplicate-aware item cards, compact grouped outfit extension view |
| Homepage | placement shell, context-aware carousel or grid, personalization-safe fallbacks |
| Inspiration / occasion pages | grouped look cards or modular recommendation sections with explicit occasion framing |
| Shared infrastructure | `RecommendationSkeleton`, `RecommendationEmptyState`, `RecommendationErrorState`, `RecommendationDegradedState`, telemetry helpers, request hooks |

## 20. Permissions / Security Rules

- Surfaces may use anonymous session context without implying known-customer personalization.
- Known-customer tokens and identity references must follow storefront authentication and consent rules.
- Customer-facing modules must not expose raw trace data, rule lists, or sensitive profile reasoning.
- Telemetry must preserve stable IDs but avoid leaking unnecessary internal metadata into the browser.
- Any experiment or recommendation metadata exposed client-side must be safe for a customer-facing environment.
- Server-side fallback telemetry and BFF logging must obey privacy and regional data-use constraints.

## 21. Notifications / Alerts / Side Effects

Customer-visible side effects:

- optional toast or inline error for add-to-cart failure from a recommendation module
- empty or degraded-state messaging when a placement is intentionally suppressed or narrowed

Internal side effects:

- telemetry events for impression, click, save, add-to-cart, dismiss, purchase continuity
- alerting when empty rates, error rates, or degraded rates spike on critical placements
- optional experiment annotations for placement-level regressions

This feature does not own outbound notifications such as email or SMS.

## 22. Integrations / Dependencies

- **Shared contracts and delivery API** - source of typed recommendation sets and trace metadata
- **Complete-look orchestration** - authoritative grouped `outfit` semantics for PDP and cart
- **Recommendation decisioning and ranking** - upstream source of recommendation contents and order
- **Catalog and product intelligence** - inventory, imagery, and product validity needed for safe rendering
- **Merchandising governance and operator controls** - campaign, override, and suppression context affecting placements
- **Analytics and experimentation** - event taxonomy, attribution continuity, and experiment IDs
- **Identity and style profile** - known-customer and confidence-aware personalization inputs in later phases
- **Context engine and personalization** - Phase 2+ homepage, inspiration, and contextual ecommerce placements
- **Commerce APIs** - cart actions, variant validation, and price / availability truth

## 23. Edge Cases / Failure Cases

- slow recommendation response on PDP or cart
- browser ad blocker suppresses telemetry
- recommendation response is valid but too degraded for safe display
- product variant changes after recommendations render
- item recommended on PDP is already in cart by the time the shopper clicks
- same product appears in multiple modules on the same surface
- stale inventory or sellability truth causes add-to-cart failure
- hydration mismatch between server render and client state
- experiment assignment arrives late relative to first render
- anonymous user becomes known mid-session and invalidates prior personalization assumptions
- mobile viewport or carousel behavior hides products before impression qualification is clear

Each case should map to explicit handling rather than silent failure or misleading UI.

## 24. Non-Functional Requirements

- interactive response time must fit Phase 1 ecommerce expectations; exact thresholds remain tied to `DEC-002`
- recommendation modules must minimize impact on Core Web Vitals and page responsiveness
- rendering behavior must be accessible by keyboard and screen reader
- module behavior must be observable with structured logs, placement IDs, and trace-aware error correlation
- storefront integration must support gradual rollout by placement, market, and experiment
- module refresh behavior must be bounded so cart changes do not trigger excessive network churn
- SSR, ISR, and CSR implementations must preserve the same semantics even if transport differs

## 25. Analytics / Auditability Requirements

Ecommerce surface experiences are a first-class producer of recommendation telemetry.

Required event families:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override where operator or governance context materially changes behavior upstream

Required linkage fields, where applicable:

- `recommendationSetId`
- `traceId`
- `surface`
- `placement`
- `recommendationType`
- anchor product ID or placement intent
- product ID and position
- experiment and variant IDs
- rule or campaign context if provided by the contract

Important surface-specific rules:

- impression means visible exposure, not successful fetch alone
- fallback-generated telemetry must be explicitly marked
- cart and PDP action events must preserve recommendation lineage into commerce outcomes
- module IDs and placement IDs must remain stable enough to support experiment and anomaly analysis

## 26. Testing Requirements

- component tests for each module state and recommendation type
- contract tests for mapping API responses into module view models
- E2E PDP and cart tests covering fetch, impression, click, and add-to-cart flows
- duplicate-suppression tests for cart modules
- degraded-state and error-path tests for placement hide/show logic
- telemetry tests confirming propagation of `recommendationSetId`, `traceId`, placement, and recommendation type
- accessibility tests for keyboard navigation, headings, focus order, and screen-reader labels
- responsive tests for mobile and desktop grouped module rendering
- experiment tests for variant-aware placement behavior
- performance tests for timeout, retry, and skeleton behavior on slow networks

## 27. Recommended Architecture

Recommended storefront architecture:

1. **Placement registry** - determines where recommendation modules can appear
2. **Storefront recommendation hook / service** - normalizes surface context and calls the shared contract
3. **View-model mapper** - turns contract payloads into typed module state
4. **Shared recommendation component library** - renders `outfit`, `cross-sell`, `upsell`, and future types consistently
5. **Telemetry helper layer** - centralizes impression, click, and commerce-action tracking
6. **Optional storefront BFF** - handles auth, cache policy, and server fallback telemetry without changing recommendation meaning

This architecture should keep storefront logic thin while still giving frontend teams a clear reusable integration pattern.

## 28. Recommended Technical Design

- use a single typed `useRecommendations(requestContext)` hook or equivalent service per storefront stack
- model recommendation modules as discriminated unions by `recommendationType`
- keep grouped `outfit` members explicit rather than inferring grouping from flat item order
- centralize placement IDs and surface constants in one configuration source
- include recommendation lineage in add-to-cart helpers so commerce events can be attributed later
- use an IntersectionObserver or equivalent visibility model for browser impressions
- allow a storefront BFF to add auth, cache, and fallback behavior without changing set semantics
- keep client-side retries bounded and idempotent
- treat server-side telemetry fallback as a first-class path, not an afterthought

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW PDP and cart modules for `outfit`, `cross-sell`, and `upsell`; stable placement IDs; basic degraded states; telemetry continuity
- **Phase 2:** homepage, inspiration, and occasion-led ecommerce placements using the same contract; stronger context and profile integration where permitted
- **Phase 3:** deeper optimization of placement orchestration, experiment maturity, and shared storefront component reuse across more ecommerce entry points

Phase 1 should optimize for trustworthy shopping behavior and telemetry before expanding placement breadth.

## 30. Summary

Ecommerce surface experiences are where the recommendation platform becomes visible, useful, and measurable. The feature must keep decision logic server-side while making recommendation types explicit in the UI, especially for grouped `outfit` experiences on PDP and cart.

The implementation bar is:

- typed module rendering rather than generic carousels
- honest loading, empty, degraded, and error behavior
- recommendation lineage preserved through commerce actions
- telemetry continuity with browser and server-fallback paths
- placement configuration that scales beyond one-off PDP widgets

The remaining uncertainty is already visible in portfolio decisions around latency targets, surface-expansion timing, copy conventions, telemetry fallback policy, and inventory freshness windows. Those are downstream shaping choices, not reasons to keep the ecommerce feature spec shallow.
