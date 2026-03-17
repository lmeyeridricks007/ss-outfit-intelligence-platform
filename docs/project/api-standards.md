# API Standards

**Purpose:** Cross-cutting standards for API design, versioning, errors, and authentication. Apply to all platform APIs consumed by channels or internal services; primary reference for the Delivery API (F11) and future public/internal APIs.  
**Source:** Business requirements (BR-7), architecture overview, domain model, Delivery API feature spec.  
**Traceability:** Referenced by feature specs (e.g. `docs/features/delivery-api.md`), technical architecture, and implementation.  
**Status:** Living document; update when contract or security expectations change.  
**Review:** Standards-stage artifact; assess per `docs/project/review-rubrics.md`.  
**Approval mode:** HUMAN_REQUIRED for material changes to API contract or auth expectations.

---

## Related Documents

- **Domain model:** `docs/project/domain-model.md` — Recommendation Request, Recommendation Result, canonical identifiers.
- **Standards:** `docs/project/standards.md` — lifecycle, promotion, naming.
- **Technical architecture:** Defines concrete auth mechanism (e.g. gateway, API key store); this doc states expectations.

---

## 1. API Design

### Principles

1. **Capability-oriented:** APIs must reflect business capabilities, not internal implementation. Consumers depend on stable, documented contracts.
2. **Explainability:** Recommendation responses must support downstream debugging and analytics (e.g. reason codes, source mix, set ID, trace ID).
3. **Channel-agnostic core:** One logical contract for all channels; channel-specific formatting (e.g. image URLs for email) is optional and documented per channel when used. Do not duplicate recommendation logic per channel.
4. **Stateless:** APIs are stateless request/response; no server-side session requirement beyond what is needed for auth and rate limiting.
5. **No PII in response:** Responses must not contain customer name, email, or other PII. Request may carry customer_id or session_id for resolution; do not log PII.

### Recommendation response (Delivery API and similar)

Every recommendation response must include:

- **Request context echo** — placement, channel, anchor (or equivalent) so the client can correlate response to request.
- **Recommendation set ID** — stable identifier for this response; required for attribution (F12).
- **Trace ID** — identifier for this request/response; required for attribution and debugging.
- **Recommendation type** — e.g. outfit, cross-sell, upsell, style_bundle, contextual, personal.
- **Ranked items or looks** — array of product_id or look_id with optional reason_code and source.
- **Reason/source** — enough for explainability and analytics; need not expose sensitive reasoning.

### Readiness criteria

An API artifact is not implementation-ready until it defines:

- **Consumers** — who calls the API (channels, services).
- **Request and response** — contract (fields, types, examples) and optional OpenAPI snippet.
- **Authentication expectations** — see §4; details in technical architecture.
- **Dependency requirements** — upstream services and failure behavior.
- **Latency assumptions** — target (e.g. p95) and fallback when exceeded.
- **Fallback behavior** — what is returned on dependency failure or empty result (e.g. 200 with fallback body, not 500 for “no recommendations” where applicable).

---

## 2. Versioning

- **Where to version:** Prefer **URL path** (e.g. `/v1/recommendations`) or **Accept/API-Version header**. Choose one scheme and document it; use consistently across platform APIs.
- **When to bump:** Bump major version when the contract changes in a **backward-incompatible** way (e.g. removing or renaming required fields, changing semantics). Additive changes (optional fields, new endpoints) may stay in the same version; document in changelog.
- **Backward compatibility:** Within a major version, do not remove or rename existing request/response fields. Deprecate with notice and a sunset version; document in API spec and release notes.
- **Default version:** If clients omit version, define default (e.g. latest stable v1); document in API spec.

---

## 3. Errors

### HTTP status usage

| Status | Use when |
|--------|----------|
| **200 OK** | Success; body contains full response. Also use for “success with fallback” (e.g. recommendations returned with fallback_used) so clients can always log set_id/trace_id. Do not use 500 for “no recommendations” when fallback or empty list is valid. |
| **400 Bad Request** | Invalid request (missing required field, invalid value, invalid placement). Body should include machine-readable error code and optional message. Do not call engine for invalid placement. |
| **401 Unauthorized** | Missing or invalid auth (e.g. API key, token). |
| **403 Forbidden** | Authenticated but not authorized for this resource or action. |
| **429 Too Many Requests** | Rate limit exceeded. Include `Retry-After` header when applicable. Optional per API. |
| **503 Service Unavailable** | API or critical dependency temporarily unavailable. Prefer returning 200 with fallback body for recommendation APIs when policy is fail-open; use 503 when the API cannot fulfill the request at all. |
| **5xx** | Use sparingly; prefer 200 + fallback or 503 so clients can degrade gracefully. Do not 504 for “no recommendations” unless policy is to fail closed. |

