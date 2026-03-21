# Curated Look Authoring

## Parent Feature

- **Feature:** [Look Graph and Compatibility](../../look-graph-and-compatibility.md)
- **Feature slug:** `look-graph-and-compatibility`
- **Sub-feature slug:** `curated-look-authoring`
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

Author complete-look definitions with stable IDs, slots, alternates, and lifecycle control for downstream recommendation assembly.

## 2. Core Concept

Curated Look Authoring is the capability slice of **Look Graph and Compatibility** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need curated look authoring behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for curated look authoring so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when look graph and compatibility affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A merchandiser creates or updates a look
- A look is submitted for review or publication
- A downstream consumer requests active look definitions

## 5. Inputs

- Canonical product IDs
- Look metadata and slot assignments
- Lifecycle and approval settings

## 6. Outputs

- Versioned look definition
- Publication-ready slot structure
- Look audit history

## 7. Workflow / Lifecycle

1. Create or update a draft look with products, slots, and alternates.
2. Validate the draft against catalog, compatibility, and governance rules.
3. Publish the approved version for graph and orchestration consumption.

## 8. Business Rules

- Every look requires a stable look ID and version history.
- Published looks cannot reference ineligible or unresolved products.
- Slot semantics must distinguish required, optional, and alternate members.

## 9. Configuration Model

- Curated Look Authoring policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `curated_look_authoring` primary record storing the current curated look authoring state.
- `curated_look_authoring_history` append-only history for lifecycle and trace reconstruction.
- `curated_look_authoring_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/looks
- GET /internal/looks/{lookId}

## 12. Events Produced

- LookDraftSaved
- LookPublished

## 13. Events Consumed

- CatalogReadModelUpdated
- GovernanceObjectPublished

## 14. Integrations

- Merchandising governance
- Catalog read model
- Graph lifecycle jobs

## 15. UI Components

- Look builder canvas
- Slot and alternate editor

## 16. UI Screens

- Look authoring workspace
- Look publication review

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

- Metrics: request count, success rate, degraded rate, and freshness for curated look authoring.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/looks` with `Canonical product IDs` and return `Versioned look definition` plus traceable metadata.
2. Event flow: consume `CatalogReadModelUpdated` and emit `LookDraftSaved` after business rules and lifecycle checks pass.
3. Operator flow: use `Look authoring workspace` to inspect or change curated look authoring behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `look-graph-and-compatibility-service`, `look-graph-and-compatibility-api`, and `curated-look-authoring-worker` for async processing.
- Database tables or collections required: `curated_look_authoring`, `curated_look_authoring_history`, and `curated_look_authoring_projection`.
- Jobs or workers required: `curated-look-authoring-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Merchandising governance, Catalog read model, Graph lifecycle jobs.
- Frontend components required: Look builder canvas, Slot and alternate editor.
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

- How much of look authoring must exist in UI versus API-first workflows at launch?
- Which asset and copy fields belong directly on the look object versus CMS?
