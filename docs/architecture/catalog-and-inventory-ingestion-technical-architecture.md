# Technical architecture: Catalog and inventory ingestion

**TA ID:** TA-006  
**Feature ID:** F1 / FEAT-001  
**Issue:** #27  
**Stage:** `workflow:architecture`  
**Trigger source:** Issue-created automation  
**Approval mode:** HUMAN_REQUIRED  
**Artifact owner:** Architecture Agent  
**Primary reviewers:** Review Agent, Architecture Lead  
**Upstream artifacts:** `docs/features/catalog-and-inventory-ingestion.md`, `docs/project/architecture-overview.md`, `docs/project/data-standards.md`, `docs/project/api-standards.md`, `docs/project/integration-standards.md`  
**Downstream board:** `docs/boards/implementation-plan.md`

---

## 1. Scope and architectural decisions

This architecture defines the ingestion foundation for catalog, inventory, attach logic, and merchandising constraints so downstream systems consume one normalized, governed product availability model instead of integrating directly with inconsistent upstream sources.

### Chosen direction

1. **Hybrid ingestion model:** support scheduled full loads plus incremental delta/event-driven updates. Full loads provide recoverability; deltas and events provide freshness.
2. **Platform canonical model:** upstream systems remain authoritative for raw source data, but the platform owns the **canonical serving model** used by product graph, recommendation, storefront, and analytics.
3. **Central attach and constraint registry:** attach logic and merchandising constraints are stored in a platform-managed registry with versioning, approval metadata, and channel-scoped projections. Upstream systems may author inputs, but downstream consumers read the platform projection only.
4. **Separate catalog and availability projections:** product content and inventory availability are stored independently so inventory can refresh faster without rewriting full product documents.
5. **Asynchronous downstream fan-out:** downstream graph, search, analytics, and cache refreshes consume published change events instead of coupling directly to sync jobs.

### Assumptions recorded for implementation planning

- Approved upstream sources for v1 are PIM, Shopify, OMS, DAM, and Custom Made as listed in F1.
- Inventory freshness for downstream serving targets **under 5 minutes** from accepted upstream delta/event, while catalog attribute freshness targets **under 30 minutes** for deltas and **same-day completion** for full refresh.
- Attach logic and merchandising constraints require an auditable publish flow but do not require a separate end-user UI in this stage.

---

## 2. Component responsibilities

| Component | Responsibility | Inputs | Outputs | Ownership boundary |
|-----------|----------------|--------|---------|--------------------|
| **Ingestion orchestrator** | Schedules full/delta syncs, tracks run state, enforces dependency ordering, and exposes internal control APIs for replay and backfill. | Schedules, internal trigger API requests, source health status | Job records, connector work items, alerts | Platform ingestion service |
| **Source connectors** | Pull or receive source-specific catalog and inventory payloads from PIM, Shopify, OMS, DAM, and Custom Made. Normalize transport concerns such as auth, pagination, cursors, and retries. | External APIs, files, or webhooks | Raw source envelopes, source watermarks | One adapter per source; external contract boundary |
| **Raw landing store** | Persists immutable source payloads for replay, audit, and diffing before transformation. | Raw connector payloads | Replayable source snapshots | Internal data platform boundary |
| **Canonical mapper** | Maps source identifiers and attributes into canonical product, variant, media, availability, attach-definition, and constraint-set schemas. | Raw payloads, source mapping rules | Canonical records with canonical IDs and normalized enums | Internal domain transformation boundary |
| **Validation and governance pipeline** | Applies required-field, enum, referential, uniqueness, and policy checks; routes invalid records to quarantine without corrupting serving data. | Canonical candidate records | Accepted records, quarantined records, validation metrics | Internal governance boundary |
| **Product catalog store** | Stores the current canonical catalog projection used by downstream read models. Maintains product lifecycle status and source lineage. | Accepted canonical product records | Product read projection, change feed | Platform source-of-truth for downstream reads |
| **Availability store** | Stores inventory availability and sellability projections independently from catalog content. | Accepted inventory records | Availability read projection, low-stock/out-of-stock change feed | Fast-refresh operational store |
| **Attach and constraint registry** | Stores platform-published attach logic and merchandising constraints with version history, effective windows, and channel scoping. | Ingested definitions, internal publish API, governance metadata | Published attach definitions, published constraint sets, audit records | Platform governance boundary |
| **Publication event bus** | Emits canonical change events after successful writes so downstream consumers update without calling source systems. | Product, inventory, attach, and constraint changes | Versioned events for graph, recommendation, analytics, and cache invalidation | Async integration boundary |
| **Observability and run-control** | Aggregates metrics, logs, dead-letter counts, SLA compliance, and reconciliation reports. | Run events, validation results, publication acknowledgements | Dashboards, alerts, reconciliation reports | Shared platform operations boundary |

