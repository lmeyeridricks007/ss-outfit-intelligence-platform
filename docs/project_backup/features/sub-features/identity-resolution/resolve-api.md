# Sub-Feature: Resolve API (Identity Resolution)

**Parent feature:** F4 — Identity Resolution (`docs/features/identity-resolution.md`)  
**BR(s):** BR-2, BR-12  
**Capability:** Request-time resolution of session/user/email/POS identifiers to canonical customer_id.

---

## 1. Purpose

Expose a **request-time API** that accepts one or more identity signals (session_id, user_id, email_id, pos_customer_id) and returns the **canonical customer_id**, **confidence**, and **consent_ok** for a given use case and channel. Enables F2 (event enrichment), F7 (profile lookup), and F11 (recommendation request context) to obtain a stable customer identity without implementing resolution logic.

## 2. Core Concept

A **synchronous resolve endpoint** that:
- Accepts identity signals and optional context (channel, region, use_case).
- Looks up the identity link table (and optional cache) to determine customer_id.
- Applies consent checks for the requested use_case/region.
- Returns either a resolved customer_id with confidence and consent_ok, or anonymous (customer_id null, reason).

## 3. User Problems Solved

- **Backend services (F2, F7, F11):** Single call to get customer_id for a request; no duplicate resolution logic.
- **Attribution and profile:** Consistent customer_id across events and recommendation requests.
- **Compliance:** Caller receives consent_ok so downstream can avoid personalization when not permitted.

## 4. Trigger Conditions

- **Request-time:** Every call is triggered by an incoming request from a consumer (F11 gateway, F2 enrichment job, F7 profile read). No scheduled or event-driven trigger for the API itself.

## 5. Inputs

| Input | Type | Required | Description |
|------|------|----------|-------------|
| session_id | string | No | Anonymous or first-party session identifier (e.g. from cookie). |
| user_id | string | No | Authenticated user ID from auth provider (e.g. after login). |
| email_id | string | No | Email or hashed email identifier from CRM/email system. |
| pos_customer_id | string | No | POS or store system customer ID. |
| channel | string | Yes | webstore \| email \| clienteling. |
| use_case | string | Yes | recommendations \| clienteling_profile \| analytics (per F22). |
| region | string | No | Region/locale for consent (e.g. EU). |

At least one of session_id, user_id, email_id, pos_customer_id must be provided.

## 6. Outputs

| Output | Type | Description |
|--------|------|-------------|
| customer_id | string \| null | Canonical customer ID when resolved; null when anonymous or consent not ok. |
| confidence | number | 0–1; resolution confidence (e.g. 1.0 deterministic, &lt;1 probabilistic). |
| consent_ok | boolean | Whether use of customer_id is permitted for this use_case/region. |
| reason | string | Optional: "anonymous" \| "consent_required" \| "no_link" when customer_id is null. |

## 7. Workflow / Lifecycle

1. **Receive** POST /identity/resolve with body (identity signals + channel, use_case, optional region).
2. **Validate** input (at least one identifier; channel and use_case present).
3. **Lookup** link table (and/or cache) by identifiers; resolve to customer_id and confidence.
4. **Consent check** (sub-feature consent-check): for customer_id, use_case, region → consent_ok.
5. **Respond** 200 with customer_id (or null), confidence, consent_ok, optional reason.
6. No persistent state change in this sub-feature; read-only resolution.

## 8. Business Rules

- Do not create customer_id in this API; creation/merge is in link-management. Resolve only returns existing links.
- If no link exists for any identifier, return customer_id: null, reason: "anonymous".
- If link exists but consent_ok is false, return customer_id: null (or filtered per policy), reason: "consent_required".
- Confidence must be in [0, 1]; expose as returned by link store.

## 9. Configuration Model

- **Feature flags:** Optional kill switch to always return anonymous (e.g. for incident).
- **Default region:** If region not provided, use platform default for consent check.
- **Validation:** Reject request if channel or use_case missing (400).

## 10. Data Model

- **Request (transient):** See Inputs table; not persisted by resolve API.
- **Response (transient):** customer_id, confidence, consent_ok, reason; not persisted by API.
- **Reads from:** identity link table (customer_id, source_system, source_id, confidence, status); consent store (per consent-check sub-feature); optional cache (identity-cache sub-feature).

## 11. API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /identity/resolve | Resolve identity signals to customer_id, confidence, consent_ok. |

**Example request:**

```http
POST /identity/resolve
Content-Type: application/json

{
  "session_id": "sess-abc-123",
  "user_id": "auth-456",
  "channel": "webstore",
  "use_case": "recommendations",
  "region": "US"
}
```

**Example response (resolved):**

```json
{
  "customer_id": "cust-789",
  "confidence": 1.0,
  "consent_ok": true
}
```

**Example response (anonymous):**

```json
{
  "customer_id": null,
  "confidence": 0,
  "consent_ok": false,
  "reason": "anonymous"
}
```

## 12. Events Produced

- None. Synchronous read-only API. Optional: emit IdentityResolved (customer_id, request_key) for caching or analytics; if implemented, schema must exclude PII.

