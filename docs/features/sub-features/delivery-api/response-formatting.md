# Sub-Feature: Response Formatting (Delivery API)

**Parent feature:** F11 — Delivery API (`docs/features/delivery-api.md`)  
**BR(s):** BR-7  
**Capability:** Build the final HTTP response body and status code for the recommendation API from orchestrator output (set_id, trace_id, items, request context).

---

## 1. Purpose

Produce the **contract-compliant response** for the Delivery API: request_context_echo, recommendation_set_id, trace_id, recommendation_type, items array (with id, type, reason_code, source), and optional metadata (e.g. fallback_used). Ensures every response conforms to api-standards and BR-7 so channels and F12 can rely on set_id and trace_id for attribution.

## 2. Core Concept

A **response builder** that:
- Takes orchestrator output: set_id, trace_id, items (from F9 or fallback), request_context_echo, recommendation_type, fallback_used (optional).
- Builds JSON body per OpenAPI/contract: no extra fields that are not part of the contract; no PII.
- Sets HTTP status (200 for success and fallback; 4xx only for validation before orchestration). Never returns 500 for “no recommendations” (orchestrator uses fallback-handling for that).
- Optional: channel-specific formatting (e.g. response_format=email adds image URLs); prefer single shape and let channels adapt.

## 3. User Problems Solved

- **Consistency:** All channels receive the same response shape; integration and F12 event attachment are predictable.
- **Attribution:** set_id and trace_id always present on 200 responses so clients can attach them to outcome events.
- **Contract evolution:** Single place to change response shape when API version or contract evolves.

## 4. Trigger Conditions

- **Request-time:** Invoked by request-orchestration after engine (or fallback) returns; one response per request.

## 5. Inputs

- **From orchestrator:** recommendation_set_id, trace_id, recommendation_type, items (array of { id, type, reason_code?, source? }), request_context_echo (placement, channel, anchor_product_id?, etc.), fallback_used (boolean, optional).

## 6. Outputs

- **HTTP status:** 200 (success and fallback cases). 4xx are returned by validation before orchestration, not by this sub-feature.
- **Body:** JSON object with request_context_echo, recommendation_set_id, trace_id, recommendation_type, items, optional metadata (fallback_used).

## 7. Workflow / Lifecycle

1. Receive orchestrator output.
2. Build request_context_echo from request (placement, channel, anchor_product_id, etc.); or use echo provided by orchestrator.
3. Build items array: ensure each item has id, type (product \| look), and optional reason_code, source. Filter or map if engine returns extra fields.
4. Assemble final JSON. Ensure set_id and trace_id are strings (UUID).
5. Return 200 with Content-Type application/json and body. No persistent state.

## 8. Business Rules

- **Every 200 must include recommendation_set_id and trace_id.** No exception.
- **No PII in response.** Only product_ids, look_ids, set_id, trace_id, reason codes, placement, channel.
- **Empty items allowed.** When fallback returns empty list, response still has items: [] with set_id and trace_id.
- **Contract stability:** Add new fields only in new API version or with optional fields; do not remove or rename without versioning.

## 9. Configuration Model

- **Response format variant:** Optional response_format=web|email|clienteling to add fields (e.g. image URLs for email). Default: single shape.
- **API version:** Version in URL or header; response may include version field. Document in OpenAPI.

## 10. Data Model

- **Response (transient):** See Outputs; not persisted. Schema aligns with OpenAPI response schema.

## 11. API Endpoints

- No separate endpoint. This sub-feature builds the body for GET/POST /recommendations (or /v1/recommendations) 200 response.

## 12. Events Produced

- None. Response is returned synchronously to client.

## 13. Events Consumed

- None.

## 14. Integrations

- **Orchestrator:** Provides input. **API gateway / framework:** Sends status and body to client. **Channels:** Consume response. **F12:** Channels send set_id and trace_id from this response in outcome events.

## 15. UI Components

- None. API response only.

## 16. UI Screens

- None. OpenAPI/Swagger shows response schema.

## 17. Permissions & Security

- **No PII:** Validate that built response contains no customer name, email, or other PII. Logs must not log full response with PII (none should be present).
- **Sanitization:** If engine or fallback ever returned sensitive data (should not), strip before building response.

## 18. Error Handling

- **Orchestrator did not provide set_id or trace_id:** Must not happen if orchestration is correct; if it does, generate UUIDs and log error (do not return 500 to client; return 200 with generated IDs).
- **Invalid item shape:** Map or filter to valid shape; log if engine contract violated.

## 19. Edge Cases

- **Items empty:** Return items: []; valid response.
- **Items have extra fields:** Include only contract fields (id, type, reason_code, source); drop extra.
- **recommendation_type unknown:** Use default (e.g. "contextual") or value from engine; ensure enum in contract.

## 20. Performance Considerations

- **Overhead:** Minimal (in-memory build). No I/O. Serialization (JSON) should be fast.
- **Size:** Limit items array size to limit (e.g. 10); orchestrator already passes limit; do not truncate without documenting.

## 21. Observability

- **Metrics:** Response size (optional); not critical. Errors if set_id/trace_id missing (should be zero).
- **Logs:** Log trace_id, placement, item count, fallback_used for debugging; no PII.

## 22. Example Scenarios

- **Success:** Orchestrator provides set_id, trace_id, 10 items, request_context_echo → response 200 with same + items array.
- **Fallback:** Orchestrator provides set_id, trace_id, items: [] or static list, fallback_used: true → response 200 with metadata.fallback_used or equivalent.
- **Email format:** If response_format=email, add image_url per item (optional); document in API spec.

## 23. Implementation Notes

- **Backend:** Response builder function or module in Delivery API service; receives orchestrator output; returns { statusCode: 200, body: JSON }. No DB, no jobs, no frontend.
- **Database:** None.
- **Jobs:** None.
- **External APIs:** None.
- **Frontend:** None. OpenAPI spec is the contract for frontend/channels.

## 24. Testing Requirements

- **Unit:** Input → output JSON shape; set_id and trace_id always present; items array shape; empty items; fallback_used in metadata.
- **Contract:** Publish OpenAPI response schema; contract test that builder output validates against schema.
- **Integration:** Orchestrator → response-formatting → client receives 200 and valid JSON; F12 consumer can parse set_id and trace_id.

---

## Example: Response body

```json
{
  "request_context_echo": {
    "placement": "pdp_complete_the_look",
    "channel": "webstore",
    "anchor_product_id": "prod-suit-1"
  },
  "recommendation_set_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  "recommendation_type": "cross-sell",
  "items": [
    { "id": "look-1", "type": "look", "reason_code": "complete_the_look", "source": "curated" },
    { "id": "prod-shirt-1", "type": "product", "reason_code": "compatible", "source": "graph" }
  ],
  "metadata": { "fallback_used": false }
}
```

---

## Implementation Implications Summary

| Area | Item |
|------|------|
| Backend services | Response builder in Delivery API; OpenAPI spec maintenance. |
| Database | None. |
| Jobs | None. |
| External APIs | None. |
| Frontend | None (consumers use OpenAPI). |
