# Technical Architecture: Catalog and Inventory Ingestion

**TA ID:** TA-006  
**Feature ID:** FEAT-001 / F1  
**Issue:** #27  
**Stage:** Technical architecture (`workflow:architecture`)  
**Source:** `docs/features/catalog-and-inventory-ingestion.md`, `docs/project/architecture-overview.md`, `docs/project/data-standards.md`, `docs/project/integration-standards.md`, `docs/project/api-standards.md`  
**Traceability:** Downstream of approved feature breakdown FEAT-001; feeds `docs/boards/implementation-plan.md` and downstream build stages.  
**Approval mode:** HUMAN_REQUIRED (inherited from FEAT-001). Autonomous mode is ON for this run, so the branch/PR flow completes without pausing for a human gate.  
**Trigger:** Issue-created autonomous run for GitHub issue #27.  
**Status:** Completed architecture-stage artifact for implementation planning and PR review.

---

## 1. Objective and scope

Define the implementation-oriented architecture for ingesting catalog and inventory data from approved upstream systems into a canonical platform model that downstream product graph, look store, recommendation, and analytics capabilities can consume safely.

This architecture covers:

- source connector responsibilities and precedence,
- ingestion control plane and execution flow,
- canonical product and inventory storage boundaries,
- validation, quarantine, replay, and observability,
- internal APIs and event contracts,
- support boundaries for attach logic and merchandising constraints,
- failure handling, risks, and implementation-plan readiness.

This architecture does **not** redesign upstream systems, replace PIM/OMS/DAM, or define end-user merchandising UI behavior.

---

## 2. Architectural decisions

The following decisions resolve the open questions from the issue closely enough for implementation planning:

1. **Attach logic system of record:** The platform merchandising/rules domain is the authoritative system of record for attach logic. Catalog ingestion supplies canonical product attributes, relationship hints, and availability signals that attach logic depends on, but connectors do not own the attach rules themselves.
2. **Merchandising constraints ownership:** Merchandising constraints are managed centrally in platform governance components and consumed by downstream channels through shared APIs and data products; channels may add presentation-specific filtering only when explicitly configured.
3. **Inventory ingest mode:** Use a **hybrid model**: full bootstrap loads, scheduled delta sync, and optional event/webhook acceleration where a source supports it. Inventory is not modeled as a streaming-only dependency in v1.
4. **Freshness expectation by consumer:** Delivery/runtime consumers depend on near-real-time inventory updates, while reporting and non-runtime rebuild consumers can tolerate scheduled refresh windows.
5. **Failure isolation:** Ingestion failures must degrade to the last known good catalog/inventory state and must not take down recommendation-serving paths.

---

## 3. High-level architecture

```text
Approved source systems
PIM | Shopify | OMS | DAM | Custom Made
        |
        v
+------------------------+
| Source adapter layer   |
| auth, pull/webhook,    |
| pagination, rate-limit |
+------------------------+
        |
        v
+------------------------+      +-------------------------+
| Sync orchestrator      |----->| Run metadata store      |
| schedule, trigger API, |      | status, cursor, errors  |
| backfill, retry policy |      +-------------------------+
+------------------------+
        |
        v
+------------------------+
| Raw landing / replay   |
| immutable payload copy |
+------------------------+
        |
        v
+------------------------+      +-------------------------+
| Normalize + validate   |----->| Quarantine store        |
| schema map, precedence,|      | bad records + reasons   |
| dedupe, idempotency    |      +-------------------------+
+------------------------+
        |
        v
+------------------------+      +-------------------------+
| Canonical catalog store|----->| Change publication      |
| product master records |      | events / CDC / cache    |
+------------------------+      +-------------------------+
        |
        +-------------> Inventory availability store
        |              region/channel availability snapshot
        |
        +-------------> Downstream consumers
                       product graph, look store, merch rules,
                       recommendation engine, analytics
```

---

## 4. Component responsibilities

