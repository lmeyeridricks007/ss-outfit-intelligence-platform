# Sub-Feature: Identity Enrichment (Delivery API)

**Parent feature:** F11 — Delivery API (`docs/features/delivery-api.md`)  
**BR(s):** BR-7  
**Capability:** Resolve request identifiers (session_id, customer_id) to canonical customer_id for use by profile and engine within the Delivery API flow.

---

## 1. Purpose

Within the Delivery API request path, **obtain a canonical customer_id** from the incoming request’s session_id and/or customer_id so the orchestrator can call F7 (profile) and F9 (engine) with a consistent identity. Delegates to F4 (identity resolution) resolve-api; this sub-feature is the **adapter** that maps API request fields to the resolve call and handles anonymous when no identifier or no link exists.

## 2. Core Concept

A **thin enrichment step** that:
- Reads session_id and/or customer_id from the validated recommendation request.
- If customer_id is already provided (e.g. clienteling), optionally validates or passes through; or calls F4 resolve with customer_id for consent check.
- If only session_id (or session_id + user_id from auth context), calls F4 POST /identity/resolve with channel and use_case=recommendations.
- Returns customer_id (or null for anonymous) to the orchestrator. Does not implement resolution logic; that is F4.

## 3. User Problems Solved

- **Single call site:** Orchestrator does not need to know F4 contract; identity-enrichment encapsulates it.
- **Anonymous handling:** When F4 returns customer_id=null, identity-enrichment returns null so orchestrator can pass empty profile and non-personal engine call.
- **Consent:** F4 returns consent_ok; if policy is to not use customer_id when consent_ok=false, identity-enrichment returns null so no personalization is used.

## 4. Trigger Conditions

- **Request-time:** Invoked once per recommendation request by request-orchestration, immediately after validation and before F7/F8 calls.

## 5. Inputs

- **From request:** session_id (optional), customer_id (optional), channel (required). user_id may be available from auth context if gateway injects it.

## 6. Outputs

- **customer_id:** string \| null. Canonical customer ID when resolved and (per policy) consent_ok; null when anonymous or consent not ok.
- Optional: **confidence**, **consent_ok** for logging or debugging; orchestrator typically needs only customer_id.

## 7. Workflow / Lifecycle

1. Receives (session_id?, customer_id?, channel) from orchestrator.
2. If no session_id and no customer_id: return customer_id=null (anonymous).
3. If customer_id provided and policy is “trust channel”: return customer_id (optional: still call F4 for consent_ok and return null if false).
4. Else: call F4 POST /identity/resolve with session_id, user_id (if from auth), channel, use_case=recommendations, optional region.
5. Map F4 response: if customer_id present and consent_ok (or policy allows): return customer_id; else return null.
6. On F4 timeout or 5xx: return null (fail open to anonymous) so recommendation request still returns 200 with non-personal results.

## 8. Business Rules

- **Anonymous:** Missing session_id and customer_id, or F4 returns customer_id=null or reason=anonymous → return null.
- **Consent:** If F4 returns consent_ok=false, return null so profile and engine do not use personalized data for that use case.
- **Fail open:** When F4 is unavailable, return null and log/alert; do not block recommendation response.

## 9. Configuration Model

- **Trust customer_id from channel:** When true (e.g. clienteling), use request customer_id without resolve; when false, always call F4. Optional: always call F4 for consent_ok even when customer_id provided.
- **Timeout:** F4 resolve call timeout (e.g. 50 ms); on timeout return null.
- **Default region:** For F4 resolve when request does not include region.

## 10. Data Model

- No persistent data. Input/output transient. Reads from F4 (resolve-api).

## 11. API Endpoints

- No external API. Internal step called by request-orchestration. Calls F4 POST /identity/resolve.

## 12. Events Produced

- None. Optional: metric (resolved vs anonymous rate).

## 13. Events Consumed

- None.

## 14. Integrations

- **F4 resolve-api:** Primary dependency. Request: session_id, user_id?, channel, use_case=recommendations, region?. Response: customer_id, confidence, consent_ok, reason.
- **Orchestrator:** Consumes output (customer_id) for F7 and F9.

## 15. UI Components

- None.

## 16. UI Screens

- None.

## 17. Permissions & Security

- **F4 call:** Service-to-service auth. Do not log session_id or customer_id in plain text in logs.
- **Output:** customer_id is sensitive; only passed to F7/F9 internally; not in API response to channel (response has no PII per parent spec).

## 18. Error Handling

- **F4 400:** Invalid request; identity-enrichment should not pass invalid input; if F4 returns 400, log and return null.
- **F4 503 / timeout:** Return null; log and optional alert. Request continues with anonymous path.
- **No identifier:** Return null; no call to F4.

## 19. Edge Cases

- **Both session_id and customer_id present:** Call F4 with both; F4 returns resolved customer_id (may match or merge); use F4 response.
- **customer_id from channel (clienteling):** If trust_channel=true, return customer_id; else still call F4 for consent_ok.
- **F4 returns same customer_id for different session_ids:** Normal; return customer_id.

## 20. Performance Considerations

- **Latency:** Single F4 call; must complete within orchestration budget. Use F4 cache (identity-cache) so most requests are fast.
- **Timeout:** Short (e.g. 50 ms) so orchestration can proceed to fallback if F4 is slow.

## 21. Observability

- **Metrics:** Call count; F4 latency; resolved vs null rate; F4 error/timeout rate.
- **Logs:** Do not log identifiers; log request_id, resolved (true/false), F4 status.

## 22. Example Scenarios

- **Web with session:** session_id=s1, channel=webstore → F4 resolve(s1, …) → customer_id=c1, consent_ok=true → return c1.
- **Web anonymous:** session_id=s2 only, no link → F4 returns null → return null.
- **Clienteling with customer_id:** customer_id=c3, channel=clienteling, trust_channel=true → return c3 without calling F4 (or call F4 for consent only).

## 23. Implementation Notes

- **Backend:** Module or step in Delivery API service; HTTP client to F4 or shared library. No DB, no jobs, no frontend.
- **Database:** None.
- **Jobs:** None.
- **External APIs:** F4 only (internal).
- **Frontend:** None.

## 24. Testing Requirements

- **Unit:** No identifiers → null; F4 response mapping (customer_id+consent_ok → return customer_id or null).
- **Integration:** With real or mock F4; session_id → F4 → customer_id returned; F4 timeout → null returned; F4 consent_ok=false → null returned.
- **Contract:** Input/output contract with request-orchestration.

---

## Implementation Implications Summary

| Area | Item |
|------|------|
| Backend services | Identity-enrichment step in Delivery API; F4 resolve client. |
| Database | None. |
| Jobs | None. |
| External APIs | F4 resolve-api. |
| Frontend | None. |