## 13. Events Consumed

- None required for request-time resolve. Optional: consume UserLoggedIn or ConsentUpdated to invalidate cache (see identity-cache).

## 14. Integrations

- **Link store:** Read identity links (link-management sub-feature or shared DB).
- **Consent check:** Call consent-check sub-feature or consent store (F22).
- **Cache:** Read/write optional (identity-cache sub-feature).
- **Consumers:** F11 (orchestration), F2 (enrichment), F7 (profile key).

## 15. UI Components

- None. Internal API only; no user-facing UI.

## 16. UI Screens

- None. Operational dashboards (e.g. latency, error rate) may display resolve API metrics; see Observability.

## 17. Permissions & Security

- **Access:** Internal only. Callable by backend services (F11, F2, F7) or API gateway; not exposed to public internet.
- **Auth:** Service-to-service auth (e.g. API key, mTLS) as per technical architecture.
- **PII:** Do not log request body with raw email or PII; log only hashed or request_id. Response has no PII (only customer_id and flags).

## 18. Error Handling

| Condition | HTTP | Response body / behavior |
|-----------|------|---------------------------|
| Missing channel or use_case | 400 | { "error": "missing_required", "field": "channel" \| "use_case" } |
| No identifier provided | 400 | { "error": "at_least_one_identifier_required" } |
| Link store unavailable | 503 or 200 | 503 with retry; or 200 with customer_id: null, reason: "anonymous" (fail open per parent spec) |
| Consent store unavailable | 503 or 200 | Policy: fail open (return consent_ok: false) or 503; document in config. |

## 19. Edge Cases

- **All identifiers null/empty:** Return 400.
- **Multiple identifiers point to different customer_ids:** Use merge/precedence rules from link-management (e.g. logged-in > email); return single customer_id.
- **Link exists but status unlinked:** Treat as no link; return anonymous.
- **Cache hit with stale consent:** Use TTL on cache; or cache key includes use_case+region and consent checked on read.

## 20. Performance Considerations

- **Latency:** p95 &lt; 50–100 ms so F11 request path is not blocked (per parent F4 NFR).
- **Caching:** Use identity-cache sub-feature (session_id → customer_id, TTL) to reduce link store and consent lookups.
- **Parallelism:** Single lookup; no heavy compute in resolve path.

## 21. Observability

- **Metrics:** Request count, latency (p50/p95/p99), error rate (4xx, 5xx), anonymous rate (customer_id null), consent_ok false rate.
- **Logs:** Request_id, channel, use_case; do not log identifiers or PII. Log 400/503 for debugging.
- **Alerts:** Latency &gt; threshold; error rate spike; dependency (link store, consent) failure.

## 22. Example Scenarios

**Scenario A — Logged-in web user:**  
Request: session_id=s1, user_id=u1, channel=webstore, use_case=recommendations.  
Link table: (user_id=u1 → customer_id=c1, confidence=1.0). Consent ok.  
Response: customer_id=c1, confidence=1.0, consent_ok=true.

**Scenario B — Anonymous session:**  
Request: session_id=s2 only, channel=webstore, use_case=recommendations.  
No link for s2.  
Response: customer_id=null, confidence=0, consent_ok=false, reason="anonymous".

**Scenario C — Consent withdrawn:**  
Request: session_id=s3, user_id=u3, channel=webstore, use_case=recommendations.  
Link: user_id=u3 → customer_id=c3. Consent check: false for recommendations.  
Response: customer_id=null (or c3 with consent_ok=false per policy), reason="consent_required".

## 23. Implementation Notes

- **Backend service:** Resolve API can be part of identity service or API gateway sidecar. Must call link store and consent check (or inline consent logic).
- **Database:** No tables owned by this sub-feature; reads link table and consent store.
- **Jobs/workers:** None.
- **External APIs:** None; internal only.
- **Frontend:** None.
- **Shared:** Align with data-standards (canonical customer_id, confidence); domain model (Customer, identity links).

## 24. Testing Requirements

- **Unit:** Validation (missing channel/use_case → 400; no identifier → 400); response shape for resolved vs anonymous.
- **Integration:** With real or mocked link store and consent store; verify 200 + customer_id when link exists and consent ok; 200 + null when no link or consent_ok false.
- **Contract:** Publish request/response schema; consumer (e.g. F11) contract test.
- **Failure:** Mock link store down; verify 503 or 200-with-anonymous per config.

---

## Example: Database records read (conceptual)

Link table row used for resolve:

| customer_id | source_system | source_id | confidence | status |
|-------------|---------------|-----------|------------|--------|
| cust-789 | auth | auth-456 | 1.0 | active |

Consent store (per F22): (customer_id=cust-789, use_case=recommendations, region=US) → allowed=true.

---

## Implementation Implications Summary

| Area | Item |
|------|------|
| Backend services | Resolve API handler (part of identity service or gateway); link store client; consent check client. |
| Database tables | None owned; reads identity link table, consent store. |
| Jobs/workers | None. |
| External APIs | None. |
| Frontend | None. |
| Shared UI | None. |
