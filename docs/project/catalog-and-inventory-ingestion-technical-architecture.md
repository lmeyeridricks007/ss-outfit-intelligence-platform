# Technical Architecture: Catalog and Inventory Ingestion

**TA ID:** TA-006  
**Feature:** FEAT-001 / F1 — Catalog and inventory ingestion  
**BR(s):** BR-002 (data ingestion and identity)  
**Approval mode:** HUMAN_REQUIRED  
**Trigger:** Direct run using GitHub issue #27 context  
**Source:** `docs/features/catalog-and-inventory-ingestion.md`, `docs/project/architecture-overview.md`, `docs/project/domain-model.md`, `docs/project/api-standards.md`, `docs/project/data-standards.md`, `docs/project/integration-standards.md`  
**Traceability:** Downstream of approved feature breakdown (`docs/features/catalog-and-inventory-ingestion.md`, `docs/boards/features.md` FEAT-001). Feeds `docs/boards/implementation-plan.md`, F5 product graph, F6 outfit graph / look store, F10 merchandising rules engine, and F11 delivery API readiness.  
**Status:** Drafted for architecture-stage review.  
**Review:** Architecture-stage artifact; assess for implementation readiness, dependency correctness, and standards alignment.

---

## 1. Objective and scope

Provide a production-oriented ingestion architecture that accepts catalog, inventory, attach logic, and merchandising-constraint inputs from approved upstream systems; normalizes them into canonical contracts; and publishes governed downstream data for product graph, look store, rules evaluation, and recommendation delivery.

This architecture explicitly keeps upstream systems as systems of record for source data capture while isolating downstream consumers from source-specific schemas, timing, and error behavior.

### In scope for this architecture

- Multi-source ingestion for catalog and inventory domains.
- Canonical normalization, validation, quarantine, and replay controls.
- Contract support for attach logic and merchandising constraints needed by downstream consumers.
- Internal trigger APIs, async topics, storage boundaries, and failure handling.
- Operational controls, auditability, and readiness criteria for implementation planning.

### Out of scope for this architecture

- Redesign of upstream PIM, OMS, DAM, Shopify, or Custom Made systems.
- End-user merchandising UI and authoring workflows.
- Recommendation ranking logic and pricing engine behavior.
- Final decision on which upstream team owns attach logic governance; that is a required follow-up decision recorded below.

---

## 2. Architecture summary

The chosen architecture is a **control-plane + adapter + canonical-store** pattern:

1. **Ingestion Control API** accepts scheduled, event-driven, and manual sync requests.
2. **Sync Orchestrator** resolves the source, scope, cursor, and retry policy for each run.
3. **Source Adapters** pull or receive source-specific payloads from PIM, Shopify, OMS, DAM, Custom Made, and any approved attach-logic feed.
4. **Normalization and Validation Pipeline** maps source payloads to canonical entities and enforces schema, reference, and business-rule checks.
5. **Quarantine and Replay** stores invalid records for operator triage without corrupting the last good downstream state.
6. **Canonical Catalog Store** persists product, inventory, source mapping, and attach-definition records with idempotent upsert semantics.
7. **Projection Publisher** emits canonical change events and updates consumer-oriented projections for graph, merchandising, and delivery consumers.
8. **Observability and Audit** records run history, freshness, error classes, and replay activity.

This direction favors **durable canonical state plus emitted change events** over direct source-to-consumer fanout. The trade-off is extra storage and projection logic, but it prevents each downstream feature from re-solving schema drift, retries, and source precedence independently.

---

## 3. Component responsibilities

