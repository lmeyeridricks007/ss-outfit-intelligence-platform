# Data Standards

**Purpose:** Cross-cutting standards for entities, identity, events, telemetry, and privacy. Apply to all platform data (catalog, behavioral events, recommendation outcomes, profile, identity); primary reference for F2, F4, F7, F12, F17, F22 and technical architecture.  
**Source:** Business requirements (BR-2, BR-10, BR-12), domain model, architecture overview, behavioral ingestion (F2), identity resolution (F4), recommendation telemetry (F12), privacy and consent (F22).  
**Traceability:** Referenced by feature specs, technical architecture, and implementation; aligns with `docs/project/domain-model.md`.  
**Status:** Living document; update when schema, identity, or privacy expectations change.  
**Review:** Standards-stage artifact; assess per `docs/project/review-rubrics.md`.  
**Approval mode:** HUMAN_REQUIRED for material changes to data schema or privacy expectations.

---

## Related Documents

- **Domain model:** `docs/project/domain-model.md` — entities, relationships, identifiers.
- **Standards:** `docs/project/standards.md` — lifecycle, promotion, naming.
- **Glossary:** `docs/project/glossary.md` — look, outfit, placement, channel.

---

## 1. Entities

### Canonical data domains

Data is organized into stable **domains**; each has a canonical identifier and ownership:

| Domain | Canonical ID | Description |
|--------|----------------|-------------|
| **Product** | `product_id` | Catalog items; category, attributes, relationships (F1, F5). |
| **Customer** | `customer_id` | Canonical customer; identity resolution (F4) produces this; one per person where consented. |
| **Look** | `look_id` | Curated product grouping; outfit graph and look store (F6). |
| **Merchandising rule** | `rule_id` | Pin, exclude, include, constraints; F10, F19. |
| **Campaign** | campaign identifier | Marketing or placement scope; attribution. |
| **Experiment** | experiment_id / variant | A/B or MAB; attribution (F24). |
| **Recommendation result** | recommendation set ID, trace ID | Per response; attribution (F11, F12). |

Entity attributes and relationships follow the **domain model** (`docs/project/domain-model.md`). Do not introduce new canonical IDs without aligning with domain model and feature list.

### Identifier rules

- **Stable:** Canonical IDs do not change for the lifetime of the entity (or follow defined migration rules).
- **Opaque where appropriate:** customer_id and session_id are opaque to clients; do not encode PII in IDs.
- **Single source of truth:** product_id from catalog (F1); customer_id from identity resolution (F4); look_id from look store (F6).

---

## 2. Identity

- **Canonical customer_id:** The platform uses a single **customer_id** per person (where identity is resolved and consented). Identity resolution (F4) merges anonymous, logged-in, POS, and email identities into this ID. Downstream (F7 profile, F11 API, F2 events) use customer_id for personalization and attribution.
- **Session vs customer:** When a user is not identified, use **session_id** only (e.g. anonymous). Events and API requests may carry session_id and/or customer_id; resolution produces customer_id when a link exists and consent permits. Do not invent customer_id for anonymous-only sessions.
- **Identity resolution confidence:** When merging identities across systems, **record confidence** (e.g. 0–1). Use for audit and optionally for gating personalization (e.g. below-threshold links not used for personalization per policy). See F4 and domain model.
- **Consent and scope:** Identity resolution must respect **consent** and **region**. Do not merge or expose customer_id for a use case (e.g. recommendations) when consent is withdrawn or not granted. F22 defines consent checks; F4 consumes them.
- **No PII in identity store:** Store only identifiers and consent flags; PII (name, email) lives in CRM or auth; identity resolution stores links (source_system, source_id → customer_id) and optional hashed identifiers per policy.

---

## 3. Events

### Canonical event schema

All **behavioral and outcome events** conform to a canonical schema. Required and optional fields:

| Field | Required | Description |
|--------|----------|-------------|
| **event_name** | Yes | e.g. product_view, add_to_cart, order_completed; for outcomes: recommendation_impression, recommendation_click, recommendation_add_to_cart, recommendation_purchase, recommendation_dismiss. |
| **event_timestamp** | Yes | When the event occurred (ISO 8601 or epoch ms). |
| **customer_id** or **session_id** | At least one | customer_id when resolved (F4); session_id for anonymous. Both allowed for correlation. |
| **channel** | Yes | webstore, email, clienteling. |
| **placement** | When applicable; required for outcome events | Where the action occurred (e.g. pdp_complete_the_look, cart, homepage). Outcome events must include placement for attribution. |
| **anchor product_id or look_id** | When applicable | Product or look that was viewed, clicked, or in cart. |
| **recommendation_set_id**, **trace_id** | For outcome events | Required for impression, click, add-to-cart, purchase, dismiss that result from a recommendation. From F11 response. |

Optional: event_id (deduplication), campaign_id, experiment_id, position, order_id, revenue, flexible payload for domain-specific data. Unknown fields may be allowed in a flexible payload; required fields must be present. **Validation:** Events missing required fields for their type (e.g. outcome events without set_id/trace_id or placement) must be rejected or quarantined; do not drop silently. See F2 (behavioral) and F12 (outcome) feature specs.

### Behavioral vs outcome events

- **Behavioral:** product_view, add_to_cart, order_completed, search, store_visit, email_engagement, etc. Used for profile (F7) and analytics. May include recommendation_set_id/trace_id only when the action is an outcome of a recommendation.
- **Outcome events:** recommendation_impression, recommendation_click, recommendation_add_to_cart, recommendation_purchase, recommendation_dismiss. **Must** include recommendation_set_id and trace_id. Used for attribution (F17) and performance (BR-10). Ingested via F12 or shared pipeline with F2.

---

## 4. Telemetry