### Critical path ownership

- **External systems own raw business content** (product attributes, inventory feeds, source-level attach inputs where they exist).
- **The platform owns canonical IDs, downstream-serving projections, publish events, and governance metadata.**
- **Downstream systems must not bypass platform projections** for catalog, availability, attach logic, or merchandising constraints.

---

## 3. Canonical data model implications

### Core entities

| Entity | Primary key | Selected required fields | Notes |
|--------|-------------|--------------------------|-------|
| **Product** | `product_id` | source lineage, status, title, category, brand, material/fabric, color, fit, season, occasion, channel visibility | Canonical catalog record used by graph and recommendation |
| **Variant / SKU** | `sku_id` | parent `product_id`, size, color, sellable flag | Optional if source granularity is variant-first |
| **Inventory availability** | composite of `sku_id`, channel, location/region | quantity or availability state, last_seen_at, freshness status | Stored separately for faster updates |
| **Attach definition** | `attach_definition_id` | anchor entity, candidate entity set, attach type, precedence, effective window, target channels | Enables bundle/attach logic independent of recommendation model |
| **Constraint set** | `constraint_set_id` | include/exclude rules, inventory thresholds, region/channel scope, priority | Centrally managed with channel overrides |
| **Source mapping** | source system + source object id | canonical target id, first_seen_at, last_seen_at | Immutable mapping once assigned unless explicit migration |
| **Sync run** | `sync_run_id` | source, scope, cursor/window, status, counts, started_at, completed_at | Required for replay and audit |

### Canonical rules

- Canonical IDs are stable and opaque; source IDs are preserved only as lineage.
- Every published record includes `source_system`, `source_version` or watermark, and `published_at`.
- Product retirements and inventory removals are explicit state transitions, not silent deletes.
- Attach definitions and constraint sets are versioned; downstream consumers receive only **published** versions.

---

## 4. Data flow

### 4.1 Full-load flow

1. **Ingestion orchestrator** starts a full sync for a source and writes a `sync_run_id`.
2. **Source connector** fetches paginated source data and stores immutable payload batches in the **raw landing store**.
3. **Canonical mapper** converts source objects to canonical product, variant, media, attach-definition, constraint-set, and inventory payloads.
4. **Validation pipeline** rejects malformed or policy-invalid records into quarantine while accepting valid records.
5. Accepted catalog records upsert into the **product catalog store**; accepted availability records upsert into the **availability store**.
6. Published attach logic and constraint updates upsert into the **attach and constraint registry**.
7. Successful writes emit versioned events on the **publication event bus**.
8. **Product graph**, **outfit graph/look store**, **recommendation engine**, **analytics**, and any cache invalidators consume the events and update their projections.
9. **Observability and run-control** records reconciliation totals and flags partial failures.

### 4.2 Delta/event flow

1. A connector receives a webhook or polls a delta endpoint using the last committed watermark.
2. The changed records pass through the same landing, mapping, validation, and write path as full loads.
3. Only changed entities emit downstream events.
4. Availability deltas bypass expensive full product recomputation; only the **availability store** and subscribed consumers are updated.

### 4.3 Read path for downstream consumers

1. Downstream services read catalog and availability from the platform projections or subscribe to change events.
2. **Recommendation engine** reads product metadata, sellability state, attach definitions, and constraint sets from platform-owned projections.
3. **Storefront and other channels** consume normalized outputs indirectly via recommendation and graph services, not directly from ingestion jobs.

### 4.4 Failure behavior

- If a source connector fails, the previous good projection remains active.
- If validation rejects a subset of records, the run completes as **partial** and only accepted records publish.
- If publication to the event bus fails after storage succeeds, the system retries event publication from an outbox; downstream visibility is eventually consistent but storage remains correct.
- If attach or constraint publication fails validation, the previously published version remains active until a corrected version is published.

