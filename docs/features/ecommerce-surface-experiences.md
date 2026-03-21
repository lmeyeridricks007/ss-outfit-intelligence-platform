# Feature: Ecommerce surface experiences

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003, BR-001, BR-002); `docs/project/br/br-003-multi-surface-delivery.md`, `br-001-complete-look-recommendation-capability.md`, `br-010-analytics-and-experimentation.md`; `docs/project/product-overview.md`; `docs/project/standards.md` (UI assumptions); `docs/project/roadmap.md`.

---

## 1. Purpose

Define how ecommerce surfaces (PDP, cart, later homepage/inspiration) **consume** the shared delivery contract, render **recommendation types** distinctly, handle states, and emit telemetry—without embedding channel-specific decision logic (BR-003).

## 2. Core Concept

Web frontends are **consumers**: they request typed **recommendation sets**, render **outfits** as grouped UI, track **impression**/**click**/cart events with **recommendation set ID** and **trace ID**.

## 3. Why This Feature Exists

Delivers Phase 1 measurable value on high-intent surfaces (`roadmap.md` Phase 1).

## 4. User / Business Problems Solved

- P1 completes **outfits** from PDP.
- Cart attach without incoherent clutter.
- Business metrics via proper instrumentation (BR-010).

## 5. Scope

UX patterns, component boundaries, integration with delivery API, loading/error/empty/degraded states, accessibility. **Missing decisions:** design system components; exact placements beyond PDP/cart; SSR vs CSR data fetching.

## 6. In Scope

- PDP **outfit** module + optional cross-sell/upsell modules.
- Cart completion module; duplicate avoidance display logic.
- Phase 2 placements: homepage/inspiration—contract reuse, stronger context/profile.

## 7. Out of Scope

Native mobile apps unless later; checkout redesign unrelated to recommendations.

## 8. Main User Personas

P1, P2, P3 (Phase 2+), S4 via instrumentation quality.

## 9. Main User Journeys

BR-001 PDP and cart journeys; occasion-led when enabled (`product-overview.md`).

## 10. Triggering Events / Inputs

Route change to PDP, cart line mutations, viewport visibility for impressions, user interactions.

## 11. States / Lifecycle

UI: `loading → ready → empty → degraded → error → retrying`; stale data refresh on cart update.

## 12. Business Rules

- Do not flatten **outfit** into generic carousel without labels (BR-001/BR-002).
- Honor degraded flags from API (suppress module or show messaging—**copy missing decision**).
- Inventory changes between render and ATC handled by commerce stack; UI refetches on focus optional.

## 13. Configuration Model

Feature flags per placement/market; module ordering; experiment bucketing hooks on client.

## 14. Data Model

Client holds `traceId`, per-set `recommendationSetId`, `recommendationType`, item payloads from API.

## 15. Read Model / Projection Needs

Optional edge cached responses for anonymous PDP (policy **missing decision**).

## 16. APIs / Contracts

Frontend calls shared delivery API or BFF; must pass channel/surface/placement constants.

**Telemetry fallback contract:** When browser analytics are blocked, ecommerce consumers must support a server-side impression fallback path that records at minimum `surface`, `placement`, `recommendationSetId`, `traceId`, `recommendationType`, visibility basis, and request timestamp, then marks the event source as `server_fallback`. This fallback must stay schema-compatible with `analytics-and-experimentation.md`.

## 17. Events / Async Flows

Client analytics pipeline batches events; server-side impression logging recommended.

## 18. UI / UX Design

- Visual grouping for **outfits**; distinguish modules.
- Skeleton loaders; accessible keyboard navigation; mobile parity.
- Clear labeling: Complete the look vs You may also like (**copy missing decision**).

## 19. Main Screens / Components

`OutfitModule`, `CrossSellCarousel`, `UpsellCompare`, `RecommendationSkeleton`, `EmptyRecommendationState`, `DegradedBanner`.

## 20. Permissions / Security Rules

Use customer tokens as required; avoid leaking internal trace JSON to browser beyond safe ids.

## 21. Notifications / Alerts / Side Effects

Optional toast on add-to-cart failure; no email from this feature.

## 22. Integrations / Dependencies

Delivery API, commerce cart APIs, analytics SDK, experimentation SDK.

See `analytics-and-experimentation.md` for the canonical impression semantics and fallback event requirements when client-side event delivery is degraded.

## 23. Edge Cases / Failure Cases

Slow API → timeout UI; partial set render; ad-blocked analytics → server backup; variant selection conflicts.

## 24. Non-Functional Requirements

Core Web Vitals impact minimization; lazy load below fold; caching discipline.

## 25. Analytics / Auditability Requirements

Impression when ≥50% visible **or** policy-defined; attach metadata per `data-standards.md`.

## 26. Testing Requirements

Component tests; visual regression; E2E add-to-cart; experiment assignment tests.

## 27. Recommended Architecture

Thin BFF per storefront; shared UI package for recommendation modules across pages.

## 28. Recommended Technical Design

Single hook `useRecommendations(context)` encapsulating fetch, trace ids, refetch rules; event helper `trackRecommendationEvent`.

## 29. Suggested Implementation Phasing

- **Phase 1:** PDP + cart RTW modules; outfit/cross-sell/upsell.
- **Phase 2:** Homepage/inspiration/occasion surfaces with context/profile.

## 30. Summary

Ecommerce experiences monetize the platform (`roadmap.md`). Keep decision logic server-side; focus UX on clarity of **recommendation types** and bulletproof telemetry. Placement and copy details remain **missing decisions** for design.
