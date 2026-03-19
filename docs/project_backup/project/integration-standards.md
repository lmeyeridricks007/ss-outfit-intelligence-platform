# Integration Standards

**Purpose:** Cross-cutting standards for integrations: **external (runtime)** systems (auth, retries, idempotency) and **delivery process** (GitHub, Cursor, CI). Apply to all outbound/inbound calls to third-party or external systems (catalog, OMS, CRM, POS, email, event ingest, Delivery API consumers) and to the tooling that governs delivery.  
**Source:** Business requirements, architecture overview, API standards, behavioral event ingestion (F2), recommendation telemetry (F12), event ingest and approval-workflow sub-features.  
**Traceability:** Referenced by feature specs, technical architecture, and implementation; aligns with `docs/project/api-standards.md` for API auth.  
**Status:** Living document; update when integration, auth, or retry expectations change.  
**Review:** Standards-stage artifact; assess per `docs/project/review-rubrics.md`.  
**Approval mode:** HUMAN_REQUIRED for material changes to auth, retry, or idempotency expectations.

---

## Related Documents

- **API standards:** `docs/project/api-standards.md` — API auth, errors, client handling (retry for 429/5xx).
- **Data standards:** `docs/project/data-standards.md` — event schema, event_id for deduplication.
- **Standards:** `docs/project/standards.md` — lifecycle, promotion, naming.
- **Review rubrics:** `docs/project/review-rubrics.md` — scoring, thresholds, required review output.

---

## 1. Integration Principles

1. **Contract-driven:** Integrations should be **contract-driven and documented** before build. Define request/response (or message schema), auth, and failure behavior in the spec or technical architecture.
2. **Human approval gates:** Human approval gates should protect **business-sensitive changes** (e.g. campaign activation, rule publication, live widget rollout). See §4 (Human Approval Expectations).
3. **Explicit scope:** Distinguish **runtime integrations** (catalog, OMS, CRM, POS, email, event ingest, Delivery API) from **delivery process integrations** (GitHub, Cursor, GitHub Actions). Both must be explicit and documented.

---

## 2. External (Runtime) Integrations: Auth, Retries, Idempotency

These standards apply to **outbound** calls from the platform to external systems (catalog, OMS, CRM, POS, context providers) and to **inbound** calls from external systems or channels to the platform (event ingest, Delivery API, profile, telemetry).

### 2.1 Authentication

**Inbound (callers to the platform)**

- All **sensitive or mutation** endpoints must require **authentication**. Reject unauthenticated requests with **401 Unauthorized**. See API standards (§4) for channel-facing APIs (e.g. Delivery API, event ingest).
- **Event ingest:** API key or token for sources; no public unauthenticated ingest. Use a backend-for-frontend or server-side proxy for web-originated events so credentials are not exposed. See F2, F12.
- **Credentials:** Do not log or expose credentials (API keys, tokens) in requests or responses. Technical architecture defines where credentials are stored (e.g. secrets manager, gateway config).

**Outbound (platform calling external systems)**

- Use the **auth mechanism required by the external system** (API key, OAuth, mTLS, or service account). Document per integration in the feature spec or technical architecture.
- **Secrets:** Credentials for outbound calls must not live in code or in plain text in config; use a secrets store or environment-specific config that is not committed. Rotate on compromise or per policy.
- **Least privilege:** Request only the scopes or permissions needed for the integration (e.g. read-only for catalog sync where possible).

**Summary**

| Direction | Expectation |
|-----------|-------------|
| Inbound to platform | Authenticate all sensitive/mutation endpoints; 401 when missing/invalid; no unauthenticated public ingest for events. |
| Outbound from platform | Use external system’s required auth; secrets in secure store; document per integration. |

### 2.2 Retries

**When to retry**

- **Retry** on **transient** failures: **5xx**, **503 Service Unavailable**, **429 Too Many Requests**, and **timeouts** (when the operation is safe to retry). Use **Retry-After** header when the server provides it (e.g. 429).
- **Do not retry** (without changing the request) on **4xx** (except 429): e.g. 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found. Client must fix the request or credentials.
- **Idempotency:** Retry only when the operation is **idempotent** or when the client sends an **idempotency key** and the server supports deduplication. See §2.3.

**How to retry**

- **Backoff:** Use **exponential backoff** (or honor **Retry-After**) to avoid overwhelming the dependency. Document max attempts and backoff policy per integration (e.g. max 3 retries, 1s / 2s / 4s).
- **Timeout:** Set a **per-call timeout** and a **total budget** for retries so the caller (e.g. Delivery API) can meet its SLA or fall back.
- **Circuit breaker (optional):** For repeatedly failing dependencies, consider a circuit breaker (stop calling for a period, then probe) so one failing system does not cascade. Document in technical architecture where applied.
- **Dead-letter:** For async flows (e.g. event ingest), failed messages after max retries should go to **dead-letter** or quarantine with alert; do not drop silently. See F2, F12.

**Client handling (callers to our APIs)**

- **429:** Retry after **Retry-After** or with backoff. See API standards (§3).
- **5xx / 503:** Retry with backoff; optional fallback UI (e.g. hide widget or show static content). Do not retry indefinitely; cap attempts and then degrade.

### 2.3 Idempotency

**Mutations (create/update/delete)**

- **Client-supplied idempotency key:** For APIs that perform **mutations** (e.g. create event, create link, submit for approval), support an **idempotency key** (e.g. header `Idempotency-Key: <key>`) so the same key sent twice results in one logical operation. Server returns the same response for duplicate keys (e.g. 200 with same body, or 409 if policy is to reject duplicate).
- **At-least-once delivery:** When the transport guarantees at-least-once (e.g. message queue), **consumers must be idempotent**: detect duplicates (e.g. by event_id or idempotency key) and apply the operation once (e.g. 200 idempotent for duplicate event).

