# Feature Deep-Dive: Behavioral Event Ingestion (F2)

**Feature ID:** F2  
**BR(s):** BR-2 (Data ingestion and identity)  
**Capability:** Ingest customer behavioral data  
**Source:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`, `docs/project/data-standards.md`

---

## 1. Purpose

Capture orders, browsing, cart actions, store visits, appointments, and email engagement from source systems so the platform can build **customer style profiles** (F7) and support **attribution** of recommendation outcomes (impression, click, add-to-cart, purchase). Behavioral data is the primary input for personalization and for measuring recommendation performance.

## 2. Core Concept

An **event pipeline** that:
- Ingests behavioral events from ecommerce, POS, store systems, and email/CRM.
- Normalizes to a **canonical event schema** (event name, timestamp, customer/session identifier, channel, anchor product/look where relevant; for recommendation outcomes: recommendation set ID and trace ID).
- Delivers events to the **customer profile service** (F7) for profile build and to **analytics/telemetry** (F12, F17) for attribution.
- Supports **real-time or near real-time** latency where required (SLA TBD).

## 3. Why This Feature Exists

- **BR-2** requires customer behavioral data to be ingested and kept up to date.
- **BR-3** (customer profile) depends on orders, browsing, store visits, and stated interests—all supplied by this pipeline.
- **BR-10** (analytics and attribution) requires outcome events (impression, click, add-to-cart, purchase, dismiss) with recommendation set ID and trace ID; those events flow through this pipeline or a dedicated telemetry path that shares the same schema and identity.

## 4. User / Business Problems Solved

- **Returning / style-seeking customers:** Enables personalized recommendations via profile built from behavior.
- **CRM / Merchandising:** Enables targeting and performance measurement.
- **Product/Engineering:** Single event schema and pipeline so profile and analytics do not each integrate directly with every source.

## 5. Scope

### 6. In Scope

- **Event types:** Product view, add-to-cart, remove-from-cart, checkout started, order completed, search, category view, store visits, appointments, email engagement (open, click). **Outcome events:** impression, click, add-to-cart, purchase, dismiss (with set ID and trace ID).
- **Sources:** Ecommerce (web/mobile), POS, store/CRM (visits, appointments), email/CRM (engagement). Exact systems are a missing decision.
- **Canonical schema:** event_name, event_timestamp, customer_id (when resolved) or session_id, channel, placement (if applicable), anchor product_id or look_id, optional cart/order payload; for outcomes: recommendation_set_id, trace_id.
- **Latency:** Real-time or near real-time as defined in SLA; at least sufficient for profile build and attribution reporting within agreed window.
- **Identity:** Events may arrive with anonymous session, logged-in user ID, or POS/email identifiers; **identity resolution (F4)** produces canonical customer_id; this pipeline stores or forwards both raw and resolved identifiers as required for profile and attribution.

### 7. Out of Scope

- **Identity resolution logic** — owned by F4; this feature ingests and passes identifiers; may call F4 or consume resolved IDs from a shared store.
- **Profile computation** — owned by F7; this feature delivers events, not profile outputs.
- **Recommendation logic** — no recommendation generation here; only event ingestion and routing.

## 8. Main User Personas

- **Returning Customer / Style-Seeking Customer** — Indirect; behavior is captured to improve their recommendations.
- **CRM / Merchandising / Product** — Indirect; data enables targeting and reporting.
- **Backend/Data engineers** — Build and operate the pipeline.

## 9. Main User Journeys

- **Event flow:** User (or system) generates event in source (e.g. “add to cart” on web) → source emits to platform (API, queue, or batch) → pipeline normalizes and enriches (e.g. resolve session to customer_id) → events written to event store / stream → F7 and F12/F17 consume.
- **Batch backfill:** Historical events loaded for profile build or analytics; same schema; idempotent where possible (e.g. by event_id).

## 10. Triggering Events / Inputs

- **Real-time:** API or message queue receiving events from web, app, POS, email system.
- **Batch:** File or bulk API from source systems (e.g. nightly order export).
- **Inputs:** event payload (source event type, timestamp, identifiers, context); optional correlation IDs for deduplication.

## 11. States / Lifecycle

- **Event:** Received → Validated → Enriched (e.g. customer_id resolved) → Persisted / Published → Consumed by F7 and/or analytics. Failed events → dead-letter or retry with alert.
- **Pipeline:** Healthy / Degraded / Failing (for monitoring).

## 12. Business Rules

- **Schema:** All events must conform to canonical schema; unknown or optional fields allowed in a flexible payload but required fields must be present.
- **Recommendation outcomes:** Must include recommendation_set_id and trace_id when the event is the result of a recommendation (impression, click, add-to-cart, purchase, dismiss). Per BR-10 and data standards.
- **Privacy:** Only ingest and store data permitted for the use case and region; consent and opt-out respected (see F22). No PII in logs beyond what is required for pipeline ops (e.g. hashed or redacted).

## 13. Configuration Model

- **Per-source:** Endpoint or topic, auth, event type mapping (source → canonical), which events to ingest.
- **Routing:** Which event types go to profile service vs analytics vs both; retention and partitioning.
- **Feature flags:** Enable/disable sources or event types.

## 14. Data Model

- **Canonical event (log/store):** event_id, event_name, event_timestamp, customer_id (nullable), session_id, channel, placement, anchor_product_id, anchor_look_id, recommendation_set_id, trace_id, payload (JSON), source_system, ingested_at.
- **Outcome events:** Same plus explicit type (impression, click, add_to_cart, purchase, dismiss).
- **Mapping:** Source event types → canonical event_name; source identifiers → session_id / customer_id after resolution.

## 15. Read Model / Projection Needs

- **Customer profile service (F7):** Consumes event stream or queryable store for profile build (orders, views, cart, etc.).
- **Recommendation telemetry (F12) / Analytics (F17):** Consume outcome events and optionally full behavioral stream for CTR, conversion, attribution.
- **Identity resolution (F4):** May consume raw events for resolution; or receives identifiers from this pipeline and returns customer_id for enrichment.

## 16. APIs / Contracts

- **Inbound (ingestion):** `POST /events` or queue message with body conforming to canonical schema (or source-specific with adapter). Response: 202 Accepted, event_id or correlation_id.
- **Internal (to F7/F12):** Stream or query API; contract is canonical event schema and guarantee (at-least-once or exactly-once as designed).
- **Example request (simplified):**

```json
POST /events
{
  "event_name": "product_view",
  "event_timestamp": "2025-03-17T12:00:00Z",
  "session_id": "sess-abc",
  "customer_id": "cust-123",
  "channel": "webstore",
  "placement": "pdp",
  "anchor_product_id": "prod-456",
  "source_system": "web"
}
→ 202 Accepted
{ "event_id": "evt-xyz" }
```

**Outcome event (with attribution):**

```json
{
  "event_name": "recommendation_click",
  "event_timestamp": "2025-03-17T12:01:00Z",
  "session_id": "sess-abc",
  "customer_id": "cust-123",
  "recommendation_set_id": "set-789",
  "trace_id": "trace-012",
  "anchor_product_id": "prod-456",
  "clicked_product_id": "prod-999"
}
```

## 17. Events / Async Flows

- **Consumed:** Incoming events from sources (push or pull).
- **Emitted (internal):** Normalized events to event store or stream; optionally `BehavioralEventIngested` for downstream subscribers. F7 and F12/F17 consume from store or stream.
- **Flow:** Ingest → validate → enrich (identity) → persist/publish → (async) profile and analytics consume.

## 18. UI / UX Design

- **Admin (optional):** Event pipeline health, throughput, error rates, recent failures. No customer-facing UI.
- **Monitoring:** Dashboards for event volume, latency, dead-letter count, consumer lag.

## 19. Main Screens / Components

- Pipeline status, event volume by type/source, error log, schema/docs for producers. Operational only.

## 20. Permissions / Security Rules

- **Ingestion endpoint:** Authenticated; only trusted sources (web backend, POS bridge, email/CRM connector). No public unauthenticated ingestion of behavioral data.
- **Access to event store:** Restricted; profile service and analytics have read access; no raw export to unauthorized systems. PII handling per F22.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Pipeline failure, schema validation failure spike, consumer lag above threshold, dead-letter growth.
- **Side effects:** Profile service updates profiles; analytics update aggregates and attribution. No direct side effect on recommendation API response time (async consumption).

## 22. Integrations / Dependencies

- **Upstream:** Ecommerce platform, POS, store/CRM (visits, appointments), email/CRM. Exact systems TBD.
- **Downstream:** Identity resolution (F4) for customer_id; Customer profile service (F7); Recommendation telemetry (F12) and Core analytics (F17).
- **Shared:** Canonical event schema from `docs/project/data-standards.md` and architecture overview §4.2; recommendation set ID and trace ID from API standards.

## 23. Edge Cases / Failure Cases

- **Duplicate events:** Dedupe by event_id or (source_id, timestamp, session); at-least-once acceptable for some consumers (e.g. profile can be idempotent).
- **Late-arriving events:** Out-of-order and late events; profile and attribution may need watermarking or windowing; define policy (e.g. ignore events older than N days for profile).
- **Missing recommendation_set_id/trace_id on outcome events:** Reject or quarantine; alert; do not attribute to recommendations without IDs.
- **Source down:** Buffer or backpressure; do not lose events; retry and alert.
- **Schema evolution:** Version event schema; support backward compatibility for consumers.

## 24. Non-Functional Requirements

- **Throughput:** Scale to event volume from web, POS, email (volume TBD).
- **Latency:** End-to-end from source to consumable by F7 within SLA (e.g. seconds to minutes for real-time).
- **Retention:** Event retention period for profile and analytics (e.g. 90 days raw; aggregates indefinitely); align with privacy and storage policy.
- **Security:** TLS in transit; encryption at rest; no PII in logs.

## 25. Analytics / Auditability Requirements

- **Audit:** Log pipeline runs and failure reasons; no PII in audit logs. Metrics: ingest rate, error rate, consumer lag.
- **Attribution:** Outcome events with set_id and trace_id are the basis for BR-10 attribution; pipeline must preserve and deliver them reliably.

## 26. Testing Requirements

- **Unit:** Validation logic, schema mapping, enrichment (e.g. identity lookup).
- **Integration:** Ingest sample events; verify delivery to F7 and analytics; verify outcome events include set_id/trace_id.
- **Contract:** Canonical schema and outcome event contract for producers (web, email, clienteling).
- **Failure:** Invalid payload, missing required fields, duplicate events; assert no data loss and correct routing to dead-letter or retry.

## 27. Recommended Architecture

- **Component:** Part of “Ingestion & events” layer. Event pipeline can be a dedicated service (API + workers) or stream-processing (e.g. Kafka, Kinesis) with adapters per source.
- **Pattern:** Ingest → validate → enrich (identity) → persist/stream → consumers (F7, F12/F17). Decouple ingestion from consumption so backlog does not block ingestion.

## 28. Recommended Technical Design

- **Ingestion API or connector** per source; **schema registry** or shared library for canonical schema; **identity enrichment** via call to F4 or lookup; **event store or stream** with partitioning by customer_id or time; **consumers** for profile and analytics. Idempotent writes where possible (e.g. event_id).

## 29. Suggested Implementation Phasing

- **Phase 1:** Core event types (view, add-to-cart, purchase, order completed); one primary source (ecommerce); canonical schema; delivery to profile service and a simple analytics sink; outcome events with set_id/trace_id from web widgets.
- **Phase 2:** POS, store visits, appointments, email engagement; additional sources; retention and partitioning; monitoring and alerting.
- **Later:** Exactly-once semantics if required; replay and backfill tooling.

## 30. Summary

Behavioral event ingestion (F2) captures orders, browsing, cart actions, store visits, appointments, and email engagement into a canonical event pipeline. It feeds the customer profile service (F7) for personalization and telemetry/analytics (F12, F17) for attribution. Outcome events must carry recommendation set ID and trace ID. Identity resolution (F4) enriches events with customer_id; F2 does not perform resolution but depends on it for full value. The pipeline must meet latency and throughput requirements and respect privacy and consent (F22).