| Component | Responsibility | Inputs | Outputs | Ownership boundary |
|-----------|----------------|--------|---------|--------------------|
| **Sync orchestrator** | Accept scheduled and manual sync requests, choose full vs delta mode, sequence source runs, enforce retry windows and concurrency limits | Scheduler, internal trigger API, optional source webhooks | Sync run jobs, source execution plans, run metadata | Platform ingestion service boundary; no downstream business logic |
| **Source adapter layer** | Translate source-specific auth, pagination, delta cursors, webhook payloads, and rate limits into a normalized ingestion envelope | PIM, Shopify, OMS, DAM, Custom Made APIs/files/events | Raw source payloads with source metadata and cursor state | One adapter per source/system contract |
| **Raw landing store** | Persist immutable source payloads for audit, replay, and debugging before business validation | Adapter payloads | Replayable raw payload records | Storage owned by ingestion only |
| **Normalization and validation pipeline** | Map source fields into canonical product/inventory schema, apply source precedence, deduplicate, validate required fields and enums, stamp canonical identifiers | Raw payloads, source mapping config, canonical schema rules | Valid canonical entities or quarantined failures | Critical path data-quality boundary |
| **Canonical catalog store** | Persist the current canonical product master record and source lineage for each `product_id` | Valid canonical product payloads | Queryable product records, change feed entries | Source of truth for platform product data |
| **Inventory availability store** | Persist current availability snapshot by product and optional region/channel scope; shield runtime consumers from raw source variability | Valid inventory deltas/snapshots | Queryable availability records, freshness timestamps | Source of truth for platform inventory availability |
| **Quarantine and replay manager** | Hold invalid or conflicting records, provide retry and replay paths after mapping or source fixes | Validation failures, conflict failures | Replay requests, operator diagnostics, alert events | Operational recovery boundary |
| **Change publication layer** | Emit downstream product/inventory changes after canonical writes; decouple ingestion from graph/recommendation implementations | Canonical write events or CDC | Versioned product and inventory change events, cache invalidation signals | Integration boundary to F5/F6/F9/F11/F17 |
| **Observability and SLA monitor** | Track run health, freshness, source latency, failure rates, and downstream publish lag | Run metadata, adapter metrics, validation metrics, publish metrics | Dashboards, alerts, SLA breach notifications | Operational monitoring boundary |
| **Attach and constraint projection** | Project attach-relevant attributes, source relationship hints, and governance-ready product context to downstream rules/graph components without making ingestion the owner of attach policy or merchandising constraints | Canonical products, source relationship hints, availability state, governance scope inputs | Normalized attributes and scoped policy context usable by F5/F6/F10 | Supporting projection only; not the system of record for attach logic or merchandising constraints |

### Source precedence model

To avoid conflicting ownership on the critical path, v1 uses this precedence:

| Data domain | Preferred system of record | Notes |
|-------------|----------------------------|-------|
| Core product identity and merchandising attributes | **PIM** | Primary source for product metadata and stable product lineage |
| Channel publication metadata | **Shopify** | Used for storefront-availability and publication hints, not master identity |
| Inventory / fulfillment availability | **OMS** | Preferred for quantity or sellable availability |
| Media assets | **DAM** | Asset URLs and metadata attached to canonical product |
| Custom Made catalog attributes | **Custom Made** | CM-only attributes/options merged onto canonical product where applicable |

If a source is absent for a product, the canonical record remains valid with the best available attributes; missing non-required domains do not block ingestion of the whole record.

---

## 5. Canonical data model and contracts

### 5.1 Canonical product contract

The canonical product model aligns with `docs/project/data-standards.md` and the F1 feature spec.

**Required fields**

- `product_id`
- `source_system`
- `source_id`
- `status` (`active`, `retired`, `draft`)
- `updated_at`
- `category`

**Key optional fields**