| Component | Responsibility | Inputs | Outputs | Ownership boundary |
|-----------|----------------|--------|---------|--------------------|
| **Ingestion Control API** | Accept internal run requests and authenticated source webhooks; create sync jobs; expose job status | `POST /internal/catalog-sync-jobs`, approved webhook calls, scheduler triggers | `sync_job` record, queued work item, job status responses | Internal platform boundary; no customer-facing access |
| **Scheduler / Trigger Manager** | Launch recurring full and delta jobs by source and domain | Cron or workflow configuration | Sync job requests | Platform operations boundary |
| **Sync Orchestrator** | Resolve source config, run type, cursor, checkpointing, retries, and downstream publish scope | Sync job request, source config, previous checkpoints | Adapter execution plan, run status, retry decisions | Ingestion service boundary |
| **Source Adapter: PIM** | Pull canonicalizable product and attribute data from PIM | PIM APIs/files | Raw product batches, source metadata | External integration boundary |
| **Source Adapter: Shopify** | Pull channel-facing catalog and publishability attributes | Shopify APIs/webhooks | Raw product and availability batches | External integration boundary |
| **Source Adapter: OMS / inventory** | Pull inventory snapshots or deltas needed for shoppability filtering | OMS APIs/events/files | Raw inventory records, inventory checkpoints | External integration boundary |
| **Source Adapter: DAM / asset metadata** | Pull asset references and media completeness signals used downstream | DAM APIs/files | Raw asset metadata | External integration boundary |
| **Source Adapter: Custom Made** | Pull CM-specific product applicability and availability metadata | Custom Made APIs/files | Raw CM catalog and availability payloads | External integration boundary |
| **Source Adapter: Attach / constraint feed** | Ingest attach-relationship or merchandising-constraint inputs when the upstream source is approved | External API/file/event feed | Raw attach or constraint records | External integration boundary; exact owner is a missing decision |
| **Normalizer** | Map raw records to canonical entities using source-specific mapping rules | Raw adapter payloads, mapping config, domain standards | Canonical `Product`, `InventorySnapshot`, `AttachDefinition`, `MerchandisingConstraint`, `SourceMapping` records | Internal transformation boundary |
| **Validator** | Enforce required fields, enum/domain validity, cross-record reference checks, idempotency keys, and source precedence rules | Canonicalized records, schema definitions, reference data | Accepted records, rejected records with error classification | Internal governance boundary |
| **Quarantine Store** | Persist rejected records for operator review and selective replay | Rejected records, validation metadata | Quarantine entries, replay requests | Internal ops boundary |
| **Canonical Catalog Store** | Persist canonical product, inventory, source mapping, and attach-definition state with version metadata | Accepted canonical records | Read models, publish triggers, point-in-time recovery | Internal source-of-truth-for-platform boundary |
| **Projection Publisher** | Emit downstream events and materialized views optimized for graph and rules consumers | Canonical store changes | Topics, projection tables, cache invalidation events | Internal async boundary |
| **Run Ledger / Audit Store** | Track sync runs, checkpoints, freshness, operator actions, and replay events | Job lifecycle events, audit metadata | Run history, dashboards, audit trail | Internal ops/governance boundary |
| **Consumer Projection: Graph Feed** | Expose canonical product and attach data to F5/F6 | Canonical changes | Graph-ready product and relation projection | Downstream handoff boundary |
| **Consumer Projection: Merchandising Feed** | Expose attach and constraint records needed by F10 / F11 | Canonical changes | Constraint projection, attach definitions, freshness status | Downstream handoff boundary |

### Canonical entities produced by this feature

- **Product**: `product_id`, identifiers, merchandising attributes, lifecycle status, publishability metadata, RTW/CM applicability.
- **InventorySnapshot**: `product_id`, location or scope, availability signal, quantity or stock band, effective timestamp.
- **AttachDefinition**: `attach_definition_id`, anchor product/group, related product/group, relationship type, priority, source metadata, effective window.
- **MerchandisingConstraint**: `constraint_id`, target scope (channel, region, placement, category, product), constraint type, effective window, source metadata.
- **SourceMapping**: external source identifier to canonical ID mapping, source priority, version metadata.
- **SyncRun**: run identifier, trigger type, source, scope, checkpoint, status, counts, failure classification.

---

## 4. Data flow

### 4.1 Full or delta catalog sync

1. Scheduler or operator calls **Ingestion Control API** with source, domain, and scope.
2. **Sync Orchestrator** loads source configuration, determines full or delta cursor, and dispatches the matching **Source Adapter**.
3. Adapter reads source payloads in pages or batches and writes immutable raw-run metadata to the **Run Ledger**.
4. **Normalizer** maps source records to canonical `Product`, `SourceMapping`, and optional `AttachDefinition` or `MerchandisingConstraint` records.
5. **Validator** enforces schema and reference checks:
   - required identifiers and timestamps
   - enum/value validity
   - source precedence and canonical ID mapping rules
   - duplicate detection within the run and within the replay window
