# Feature Deep-Dive: In-Store Clienteling Integration (F23)

**Feature ID:** F23  
**BR(s):** BR-9 (In-store clienteling recommendations)  
**Capability:** Provide in-store clienteling recommendations  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/business-requirements.md`

---

## 1. Purpose

Supply **recommended outfits, cross-sell items, and (where permitted) customer style profile** to **associate-facing surfaces** (app or tablet) for **in-store clienteling**, with **store/region and appointment context** for **RTW and CM** (BR-9). Clienteling consumes the **same Delivery API** (F11) and respects **privacy/consent** (F22) for profile display.

## 2. Core Concept

- **Clienteling** = associate-facing tool (e.g. tablet or app) used by **In-Store Sales Associate / Client Advisor** during customer interaction. Associate selects or identifies **customer** (e.g. by customer_id, phone, or appointment); tool calls **F11** with placement=clienteling, channel=clienteling, customer_id, **store_id/region**, optional **appointment_id** (for CM). F11 returns recommendations (outfits, cross-sell); **optional** call to **F7** (or F11 response) for **style profile summary** (where **F22** consent allows). Tool displays recommendations and (if permitted) profile; associate uses to suggest looks and next items. **Outcome events** (impression, click, add-to-cart, purchase) sent to **F12** with set_id and trace_id for attribution (BR-10).
- **RTW vs CM:** RTW = stock-aware, immediate shoppability; CM = appointment, fabric, complementary items. Same API; **context** (appointment, store inventory) passed in request; F8/F9 adapt.

## 3. Why This Feature Exists

- **BR-9:** Store associates must see recommended outfits, cross-sell, and (where permitted) customer style profile; recommendations must consider store/region and appointment context. Success: clienteling usage and basket/conversion when recommendations used.
- **Architecture:** Same Delivery API; clienteling is a channel with different presentation and context (store, appointment).

## 4. User / Business Problems Solved

- **In-Store Associate:** Fast, relevant suggestions without guessing; profile (if shown) helps personalize. **Customer:** Coherent in-store experience; same “style brain” as online. **Business:** Basket size and follow-up conversion (BR-9 metrics).

## 5. Scope

### 6. In Scope

- **Request:** Clienteling app calls **F11** with placement=clienteling (or clienteling_pdp, clienteling_cart equivalent), channel=clienteling, **customer_id** (required for personalization and profile), **store_id** or **region** (for in-store inventory and context), optional **appointment_id** (CM), optional **anchor_product_id** (if associate is on a product). **Response:** Same as F11 (set_id, trace_id, items). **Profile:** Optional separate call to **F7** for “style profile summary” (preferences, segment, intent) for display in app; **F22** check required—only if consent for use_case=clienteling_profile. If no consent, do not call F7 or show profile block.
- **UI (clienteling app):** Display recommendations (outfit cards, product cards); optional **profile summary** (“Prefers formal, navy/grey”); associate can tap to see product detail or add to basket. **Outcome events:** Send recommendation_impression, recommendation_click, recommendation_add_to_cart (and purchase when sale completes) to **F12** with set_id, trace_id, channel=clienteling. **Attribution:** Same as web; F17 can report by channel=clienteling.
- **Store/region:** Passed to F11; F8 context engine and F9/F10 can filter (e.g. only in-stock at this store). **Appointment (CM):** If appointment_id or context “CM appointment,” F9 may weight complementary items and fabric context (engine behavior); F23 only passes context.
- **Permissions:** Only **associate** role can access clienteling app; **customer_id** from scan, search, or appointment. **No customer-facing** clienteling UI in this spec; associate-facing only.

### 7. Out of Scope

- **Delivery API or engine** — F11, F9. F23 is the **client** (app). **Profile service** — F7; F23 calls for display. **Consent** — F22; F23 checks before showing profile. **POS integration** — Add-to-cart/purchase may sync to POS; F23 sends events to F12; POS integration is separate. **Appointment booking** — CRM or store system; F23 only passes appointment_id to F11.

## 8. Main User Personas

- **In-Store Sales Associate / Client Advisor** — Primary user; uses app to see recommendations and profile (if permitted). **Customer** — Indirect; receives better in-store advice.

## 9. Main User Journeys

- **Associate opens app, selects customer:** By name search or scan → customer_id resolved → App calls F11 (placement=clienteling, customer_id, store_id) and optionally F7 (profile) with consent check → Displays recommendations and profile summary → Associate shows customer; customer adds items → Associate taps “Add to basket” in app or completes in POS → App sends recommendation_click and recommendation_add_to_cart (and purchase when done) to F12.
- **CM appointment:** Associate opens appointment → appointment_id and customer_id → App calls F11 with appointment_id and store_id → Recommendations include complementary items for CM → Same display and events.

## 10. Triggering Events / Inputs

- **User (associate):** Select customer, optional select product (anchor), optional open appointment. **Inputs to F11:** customer_id, placement, channel=clienteling, store_id/region, appointment_id (optional), anchor_product_id (optional). **Inputs to F7:** customer_id, use_case=clienteling_profile (only if F22 allows). **Outcome events:** Impression when recommendations shown; click when item tapped; add-to-cart and purchase when sale completed.

## 11. States / Lifecycle

- **App:** Loaded → Customer selected → Recommendations loaded (or error/empty). **No persistent state** in platform for “clienteling session”; app may cache recommendations briefly. **Profile:** Shown or hidden (per F22).

## 12. Business Rules

- **Consent for profile:** Do not show profile unless F22 check (clienteling_profile use case) returns allowed. **Store/region required:** F11 request should include store_id or region so recommendations are store-relevant (in-stock, local). **Attribution:** Every outcome event must include set_id and trace_id from F11 response. **Associate-only:** Clienteling app is not customer-facing; auth as associate.

## 13. Configuration Model

- **Placement:** clienteling (or clienteling_main); optional clienteling_anchor for “complete the look” from one product. **Limit:** e.g. 10. **Profile:** On/off in app config; still gated by F22. **Store list:** For store_id picker or auto-detect (from device/location).

## 14. Data Model

- **Client-side (app):** customer_id, store_id, recommendations (from F11), profile_summary (from F7 if allowed), set_id, trace_id. **No new server-side persistence** for F23; F11 and F7 are read-only from app. **Events:** Same as F12 schema (channel=clienteling).

## 15. Read Model / Projection Needs

- **App reads:** F11 (recommendations); F7 (profile, if consent); F22 (consent check). **F12:** Receives events. **F17:** Reports by channel=clienteling.

## 16. APIs / Contracts

- **F11:** POST /recommendations { placement: "clienteling", channel: "clienteling", customer_id: "...", store_id: "...", appointment_id: "..." (optional) } → set_id, trace_id, items. **F7:** GET /profile/{customer_id}?use_case=clienteling_profile (only if F22 allows). **F12:** POST /events/outcomes (impression, click, add_to_cart, purchase) with set_id, trace_id, channel=clienteling.
- **Example:** F11 with store_id=store-EU-1, customer_id=cust-1 → returns 10 items (in-stock at store or region); F7 with use_case=clienteling_profile → returns { segment: "formal_focus", preferences: "navy, grey" } (if consent OK).

## 17. Events / Async Flows

- **Emitted to F12:** recommendation_impression, recommendation_click, recommendation_add_to_cart, recommendation_purchase (when sale completes). **No consumed events** for F23 app logic.

## 18. UI / UX Design

- **Associate-facing:** Customer selector (search/scan); Recommendations list (cards: outfit or product with image, name, price); optional Profile summary (short text: “Prefers formal, navy/grey”); Add to basket / Show product. **Offline (optional):** Cache last recommendations for short period if network flaky; sync events when back online. **Accessibility:** Usable on tablet; large tap targets.

## 19. Main Screens / Components

- **Screens:** Customer select; Recommendations view (with optional profile block); Product detail (optional). **Components:** CustomerSearch, RecommendationList, ProfileSummary, RecommendationCard, AddToBasketButton.

## 20. Permissions / Security Rules

- **Auth:** Associate login (store system or platform); only associate role can access clienteling app. **Customer data:** customer_id and profile are sensitive; app must not expose to customer device; associate device only. **F22:** Enforce before showing profile; do not bypass.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** F11 or F7 failure (show “Recommendations unavailable” in app); high error rate from clienteling. **Side effects:** F12 receives events; F17 reports clienteling channel; basket/conversion attributed (BR-9).

## 22. Integrations / Dependencies

- **Upstream:** Delivery API (F11); Customer profile (F7) for profile summary; Privacy/consent (F22) for profile display. **Downstream:** Recommendation telemetry (F12); Core analytics (F17). **Store/POS:** Optional integration for “add to basket” and purchase (F23 sends events; POS may be separate). **Shared:** BR-9; F12 event schema; architecture (same API).

## 23. Edge Cases / Failure Cases

- **No customer_id:** Guest or anonymous; F11 can be called with session_id only; no profile. **F22 denies profile:** Do not call F7 or show profile block; recommendations still shown. **F11 timeout:** Show “Recommendations unavailable”; retry or cache last. **Store not passed:** F11 may return global recommendations; recommend always pass store_id. **Offline:** Optional cache; queue events for F12 when back online.

## 24. Non-Functional Requirements

- **Latency:** F11 response &lt; SLA (e.g. 500 ms) so associate is not waiting. **Availability:** App should work when F11 is up; graceful degradation (no recommendations) when down. **Security:** TLS; no customer PII in logs; associate device only.

## 25. Analytics / Auditability Requirements

- **Events:** All outcome events to F12 with set_id, trace_id for BR-9 metrics (usage, basket, conversion). **No PII** in event body beyond customer_id if required for attribution (hash or scope per policy). **Audit:** Optional log of “profile viewed” (associate_id, customer_id, timestamp) for compliance; minimal.

## 26. Testing Requirements

- **Unit:** Consent check before profile request; event payload (set_id, trace_id). **Integration:** Mock F11 and F7; load app with customer_id → verify recommendations and profile (when consent OK); send event → verify F12 receives. **E2E:** Real F11 (staging); associate flow; verify events in F17 report.

## 27. Recommended Architecture

- **Component:** “Channels & consumers” layer. **Clienteling app:** Native or web app on tablet; backend-for-frontend (BFF) for F11/F7/F12 calls to avoid exposing keys. **Pattern:** Same as webstore (F13–F15): call F11, render, send events to F12; add F7 + F22 for profile.

## 28. Recommended Technical Design

- **App:** React Native or web (responsive); BFF for API calls. **BFF:** Authenticate associate; call F11 with customer_id, store_id; call F22 check then F7 for profile; return combined payload; on associate action, send event to F12. **Store_id:** From device config or associate select. **Profile:** Only include in response when F22 allows; app shows/hides block.

## 29. Suggested Implementation Phasing

- **Phase 1:** F11 integration (placement=clienteling, customer_id, store_id); recommendations list in app; outcome events (impression, click) to F12. **Phase 2:** Profile (F7 + F22); add-to-cart and purchase events; appointment_id for CM; F17 clienteling report. **Later:** Offline cache; POS deep link; multiple stores.

## 30. Summary

**In-store clienteling integration** (F23) delivers **recommendations** and (where permitted) **customer style profile** to **associate-facing** surfaces via the **same Delivery API** (F11) and **profile service** (F7). **Consent** (F22) gates profile display. **Store/region** and **appointment** context improve relevance for RTW and CM. **Outcome events** go to **recommendation telemetry** (F12) for attribution (BR-9). No separate recommendation logic; same engine and API as web and email. BR-9 success: clienteling usage and basket/conversion when recommendations used.
