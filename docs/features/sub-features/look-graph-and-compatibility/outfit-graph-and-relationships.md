# Outfit Graph and Relationships

## Parent Feature

- **Feature:** [Look Graph and Compatibility](../../look-graph-and-compatibility.md)
- **Feature slug:** `look-graph-and-compatibility`
- **Sub-feature slug:** `outfit-graph-and-relationships`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/look-graph-and-compatibility.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Represent product-to-product, product-to-look, and slot relationship edges for low-latency retrieval of compatible outfit candidates.

## 2. Core Concept

Outfit Graph and Relationships is the capability slice of **Look Graph and Compatibility** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need outfit graph and relationships behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for outfit graph and relationships so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when look graph and compatibility affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A published look changes
- Catalog or compatibility data changes require graph rebuild
- A retrieval request needs graph edges for an anchor item

## 5. Inputs

- Published look definitions
- Canonical products and attributes
- Relationship generation rules

## 6. Outputs

- Graph nodes and edges
- Anchor-to-look relationship projection
- Graph build metadata

## 7. Workflow / Lifecycle

1. Project eligible products and looks into graph nodes.
2. Materialize relationship edges based on look membership and compatibility logic.
3. Publish graph read models optimized for recommendation retrieval.

## 8. Business Rules

- Edges require provenance back to a look, rule, or deterministic generation step.
- Graph rebuilds must be replayable and idempotent.
- Relationship projections cannot outlive the eligibility state that created them.

## 9. Configuration Model

- Outfit Graph and Relationships policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `outfit_graph_and_relationships` primary record storing the current outfit graph and relationships state.
- `outfit_graph_and_relationships_history` append-only history for lifecycle and trace reconstruction.
- `outfit_graph_and_relationships_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/look-graph/anchors/{canonicalProductId}
- POST /internal/look-graph/rebuild

## 12. Events Produced

- LookGraphRebuilt
- LookGraphProjectionUpdated

## 13. Events Consumed

- LookPublished
- CatalogReadModelUpdated

## 14. Integrations

- Catalog read model
- Recommendation orchestration
- Analytics pipeline

## 15. UI Components

- Graph relationship viewer
- Anchor lookup control

## 16. UI Screens

- Look graph explorer
- Graph rebuild operations

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

- Metrics: request count, success rate, degraded rate, and freshness for outfit graph and relationships.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/look-graph/anchors/{canonicalProductId}` with `Published look definitions` and return `Graph nodes and edges` plus traceable metadata.
2. Event flow: consume `LookPublished` and emit `LookGraphRebuilt` after business rules and lifecycle checks pass.
3. Operator flow: use `Look graph explorer` to inspect or change outfit graph and relationships behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `look-graph-and-compatibility-service`, `look-graph-and-compatibility-api`, and `outfit-graph-and-relationships-worker` for async processing.
- Database tables or collections required: `outfit_graph_and_relationships`, `outfit_graph_and_relationships_history`, and `outfit_graph_and_relationships_projection`.
- Jobs or workers required: `outfit-graph-and-relationships-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Catalog read model, Recommendation orchestration, Analytics pipeline.
- Frontend components required: Graph relationship viewer, Anchor lookup control.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/look-graph-and-compatibility.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- What minimum attribute depth is needed before relationship generation can be automated more broadly?
- How should last-known-good graph behavior work during partial rebuild failures?
