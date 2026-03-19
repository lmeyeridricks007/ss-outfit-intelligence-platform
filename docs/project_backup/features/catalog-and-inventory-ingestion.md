# Feature Deep-Dive: Catalog and Inventory Ingestion (F1)

**Feature ID:** F1  
**BR(s):** BR-2 (Data ingestion and identity)  
**Capability:** Ingest product and catalog data  
**Source:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Ingest and sync product catalog, inventory, and product metadata from source systems (PIM, Shopify, OMS, DAM, Custom Made) so the product graph, outfit graph, and recommendation engine use a current, shoppable assortment. This feature is the foundation for all product-based recommendations; without fresh catalog data, the engine cannot recommend in-stock, correct items.

## 2. Core Concept

A **catalog and inventory ingestion** pipeline that:
- Pulls or receives product and inventory data from committed source systems.
- Normalizes to a canonical **Product** domain (per `docs/project/domain-model.md` and `docs/project/data-standards.md`).
- Keeps data fresh within agreed SLA (e.g. catalog &lt; 24h; inventory refresh frequency TBD).
- Feeds the **product graph** (F5) and **outfit graph / look store** (F6); does not replace PIM/OMS—it integrates with them.

## 3. Why This Feature Exists

- **BR-2** requires product catalog and behavioral/context data to be ingested and kept up to date.
- Recommendations must be **shoppable**: wrong or out-of-stock items damage trust and conversion. Catalog and inventory are the source of truth for what can be recommended.
- The product graph (relationships, compatibility) and looks (curated product sets) depend on canonical product records; ingestion is the entry point for that data.

## 4. User / Business Problems Solved

- **Merchandising (indirect):** Ensures recommendations reflect current assortment and availability.
- **All channels:** PDP, cart, homepage, email, clienteling all show products; stale or missing data would break widgets and attribution.
- **Product/Engineering:** Single canonical product domain so downstream systems (graph, engine, API) do not each integrate directly with PIM/OMS.

## 5. Scope

### 6. In Scope

- Connectors or APIs to **PIM**, **Shopify**, **OMS**, **DAM**, **Custom Made** (exact systems are a missing decision; design for multi-source).
- **Full and incremental (delta)** sync of product attributes: `product_id`, category, fabric, color, pattern, fit, season, occasion, price tier, style family, RTW/CM applicability.
- **Inventory/availability** at the level required for recommendation filtering (e.g. by channel or region if needed).
- **Normalization** to canonical IDs and schema; mapping from source-system IDs to platform `product_id`.
- **Lifecycle:** New, updated, discontinued/retired products; handling of soft deletes where applicable.
- **Data quality:** Validation and logging of failures; optional quarantine for bad records.
- **SLA:** Data freshness within agreed window (e.g. catalog &lt; 24h; inventory latency TBD).

### 7. Out of Scope

- **Replacing** PIM or OMS; this is integration only.
- **Authoring** product content (that stays in PIM); this feature only ingests.
- **Real-time** per-transaction inventory (unless explicitly required); near real-time or scheduled refresh is typical.
- **Pricing/promotions** as a separate domain (can be in scope if needed for rules; otherwise defer).

## 8. Main User Personas

- **Merchandising Manager** — Indirect; benefits from correct, up-to-date products in recommendations.
- **Product Manager / Architect** — Needs reliable pipeline and SLA for build/ops.
- **Backend/Data engineers** — Implement and operate connectors and normalization.

## 9. Main User Journeys

- **Scheduled sync:** Job runs on schedule (e.g. nightly full, hourly delta); pulls from each source; normalizes and writes to canonical store; product graph and look store consume from that store.
- **On-demand refresh:** Admin or system triggers a sync for a source or category (e.g. after a bulk upload in PIM).
- **Failure handling:** Connector or validation failure triggers alert; bad records logged/quarantined; retry and backfill procedures.

## 10. Triggering Events / Inputs

- **Scheduled:** Cron or workflow trigger (e.g. every N hours).
- **Event-driven (if supported):** Webhook or message from source system on product/inventory change (optional; reduces latency).
- **On-demand:** API or admin action to trigger sync for a given source or scope.
- **Inputs:** Source system credentials, endpoint URLs, scope (full vs delta), last-sync cursor/timestamp.