6. Valid records are upserted into the **Canonical Catalog Store** with versioning metadata; invalid records are written to **Quarantine Store**.
7. **Projection Publisher** emits change topics and refreshes graph and merchandising projections.
8. **Run Ledger** records completion state: success, partial success, or failed.

### 4.2 Inventory update flow

1. OMS or approved inventory source sends a delta event or is polled on schedule.
2. Inventory adapter normalizes payloads into `InventorySnapshot` records keyed by `product_id` and inventory scope.
3. Validator rejects empty or stale snapshots that would incorrectly erase the last known good state.
4. Canonical store upserts the new snapshot while retaining the last successful checkpoint.
5. Projection publisher emits `catalog.inventory.upserted.v1` and updates the delivery-facing availability projection.
6. Downstream consumers apply freshness windows rather than assuming per-transaction accuracy.

### 4.3 Attach logic and merchandising-constraint flow

1. Approved upstream source delivers attach definitions or merchandising constraints by file, API, or event.
2. Attach/constraint adapter normalizes data into `AttachDefinition` and `MerchandisingConstraint`.
3. Canonical store persists both the business payload and source metadata (`source_system`, `source_record_id`, `received_at`, `precedence`).
4. Projection publisher exposes:
   - graph-oriented relationships for F5/F6
   - rules-oriented constraints for F10/F11
5. When the source-of-record decision changes, the boundary remains stable because downstream consumers depend on canonical contracts rather than direct source payloads.

### 4.4 Failure and replay flow

1. Adapter timeout, 429, 5xx, or transport error is retried with exponential backoff per integration standards.
2. Non-retryable 4xx or schema failures are logged with source payload identifiers.
3. Invalid records move to **Quarantine Store**; accepted records continue so one bad record does not abort the entire batch unless the failure-rate threshold is exceeded.
4. Operators replay quarantined records after mapping or source corrections using the original run context.
5. Downstream consumers continue reading the last successful projections until a newer successful publish is available.

---

## 5. API implications

### 5.1 Internal APIs

#### `POST /internal/catalog-sync-jobs`

Creates a sync job for a source/domain/scope combination.

```json
{
  "source": "pim",
  "domains": ["catalog", "attach"],
  "scope": "delta",
  "cursor": "2026-03-18T00:00:00Z",
  "trigger": "manual"
}
```

**Response:** `202 Accepted`

```json
{
  "job_id": "sync_01HRV0Y3CZ4V1AJ8Y9G2SQNQ4R",
  "status": "queued",
  "accepted_domains": ["catalog", "attach"]
}
```

**Errors**
- `400` invalid source, domain, or incompatible scope
- `401` unauthenticated internal caller
- `409` duplicate active sync for the same source/domain/scope
- `422` checkpoint or source configuration invalid

#### `GET /internal/catalog-sync-jobs/{job_id}`

Returns run status, counters, and quarantine summary.

```json
{
  "job_id": "sync_01HRV0Y3CZ4V1AJ8Y9G2SQNQ4R",
  "status": "partial_success",
  "source": "pim",
  "domains": ["catalog", "attach"],
  "records_read": 21043,
  "records_written": 20980,
  "records_quarantined": 63,
  "started_at": "2026-03-18T10:00:00Z",
  "completed_at": "2026-03-18T10:07:12Z"
}
```

#### `POST /internal/catalog-sync-jobs/{job_id}/replay`

Replays quarantined or failed slices after operator action.

**Constraints**
- Internal-only, authenticated, audited.
- Requires explicit replay scope (`record_ids` or `failure_class`).

### 5.2 Event contracts

#### `catalog.product.upserted.v1`

Producer: Projection Publisher  
Consumers: F5 product graph, F6 outfit graph / look store, indexing/search consumers