---

## 5. API implications

### 5.1 Internal control APIs

| Endpoint | Method | Purpose | Success response | Error behavior |
|----------|--------|---------|------------------|----------------|
| `/internal/catalog-ingestion/jobs` | `POST` | Start a full, delta, or replay sync for one or more sources. | `202 Accepted` with `sync_run_id`, accepted scope, and requested sources | `400` invalid scope/source, `401/403` unauthorized, `409` overlapping lock, `429` concurrency exceeded |
| `/internal/catalog-ingestion/jobs/{sync_run_id}` | `GET` | Read run status, counts, and partial-failure details. | `200 OK` run summary | `404` unknown run |
| `/internal/catalog-ingestion/jobs/{sync_run_id}/retry` | `POST` | Retry failed slices or event publication for a partial run. | `202 Accepted` retry job | `409` run not retryable |
| `/internal/catalog-ingestion/sources/{source}/watermark` | `GET` | Inspect committed cursor/watermark for delta ingestion. | `200 OK` watermark payload | `404` unknown source |

### 5.2 Governance APIs for attach logic and constraints

| Endpoint | Method | Purpose | Success response | Error behavior |
|----------|--------|---------|------------------|----------------|
| `/internal/attach-definitions/{attach_definition_id}` | `PUT` | Create or replace a draft attach definition from upstream integration or internal tooling. | `200 OK` saved draft/version | `400` invalid graph references, `409` overlapping active version |
| `/internal/attach-definitions/{attach_definition_id}/publish` | `POST` | Publish a reviewed attach definition to downstream consumers. | `202 Accepted` publish version | `403` missing approval scope, `409` unresolved validation issues |
| `/internal/constraint-sets/{constraint_set_id}` | `PUT` | Create or replace a draft merchandising constraint set. | `200 OK` saved draft/version | `400` invalid scope or thresholds |
| `/internal/constraint-sets/{constraint_set_id}/publish` | `POST` | Publish a constraint set with channel-specific projections. | `202 Accepted` publish version | `403` missing approval scope, `409` conflicts with active rules |

### 5.3 Event contracts

| Topic | Producer | Consumers | Payload highlights |
|-------|----------|-----------|--------------------|
| `catalog.product.upserted.v1` | Ingestion service | Product graph, look store, analytics, cache invalidation | `product_id`, lifecycle state, changed attributes, source lineage, published timestamp |
| `catalog.product.retired.v1` | Ingestion service | Product graph, recommendation engine, search/index | `product_id`, retirement reason, effective timestamp |
| `inventory.availability.updated.v1` | Ingestion service | Recommendation engine, storefront cache, analytics | `sku_id`, channel/region, availability state, quantity bucket, freshness metadata |
| `merchandising.attach-definition.published.v1` | Attach registry | Recommendation engine, look store, analytics | `attach_definition_id`, anchor scope, candidate set refs, precedence, effective window |
| `merchandising.constraint-set.published.v1` | Constraint registry | Recommendation engine, delivery filters, analytics | `constraint_set_id`, scope, priority, include/exclude clauses, inventory thresholds |
| `catalog.sync-run.completed.v1` | Ingestion service | Observability, ops workflows | run totals, duration, partial-failure counts, source watermark |

### 5.4 Contract rules

- All mutation and publish endpoints require authenticated service or admin access per `docs/project/integration-standards.md`.
- Mutation endpoints use idempotency keys so connector retries do not double-create drafts or publish actions.
- Event payloads include canonical IDs only; source IDs remain in lineage fields and are not used by consumers for joins.

---

## 6. Integration points

