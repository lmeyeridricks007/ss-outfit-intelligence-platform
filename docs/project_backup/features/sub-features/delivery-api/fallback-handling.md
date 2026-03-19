# Sub-Feature: Fallback Handling (Delivery API)

**Parent feature:** F11 — Delivery API (`docs/features/delivery-api.md`)  
**BR(s):** BR-7, BR-5  
**Capability:** When the recommendation engine times out, returns an error, or returns too few items, provide a fallback response (static list or empty) with set_id and trace_id so the API always returns 200 and widgets never break.

---

## 1. Purpose

Ensure the Delivery API **never returns 500 or a broken response** for “no recommendations” or “engine failure.” When F9 (engine) times out, returns 5xx, or returns fewer items than needed and its internal fallback also fails, this sub-feature supplies a **fallback response** (configurable static product_ids/look_ids or empty list) and attaches the **same set_id and trace_id** generated for the request so attribution (F12) and analytics (F17) still work. Aligns with parent spec: “return 200 with fallback body; do not 504 unless policy is to fail open.”

## 2. Core Concept

A **fallback provider** that:
- Is invoked by request-orchestration when: (a) F9 call times out, (b) F9 returns 5xx or throws, (c) F9 returns empty and no internal fallback filled (or F9 is not called due to earlier dependency failure).
- Returns a **fallback payload:** items array (static list from config, or “popular” placeholder, or empty) with the **request’s set_id and trace_id** (passed from orchestrator).
- Does not call F9 again; does not retry. Single attempt to produce a safe response.
- Configurable per placement or global: which product_ids/look_ids to return, or “empty”.

## 3. User Problems Solved

- **Availability:** Recommendation API remains usable when engine or dependencies fail; channels get 200 and can show “no recommendations” or static CTA.
- **Attribution:** set_id and trace_id on fallback response so impression and any click can still be attributed.
- **UX:** Widgets do not show errors or blank; they show fallback content or empty state with set_id/trace_id for tracking.

## 4. Trigger Conditions

- **Orchestrator decision:** When F9 timeout, F9 error, F9 empty (and engine’s own fallback did not fill), or when orchestrator decides to skip F9 (e.g. F7 and F8 both failed and policy is to return fallback). Orchestrator calls fallback-handling with (set_id, trace_id, request_context_echo, placement, optional limit).

## 5. Inputs

- **From orchestrator:** recommendation_set_id, trace_id, request_context_echo, placement, channel, optional limit. Reason for fallback (timeout, error, empty) may be passed for logging.

## 6. Outputs

- **items:** Array of { id, type, reason_code?, source? } — either from config (static list for placement or global) or empty [].
- **recommendation_type:** e.g. "fallback" or "contextual".
- **fallback_used:** true (so response-formatting can include in metadata).
- **request_context_echo:** Pass-through from input. Same set_id and trace_id as input.

## 7. Workflow / Lifecycle

1. Receives (set_id, trace_id, request_context_echo, placement, reason).
2. Looks up fallback config for placement (or default): static list of product_ids/look_ids or “empty”.
3. If static list: map to items array with type and optional reason_code/source (e.g. source=fallback).
4. If empty: items = [].
5. Returns { set_id, trace_id, request_context_echo, items, recommendation_type: "fallback", fallback_used: true } to orchestrator → response-formatting builds 200 response.
6. No retry; no call to F9.

## 8. Business Rules

- **Every fallback response must include the same set_id and trace_id** as the original request. Do not generate new IDs.
- **Never return 5xx from Delivery API** for “no recommendations” or engine failure; always 200 + body (with fallback_used so clients know).
- **Configurable:** Per-placement or global fallback list; if no config, use empty list. Document default.
- **No PII:** Fallback payload has only product/look ids and echo; no customer data.

## 9. Configuration Model

- **Per placement:** placement_id → fallback_type (static \| empty), fallback_product_ids [], fallback_look_ids [].
- **Global default:** fallback_type=empty or static list when no placement override.
- **Timeout/error policy:** Always use fallback (no 504). Optional future: feature flag to 504 on engine timeout (not recommended).

## 10. Data Model

- **Config (read):** placement_id, fallback_type, fallback_product_ids, fallback_look_ids. Stored in config store or F20; no persistent state in this sub-feature for request data.

