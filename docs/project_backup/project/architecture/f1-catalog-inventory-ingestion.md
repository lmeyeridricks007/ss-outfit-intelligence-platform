# F1 Technical Architecture: Catalog and Inventory Ingestion

**Feature ID:** F1  
**Issue:** #34  
**Stage:** Technical architecture  
**Primary BR:** BR-2 (data ingestion and identity)  
**Upstream artifacts:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`  
**Reference standards:** `docs/project/domain-model.md`, `docs/project/data-standards.md`, `docs/project/api-standards.md`, `docs/project/integration-standards.md`  
**Downstream board:** `docs/boards/implementation-plan.md`  
**Trigger:** Issue-created automation run in autonomous mode (`docs/project/autonomous-automation-config.md`)  
**Status:** Drafted for implementation planning and PR review

---

## 1. Purpose and scope

F1 establishes the ingestion foundation for the rest of Phase 1 and the recommendation stack that follows. It is responsible for bringing product, inventory, asset, and source metadata into a canonical platform representation so downstream capabilities can rely on stable product identifiers and current assortment state.

This architecture covers:

- Source connectors for PIM, Shopify, OMS, DAM, and Custom Made.
- Raw ingestion, normalization, validation, and deduplication.
- Canonical product and inventory storage.
- Product change and inventory change events for downstream consumers.
- Internal APIs and contracts used by F5 (product graph), F6 (look store), F9 (recommendation engine), and F11 (Delivery API).
- Security, observability, operational risks, and phased rollout.

This architecture does **not** replace source systems. It creates a governed platform copy optimized for recommendation, graph, and delivery use cases, consistent with `docs/project/architecture-overview.md`.

---

## 2. Architectural decisions

1. **Canonical IDs are assigned inside the platform.** Source identifiers remain mapped, but downstream services consume stable `product_id` and `variant_id` values as defined in `docs/project/domain-model.md` and `docs/project/data-standards.md`.
2. **Product content and inventory are separated at write time, joined at read time.** Product attributes change less frequently than inventory; separate storage and event streams reduce contention and let inventory update faster.
3. **Every connector lands immutable raw payloads before transformation.** This supports replay, audit, schema evolution, and defect isolation.
4. **Normalization is source-aware but outputs a shared canonical contract.** Each connector may parse differently, but all downstream readers see the same product, variant, inventory, and asset shapes.
5. **Events are emitted from canonical writes, not directly from source payloads.** Downstream systems consume business-meaningful changes instead of source-specific formats.
6. **Inventory is fail-soft for recommendation surfaces.** When a fresh inventory update is temporarily unavailable, downstream readers can still read the latest known sellable state, but freshness lag is surfaced through monitoring and response metadata.

---

## 3. Logical architecture

```text
Source systems
  PIM        Shopify        OMS        DAM        Custom Made
    |            |            |          |              |
    +------------+------------+----------+--------------+
                                 |
                                 v
                     Connector layer and schedulers
                 (pollers, webhooks, backfills, retries)
                                 |
                                 v
                      Raw landing and replay store
                                 |
                                 v
                  Normalization, validation, mapping layer
          (schema checks, source precedence, idempotency, dedupe)
                                 |
                                 v
      +--------------------------+---------------------------+
      |                                                      |
      v                                                      v
Canonical product store                              Inventory projection store
(product, variant, source map, assets)              (variant/location availability)
      |                                                      |
      +--------------------------+---------------------------+
                                 |
                                 v
                         Catalog event publisher
             (product upserted, retired, inventory changed, failed)
                                 |
          +----------------------+----------------------+-------------------+
          |                      |                      |                   |
          v                      v                      v                   v
     F5 Product graph       F6 Look store        F9 Engine inputs     F11 Delivery API
                                 |
                                 v
                    Monitoring, dead-letter, replay tooling
