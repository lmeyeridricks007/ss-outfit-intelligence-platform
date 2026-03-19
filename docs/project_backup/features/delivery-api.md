# Feature Deep-Dive: Delivery API (F11)

**Feature ID:** F11  
**BR(s):** BR-7 (Delivery API and channel activation)  
**Capability:** Deliver recommendations via API  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/api-standards.md`, `docs/project/domain-model.md`

---

## 1. Purpose

Expose a **single logical API** for recommendations so web, email, and clienteling can request **outfits, cross-sell, upsell, and style bundles** with **recommendation set ID** and **trace ID** for attribution (BR-7). The Delivery API is the **experience delivery** layer: it accepts the request, enriches it (profile, context), calls the recommendation engine (F9) and rules (F10), and returns a **structured response** with set_id, trace_id, ranked items/looks, and reason/source hints. It also defines **fallback behavior** when the engine returns insufficient results or when SLA is missed.

## 2. Core Concept

- **Single API:** One contract for all channels (webstore, email, clienteling). Channels differ only in **request context** (placement, channel) and **presentation**; recommendation logic is shared (architecture principle).
- **Request:** Customer/session, context (anchor product or cart, placement, channel), optional campaign or experiment. Align with Recommendation Request (domain model) and api-standards.
- **Response:** Request context echo, **recommendation set ID**, **trace ID**, recommendation type, **ranked items or looks**, **reason/source hints**. Per api-standards and BR-7. Consumers must send **outcome events** (impression, click, add-to-cart, purchase, dismiss) with set_id and trace_id (F12).
- **Fallback:** When engine returns fewer items than requested or when engine/context timeout, return configured fallback (e.g. static curated set or “popular”) so widgets never break. Latency fallback: if total time &gt; SLA, return cached or fallback response.

## 3. Why This Feature Exists

- **BR-7:** A stable delivery API must provide recommendations to webstore, email, and clienteling with set ID, trace ID, and reason/source for explainability and analytics.
- **Architecture:** Single recommendation logic, multi-channel delivery; all channels consume this API and adapt presentation only.
- **Attribution:** Set ID and trace ID on every response and on every outcome event (F12) enable CTR, conversion, and revenue attribution (BR-10).

## 4. User / Business Problems Solved

- **Channels (web, email, clienteling):** One integration point; same contract; no duplicate logic.
- **Product/Engineering:** Clear API boundary; versioning and evolution in one place.
- **Analytics:** Attribution and debugging via set_id and trace_id.

## 5. Scope

### 6. In Scope

- **Request contract:** customer_id (optional), session_id, placement (required), channel (required), anchor_product_id (optional), cart_product_ids (optional), context (optional: occasion, location, region), campaign_id (optional), experiment_id (optional), limit (optional, default 10), options (optional: include_reason, response_format). All per domain model and architecture §4.1.
- **Response contract:** request_context_echo (placement, channel, anchor, etc.), recommendation_set_id (stable ID for this response), trace_id (for this request/response), recommendation_type (outfit, cross-sell, upsell, style_bundle, occasion_based, contextual, personal), items (array of product_id or look_id with optional reason/source), metadata (optional). Per api-standards.
- **Orchestration:** Resolve customer_id (F4) if only session_id provided; fetch profile (F7); call context engine (F8); call recommendation engine (F9) with profile and context; F9 internally calls F10. Generate **set_id** and **trace_id** (UUID or platform scheme); attach to response. On engine failure or empty+no fallback, return fallback response or 200 with empty items + set_id/trace_id (do not 500 so client can still log impression).
- **Fallback:** When engine returns &lt; limit items, engine already runs fallback (F9); if F9 still returns empty (e.g. dependency failure), Delivery API returns static fallback (configurable) or empty list with set_id/trace_id. On timeout (e.g. &gt; 500 ms), return cached or fallback response; log and alert.
- **Channel-specific formatting (optional):** Response can be generic (list of ids + reason); or API can accept `response_format=web|email|clienteling` and return slightly different shape (e.g. email: include image URLs). Prefer single shape; channels adapt. If format differs, document per channel.
- **SLA:** Latency and availability targets TBD (missing decision); API must document fallback when SLA missed.

### 7. Out of Scope

- **Recommendation logic** — F9. API only orchestrates and formats.
- **Outcome event collection** — F12. API does not receive events; channels send to event pipeline. API only returns set_id and trace_id so channels can attach them to events.
- **Admin UI** — F18–F20. API is programmatic only.
- **Authentication/authorization** — Assumed by gateway; API accepts authenticated requests (e.g. API key or token). Details in technical architecture.

## 8. Main User Personas

- **CRM / Email Marketing Manager, Product Manager** — Integrate campaigns and products with API.
- **Frontend engineers (web, clienteling)** — Consume API for widgets and surfaces.
- **Backend engineers** — Implement orchestration, set_id/trace_id, fallback.

## 9. Main User Journeys

- **Webstore PDP:** Frontend calls `GET /recommendations?placement=pdp_complete_the_look&channel=webstore&anchor_product_id=...&session_id=...` (or POST with body) → API resolves customer, gets profile, context, calls engine → returns 200 with items + set_id + trace_id → frontend renders widget and sends impression/click events with set_id/trace_id (F12).
- **Email:** Email assembly service calls API with campaign_id, audience segment (e.g. customer_ids or list), placement=email_block, limit=5 → API returns payload per customer or batch → email includes recommendations and logs set_id/trace_id for click tracking.
- **Clienteling:** App calls API with customer_id, placement=clienteling, channel=clienteling, optional store_id/region → same flow → returns recommendations; app shows and sends outcome events.

## 10. Triggering Events / Inputs

- **Request-only.** Every call is a single request/response. Inputs: see Request contract above. No webhooks or async triggers from API.

## 11. States / Lifecycle

- **Request:** In progress → Completed (200 + body) / Fallback returned / Error (5xx or 200 with fallback body). No persistent state; stateless API.
- **Set ID and trace ID:** Generated per response; stored only in logs and in outcome events (F12), not in API store.

## 12. Business Rules

- **Set ID and trace ID:** Every 200 response must include recommendation_set_id and trace_id. Same trace_id for the single request/response; set_id identifies the recommendation set (this response). Channels must send these on all outcome events (F12); API docs must require it.
- **No PII in response:** Response contains product_ids, look_ids, set_id, trace_id, reason codes; no customer name/email. Request may contain customer_id; do not log PII.
- **Fallback:** Never return 500 for “no recommendations”; return 200 with empty items or fallback items and set_id/trace_id so client can render “no results” or fallback and still log.
- **Idempotency:** Same request (e.g. same session, placement, anchor) can return different results (e.g. A/B experiment, or engine non-determinism). Optional: idempotency key for email batch to dedupe; not required for real-time.

## 13. Configuration Model

- **Placement and strategy:** Which placement maps to which engine strategy (or engine reads from F20); API may pass through. Fallback strategy per placement (in F9 or API config).
- **Fallback response:** Static list (product_ids or look_ids) or “empty” per placement when engine fails. Configurable.
- **Timeout:** Max time to wait for F8+F9 (e.g. 500 ms); after that return fallback. SLA targets (p95, availability %) in technical architecture.
- **Rate limits:** Optional per client (channel); prevent abuse. Document in API spec.

## 14. Data Model

- **Request (transient):** session_id, customer_id, placement, channel, anchor_product_id, cart_product_ids, context, campaign_id, experiment_id, limit. Not persisted by API.
- **Response (transient):** recommendation_set_id, trace_id, recommendation_type, items: [ { id, type (product|look), reason_code, source } ], request_context_echo. Not persisted by API; clients and F12 store set_id/trace_id in events.
- **No persistent storage** in Delivery API for recommendations; only orchestration and pass-through.

## 15. Read Model / Projection Needs

- **API reads:** Identity (F4) for resolve; Profile (F7); Context (F8); Engine (F9) returns list. API does not read F5/F6/F10 directly; F9 encapsulates. Optional: placement/strategy config from F20.
- **Channels:** Only consumer of API response. Analytics (F12, F17) consume outcome events that reference set_id/trace_id.

## 16. APIs / Contracts

**Public (to channels):**

- `GET /recommendations` or `POST /recommendations` with query/body:
  - **Request:** placement (required), channel (required), session_id (required if no customer_id), customer_id (optional), anchor_product_id (optional), cart_product_ids (optional), occasion (optional), region (optional), campaign_id (optional), experiment_id (optional), limit (optional, default 10).
  - **Response:** 200 OK { request_context_echo, recommendation_set_id, trace_id, recommendation_type, items: [ { id, type, reason_code, source } ] }. 4xx for bad request (e.g. missing placement); 5xx only for unexpected server error (prefer 200 + fallback).
- **Example:**

```json
POST /recommendations
{
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "session_id": "sess-abc",
  "anchor_product_id": "prod-suit-1",
  "limit": 10
}
→ 200 OK
{
  "request_context_echo": { "placement": "pdp_complete_the_look", "channel": "webstore", "anchor_product_id": "prod-suit-1" },
  "recommendation_set_id": "set-uuid-1",
  "trace_id": "trace-uuid-1",
  "recommendation_type": "cross-sell",
  "items": [
    { "id": "look-1", "type": "look", "reason_code": "complete_the_look", "source": "curated" },
    { "id": "prod-shirt-1", "type": "product", "reason_code": "compatible", "source": "graph" }
  ]
}
```

## 17. Events / Async Flows

- **No events emitted by API.** Outcome events (impression, click, etc.) are emitted by **channels** to event pipeline (F12); they must include set_id and trace_id from this response.
- **Flow:** Sync: Client → API → F4 (resolve) → F7 (profile) → F8 (context) → F9 (engine) → API (format) → Client.

## 18. UI / UX Design

- **None.** API only. Channel UIs (web widgets, clienteling app, email) are separate (F13–F15, F23, F16).

## 19. Main Screens / Components

- None. API documentation (OpenAPI/Swagger) is the “contract UI” for integrators.

## 20. Permissions / Security Rules

- **Authentication:** API key or token per channel/client; reject unauthenticated. Technical architecture defines auth (e.g. API gateway).
- **Authorization:** Channel may be restricted to certain placements (e.g. clienteling only for clienteling placement). Optional. No customer-level auth in API (customer_id is data, not identity of caller).
- **PII:** Do not log request body with customer_id in plain text in production; mask or hash in logs. Response has no PII.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Latency &gt; SLA; error rate; fallback rate; dependency (F9, F7, F8) failure.
- **Side effects:** None; stateless. Channels use response to render and to send events (F12).

## 22. Integrations / Dependencies

- **Upstream:** Identity (F4), Profile (F7), Context (F8), Recommendation engine (F9). Optional: F20 for placement config.
- **Downstream:** All channels (webstore F13–F15, email F16, clienteling F23) and future mobile. Telemetry (F12) consumes outcome events that carry set_id/trace_id from this API.
- **Shared:** api-standards (request context echo, set_id, trace_id, reason, source); domain model (Recommendation Request, Result); BR-7.

## 23. Edge Cases / Failure Cases

- **Engine timeout:** Return fallback response with set_id/trace_id; log and alert. Do not 504 unless policy is to fail open.
- **Engine returns empty:** F9 should have run fallback; if still empty, API returns empty items with set_id/trace_id (200). Client shows “no recommendations” or static CTA.
- **Missing session_id and customer_id:** Treat as anonymous; resolve to null customer_id; profile empty; engine uses non-personal strategies. Return 200.
- **Invalid placement:** 400 Bad Request with message. Do not call engine.
- **Rate limit:** 429 Too Many Requests; retry-after header. Optional.

## 24. Non-Functional Requirements

- **Latency:** p95 &lt; X ms (TBD; e.g. 500 ms). Include F4, F7, F8, F9 in budget; optimize (parallel calls, cache profile/context).
- **Availability:** ≥ Y% (TBD). Fallback on dependency failure so API always returns 200 + body (or fallback body).
- **Versioning:** API version in URL or header (e.g. /v1/recommendations) for backward compatibility when contract evolves.

## 25. Analytics / Auditability Requirements

- **Logs:** trace_id, placement, channel, latency, fallback_used, dependency errors. No PII. For debugging and SLA monitoring.
- **Metrics:** Request count by placement/channel; latency p50/p95; error and fallback rate; export to F17.

## 26. Testing Requirements

- **Unit:** Request validation; set_id/trace_id generation; fallback when engine returns empty or error.
- **Integration:** Full flow with mock F4, F7, F8, F9; verify response shape and set_id/trace_id. Contract tests: OpenAPI schema. Load test: latency under load.
- **E2E:** Channel (e.g. web widget) calls API → renders → sends event with set_id/trace_id → F12 receives (optional).

## 27. Recommended Architecture

- **Component:** “Experience delivery” layer; single entry point for recommendations. API gateway or dedicated service that orchestrates F4, F7, F8, F9.
- **Pattern:** Request → validate → resolve (F4) → get profile (F7) → get context (F8) → call engine (F9) → format response → return. Parallelize F7 and F8; then F9. Generate set_id and trace_id at start; pass through to response.

## 28. Recommended Technical Design

- **Service:** Stateless HTTP/HTTPS; horizontal scaling. **Orchestrator:** Sync calls to F4, F7, F8, F9 (or async with timeout). **IDs:** UUID v4 for set_id and trace_id; store in response only. **Fallback:** Config-driven list or “empty”; return on timeout or engine error. **Docs:** OpenAPI 3.0; document set_id/trace_id requirement for outcome events (F12).

## 29. Suggested Implementation Phasing

- **Phase 1:** POST /recommendations with placement, channel, session_id, anchor_product_id; orchestrate F4, F7, F8, F9; return set_id, trace_id, items; fallback on error/empty. One placement (e.g. pdp_complete_the_look).
- **Phase 2:** All placements; campaign_id, experiment_id; response_format optional; SLA and timeout; rate limit; OpenAPI and client SDKs.
- **Later:** Versioning; caching (e.g. same anchor + placement for 1 min); batch endpoint for email (if needed).

## 30. Summary

**Delivery API** (F11) is the **single entry point** for recommendations. It accepts **placement, channel, customer/session, anchor/cart, and optional campaign/experiment**, orchestrates **identity** (F4), **profile** (F7), **context** (F8), and **recommendation engine** (F9), and returns **recommendation set ID, trace ID, ranked items/looks, and reason/source**. **Fallback** when engine fails or returns empty ensures widgets never break. All channels (web, email, clienteling) use this API; outcome events (F12) must carry set_id and trace_id for attribution. BR-7 and api-standards are satisfied; latency and availability targets are TBD in technical architecture.
