# Feature Deep-Dive: Recommendation Telemetry (F12)

**Feature ID:** F12  
**BR(s):** BR-10 (Analytics and optimization)  
**Capability:** Measure recommendation performance and attribution  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/data-standards.md`

---

## 1. Purpose

**Capture outcome events** (impression, click, add-to-cart, purchase, dismiss) with **recommendation set ID** and **trace ID** so analytics can measure **CTR, add-to-cart rate, conversion, revenue attribution, and AOV** by placement and strategy (BR-10). Telemetry is the pipeline that receives these events from channels and delivers them to the **analytics and reporting** layer (F17).

## 2. Core Concept

- **Outcome events:** Every time a recommendation is shown (impression), clicked (click), added to cart (add-to-cart), purchased (purchase), or dismissed (dismiss), the **channel** (web, email, clienteling) sends an event that includes **recommendation_set_id** and **trace_id** from the Delivery API (F11) response. Events may also include placement, channel, product_id/look_id clicked, order_id (for purchase), and revenue.
- **Telemetry feature:** (1) **Ingest** outcome events (API or queue) with a **canonical schema**. (2) **Validate** (set_id, trace_id required). (3) **Store** or **forward** to analytics store (data warehouse, stream) for F17 reporting and attribution. (4) Optionally **enrich** (e.g. resolve trace_id to placement/strategy). Does not compute metrics; F17 does. F12 is the **event pipeline** for recommendation outcomes, aligned with behavioral event ingestion (F2) schema where outcome events are a subset.

## 3. Why This Feature Exists

- **BR-10:** Recommendation performance must be measured (impression, click, add-to-cart, purchase, dismiss) with set_id and trace_id; core metrics (CTR, conversion, revenue attribution, AOV) depend on these events.
- **Architecture:** Event pipeline and data standards require outcome events to carry set_id and trace_id; telemetry ensures they are collected and available for analytics.
- **Attribution:** Without set_id/trace_id on every outcome, revenue and conversion cannot be attributed to recommendation placements (last-click or other model in F17).

## 4. User / Business Problems Solved

- **Merchandising / CRM / Product:** See which placements and strategies perform; optimize and report.
- **Channels:** Single place to send outcome events; consistent schema.
- **Compliance:** Audit trail of what was shown and what was clicked (with set_id/trace_id); no PII in event payload beyond customer_id if required for attribution.

## 5. Scope

### 6. In Scope

- **Event types:** recommendation_impression, recommendation_click, recommendation_add_to_cart, recommendation_purchase, recommendation_dismiss. Each must include recommendation_set_id and trace_id (from F11 response). Optional: placement, channel, product_id, look_id, position, order_id, revenue, customer_id (for attribution). Schema per data-standards and architecture §4.2.
- **Ingestion:** API (e.g. POST /events/outcomes) or message queue consumed by telemetry service. Channels (web frontend, email system, clienteling app) send events after user action. At-least-once delivery; idempotency by event_id if supported.
- **Validation:** Reject or quarantine events missing set_id or trace_id; do not drop silently; alert on high reject rate.
- **Storage/forwarding:** Write to event store (same as F2 or dedicated) or stream (Kafka, Kinesis) for F17 to consume. Retention per policy (e.g. 2 years for attribution).
- **No PII in event body** beyond customer_id if required for attribution; hash or scope per policy. Do not log full event with PII.

### 7. Out of Scope

- **Computing metrics** (CTR, conversion, revenue) — F17. F12 only collects and stores/forwards events.
- **Delivery API** — F11 returns set_id/trace_id; F12 does not call F11. Channels are responsible for sending events with IDs from F11 response.
- **Behavioral events** (view, add-to-cart not from recommendation) — F2. F12 is **recommendation outcome** events only. F2 may share same event pipeline with a different event_type; then F12 is the schema and validation for outcome events.
- **A/B assignment** — F24. Events may include experiment_id; F24 uses events for experiment reporting. F12 does not assign experiments.

## 8. Main User Personas

- **Merchandising Manager, CRM, Product Manager** — Benefit from reporting (F17) that uses this data.
- **Frontend/backend engineers** — Implement event sending from channels; implement ingestion and validation in F12.
- **Data/analytics engineers** — Build F17 on top of this event stream.

## 9. Main User Journeys

- **Impression:** Widget renders with recommendations (from F11) → frontend sends recommendation_impression with set_id, trace_id, placement, item_ids (or list) → F12 receives, validates, stores/forwards.
- **Click:** User clicks item → frontend sends recommendation_click with set_id, trace_id, product_id or look_id, position → F12 receives, validates, stores.
- **Purchase:** Checkout completes; backend or frontend sends recommendation_purchase with set_id, trace_id, order_id, revenue (optional), line items that came from recommendations → F12 receives, validates, stores. Attribution model (F17) may use order_id to attribute revenue to last or first recommendation click.
- **Dismiss:** User dismisses widget or item → recommendation_dismiss with set_id, trace_id → F12 receives, stores (for engagement and diversity metrics).

## 10. Triggering Events / Inputs

- **Event-driven.** Inputs: outcome event payload from channels. No scheduled trigger for ingestion; only consumers (F17) may run batch or stream jobs on stored events.

## 11. States / Lifecycle

- **Event:** Received → Validated → Stored/Forwarded. Invalid (missing set_id/trace_id) → Rejected or quarantined; alert.
- **Pipeline:** Healthy / Degraded (e.g. consumer lag) / Failing. No state machine for events; append-only log.

## 12. Business Rules

- **Set ID and trace ID required:** Reject or quarantine events without both. Do not accept “null” for attribution-critical events (impression, click, purchase).
- **Schema:** Conform to canonical outcome event schema (event_name, event_timestamp, recommendation_set_id, trace_id, placement, channel, optional product_id, look_id, position, order_id, revenue, customer_id). Per data-standards.
- **Idempotency:** If channel sends duplicate (e.g. double-click), store once or dedupe by (trace_id, event_type, product_id, timestamp) so attribution is not double-counted. Define policy.
- **Privacy:** customer_id in event only if required for attribution and permitted; retention and access per F22 and data policy.

## 13. Configuration Model

- **Schema version:** Support v1 outcome schema; future versions for new fields. Validation rules: required fields per event type.
- **Retention:** How long to keep raw events; aggregation retention in F17.
- **Quarantine:** Rules for invalid events (retry, discard, alert). Feature flags: strict validation (reject) vs quarantine.

## 14. Data Model

- **Outcome event (canonical):** event_id, event_name (impression|click|add_to_cart|purchase|dismiss), event_timestamp, recommendation_set_id, trace_id, placement, channel, product_id (optional), look_id (optional), position (optional), order_id (optional), revenue (optional), customer_id (optional), session_id (optional), ingested_at, source (web|email|clienteling).
- **Validation result:** event_id, valid (boolean), errors (array). Invalid events logged and optionally quarantined in separate store.

## 15. Read Model / Projection Needs

- **Core analytics and reporting (F17):** Primary consumer. Reads event stream or queryable store to compute CTR, add-to-cart rate, conversion, revenue attribution, AOV by placement, strategy, experiment. May aggregate into tables or real-time dashboards.
- **A/B and experimentation (F24):** Reads events with experiment_id to compute experiment metrics.
- **No other consumers** of raw outcome events for product features; internal analytics and ops only.

## 16. APIs / Contracts

- **Inbound (from channels):** `POST /events/outcomes` with body = array or single event: { event_name, event_timestamp, recommendation_set_id, trace_id, placement, channel, product_id?, look_id?, position?, order_id?, revenue?, customer_id?, session_id? }. Response: 202 Accepted, event_id(s); or 400 if validation fails (missing set_id/trace_id).
- **Example:**

```json
POST /events/outcomes
{
  "event_name": "recommendation_click",
  "event_timestamp": "2025-03-17T12:01:00Z",
  "recommendation_set_id": "set-uuid-1",
  "trace_id": "trace-uuid-1",
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "product_id": "prod-shirt-1",
  "position": 2
}
→ 202 Accepted
{ "event_id": "evt-xyz" }
```

- **Internal (to F17):** Stream or query API to read events. Contract: same schema; batch or stream. No public read API for raw events.

## 17. Events / Async Flows

- **Consumed:** Outcome events from channels (push to API or queue).
- **Emitted (optional):** OutcomeEventIngested (event_id, event_name) for downstream F17 trigger or audit. Or F17 polls/consumes stream.
- **Flow:** Channel → POST or queue → F12 validate → store/forward → F17 consumes.

## 18. UI / UX Design

- **None.** Backend pipeline only. Reporting UI is F17. Optional ops: event volume dashboard, validation failure count.

## 19. Main Screens / Components

- None. Monitoring dashboard only (event rate, validation errors, consumer lag).

## 20. Permissions / Security Rules

- **Ingestion:** Authenticated; only trusted channel backends or frontends (with API key or server-side only). Do not allow unauthenticated public POST (would allow fake events). For client-side (web), use backend-for-frontend that forwards with server auth.
- **Read (event store):** Restricted to F17 and analytics; no external access. PII (customer_id) in events; access control and retention per F22.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Validation failure rate above threshold; missing set_id/trace_id spike; consumer lag (F17); pipeline down.
- **Side effects:** F17 reports and attribution depend on this pipeline; missing or invalid events cause undercount or wrong attribution.

## 22. Integrations / Dependencies

- **Upstream:** Channels (web F13–F15, email F16, clienteling F23) send events. Delivery API (F11) provides set_id and trace_id that channels must attach.
- **Downstream:** Core analytics and reporting (F17); A/B (F24) for experiment events.
- **Shared:** data-standards (event schema, set_id, trace_id); architecture §4.2 (outcome events); BR-10.

## 23. Edge Cases / Failure Cases

- **Duplicate events:** Dedupe by (trace_id, event_type, product_id, timestamp) or event_id; do not double-count in F17.
- **Late events:** Purchase may arrive days later; F17 attribution window (e.g. 30 days) should include late events; store with event_timestamp and ingested_at; F17 uses event_timestamp for attribution.
- **Invalid event (no set_id):** Reject 400 or quarantine; do not store in main stream; alert. Channels must fix.
- **Backlog:** If F12 cannot keep up, buffer (queue); do not drop. Monitor consumer lag.
- **Schema evolution:** New optional fields; backward compatible. Required fields (set_id, trace_id) never removed.

## 24. Non-Functional Requirements

- **Throughput:** Scale to event volume from all channels (impressions can be high). Accept at least N events/sec (TBD).
- **Latency:** Events available to F17 within N minutes (e.g. 5 min for batch; or real-time stream). Define SLA.
- **Retention:** Raw events retained for attribution window (e.g. 2 years) or per policy; comply with privacy (F22).
- **Security:** TLS in transit; encryption at rest; no PII in logs.

## 25. Analytics / Auditability Requirements

- **Audit:** Log ingestion count, validation failure count; no PII in audit. Pipeline run metrics for ops.
- **Attribution:** Events are the source of truth for “revenue from recommendations”; F17 applies attribution model; F12 must not drop valid events.

## 26. Testing Requirements

- **Unit:** Validation (required fields, set_id/trace_id present); schema mapping.
- **Integration:** Send sample events (impression, click, purchase) → verify stored and queryable by F17; send invalid event → verify reject or quarantine. Contract: event schema for channels.
- **E2E:** Widget (F13) gets response from F11 → sends impression/click → F12 receives → F17 query returns event (optional).

## 27. Recommended Architecture

- **Component:** Part of “Ingestion & events” layer with F2, or dedicated “outcome events” pipeline. Can share event store with F2 with event_type filter for “recommendation_*”.
- **Pattern:** Ingest (API or queue) → validate → persist to event store or stream → F17 consumes. Same pattern as F2; outcome events are a subset of behavioral with required set_id/trace_id.

## 28. Recommended Technical Design

- **Ingestion API or queue** (Kafka topic, Kinesis stream, or REST). **Validator** (schema + required set_id/trace_id). **Event store** (append-only log or stream). **Consumer** (F17 batch or stream). **Quarantine store** for invalid events; **alerting** on reject rate. **Deduplication** in F17 or in F12 (event_id or (trace_id, event_type, product_id, timestamp)).

## 29. Suggested Implementation Phasing

- **Phase 1:** POST /events/outcomes with impression, click; validate set_id/trace_id; store to same store as F2 or dedicated table; F17 can query. Documentation for channels to send events with IDs from F11.
- **Phase 2:** add_to_cart, purchase, dismiss; revenue and order_id for attribution; deduplication; stream for real-time F17; retention and privacy (customer_id hashing if needed).
- **Later:** Schema versioning; backfill tooling; experiment_id in events for F24.

## 30. Summary

**Recommendation telemetry** (F12) **captures outcome events** (impression, click, add-to-cart, purchase, dismiss) with **recommendation set ID** and **trace ID** from channels and **stores/forwards** them for **analytics and attribution** (F17). Events must include set_id and trace_id; invalid events are rejected or quarantined. F12 does not compute metrics; F17 does. Channels are responsible for sending events after every recommendation impression and user action, using IDs from the Delivery API (F11) response. BR-10 and data-standards are satisfied; retention and privacy (F22) must be applied to event storage and access.