```

### 3.1 Component responsibilities

| Component | Responsibility | Primary outputs |
|-----------|----------------|-----------------|
| **Connector layer** | Pull or receive source-system payloads; authenticate to sources; manage backoff and retries per `docs/project/integration-standards.md` | Raw payloads, connector metrics |
| **Raw landing and replay store** | Persist immutable source payloads with receipt metadata and checksum | Replayable raw records, audit history |
| **Normalization and mapping layer** | Validate payloads, apply source precedence, map source IDs to canonical IDs, reject or quarantine malformed records | Canonical product and inventory records, validation failures |
| **Canonical product store** | Persist canonical product aggregate, variants, taxonomy, assets, and source references | Product read model for F5, F6, F9, F11 |
| **Inventory projection store** | Persist availability by variant, location, region, and channel scope | Current sellable inventory read model |
| **Catalog event publisher** | Emit downstream catalog and inventory events from successful canonical writes | Product and inventory events |
| **Operational control plane** | Track job runs, dead-letter queues, backfills, replay requests, and freshness lag | Run history, alert triggers, operator views |

---

## 4. Source connectors and source-of-truth strategy

The BRs note that exact committed source ownership is still a missing decision. This architecture therefore proposes a default precedence model so implementation can proceed without guessing, while keeping the final owner assignment explicit in implementation planning.

| Source system | Expected content | Integration mode | Proposed precedence | Freshness target for v1 |
|---------------|------------------|------------------|---------------------|-------------------------|
| **PIM** | Core product content, taxonomy, attributes, merchandising metadata | Poll or export feed with daily full sync and incremental delta where available | Primary source for product master data | Incremental within 4h; full rebuild within 24h |
| **Shopify** | Channel publish status, ecommerce handles, variant merchandising details, selected price/display fields | Webhook plus scheduled reconciliation | Source for web-channel publication state; secondary for product content | Change reflected within 15m |
| **OMS** | Inventory by SKU and location, availability signals, sellable quantity | Poll or event feed | Primary source for inventory truth | Change reflected within 5m |
| **DAM** | Asset URLs, image metadata, swatches, media versioning | Poll or webhook | Primary source for media assets | Change reflected within 4h |
| **Custom Made** | CM fabrics, appointment-related assortment, custom attributes and lead-time metadata | Feed or scheduled export | Primary source for CM-only attributes not available in PIM | Change reflected within 30m to 4h, depending on feed capability |

### 4.1 Source precedence rules

When two sources populate the same logical field, the platform resolves conflicts in this order unless the implementation plan explicitly overrides it:

1. **PIM** for product taxonomy, descriptive attributes, and category hierarchy.
2. **DAM** for asset metadata and media URLs.
3. **OMS** for inventory availability and location-level stock.
4. **Shopify** for channel publication flags and commerce presentation metadata.
5. **Custom Made** for CM-only product extensions.

All source-origin fields are stored with `source_system`, `source_id`, `source_revision`, and `last_seen_at` so the platform can explain why a canonical value exists.

---

## 5. Canonical product and inventory model

This feature operationalizes the domain model's `Product` entity by creating canonical storage that downstream services can query without speaking directly to source systems.

### 5.1 Canonical product aggregate

Each canonical product contains:

- `product_id` as the stable aggregate identifier.
- Product status (`active`, `inactive`, `retired`, `draft_like` if imported before publish).
- Category and taxonomy attributes aligned to the domain model.
- Style attributes such as fabric, fit, color, pattern, season, occasion, style family, RTW/CM mode.
- Variant collection keyed by `variant_id`, with source SKU references.
- Asset references and media metadata.
- Source mapping metadata for every contributing system.
- Quality flags (missing image, missing category, conflicting source values, invalid size curve).

### 5.2 Inventory projection

Inventory is stored separately at the `variant_id` level and projected by:

- `location_id`
- `region`
- `channel`
- `available_to_sell`
- `reserved_quantity`
- `last_inventory_at`
- freshness status (`fresh`, `stale`, `unknown`)

This design lets recommendation and delivery layers apply inventory-aware filtering without mutating the core product aggregate on every stock change.

### 5.3 Supporting stores

| Store | Purpose | Why it exists |
|-------|---------|---------------|
| **Raw landing store** | Immutable copy of source payloads plus receipt metadata | Replay, audit, defect isolation |
| **Source mapping table** | Maps source keys to canonical `product_id` and `variant_id` | Stable IDs and deduplication |
| **Canonical product store** | Transactional source of truth for normalized product entities | Shared product contract for F5, F6, F9, F11 |
| **Inventory projection store** | Fast-changing stock and availability state | Low-latency inventory reads and inventory event emission |
| **Catalog search or read projection** | Query-optimized projection for downstream readers | Efficient fan-out without exposing write storage shape |

### 5.4 Canonical contract summary

The implementation plan should preserve the following logical contracts even if storage technology changes. These shapes make the F1 boundary explicit for F5, F6, F9, and F11.

| Contract | Required identifiers | Minimum required fields | Primary consumers |
|----------|----------------------|-------------------------|-------------------|
| **Product aggregate** | `product_id` | status, category, taxonomy path, fabric, fit, color, pattern, season, occasion, style family, RTW/CM applicability, `updated_at`, `source_refs`, `quality_flags` | F5, F6, F9, F11 |
| **Variant summary** | `variant_id`, `product_id` | source SKU refs, size or option attributes, publish status, price-display fields when approved for inclusion, `updated_at` | F9, F11 |
| **Inventory availability** | `variant_id`, `product_id`, `location_id` or regional scope | `available_to_sell`, `reserved_quantity`, `channel`, `region`, `last_inventory_at`, freshness status | F9, F11 |
| **Asset summary** | `product_id`, asset source key | asset version, asset type, URL or reference, sort order, swatch flag, `updated_at` | F6, F11 |
| **Source mapping record** | source system name, source object ID | mapped canonical ID, source revision, `last_seen_at`, mapping status | F1 operators and replay tooling |

This contract summary complements the entity rules in `docs/project/domain-model.md` and the identifier and event rules in `docs/project/data-standards.md`. Downstream consumers should not read raw source payloads or infer missing canonical identifiers from source-specific keys.

---

## 6. End-to-end data flow

### 6.1 Product and catalog flow

1. Connector authenticates to the source system and pulls or receives the next batch.
2. Raw payload is written to the landing store with connector name, checksum, source revision, and receive timestamp.
3. Normalization validates schema, required identifiers, and category or attribute rules.
4. Mapping logic resolves whether the record matches an existing canonical product or should create a new one.
5. Source precedence rules merge incoming fields into the canonical product aggregate.
6. Canonical write succeeds atomically for product, variants, source mappings, and quality flags.
7. Publisher emits `catalog.product.upserted` or `catalog.product.retired`.
8. F5, F6, and search projections consume the event and refresh their own models.

### 6.2 Inventory flow

1. OMS or Shopify inventory change is received or polled.
2. Raw inventory payload is persisted for replay.
3. Normalization maps source SKU to canonical `variant_id`.
4. Inventory projection store updates location and channel availability.
5. Publisher emits `inventory.level.changed` with the changed availability state.
6. F9 and F11 consumers refresh stock-aware recommendation candidates.

### 6.3 Failure flow

1. Malformed or unmappable payloads are quarantined, not dropped.
2. Connector retries transient failures using exponential backoff aligned to `docs/project/integration-standards.md`.
3. Permanent failures emit `catalog.ingestion.failed` and increment alerting counters.
4. Operators use replay tooling to retry from raw payloads after mapping or schema fixes.

---

## 7. Events and downstream contracts

F1 publishes canonical platform events so downstream systems can update without tight coupling to connector logic.

### 7.1 Event set

| Event name | Trigger | Required fields |
|------------|---------|-----------------|
| `catalog.product.upserted` | Product create or meaningful canonical update | `event_timestamp`, `product_id`, `source_system`, `source_revision`, `product_status`, `changed_fields` |
| `catalog.product.retired` | Product removed from sellable assortment or retired in master data | `event_timestamp`, `product_id`, `retired_reason`, `source_system` |
| `inventory.level.changed` | Variant/location availability changed | `event_timestamp`, `product_id`, `variant_id`, `location_id`, `available_to_sell`, `freshness_status`, `source_system` |
| `catalog.asset.updated` | Asset set changed in a way that affects customer display | `event_timestamp`, `product_id`, `asset_version`, `source_system` |
| `catalog.ingestion.failed` | Connector or normalization failure requiring operator attention | `event_timestamp`, `connector_name`, `source_key`, `error_code`, `retry_state` |

All events follow the canonical event conventions from `docs/project/data-standards.md`: event name, event timestamp, canonical identifiers where available, and no PII.

### 7.2 Consumer expectations

- **F5 Product graph:** Consumes product upserts and asset changes to build compatibility edges and category coverage.
- **F6 Look store:** Consumes product upserts and retire events to keep curated looks valid and to retire unavailable components.
- **F9 Recommendation engine:** Reads the catalog projection and inventory projection for candidate generation and filtering.
- **F11 Delivery API:** Uses the catalog read API or read projection for product details, imagery, and availability hints in responses.

Downstream consumers must treat F1 events as **at-least-once** and therefore implement idempotent handling using `product_id`, `variant_id`, and source revision metadata.

---

## 8. Internal APIs and read contracts

F1 is primarily event-driven, but downstream services still need read access to canonical product and availability data. These are internal service contracts, not customer-facing APIs.

### 8.1 Internal read APIs

| API | Purpose | Core response fields |
|-----|---------|----------------------|
| `GET /internal/v1/catalog/products/{product_id}` | Return canonical product aggregate for graph, look, or delivery readers | `product_id`, status, taxonomy, style attributes, assets, variant summaries, source_refs, quality_flags |
| `GET /internal/v1/catalog/variants/{variant_id}/availability` | Return inventory state for stock-aware recommendation and delivery | `variant_id`, `product_id`, channel availability, location summary, `last_inventory_at`, freshness status |
| `GET /internal/v1/catalog/products:search` | Query by category, attribute filters, source tag, or publish state for backfills and graph jobs | Product summaries with pagination |
| `GET /internal/v1/ingestion/jobs/{job_id}` | Operator visibility into run state and failures | Job status, counts, lag, error summary |
| `POST /internal/v1/ingestion/replays` | Re-run a connector batch or failed payload set | Replay request ID, status, target scope |

### 8.2 Contract rules

- Authentication and authorization follow `docs/project/api-standards.md`; all internal endpoints are authenticated and restricted by service identity.
- Responses do not expose source credentials or raw payloads.
- Read APIs return the latest canonical state plus freshness metadata so downstream services can make graceful fallback decisions.
- Search and replay endpoints are operational interfaces and should be rate-limited more aggressively than read endpoints.
- Version `v1` contracts should evolve additively; breaking field removals or semantic changes require a new internal version and downstream migration plan.
- Retired or stale records should remain queryable to authorized internal consumers when cleanup, replay, or look-validation workflows need historical context.

---

## 9. Security and governance

Although F1 is product-data focused rather than customer-profile focused, it still carries operational and governance requirements.

### 9.1 Security controls

- **Least privilege connectors:** Each source connector uses read-only credentials where possible.
- **Secret handling:** Credentials are stored outside code and rotated per platform policy.
- **Transport security:** All external calls use encrypted transport; webhook signatures are verified when supported.
- **Write-path authorization:** Only ingestion services and authorized operators can mutate canonical stores or trigger replays.
- **Auditability:** Every replay, manual correction, and source precedence override is logged with actor, timestamp, and reason.

### 9.2 Data governance

- F1 uses canonical IDs and source mappings consistent with `docs/project/data-standards.md`.
- No customer PII should be introduced into catalog payloads or logs.
- Quality flags are retained so downstream teams can distinguish "valid but incomplete" products from healthy products.
- Retired products are soft-retained for traceability and look cleanup rather than hard-deleted immediately.

---

## 10. Monitoring, alerting, and NFRs

### 10.1 Key metrics

| Area | Metric | Why it matters |
|------|--------|----------------|
| Connector health | Success rate, retry count, duration, bytes processed | Detect upstream outages and connector regressions |
| Freshness | Lag from source change to canonical write for catalog and inventory | BR-2 data freshness evidence |
| Data quality | Validation failures, unmapped SKUs, duplicate mappings, missing mandatory attributes | Prevent silent recommendation quality degradation |
| Event delivery | Publish lag, dead-letter volume, consumer lag | Keeps F5, F6, F9, and F11 in sync |
| Read APIs | Request rate, p95 latency, error rate | Protect downstream runtime dependencies |
| Inventory trust | Percentage of stale inventory records and age of oldest stale record | Prevent inaccurate stock-aware recommendations |

### 10.2 Alerts

Raise alerts when any of the following happens:

- Inventory freshness exceeds the agreed threshold for a channel or region.
- Product upsert failure rate spikes above the normal baseline.
- Unmapped source identifiers exceed a set percentage of batch volume.
- Event dead-letter queue grows continuously.
- Internal catalog read APIs exceed latency budget or return elevated 5xx errors.

### 10.3 Proposed operational targets

These targets are suitable for implementation planning and can be tightened later if source capabilities allow:

- Product attribute freshness: within 4 hours for incremental updates, within 24 hours for full reconciliation.
- Inventory freshness: within 5 minutes of OMS change receipt.
- Catalog event publish lag: within 2 minutes of canonical write.
- Internal catalog read API latency: p95 under 200 ms for single-product lookups.
- Replay objective: any failed batch can be replayed from raw payloads without manual data reconstruction.

---

## 11. Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Source ownership for fields is not fully ratified | Conflicting values or stalled connector design | Lock the proposed precedence model in implementation planning and record any overrides explicitly |
| SKU collisions or incomplete source mappings | Duplicate canonical products or broken inventory joins | Use mapping table with conflict detection and quarantine until resolved |
| Inventory latency from OMS is worse than recommendation needs | Out-of-stock recommendations reach runtime consumers | Separate freshness status, fail-soft reads, and alerts; allow conservative filtering when inventory is stale |
| DAM or CM feeds lag behind catalog master data | Missing images or incomplete CM presentation | Quality flags and asset-specific events; allow product ingestion without blocking on asset arrival |
| Full reprocessing becomes expensive as catalog grows | Long backfills and delayed fixes | Keep immutable raw payloads, incremental checkpoints, and partitioned replay support |
| Downstream teams couple directly to source-specific fields | Fragile integrations and duplicated logic | Publish only canonical contracts and reject direct source-format dependencies in implementation review |

### 11.1 Non-blocking open decisions

- Final confirmation of source-of-truth ownership per field and per region.
- Whether Shopify is only a consumer-facing publication source or also a partial pricing authority.
- Whether CM inventory is modeled as availability, appointment capacity, or configurable lead-time only.
- Whether the catalog read API is implemented as service endpoints, database views behind a gateway, or search-index-backed reads.

These do not block the architecture artifact; they should be captured as implementation-plan assumptions.

---

## 12. Phasing aligned to the feature deep-dive

### Phase 1A: Minimum viable ingestion foundation

- Implement PIM, OMS, and Shopify connectors.
- Stand up raw landing, normalization, source mapping, canonical product store, and inventory projection store.
- Publish product and inventory change events for F5 and F6.
- Expose internal read APIs for product and availability queries.

### Phase 1B: Enrichment and operational hardening

- Add DAM and Custom Made connectors.
- Add quality dashboards, dead-letter handling, replay workflow, and batch observability.
- Extend inventory projections with location and channel views needed by F9 and F11.
- Add catalog search projection for graph jobs and look validation.

### Phase 1C: Scale and readiness for downstream phases

- Tighten freshness and lag alerting based on production traffic.
- Add schema versioning and compatibility checks for emitted events.
- Formalize downstream SLOs for F9 and F11 catalog reads.
- Prepare implementation-plan work items for F5/F6 dependency handoff and F11 catalog response enrichment.

This phasing aligns with `docs/project/feature-list.md` and `docs/project/roadmap.md`: F1 must provide the engine-ready assortment foundation before F5 and F6 can fully populate graph relationships and curated looks.

---

## 13. Traceability to existing project docs

| Existing doc | How this architecture uses it |
|--------------|-------------------------------|
| `docs/project/architecture-overview.md` | Refines the ingestion layer into connector, canonical-store, and event-publisher components |
| `docs/project/domain-model.md` | Applies canonical `Product`, `Look`, and identifier rules to F1 storage and events |
| `docs/project/data-standards.md` | Inherits canonical ID, event, telemetry, and no-PII rules for product and inventory contracts |
| `docs/project/api-standards.md` | Defines auth, error, and response expectations for internal F1 APIs |
| `docs/project/integration-standards.md` | Defines connector auth, retries, idempotency, dead-letter, and replay expectations |
| `docs/project/roadmap.md` | Aligns rollout and dependencies with Phase 1 and the handoff into F5/F6/F9/F11 |

---

## 14. Review record

**Artifact:** F1 catalog and inventory ingestion technical architecture  
**Stage:** Architecture  
**Approval mode:** HUMAN_REQUIRED on the board unless overridden by autonomous completion rules  
**Review trigger:** Issue-created automation run

### 14.1 Overall disposition

Eligible for promotion. The artifact defines component boundaries, data flow, source connectors, canonical product storage, events, internal APIs, security, monitoring, risks, and phased rollout for F1. For this autonomous run, the board item may move to a non-blocking state after commit, push, and PR creation per `docs/project/autonomous-automation-config.md`.

### 14.2 Scored dimensions

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Clarity | 5 | Scope, architectural decisions, diagram, component table, and phased rollout are explicit |
| Completeness | 5 | Covers connectors, stores, events, APIs, security, monitoring, risks, and phasing |
| Implementation Readiness | 5 | Downstream implementation planning can derive workstreams, contracts, and operational controls without re-deriving core decisions |
| Consistency With Standards | 5 | Uses domain-model IDs, data-standards events, API-standards auth expectations, and integration retry rules |
| Correctness Of Dependencies | 5 | Upstream and downstream traceability is explicit; F1 to F5/F6/F9/F11 handoff is defined |
| Automation Safety | 5 | Trigger is stated, assumptions are explicit, and unresolved items are tracked as non-blocking notes rather than stop conditions |

**Average:** 5.0  
**Confidence:** HIGH

### 14.3 Follow-ups for implementation planning

- Confirm final field-level ownership for pricing and publish status.
- Choose concrete storage and messaging technology without changing the canonical contracts described here.
- Break replay tooling, connector work, and downstream consumer adoption into implementation-plan items.
