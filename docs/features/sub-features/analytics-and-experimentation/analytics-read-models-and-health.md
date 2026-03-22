# Sub-feature capability: Analytics Read Models And Health

**Parent feature:** `Analytics and experimentation`  
**Parent feature file:** `docs/features/analytics-and-experimentation.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/analytics-and-experimentation/`  
**Upstream traceability:** `docs/features/analytics-and-experimentation.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-010, BR-003, BR-002, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-006`, `DEC-007`)  
**Tracked open decisions:** `DEC-006`, `DEC-007`

---

## 1. Purpose

Provide query-ready analytics projections and telemetry health views for recommendation performance so operators can safely trust dashboards, detect measurement regressions early, and take action before product decisions are made from corrupted data.

This capability is the boundary between raw event streams and operational analytics consumption. It owns projection correctness, freshness, and health semantics for read-time consumers.

## 2. Core Concept

`Analytics Read Models And Health` continuously transforms validated recommendation telemetry into curated read models:

- funnel and conversion projections
- experiment scorecards
- governance-aware performance slices
- pipeline quality and freshness health indicators

Read models are optimized for low-latency reads and consistent metric definitions. Health views are first-class outputs, not side dashboards. If data quality degrades, this capability must surface the degradation with reason codes and confidence impact.

## 3. User Problems Solved

- Product and analytics teams need stable metric definitions across surfaces, not ad hoc SQL per dashboard.
- Experiment owners need trusted scorecards that remain valid when events arrive late.
- Operations teams need fast visibility into ingestion lag, schema drift, duplicate rates, and attribution-confidence drops.
- Governance users need to separate model changes from campaign and override effects in the same view.
- Engineering needs a replay-safe projection layer to recover from schema or pipeline incidents without rewriting downstream dashboards.

## 4. Trigger Conditions

- A validated recommendation telemetry event is accepted.
- A new attribution link or adjustment arrives.
- A new experiment assignment or governance annotation arrives.
- A projection schedule window closes (for incremental recompute).
- A schema version changes or schema drift is detected.
- An operator starts a backfill or replay run.

## 5. Inputs

- `analytics.event.validated` stream (canonical recommendation events)
- attribution records (`analytics.attribution.created`, adjusted outcomes)
- experiment assignment context and holdout metadata
- governance annotations (campaigns, overrides, suppressions)
- schema registry and policy versions
- projection and alert configuration (freshness SLO, completeness thresholds)

## 6. Outputs

- read-model snapshots for funnel, experiment, governance, and channel comparison views
- health snapshots (freshness lag, schema reject rate, duplicate rate, missing-ID rate)
- incident and alert records with severity and reason codes
- backfill run status and replay checkpoints
- metric-definition version lineage for auditability

## 7. Workflow / Lifecycle

1. **Consume:** Pull validated events and enrichment side-streams by checkpoint.
2. **Normalize:** Enforce canonical dimensions (`surface`, `placement`, `recommendationType`, `sourceMix`, `market`, `variantId`).
3. **Project:** Update incremental read-model tables/documents by time bucket and dimension set.
4. **Assess health:** Compute quality and freshness SLIs for the same window.
5. **Publish:** Expose projection versions via query endpoints and internal dashboard contracts.
6. **Alert:** Emit degraded-state events when thresholds are breached.
7. **Recover:** Support replay/backfill with idempotent checkpointing and compare pre/post deltas.

Lifecycle states for each projection shard:
`pending -> computing -> published -> stale -> recovering -> published`

## 8. Business Rules

- Core event semantics are inherited and cannot be redefined here: impression, click, save, add-to-cart, purchase, dismiss, override.
- Read models must preserve `traceId` and `recommendationSetId` lineage at least to drilldown-compatible granularity.
- If critical fields are missing (`eventType`, `eventTs`, `recommendationSetId`, `surface`), records are excluded from aggregates and counted in health debt; silent null-filling is not allowed.
- Duplicate protection must be deterministic (`eventId` + producer/source semantics) and replay-safe.
- Late-arriving records must update projections according to watermark policy; previously published windows must support correction.
- Governance annotations and experiment dimensions must remain simultaneously queryable; neither can overwrite the other.
- Health degradation must be visible to consumers before or with impacted metrics.
- Open decisions stay unresolved in this spec and must be honored in implementation: `DEC-006` (server fallback policy detail), `DEC-007` (attribution window and experiment stickiness policy).

## 9. Configuration Model

Required configuration domains:

