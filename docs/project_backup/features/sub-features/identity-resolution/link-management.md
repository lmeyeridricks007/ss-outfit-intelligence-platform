# Sub-Feature: Link Management (Identity Resolution)

**Parent feature:** F4 — Identity Resolution (`docs/features/identity-resolution.md`)  
**BR(s):** BR-2, BR-12  
**Capability:** Add, merge, and unlink identity links; maintain identity graph.

---

## 1. Purpose

Manage the **identity link table** that maps source identifiers (session_id, user_id, email_id, pos_customer_id) to canonical **customer_id**. Supports creating new links (e.g. on login), merging links when the same person is identified via multiple sources, and unlinking (e.g. consent withdrawal). Does not perform request-time resolve; that is resolve-api.

## 2. Core Concept

A **link lifecycle** component that:
- **Adds** links when a persistent identifier is first seen (e.g. user_id from auth after login).
- **Merges** two customer_ids when high-confidence match is found (e.g. same email); one customer_id supersedes the other.
- **Unlinks** a source_id from customer_id (e.g. consent withdrawal; link status = unlinked).
- Enforces **no invented IDs:** do not create customer_id without at least one verified link (auth, POS).

## 3. User Problems Solved

- **Single customer view:** One customer_id per person across web, email, POS.
- **Login/email/POS onboarding:** New links created so resolve-api can return customer_id on next request.
- **Compliance:** Unlink or mark consent_withdrawn so resolve and downstream respect opt-out.

## 4. Trigger Conditions

- **Event-driven:** Auth callback (UserLoggedIn) → add link session_id + user_id → customer_id. Consent withdrawal → unlink or flag.
- **Batch:** Nightly or on-event merge job to merge duplicate customer_ids; update confidence.
- **API:** Internal POST /identity/links (or equivalent) to add/merge/unlink by admin or auth service.

## 5. Inputs

- **Add link:** source_system, source_id, customer_id (existing or new), confidence, optional channel.
- **Merge:** primary_customer_id, secondary_customer_id (links of secondary move to primary; secondary marked superseded).
- **Unlink:** customer_id, source_system, source_id; or customer_id + use_case for consent withdrawal (soft unlink or flag).

## 6. Outputs

- **Add:** link_id or customer_id created; 201 or 200.
- **Merge:** All links of secondary_customer_id reassigned to primary_customer_id; secondary status = superseded.
- **Unlink:** Link status = unlinked; or consent flag updated. 200.

## 7. Workflow / Lifecycle

- **Add:** Receive add request → check if source_id already linked → if not, create new link (or new customer_id if first verified link) → write link table → optional emit event → invalidate cache for session_id if present.
- **Merge:** Resolve precedence (e.g. logged-in > email) → reassign all links of B to A → set B status = superseded → audit log → invalidate caches.
- **Unlink:** Set link status = unlinked or set consent flag for use_case → audit log → invalidate cache.

## 8. Business Rules

- **No invented IDs:** Create customer_id only when at least one verified link (auth, POS, or policy-defined) exists. Anonymous-only stays session-level.
- **Merge precedence:** Define in config (e.g. logged-in > email > POS > anonymous); avoid duplicate customer_id for same person.
- **Retention:** Anonymous link TTL; do not create customer_id for every anonymous session (policy).
- **Idempotency:** Add link with same (source_system, source_id) → update confidence/updated_at; no duplicate row.

## 9. Configuration Model

- **Merge rules:** Precedence order; confidence threshold for auto-merge.
- **Creation rules:** Which sources can create new customer_id (e.g. auth, POS only).
- **Retention:** Anonymous link expiry; merge job schedule.

## 10. Data Model

- **identity_link:** link_id (PK), customer_id (FK), source_system, source_id (hashed if required), confidence, status (active \| unlinked \| superseded), created_at, updated_at.
- **customer (canonical):** customer_id (PK), created_at, updated_at, consent_flags (JSON or separate table), status.

## 11. API Endpoints

- **Internal** (examples):  
  - POST /identity/links — add link.  
  - POST /identity/links/merge — merge two customer_ids.  
  - POST /identity/links/unlink — unlink or set consent flag.  
Exact paths and auth per technical architecture.

## 12. Events Produced

- **Optional:** IdentityLinkAdded, IdentityMerged, IdentityUnlinked (for cache invalidation, F2 backfill). Payload: customer_id, source_system; no PII.

## 13. Events Consumed

- **UserLoggedIn** (from auth): user_id, session_id → add link, create or attach customer_id.
- **ConsentUpdated** (from F22): customer_id, use_case, allowed=false → unlink or set consent flag.

## 14. Integrations

- **Upstream:** Auth provider (login event), F22 (consent), POS/CRM (batch or API).
- **Downstream:** resolve-api (reads link table), identity-cache (invalidate on change), audit-log (write actions).

## 15. UI Components

- None for link-management itself. Admin may have “identity links” viewer (read-only, anonymized) in governance UI.

## 16. UI Screens

- Optional: Audit log viewer; link stats dashboard (see parent F4 §18–19).

## 17. Permissions & Security

- **APIs:** Internal only; called by auth service, F22, or batch jobs. No public exposure.
- **PII:** source_id stored hashed where policy requires; no PII in logs or events.

## 18. Error Handling

- **Merge when one customer_id missing:** 404.
- **Unlink already unlinked:** 200 idempotent.
- **Add when customer_id does not exist:** Create customer_id only if policy allows (first verified link); else 400.

## 19. Edge Cases

- **Conflicting links:** Two sessions link to different emails; merge job or manual merge with precedence.
- **High churn of anonymous IDs:** Do not create customer_id; only link to existing when persistent id present.
- **Double merge:** Ensure merge is idempotent and secondary_customer_id is not already superseded.

## 20. Performance Considerations

- **Batch merge:** Run in off-peak; batch size and locking to avoid long blocks.
- **Index:** (source_system, source_id) for resolve lookups; customer_id for merge/unlink.

## 21. Observability

- **Metrics:** Links added/merged/unlinked per day; merge job duration; error rate.
- **Audit:** All add/merge/unlink written to audit-log sub-feature.

## 22. Example Scenarios

- **Login:** User logs in → auth sends UserLoggedIn(session_id=s1, user_id=u1) → link-management adds link (auth, u1) → customer_id c1 (new or existing) → resolve-api can return c1 for s1.
- **Consent withdraw:** User opts out → F22 updates consent → link-management sets consent_withdrawn for c1, use_case=recommendations → next resolve returns consent_ok=false.

## 23. Implementation Notes

- **Backend:** Service or module with add/merge/unlink handlers; link table writer; optional event publisher.
- **Database:** identity_link table; customer table (or shared with profile/CRM). Audit log table or append-only store.
- **Jobs:** Optional nightly merge job to merge duplicates by confidence rules.
- **External APIs:** None.
- **Frontend:** None (optional admin viewer).

## 24. Testing Requirements

- **Unit:** Merge precedence; no duplicate link for same (source_system, source_id); unlink idempotent.
- **Integration:** Add link → resolve returns customer_id; merge → resolve returns primary; unlink → resolve returns anonymous or consent_ok false.
- **Audit:** Verify every add/merge/unlink written to audit log.
