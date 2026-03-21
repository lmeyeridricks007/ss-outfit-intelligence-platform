# Inventory Eligibility Projection

## Parent Feature

- **Feature:** [Catalog and Eligibility Foundation](../../catalog-and-eligibility-foundation.md)
- **Feature slug:** `catalog-and-eligibility-foundation`
- **Sub-feature slug:** `inventory-eligibility-projection`
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

Combine inventory, assortment, and market policy into a recommendation-ready eligibility projection with explicit reason codes.

## 2. Core Concept

Inventory Eligibility Projection is the capability slice of **Catalog and Eligibility Foundation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need inventory eligibility projection behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for inventory eligibility projection so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when catalog and eligibility foundation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- Inventory or assortment changes arrive from upstream systems
- Market-level eligibility rules are updated
- A recommendation request needs a low-latency eligibility lookup

## 5. Inputs

- Inventory availability updates
- Regional assortment assignments
- Eligibility policy definitions

## 6. Outputs

- Eligibility projection per market and channel
- Reason codes for hard exclusions and degradations
- Eligibility freshness timestamp

## 7. Workflow / Lifecycle

1. Ingest inventory and assortment changes into a normalized projection stream.
2. Apply market, channel, and policy constraints to each candidate product.
3. Expose a low-latency read model to candidate generation and delivery services.

## 8. Business Rules

- Hard exclusions take precedence over ranking or merchandising boosts.
- Stale eligibility must be visible via freshness metadata.
- Customer-facing payloads must not expose internal quarantine reasons verbatim.

## 9. Configuration Model

- Inventory Eligibility Projection policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `inventory_eligibility_projection` primary record storing the current inventory eligibility projection state.
- `inventory_eligibility_projection_history` append-only history for lifecycle and trace reconstruction.
- `inventory_eligibility_projection_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/eligibility/products/{canonicalProductId}
- POST /internal/eligibility/batch-resolve

## 12. Events Produced

- CatalogEligibilityProjected
- EligibilityFreshnessDegraded

## 13. Events Consumed

- InventoryUpdated
- AssortmentPolicyChanged

## 14. Integrations

- OMS or inventory service
- Commerce market configuration
- Recommendation orchestration

## 15. UI Components

- Eligibility reason badge
- Market availability matrix

## 16. UI Screens

- Eligibility diagnostics view
- Market coverage report

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

- Metrics: request count, success rate, degraded rate, and freshness for inventory eligibility projection.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/eligibility/products/{canonicalProductId}` with `Inventory availability updates` and return `Eligibility projection per market and channel` plus traceable metadata.
2. Event flow: consume `InventoryUpdated` and emit `CatalogEligibilityProjected` after business rules and lifecycle checks pass.
3. Operator flow: use `Eligibility diagnostics view` to inspect or change inventory eligibility projection behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `catalog-and-eligibility-foundation-service`, `catalog-and-eligibility-foundation-api`, and `inventory-eligibility-projection-worker` for async processing.
- Database tables or collections required: `inventory_eligibility_projection`, `inventory_eligibility_projection_history`, and `inventory_eligibility_projection_projection`.
- Jobs or workers required: `inventory-eligibility-projection-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: OMS or inventory service, Commerce market configuration, Recommendation orchestration.
- Frontend components required: Eligibility reason badge, Market availability matrix.
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

- When should uncertain inventory downrank instead of hard-exclude an item?
- What is the acceptable eligibility freshness threshold for each surface?
