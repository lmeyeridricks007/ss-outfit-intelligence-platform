# Trace and Decision Metadata

## Parent Feature

- **Feature:** [Recommendation Orchestration and Types](../../recommendation-orchestration-and-types.md)
- **Feature slug:** `recommendation-orchestration-and-types`
- **Sub-feature slug:** `trace-and-decision-metadata`
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

Attach durable recommendation set identifiers and decision metadata so outputs remain measurable, auditable, and explainable.

## 2. Core Concept

Trace and Decision Metadata is the capability slice of **Recommendation Orchestration and Types** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need trace and decision metadata behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for trace and decision metadata so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when recommendation orchestration and types affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation set is assembled or degraded
- A response is handed to delivery adapters
- Analytics or operator tooling needs decision lineage

## 5. Inputs

- Recommendation assembly results
- Provider and governance metadata
- Experiment and request context

## 6. Outputs

- Recommendation set ID
- Trace ID and decision metadata bundle
- Delivery-safe metadata subset

## 7. Workflow / Lifecycle

1. Generate or attach durable IDs during recommendation assembly.
2. Aggregate governance, provider, experiment, and degradation metadata.
3. Persist a full metadata record while exposing delivery-safe subsets to clients.

## 8. Business Rules

- Trace and set IDs must remain stable across downstream events.
- Delivery-safe metadata cannot leak internal-only reasoning details.
- Metadata completeness must be measurable and alertable.

## 9. Configuration Model

- Trace and Decision Metadata policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `trace_and_decision_metadata` primary record storing the current trace and decision metadata state.
- `trace_and_decision_metadata_history` append-only history for lifecycle and trace reconstruction.
- `trace_and_decision_metadata_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/recommendations/traces/{traceId}
- POST /internal/recommendations/metadata/validate

## 12. Events Produced

- RecommendationDecisionMetadataRecorded
- RecommendationTraceRedactionApplied

## 13. Events Consumed

- RecommendationSetAssembled
- ExperimentAssignmentEvaluated

## 14. Integrations

- Delivery API
- Analytics and experimentation
- Explainability trace service

## 15. UI Components

- Trace ID copy control
- Decision metadata summary card

## 16. UI Screens

- Recommendation trace lookup
- Metadata completeness report

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

- Metrics: request count, success rate, degraded rate, and freshness for trace and decision metadata.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/recommendations/traces/{traceId}` with `Recommendation assembly results` and return `Recommendation set ID` plus traceable metadata.
2. Event flow: consume `RecommendationSetAssembled` and emit `RecommendationDecisionMetadataRecorded` after business rules and lifecycle checks pass.
3. Operator flow: use `Recommendation trace lookup` to inspect or change trace and decision metadata behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `recommendation-orchestration-and-types-service`, `recommendation-orchestration-and-types-api`, and `trace-and-decision-metadata-worker` for async processing.
- Database tables or collections required: `trace_and_decision_metadata`, `trace_and_decision_metadata_history`, and `trace_and_decision_metadata_projection`.
- Jobs or workers required: `trace-and-decision-metadata-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Analytics and experimentation, Explainability trace service.
- Frontend components required: Trace ID copy control, Decision metadata summary card.
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

- What minimum metadata subset should external clients receive in Phase 1?
- How should trace completeness degrade when one upstream provider times out?