## 11. API Endpoints

- No external API. Internal module called by request-orchestration. Optional: admin API to preview fallback for a placement (F20).

## 12. Events Produced

- None. Optional: metric (fallback_used_count by placement, reason) for alerting and tuning.

## 13. Events Consumed

- None. Invoked synchronously by orchestrator.

## 14. Integrations

- **Orchestrator:** Calls fallback-handling when engine timeout/error/empty; passes set_id, trace_id, placement.
- **Config:** Read from F20 (placement config) or app config. Optional: F6 (look store) to resolve look_ids to item shape if needed; prefer preconfigured list to avoid dependency in fallback path.
- **Response-formatting:** Receives fallback output and builds 200 response like normal path.

## 15. UI Components

- None. Optional: F20 admin “Preview fallback” shows what would be returned for a placement.

## 16. UI Screens

- None. Optional: F20 placement config screen includes fallback list configuration.

## 17. Permissions & Security

- **Config:** Only authorized roles (merchandising, admin) can set fallback list. Fallback-handling only reads config.
- **Response:** No PII; same security as normal response.

## 18. Error Handling

- **Config missing or invalid:** Use global default (empty list); log. Do not fail the request.
- **Fallback list references invalid product_id/look_id:** Return items that exist; skip invalid; or return empty. Do not 500.

## 19. Edge Cases

- **Orchestrator passes null set_id/trace_id:** Must not happen; if it does, generate new UUIDs and log error (ensure response still has both IDs).
- **Very long static list:** Truncate to limit (e.g. 10) per request limit; document.
- **Placement has no fallback config:** Use global default (empty or global static list).

## 20. Performance Considerations

- **Latency:** No call to F9; only config lookup and in-memory build. Should add minimal latency (&lt;5 ms). Config may be cached with TTL.
- **Availability:** No dependency on F9 in fallback path; only config store (or in-memory default).

## 21. Observability

- **Metrics:** Fallback_used count by placement; fallback reason (timeout, error, empty). Alert when fallback rate exceeds threshold.
- **Logs:** trace_id, placement, reason (timeout/error/empty) for debugging. No PII.
- **Alerts:** Fallback rate &gt; X%; F9 timeout rate.

## 22. Example Scenarios

- **Engine timeout:** F9 does not respond in 400 ms → orchestrator calls fallback-handling(set_id, trace_id, placement=pdp_complete_the_look) → config says empty → items: [], fallback_used: true → 200.
- **Engine returns 503:** Orchestrator catches → fallback-handling with static list for placement → 200 with 5 static product_ids, fallback_used: true.
- **Engine returns empty:** F9 and its internal fallback return [] → orchestrator calls fallback-handling → empty or static → 200.

## 23. Implementation Notes

- **Backend:** Fallback-handling module in Delivery API service; config client or in-memory config; no DB for request state; optional cache for config.
- **Database:** None for request flow; config may be in DB (F20) or file.
- **Jobs:** None.
- **External APIs:** None in hot path. Optional: resolve look_ids to item details if fallback uses look_ids and response needs full shape; prefer static ids only to keep fallback path simple.
- **Frontend:** None. Channels receive same response shape; fallback_used in metadata so they can show “recommendations unavailable” or static block.

## 24. Testing Requirements

- **Unit:** Config lookup (placement override, global default); empty list; static list mapping to items array; set_id/trace_id pass-through.
- **Integration:** Orchestrator triggers fallback on mock F9 timeout → response 200 with set_id, trace_id, fallback_used true. Verify no call to F9 when fallback is used.
- **Contract:** Fallback response shape matches normal response shape (same schema).

---

## Example: Fallback response body

Same as normal response; metadata.fallback_used = true:

```json
{
  "request_context_echo": { "placement": "pdp_complete_the_look", "channel": "webstore" },
  "recommendation_set_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  "recommendation_type": "fallback",
  "items": [],
  "metadata": { "fallback_used": true }
}
```

---

## Implementation Implications Summary

| Area | Item |
|------|------|
| Backend services | Fallback-handling module; config reader (F20 or app config). |
| Database | None (config may be in F20 DB). |
| Jobs | None. |
| External APIs | None in fallback path. |
| Frontend | None; channels interpret fallback_used. |
