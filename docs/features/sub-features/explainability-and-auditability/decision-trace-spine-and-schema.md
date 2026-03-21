# Decision Trace Spine and Schema

## Parent Feature

- **Feature:** [Explainability and Auditability](../../explainability-and-auditability.md)
- **Feature slug:** `explainability-and-auditability`
- **Sub-feature slug:** `decision-trace-spine-and-schema`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/explainability-and-auditability.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/br/br-009-merchandising-governance.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-010-analytics-and-experimentation.md`
- `docs/project/architecture-overview.md`
- `docs/project/goals.md`
- `docs/project/standards.md`
- `docs/project/data-standards.md`

## 1. Purpose

Define the canonical recommendation trace schema that captures request context, candidate flow, governance, experimentation, and degradation details.

## 2. Core Concept

Decision Trace Spine and Schema is the capability slice of **Explainability and Auditability** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need decision trace spine and schema behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for decision trace spine and schema so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when explainability and auditability affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation decision is made
- A trace schema evolves
- A downstream service validates trace completeness

## 5. Inputs

- Recommendation decision metadata
- Trace schema definitions
- Trace completeness policies

## 6. Outputs

- RecommendationTrace record
- Schema validation result
- Trace completeness metadata

## 7. Workflow / Lifecycle

1. Assemble trace data across request intake, orchestration, and delivery.
2. Validate the trace against the canonical schema.
3. Persist the trace spine for lookup, analytics joins, and audits.

## 8. Business Rules

- Trace IDs and schema versions must be durable and explicit.
- The trace spine must differentiate facts, decisions, and degraded assumptions.
- Trace completeness must be measurable and queryable.

## 9. Configuration Model

- Decision Trace Spine and Schema policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `decision_trace_spine_and_schema` primary record storing the current decision trace spine and schema state.
- `decision_trace_spine_and_schema_history` append-only history for lifecycle and trace reconstruction.
- `decision_trace_spine_and_schema_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/traces/schema
- POST /internal/traces/validate

## 12. Events Produced

- RecommendationTraceRecorded
- RecommendationTraceValidationFailed

## 13. Events Consumed

- RecommendationDecisionMetadataRecorded
- GovernanceAuditRecorded

## 14. Integrations

- Recommendation orchestration
- Analytics and experimentation
- Audit storage

## 15. UI Components

- Trace schema browser
- Completeness badge

## 16. UI Screens

- Trace schema reference
- Trace validation explorer

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

- Metrics: request count, success rate, degraded rate, and freshness for decision trace spine and schema.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/traces/schema` with `Recommendation decision metadata` and return `RecommendationTrace record` plus traceable metadata.
2. Event flow: consume `RecommendationDecisionMetadataRecorded` and emit `RecommendationTraceRecorded` after business rules and lifecycle checks pass.
3. Operator flow: use `Trace schema reference` to inspect or change decision trace spine and schema behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `explainability-and-auditability-service`, `explainability-and-auditability-api`, and `decision-trace-spine-and-schema-worker` for async processing.
- Database tables or collections required: `decision_trace_spine_and_schema`, `decision_trace_spine_and_schema_history`, and `decision_trace_spine_and_schema_projection`.
- Jobs or workers required: `decision-trace-spine-and-schema-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Analytics and experimentation, Audit storage.
- Frontend components required: Trace schema browser, Completeness badge.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/explainability-and-auditability.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which trace fields are mandatory in the first operator experience?
- What completeness threshold marks a trace as degraded or partial?