## 11. States / Lifecycle

- **Product record:** Draft (first seen) → Active → Updated (versioned) → Discontinued/Retired (optional).
- **Sync run:** Queued → In progress → Completed (success / partial / failed).
- **Connector:** Healthy / Degraded / Failing (for monitoring and alerting).

## 12. Business Rules

- Canonical `product_id` is stable; source IDs map to it once and do not change for the same logical product.
- Discontinued or retired products are either excluded from recommendation candidate pool or flagged so rules can hide them.
- Inventory below threshold (e.g. 0 or region-specific) can be used to filter recommendations (see merchandising rules and context engine).
- Data freshness SLA is contractual; breaches should be visible in monitoring and optionally block recommendation refresh for affected categories (policy decision).

## 13. Configuration Model

- **Per-source config:** Endpoint, auth, sync frequency, scope (full/delta), mapping (source ID → canonical, source attributes → canonical schema).
- **Global:** Default refresh interval, retry policy, quarantine rules, SLA thresholds.
- **Feature flags:** Enable/disable specific sources or sync types without code change.

## 14. Data Model

- **Product (canonical):** `product_id`, source_system, source_id, category, fabric, color, pattern, fit, season, occasion, price_tier, style_family, rtw_applicable, cm_applicable, created_at, updated_at, status (active/retired), optional version.
- **Inventory (if stored here):** product_id, location/region (optional), quantity or availability flag, last_updated.
- **Sync metadata:** source_id, last_sync_at, cursor/token, status, record_count, error_message (on failure).
- **Mapping table:** source_system + source_product_id → canonical product_id (immutable once set).

## 15. Read Model / Projection Needs

- **Product graph (F5)** and **outfit graph (F6)** read from the canonical product store (or event stream). Ingestion publishes normalized product events or writes to a store that those features read.
- **Recommendation engine** and **merchandising rules** need product and optionally inventory; they consume via graph or direct read, not from raw source systems.
- **Analytics** may need product dimensions (category, etc.) for reporting; typically from same canonical store.

## 16. APIs / Contracts

- **Internal:** Job or service API to trigger sync (e.g. `POST /internal/ingestion/catalog/sync` with body `{ "source": "pim", "scope": "full|delta" }`). Response: job_id, status.
- **Source systems:** Outbound calls to PIM/Shopify/OMS/DAM/Custom Made (REST or batch file); contract depends on each system. Prefer pagination and delta endpoints where available.
- **Downstream:** Either **events** (e.g. `ProductCreated`, `ProductUpdated`, `ProductRetired`) or **database/store** that product graph and look store read. Contract: canonical schema and IDs.

**Example internal trigger:**

```json
POST /internal/ingestion/catalog/sync
{ "source": "shopify", "scope": "delta", "since": "2025-03-15T00:00:00Z" }
→ 202 Accepted
{ "job_id": "sync-abc-123", "status": "queued" }
```

## 17. Events / Async Flows

- **Emitted (if event-driven):** `Catalog.ProductIngested` or per-entity `ProductCreated`/`ProductUpdated`/`ProductRetired` with payload: product_id, key attributes, timestamp. Consumers: product graph, outfit graph, cache invalidation.
- **Consumed:** Optional webhooks from sources (e.g. “product updated”) to trigger incremental sync.
- **Async flow:** Trigger → fetch from source → normalize → validate → write/emit → update sync metadata; on failure → alert and optionally retry.

## 18. UI / UX Design

- **Admin (optional in Phase 1):** “Data ingestion” or “Connectors” screen: list sources, status (last sync, success/fail), manual “Sync now,” view recent errors. Not required for Phase 1 (file/config-driven is acceptable).
- **Monitoring/ops:** Dashboards for sync latency, record counts, error rates, SLA compliance.

## 19. Main Screens / Components

- Connector status cards; sync history table; error log; configuration form (per source). Details depend on whether admin UI is in scope for F1 or deferred.

## 20. Permissions / Security Rules

