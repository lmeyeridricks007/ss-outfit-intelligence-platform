# Feature Deep-Dive: Identity Resolution (F4)

**Feature ID:** F4  
**BR(s):** BR-2 (Data ingestion and identity), BR-12 (Governance and safety)  
**Capability:** Resolve customer identity across channels  
**Source:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/domain-model.md`, `docs/project/data-standards.md`

---

## 1. Purpose

Merge **anonymous**, **logged-in**, **POS**, and **email** identities into a **stable customer view** (canonical `customer_id`) with **consent** respected, so behavior and preferences are recognized across touchpoints. Identity resolution enables a single **Customer Style Profile** (F7) per person and consistent attribution across web, email, and clienteling (BR-2, BR-12).

## 2. Core Concept

An **identity resolution** process (and optionally service) that:
- Receives **identity signals** from multiple sources: anonymous session IDs, logged-in user IDs, POS customer IDs, email/CRM identifiers.
- **Links** these to a canonical **customer_id** using deterministic and/or probabilistic rules, with **identity resolution confidence** recorded (per data standards).
- Respects **consent** and **regional rules** (e.g. GDPR); does not merge or expose data where consent is missing or use case is not permitted.
- Exposes **canonical customer_id** (and optionally link metadata) to **customer profile service** (F7), **delivery API** (F11), and **behavioral ingestion** (F2) for enrichment.

## 3. Why This Feature Exists

- **BR-2:** Customer identity must be resolved across anonymous, logged-in, POS, and email where technically and consent-wise feasible.
- **BR-12:** Privacy and consent must be respected; customer data use scoped to permitted use cases and regions.
- **BR-3, BR-7, BR-9:** Single profile and cross-channel recommendations require one stable identity per customer where consented.

## 4. User / Business Problems Solved

- **Returning customers:** Recognized across sessions and channels; one profile, no duplicate or fragmented history.
- **CRM / Email:** Target and attribute by same customer_id as web and clienteling.
- **Associates:** Clienteling sees same customer and profile as online.
- **Compliance:** Consent and regional boundaries enforced; audit trail for identity operations.

## 5. Scope

### 6. In Scope

- **Link identity signals** to canonical customer_id: session_id, auth user_id, POS customer_id, email_id (hashed or raw per policy). Deterministic (e.g. login) and probabilistic (e.g. device + email match) linking; **confidence score** stored.
- **Consent and scope:** Only merge and expose where consent exists for the use case (e.g. recommendation personalization) and region. **Opt-out** respected; unlink or mask when consent withdrawn.
- **Canonical ID:** Stable customer_id; first creation and merge rules (e.g. first high-confidence link wins; or create new and merge later). **Identity graph** or link table: (source_system, source_id) → customer_id, confidence, created_at, consent_flags.
- **Output:** customer_id for a given request (session_id, user_id, etc.); optional: list of linked identifiers, confidence. Consumed by F2 (enrich events), F7 (profile), F11 (request context).
- **Audit:** Log merge and unlink actions (no PII in logs; only customer_id and action type) for governance.

### 7. Out of Scope

- **Authentication** (login/signup) — owned by identity provider or commerce platform; this feature consumes auth outcomes (user_id after login).
- **Profile computation** — owned by F7; this feature only provides customer_id and link metadata.
- **PII storage** — store only identifiers and consent flags; actual PII (name, email) may live in CRM or profile store; this feature focuses on **resolution** and **linking**.

## 8. Main User Personas

- **Returning Customer, CRM, In-Store Associate** — Benefit from consistent identity across channels.
- **Compliance / Legal** — Need consent and audit.
- **Backend/Data engineers** — Implement and operate resolution and consent checks.

## 9. Main User Journeys

- **Login:** User logs in on web → auth provides user_id → resolution links session_id to user_id and resolves to customer_id → F2 events and F11 requests use customer_id.
- **POS / Email:** POS or email system sends identity signal → resolution links to existing customer_id or creates new → profile and recommendations use same customer_id.
- **Consent withdrawal:** User opts out → resolution marks consent withdrawn for use case → profile and API must not use personalized data for that customer (F22); identity link may remain for non-personalized use or be unlinked per policy.
- **Anonymous to identified:** Anonymous session later logs in or provides email → resolution merges session to customer_id; historical anonymous events can be attributed (policy: whether to backfill profile from pre-login events).

## 10. Triggering Events / Inputs

- **Request-time:** “Resolve customer_id for this session_id / user_id / email / POS id” → lookup or compute → return customer_id and confidence.
- **Batch:** Nightly or on-event (e.g. after login) run to merge new links, update confidence, apply consent rules.
- **Inputs:** One or more identifiers (session_id, user_id, email_hash, pos_customer_id); optional context (channel, region) for consent check.

## 11. States / Lifecycle

- **Identity link:** Active / Unlinked (e.g. after consent withdrawal) / Superseded (merged into another customer_id).
- **Customer (canonical):** Active / Consent_withdrawn (for use case X) / Deleted (soft; no new links).
- **Resolution result:** Resolved (customer_id + confidence) / Anonymous (no link; session-only) / Consent_required (link exists but consent missing for this use case).

## 12. Business Rules

- **Confidence:** Record and optionally expose (e.g. to profile service); below-threshold links may not be used for personalization (policy).
- **Consent:** Per use case and region; resolution must not return customer_id for personalized use if consent withdrawn. F22 enforces downstream; resolution provides consent flags or filtered output.
- **Merge rules:** Define precedence (e.g. logged-in > email > anonymous); avoid duplicate customer_id for same person; merge when high-confidence match found.
- **No invented IDs:** Do not create customer_id without at least one verified link (e.g. from auth or POS); anonymous-only stays session-level.

## 13. Configuration Model

- **Linking rules:** Which sources can create vs merge; confidence thresholds; merge precedence.
- **Consent:** Use-case and region matrix; opt-out handling (unlink vs flag).
- **Retention:** How long to keep anonymous links; when to create customer_id (e.g. first purchase, first login).
- **Feature flags:** Enable/disable probabilistic linking; strict consent enforcement.

## 14. Data Model

- **Customer (canonical):** customer_id, created_at, updated_at, consent_flags (JSON or table: use_case, region, allowed), status.
- **Identity link:** link_id, customer_id, source_system, source_id (hashed if required), confidence, created_at, status (active/unlinked).
- **Resolution result (transient or cached):** request_key (e.g. session_id), customer_id, confidence, consent_ok_for_use_case.
- **Audit log:** action (link|unlink|merge), customer_id, source, timestamp; no PII.

## 15. Read Model / Projection Needs

- **F2 (behavioral ingestion):** Needs customer_id for events; calls resolution or reads resolved_id by session_id/user_id after event received.
- **F7 (profile):** Needs customer_id to attach profile; resolution provides customer_id for request or for event enrichment.
- **F11 (delivery API):** Request includes session_id and/or user_id; API or middleware calls resolution to get customer_id for engine and profile lookup.
- **F22 (privacy):** Consent flags and opt-out state; resolution is source of truth for “can we use this customer_id for personalization?”

## 16. APIs / Contracts

- **Internal:** `POST /identity/resolve` with body `{ "session_id": "...", "user_id": "...", "email_id": "...", "channel": "webstore", "use_case": "recommendations" }` → `{ "customer_id": "cust-123", "confidence": 0.95, "consent_ok": true }` or `{ "customer_id": null, "reason": "anonymous" }`.
- **Batch/link:** Internal API or job to add link, merge, or unlink; used by auth callback or consent service.
- **Example:**

```json
POST /identity/resolve
{ "session_id": "sess-abc", "user_id": "auth-456", "channel": "webstore", "use_case": "recommendations" }
→ 200 OK
{ "customer_id": "cust-789", "confidence": 1.0, "consent_ok": true }
```

## 17. Events / Async Flows

- **Consumed:** Optional: `UserLoggedIn`, `ConsentUpdated` from auth or consent system to trigger link or unlink.
- **Emitted (optional):** `IdentityResolved` (customer_id, request_key) for downstream (F2, cache). Or downstream calls resolve API synchronously.
- **Flow:** Request → resolve (lookup or compute) → return; batch job → merge/unlink → update link table → invalidate caches if needed.

## 18. UI / UX Design

- **Admin (governance):** View resolution stats (coverage, confidence distribution); consent matrix; audit log viewer. No customer-facing UI.
- **Monitoring:** Resolution latency, coverage (%), consent rejection rate.

## 19. Main Screens / Components

- Resolution dashboard; consent configuration; audit log; link table (anonymized) for support. Operational and governance only.

## 20. Permissions / Security Rules

- **Resolve API:** Internal only; called by F2, F7, F11 or gateway. No external exposure of raw identity links.
- **Consent and PII:** Comply with F22 and data standards; no PII in logs; hashing where required for email/phone in links.
- **Audit:** Only authorized roles can view audit log and link table (anonymized).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Resolution failure rate, consent withdrawal spike, duplicate customer_id detection (merge issue).
- **Side effects:** F7 profile keyed by customer_id; F11 uses customer_id for personalization; F2 events enriched with customer_id. Consent withdrawal triggers F22 to stop personalization for that customer.

## 22. Integrations / Dependencies

- **Upstream:** Auth provider (user_id after login), POS (customer_id), email/CRM (email_id). Consent management (may be same system or separate).
- **Downstream:** F2 (event enrichment), F7 (profile key), F11 (request context), F22 (consent enforcement).
- **Shared:** `docs/project/data-standards.md` (identity resolution confidence, canonical IDs); domain model (Customer, identity links); BR-12 (governance).

## 23. Edge Cases / Failure Cases

- **Conflicting links:** Two sessions link to different emails; merge rule and confidence decide; avoid creating two customer_id for same person.
- **Consent withdrawn mid-session:** Next resolve returns consent_ok: false; F11 and F7 treat as anonymous or non-personalized for that use case.
- **High churn of anonymous IDs:** Do not create customer_id for every anonymous session; only when persistent identifier (login, email, POS) is present.
- **Cross-region:** Consent may differ by region; resolution returns customer_id only if consent_ok for requested region/use case.
- **Resolution service down:** F11 can fall back to session-only (anonymous); F2 may store events with session_id only and resolve later in batch.

## 24. Non-Functional Requirements

- **Latency:** Resolve call &lt; 50–100 ms p95 so request path is not blocked; cache resolved (session_id → customer_id) with TTL.
- **Availability:** High; fallback to anonymous when resolution unavailable.
- **Privacy:** No PII in logs; links stored with hashed identifiers if policy requires; retention of link history per policy.

## 25. Analytics / Auditability Requirements

- **Audit:** All link, unlink, merge actions with customer_id and timestamp; no PII. Required for BR-12 and compliance.
- **Metrics:** Resolution coverage (%), confidence distribution, consent_ok rate; for product and compliance review.

## 26. Testing Requirements

- **Unit:** Linking rules, confidence calculation, consent check logic.
- **Integration:** Resolve with session only, session+user, session+email; verify customer_id and consent_ok; verify F2/F11 receive correct id.
- **Consent:** Withdraw consent; verify resolve returns consent_ok: false and F7/F11 behavior.
- **Failure:** Resolution service down; verify F11 falls back to anonymous without error.

## 27. Recommended Architecture

- **Component:** Part of “Ingestion & events” layer (architecture) or dedicated identity service. Separate from auth; consumes auth outcomes.
- **Pattern:** Resolve API + identity graph (link table) + optional batch merge job. Cache for request-time performance.

## 28. Recommended Technical Design

- **Link table** (customer_id, source_system, source_id, confidence, consent_flags, status); **resolve service** (lookup + deterministic/probabilistic rules); **consent store** or integration; **cache** (session_id → customer_id, TTL). **Audit log** append-only. Align with data standards (canonical ID, confidence).

## 29. Suggested Implementation Phasing

- **Phase 1:** Deterministic only (logged-in user_id → customer_id); single source (ecommerce auth); consent flag from auth or simple store; F2 and F11 call resolve API.
- **Phase 2:** POS and email linking; probabilistic linking; confidence score; consent matrix; audit log; F7 and F22 integration.
- **Later:** Cross-device probabilistic; full consent management integration; regional consent variants.

## 30. Summary

Identity resolution (F4) merges anonymous, logged-in, POS, and email identities into a **stable customer_id** with **consent** respected. It enables a single **Customer Style Profile** (F7) and consistent attribution across channels. It is consumed by **behavioral ingestion** (F2), **customer profile service** (F7), **delivery API** (F11), and **privacy/consent enforcement** (F22). Identity resolution confidence is recorded; consent and regional rules are enforced. Failures must not break the recommendation API; fallback to anonymous/session-only is required.
