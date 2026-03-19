# Sub-Feature: Consent Check (Identity Resolution)

**Parent feature:** F4 — Identity Resolution (`docs/features/identity-resolution.md`)  
**BR(s):** BR-12  
**Capability:** Determine whether customer_id may be used for a given use_case and region (consent_ok).

---

## 1. Purpose

Provide a **consent check** used by resolve-api (and optionally F7, F11) to decide if a resolved **customer_id** is allowed for the requested **use_case** and **region**. Returns a boolean (consent_ok) so callers do not use customer_id for personalization when consent is withdrawn. F22 (privacy and consent enforcement) may own the consent store; this sub-feature is the **check** invoked at resolve time.

## 2. Core Concept

A **check function or service** that: given (customer_id, use_case, optional region), returns whether use of that customer’s data is permitted for that use case and region. Uses consent store (F22 or shared) and optional regional rules. No PII in check; only identifiers and flags.

## 3. User Problems Solved

- **Compliance:** Respect opt-out and regional rules (e.g. GDPR) before returning customer_id for personalization.
- **Resolve API:** Single place to get consent_ok for response.
- **F7/F11:** Can rely on resolve returning consent_ok so they do not need separate consent logic for recommendation use.

## 4. Trigger Conditions

- **Request-time:** Invoked by resolve-api for every resolve request that returns a customer_id (before responding).
- **Optional:** F7 profile read, F23 clienteling may call consent check directly if not using resolve.

## 5. Inputs

- customer_id (required)
- use_case (required): e.g. recommendations, clienteling_profile, analytics
- region (optional): e.g. EU, US; default from config if not provided

## 6. Outputs

- **allowed** (boolean): true if use is permitted; false if withdrawn or not granted for this use_case/region.
- Optional: **reason** (e.g. "withdrawn", "no_consent_record") for logging only.

## 7. Workflow / Lifecycle

1. Receive (customer_id, use_case, region).
2. Lookup consent store: (customer_id, use_case, region) → allowed.
3. Apply default if no record: per policy (strict = false, legacy = true with sunset).
4. Return allowed (and optional reason). No state change in this sub-feature.

## 8. Business Rules

- **Default:** If no consent record exists, policy defines default (recommend strict = false for new users).
- **Region:** Consent may differ by region; store and check per (customer_id, use_case, region) or (customer_id, use_case) with region override.
- **Use case granularity:** recommendations_personalization, email_recommendations, clienteling_profile, analytics (align with F22).

## 9. Configuration Model

- **Default when no record:** allowed = true \| false; per environment or use_case.
- **Region list:** Supported regions for consent; default_region if request omits.

## 10. Data Model

- **Reads:** Consent store (F22): (customer_id, use_case, region) → allowed (boolean). May be key-value or table.
- **No write** in this sub-feature; F22 or preference center updates store.

## 11. API Endpoints

- **Internal:** GET /identity/consent/check?customer_id=...&use_case=...&region=... → { "allowed": true \| false }. Or in-process function called by resolve-api. Not exposed publicly.

## 12. Events Produced

- None. Read-only check.

## 13. Events Consumed

- Optional: ConsentUpdated → invalidate in-memory or distributed cache if consent check result is cached.

## 14. Integrations

- **Consent store:** F22 or shared consent service.
- **Callers:** resolve-api (primary), optionally F7, F23.

## 15. UI Components

- None. Consent collection UI is out of scope (F22 / commerce).

## 16. UI Screens

- None.

## 17. Permissions & Security

- **Access:** Internal only. No PII in request/response (only customer_id and flags).
- **Audit:** Consent checks may be logged (customer_id, use_case, result) for compliance; no PII.

## 18. Error Handling

- **Consent store down:** Return allowed=false (fail closed) or 503; policy must be defined. Prefer fail closed for compliance.
- **Invalid customer_id or use_case:** Return 400 or allowed=false.

## 19. Edge Cases

- **New customer (no record):** Apply default policy.
- **Region not provided:** Use default_region for lookup.
- **Multiple use_cases in one request:** Resolve may call once per use_case or once with use_case=recommendations for F11.

## 20. Performance Considerations

- **Latency:** Check must complete within resolve-api budget (&lt;50–100 ms p95). Cache consent result per (customer_id, use_case, region) with short TTL if store is remote.
- **Availability:** Consent store should be highly available; else fail closed and document.

## 21. Observability

- **Metrics:** Check count; allowed vs denied rate; latency; consent store errors.
- **Logs:** Do not log PII; log customer_id hash or request_id, use_case, result for debugging.

## 22. Example Scenarios

- **Opt-in user:** customer_id=c1, use_case=recommendations, region=US → store (c1, recommendations, US)=true → allowed=true.
- **Opt-out user:** store (c1, recommendations, US)=false → allowed=false.
- **No record, strict default:** allowed=false.

## 23. Implementation Notes

- **Backend:** In-process library or internal HTTP call to F22 consent API. Optional cache layer.
- **Database:** None owned; reads consent store.
- **Jobs:** None.
- **External APIs:** None (consent store is internal).
- **Frontend:** None.

## 24. Testing Requirements

- **Unit:** Default policy; region fallback; allowed true/false from store.
- **Integration:** With consent store; withdraw consent → next check returns false.
- **Failure:** Consent store unavailable → allowed=false or 503 per policy.