- **Trigger sync:** Restricted to internal services or admin role; no customer-facing endpoint.
- **Credentials:** Source system credentials stored securely (e.g. secrets manager); not logged or exposed.
- **Data:** Product data is not PII; access control is by role (admin/ops can view sync status and errors).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Sync failure, SLA breach (catalog older than N hours), spike in validation failures.
- **Side effects:** Product graph and look store update when new data arrives; recommendation engine may need cache refresh or event-driven update so it serves fresh data.

## 22. Integrations / Dependencies

- **Upstream:** PIM, Shopify, OMS, DAM, Custom Made (exact list and ownership are missing decisions).
- **Downstream:** Product graph (F5), Outfit graph and look store (F6). Recommendation engine (F9) and Delivery API (F11) consume via graph, not directly from ingestion.
- **Shared:** Canonical ID and schema from `docs/project/domain-model.md` and `docs/project/data-standards.md`; identity not required for this feature.

## 23. Edge Cases / Failure Cases

- **Source unavailable:** Retry with backoff; do not overwrite last good state with empty data; alert after N failures.
- **Schema change in source:** Mapping may break; validation should catch unexpected fields/missing required; version mapping or fallback.
- **Duplicate source IDs:** Dedupe by (source_system, source_id); first-write wins or defined rule for canonical id.
- **Large backfill:** Paginate; consider batch size and downstream load (e.g. graph rebuild).
- **Partial failure:** Mark sync as partial; record which entities failed; allow retry of failed slice only if supported.

## 24. Non-Functional Requirements

- **Throughput:** Handle full catalog sync within maintenance window (size TBD).
- **Latency:** Delta sync completion within SLA (e.g. &lt; 1h from source change).
- **Availability:** Ingestion pipeline failure should not take down recommendation API; recommendation can serve from last good state.
- **Security:** Credentials and secrets not logged; outbound calls over TLS.

## 25. Analytics / Auditability Requirements

- **Audit:** Log sync runs (who/what triggered, start/end time, record counts, status). No PII.
- **Metrics:** Sync duration, records ingested, validation errors, SLA compliance; exportable for reporting.

## 26. Testing Requirements

- **Unit:** Normalization logic (source → canonical); mapping; validation rules.
- **Integration:** Test connector against stub or sandbox for each source type; full and delta flows.
- **Contract:** Contract tests for canonical product schema and event payloads consumed by F5/F6.
- **Failure:** Simulate source down, invalid payload, duplicate IDs; assert no data corruption and alerting.

## 27. Recommended Architecture

- **Component:** Part of “Ingestion & events” layer (architecture overview). Separate service or job from recommendation runtime so source outages do not affect API.
- **Pattern:** ETL or event-driven: extract from sources → transform/normalize → load to canonical store or emit events. Prefer idempotent writes.
- **Storage:** Canonical product store (DB or data lake); optionally event log for replay and downstream consumers.

## 28. Recommended Technical Design

- One **orchestrator** (scheduler + trigger) and per-source **connectors** (adapters). Shared **normalizer** and **validator** against canonical schema. **Idempotent** writes using product_id; upsert semantics for updates.
- **Technology:** Align with project stack (e.g. serverless jobs, or Kubernetes jobs, or streaming). Prefer incremental/delta where sources support it to reduce load and latency.

## 29. Suggested Implementation Phasing

- **Phase 1 (MVP):** One primary source (e.g. Shopify or PIM), full sync + simple delta if available; canonical store; feed to product graph. No admin UI required (config-driven).
- **Phase 2:** Additional sources (OMS, DAM, Custom Made); admin view for status and manual trigger; SLA monitoring and alerts.
- **Later:** Real-time or near real-time webhooks if required; inventory at region level if needed for rules.

## 30. Summary

Catalog and inventory ingestion (F1) is the pipeline that keeps product and availability data current in the platform. It integrates with PIM, Shopify, OMS, DAM, and Custom Made (as committed), normalizes to a canonical Product domain, and feeds the product graph and look store. It is triggered on schedule or on demand, supports full and delta sync, and must meet data freshness SLA. Downstream features (F5, F6, F9, F11) depend on it; it does not replace source systems and does not expose customer data.
