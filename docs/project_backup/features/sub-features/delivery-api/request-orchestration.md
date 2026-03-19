# Sub-Feature: Request Orchestration (Delivery API)

**Parent feature:** F11 — Delivery API (`docs/features/delivery-api.md`)  
**BR(s):** BR-7  
**Capability:** Orchestrate the recommendation request flow: validate → resolve → profile + context → engine → format; generate set_id and trace_id.

---

## 1. Purpose

Coordinate the **end-to-end request flow** for the Delivery API: validate incoming request, call identity enrichment (F4), fetch profile (F7) and context (F8) in parallel where possible, call recommendation engine (F9), then hand off to response-formatting. Generate **recommendation_set_id** and **trace_id** at request start and pass through so every response and downstream event can be attributed.

## 2. Core Concept

An **orchestrator** that:
- Validates request (placement, channel required; session_id or customer_id present).
- Generates set_id (UUID) and trace_id (UUID) once per request.
- Calls identity-enrichment to obtain customer_id.
- Calls F7 (profile) and F8 (context) in parallel with customer_id and request params.
- Calls F9 (engine) with profile, context, placement, anchor, limit.
- Invokes response-formatting with engine output (or fallback-handling on timeout/empty).
- Does not implement recommendation logic; only sequencing and delegation.

## 3. User Problems Solved

- **Single flow:** All channels get the same pipeline; no duplicate orchestration in each channel.
- **Attribution:** set_id and trace_id on every response so F12 and F17 can attribute outcomes.
- **Latency:** Parallel F7 + F8 to stay within SLA budget.

## 4. Trigger Conditions

- **Request:** Every valid POST/GET /recommendations (or /v1/recommendations) triggers one orchestration run. No batch or scheduled trigger.

## 5. Inputs

- **From request:** placement, channel, session_id (optional), customer_id (optional), anchor_product_id, cart_product_ids, occasion, region, campaign_id, experiment_id, limit (default 10). Per parent F11 §14–16.

## 6. Outputs

- **To response-formatting:** request_context_echo, recommendation_set_id, trace_id, recommendation_type, items (from F9 or fallback), metadata (e.g. fallback_used). No persistent state; stateless.

## 7. Workflow / Lifecycle

1. **Validate** request (400 if placement/channel missing or no session_id and no customer_id).
2. **Generate** set_id and trace_id (UUID v4).
3. **Identity enrichment** (sub-feature): resolve session_id/user_id → customer_id (or null for anonymous).
4. **Parallel:** GET profile (F7) for customer_id; GET context (F8) for placement, anchor, region. Use customer_id=null when anonymous.
5. **Engine call** (F9): POST with profile, context, placement, anchor, cart, limit. Apply timeout (e.g. 400 ms).
6. **On success:** Pass engine response to response-formatting.
7. **On timeout or error:** Delegate to fallback-handling; pass fallback result to response-formatting.
8. **Respond:** response-formatting produces final body; return 200 with body (set_id, trace_id, items).

## 8. Business Rules

- **set_id and trace_id:** Every 200 response must include both; generated once per request. Same trace_id for the single request/response.
- **No 500 for “no recommendations”:** Use fallback-handling to return 200 with empty or fallback items + set_id/trace_id.
- **Anonymous:** When customer_id is null, pass empty profile and context to F9; engine uses non-personal strategies.

## 9. Configuration Model

- **Timeout:** Total orchestration timeout (e.g. 500 ms) and per-dependency timeout (F7, F8, F9). After timeout, trigger fallback-handling.
- **Parallelization:** F7 and F8 called in parallel; F9 after both complete (or with context timeout).

## 10. Data Model

- **Transient only:** request payload, set_id, trace_id, profile, context, engine response. Not persisted by API.

## 11. API Endpoints

- This sub-feature is **internal** to the Delivery API. Public endpoint is POST/GET /recommendations (or /v1/recommendations); orchestration runs inside that handler.

## 12. Events Produced

- None. Optional: internal metrics (orchestration latency, dependency latency, fallback_used).

## 13. Events Consumed

- None. Synchronous request/response only.

## 14. Integrations

