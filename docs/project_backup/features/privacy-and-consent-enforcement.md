# Feature Deep-Dive: Privacy and Consent Enforcement (F22)

**Feature ID:** F22  
**BR(s):** BR-12 (Governance and safety)  
**Capability:** Respect privacy and consent in data use  
**Source:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/data-standards.md`

---

## 1. Purpose

**Scope customer data use** to **permitted use cases and regions**; **respect consent and opt-out**; **do not expose sensitive profile reasoning** to customer-facing surfaces; **no unapproved bulk overrides** (BR-12). Privacy and consent enforcement is a cross-cutting concern: **identity resolution** (F4), **customer profile** (F7), **behavioral ingestion** (F2), **clienteling** (F23), and **analytics** must all respect it.

## 2. Core Concept

- **Consent:** Customer permission for specific use cases (e.g. recommendation personalization, email recommendations, clienteling profile view). Stored per customer (and optionally per use case and region). **Opt-out** = consent withdrawn for one or all use cases.
- **Enforcement:** Before **using** customer_id for personalization (F7 profile, F9 personal strategy), **check** consent for use case and region. Before **exposing** profile or PII to **clienteling** (F23), check consent for “clienteling” use case. Before **ingesting or retaining** behavioral data (F2), ensure consent for “analytics/recommendations.” **Identity resolution** (F4) must not merge or expose where consent is missing. **No unapproved bulk override:** No single action (e.g. rule) that applies to all users/placements without designated approval path (F21); policy/process measure.
- **Sensitive data:** Profile “reasoning” (e.g. why we think customer prefers formal) must not be shown to customer-facing UI; only internal or associate-facing with permission. **PII:** Name, email, etc. only where permitted and necessary; minimize in logs and exports.

## 3. Why This Feature Exists

- **BR-12:** Privacy and consent must be respected; customer data use scoped to permitted use cases and regions. **Governance goals** (goals.md): identity resolution, consent, and customer trust central to design.
- **Compliance:** GDPR, CCPA, or regional rules require consent and opt-out; enforcement is the implementation.

## 4. User / Business Problems Solved

- **Customers:** Trust that data is used only as consented; can opt out. **Compliance/Legal:** Audit and enforce consent. **Brand:** Avoid misuse and reputational risk.

## 5. Scope

### 6. In Scope

- **Consent store:** Per customer (customer_id): use_case (e.g. recommendations_personalization, email_recommendations, clienteling_profile), region (optional), allowed (boolean), updated_at. **Opt-out:** Set allowed=false for use case; optionally “delete my data” (separate process: purge profile, anonymize events).
- **Check before use:** **F7 (profile):** Before returning profile for “recommendations” use case, check consent; if not allowed, return empty or do not use for personalization. **F4 (identity):** Before linking identities for personalization, check consent; if not allowed, do not merge or return customer_id for that use case. **F23 (clienteling):** Before showing profile to associate, check consent for “clienteling_profile”; if not allowed, do not show. **F2 (behavioral):** Only ingest/store events for customers who have consented to “analytics” or “recommendations” (or anonymize); define policy. **F17 (reporting):** No PII in reports; only aggregates; optional customer_id hashing in attribution.
- **No bulk override:** Policy: rules that apply to “all placements” or “all users” require approval (F21). F22 does not implement rules; it is the **policy** that F19/F21 enforce. F22 may expose “consent required” flags to F4, F7, F23.
- **Audit:** Log consent changes (who withdrew, when); do not log full PII in audit. **Data minimization:** Logs and exports: no PII beyond what is necessary (e.g. customer_id hashed or scoped).

### 7. Out of Scope

- **Consent collection UI** (e.g. preference center) — May be in commerce or CRM; F22 consumes consent state. **Identity resolution logic** — F4; F22 provides “can use for use_case?” check. **Profile computation** — F7; F22 gates **use** of profile. **Legal advice** — F22 implements policy; legal defines policy.

## 8. Main User Personas

- **All personas (trust):** Customers expect consent respected. **Compliance / Legal** — Define and audit. **Engineers** — Implement checks in F4, F7, F23, F2.

## 9. Main User Journeys

- **Opt-out:** Customer withdraws consent (via preference center or request) → Consent store updated (allowed=false for use case) → Next F4 resolve returns “do not use for personalization” for that customer; F7 returns empty profile for personalization; F23 does not show profile. **Data request:** Customer requests “what do you have on me” or “delete” → Separate process (export or purge); F22 may provide “consent state” for export.
- **Check:** F7 before returning profile → GET consent(customer_id, use_case=recommendations) → if not allowed, return empty. F23 before showing profile → GET consent(customer_id, use_case=clienteling_profile) → if not allowed, hide profile block.

## 10. Triggering Events / Inputs

- **Request-time:** F4, F7, F23 (and optionally F11) call “check consent(customer_id, use_case, region)”. **Inputs:** customer_id, use_case, region (optional). **Output:** allowed (boolean) or scope (e.g. “no personalization”).
- **Consent update:** User or system updates consent (preference center, API, support) → Consent store updated; optional event to invalidate F7 profile cache or F4 link.

## 11. States / Lifecycle

- **Consent:** allowed | withdrawn (per use case). **No state machine** in F22; store is key-value (customer_id, use_case → allowed). **Purge:** Optional “deleted” state; then purge profile and anonymize events (separate job).

## 12. Business Rules

- **Default:** If no consent record, define policy: treat as “no consent” (strict) or “consent” (legacy); recommend strict for new users, legacy with sunset for existing. **Region:** Consent may differ by region (e.g. EU); check region in request or profile. **Use case granularity:** recommendations_personalization, email_recommendations, clienteling_profile, analytics (define list). **No override:** Even with consent, do not expose “why we recommended” (sensitive reasoning) to customer-facing UI; only high-level (e.g. “because you liked X”) if permitted.

## 13. Configuration Model

- **Use cases:** List of use_case ids and names. **Default policy:** No record = allow or deny. **Region list:** For region-scoped consent. **Feature flags:** Strict enforcement on/off (for rollout).

## 14. Data Model

- **Consent:** customer_id, use_case, region (optional), allowed (boolean), updated_at, source (e.g. preference_center). **Audit (consent change):** customer_id (or hash), use_case, old_allowed, new_allowed, timestamp; no PII in log. **No profile or event storage** in F22; only consent and audit.

## 15. Read Model / Projection Needs

- **F4, F7, F23, F11:** Read consent(customer_id, use_case) before using data. **Preference center (external):** May read consent to display; write consent on user action. **Compliance:** Query audit log (consent changes); export consent state per customer (for “what do you have” request).

## 16. APIs / Contracts

- **Check:** GET /consent/check?customer_id=...&use_case=recommendations_personalization&region=eu → 200 { allowed: true|false }. **Update (internal or preference center):** PUT /consent { customer_id, use_case, allowed } → 200. **Audit:** GET /consent/audit?customer_id=&from=&to= (admin only) → list of consent changes.
- **Example:** GET /consent/check?customer_id=cust-1&use_case=clienteling_profile → 200 { allowed: true }.

## 17. Events / Async Flows

- **Consumed:** ConsentUpdated (from preference center or API). **Emitted (optional):** ConsentChanged for F4/F7 cache invalidation. **Flow:** Check is sync; update is write then optional notify.

## 18. UI / UX Design

- **F22 has no end-user UI.** Preference center (if in scope elsewhere) shows “Use my data for recommendations: Yes/No.” **Admin:** Optional consent audit viewer (customer_id hashed, use_case, allowed, date); no PII.

## 19. Main Screens / Components

- **None** in F22. Optional admin: ConsentAuditViewer.

## 20. Permissions / Security Rules

- **Check API:** Internal only (F4, F7, F23, F11). **Update API:** Preference center (authenticated as customer) or admin/support (with audit). **Audit read:** Compliance only. **No PII** in logs or public API.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Consent store failure (F4/F7 should fallback to “no consent” and alert). **Side effects:** When consent withdrawn, F7 returns empty for personalization; F23 hides profile; F4 may unlink or mark “do not use for personalization.”

## 22. Integrations / Dependencies

- **Upstream:** Preference center or CRM (consent updates). **Downstream:** F4 (resolve check), F7 (profile check), F23 (clienteling check). **Shared:** BR-12; data-standards (consent); goals (governance).

## 23. Edge Cases / Failure Cases

- **Consent store down:** F4/F7/F23 should treat as “no consent” (safe default); do not fail request; return anonymous or empty profile. **Missing customer_id:** Anonymous session; no consent check (no personalization). **Region mismatch:** Check region in request; if EU and no consent, do not use personalization for EU region.

## 24. Non-Functional Requirements

- **Latency:** Check &lt; 10 ms (cache consent by customer_id). **Availability:** High; fallback to “no consent” on failure. **Retention:** Consent and audit retained per policy (e.g. 7 years for compliance).

## 25. Analytics / Auditability Requirements

- **Audit:** All consent changes logged (who, when, use_case, old/new); no PII in log (customer_id hashed or id only). **Compliance export:** Ability to export “consent state per customer” for data subject request (anonymized or with auth).

## 26. Testing Requirements

- **Unit:** Check logic (allowed vs denied); default policy. **Integration:** Withdraw consent → F7 returns empty for personalization; F23 does not show profile. **Failure:** Consent store down → F7 returns empty; no 500.

## 27. Recommended Architecture

- **Component:** Shared service or library used by F4, F7, F23. **Store:** DB table consent (customer_id, use_case, allowed); cache (Redis) with TTL. **Pattern:** Sync check on every request that needs consent; update via API from preference center.

## 28. Recommended Technical Design

- **Consent table:** customer_id, use_case, region, allowed, updated_at. **Cache:** customer_id + use_case → allowed; TTL 5 min. **API:** Check (read), Update (write from preference center). **Audit table:** append-only consent_audit (customer_id_hash, use_case, old_allowed, new_allowed, ts).

## 29. Suggested Implementation Phasing

- **Phase 1:** Consent store and check API; F7 and F4 use check (recommendations_personalization); default = allow (legacy) or deny (strict). **Phase 2:** clienteling_profile use case for F23; preference center integration; audit log; region. **Later:** Purge and “delete my data” flow; consent audit viewer.

## 30. Summary

**Privacy and consent enforcement** (F22) **scopes customer data use** to **permitted use cases and regions** and **respects consent and opt-out**. **F4, F7, F23** (and optionally F11) **check consent** before using or exposing data. **No unapproved bulk override** is a policy enforced via F21 and process. **Sensitive profile reasoning** is not exposed to customer-facing surfaces. Consent store and check API are the core; failure must default to “no consent” (safe). BR-12 and governance goals are satisfied.
