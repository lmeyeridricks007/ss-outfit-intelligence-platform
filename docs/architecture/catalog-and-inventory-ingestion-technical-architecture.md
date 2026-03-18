# Technical Architecture: Catalog and Inventory Ingestion

**TA ID:** TA-006
**Feature:** FEAT-001 / F1 — Catalog and inventory ingestion
**Upstream artifact:** `docs/features/catalog-and-inventory-ingestion.md`
**Source:** `docs/project/architecture-overview.md`, `docs/project/domain-model.md`, `docs/project/data-standards.md`, `docs/project/integration-standards.md`, `docs/project/business-requirements.md`, `docs/project/roadmap.md`
**Traceability:** Downstream of approved feature breakdown; feeds `docs/boards/implementation-plan.md`, F5 product graph, F6 outfit graph and look store, and later F10/F11 inventory-aware recommendation paths.
**Status:** Drafted for architecture-stage review.
**Review:** Architecture-stage artifact; assess per `docs/.cursor/prompts/review-pass.md` and the project review rules.
**Approval mode:** HUMAN_REQUIRED
**Trigger:** issue-created automation (GitHub issue #27)

---

## 1. Scope and architecture objectives

This architecture defines the implementation-oriented design for ingesting catalog, inventory, attach, and merchandising-constraint data from approved upstream systems into a canonical platform model.

The design is responsible for:

- ingesting product, inventory, asset, and product-relationship payloads from upstream systems;
- normalizing them into canonical entities and stable `product_id` mappings;
- publishing governed downstream contracts for graph, recommendation, reporting, and operational consumers;
- isolating source-specific inconsistencies behind connectors so downstream services do not integrate directly with upstream schemas;
- preserving support for attach logic and merchandising constraints without making F1 the runtime rules engine.

The design explicitly does **not** replace upstream systems, expose a customer-facing API, or evaluate recommendation-time merchandising rules that belong to F10/F19.

---

## 2. Architecture decisions and implementation boundaries

### 2.1 Chosen direction

1. **Canonical catalog domain inside the platform**
   - The platform owns a canonical catalog domain for downstream consumption: `Product`, `InventorySnapshot`, `AttachmentPolicy`, `CatalogConstraint`, and `CatalogIngestionRun`.
   - Upstream systems remain authoring systems for their source data; downstream services must read the platform canonical model, not upstream payloads.

2. **Connector + orchestrator pattern**
   - Each source system has its own connector adapter for auth, pagination, delta cursor handling, schema translation, and retry behavior.
   - A shared ingestion control plane schedules runs, tracks job state, and routes data through normalization, validation, quarantine, and publication.

3. **Hybrid sync strategy**
   - **Catalog and asset data:** scheduled full reconciliation plus delta pulls where supported.
   - **Inventory data:** full reconciliation for recovery plus faster delta or event-triggered updates where supported by OMS or commerce platforms.
   - This answers the open full-load vs delta vs event-stream question without forcing all sources into one mode.

4. **Central downstream system of record for attach and constraint consumption**
   - The platform canonical `AttachmentPolicy` and `CatalogConstraint` stores are the downstream system of record for consumers inside this platform.
   - Upstream authoring may originate in PIM or another approved merchandising feed, but downstream services consume the normalized platform contract only.
   - Channel-specific overrides remain out of scope for F1 and belong to later merchandising-rule features.

5. **Freshness tiers by consumer**
   - **Near-real-time consumers:** inventory-aware recommendation and channel delivery paths consume the latest inventory projection.
   - **Eventual-consistency consumers:** graph builders, reporting, and bulk analytic consumers consume canonical events or snapshot tables.
   - Exact SLO numbers remain a product/architecture approval decision, but the component boundaries support different freshness requirements without separate upstream integrations.

### 2.2 Ownership boundary with later features

- **F1 owns:** source ingestion, canonical normalization, identity-free catalog data quality, product/inventory/attach/constraint publication contracts, replay and quarantine operations.
- **F5/F6 own:** graph construction and look modeling on top of canonical product and attachment outputs.
- **F10/F19 own:** recommendation-time rule authoring and evaluation such as pin/include/exclude/boost/demotion and placement-specific overrides.
- **F11 owns:** channel-facing recommendation delivery; it does not call upstream catalog systems directly.

---

## 3. Component responsibilities

| Component | Responsibility | Inputs | Outputs | Ownership boundary |
|-----------|----------------|--------|---------|--------------------|
| **Catalog source connectors** | Connect to PIM, Shopify, DAM, and Custom Made sources; fetch full and delta product payloads; translate source auth/rate-limit behavior into standard connector responses | Source credentials, last cursor, source-specific API or file payloads | Raw product batches, connector metadata, source watermarks | Source-specific only; no canonical writes |
| **Inventory connectors** | Connect to OMS and commerce inventory endpoints or event feeds; fetch inventory changes and reconciliation snapshots | Source credentials, location scope, cursors, inventory events | Raw inventory batches/events, source watermarks | Inventory acquisition only; no downstream filtering decisions |
| **Ingestion control plane** | Schedule runs, accept manual triggers, fan out source jobs, track job state, enforce concurrency and retry budgets | Trigger requests, schedules, source config | Job records, run status, retry attempts, alerts | No business transformation logic |
| **Raw landing and audit store** | Persist immutable raw payloads and metadata for replay, audit, and troubleshooting | Raw batches/events from connectors | Raw payload archive, source checksum, receive timestamp | Append-only storage; not read by downstream product services |
| **Normalization and validation pipeline** | Map source payloads to canonical entities, resolve `product_id`, validate required fields, classify errors as retryable vs quarantineable | Raw payloads, mapping config, canonical schema rules | Canonical entity upserts, validation errors, quarantine records | Canonical transformation only; no graph construction |
| **Canonical catalog store** | Persist authoritative platform copies of products and related metadata | Canonical product records, source mappings | `Product` records, source-to-canonical ID mappings, retirement state | Canonical product storage only |
| **Inventory projection store** | Persist latest inventory state needed by downstream consumers, including scope such as region/channel when provided | Canonical inventory updates | `InventorySnapshot` records, freshness timestamps | Projection for consumers; not source master |
| **Attachment policy registry** | Persist normalized product-to-product attach relationships and attach metadata for downstream graph/recommendation consumers | Canonical attachment payloads from approved source feeds | `AttachmentPolicy` records, relationship version, status | Stores channel-agnostic attach definitions only |
| **Catalog constraint registry** | Persist normalized product eligibility and merchandising constraint attributes required downstream (for example inventory eligibility, region/channel sellability, RTW/CM applicability) | Canonical constraint payloads or derived rules from ingestion | `CatalogConstraint` records, eligibility flags | Stores ingest-time constraints only; not runtime override engine |
| **Publication outbox** | Publish canonical change events and/or materialized views for downstream systems with idempotent delivery semantics | Canonical writes from stores | Versioned topics, replayable change log, consumer checkpoints | No source integration or rule evaluation |
| **Operations and observability** | Emit metrics, alerts, dashboards, and dead-letter/quarantine workflows | Job status, validation failures, publish failures | Alerts, dashboards, DLQ/quarantine triage records | Monitoring and support only |

---

## 4. Data flow

### 4.1 Primary entities

- `Product`
- `InventorySnapshot`
- `AttachmentPolicy`
- `CatalogConstraint`
- `CatalogIngestionRun`
- `SourceProductMapping`

### 4.2 Source-to-sink flow

1. **Trigger**
   - Schedule, manual API call, or source webhook creates a `CatalogIngestionRun`.
   - The control plane resolves source config, run mode (`full`, `delta`, `event-driven`), and retry budget.

2. **Acquire**
   - Source connectors pull or receive raw payloads from PIM, OMS, Shopify, DAM, or Custom Made.
   - Each payload is written to the raw landing store before transformation so replay never depends on the upstream system staying available.

3. **Normalize**
   - The normalization pipeline maps source fields into canonical schema fields defined by the domain and data standards.
   - `SourceProductMapping` resolves or creates stable `product_id` values.
   - Attachment and constraint payloads are separated from base product and inventory payloads so each entity can be versioned independently.

4. **Validate**
   - Required canonical fields, identifier mappings, lifecycle semantics, and freshness metadata are validated.
   - Retryable connector failures remain in job retry flow.
   - Non-retryable record-level failures move to quarantine with source reference, error code, and replay eligibility.

5. **Persist**
   - Valid canonical entities are upserted into the canonical catalog store, inventory projection store, attachment policy registry, and catalog constraint registry.
   - Product retirement and soft-delete logic update lifecycle state instead of hard-deleting downstream references.

6. **Publish**
   - The publication outbox emits versioned change events and/or refreshes materialized views for downstream consumers.
   - F5 and F6 consume product and attachment changes for graph rebuilds or incremental edge updates.
   - Reporting and downstream operational consumers read snapshots or event streams instead of upstream sources.

7. **Observe**
   - Run-level metrics capture record counts, freshness lag, validation failure rate, and publish lag.
   - Alerting is triggered for connector outages, repeated quarantines, or freshness SLA breaches.

### 4.3 Consumer-tier behavior

| Consumer tier | Data source | Freshness expectation | Notes |
|---------------|-------------|-----------------------|-------|
| **Graph and look builders (F5/F6)** | Canonical events plus snapshot tables | Eventual consistency | Can batch incremental updates; should not read raw payloads |
| **Recommendation/runtime consumers (later F10/F11)** | Inventory projection and canonical constraint views | Near real time relative to source updates | Must use last good state if the latest update path fails |
| **Reporting and monitoring** | Snapshot tables and ingestion-run metrics | Eventual consistency | Use audit-safe data, not raw secrets or source payloads |

---

## 5. API implications

There is no new customer-facing API in F1. The architecture introduces internal control endpoints and versioned publication contracts.

### 5.1 Internal control APIs

#### `POST /internal/catalog-ingestion/jobs`

- **Purpose:** trigger a full, delta, or scoped ingestion run.
- **Request body:**
  ```json
  {
    "source": "pim",
    "mode": "delta",
    "entity_types": ["product", "attachment_policy"],
    "since": "2026-03-18T00:00:00Z",
    "scope": {
      "category_ids": ["suiting"]
    }
  }
  ```
- **Response:** `202 Accepted` with `job_id`, `status`, and accepted scope.
- **Errors:** `400` invalid source or scope, `401/403` unauthorized caller, `409` duplicate in-flight run for same source and scope, `503` control plane unavailable.

#### `GET /internal/catalog-ingestion/jobs/{job_id}`

- **Purpose:** retrieve job status, counts, quarantine summary, and last publication checkpoint.
- **Response:** `200 OK` with run metadata and counts.
- **Errors:** `404` unknown job, `401/403` unauthorized caller.

#### `POST /internal/catalog-ingestion/sources/{source}/webhook`

- **Purpose:** accept source-triggered change notifications for supported systems.
- **Behavior:** validates source auth, writes event to raw landing, enqueues targeted delta job.
- **Errors:** `400` invalid event payload, `401/403` invalid auth, `429` rate-limited source, `503` enqueue unavailable.

### 5.2 Canonical publication contracts

Downstream components consume versioned events or materialized views with canonical IDs.

| Contract | Producer | Primary consumers | Required payload fields |
|----------|----------|-------------------|-------------------------|
| `catalog.product.upserted.v1` | Publication outbox | F5, F6, reporting | `product_id`, `status`, canonical attributes, `source_system`, `updated_at`, `version` |
| `catalog.inventory.upserted.v1` | Publication outbox | Later F10/F11, reporting | `product_id`, `inventory_scope`, `availability` or `quantity`, `freshness_at`, `version` |
| `catalog.attachment-policy.upserted.v1` | Publication outbox | F5, F6, later recommendation components | `attachment_policy_id`, `anchor_product_id`, `attached_product_id`, relationship metadata, `status`, `version` |
| `catalog.constraint.upserted.v1` | Publication outbox | Later F10/F11, reporting | `constraint_id`, `product_id`, constraint type, scope, effective status, `version` |
| `catalog.product.retired.v1` | Publication outbox | F5, F6, caches, reporting | `product_id`, `retired_at`, `replacement_product_id` when applicable |

Publication must be idempotent and replayable. Event payloads follow canonical ID and timestamp rules from `docs/project/data-standards.md`.

### 5.3 Downstream read boundary

- **V1 direction:** downstream services consume platform-managed events and materialized views rather than a general-purpose read API.
- If a read API is required later, it must be added as a separate architecture item so ownership, caching, and auth are explicit.

---

## 6. Integration points

| Integration | Role in architecture | Auth pattern | Sync mode | Failure behavior |
|-------------|----------------------|--------------|-----------|------------------|
| **PIM** | Primary product attributes, taxonomy, and source product identifiers | Service credential or API key in secrets store | Full + delta pull; webhook if available | Retry transient 5xx/429/timeout; quarantine record-level schema failures |
| **OMS** | Inventory and sellability state | Service credential | Full reconciliation + fast delta/event path | Preserve last good inventory snapshot on outage; alert on freshness breach |
| **Shopify** | Commerce publication metadata and channel-specific assortment overlays when approved | API token | Delta pull and scoped reconciliation | Retry transient failures; do not overwrite canonical product with sparse commerce-only payloads unless mapping allows |
| **DAM** | Asset metadata enrichment such as image/document references | API token or service account | Batch or delta | Treat as enrichment dependency; asset outage must not block core product ingestion |
| **Custom Made** | Custom product attributes and RTW/CM applicability metadata | Service credential or file drop auth | Batch or delta import | Route bad records to quarantine; do not block non-CM catalog updates |
| **Observability/alerting** | Metrics, dashboards, and notifications | Internal service auth | Async event emission | Fail open for metrics emission; never block canonical writes on telemetry outage |

### Integration standards applied

- Outbound secrets remain outside code and use least-privilege access.
- Retries apply only to transient failures and honor source rate limits.
- Idempotency is enforced on job triggers, event publication, and downstream consumer contracts.
- Async failures after max retry move to quarantine or dead-letter handling; nothing is silently dropped.

---

## 7. Risks and trade-offs

1. **Hybrid sync complexity vs source flexibility**
   - **Chosen direction:** support full, delta, and event-triggered paths.
   - **Trade-off:** more connector complexity, but avoids forcing every upstream into snapshot-only behavior and supports faster inventory freshness where possible.

2. **Central canonical attach registry vs source-specific downstream logic**
   - **Chosen direction:** central downstream attach registry.
   - **Trade-off:** requires canonical schema and ownership decisions up front, but prevents graph/recommendation consumers from coupling themselves to source-specific relationship formats.

3. **Inventory projection store vs direct OMS lookups**
   - **Chosen direction:** platform-managed inventory projection.
   - **Trade-off:** introduces replication lag, but avoids request-time OMS coupling and lets downstream services keep operating from last known good state during outages.

4. **Quarantine-first validation vs permissive ingestion**
   - **Chosen direction:** quarantine invalid records and continue the rest of the run.
   - **Trade-off:** some records may be temporarily missing downstream, but the pipeline remains auditable and avoids corrupting canonical state.

5. **Materialized views/events vs broad internal read API**
   - **Chosen direction:** publish views and events first.
   - **Trade-off:** consumers must handle event/view integration, but ownership and scaling stay clearer than introducing a catch-all internal catalog API too early.

---

## 8. Missing platform decisions

These decisions are explicit follow-ups and must not be hidden in implementation work:

1. **Initial authoring source for attach logic**
   - The platform canonical registry is the downstream consumption source of truth, but human approval is still needed on which upstream system authors v1 attach payloads.

2. **Freshness SLOs by consumer tier**
   - The architecture supports separate near-real-time and eventual-consistency tiers, but approval is still needed on exact freshness targets and breach thresholds.

3. **Inventory granularity**
   - Human confirmation is needed on whether downstream v1 requires quantity, availability flag only, or region/channel/location-level inventory views.

4. **Approved source list and ownership**
   - The connector boundary is defined, but the v1 committed subset and system owner for each connector should be recorded before implementation planning.

---

## 9. Readiness criteria

The implementation plan can be written when the following are accepted:

- [ ] Canonical entities and publication contracts in this document are approved as the baseline for F1.
- [ ] The v1 connector list and owning systems are explicitly recorded.
- [ ] The attach authoring source decision is recorded, even though downstream consumption already uses the canonical registry.
- [ ] Freshness SLOs are defined for inventory-aware consumers and eventual-consistency consumers.
- [ ] Quarantine, replay, and dead-letter operating model is accepted by the implementation plan.
- [ ] Product retirement and source-to-canonical ID mapping policy is accepted.
- [ ] Downstream dependency notes for F5/F6 and later F10/F11 consumption are carried into the implementation plan.

---

## 10. Approval and milestone-gate notes

- **Approval mode:** HUMAN_REQUIRED. A passing review may recommend `READY_FOR_HUMAN_APPROVAL` only; it must not self-promote to `APPROVED`.
- **Milestone gate from roadmap:** Phase 1 requires a **data and graph readiness review** before Phase 2 engine and API work starts.
- **Promotion rule:** Do not create an implementation-plan board row until this architecture item is explicitly approved by a human.

---

## 11. Recommended board update

- Add `TA-006` to `docs/boards/technical-architecture.md`.
- Set status to `READY_FOR_HUMAN_APPROVAL` if the review in this artifact is accepted.
- Record that the item is issue-triggered (`issue-created automation`), approval mode is `HUMAN_REQUIRED`, and no implementation-plan promotion occurs until explicit human approval is recorded.

---

## 12. Review: Catalog and Inventory Ingestion Technical Architecture — TA-006

**Trigger:** issue-created automation

**Disposition:** READY_FOR_HUMAN_APPROVAL

**Scores (1–5):** Clarity 5 | Completeness 5 | Implementation Readiness 5 | Consistency 5 | Dependencies 5 | Automation Safety 5 → **Average:** 5.0

**Confidence:** HIGH — component boundaries, contracts, failure behavior, and follow-up decisions are explicit enough for implementation planning once human approval is recorded.

**Blocking issues:** None

**Required edits:** None

**Approval-mode interpretation:** HUMAN_REQUIRED → recommend READY_FOR_HUMAN_APPROVAL

**Upstream artifacts to update (if rejection comments apply):** None

**Board update:** Set `TA-006` to `READY_FOR_HUMAN_APPROVAL`; add note: `Issue-created architecture draft and review complete; awaiting human approval before implementation-plan promotion.`

**Remaining human/merge requirements:** Human approval is still required before status may move to `APPROVED` and before any `implementation-plan` row is created. The Phase 1 data-and-graph readiness gate remains in force before Phase 2 work starts.