```json
{
  "event_id": "evt_01HRV14Q8F8MZJ9M3TY9Q12A2T",
  "occurred_at": "2026-03-18T10:07:12Z",
  "product_id": "prd_12345",
  "operation": "upsert",
  "source_system": "pim",
  "version": 42,
  "attributes": {
    "category": "jacket",
    "color": "navy",
    "style_family": "formal",
    "rtw_applicable": true,
    "cm_applicable": false
  }
}
```

#### `catalog.inventory.upserted.v1`

Producer: Projection Publisher  
Consumers: F10 merchandising rules engine, F11 delivery API read model, analytics freshness monitors

```json
{
  "event_id": "evt_01HRV15CEV7Y3FG8T8FA02XH2Y",
  "occurred_at": "2026-03-18T10:07:13Z",
  "product_id": "prd_12345",
  "inventory_scope": "web-us",
  "availability": "in_stock",
  "quantity_band": "11-25",
  "effective_at": "2026-03-18T10:05:00Z"
}
```

#### `catalog.attach-definition.upserted.v1`

Producer: Projection Publisher  
Consumers: F5 product graph, F10 merchandising rules engine

```json
{
  "event_id": "evt_01HRV16G9KEQTFM0P6M4CS98SN",
  "occurred_at": "2026-03-18T10:07:13Z",
  "attach_definition_id": "att_987",
  "anchor_product_id": "prd_12345",
  "related_product_id": "prd_67890",
  "relationship_type": "cross_sell",
  "priority": 100,
  "source_system": "pim"
}
```

### 5.3 Contract rules

- All mutation and replay endpoints require authentication and audit logging.
- Async contracts use stable canonical IDs and source metadata per `docs/project/data-standards.md`.
- Event consumers must be idempotent using `event_id` and entity version.
- Inventory events are authoritative only within their freshness SLA; consumers must check `effective_at`.

---

## 6. Integration points

| Integration | Direction | Mode | Auth expectation | Retry/failure behavior |
|-------------|-----------|------|------------------|------------------------|
| **PIM** | Outbound from platform | Scheduled full + delta API/file ingest | Service account or API key; read-only scope | Retry 429/5xx/timeouts; fail batch slice after max attempts; keep last good projection |
| **Shopify** | Outbound and optional inbound webhook | Delta API + webhook assist | API token or app credentials | Verify webhook authenticity; use checkpoint reconciliation to avoid missed events |
| **OMS / inventory source** | Outbound or inbound event | Near-real-time delta preferred; scheduled fallback supported | Service account, API key, or event credentials | Reject empty destructive snapshots unless explicitly marked full snapshot |
| **DAM** | Outbound | Scheduled sync | Read-only credential | Missing asset metadata quarantined without blocking non-media attributes unless configured otherwise |
| **Custom Made** | Outbound | Scheduled or event-assisted | Service account | CM-specific schema mapped through normalizer; non-retryable schema mismatch quarantined |
| **Attach / constraint system** | Outbound or inbound depending on final source | Batch or event | Per-source documented auth | Critical blocker if no approved source exists before implementation starts |
| **F5 Product graph** | Internal downstream | Async topic + projection table | Internal trust boundary | Consumers replay from topic or projection rebuild if missed |
| **F6 Outfit graph / look store** | Internal downstream | Async topic + projection table | Internal trust boundary | Same as graph feed |
| **F10 Merchandising rules engine** | Internal downstream | Constraint projection and inventory feed | Internal trust boundary | Reads canonical constraints; stale freshness alarm if feed delayed |
| **F11 Delivery API** | Internal downstream | Availability/read projection | Internal trust boundary | Must degrade to last good projection when freshness SLA is breached |

### In-repo vs external boundaries

- **External:** PIM, Shopify, OMS, DAM, Custom Made, and the future attach-logic source.
- **In-repo / internal platform:** Ingestion Control API, Orchestrator, Normalizer, Validator, Quarantine, Canonical Catalog Store, Projection Publisher, Run Ledger, downstream projections.

---

## 7. Operational model and failure behavior

### 7.1 Run isolation

