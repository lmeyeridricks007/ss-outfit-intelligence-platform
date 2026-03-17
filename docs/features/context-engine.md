# Feature Deep-Dive: Context Engine (F8)

**Feature ID:** F8  
**BR(s):** BR-5 (Recommendation strategies and algorithms)  
**Capability:** Apply context-aware filtering  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Supply **weather, season, location, occasion, channel/placement, and inventory** context to the recommendation engine so it can filter and rank in a **context-aware** way (BR-5). The context engine aggregates ingested context (F3) and request-time context (placement, channel, anchor product/cart) into a single **context payload** for the recommendation engine (F9).

## 2. Core Concept

- **Context engine** is the component that **assembles** and **supplies** context for each recommendation request. It does not generate recommendations; it answers “what is the current context for this request?”
- **Inputs:** (1) **Ingested context** from F3: weather, season, calendar (by region or global). (2) **Request context** from Delivery API (F11): placement, channel, anchor product or cart, optional occasion/location from request. (3) **Inventory** (optional): in-stock by region from F1 or OMS.
- **Output:** A **context object** passed to F9: e.g. { weather, season, region, locale, occasion, placement, channel, anchor_product_id, cart_product_ids, inventory_filter }. F9 uses this for filtering (e.g. seasonal relevance, weather-appropriate) and ranking.

## 3. Why This Feature Exists

- **BR-5:** Engine must support context-aware filtering (weather, season, occasion, inventory). The context engine is the single place that gathers and normalizes context so F9 does not need to call F3 and parse request separately.
- **Architecture:** Clear separation: ingestion (F3) and request (F11) provide raw inputs; context engine enriches and passes one payload to F9; F9 stays context-agnostic in its data fetching and only uses the payload for logic.

## 4. User / Business Problems Solved

- **Customers:** See recommendations that fit the moment (e.g. summer fabrics in summer, formal for “interview” occasion).
- **Associates:** Store/region and appointment context improve clienteling recommendations.
- **Engine:** Single, consistent context interface; no duplicated context logic in F9.

## 5. Scope

### 6. In Scope

- **Assemble context** for each recommendation request: call F3 (or read from cache) for weather/season/calendar by region; take placement, channel, anchor product, cart, occasion, location from request (F11); optionally resolve “in stock” or “available in region” from inventory (F1 or OMS). Return one **context payload** to F9.
- **Region/locale:** Map request location (geo, store_id, or profile region) to canonical region for weather and inventory. Default region when unknown.
- **Occasion:** Pass through from request (e.g. “wedding,” “interview”); optional validation against allowed list.
- **Inventory:** Optional filter “only in-stock” or “in-stock in region X”; context engine may call inventory service or receive from F11; F9 or F10 applies filter. Define ownership (context engine vs rules engine).
- **Latency:** Context assembly must be fast (&lt; 20–50 ms) so total request latency (F11 → F8 → F9) meets API SLA.

### 7. Out of Scope

- **Recommendation ranking/filtering logic** — F9; context engine only supplies data.
- **Context ingestion** — F3; context engine reads from F3 or cache.
- **Merchandising rules** (inventory rules) — F10; context engine may supply “inventory_filter” but F10 applies exclude/pin. Clarify: inventory as “context” (e.g. only show in-stock) vs “rule” (e.g. exclude out-of-stock); both can be supported with context engine providing availability signal and F10 applying hard exclude.

## 8. Main User Personas

- **Style-Seeking Customer, In-Store Associate** — Indirect; benefit from context-aware results.
- **Backend engineers** — Implement assembly and wiring to F3 and F11.

## 9. Main User Journeys

- **Request flow:** F11 receives request (placement, channel, customer_id, anchor_product_id, optional occasion, location) → F11 (or gateway) calls context engine with request params → context engine fetches weather/season from F3 (or cache), adds request params, optional inventory lookup → returns context payload → F11 passes to F9 with profile and other inputs → F9 uses context for filtering and ranking.
- **Cache:** F3 data (weather, season) cached by region with TTL; context engine reads from cache to avoid blocking on F3 every request.

## 10. Triggering Events / Inputs

- **Request-time only.** Each recommendation request triggers one context assembly. Inputs: placement, channel, customer_id (for profile), anchor_product_id, cart_product_ids, occasion, location/region, campaign_id, experiment_id (for attribution). Optional: inventory_region.

## 11. States / Lifecycle

- **Context payload:** Transient; not stored. Built per request. No state machine.
- **Cache (F3 data):** Warm / Expired. Refresh on TTL or on F3 update (optional).

## 12. Business Rules

- **Default context:** If F3 unavailable or region unknown, supply defaults (e.g. season = current derived, weather = unknown) so F9 does not break. F9 should treat “unknown” as “no filter” for that dimension.
- **Occasion:** If request has occasion, pass through; F9 may filter by occasion. If not provided, leave null or derive from calendar (e.g. holiday) if available.
- **Placement and channel:** Always from request; required for strategy and rule selection in F9/F10.

## 13. Configuration Model

- **Region mapping:** location/geo/store_id → region_id. Default region when unmapped.
- **Allowed occasions:** Optional list; invalid occasion ignored or defaulted.
- **Inventory:** On/off for “in-stock only” in context; which service to call (F1 or OMS). Optional.
- **Feature flags:** Bypass context (e.g. for testing); or disable weather/season.

## 14. Data Model