**Event ingest**

- **event_id:** Ingest accepts an optional **event_id** (or correlation_id) from the client for **deduplication**. Duplicate event_id within the defined window → **200 OK** with same ack (idempotent); do not double-write to the stream. See data standards (event_id), F2 event ingest.
- **Validation failure** → 400; **duplicate (idempotency key / event_id)** → 200 idempotent; **downstream unavailable** → retry or dead-letter. See event-ingest sub-feature §18.

**Summary**

| Scenario | Expectation |
|----------|-------------|
| Mutations (platform API) | Support idempotency key where applicable; same key → same response, single side effect. |
| At-least-once consumers | Idempotent handling: dedupe by event_id or key; no double apply. |
| Event ingest | Accept event_id for dedup; duplicate → 200 idempotent; document window/ttl per spec. |

---

## 3. Delivery Process Integrations

These are **non-runtime** integrations that govern how work is designed, reviewed, and promoted. They are separate from catalog, OMS, CRM, and recommendation APIs.

- **GitHub** as source of truth for repo history, pull requests, issues, and approvals.
- **Cursor Cloud Agents** for stage-based artifact generation and review support.
- **Cursor Automations** for event-driven and scheduled workflow assistance where appropriate.
- **GitHub Actions** for deterministic CI, merge-aware transitions, and safety checks.

Contract and behavior for these are defined in the agent operating model, boards README, and automation-safety rules; this doc only states that they are explicit delivery-process integrations.

---

## 4. Human Approval Expectations

- No integration that **changes customer-visible recommendation behavior** should be considered production-ready without **approved upstream artifacts** (e.g. BRs, feature spec, architecture).
- **High-risk integrations** such as campaign activation, live widget rollout, and rule publication require **human approval evidence** (e.g. READY_FOR_HUMAN_APPROVAL → APPROVED per standards).
- Approval workflows (F21) and audit (F22) apply to business-sensitive changes; see feature specs and project standards.

---

## 5. References

- **API standards:** `docs/project/api-standards.md`
- **Data standards:** `docs/project/data-standards.md`
- **Behavioral event ingestion:** `docs/features/behavioral-event-ingestion.md`
- **Event ingest sub-feature:** `docs/features/sub-features/behavioral-event-ingestion/event-ingest.md`
- **Recommendation telemetry:** `docs/features/recommendation-telemetry.md`
- **Approval workflows:** `docs/features/approval-workflows-and-audit.md`
- **Review rubrics:** `docs/project/review-rubrics.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Integration standards (this document).  
**Stage:** Standards / external integrations (auth, retries, idempotency).  
**Approval mode:** HUMAN_REQUIRED for material changes.  
**Review source:** Direct invocation (independent review against review-rubrics).

### Overall disposition

**Eligible for promotion.** The integration standards doc covers integration principles, external runtime integrations (auth inbound/outbound, retries when/how, idempotency for mutations and event ingest), delivery process integrations, and human approval expectations. It aligns with API standards, data standards, F2, F12, and event-ingest sub-feature. All six dimensions score 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL** for material changes to this doc.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Scope (external vs delivery process), intent, and structure (principles, auth, retries, idempotency, delivery, approval) are clear. Tables and lists are easy to follow. |
| **Completeness** | 5 | Principles (contract-driven, human gates, explicit scope); auth (inbound: 401, no unauthenticated ingest, credentials; outbound: external auth, secrets, least privilege); retries (when to retry, when not, backoff, timeout, circuit breaker, dead-letter); idempotency (mutations: idempotency key; at-least-once: idempotent consumer; event ingest: event_id, duplicate→200); delivery process; human approval. Dependencies and edge cases covered. |
| **Implementation Readiness** | 5 | Feature specs and technical architecture can derive auth, retry, and idempotency behavior from this doc with limited ambiguity. |
| **Consistency With Standards** | 5 | Aligns with API standards (auth, 429/5xx retry), data standards (event_id), F2/F12, event-ingest; terminology and header/review record follow project standards. |
| **Correctness Of Dependencies** | 5 | References to API standards, data standards, F2, F12, event-ingest, approval-workflows, review-rubrics are accurate; internal cross-references (§2.3, §4) correct; retry and idempotency rules match referenced specs; no incorrect claims. |
| **Automation Safety** | 5 | Doc does not assert approval or completion of any board item; recommendation is READY_FOR_HUMAN_APPROVAL only; guardrails respected. |

**Average:** 5.0. **Minimum dimension:** 5. **Threshold:** Average > 4.1 and no dimension < 4 — **met**.

### Confidence rating

**HIGH.** Inputs (API standards, data standards, F2, F12, event-ingest) are stable; scope is clear; standards are actionable for integration design and implementation.

### Blocking issues

**None.**

### Recommended edits

**None required.** When technical architecture defines concrete retry limits (e.g. max attempts, backoff) or circuit-breaker policy per integration, add a one-line cross-reference from this doc.

### Explicit recommendation

Based on approval mode **HUMAN_REQUIRED:** the artifact should move to **READY_FOR_HUMAN_APPROVAL** (not direct APPROVED, not CHANGES_REQUESTED). It is suitable as the integration standards reference; material changes to auth, retry, or idempotency expectations require review and human approval before adoption.

### Propagation to upstream

**None required.** No human rejection comments. If API standards, data standards, or F2/F12 change in a way that affects these expectations, update this doc.

### Pending confirmation

Before completion (adoption of any material change to this doc): **human approval** is required. When technical architecture documents per-integration retry and circuit-breaker policy, **alignment** and a cross-reference from this doc should be confirmed. No GitHub Actions or merge dependency for this artifact.