- `projection.enabled` (per environment)
- `projection.policyVersion`
- `projection.windowing` (5m, 1h, daily rollups)
- `projection.dimensionsAllowlist` (channel/surface/type/source mix/market/variant)
- `health.freshnessSLO` by surface/channel
- `health.thresholds` for schema reject rate, duplicate rate, missing-ID rate, lag, fallback share
- `replay.maxConcurrency` and `replay.maxLookbackDays`
- `retention.raw`, `retention.normalized`, `retention.projections`
- `security.dimensionAccessPolicy` for market/channel scoping

All config must be versioned and attached to produced snapshots so historical charts are interpretable.

## 10. Data Model

Primary entities:

- **`ProjectionSnapshot`**  
  `snapshotId`, `projectionType`, `windowStart`, `windowEnd`, `dimensions`, `metricValues`, `policyVersion`, `schemaVersion`, `publishedAt`
- **`ProjectionCheckpoint`**  
  `checkpointId`, `streamName`, `offsetOrCursor`, `watermarkTs`, `updatedAt`
- **`TelemetryHealthSnapshot`**  
  `healthSnapshotId`, `windowStart`, `windowEnd`, `freshnessLagSec`, `schemaRejectRate`, `duplicateRate`, `missingIdRate`, `fallbackShare`, `status`
- **`DataQualityIncident`**  
  `incidentId`, `severity`, `detectedAt`, `dimensionScope`, `reasonCode`, `threshold`, `observedValue`, `status`, `owner`
- **`BackfillRun`**  
  `runId`, `requestedBy`, `startedAt`, `completedAt`, `rangeStart`, `rangeEnd`, `state`, `deltaSummary`

Recommended shared fields:

- canonical IDs and source references
- `createdAt` and `updatedAt`
- `policyVersion` and `schemaVersion`
- reason codes and confidence impact fields

## 11. API Endpoints

Illustrative contract surfaces:

- `GET /analytics/read-models/funnel?surface=&recommendationType=&window=`
- `GET /analytics/read-models/experiments/{experimentId}/scorecard`
- `GET /analytics/read-models/governance-impact?campaignId=&window=`
- `GET /analytics/health/telemetry?surface=&window=`
- `POST /analytics/read-models/backfills`
- `GET /analytics/read-models/backfills/{runId}`

Transport and exact schemas are architecture-stage details, but metric semantics and health fields above are mandatory.

## 12. Events Produced

- `analytics.read-model.snapshot.updated`
- `analytics.read-model.health.degraded`
- `analytics.read-model.schema-drift.detected`
- `analytics.read-model.backfill.completed`
- `analytics.read-model.backfill.failed`

## 13. Events Consumed

- `analytics.event.validated`
- `analytics.attribution.created`
- `analytics.attribution.adjusted`
- `experiment.assignment.created`
- `analytics.governance.annotation.recorded`
- `analytics.event.rejected`

## 14. Integrations

- canonical recommendation events capability (input stream contract)
- outcome attribution and confidence capability (attributed outcome stream)
- experiment assignment and delivery contracts capability (variant dimensions)
- governance annotations for analysis capability (operator-change dimensions)
- impression policy and server fallback capability (fallback-share health dimension)
- shared contracts and delivery API (trace/recommendation identifiers)
- warehouse/semantic layer and internal BI consumers

## 15. UI Components

- **Projection freshness badge** (per dashboard tile)
- **Telemetry health sparkline cards** (lag, rejects, duplicates, fallback share)
- **Data quality incident table** with reason-code filters
- **Experiment scorecard module** with confidence and sample-size indicators
- **Governance impact filter bar** (campaign, override, suppression toggles)
- **Backfill run status panel** (state, progress, delta summary)

## 16. UI Screens

- **Analytics overview** (funnel + freshness + quality summary)
- **Experiment scorecard detail** (variant comparison with health context)
- **Data quality and incidents console** (threshold breaches and resolution workflow)
- **Backfill/replay operations view** (run submission and run history)

## 17. Permissions & Security

- Read access is role-based (`viewer`, `analyst`, `operator`, `admin`) with market/channel scoping.
- Raw drilldown identifiers are more restricted than aggregate metrics.
- Backfill/replay endpoints require elevated operator/admin role and audit logging.
- PII-bearing dimensions must be masked or blocked by region and consent policy.
- Every projection publication, incident state change, and backfill action must be auditable.

## 18. Error Handling