- `title`
- `style_family`
- `fabric`
- `color`
- `pattern`
- `fit`
- `season`
- `occasion`
- `price_tier`
- `rtw_applicable`
- `cm_applicable`
- `asset_refs`
- `channel_publication`
- `relationship_hints`
- `merchandising_attributes`

**Lineage fields**

- `canonical_version`
- `source_versions[]`
- `ingested_at`
- `ingestion_run_id`

### 5.2 Canonical inventory contract

- `product_id`
- `availability_status`
- `quantity` (optional when the source supplies only boolean availability)
- `region`
- `channel`
- `source_system`
- `last_updated`
- `inventory_run_id`

### 5.3 Attach and merchandising support contract

The ingestion pipeline must supply enough data for downstream attach logic and merchandising constraints to evaluate without re-reading source systems:

- stable `product_id`,
- product compatibility attributes (`category`, `style_family`, `fabric`, `occasion`, `fit`),
- RTW/CM applicability flags,
- channel/region availability,
- optional relationship hints imported from source systems,
- source lineage so downstream governance can explain why data changed.

Attach rules themselves remain owned by downstream graph/rules components, not the ingestion service.

---

## 6. Data flow

### 6.1 Full bootstrap flow

1. Scheduler or operator calls the internal sync API for a source with `scope=full`.
2. Sync orchestrator creates a run record and checkpoints the requested scope.
3. Source adapter authenticates to the upstream system and paginates through the full dataset.
4. Raw payloads are written to the landing store before transformation.
5. Normalization pipeline maps source fields to the canonical schema and applies source precedence.
6. Validation checks required fields, enum values, identifier stability, and duplicate source keys.
7. Invalid records are written to quarantine with machine-readable failure reasons.
8. Valid product records are upserted into the canonical catalog store.
9. Valid inventory records are upserted into the inventory availability store.
10. Change publication emits downstream events or CDC notifications.
11. Run metadata is finalized with counts, cursor state, duration, and any partial-failure summary.

### 6.2 Delta / near-real-time flow

1. Scheduler or source webhook triggers a delta sync with a `since` cursor.
2. Adapter fetches only changed products or inventory slices where supported.
3. Idempotency keys are derived from source event IDs or `(source_system, source_id, updated_at)` when explicit event IDs are absent.
4. Canonical upserts overwrite only newer versions and preserve last known good fields from higher-precedence sources.
5. Change publication emits only changed entities so downstream graph and caches can update incrementally.

### 6.3 Failure and recovery flow

1. Transient adapter failures (`429`, `5xx`, timeout) retry with exponential backoff per integration standards.
2. Exhausted retries mark the connector or run as degraded and raise alerts.
3. Invalid records do **not** poison the whole run unless a source-level contract violation crosses a configurable threshold.
4. Runtime consumers continue reading the last known good catalog and inventory state.
5. Operators can replay quarantined records or rerun a source slice after fixing mappings or source data.

### 6.4 Downstream consumption flow

1. Product graph (F5) consumes product changes to refresh nodes and compatibility relationships.
2. Outfit graph / look store (F6) consumes product and availability changes to keep curated looks shoppable.
3. Merchandising rules and attach-logic components consume projected attributes and availability state for rule evaluation.
4. Recommendation engine (F9) and Delivery API (F11) read through downstream graph/rules layers rather than from raw connectors.
5. Analytics (F17) consumes canonical dimensions and ingestion metrics for reporting and SLA visibility.

---

## 7. Internal APIs and event implications

### 7.1 Internal APIs

All APIs are internal-only and authenticated at the platform boundary per `docs/project/api-standards.md` and `docs/project/integration-standards.md`.

#### `POST /internal/catalog-sync-jobs`

Trigger a sync run.

**Request**

```json
{
  "source": "pim",
  "entity_scope": "catalog_and_inventory",
  "mode": "full",
  "since": null,
  "reason": "scheduled_refresh"
}
```

**Response**

```json
{
  "job_id": "sync_2026_03_18_001",
  "status": "queued"
}
```