### Error response shape

Use a consistent structure for 4xx and 5xx:

- **error** — machine-readable code (e.g. `missing_required`, `invalid_placement`, `rate_limit_exceeded`).
- **message** — optional human-readable description (no PII).
- **field** — optional; which request field caused the error (e.g. `placement`, `channel`).
- **request_id** or **trace_id** — optional; for support and logs.

Example (400):

```json
{
  "error": "invalid_placement",
  "message": "Placement is required and must be one of: pdp_complete_the_look, cart, homepage, ...",
  "field": "placement"
}
```

Example (429):

```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests; retry after the value in Retry-After header."
}
```

Clients should use `error` for branching; do not rely only on `message` for logic.

### Client handling

- **4xx:** Client should not retry without changing the request (fix validation, auth, or rate).
- **429:** Retry after `Retry-After` or with backoff.
- **5xx / 503:** Retry with backoff; optional fallback UI (e.g. hide widget or show static content).

---

## 4. Authentication

- **Responsibility:** Authentication and authorization are enforced at the **API gateway** or at the API boundary. The API assumes the request is already authenticated; details (API key, OAuth, mTLS) are defined in **technical architecture**.
- **Expectation:** All requests to public or channel-facing APIs must be **authenticated** (e.g. API key per channel, or token). Reject unauthenticated requests with **401 Unauthorized**.
- **No credentials in API contract:** This doc does not mandate a specific auth scheme; technical architecture will specify (e.g. API key in header, token in Authorization header). API specs must document the auth requirement and where to obtain credentials.
- **Authorization (optional):** Gateway or API may restrict which placements or channels a client can call (e.g. clienteling key only for clienteling placement). Document per API. Customer-level auth (who the recommendation is for) is data in the request, not the identity of the caller.
- **Logging:** Do not log request body or headers that contain credentials or PII. Log request_id, trace_id, placement, channel, and error codes for debugging; mask or hash customer_id in logs when required by policy.

---

## 5. References

- **Domain model:** `docs/project/domain-model.md`
- **Delivery API spec:** `docs/features/delivery-api.md`
- **Standards:** `docs/project/standards.md`
- **Review rubrics:** `docs/project/review-rubrics.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** API standards (this document).  
**Stage:** Standards / API contract and security.  
**Approval mode:** HUMAN_REQUIRED for material changes.

### Overall disposition

**Eligible for promotion.** The API standards doc covers API design, versioning, errors, and auth; it aligns with the Delivery API spec and domain model. All dimensions score 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL** for material changes to this doc.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Scope, intent, and structure (design, versioning, errors, auth) are clear. Principles and tables are easy to follow. |
| **Completeness** | 5 | API design (principles, recommendation response, readiness); versioning (where, when, compatibility); errors (status usage, response shape, client handling); auth (gateway, expectation, no PII in logs). Dependencies and edge cases (fallback vs 5xx, 429) covered. |
| **Implementation Readiness** | 5 | Implementers and technical architecture can derive contracts, error handling, and auth placement from this doc. |
| **Consistency With Standards** | 5 | Aligns with domain model (Recommendation Request/Result), Delivery API spec (F11), and project standards; terminology consistent. |
| **Correctness Of Dependencies** | 5 | References to domain model, Delivery API, technical architecture, and review-rubrics are accurate; no incorrect claims. |
| **Automation Safety** | 5 | N/A for API design doc; doc does not assert approval or completion of any board item. |

**Average:** 5.0. **Minimum dimension:** 5.

### Confidence rating

**HIGH.** Inputs (BR-7, architecture, Delivery API spec) are stable; scope is clear; standards are actionable for design and implementation.

### Blocking issues

**None.**

### Recommended edits

**None required.** When technical architecture defines the concrete auth mechanism, add a one-line pointer from this doc (e.g. “See technical architecture §X for API key and gateway configuration”).

### Explicit recommendation

Based on approval mode **HUMAN_REQUIRED:** the artifact should move to **READY_FOR_HUMAN_APPROVAL** (not direct APPROVED, not CHANGES_REQUESTED). It is suitable as the API standards reference; material changes to contract, versioning, error shape, or auth expectations require review and human approval before adoption.

### Propagation to upstream

**None required.** No human rejection comments. If the Delivery API or domain model changes in a way that affects these standards, update this doc.

### Pending confirmation

Before completion (adoption of any material change to this doc): **human approval** is required. When technical architecture is written, **alignment** with the concrete auth mechanism (and a cross-reference from this doc) must be confirmed. No GitHub Actions or merge dependency for this artifact.