- **Recommendation outcome events:** Every recommendation impression, click, add-to-cart, purchase, and dismiss must be sent with **recommendation_set_id** and **trace_id** from the Delivery API (F11) response. Channels (web, email, clienteling) send these events to the telemetry pipeline (F12); F12 validates and stores/forwards to analytics (F17).
- **Attribution:** Revenue and conversion are attributed to placements and strategies by joining outcome events (click, purchase) via trace_id and optional order_id. Attribution model (e.g. last-click, time window) is defined in F17; data standards require that **every outcome event carries set_id and trace_id** so attribution is possible.
- **Validation:** Reject or quarantine events missing recommendation_set_id or trace_id for outcome event types; do not drop silently; alert on high reject rate.
- **Retention:** Define retention per policy (e.g. 2 years for attribution); document in technical architecture or F12.
- **No PII in telemetry payload:** Event body may include customer_id for attribution join; do not include name, email, or other PII. Logs and exports: no PII beyond what is necessary; hash or scope per policy.

---

## 5. Privacy and Governance

- **Use case and region:** Use customer data only for **permitted use cases** and **regions**. Consent store (F22) defines per customer and use case (e.g. recommendations_personalization, email_recommendations, clienteling_profile, analytics). Check consent before using customer_id for personalization, profile display, or behavioral ingestion. Region may affect consent (e.g. EU).
- **Consent and opt-out:** **Respect opt-out.** When consent is withdrawn for a use case, identity resolution (F4) must not return customer_id for that use case (or must return consent_ok=false); profile (F7) must return empty or non-personal for that use case; clienteling (F23) must not show profile when consent is withdrawn for clienteling. Downstream delivery surfaces must not use data for purposes the customer has opted out of.
- **Data minimization:** Collect and retain only what is necessary for the use case. Logs and exports: no PII beyond what is required (e.g. customer_id hashed or scoped). Audit logs: log consent changes and critical actions without full PII.
- **Sensitive reasoning:** Do not expose “why we recommended” (internal reasoning) to customer-facing UI; only high-level explainability (e.g. “because you liked X”) if permitted by policy.
- **No unapproved bulk overrides:** Policy (F21, F22): rules or actions that apply to all placements or all users require designated approval path. Data standards do not implement this; they state that data use must be scoped and consented.

---

## 6. References

- **Domain model:** `docs/project/domain-model.md`
- **Behavioral event ingestion:** `docs/features/behavioral-event-ingestion.md`
- **Identity resolution:** `docs/features/identity-resolution.md`
- **Recommendation telemetry:** `docs/features/recommendation-telemetry.md`
- **Privacy and consent:** `docs/features/privacy-and-consent-enforcement.md`
- **Review rubrics:** `docs/project/review-rubrics.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Data standards (this document).  
**Stage:** Standards / data, identity, events, telemetry, privacy.  
**Approval mode:** HUMAN_REQUIRED for material changes.  
**Review source:** Direct invocation (independent review against review-rubrics).

### Overall disposition

**Eligible for promotion.** The data standards doc covers entities, identity, events, telemetry, and privacy; it aligns with the domain model and feature specs (F2, F4, F12, F22). All six dimensions score 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL** for material changes to this doc.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Scope, intent, and structure (entities, identity, events, telemetry, privacy) are clear. Header states purpose, source, traceability; tables (domains, event schema) and rules are easy to follow without restating the prompt. |
| **Completeness** | 5 | Entities (domains, canonical IDs, identifier rules); identity (customer_id, session, confidence, consent, no PII in store); events (full schema, required vs optional, placement for outcome events, validation rule, behavioral vs outcome); telemetry (outcome events, set_id/trace_id, attribution, validation, retention, no PII); privacy (use case, region, consent, opt-out, minimization, sensitive reasoning, no bulk override). Dependencies and edge cases (anonymous sessions, invalid events) covered. |
| **Implementation Readiness** | 5 | F2, F4, F7, F12, F17, F22 and technical architecture can derive schemas, validation rules, and consent checks from this doc with limited ambiguity. |
| **Consistency With Standards** | 5 | Aligns with domain model, glossary, and feature specs; terminology (customer_id, look_id, placement, channel, set_id, trace_id) consistent; header and review record follow project standards and review-rubrics output format. |
| **Correctness Of Dependencies** | 5 | References to domain model, F2, F4, F12, F22, F17, F11, BR-2, BR-10, BR-12, and review-rubrics are accurate; paths and feature IDs verified; no incorrect claims. |
| **Automation Safety** | 5 | Doc does not assert approval or completion of any board item; recommendation is READY_FOR_HUMAN_APPROVAL only; guardrails respected. |

**Average:** 5.0. **Minimum dimension:** 5. **Threshold:** Average > 4.1 and no dimension < 4 — **met**.

### Confidence rating

**HIGH.** Inputs (domain model, BRs, feature specs) are stable; scope is clear; standards are actionable for pipelines and consent enforcement.

### Blocking issues

**None.**

### Recommended edits

**None required.** When technical architecture defines event store and retention, add a one-line cross-reference from this doc.

### Explicit recommendation

Based on approval mode **HUMAN_REQUIRED:** the artifact should move to **READY_FOR_HUMAN_APPROVAL** (not direct APPROVED, not CHANGES_REQUESTED). It is suitable as the data standards reference; material changes to schema, identity, or privacy expectations require review and human approval before adoption.

### Propagation to upstream

**None required.** No human rejection comments. If the domain model or a feature spec (F2, F4, F12, F22) changes in a way that affects these standards, update this doc.

### Pending confirmation

Before completion (adoption of any material change to this doc): **human approval** is required. When technical architecture defines event store, retention, and consent store details, **alignment** and a cross-reference from this doc should be confirmed. No GitHub Actions or merge dependency for this artifact.