**Errors**

- `400 invalid_source`
- `400 invalid_mode`
- `401 unauthorized`
- `409 sync_already_running`

#### `GET /internal/catalog-sync-jobs/{job_id}`

Return current run status, counts, cursor, and failure summary for operational tooling.

#### `POST /internal/catalog-replay-jobs`

Replay quarantined records or rerun a scoped source slice.

#### `GET /internal/catalog-sources/{source}/health`

Return connector health, last-success time, freshness, and open alert state.

### 7.2 Event contracts

#### `catalog.product-upserted.v1`

**Producer:** change publication layer  
**Consumers:** F5 product graph, F6 look store, optional cache invalidation services

**Payload**

```json
{
  "event_id": "evt_123",
  "event_name": "catalog.product-upserted",
  "event_timestamp": "2026-03-18T10:15:30Z",
  "product_id": "prod_123",
  "source_system": "pim",
  "canonical_version": 42,
  "status": "active",
  "attributes": {
    "category": "suit",
    "style_family": "formal",
    "fabric": "wool",
    "occasion": ["wedding", "business"]
  },
  "relationship_hints": [],
  "ingestion_run_id": "sync_2026_03_18_001"
}
```

#### `inventory.availability-upserted.v1`

**Producer:** change publication layer  
**Consumers:** F6 look store, F9 recommendation engine dependencies, F11-serving caches

**Payload**

```json
{
  "event_id": "evt_456",
  "event_name": "inventory.availability-upserted",
  "event_timestamp": "2026-03-18T10:15:45Z",
  "product_id": "prod_123",
  "region": "us-east",
  "channel": "webstore",
  "availability_status": "in_stock",
  "quantity": 12,
  "source_system": "oms",
  "last_updated": "2026-03-18T10:14:58Z",
  "ingestion_run_id": "sync_2026_03_18_001"
}
```

#### `catalog.ingestion-run.v1`

**Producer:** sync orchestrator  
**Consumers:** operations dashboards, alerting, analytics

**Payload fields**

- `run_id`
- `source`
- `mode`
- `status`
- `records_read`
- `records_written`
- `records_quarantined`
- `started_at`
- `completed_at`
- `error_summary`

---

## 8. Integration points and failure behavior

| Integration | Direction | Auth expectation | Mode | Failure behavior |
|-------------|-----------|------------------|------|------------------|
| **PIM** | Outbound pull and optional inbound webhook | API key or OAuth in secure store | Full + delta | Retry transient failures; preserve last good catalog state on outage |
| **Shopify** | Outbound pull | App token in secure store | Delta preferred, full fallback | Retry 429/5xx; publish-storefront flags only when sync succeeds |
| **OMS** | Outbound pull and optional event/webhook | Service credential in secure store | Delta or near-real-time event-assisted | Do not zero out availability on connector failure; hold previous snapshot and alert |
| **DAM** | Outbound pull | API token/service account | Scheduled sync | Asset failures do not block product identity updates unless required asset policy says otherwise |
| **Custom Made** | Outbound pull or file drop | Service account or signed file exchange | Scheduled batch | Missing CM attributes downgrade only CM-specific recommendation eligibility |

**Retry policy**

- Retry only transient failures (`429`, `5xx`, timeout).
- Use exponential backoff and honor `Retry-After` where provided.
- Cap retries so a single bad dependency does not consume the whole batch window.
- Push exhausted records or slices to quarantine/dead-letter for replay.

**Idempotency policy**

- Upserts are keyed by `product_id` and source lineage version.
- Duplicate source events or files should produce the same resulting canonical state without duplicate downstream side effects.
- Event publication uses stable `event_id` values to support consumer deduplication.

---

## 9. Attach logic and merchandising constraint architecture

The issue requires clear support for attach logic and merchandising constraints. This architecture handles that by separating **data supply** from **policy ownership**.

### 9.1 What ingestion owns