| Integration | Mode | Auth | Retry / failure pattern | Notes |
|-------------|------|------|-------------------------|-------|
| **PIM** | Polling API or batch export | Read-only service account or API key | Retry 429/5xx with exponential backoff; do not mark catalog empty on failure | Primary source for rich product attributes |
| **Shopify** | Polling API plus optional webhook | API token | Use cursor-based delta fetch; dedupe webhook + poll overlap | Source for commerce-visible assortment and channel visibility |
| **OMS** | Polling API or file drop | Service account | Retry transient failures; quarantine malformed availability rows | Primary source for inventory and fulfillment availability |
| **DAM** | Polling API or batch manifest | API key/OAuth | Retry transient failures; tolerate lag without blocking product upsert | Media enrichment should not block sellability if optional |
| **Custom Made** | Polling API or export | Service account | Same transient retry policy; explicit partial-run handling | Provides CM-specific attributes and availability semantics |
| **Product graph / look store** | Async events or projection read | Internal service auth | Rebuild from replay or topic offset on failure | Downstream dependency, not source-of-truth |
| **Recommendation engine** | Projection read + async events | Internal service auth | Uses last good projection if event lag occurs | Consumes product, inventory, attach logic, constraints |
| **Analytics / observability** | Async events | Internal service auth | Dead-letter on sink failure; no silent drop | Required for SLA, error-rate, and freshness reporting |

---

## 7. Operational model and non-functional requirements

### 7.1 Freshness and performance targets

- **Inventory delta propagation:** target under **5 minutes** from accepted upstream change to published downstream availability event.
- **Catalog delta propagation:** target under **30 minutes** from accepted upstream change to published product event.
- **Full refresh completion:** target same-day completion inside the agreed maintenance window; downstream consumers continue serving last good state during the run.
- **Run concurrency:** one full run per source at a time; deltas may run in parallel with different sources but must serialize per source and entity partition.

### 7.2 Reliability controls

- Per-source watermarks prevent duplicate delta windows.
- Writes use upsert semantics keyed by canonical IDs and natural lineage keys.
- Publication uses an outbox so store writes and event publication remain recoverable.
- Quarantine retains invalid records with validation reason and replay path.

### 7.3 Observability requirements

- Metrics: run duration, accepted/quarantined record counts, source lag, event publication lag, freshness SLA breaches.
- Alerts: source unavailable, repeated schema validation failures, watermark drift, outbox backlog, inventory freshness breach.
- Reconciliation: compare upstream counts and hash totals with canonical projections for each full run.

---

## 8. Risks and trade-offs

| Area | Chosen direction | Alternative considered | Trade-off / risk |
|------|------------------|------------------------|------------------|
| **Freshness model** | Hybrid full + delta/event ingestion | Full loads only | More moving parts, but avoids stale inventory and simplifies recovery when deltas drift |
| **Attach logic system of record** | Platform registry is downstream serving record | Read attach logic directly from each source at runtime | Central governance and auditability improve consistency, but require explicit publish workflow and ownership |
| **Constraint management** | Central registry with channel-scoped projections | Per-channel rule stores | Central policy reduces duplication, but conflicts must be resolved at publish time |
| **Storage shape** | Separate catalog and availability projections | Single wide product document | Faster inventory updates and less write amplification, but adds join logic for downstream consumers |
| **Downstream propagation** | Async event fan-out from canonical stores | Direct synchronous callbacks from sync job | Lower coupling and better replay, but eventual consistency must be tolerated and monitored |
| **Validation behavior** | Quarantine invalid slices and publish accepted records | Fail entire run on first invalid record | Protects freshness for most products, but requires strong reconciliation so partial failures are visible |

### Primary implementation risks

1. **Source schema drift** can break mappings and silently reduce catalog completeness unless validation coverage is strict.
2. **Inventory semantics differ by source** (on-hand, available-to-promise, sellable) and require a single canonical availability policy before implementation.
3. **Attach and constraint ownership** may span merchandising and integration teams; publish workflow permissions must be settled before build.
4. **Downstream lag** can cause recommendation decisions to use stale inventory or constraints if event processing backlogs are not monitored.

---

## 9. Missing decisions that must be confirmed during implementation planning

These are recorded explicitly so the next stage does not guess:

1. Exact upstream system owners, sandbox availability, and contract versioning commitments for each v1 source.
2. Canonical availability policy: whether recommendation filtering uses binary sellable state, quantity buckets, or ATP-derived thresholds.
3. Whether attach definitions are authored only inside the platform or also imported from one or more source systems.
4. Region/channel granularity required for inventory and merchandising constraints at launch.
5. Whether downstream consumers will read via event-driven local projections only, direct read APIs, or a mixed model.

None of these block the architecture artifact itself, but the implementation plan must convert each into a named work package or explicit assumption.

---

## 10. Readiness criteria

