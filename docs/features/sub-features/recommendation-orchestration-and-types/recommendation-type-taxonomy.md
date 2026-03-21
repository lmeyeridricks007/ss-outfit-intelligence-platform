# Recommendation Type Taxonomy

## Parent Feature

- **Feature:** [Recommendation Orchestration and Types](../../recommendation-orchestration-and-types.md)
- **Feature slug:** `recommendation-orchestration-and-types`
- **Sub-feature slug:** `recommendation-type-taxonomy`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/recommendation-orchestration-and-types.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Maintain the governed taxonomy of recommendation types and overlays so each response has explicit semantic meaning across surfaces and analytics.

## 2. Core Concept

Recommendation Type Taxonomy is the capability slice of **Recommendation Orchestration and Types** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need recommendation type taxonomy behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for recommendation type taxonomy so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when recommendation orchestration and types affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A new recommendation type or overlay is proposed
- A surface requests allowed recommendation types
- Analytics joins need canonical recommendation type codes

## 5. Inputs

- Recommendation type definitions
- Surface and channel requirements
- Analytics and UI taxonomy rules

## 6. Outputs

- Governed recommendation type registry
- Allowed-type list per surface
- Type semantics metadata

## 7. Workflow / Lifecycle

1. Define or update recommendation types and overlay semantics in the taxonomy registry.
2. Validate type usage against surface and analytics needs.
3. Publish a versioned type registry for orchestration and delivery consumers.

## 8. Business Rules

- Each recommendation set must declare a single primary type.
- Overlay semantics such as contextual or personal cannot replace the primary type.
- Type changes require backward compatibility planning for delivery and analytics consumers.

## 9. Configuration Model

- Recommendation Type Taxonomy policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `recommendation_type_taxonomy` primary record storing the current recommendation type taxonomy state.
- `recommendation_type_taxonomy_history` append-only history for lifecycle and trace reconstruction.
- `recommendation_type_taxonomy_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/recommendations/types
- POST /internal/recommendations/types/validate

## 12. Events Produced

- RecommendationTypeRegistryUpdated
- RecommendationTypeValidationFailed

## 13. Events Consumed

- SurfacePolicyPublished
- AnalyticsSchemaUpdated

## 14. Integrations

- Delivery API
- Analytics and experimentation
- Ecommerce surface activation

## 15. UI Components

- Type taxonomy table
- Surface-type matrix

## 16. UI Screens

- Recommendation type admin
- Type compatibility preview

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

- Metrics: request count, success rate, degraded rate, and freshness for recommendation type taxonomy.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/recommendations/types` with `Recommendation type definitions` and return `Governed recommendation type registry` plus traceable metadata.
2. Event flow: consume `SurfacePolicyPublished` and emit `RecommendationTypeRegistryUpdated` after business rules and lifecycle checks pass.
3. Operator flow: use `Recommendation type admin` to inspect or change recommendation type taxonomy behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `recommendation-orchestration-and-types-service`, `recommendation-orchestration-and-types-api`, and `recommendation-type-taxonomy-worker` for async processing.
- Database tables or collections required: `recommendation_type_taxonomy`, `recommendation_type_taxonomy_history`, and `recommendation_type_taxonomy_projection`.
- Jobs or workers required: `recommendation-type-taxonomy-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Analytics and experimentation, Ecommerce surface activation.
- Frontend components required: Type taxonomy table, Surface-type matrix.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/recommendation-orchestration-and-types.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which type combinations must be supported in the first bundled response contract?
- How should new types be versioned for legacy clients?