- canonical product and inventory data,
- projected attach-relevant product attributes,
- source relationship hints when provided,
- freshness and lineage metadata,
- availability signals needed to suppress non-shoppable products.

### 9.2 What ingestion does not own

- attach rule authoring,
- merchandising constraint policy,
- channel-specific ranking behavior,
- recommendation decision logic.

### 9.3 Interface to downstream policy systems

Downstream graph/rules services consume a stable projection that includes:

- `product_id`,
- category and style taxonomy,
- compatibility attributes,
- RTW/CM applicability,
- channel and region availability,
- retirement/discontinuation status,
- source lineage and freshness timestamps,
- policy-scope join keys (channel, market, collection, lifecycle status),
- optional source relationship hints that can seed centrally managed attach logic.

Where policy systems publish their own rule data, the ingestion-side projection should expose a **join-stable contract** rather than duplicate policy state. The minimum contract for the downstream join surface is:

- `product_id`
- `canonical_version`
- `availability_scope[]`
- `compatibility_attributes`
- `policy_scope`
- `freshness_timestamp`
- `source_lineage`

This supports centralized rule definition without turning ingestion into a rules engine.

---

## 10. Operational concerns

### 10.1 Observability

Track at minimum:

- run duration by source and mode,
- records read/written/quarantined,
- freshness lag per source and per inventory consumer,
- connector error rate,
- downstream publication lag,
- replay success rate.

### 10.2 Alerting

Alert on:

- source connector outage,
- freshness SLA breach,
- validation failure spike,
- inventory publish lag beyond runtime threshold,
- repeated replay failure for the same source slice.

### 10.3 Security and governance

- Store source credentials outside the repo in a secure secret store.
- Restrict internal trigger/replay APIs to platform operators and approved services.
- Keep raw landing data free of secrets and PII; product data is non-PII but logs must still avoid credentials.
- Audit manual replays and on-demand runs with actor, source, scope, and timestamp.

---

## 11. Risks and trade-offs

| Risk / trade-off | Chosen direction | Why | Residual risk |
|------------------|------------------|-----|---------------|
| **Batch-only vs hybrid ingest** | Hybrid full + delta + optional events | Balances source variability with runtime freshness | More connector complexity than batch-only |
| **Single canonical model vs source-specific downstream reads** | Canonical model | Keeps downstream systems decoupled from source quirks | Requires careful schema evolution governance |
| **Quarantine partial failures vs fail-whole-run** | Quarantine bad records, continue when safe | Avoids blocking the full assortment on a small number of bad records | Partial freshness inconsistencies need visibility |
| **Centralized attach logic vs source-owned attach hints** | Centralized platform policy with optional source hints | Aligns with shared recommendation governance and consistent downstream behavior | Organizational agreement still required for legacy source-owned logic migration |
| **Snapshot inventory store vs direct OMS reads at runtime** | Snapshot store | Protects serving path from OMS latency/outages | Runtime freshness depends on well-defined sync SLA |

---

## 12. Missing decisions requiring confirmation

These do not block architecture completion, but they must be made explicit in the implementation plan and PR notes:

1. **Exact v1 source list and owning teams** for PIM, OMS, DAM, Shopify, and Custom Made connectors.
2. **Numeric freshness targets** for:
   - catalog full refresh window,
   - delta completion window,
   - runtime inventory freshness threshold.
3. **Inventory granularity** required in v1: global, region, store, or channel-region.
4. **Threshold policy** for when validation failures should escalate from partial-success to run failure.
5. **Whether any upstream system currently stores attach hints** that must be imported rather than re-authored centrally.

---

## 13. Readiness criteria for implementation planning

Implementation planning can begin when the following are treated as baseline requirements:

- [x] Component boundaries are explicit.
- [x] Canonical product and inventory contracts are defined at an implementation-ready level.
- [x] Internal trigger, status, and replay APIs are named with expected error behavior.
- [x] Downstream publication model is explicit.
- [x] Failure isolation, retry, and idempotency behavior are documented.
- [x] Attach-logic and merchandising-constraint boundaries are explicit.
- [x] Missing decisions are isolated so they can become implementation tasks instead of hidden ambiguity.

