# Sub-Feature: Identity Cache (Identity Resolution)

**Parent feature:** F4 — Identity Resolution (`docs/features/identity-resolution.md`)  
**BR(s):** BR-2  
**Capability:** Cache resolution results (e.g. session_id → customer_id) to meet latency NFR and reduce link store load.

---

## 1. Purpose

Cache the **result of identity resolution** (e.g. session_id → customer_id, confidence, consent_ok) with a **TTL** so repeated requests from the same session do not hit the link store and consent check on every call. Enables resolve-api to meet p95 &lt; 50–100 ms and reduces load on identity and consent stores.

## 2. Core Concept

A **cache layer** (in-memory, Redis, or similar) keyed by request identity (e.g. session_id + channel + use_case, or session_id only) storing: customer_id, confidence, consent_ok, optional timestamp. Resolve-api reads cache first; on miss, performs full resolve and writes cache. Invalidated on link add/merge/unlink and optionally on ConsentUpdated.

## 3. User Problems Solved

- **Latency:** Sub-millisecond cache hit for hot sessions; F11 request path stays within SLA.
- **Availability:** Reduces dependency on link store for every request.
- **Load:** Fewer reads to link table and consent store.

## 4. Trigger Conditions

- **Read:** Every resolve-api request checks cache by cache key (e.g. session_id + use_case + region).
- **Write:** On resolve-api miss, after successful resolve, write (key → customer_id, confidence, consent_ok) with TTL.
- **Invalidate:** On link-management add/merge/unlink; optionally on ConsentUpdated.

## 5. Inputs

- **Cache key:** Derived from (session_id, use_case, region) or (session_id) to balance granularity vs hit rate. Must include use_case if consent differs per use case.
- **Value to store:** customer_id, confidence, consent_ok; optional created_at.

## 6. Outputs

- **Cache hit:** Return cached customer_id, confidence, consent_ok; skip link store and consent check.
- **Cache miss:** Return null; resolve-api continues to full resolve and then populates cache.

## 7. Workflow / Lifecycle

1. Resolve-api receives request → build cache key.
2. Cache get(key). If hit and not expired → return cached value; done.
3. If miss → run link lookup + consent check → on success, cache set(key, value, TTL) → return value.
4. On link-management or consent update → invalidate keys that may include affected customer_id or session_id (e.g. by pattern or by maintaining session_id → key index). Exact invalidation strategy per implementation (e.g. TTL-only, or event-driven invalidate).

## 8. Business Rules

- **TTL:** Short enough to respect consent changes quickly (e.g. 5–15 min); long enough to reduce load. Document in config.
- **Stale consent:** If cache does not include use_case/region in key, consent withdrawal may be visible only after TTL expiry unless invalidate on ConsentUpdated is implemented.
- **No PII in key/value:** Key = session_id (opaque) or hash; value = customer_id and flags only.

## 9. Configuration Model

- **TTL:** Seconds (e.g. 300–900). Per environment.
- **Cache key schema:** session_id only vs session_id + use_case + region.
- **Invalidation:** Enable/disable invalidation on link/consent events; pattern for delete (e.g. session:*).

## 10. Data Model

- **Cache entry (ephemeral):** key (string), value (JSON: customer_id, confidence, consent_ok), expires_at. No persistent DB; cache store only.

## 11. API Endpoints

- No external API. Internal cache get/set/delete used by resolve-api and link-management (or event handler).

## 12. Events Produced

- None. Optional: cache hit/miss metrics.

## 13. Events Consumed

- **IdentityLinkAdded, IdentityMerged, IdentityUnlinked** (from link-management): Invalidate cache for affected session_ids or customer_ids. May require maintaining session_id → keys index or pattern delete.
- **ConsentUpdated:** Invalidate cache for that customer_id (all keys that could return that customer_id).

## 14. Integrations

- **Resolve-api:** Primary consumer (read-through); populates on miss.
- **Link-management:** Triggers invalidation (or shared cache client).
- **Consent (F22):** Optional invalidation on ConsentUpdated.
- **Cache store:** Redis, Memcached, or in-process LRU per technical architecture.

## 15. UI Components

- None.

## 16. UI Screens

- None. Optional: cache hit rate, eviction count in ops dashboard.

## 17. Permissions & Security

- **Access:** Same as resolve-api; cache is internal. Keys must not contain PII.
- **Encryption:** Cache at rest if required by policy (e.g. Redis TLS).

## 18. Error Handling

- **Cache unavailable:** Resolve-api falls back to full resolve (no cache); log and alert. Do not fail request.
- **Invalidation failure:** Log; rely on TTL to expire stale entries. Optional retry.

## 19. Edge Cases

- **Same session, different use_case:** If key includes use_case, separate entries; consent_ok can differ per use_case.
- **Merge:** Two session_ids previously mapped to two customer_ids; after merge, invalidate both session keys so next resolve returns merged customer_id.
- **Clock skew:** Use TTL from write time; no dependency on client clock.

## 20. Performance Considerations

- **Latency:** Cache get &lt; 1–2 ms p99. TTL and key design to balance hit rate vs freshness.
- **Memory:** Size limit and eviction policy (e.g. LRU) to avoid unbounded growth.

## 21. Observability

- **Metrics:** Hit rate, miss rate, latency (get/set), invalidation count, cache store errors.
- **Alerts:** Cache down → resolve-api degrades but continues; alert for investigation.

## 22. Example Scenarios

- **First request for session s1:** Cache miss → resolve → customer_id=c1, consent_ok=true → cache set(s1+use_case, value, 600s) → return.
- **Second request same session:** Cache hit → return c1, consent_ok=true without link store call.
- **User withdraws consent:** ConsentUpdated → invalidate keys for c1 → next request for s1 cache miss → resolve → consent_ok=false → cache set with new value.

## 23. Implementation Notes

- **Backend:** Cache client in resolve-api service; optional separate invalidation listener (subscriber to link/consent events).
- **Database:** None; cache store only (Redis/Memcached).
- **Jobs:** None (or optional periodic warm-up for high-value sessions; out of scope for MVP).
- **External APIs:** None.
- **Frontend:** None.

## 24. Testing Requirements

- **Unit:** Key generation; TTL applied; value serialization.
- **Integration:** Resolve with cache on → hit then miss (different session); invalidate → next resolve gets fresh consent.
- **Failure:** Cache down → resolve still returns correct result via full path.
