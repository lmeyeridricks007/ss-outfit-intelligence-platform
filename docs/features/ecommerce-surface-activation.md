# Feature: Ecommerce Surface Activation

## Traceability / Sources

**Canonical project docs**

- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`
- `docs/project/review-rubrics.md`
- `docs/project/agent-operating-model.md`

**Business requirements (BR)**

- `docs/project/br/br-003-multi-surface-delivery.md` (ecommerce-first rollout, PDP/cart Phase 1)
- `docs/project/br/br-001-complete-look-recommendation-capability.md` (anchor-product journey, Phase 1 surfaces)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (type semantics and surface-by-type behavior)
- `docs/project/br/br-009-merchandising-governance.md` (merchandising visibility into live behavior—surfaces must not bypass controls)
- `docs/project/br/br-010-analytics-and-experimentation.md` (impression → outcome funnel on web)
- `docs/project/br/br-011-explainability-and-auditability.md` (customer-facing explanation boundaries vs internal tooling)

---

## 1. Purpose

Specify how **ecommerce web surfaces** activate recommendation capabilities across roadmap phases: **Phase 1 PDP and cart** as the first production loop (RTW, outfit + cross-sell + upsell), then **Phase 2 homepage and web personalization**, **style inspiration / look-builder** expansion, and later refinements—covering **module behavior, UX patterns, and client-side responsibilities** while consuming the **shared delivery API** (see delivery feature; no duplicate contract definition here).

## 2. Core Concept

**Surface activation** is the end-to-end web behavior: when a module **requests** recommendations, how it **renders** typed sets, how shoppers **interact**, how **telemetry** is emitted with stable IDs, and how the UI **degrades** when data or personalization is thin. Each surface maps to BR-002’s **surface-by-type** expectations (e.g., outfit anchors PDP; cart favors attachment).

## 3. Why This Feature Exists

Ecommerce provides the fastest **measurable** loop for complete-look value (roadmap Phase 1). Without explicit surface specs, engineering may mis-place types, break analytics comparability, or overload PDP with email-style bundles (BR-002 boundaries).

## 4. User / Business Problems Solved

- **Anchor-product shoppers** complete outfits faster on PDP/cart.
- **Returning customers** (Phase 2+) see profile- and context-aware modules without confusing type mixing.
- **Merchandising** sees predictable module slots tied to governance and campaigns.
- **Analytics** gets clean impression/outcome attribution per surface and type (BR-010).

## 5. Scope

**In scope:** Phase 1 PDP and cart modules (structure, states, interactions, telemetry hooks); Phase 2 homepage/personalization expansion patterns; look-builder/inspiration direction; accessibility and performance expectations at UX level; client-side orchestration with delivery API.

**Out of scope:** Core HTTP schema of delivery API (delivery feature); ESP templates; full CM configuration UI (Phase 4 roadmap).

## 6. In Scope

- PDP: anchor context capture, outfit-first layout, companion cross-sell/upsell carousels or stacks, empty/error/fallback UX, mobile and desktop variants at pattern level.
- Cart: completion-oriented complementary suggestions, compatibility with line items, dismiss/save where applicable.
- Phase 2: homepage hero/row modules for occasion-based, personal, style-bundle discovery per BR-002 matrix.
- Phase 3+ alignment: prepare module taxonomy so email/clienteling can mirror **semantic** slots later without renaming types.
- Consent-aware degradation: anonymous vs known customer presentation rules.

## 7. Out of Scope

- Non-web channels (email, clienteling) beyond noting shared telemetry IDs.
- Checkout flow replacement.
- Detailed design system pixel specs (Figma)—patterns and requirements only.

## 8. Main User Personas

- **Anchor-product shopper (Phase 1 focus).**
- **Returning customer (Phase 2+).**
- **Occasion-led browser (Phase 2+ homepage/inspiration).**
- **Merchandiser / marketer** as indirect stakeholder via module labeling and campaign visibility.

## 9. Main User Journeys

1. **Phase 1 PDP:** Land on suit PDP → outfit module loads → shopper expands items → add-to-cart from module → telemetry chain intact.
2. **Phase 1 cart:** View cart → complementary module suggests shirt/shoes → add → purchase attribution to recommendation set.
3. **Phase 2 homepage:** Known customer sees personalized row; anonymous sees occasion or curated bundle entry; both degrade to curated/rule content without breaking layout.
4. **Look-builder (later):** Explore grouped looks; navigate to PDP with preserved context in session for trace continuity (exact param strategy downstream).

## 10. Triggering Events / Inputs

- **Triggers:** PDP `productId` available, cart line change, homepage session start, scroll-into-view for lazy modules (impression timing rules).
- **Inputs to delivery client:** surface enum, channel=`ecommerce`, locale, market, session/customer tokens, anchor/cart payloads per delivery contract.

## 11. States / Lifecycle

- **Module states:** `loading`, `ready`, `empty`, `error`, `degraded` (partial slots filled), `hidden` (consent or feature off).
- **Interaction states:** item `focused`, `expanded`, `added`, `dismissed`.
- **SSR vs CSR:** skeleton-first; avoid layout shift when recommendation heights vary (reserve min height bands).

## 12. Business Rules

- PDP: **outfit** is primary complete-look experience; **cross-sell** and **upsell** remain **separately labeled** in UI and telemetry (BR-002).
- Cart: avoid large inspirational bundles that distract from checkout unless explicitly configured as secondary collapsed section.
- Upsell must remain **compatibility-safe** and visually distinct from cross-sell (price tier cues without deceptive labeling).
- Phase 1: only outfit, cross-sell, upsell **types** in primary modules; later types appear only when roadmap phase and backend flags enable them.

## 13. Configuration Model

- **Per market:** module on/off, slot order, max items, copy variants.
- **Per experiment:** module variant ids wired to delivery experiment headers (BR-010).
- **CMS tie-in (if any):** optional headline overrides that cannot override recommendation type semantics.

## 14. Data Model

- **Client-held state:** last `recommendationSetId` per module, last `traceId`, rendered item ids for impression deduplication, scroll visibility tokens.
- **Mapping from API → UI model:** normalized `UiRecommendationItem` with stable `productId`, `slotIndex`, `recommendationType`, `moduleInstanceId`.

## 15. Read Model / Projection Needs

- Product imagery, title, price, promo flags from commerce storefront read layer (not recomputed from stale API snapshot if storefront expects live price—define single source rule in implementation).

## 16. APIs / Contracts

- Surfaces **consume** the delivery API; this feature defines **required client query parameters** and **module-level expectations** (e.g., PDP must pass anchor product on every refresh).
- **Client-to-analytics contract:** events must include `recommendationSetId`, `traceId`, `surface`, `channel`, `recommendationType`, `moduleInstanceId`, `slotIndex`.

## 17. Events / Async Flows

- **Impression:** fire when ≥50% module visible for N ms (configurable) or on render for above-fold modules—decision to be fixed per standards/data-standards in implementation.
- **Click / add-to-cart / dismiss:** emit with same IDs; join to commerce events.
- **SPA navigation:** re-fetch on anchor change; cancel in-flight requests to avoid mismatched product context.

## 18. UI / UX Design

- Clear **type labeling** (“Complete the look”, “Pairs well with”, “Upgrade options”) aligned with BR-002 intent—not generic “Recommended”.
- **Trust:** avoid dark patterns; show why upsell is premium-compatible at high level only (no internal trace).
- **Accessibility:** keyboard carousels, focus order, live region for dynamic updates, sufficient contrast.
- **Performance:** lazy load below-fold modules; prioritize LCP-friendly loading for above-fold PDP outfit block.

## 19. Main Screens / Components

- **PDP:** `OutfitModule`, `CrossSellRail`, `UpsellCompactList` (names illustrative).
- **Cart:** `CartCompletionModule`, optional `MiniOutfitSummary` if cart context supports outfit completion without clutter.
- **Homepage (Phase 2):** `PersonalizedRow`, `OccasionDiscoveryGrid`, `StyleBundleCarousel`.
- **Inspiration / look-builder (later):** `LookExplorer`, `LookToPDPHandoffBanner`.

## 20. Permissions / Security Rules

- Honor cookie/consent gating for personalization modules; anonymous mode strips personal overlays.
- Do not expose internal trace JSON to shoppers; developer tools only in non-prod.

## 21. Notifications / Alerts / Side Effects

- Optional subtle inline message when recommendations unavailable (“We’ll show suggestions when more sizes return”)—copy and triggers governed with merchandising.

## 22. Integrations / Dependencies

- **Depends on:** delivery API, storefront product services, analytics pipeline, experimentation SDK.
- **Informs:** SEO considerations for server-rendered shells where modules hydrate.

## 23. Edge Cases / Failure Cases

- Product discontinued mid-session: module refreshes to empty with trace; no broken images.
- All items OOS: show empty state with merchandising-approved fallback links (category browse), not silent collapse without explanation.
- Slow API: timeout UI with retry; maintain last good results policy **only** if explicitly allowed to avoid stale anchor mismatch.
- Multiple modules on one PDP: dedupe impressions; attribute clicks to correct module instance.

## 24. Non-Functional Requirements

- **Core Web Vitals:** module patterns must not regress PDP performance budgets; define max parallel recommendation calls per page.
- **i18n:** localized labels and RTL layout support for carousels.
- **Resilience:** client retry with backoff; circuit-breaker to hide module after repeated failures if business approves.

## 25. Analytics / Auditability Requirements

- Align with BR-010: impression, click, add-to-cart, purchase, dismiss where applicable; include experiment and campaign context echo fields when returned by API.
- Dashboard-ready dimensions: `surface`, `recommendationType`, `market`, `customerSegment` (where permitted).

## 26. Testing Requirements

- E2E: PDP module renders with mock API; cart add from module carries attribution IDs in data layer.
- Visual regression for carousel and empty states.
- Accessibility automation on keyboard paths.
- A/B harness tests: variant assignment reflected in UI and events.

## 27. Recommended Architecture

- **Thin UI containers** + **data hooks** that call delivery; centralized telemetry emitter to avoid duplicated event logic.
- **Feature flags** per surface control phase rollout without redeploying unrelated pages.

## 28. Recommended Technical Design

- Shared `RecommendationModuleController` in web app handling fetch, state machine, analytics, and experiment headers.
- TypeScript types generated from delivery OpenAPI for compile-time safety.

## 29. Suggested Implementation Phasing

- **Phase 1:** PDP outfit + cross-sell + upsell; cart completion module; baseline telemetry; RTW-first.
- **Phase 2:** Homepage rows for personal/contextual/occasion types; stronger identity gating UX.
- **Phase 3+:** Deeper inspiration surfaces; prepare shared `moduleInstanceId` taxonomy for cross-channel reporting.

## 30. Summary

Ecommerce surface activation turns shared delivery outputs into **purpose-built shopper experiences** on PDP and cart first, then expands across homepage and inspiration surfaces per roadmap. It enforces **correct recommendation-type presentation**, **robust degradation**, and **telemetry-complete** interactions aligned with BR-001/002/003 and measurement requirements BR-010/011.

## 31. Assumptions

- Storefront can pass stable session identifiers and invoke server or client fetches consistent with commerce security model.
- Analytics stack accepts a data-layer or event-bridge pattern for recommendation attribution.
- Merchandising provides approved copy templates for empty/degraded states.

## 32. Open Questions / Missing Decisions

- Exact **impression threshold** (viewport %, time) for PDP vs homepage modules.
- Whether **price** in recommendation cards is **live** from storefront or **snapshot** from API—must be consistent with commercial truth.
- **SSR strategy** for SEO-critical pages vs client-only modules.
- How many **simultaneous recommendation modules** on PDP are allowed before UX or performance degrades.
- Customer-facing **explanation** depth (if any) versus strictly stylistic copy (BR-011, business-requirements open questions).