- **Identity enrichment:** Resolve customer_id (F4 or identity-enrichment sub-feature).
- **F7:** Profile read API (customer_id → profile or empty).
- **F8:** Context assemble API (placement, anchor, region → context payload).
- **F9:** Recommendation engine (profile, context, placement, anchor, limit → ranked items).
- **Fallback-handling:** On timeout or engine error/empty.
- **Response-formatting:** Build final response body.

## 15. UI Components

- None. Backend only.

## 16. UI Screens

- None.

## 17. Permissions & Security

- **Auth:** Handled at API gateway; orchestration receives already-authenticated request. Do not log customer_id in plain text.
- **Internal calls:** Service-to-service auth to F4, F7, F8, F9 per technical architecture.

## 18. Error Handling

- **Validation failure:** Return 400 before calling F4/F7/F8/F9.
- **F4/F7/F8 down:** Proceed with customer_id=null or empty profile/context; F9 can still return non-personal results. Or trigger fallback if policy requires profile.
- **F9 timeout or 5xx:** Trigger fallback-handling; return 200 with fallback body.
- **F9 empty:** Fallback-handling fills or returns empty items + set_id/trace_id; 200.

## 19. Edge Cases

- **Missing session_id and customer_id:** Validate as invalid request (400) or treat as anonymous (resolve with no identifiers → customer_id=null). Parent spec says “treat as anonymous”; ensure identity-enrichment accepts empty and returns null.
- **Partial failure:** F7 succeeds, F8 times out → use default context or minimal context; call F9. Document behavior.
- **Engine returns partial list:** F9 may return &lt; limit; response-formatting returns as-is; no second fallback in orchestration (F9 has internal fallback).

## 20. Performance Considerations

- **Latency budget:** F4 (~50 ms) + max(F7, F8) (~100 ms) + F9 (~300 ms) ≈ 450 ms; leave margin for network and formatting. Parallel F7+F8 is critical.
- **Timeouts:** Fail fast on F7/F8/F9 so fallback-handling can return before client timeout.

## 21. Observability

- **Metrics:** Request count; orchestration latency (p50/p95/p99); per-dependency latency and error rate; fallback_used rate.
- **Logs:** trace_id, placement, channel, latency_breakdown; no PII. Log fallback and dependency errors.
- **Alerts:** Orchestration p95 &gt; SLA; F9 timeout rate; fallback rate above threshold.

## 22. Example Scenarios

- **Happy path:** Valid request → set_id/trace_id generated → F4 returns c1 → F7 returns profile, F8 returns context → F9 returns 10 items → response-formatting → 200 with set_id, trace_id, items.
- **Anonymous:** session_id only, F4 returns customer_id=null → F7 empty profile, F8 context → F9 non-personal strategies → 200 with items.
- **Engine timeout:** F9 does not respond in 400 ms → fallback-handling returns static/empty items + set_id/trace_id → 200.

## 23. Implementation Notes

- **Backend:** Orchestrator module or service; async/await or promise-all for F7+F8; single timeout for F9; delegate to fallback-handling and response-formatting modules.
- **Database:** None.
- **Jobs:** None.
- **External APIs:** F4, F7, F8, F9 (internal).
- **Frontend:** None.

## 24. Testing Requirements

- **Unit:** Validation rules; set_id/trace_id format; delegation to fallback on mock F9 timeout.
- **Integration:** With mock F4, F7, F8, F9; verify order (F4 → F7||F8 → F9) and response contains set_id, trace_id. Test anonymous path (F4 returns null). Test F9 timeout → fallback response.
- **Contract:** Orchestrator contract with response-formatting and fallback-handling (input/output shape).

---

## Example: Sequence (conceptual)

1. POST /recommendations { placement, channel, session_id, anchor_product_id, limit }
2. set_id=set-uuid-1, trace_id=trace-uuid-1
3. Identity enrichment: session_id → customer_id=c1
4. F7 get profile(c1), F8 get context(placement, anchor) — parallel
5. F9 recommend(profile, context, placement, anchor, limit) — 10 items
6. Response: 200 { request_context_echo, recommendation_set_id: set-uuid-1, trace_id: trace-uuid-1, items: [...] }

---

## Implementation Implications Summary

| Area | Item |
|------|------|
| Backend services | Orchestrator in Delivery API service; clients for F4, F7, F8, F9; timeout and fallback delegation. |
| Database | None. |
| Jobs | None. |
| External APIs | F4, F7, F8, F9 (internal). |
| Frontend | None. |