Recommended first implementation-plan workstreams:

1. ingestion control plane and run metadata,
2. source adapter framework and source precedence config,
3. canonical schema + validation/quarantine pipeline,
4. downstream change publication and graph integration contract,
5. observability and operational tooling.

---

## 14. Approval and milestone-gate notes

- **Inherited approval mode:** HUMAN_REQUIRED from FEAT-001.
- **Autonomous run handling:** Per `docs/project/autonomous-automation-config.md`, this run does not pause for human approval before commit, push, or PR creation.
- **Governance preserved:** Human review still matters for future material changes to this architecture or for downstream production rollout decisions, especially where merchandising policy or inventory freshness commitments are customer-visible.
- **Downstream implication:** The implementation plan should preserve explicit tasks for connector-owner confirmation, SLA definition, and attach-hint migration if any source currently owns part of that logic.

---

## 15. Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Catalog and inventory ingestion technical architecture (`docs/project/catalog-and-inventory-ingestion-technical-architecture.md`)  
**Stage:** Technical architecture  
**Approval mode:** HUMAN_REQUIRED (autonomous mode ON for this run)  
**Review source:** Issue-created autonomous run for GitHub issue #27

### Overall disposition

**Eligible for promotion.** The artifact defines implementation-oriented components, data flow, internal APIs, event contracts, attach-logic boundaries, and operational risks for F1. All six review dimensions score 4 or higher; average 4.8. Confidence HIGH. No blocking issues. Under normal governance this would be eligible for **READY_FOR_HUMAN_APPROVAL**; because autonomous mode is ON for this run, the board may record **APPROVED** so branch push and PR completion are non-blocking.

### Scored dimensions (1-5)

| Dimension | Score | Evidence |
|-----------|-------|----------|
| **Clarity** | 5 | Clear scope, decisions, architecture diagram, component table, and explicit ownership boundaries. |
| **Completeness** | 5 | Covers components, contracts, APIs, events, failure behavior, attach logic support, risks, missing decisions, and readiness criteria. |
| **Implementation Readiness** | 5 | The next stage can decompose work into orchestrator, connectors, canonical schema, publication, and observability tracks without re-deriving architecture. |
| **Consistency With Standards** | 4 | Aligns with architecture overview, data standards, API standards, and integration standards; approval-mode exception is explicitly documented for autonomous execution. |
| **Correctness Of Dependencies** | 5 | References FEAT-001/F1, canonical IDs, downstream F5/F6/F9/F11/F17 boundaries, and source integration expectations accurately. |
| **Automation Safety** | 5 | Trigger source is explicit, approval mode is preserved, and autonomous completion behavior is documented rather than implied. |

**Average:** 4.8. **Minimum dimension:** 4.

### Confidence rating

**HIGH.** Upstream feature scope and standards are stable, and the remaining open items are operational confirmations rather than architecture-shaping blockers.

### Blocking issues

**None.**

### Recommended edits

**None required before implementation planning.** Carry the source-owner, SLA, and inventory-granularity confirmations into the implementation plan and PR notes.

### Explicit recommendation

Because approval mode is **HUMAN_REQUIRED**, the normal recommendation would be **READY_FOR_HUMAN_APPROVAL** after review. Because autonomous mode is explicitly ON for this repository and run, the board can record **APPROVED** for completion of the autonomous architecture pass while preserving the approval-mode note in the artifact and PR.

### Propagation to upstream

**None required.** No human rejection comments were provided. If a future human review changes source-of-record assumptions or attach-logic ownership, update this architecture and any affected implementation plan items.

### Pending confirmation

- Final connector ownership by system/team.
- Numeric freshness and backlog targets.
- Inventory granularity for v1 runtime filtering.
