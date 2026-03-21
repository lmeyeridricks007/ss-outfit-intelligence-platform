# CM Invalidation and Traces

## Parent Feature

- **Feature:** [RTW and CM Mode Orchestration](../../rtw-and-cm-mode-orchestration.md)
- **Feature slug:** `rtw-and-cm-mode-orchestration`
- **Sub-feature slug:** `cm-invalidation-and-traces`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/rtw-and-cm-mode-orchestration.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/personas.md`
- `docs/project/roadmap.md`

## 1. Purpose

Invalidate CM recommendation context when customer configuration changes and record mode-specific trace fields for audit and debugging.

## 2. Core Concept

CM Invalidation and Traces is the capability slice of **RTW and CM Mode Orchestration** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need cm invalidation and traces behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for cm invalidation and traces so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when rtw and cm mode orchestration affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A configuration snapshot changes
- A CM recommendation cache entry expires
- An operator investigates CM recommendation behavior

## 5. Inputs

- Configuration snapshot lifecycle events
- Recommendation trace metadata
- Cache invalidation policies

## 6. Outputs

- CM cache invalidation signal
- Mode-specific trace fields
- Configuration-to-recommendation lineage

## 7. Workflow / Lifecycle

1. Monitor configuration and mode lifecycle events relevant to active recommendation state.
2. Invalidate stale CM recommendation caches or projections.
3. Persist mode-specific trace context that links outcomes back to configuration state.

## 8. Business Rules

- Configuration changes must invalidate stale CM recommendation context before reuse.
- Trace records need snapshot and mode lineage even when recommendations fail.
- Invalidation must be scoped narrowly enough to avoid unnecessary churn.

## 9. Configuration Model

- CM Invalidation and Traces policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `cm_invalidation_and_traces` primary record storing the current cm invalidation and traces state.
- `cm_invalidation_and_traces_history` append-only history for lifecycle and trace reconstruction.
- `cm_invalidation_and_traces_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/cm/invalidation
- GET /internal/cm/traces/{traceId}

## 12. Events Produced

- CmRecommendationInvalidated
- CmTraceRecorded

## 13. Events Consumed

- ConfigurationSnapshotValidated
- RecommendationDecisionMetadataRecorded

## 14. Integrations

- Recommendation orchestration cache
- Explainability trace service
- Observability stack

## 15. UI Components

- Invalidation history table
- CM trace lineage viewer

## 16. UI Screens

- CM cache diagnostics
- CM trace detail page

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

- Metrics: request count, success rate, degraded rate, and freshness for cm invalidation and traces.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/cm/invalidation` with `Configuration snapshot lifecycle events` and return `CM cache invalidation signal` plus traceable metadata.
2. Event flow: consume `ConfigurationSnapshotValidated` and emit `CmRecommendationInvalidated` after business rules and lifecycle checks pass.
3. Operator flow: use `CM cache diagnostics` to inspect or change cm invalidation and traces behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `rtw-and-cm-mode-orchestration-service`, `rtw-and-cm-mode-orchestration-api`, and `cm-invalidation-and-traces-worker` for async processing.
- Database tables or collections required: `cm_invalidation_and_traces`, `cm_invalidation_and_traces_history`, and `cm_invalidation_and_traces_projection`.
- Jobs or workers required: `cm-invalidation-and-traces-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration cache, Explainability trace service, Observability stack.
- Frontend components required: Invalidation history table, CM trace lineage viewer.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/rtw-and-cm-mode-orchestration.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- What invalidation granularity is acceptable for multi-step CM journeys?
- How much CM-specific trace detail should clienteling users see compared with engineers?