- Each sync job is scoped by **source + domain + scope + checkpoint**.
- Only one active job per source/domain pair may mutate the same projection window unless explicitly marked as a backfill.
- Backfills write through the same canonical contracts but publish only after validation and checkpoint reconciliation.

### 7.2 Source precedence

- Product identity mapping is established in `SourceMapping`; canonical IDs remain stable once assigned.
- Source precedence must be explicit for overlapping fields:
  - PIM preferred for descriptive product attributes.
  - OMS preferred for inventory availability.
  - DAM preferred for asset metadata.
  - Attach/constraint precedence is a missing decision until the authoritative source is named.

### 7.3 Data freshness and degradation

- The ingestion layer publishes freshness timestamps per domain and source.
- Downstream consumers must prefer **last good state** over propagating empty or partial destructive updates.
- SLA breach raises alert events but does not hard-fail the customer-facing delivery path.

### 7.4 Quarantine policy

- Validation failures are classified as `schema`, `reference`, `precedence`, `duplicate`, or `policy`.
- A run is marked `partial_success` when the quarantined percentage is below the configured threshold.
- A run is marked `failed` when the threshold is exceeded or when a source checkpoint cannot be trusted.

### 7.5 Auditability

- Every manual trigger, replay, and override writes to the Run Ledger with actor, timestamp, scope, and rationale.
- Source payload identifiers are retained for replay and troubleshooting.

---

## 8. Risks and trade-offs

| Risk / trade-off | Chosen direction | Alternatives considered | Why this direction |
|------------------|------------------|-------------------------|--------------------|
| **Canonical store plus events vs direct fanout** | Persist canonical state and publish events | Direct source-to-consumer fanout | Needed for replay, last-good-state recovery, and consistent downstream contracts |
| **Inventory as snapshots vs pure event stream** | Support delta-first ingest with snapshot-safe semantics | Full snapshots only; raw event stream only | Accommodates OMS variance while avoiding destructive empty updates |
| **Attach logic authority unclear** | Preserve canonical `AttachDefinition` contract with source metadata and precedence | Hard-code PIM as authority now; defer attach entirely | Keeps implementation shape stable while surfacing a human decision that cannot be guessed |
| **Partial success vs all-or-nothing batches** | Allow partial success with quarantine thresholds | Fail entire batch on first error | Reduces publish delays while still surfacing quality issues |
| **Near-real-time vs scheduled inventory only** | Architect for both; implementation plan selects latency class per source | Force real-time for all; nightly only | Upstream capability is unknown today and should not force one integration shape prematurely |
| **Shared pipeline vs source-specific code paths** | Shared normalizer/validator contracts with per-source adapters | Fully bespoke flows per source | Improves maintainability and standards alignment |

---

## 9. Missing decisions requiring human resolution

These decisions are explicit because they affect implementation sequencing and ownership. They are not hidden TBDs.

1. **System of record for attach logic**  
   Required to finalize precedence rules and ownership for `AttachDefinition`.

2. **Authority model for merchandising constraints**  
   Need decision on whether constraints originate centrally, per channel, or as a mixed model with precedence.

3. **Inventory latency class by downstream consumer**  
   Need explicit real-time vs near-real-time expectations for F10 and F11 to choose polling, webhook, or event-stream implementation first.

4. **Approved v1 source roster and field ownership matrix**  
   Need exact source list for MVP and authoritative owner per field group.

5. **Operational thresholds**  
   Need quarantine percentage threshold, freshness SLA by domain, and replay retention window.

---

## 10. Readiness criteria for implementation planning

Implementation planning can proceed when the following are accepted as the working baseline:

- [ ] TA-006 artifact is reviewed and moved to `READY_FOR_HUMAN_APPROVAL` or beyond per board policy.
- [ ] Canonical entity contracts (`Product`, `InventorySnapshot`, `AttachDefinition`, `MerchandisingConstraint`, `SourceMapping`, `SyncRun`) are accepted as the integration baseline.
- [ ] Internal sync-job API shape and event topics are accepted as the initial contract.
- [ ] Source precedence rules are accepted for product, inventory, and asset fields.
- [ ] Human decision recorded for attach-logic system of record.
- [ ] Human decision recorded for merchandising-constraint authority model.
- [ ] Inventory freshness targets recorded for at least the first implementation slice.
- [ ] v1 source roster and authentication method documented for each source.
- [ ] Quarantine, replay, and last-good-state behavior accepted by architecture and operations stakeholders.

