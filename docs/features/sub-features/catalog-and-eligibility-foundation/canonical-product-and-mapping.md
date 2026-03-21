# Canonical Product and Mapping

## Parent Feature

- **Feature:** [Catalog and Eligibility Foundation](../../catalog-and-eligibility-foundation.md)
- **Feature slug:** `catalog-and-eligibility-foundation`
- **Sub-feature slug:** `canonical-product-and-mapping`
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

Maintain stable canonical product identifiers and source-system mappings so every downstream recommendation path resolves the same product and variant entities.

## 2. Core Concept

Canonical Product and Mapping is the capability slice of **Catalog and Eligibility Foundation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need canonical product and mapping behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for canonical product and mapping so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when catalog and eligibility foundation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A product or variant is created or updated in a source catalog system
- A reconciliation job detects a new source identifier
- A downstream lookup requests canonical resolution for a source record

## 5. Inputs

- Source catalog product payloads
- Variant and parent-child relationships
- Identifier mapping history

## 6. Outputs

- Canonical product record
- Canonical variant record
- Source-to-canonical mapping index

## 7. Workflow / Lifecycle

1. Receive source product payload and normalize identifier fields.
2. Resolve an existing canonical record or mint a new canonical identifier.
3. Persist mapping history and publish a canonicalized change record for downstream consumers.

## 8. Business Rules

- Canonical identifiers are immutable once issued.
- Mapping collisions must be quarantined instead of silently merged.
- Variant inheritance cannot erase explicitly authored source values without audit evidence.

## 9. Configuration Model

- Canonical Product and Mapping policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `canonical_product_and_mapping` primary record storing the current canonical product and mapping state.
- `canonical_product_and_mapping_history` append-only history for lifecycle and trace reconstruction.
- `canonical_product_and_mapping_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/catalog/products/{canonicalProductId}
- POST /internal/catalog/mappings/resolve

## 12. Events Produced

- CatalogProductCanonicalized
- CatalogMappingConflictDetected

## 13. Events Consumed

- SourceCatalogProductReceived
- CatalogReconciliationRequested

## 14. Integrations

- PIM feed
- Commerce catalog service
- Recommendation read models

## 15. UI Components

- Admin mapping conflict table
- Canonical product detail drawer

## 16. UI Screens

- Catalog operations console
- Product mapping review panel

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

- Metrics: request count, success rate, degraded rate, and freshness for canonical product and mapping.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/catalog/products/{canonicalProductId}` with `Source catalog product payloads` and return `Canonical product record` plus traceable metadata.
2. Event flow: consume `SourceCatalogProductReceived` and emit `CatalogProductCanonicalized` after business rules and lifecycle checks pass.
3. Operator flow: use `Catalog operations console` to inspect or change canonical product and mapping behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `catalog-and-eligibility-foundation-service`, `catalog-and-eligibility-foundation-api`, and `canonical-product-and-mapping-worker` for async processing.
- Database tables or collections required: `canonical_product_and_mapping`, `canonical_product_and_mapping_history`, and `canonical_product_and_mapping_projection`.
- Jobs or workers required: `canonical-product-and-mapping-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: PIM feed, Commerce catalog service, Recommendation read models.
- Frontend components required: Admin mapping conflict table, Canonical product detail drawer.
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

- Which source system mints the first canonical ID in markets with overlapping assortments?
- How much source mapping history must remain queryable for audits?