- Schema mismatch or missing critical fields route records to quarantine and increment health debt counters.
- Projection failures for one shard must not block unrelated shards; partial failure states are explicit.
- Query endpoints return freshness metadata and degraded status when data is stale.
- Backfill failure emits terminal reason code and preserves last successful checkpoint.
- Idempotent retry is required for projector workers and backfill workers.

## 19. Edge Cases

- Late purchases arrive outside primary window but inside policy lookback.
- A schema update introduces a new dimension while dashboards still query old versions.
- Duplicate event bursts caused by client retries temporarily inflate volume.
- Experiment or campaign toggles change mid-window.
- Identity transitions from anonymous to known alter attribution confidence distribution.
- Replay overlaps with live ingestion and must avoid double counting.

## 20. Performance Considerations

- Projection updates should be incremental and partition-aware rather than full recompute.
- Primary read-model queries should be low latency for operational usage (target p95 under 2 seconds for default filters).
- Freshness lag for P1 ecommerce surfaces should remain within configured SLO (initial target under 15 minutes).
- Backfill jobs must be throttled to avoid starving live projector workers.
- Cache invalidation must be tied to snapshot version publication, not wall-clock assumptions.

## 21. Observability

Required SLIs:

- projection freshness lag
- schema reject rate
- duplicate rate
- missing critical-ID rate
- fallback-share rate
- backfill success rate

Required telemetry:

- structured logs with `traceId`, `recommendationSetId`, `snapshotId`, `runId`
- per-shard checkpoint and watermark metrics
- incident lifecycle events (`opened`, `acknowledged`, `resolved`)
- query-side freshness and degradation headers for client visibility

Alerting must distinguish warning vs critical and include suggested runbook link or action owner.

## 22. Example Scenarios

### Scenario A: Healthy incremental projection

1. Validated impression/click/add-to-cart/purchase events arrive for PDP.
2. Projector updates funnel and experiment snapshots for current 5-minute window.
3. Health snapshot records lag within SLO and low reject/duplicate rates.
4. Dashboard tiles refresh with `publishedAt` and `policyVersion`.

### Scenario B: Schema drift incident

1. Producer ships events with an unexpected field enum for `recommendationType`.
2. Reject rate exceeds threshold for one market/surface shard.
3. `analytics.read-model.health.degraded` is emitted with reason code `SCHEMA_DRIFT`.
4. Incident is opened; dashboards show degraded-state banner and affected slice.

### Illustrative payload

```json
{
  "eventType": "analytics.read-model.health.degraded",
  "healthSnapshotId": "hlth_01JQ9X8M8M4S1S9T6E2D3A4B5C",
  "windowStart": "2026-03-22T14:00:00Z",
  "windowEnd": "2026-03-22T14:05:00Z",
  "surface": "pdp",
  "market": "us",
  "status": "critical",
  "reasonCode": "SCHEMA_DRIFT",
  "schemaRejectRate": 0.083,
  "freshnessLagSec": 910,
  "policyVersion": "rmh.v1.2"
}
```

## 23. Implementation Notes

- **Backend services:** implement a dedicated projector service boundary in the analytics domain for read models and health.
- **Storage:** separate raw/normalized event stores from projection stores; projection stores should be partitioned by time and high-cardinality dimensions.
- **Workers/jobs:** incremental projector workers, health calculator workers, and replay/backfill workers with checkpoint persistence.
- **Contracts:** consume only canonical upstream contracts; do not invent local event semantics.
- **Frontend/shared UI:** expose health and freshness context beside metrics in all operator-facing analytics views.
- **Traceability:** maintain lineage links from snapshots to checkpoints and source windows.

Implementation implications by subsystem:

- database tables/documents for `ProjectionSnapshot`, `ProjectionCheckpoint`, `TelemetryHealthSnapshot`, `DataQualityIncident`, `BackfillRun`
- stream consumers for validated events, attribution, experiments, and governance annotations
- scheduled jobs for window close/publish and anomaly detection
- runbook-oriented incident hooks (alert routing integrations)

## 24. Testing Requirements

- unit tests for windowing, dedupe, checkpoint advancement, and shard isolation
- contract tests for read-model query payloads and health endpoints
- integration tests across consumed streams (events, attribution, experiments, governance)
- replay/backfill correctness tests (pre/post delta checks, idempotency, overlap with live ingestion)
- freshness and degradation behavior tests (stale headers, degraded banners, alert emissions)
- data-quality tests for schema drift, missing IDs, duplicate bursts, and late-arriving outcomes
- permissions tests for aggregate vs restricted drilldown access
