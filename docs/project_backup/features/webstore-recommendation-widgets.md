# Feature Deep-Dive: Webstore Recommendation Widgets (F13, F14, F15)

**Feature IDs:** F13 (PDP), F14 (Cart), F15 (Homepage/Landing)  
**BR(s):** BR-1 (Outfit and complete-look recommendations), BR-7 (Delivery API and channel activation)  
**Capabilities:** Recommend outfit on PDP; Recommend complete the look on cart; Recommend looks on homepage and landing  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/business-requirements.md`

---

## 1. Purpose

Surface recommendations on the **webstore** in three placements: **PDP** (complete the look, styled with, you may also like), **Cart** (complete your outfit), and **Homepage/Landing** (looks for you, trending outfits). Widgets call the **Delivery API** (F11) and send **outcome events** (impression, click, add-to-cart) with **set_id** and **trace_id** to **recommendation telemetry** (F12). Same API and event contract for all three; only placement and copy differ.

## 2. Core Concept

- **Widget:** A UI component (carousel, grid, or card) that (1) calls F11 with placement, channel=webstore, session_id (and optional customer_id), anchor_product_id (PDP/cart) or none (homepage), limit; (2) renders the returned items (product cards or look cards); (3) on impression sends recommendation_impression with set_id, trace_id; on click sends recommendation_click; on add-to-cart sends recommendation_add_to_cart (and optionally purchase later via order confirmation). All events include set_id and trace_id from the F11 response.
- **Placements:** F13 = PDP (placement e.g. pdp_complete_the_look, pdp_styled_with, pdp_you_may_also_like); F14 = Cart (cart_complete_your_outfit); F15 = Homepage/Landing (homepage_looks_for_you, landing_trending_outfits). Placement drives which strategy and copy the backend uses; frontend only passes placement and context.

## 3. Why This Feature Exists

- **BR-1:** Platform must deliver complete-look and complete-the-look on PDP, cart, and inspiration surfaces.
- **BR-7:** Web (PDP/cart/homepage) must consume the API in production; widgets are the consumer.
- **BR-10:** Attribution requires widgets to send outcome events with set_id and trace_id.

## 4. User / Business Problems Solved

- **Style-seeking and returning customers:** See coherent looks and next-best items where they shop (PDP, cart, homepage).
- **Business:** Conversion and basket size (BR success metrics) depend on these surfaces.
- **Product/Engineering:** Single API; frontend only implements presentation and event sending.

## 5. Scope

### 6. In Scope

- **PDP (F13):** One or more widget slots (complete the look, styled with, you may also like). Each slot = one API call with placement and anchor_product_id = current product. Render items (product or look); lazy-load or above-the-fold. Events: impression when in view, click, add-to-cart.
- **Cart (F14):** One widget “complete your outfit” with placement and anchor = cart (cart_product_ids). Same API, render, events.
- **Homepage/Landing (F15):** “Looks for you,” “trending outfits” with placement and no anchor (or session/customer for personal). Same API, render, events.
- **Frontend:** Call F11 (server-side or client-side with BFF for auth); render carousel/grid; send events to F12 (prefer server-side or BFF to avoid CORS and to attach auth). **Fallback UI:** When API returns empty or error, show “No recommendations” or static CTA; still send impression if widget was shown (with set_id/trace_id if available, or document “no set_id when empty” policy).
- **Responsive:** Widget works on desktop and mobile (future mobile app may reuse same API; this spec is webstore).

### 7. Out of Scope

- **Delivery API implementation** — F11. Widgets only consume.
- **Email or clienteling** — F16, F23. This spec is webstore only.
- **Look builder (customer-facing)** — F25; separate placement/surface.
- **Admin placement config** — F20; widgets use placement IDs that F20 configures.

## 8. Main User Personas

- **Style-Seeking Customer, Returning Customer** — Primary users of widgets.
- **Frontend engineers** — Implement widgets and event sending.
- **Product/Merchandising** — Benefit from CTR and conversion per placement.

## 9. Main User Journeys

- **PDP:** User views product → PDP loads → widget calls F11 (placement=pdp_complete_the_look, anchor_product_id=current) → renders 10 items → sends impression with set_id/trace_id → user clicks item → navigates to product or adds to cart → widget sends click (and add-to-cart if applicable).
- **Cart:** User has items in cart → cart page loads → widget calls F11 (placement=cart_complete_your_outfit, cart_product_ids=[...]) → renders items → impression, click, add-to-cart events.
- **Homepage:** User lands on homepage → widget calls F11 (placement=homepage_looks_for_you, no anchor) → renders personalized or trending looks → same events.

## 10. Triggering Events / Inputs

- **Page load / slot in view:** Trigger API call when PDP, cart, or homepage loads (or when widget enters viewport for lazy-load). Inputs: placement, session_id (from cookie or app), customer_id (if logged in), anchor_product_id or cart_product_ids, limit.
- **User action:** Click or add-to-cart triggers outcome event (click, add_to_cart) with set_id, trace_id, product_id/look_id, position.

## 11. States / Lifecycle

- **Widget:** Loading → Loaded (with items or empty) / Error (show fallback). No state machine; stateless per load.
- **Event:** Fired when impression (in view), click, add-to-cart. No retry required for event (at-least-once best effort).

## 12. Business Rules

- **Always send set_id and trace_id** on outcome events when API returned them. If API failed and no set_id/trace_id, either do not send event or send with null (document; F12 may reject null). Prefer: only send events when widget had a valid F11 response so every event has IDs.
- **Impression:** Fire once per widget view (e.g. when 50% visible or on load). Do not double-count; use a sentinel (e.g. impression_sent flag per set_id).
- **Click:** Include clicked product_id or look_id and position for attribution.
- **Add-to-cart:** Send when user adds a recommended item to cart from widget (track source=recommendation).

## 13. Configuration Model

- **Per placement:** Widget slot ID, placement string (must match F11/F20), title/copy (e.g. “Complete the look”), limit, lazy-load yes/no. From CMS or config; not from F11.
- **API endpoint and auth:** F11 base URL, API key or auth token (server-side). Feature flags: disable widget per placement for A/B (F24).

## 14. Data Model

- **Client state (transient):** placement, set_id, trace_id, items (from F11), loading, error. No persistent storage in widget; session only.
- **Event payload:** event_name, event_timestamp, recommendation_set_id, trace_id, placement, channel=webstore, product_id or look_id, position. Per F12 schema.

## 15. Read Model / Projection Needs

- **Widget reads:** F11 response (items, set_id, trace_id). No direct read of F5/F6/F9; all via F11.
- **F12:** Consumes outcome events. F17 uses for reporting.

## 16. APIs / Contracts

- **Outbound to F11:** GET or POST per F11 contract. Example: `POST /recommendations` with body { placement: "pdp_complete_the_look", channel: "webstore", session_id: "...", anchor_product_id: "prod-1", limit: 10 }. Response: { recommendation_set_id, trace_id, items: [...] }.
- **Outbound to F12:** POST /events/outcomes with outcome event body (impression, click, add_to_cart). Include set_id, trace_id from F11 response.
- **Inbound:** None (widget is client of F11 and F12).

## 17. Events / Async Flows

- **Emitted to F12:** recommendation_impression, recommendation_click, recommendation_add_to_cart (and recommendation_purchase if order confirmation sends it). All include set_id, trace_id.
- **No consumed events** for widget logic; only API call and user interaction.

## 18. UI / UX Design

- **PDP:** Carousel or grid below fold or beside product; “Complete the look,” “Styled with,” “You may also like” sections. Product cards with image, name, price; look cards with multiple products or single hero image. Click → product page or add to cart.
- **Cart:** One row or carousel “Complete your outfit” with complementary items. Same card style; add to cart CTA.
- **Homepage:** “Looks for you” or “Trending outfits” hero or grid; personalized if customer_id present. Same card style; click → look detail or product.
- **Accessibility:** Keyboard, focus, screen reader; lazy-load with placeholder. **Performance:** Lazy-load below fold; do not block LCP.

## 19. Main Screens / Components

- **Components:** RecommendationCarousel, RecommendationGrid, ProductCard, LookCard, AddToCartButton. **Screens:** PDP (widget slots), Cart (widget slot), Homepage (widget slot). Each placement can be one component with placement prop.

## 20. Permissions / Security Rules

- **F11 call:** Server-side or BFF with API key; do not expose API key to client. Session_id from httpOnly cookie; customer_id from server session.
- **F12 events:** Send from server or BFF to avoid CORS and to attach auth; or client with limited token. No PII in event (customer_id optional and hashed if needed per F22).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Widget error rate (API failure); missing set_id/trace_id in events (client bug). **Side effects:** F12 receives events; F17 reports CTR and conversion. No other side effects.

## 22. Integrations / Dependencies

- **Upstream:** Delivery API (F11) for recommendations; session/customer from webstore auth.
- **Downstream:** Recommendation telemetry (F12) for events; Core analytics (F17) consumes F12.
- **Shared:** BR-1, BR-7, BR-10; api-standards; F12 event schema.

## 23. Edge Cases / Failure Cases

- **F11 timeout or 5xx:** Show fallback (“No recommendations” or static CTA); do not send impression with null set_id (or document). Retry once optional.
- **Empty response:** F11 returns 200 with empty items; show “No recommendations” or hide widget; do not send impression if no set_id (F11 still returns set_id/trace_id for empty).
- **User not logged in:** Send session_id only; F11 returns non-personal or contextual; widget works.
- **Ad blockers:** Event endpoint may be blocked; best-effort; server-side events preferred where possible.

## 24. Non-Functional Requirements

- **Load time:** Widget must not block page render; lazy-load or async. **API latency:** F11 SLA; widget shows loading state until response or timeout (e.g. 2s).
- **Availability:** When F11 is down, widget shows fallback; page remains usable.
- **Cross-browser:** Desktop and mobile browsers; responsive.

## 25. Analytics / Auditability Requirements

- **Events:** All outcome events to F12 with set_id/trace_id for attribution (BR-10). **No PII** in client logs; optional server log with session_id for debugging only.
- **Metrics:** Impression count, click count, add-to-cart count per placement (from F17).

## 26. Testing Requirements

- **Unit:** Component render with mock F11 response; event payload shape (set_id, trace_id). **Integration:** Mock F11 and F12; load PDP → verify API call and impression sent; click → verify click event. **E2E:** Real F11 (staging); verify items render and events in F12.

## 27. Recommended Architecture

- **Component:** Part of “Channels & consumers” layer. Webstore frontend (React, Next, or other) with server-side or BFF for F11 and F12 to avoid exposing keys and to ensure events are sent.
- **Pattern:** Page load → fetch recommendations (BFF or server) → pass to widget component → render; on view/click/add-to-cart → BFF or server sends event to F12.

## 28. Recommended Technical Design

- **BFF or server route:** /api/recommendations (calls F11) and /api/events/outcomes (forwards to F12). **Frontend:** React (or similar) component that receives items + set_id + trace_id and renders; calls BFF for events. **Placement config:** From env or CMS (placement string, slot id). **Fallback:** Default copy and hide or “No recommendations” when API fails or empty.

## 29. Suggested Implementation Phasing

- **Phase 1 (F13):** PDP “complete the look” only; one widget; F11 + F12 integration; impression and click events.
- **Phase 2 (F13 full):** PDP “styled with,” “you may also like”; F14 cart widget; F15 homepage widget; add-to-cart and purchase events.
- **Later:** A/B on widget layout (F24); personalization tuning; performance (lazy-load, prefetch).

## 30. Summary

**Webstore recommendation widgets** (F13, F14, F15) surface recommendations on **PDP**, **Cart**, and **Homepage/Landing** by calling the **Delivery API** (F11) and sending **outcome events** (impression, click, add-to-cart) with **set_id** and **trace_id** to **recommendation telemetry** (F12). Same API and event contract for all placements; only placement and copy differ. Frontend must not expose API keys (use BFF/server); events must include set_id/trace_id for BR-10 attribution. Fallback UI when API fails or returns empty; no 500 to user.
