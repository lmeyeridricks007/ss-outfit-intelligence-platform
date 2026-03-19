# Feature Deep-Dive: Customer Profile Service (F7)

**Feature ID:** F7  
**BR(s):** BR-3 (Customer profile and style signals)  
**Capability:** Build and maintain customer style profile  
**Source:** `docs/project/feature-list.md`, `docs/project/domain-model.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Build and maintain a **Customer Style Profile** (durable profile of preferences, affinity, segmentation, and intent) from orders, browsing, store visits, appointments, and stated interests, so recommendations can be **personal** and **intent-aware**. The profile is consumed by the **recommendation engine** (F9) and optionally exposed to **clienteling** (F23) where permitted.

## 2. Core Concept

- **Customer Style Profile:** One active profile per **customer** (canonical customer_id from F4). Attributes: preferred colors, fits, fabrics, silhouettes, price bands; occasion affinity; segmentation (e.g. formal vs casual); intent signals (e.g. “shopping for wedding”). Confidence and last-updated metadata. Per glossary and domain model.
- **Profile service:** Consumes **behavioral events** (from F2) and optionally **identity** (from F4). Computes or updates profile (batch or near real-time). Exposes **read API** for F9 and F23: get profile by customer_id. Does not store raw events long-term; aggregates into profile.

## 3. Why This Feature Exists

- **BR-3:** A customer profile (style profile) must be built and maintained to support personal and intent-aware recommendations. Success: profile coverage and/or personal recommendation lift.
- **BR-1, BR-5:** Personal recommendations and “looks for you” require a profile; without it, only contextual and popular strategies apply.
- **BR-9:** Clienteling may show (where permitted) customer style profile to associates; profile is the source.

## 4. User / Business Problems Solved

- **Returning customers:** Get suggestions that match their taste and history; less repetition and irrelevance.
- **Style-seeking customers:** Intent and occasion can be reflected in recommendations.
- **Associates:** See summarized style profile in clienteling (F23) to assist selling.
- **Merchandising:** Segmentation and affinity support targeting and reporting.

## 5. Scope

### 6. In Scope

- **Inputs:** Orders, browsing (views, add-to-cart), store visits, appointments, email engagement, stated interests (e.g. “interested in formal wear”). All from **behavioral event ingestion** (F2); customer_id from **identity resolution** (F4).
- **Output:** Style profile: preferences (colors, fits, fabrics, price tier), affinity (categories, brands/style families), segmentation (segment_id or labels), intent (current shopping intent if detectable), confidence score, last_updated. One active profile per customer; optional historical snapshots.
- **Update:** Batch (e.g. nightly) or near real-time (e.g. on new order/view); define refresh policy. Cold start: new customers have empty or default profile; engine handles via fallback strategies (BR-5).
- **Read API:** Get profile by customer_id; optional scope (e.g. only preferences, or full). Used by F9 (and F23 for display). Respect **consent** (F22): if customer opted out of personalization, return empty or “anonymous” profile for that use case.
- **Profile coverage metric:** % of logged-in/identified users with non-empty profile after N interactions (N and target TBD—missing decision). Used for BR-3 success metric.

### 7. Out of Scope

- **Identity resolution** — F4; profile service receives customer_id and events already enriched.
- **Recommendation logic** — F9; profile is input, not ranking.
- **Raw event storage** — F2 and analytics own events; profile stores only aggregates/signals.
- **PII storage** — Profile stores preferences and affinity, not name/email; PII stays in CRM or identity. Optional: do not store any PII in profile (only customer_id and derived signals).

## 8. Main User Personas

- **Returning Customer, Style-Seeking Customer** — Benefit from personalized and intent-aware recommendations.
- **In-Store Associate** — May see profile in clienteling (F23) where permitted.
- **Merchandising / CRM** — Segmentation and affinity for targeting and reporting.

## 9. Main User Journeys

- **Profile build:** Events flow from F2 (with customer_id from F4) → profile job or stream processor updates profile (e.g. update affinity from purchase, update intent from recent views) → profile stored; F9 reads on each request (or cached).
- **Recommendation request:** F11 receives request with customer_id → F9 fetches profile from profile service → F9 uses profile for personal ranking and filtering.
- **Consent withdrawal:** F22 signals opt-out → profile service marks “no personalization” for that customer or returns empty for personalization use case; F9 treats as anonymous.

## 10. Triggering Events / Inputs

- **Event-driven:** New behavioral event (order, view, add-to-cart) with customer_id → trigger profile update (incremental or append to batch).
- **Batch:** Scheduled job processes event window and recomputes profile for affected customers.
- **Request-time:** F9 (or F23) calls “get profile(customer_id)” → profile service returns profile or empty.

## 11. States / Lifecycle

- **Profile:** Exists / Empty (cold start) / Stale (e.g. not updated in N days). Optional: Deprecated if customer deleted or consent withdrawn for all use cases.
- **Update job:** Queued → Running → Completed / Failed. Per-customer update can be incremental (event-by-event) or full recompute.

## 12. Business Rules

- **One active profile per customer:** Overwrite or version; engine and clienteling read “current” only.
- **Consent:** If F22 says no personalization for this customer/use case, profile service returns empty or flag “do not use for personalization.” Do not expose profile to clienteling if consent missing for that use case.
- **Cold start:** New customer or no events → empty profile or defaults (e.g. segment “new”); F9 uses non-personal strategies and fallbacks.
- **Confidence:** Store and optionally expose; low-confidence profile may be weighted less by F9 or used only for soft signals.

## 13. Configuration Model

- **Refresh policy:** Batch frequency; real-time update on/off; event types that trigger update.
- **Signals:** Which event types contribute to which profile attributes (e.g. purchase → affinity; view → intent). Weights and decay (e.g. recent events count more).
- **Segmentation:** Rule-based segments (e.g. “high AOV,” “formal focus”) or model-based; configurable segment definitions.
- **Retention:** How long to keep profile after last activity; optional purge for deleted customers.

## 14. Data Model

- **Profile:** customer_id, preferences (JSON: colors, fits, fabrics, price_band), affinity (categories, style_families, scores), segment_id or segments (array), intent (current intent label or null), confidence, last_updated, optional version.
- **Profile_history (optional):** customer_id, snapshot_at, profile_json. For analytics or rollback.
- **Input:** Events from F2 (already with customer_id); no raw event copy in profile service.

## 15. Read Model / Projection Needs

- **Recommendation engine (F9):** Primary consumer. Needs profile for “personal” strategy and hybrid ranking. Read by customer_id; low latency.
- **Clienteling (F23):** Optional read for “style profile” display; must respect consent (F22) and channel permission.
- **Analytics:** Optional export of segment distribution, profile coverage; no PII.

## 16. APIs / Contracts

- **Internal (to F9, F23):** `GET /profile/{customer_id}?use_case=recommendations` → 200 OK { preferences, affinity, segment, intent, confidence, last_updated } or 200 OK { empty: true } for cold start / consent. If use_case=clienteling, apply clienteling consent check.
- **Example:**

```json
GET /profile/cust-123?use_case=recommendations
→ 200 OK
{
  "customer_id": "cust-123",
  "preferences": { "colors": ["navy", "grey"], "fits": ["slim"] },
  "affinity": { "categories": ["suits", "shirts"], "scores": [0.9, 0.7] },
  "segment": "formal_focus",
  "intent": "workwear",
  "confidence": 0.85,
  "last_updated": "2025-03-17T10:00:00Z"
}
```

## 17. Events / Async Flows

- **Consumed:** Behavioral events (from F2) with customer_id; optional ConsentUpdated (from F22) to invalidate or mask profile.
- **Emitted (optional):** ProfileUpdated (customer_id) for cache invalidation or downstream analytics.
- **Flow:** Event → profile update (incremental or batch) → store; request → read from store or cache.

## 18. UI / UX Design

- **No customer-facing UI.** Admin (optional): profile coverage dashboard, segment distribution; no per-customer profile viewer (privacy). Clienteling (F23) may show a **summary** of profile (e.g. “Prefers formal, navy/grey”) with permission.

## 19. Main Screens / Components

- Backend service only. Clienteling UI (F23) may render profile summary component; data from this service.

## 20. Permissions / Security Rules

- **Read:** F9 and F23 only; internal. F23 read only when consent and channel permit (F22). No external API.
- **Data:** Profile is derived data; no PII in profile store (only customer_id and signals). Access by role; audit read access if required for compliance.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Profile build failure, coverage drop, high latency on read.
- **Side effects:** F9 recommendations change when profile updates; F23 display updates when profile is refreshed. Consent withdrawal (F22) causes profile to be unused for personalization.

## 22. Integrations / Dependencies

- **Upstream:** Behavioral event ingestion (F2) for events; Identity resolution (F4) for customer_id on events. Privacy/consent (F22) for consent check before returning profile for personalization/clienteling.
- **Downstream:** Recommendation engine (F9); Clienteling (F23) for profile display where permitted.
- **Shared:** Domain model (Customer Style Profile); glossary; BR-3 (profile coverage, personal lift).

## 23. Edge Cases / Failure Cases

- **No profile (cold start):** Return empty; F9 uses non-personal strategies. Do not fail request.
- **Profile service down:** F9 falls back to no profile (anonymous behavior); do not fail recommendation API.
- **Consent withdrawn:** Return empty for personalization use case; F23 must not show profile if consent missing for clienteling.
- **Stale profile:** Define “stale” (e.g. no update in 90 days); optionally lower confidence or treat as cold start.
- **High churn:** New customers; ensure batch or real-time keeps up so coverage metric is meaningful.

## 24. Non-Functional Requirements

- **Read latency:** p95 &lt; 50 ms so F9 is not blocked; cache by customer_id with TTL (e.g. 5 min).
- **Update latency:** Batch within N hours of events; or real-time within seconds (if supported). Define SLA for “profile reflects last purchase” (e.g. 24h).
- **Availability:** High; fallback to empty profile on failure.

## 25. Analytics / Auditability Requirements

- **Metrics:** Profile coverage (%), segment distribution, update lag; for BR-3. No PII in analytics.
- **Audit:** Optional log of “profile read” for clienteling (who, when, customer_id) for compliance; minimal and anonymized where possible.

## 26. Testing Requirements

- **Unit:** Affinity/preference computation from sample events; consent check; cold start response.
- **Integration:** Ingest sample events → run profile update → read profile → verify F9 receives expected fields. Consent withdrawal → read returns empty for personalization.
- **Contract:** Profile API schema for F9 and F23.

## 27. Recommended Architecture

- **Component:** Part of “Customer profile” in architecture (separate from ingestion). Can be same process as F9 or dedicated service; dedicated recommended for scale and consent isolation.
- **Pattern:** Event-driven or batch: consume events → compute/update profile → store. Read-through cache for request path.

## 28. Recommended Technical Design

- **Store:** Key-value or document store (customer_id → profile JSON). **Update:** Batch job (Spark, etc.) or stream (Kafka consumer) with idempotent upsert. **API:** Sync GET with cache. **Consent:** Check F22 or local consent flag before returning profile for personalization/clienteling.

## 29. Suggested Implementation Phasing

- **Phase 1:** Batch profile build from orders and views; simple affinity and preferences; read API for F9; cold start and consent (empty return). Coverage metric.
- **Phase 2:** Near real-time update; segmentation; intent signals; optional profile display in clienteling (F23) with consent.
- **Later:** Advanced intent model; historical snapshots; A/B on profile signals (F24).

## 30. Summary

**Customer profile service** (F7) builds and maintains the **Customer Style Profile** from behavioral events (F2) and identity (F4). It exposes a **read API** for the **recommendation engine** (F9) and optionally **clienteling** (F23). Profile includes preferences, affinity, segmentation, and intent; one active profile per customer. **Consent** (F22) must be respected (empty or no-use for personalization when opted out). Cold start and service failure must not break the recommendation API; F9 falls back to non-personal strategies. BR-3 success metrics: profile coverage and personal recommendation lift.
