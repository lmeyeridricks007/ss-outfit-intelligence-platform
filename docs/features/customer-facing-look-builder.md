# Feature Deep-Dive: Customer-Facing Look Builder (F25)

**Feature ID:** F25  
**BR(s):** BR-1 (Outfit and complete-look recommendations), BR-7 (Delivery API and channel activation)  
**Capability:** Let customers explore curated looks (look builder)  
**Source:** `docs/project/feature-list.md`, `docs/project/capability-map.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Let **customers** browse and explore **curated looks** as a **dedicated surface** (look builder), with recommendations delivered via the **same Delivery API** (F11) as PDP and cart; **placement and metrics** tracked (BR-1, BR-7). Look builder is an **inspiration** and **discovery** channel: full-page or section where users see looks (outfit-level) and can click through to products or add to cart.

## 2. Core Concept

- **Look builder** = customer-facing page or section (e.g. “Looks” or “Outfit ideas”) that (1) calls **F11** with placement=look_builder (or homepage_look_builder), channel=webstore, session_id/customer_id, **no anchor** (or optional “occasion” filter); (2) displays returned **looks** (and optionally items) in a grid or feed; (3) sends **outcome events** (impression, click, add-to-cart) to **F12** with set_id and trace_id. Same API contract as PDP/cart; only **placement** and **presentation** differ (e.g. look cards with multiple products, or hero image per look).
- **Content:** Curated looks from **F6** (published); engine (F9) may return looks for this placement using “curated” or “looks for you” strategy. **Personalization:** If customer_id present, F11 may return personalized look set (from F9); else trending or default set.

## 3. Why This Feature Exists

- **BR-1:** Look builder is a designated **inspiration surface** (product overview, BRs). **BR-7:** Same API; channel activation includes look builder. **Capability map:** “Let customers explore curated looks (look builder).”
- **Product goals:** Serve complete-look recommendations across homepage, PDP, cart, **and look builder**; differentiate with outfit-level discovery.

## 4. User / Business Problems Solved

- **Style-seeking customers:** Discover full looks in one place; reduce “what goes with this?” friction. **Merchandising:** Showcase curated looks; drive traffic to key outfits. **Business:** Engagement and conversion from inspiration surface.

## 5. Scope

### 6. In Scope

- **Page/section:** Dedicated URL (e.g. /looks or /outfit-ideas) or prominent section on homepage. **Request:** Call F11 with placement=look_builder (or equivalent), channel=webstore, session_id, customer_id (if logged in), optional **occasion** or **filter** (e.g. formal, casual) as context. **Response:** F11 returns items (look_ids and/or product_ids); typically **looks** (each look = multiple products). **Rendering:** **Look cards** (one card per look: image, name, product count; click → look detail or expand to show products); or **product grid** from look contents. **Add to cart:** From look detail or card: add one product or “add full look” (add all products in look). **Outcome events:** recommendation_impression (when look builder section in view), recommendation_click (look or product clicked), recommendation_add_to_cart; all with set_id, trace_id (F12). **Attribution:** F17 reports by placement=look_builder.
- **Filters (optional):** Occasion, season, style; pass as context to F11 or as second request with filter. **Pagination or infinite scroll:** F11 called with limit and offset (or cursor) for “load more.”
- **No new backend** for look builder: only **new placement** and **new frontend** consuming F11 and F12. **Look detail:** Optional sub-page (e.g. /looks/{look_id}) showing products in look; can call F11 with anchor look_id if API supports, or fetch look by id from F6 (read-only API for frontend) for display only; add-to-cart still sends events with set_id/trace_id from original recommendation response (or new request for “recommendations for this look” with new set_id/trace_id).

### 7. Out of Scope

- **Delivery API or engine** — F11, F9. **Curated look authoring** — F6, F18. **Visual builder** (upload photo → recommend) — Out of scope (BRs). **Conversational AI** — Out of scope. **Full ecommerce** (checkout, account) — Owned by commerce platform; look builder only recommendations and events.

## 8. Main User Personas

- **Style-Seeking Customer, Returning Customer** — Primary users; discover and shop looks. **Merchandising** — Indirect; curates looks shown here.

## 9. Main User Journeys

- **Browse:** User visits /looks → Frontend calls F11 (placement=look_builder) → Displays 20 look cards → Sends impression with set_id, trace_id → User clicks look → Look detail (products in look) or expand inline → User adds one product to cart → Frontend sends recommendation_add_to_cart with product_id, set_id, trace_id.
- **Filter:** User selects “Formal” → Frontend calls F11 with occasion=formal (or refetch) → Displays filtered looks → Same events.

## 10. Triggering Events / Inputs

- **Page load or scroll:** Trigger F11 call (placement=look_builder, limit=20). **User action:** Click look/product; add to cart. **Inputs:** session_id, customer_id (optional), occasion/filter (optional), limit, offset. **Outcome:** Impression, click, add_to_cart (and purchase if order completes) with set_id, trace_id.

## 11. States / Lifecycle

- **Page:** Loading → Loaded (looks) / Empty / Error. **No state machine**; stateless per load. **Events:** Same as webstore widgets (F13–F15); one impression per “view” of recommendation set.

## 12. Business Rules

- **Same attribution rules** as PDP/cart: every event must have set_id and trace_id from F11. **Look content:** From F6 (published looks); F9 returns look_ids (and optionally product_ids per look) for this placement. **Personalization:** If customer_id present, F11 may return “looks for you”; else default/trending. **No PII** in events; only product_id, look_id, set_id, trace_id.

## 13. Configuration Model

- **Placement id:** look_builder (or homepage_look_builder); must match F11 and F20 config. **Limit per request:** e.g. 20. **Layout:** Grid vs list; cards per look (from CMS or frontend config). **Feature flag:** Enable/disable look builder page (e.g. for A/B in F24).

## 14. Data Model

- **Client state:** placement, set_id, trace_id, looks (array of look_id + product_ids + metadata from F11), loading, error. **No new server-side model**; F11 response and F12 events. **Look detail:** If /looks/{look_id}, can GET look from F6 (read-only) for display; events for “add from look” should still carry recommendation set (e.g. from F11 “recommendations for look X” with new set_id/trace_id).

## 15. Read Model / Projection Needs

- **Frontend reads:** F11 (recommendations for placement=look_builder). **Optional:** F6 GET /looks/{look_id} for look detail page (products in look) if not in F11 response. **F12:** Receives events. **F17:** Reports by placement=look_builder.

## 16. APIs / Contracts

- **F11:** POST /recommendations { placement: "look_builder", channel: "webstore", session_id: "...", customer_id: "...", limit: 20, occasion: "formal" (optional) } → set_id, trace_id, items (look_ids and/or product_ids; if look, items may have type=look, id=look_id, and optional product_ids array). **F12:** POST /events/outcomes (impression, click, add_to_cart) with set_id, trace_id, placement=look_builder, product_id or look_id. **F6 (optional):** GET /looks/{look_id} for detail page (read-only; public or with scope).

## 17. Events / Async Flows

- **Emitted to F12:** recommendation_impression, recommendation_click, recommendation_add_to_cart (and purchase if from this surface). **No consumed events** for page logic.

## 18. UI / UX Design

- **Look builder page:** Hero or grid of **look cards** (image, title, “X pieces”); click → look detail or expand. **Look detail:** Products in look with images, names, prices; “Add to cart” per product or “Add all.” **Responsive:** Desktop and mobile. **Accessibility:** Keyboard, screen reader; same as F13–F15. **Performance:** Lazy-load below fold; do not block LCP.

## 19. Main Screens / Components

- **Screens:** Look builder (grid/feed); Look detail (optional). **Components:** LookCard, LookGrid, LookDetail, ProductListInLook, AddToCartButton. Reuse ProductCard from F13 if applicable.

## 20. Permissions / Security Rules

- **F11 call:** Same as webstore (BFF or server); no API key on client. **F12 events:** From BFF or server with set_id, trace_id. **F6 read (if used):** Public read for published look detail; no write. **No PII** in logs.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** F11 failure (show fallback or “No looks right now”). **Side effects:** F12 and F17; attribution to placement=look_builder.

## 22. Integrations / Dependencies

- **Upstream:** Delivery API (F11); optional F6 for look detail. **Downstream:** Recommendation telemetry (F12); Core analytics (F17). **Shared:** BR-1, BR-7; F12 schema; same as webstore widgets pattern.

## 23. Edge Cases / Failure Cases

- **F11 empty:** Show “No looks right now” or static CTA; do not send impression without set_id (F11 returns set_id even for empty). **F11 error:** Fallback message; retry optional. **Look retired:** If F6 returns 404 for look detail, show “Look no longer available.” **Pagination:** F11 with offset/cursor for “load more”; new request = new set_id/trace_id for next page (or same set with position range; define policy).

## 24. Non-Functional Requirements

- **Load:** Same as F13 (lazy-load, &lt; 2 s for above-fold). **API:** F11 SLA. **Cross-browser:** Desktop and mobile.

## 25. Analytics / Auditability Requirements

- **Events:** All to F12 with set_id, trace_id for CTR and conversion by placement=look_builder. **Metrics:** F17 report for look builder (impressions, clicks, add-to-cart, revenue).

## 26. Testing Requirements

- **Unit:** LookCard render; event payload. **Integration:** Mock F11 (returns look_ids); render grid; send impression and click; verify F12. **E2E:** Real F11; load look builder; click look; add to cart; verify events in F17.

## 27. Recommended Architecture

- **Component:** Part of webstore (same app as F13–F15). **Pattern:** Same as widgets: BFF calls F11, passes to frontend; frontend sends events to BFF → F12. **New:** Placement=look_builder; look-focused UI (cards, detail).

## 28. Recommended Technical Design

- **Route:** /looks or /outfit-ideas. **BFF:** GET /api/look-builder/recommendations (calls F11 placement=look_builder); POST /api/events/outcomes (forwards to F12). **Frontend:** Fetch recommendations; render LookGrid; on view/click/add-to-cart send events with set_id, trace_id. **Look detail:** Optional GET /api/looks/{look_id} (calls F6) for product list; add-to-cart from detail still sends recommendation event (use original set_id/trace_id or new F11 call for “complete the look” from this look with new set_id/trace_id).

## 29. Suggested Implementation Phasing

- **Phase 1 (Phase 5):** Look builder page; F11 placement=look_builder; look cards (from F11 items type=look); impression and click events; no look detail page. **Phase 2:** Look detail (/looks/{id}); add-to-cart from look; filters (occasion); F17 report. **Later:** Infinite scroll; personalization tuning; A/B on layout (F24).

## 30. Summary

**Customer-facing look builder** (F25) lets **customers browse and explore curated looks** on a **dedicated surface** using the **same Delivery API** (F11) with **placement=look_builder**. **Outcome events** (impression, click, add-to-cart) go to **F12** with **set_id** and **trace_id** for attribution. **Look content** comes from **F6** (published looks) via F9/F11. No new backend; only new placement and frontend. BR-1 and BR-7 satisfied; differentiator for outfit-level discovery.