- [x] Critical components, boundaries, and ownership are explicit.
- [x] Full-load, delta, replay, and failure paths are defined.
- [x] Internal control APIs and publish event contracts are defined for implementation planning.
- [x] Attach logic and merchandising constraints have a concrete serving architecture instead of an unresolved placeholder.
- [x] Risks, trade-offs, and missing decisions are isolated so downstream work does not hide them.
- [x] Downstream promotion target is identified: `docs/boards/implementation-plan.md`.

---

## 11. Approval / milestone-gate notes

- **Normal approval path:** Because the item approval mode is **HUMAN_REQUIRED**, a non-autonomous review flow would move this artifact to `READY_FOR_HUMAN_APPROVAL`.
- **Autonomous issue run behavior:** `docs/project/autonomous-automation-config.md` sets autonomous mode to ON, allowing this run to complete with commit, push, PR, and a non-blocking board state after review thresholds are met.
- **Milestone gates:** No separate UI-readiness gate applies to this architecture artifact. Any future publish-flow approval UI is a downstream implementation concern, not a blocker for the ingestion foundation architecture.

---

## 12. Board update recommendation

- Add **TA-006** to `docs/boards/technical-architecture.md`.
- Set status to **APPROVED** for this autonomous run, with notes that the artifact was produced from issue-created automation and is ready to seed implementation planning.
- Create **IP-001** on `docs/boards/implementation-plan.md` with status `TODO`, upstream `TA-006`, and notes that implementation planning must resolve the explicit missing decisions in §9.

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Technical architecture — Catalog and inventory ingestion (`TA-006`)  
**Stage:** Architecture  
**Trigger:** Issue-created automation (Issue #27)  
**Approval mode:** HUMAN_REQUIRED

### Overall disposition

**Eligible for promotion.** The artifact defines concrete components, data flow, contracts, integration boundaries, failure behavior, and downstream readiness for F1. All six dimensions score at least 4, average 4.8, confidence HIGH. Under normal governance the item would be **READY_FOR_HUMAN_APPROVAL**; because autonomous mode is ON for this run, the board may be updated to **APPROVED** so implementation planning can start without a blocking manual state.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|-------|----------|
| **Clarity** | 5 | Explicit metadata, architectural decisions, component table, and sectioned data/API flows make the artifact easy to consume. |
| **Completeness** | 5 | Covers components, canonical entities, full and delta flows, APIs, event contracts, integrations, risks, and readiness criteria. |
| **Implementation Readiness** | 5 | The next stage can turn this into work packages, contracts, and sequencing without inventing core service boundaries. |
| **Consistency With Standards** | 4 | Aligns with architecture overview, data standards, API standards, and integration standards; downstream board promotion is explicit. |
| **Correctness Of Dependencies** | 5 | Upstream feature F1 and shared standards are referenced accurately; downstream implementation planning dependency is stated. |
| **Automation Safety** | 5 | The artifact records the issue-created trigger, approval mode, normal approval path, and the autonomous-mode exception used for board status. |

**Average:** 4.8. **Minimum dimension:** 4. **Threshold:** Average above 4.1 with no dimension below 4 — **met**.

### Confidence rating

**HIGH.** The upstream feature and shared standards are sufficiently stable to define implementation-oriented boundaries and contracts. Remaining uncertainty is isolated to explicit decisions in §9 rather than hidden in the core design.

### Blocking issues

**None.**

### Recommended edits

**None required for architecture-stage completion.** During implementation planning, add concrete per-source connector sequencing and the chosen availability policy to the resulting plan artifact.

### Explicit recommendation

Per approval mode **HUMAN_REQUIRED**, the standard recommendation would be **READY_FOR_HUMAN_APPROVAL**. Because autonomous mode is ON for this issue-created run and review thresholds were met, the board update for this run may use **APPROVED** as the non-blocking state.

### Propagation to upstream

**None required.** No human rejection comments were present. If source ownership or attach-logic governance changes materially, update this architecture and the F1 feature spec together.

### Pending confirmation

- Human confirmation of the chosen availability policy and attach-definition ownership model is still desirable for long-term governance.
- Deterministic implementation details such as connector-specific rate limits, topic partitions, and storage technology selection should be fixed in the implementation plan, not retroactively inferred by builders.
