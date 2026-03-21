# Catalog Ingestion Lifecycle

## Parent Feature

- **Feature:** [Catalog and Eligibility Foundation](../../catalog-and-eligibility-foundation.md)
- **Feature slug:** `catalog-and-eligibility-foundation`
- **Sub-feature slug:** `catalog-ingestion-lifecycle`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/catalog-and-eligibility-foundation.md`
- `docs/project/business-requirements.md`
- `docs/project/architecture-overview.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `docs/project/data-standards.md`
- `docs/project/standards.md`

## 1. Purpose

Move source product data through raw, normalized, validated, and recommendation-ready lifecycle states with explicit quarantine handling.

## 2. Core Concept

Catalog Ingestion Lifecycle is the capability slice of **Catalog and Eligibility Foundation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need catalog ingestion lifecycle behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for catalog ingestion lifecycle so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when catalog and eligibility foundation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A batch or streaming catalog import starts
- A record fails validation or mapping
- An operator requests replay or reprocessing

## 5. Inputs

- Raw source records
- Normalization rules
- Replay and recovery commands

## 6. Outputs

- Lifecycle state transitions
- Quarantined record queue
- Recommendation-ready catalog snapshot

## 7. Workflow / Lifecycle

1. Persist raw source payloads for replay and provenance.
2. Normalize, validate, and enrich records through deterministic stages.
3. Route failures to quarantine while promoting valid records to recommendation-ready state.

## 8. Business Rules

- Each lifecycle transition must be auditable and idempotent.
- Quarantined records cannot leak into recommendation-serving paths.
- Replay must preserve the original source timestamp and provenance context.

## 9. Configuration Model

- Catalog Ingestion Lifecycle policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `catalog_ingestion_lifecycle` primary record storing the current catalog ingestion lifecycle state.
- `catalog_ingestion_lifecycle_history` append-only history for lifecycle and trace reconstruction.
- `catalog_ingestion_lifecycle_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/catalog/ingestion/replay
- GET /internal/catalog/ingestion/runs/{runId}

## 12. Events Produced

- CatalogIngestionRunCompleted
- CatalogRecordQuarantined

## 13. Events Consumed

- SourceCatalogImportStarted
- CatalogReplayRequested

## 14. Integrations

- ETL or ingestion scheduler
- Operator alerting
- Catalog quality monitoring

## 15. UI Components

- Ingestion run timeline
- Quarantine queue table

## 16. UI Screens

- Catalog ingestion operations
- Replay request modal

## 17. Permissions & Security

- Operators need role-based access that separates view, edit, publish, and export actions.
- Support and business users should receive redacted detail where internal-only rationale exists.
- Service-to-service access must use least-privilege credentials and auditable scopes.

## 18. Error Handling

- Validation failures must return stable error codes and preserve operator-visible reason details.
- Upstream integration outages should trigger explicit degraded behavior instead of silent partial success.
- Idempotent retries are required for replayable writes, event publication, and recovery workflows.
- All operator-facing errors should include remediation guidance or the next safe action.

## 19. Edge Cases

- Duplicate events, retries, or replayed inputs for the same logical action.
- Partial data availability where a request can degrade safely but not fail completely.
- Cross-market, cross-channel, or mode-specific differences that alter policy and output shape.
- Stale projections or caches that disagree with the current source-of-truth state.

## 20. Performance Considerations

- Serving-path reads should use read models or caches rather than reconstructing state from raw history.
- Background rebuilds, imports, or audits should support batching and bounded retry behavior.
- Latency budgets must be explicit where the sub-feature is on the synchronous recommendation path.
- The design should allow market or channel partitioning as data volume grows.

## 21. Observability

- Metrics: request count, success rate, degraded rate, and freshness for catalog ingestion lifecycle.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/catalog/ingestion/replay` with `Raw source records` and return `Lifecycle state transitions` plus traceable metadata.
2. Event flow: consume `SourceCatalogImportStarted` and emit `CatalogIngestionRunCompleted` after business rules and lifecycle checks pass.
3. Operator flow: use `Catalog ingestion operations` to inspect or change catalog ingestion lifecycle behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `catalog-and-eligibility-foundation-service`, `catalog-and-eligibility-foundation-api`, and `catalog-ingestion-lifecycle-worker` for async processing.
- Database tables or collections required: `catalog_ingestion_lifecycle`, `catalog_ingestion_lifecycle_history`, and `catalog_ingestion_lifecycle_projection`.
- Jobs or workers required: `catalog-ingestion-lifecycle-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: ETL or ingestion scheduler, Operator alerting, Catalog quality monitoring.
- Frontend components required: Ingestion run timeline, Quarantine queue table.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/catalog-and-eligibility-foundation.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- How long should raw payloads be retained for replay versus compliance purposes?
- Which ingestion failures are auto-retriable versus operator-controlled?