- **Context payload (in-memory, not persisted):** { placement, channel, region, locale, weather: { temperature, condition }, season, occasion, anchor_product_id, cart_product_ids, inventory_filter (optional), campaign_id, experiment_id, request_timestamp }. Schema defined for F9 contract.
- **No persistent storage** in context engine; only assembly and pass-through. F3 owns persisted context data.

## 15. Read Model / Projection Needs

- **Recommendation engine (F9):** Only consumer of context payload. Reads from context engine response (or F11 passes it). No direct read of F3 from F9 if context engine is in path.
- **Analytics:** Optional: log context used per request (placement, season, occasion) for “context adherence” (BR-5); do not log PII.

## 16. APIs / Contracts

- **Internal (called by F11 or gateway):** `POST /context/assemble` with body = request params (placement, channel, anchor_product_id, cart_product_ids, occasion, region, customer_id, campaign_id, experiment_id) → 200 OK { context payload }.
- **Example:**

```json
POST /context/assemble
{
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "anchor_product_id": "prod-1",
  "region": "eu-west",
  "occasion": null
}
→ 200 OK
{
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "region": "eu-west",
  "weather": { "temperature": 18, "condition": "partly_cloudy" },
  "season": "spring",
  "occasion": null,
  "anchor_product_id": "prod-1",
  "inventory_filter": "in_stock_region_eu_west"
}
```

## 17. Events / Async Flows

- **No events.** Synchronous request/response only. Optional: F3 emits context update → context engine invalidates cache (if cache lives in context engine).

## 18. UI / UX Design

- **None.** Backend only. Optional ops: context payload sample in logs for debugging; no UI.

## 19. Main Screens / Components

- None.

## 20. Permissions / Security Rules

- **Context assemble API:** Internal only (F11 or recommendation gateway). No customer-facing exposure. No PII in context payload (only product_ids, region, placement); customer_id may be passed for profile lookup but not stored in context engine.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Context assembly failure (e.g. F3 timeout); high latency. Fallback: return minimal context (placement, channel, anchor) so F9 still runs.
- **Side effects:** None; stateless. F9 behavior changes with context (expected).

## 22. Integrations / Dependencies

- **Upstream:** Context data ingestion (F3) for weather, season, calendar. Delivery API (F11) or gateway for request params. Optional: inventory (F1 or OMS) for in-stock filter.
- **Downstream:** Recommendation engine (F9) receives context payload from F11; context engine is called by F11 before F9.
- **Shared:** Architecture §4.1 (context in request); BR-5 (context-aware filtering).

## 23. Edge Cases / Failure Cases

- **F3 down or slow:** Use cached context or defaults; do not fail request. Timeout F3 call (e.g. 50 ms) and fallback.
- **Unknown region:** Default region or “global”; weather/season may be global or null.
- **Missing anchor/cart:** Pass null; F9 handles “no anchor” (e.g. homepage strategy).
- **Invalid occasion:** Ignore or default; do not break.

## 24. Non-Functional Requirements

- **Latency:** Assembly p95 &lt; 20–50 ms so total API latency is acceptable. Cache F3 data; single round-trip to F3 or cache only.
- **Availability:** High; fallback context on failure so F9 always receives a payload.
- **No persistence:** No DB; stateless service or library.

## 25. Analytics / Auditability Requirements

- **Metrics:** Assembly latency, cache hit rate, fallback rate. Optional: context dimensions (season, occasion) distribution for “context adherence” reporting (BR-5).
- **Audit:** No PII; optional log of context payload (anonymized) for debugging.

## 26. Testing Requirements

- **Unit:** Assembly logic: request params + F3 response → payload. Defaults when F3 fails or region unknown.
- **Integration:** Call F3 (stub), call context assemble with request → verify payload; verify F9 receives and uses (mock F9). Timeout and fallback test.
- **Contract:** Context payload schema for F9.

## 27. Recommended Architecture

- **Component:** Part of “Recommendation & governance” layer or “Experience delivery” layer. Can be a separate microservice or in-process with F11/F9. Lightweight; often in-process or same process as F11 to avoid extra network hop.
- **Pattern:** Sync call: F11 → context engine (assemble) → return payload → F11 passes to F9. Cache for F3 data inside context engine or shared cache.

## 28. Recommended Technical Design

- **Assemble function:** Input = request params; call F3 API or read from cache (key = region); merge request params + F3 result; optional inventory lookup; return payload. **Cache:** Redis or in-memory for (region → weather, season) with TTL 5–15 min. **No DB.** Deploy with F11 or F9 to reduce latency.

## 29. Suggested Implementation Phasing

- **Phase 1:** Assemble placement, channel, anchor, cart, region; call F3 for weather and season; return payload. Defaults on F3 failure. No inventory filter.
- **Phase 2:** Inventory filter (in-stock by region); occasion validation; cache tuning; metrics.
- **Later:** Calendar/occasion derivation; multi-region inventory.

## 30. Summary

**Context engine** (F8) **assembles** context for each recommendation request from **ingested context** (F3) and **request parameters** (from F11). It returns a single **context payload** (weather, season, placement, channel, anchor, cart, occasion, optional inventory filter) to the **recommendation engine** (F9). It does not run recommendation logic; it only supplies data. Failures must not break the API; defaults and cache (for F3) ensure low latency and high availability. BR-5 context-aware filtering depends on this payload.