---

## 11. Approval and milestone-gate notes

- **Approval mode:** `HUMAN_REQUIRED` because this artifact defines integration boundaries, contracts, and cross-feature dependencies.
- **Promotion rule:** Do not move this item to `APPROVED` without explicit human approval evidence on the board.
- **Downstream impact:** `docs/boards/implementation-plan.md` should not receive a promoted row until TA-006 is explicitly `APPROVED`.
- **Current follow-up gate:** Human approval should confirm the missing-decision owners for attach logic, merchandising constraints, and inventory latency before implementation-plan fanout.

---

## 12. Acceptance criteria check and follow-ups

### Acceptance criteria confirmation

| Requirement / success signal from issue #27 | Architecture response |
|---------------------------------------------|-----------------------|
| Ingest catalog and inventory from approved upstream sources | Source-adapter pattern defined for PIM, Shopify, OMS, DAM, Custom Made, and approved attach/constraint sources |
| Normalize and validate inbound data | Normalizer, Validator, Quarantine, and canonical contracts defined |
| Support attach logic definition | `AttachDefinition` contract and adapter boundary defined; authority decision escalated explicitly |
| Support merchandising constraints for downstream consumption | `MerchandisingConstraint` contract and consumer projection defined |
| Reduced ingestion errors | Validation, quarantine, idempotent upserts, replay, and last-good-state behavior reduce corruption and destructive publishes |
| Reduced manual catalog correction work | Shared canonical mapping and source-precedence model prevent downstream teams from fixing source-specific payload issues independently |
| Faster time to publish product changes | Delta/event-assisted flow, replay, and projection publisher reduce full-rebuild dependency |
| Document component responsibilities, data flow, APIs, and risks | Covered in sections 3 through 9 |

### Follow-ups before implementation planning

- Name the authoritative attach-logic owner and source system.
- Confirm whether merchandising constraints are centrally governed or channel-specific with precedence.
- Set v1 freshness targets for inventory consumers.
- Approve the v1 field ownership matrix by source.

---

## 13. Recommended board update

- **Board:** `docs/boards/technical-architecture.md`
- **Item:** `TA-006`
- **Recommended status after this run:** `READY_FOR_HUMAN_APPROVAL`
- **Evidence:** Technical architecture artifact complete; review pass below meets the threshold for a `HUMAN_REQUIRED` item; explicit missing decisions recorded; no human approval claimed.
- **Promotion decision:** No promotion yet. Implementation-plan row should be created only after explicit human approval moves TA-006 to `APPROVED`.

---

## 14. Review record (per `docs/.cursor/prompts/review-pass.md`)

## Review: Technical architecture: Catalog and inventory ingestion — TA-006

**Trigger:** Direct run using issue #27 context

**Disposition:** READY_FOR_HUMAN_APPROVAL

**Scores (1–5):** Clarity 5 | Completeness 5 | Implementation Readiness 4 | Consistency 5 | Dependencies 5 | Automation Safety 5 → **Average:** 4.8

**Confidence:** MEDIUM — The architecture is implementation-oriented and complete enough for planning, but three explicitly recorded business decisions still need human confirmation before implementation fanout.

**Blocking issues:** None

**Required edits:** None. Human approval should assign owners and target dates for the missing decisions in section 9 as part of approval notes.

**Approval-mode interpretation:** HUMAN_REQUIRED → recommend READY_FOR_HUMAN_APPROVAL, not direct APPROVED

**Upstream artifacts to update (if rejection comments apply):** None

**Board update:** Set status to `READY_FOR_HUMAN_APPROVAL`; add note: `Review passed on direct run; human approval pending. Follow-ups: attach logic authority, merchandising constraint authority, inventory latency targets.`

**Remaining human/merge requirements:** Human approval is required before TA-006 can move to `APPROVED` and promote to `docs/boards/implementation-plan.md`. No merge-aware completion state applies to this artifact.
