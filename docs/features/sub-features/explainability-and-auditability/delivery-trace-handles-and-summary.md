# Delivery Trace Handles and Summary

## Parent Feature

- **Feature:** [Explainability and Auditability](../../explainability-and-auditability.md)
- **Feature slug:** `explainability-and-auditability`
- **Sub-feature slug:** `delivery-trace-handles-and-summary`
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

Expose delivery-safe trace handles and compact summaries so downstream systems can correlate recommendation behavior without receiving internal-only reasoning.

## 2. Core Concept

Delivery Trace Handles and Summary is the capability slice of **Explainability and Auditability** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need delivery trace handles and summary behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for delivery trace handles and summary so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when explainability and auditability affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A delivery response is prepared
- A downstream client requests correlation identifiers
- Trace redaction policy changes

## 5. Inputs

- Full recommendation trace
- Delivery channel identity
- Trace redaction rules

## 6. Outputs

- Delivery-safe trace handle
- Compact trace summary
- Channel-specific redaction result

## 7. Workflow / Lifecycle

1. Load the full internal trace for a recommendation set.
2. Apply channel-specific redaction rules and select the delivery-safe summary fields.
3. Attach the safe summary to the delivery response or side channel.

## 8. Business Rules

- Delivery-safe summaries must never include restricted customer reasoning fields.
- Trace handles must remain joinable to full internal traces.
- Channel summaries must be explicit about whether details are omitted.

## 9. Configuration Model

- Delivery Trace Handles and Summary policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `delivery_trace_handles_and_summary` primary record storing the current delivery trace handles and summary state.
- `delivery_trace_handles_and_summary_history` append-only history for lifecycle and trace reconstruction.
- `delivery_trace_handles_and_summary_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/traces/{traceId}/summary
- POST /internal/traces/{traceId}/redact

## 12. Events Produced

- RecommendationTraceSummaryPrepared
- RecommendationTraceSummaryRedacted

## 13. Events Consumed

- RecommendationTraceRecorded
- DeliveryAccessEvaluated

## 14. Integrations

- Delivery API
- Channel adapters
- Security and redaction policy service

## 15. UI Components

- Trace handle chip
- Summary depth badge

## 16. UI Screens

- Delivery trace summary preview
- Redaction policy comparison page

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

- Metrics: request count, success rate, degraded rate, and freshness for delivery trace handles and summary.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/traces/{traceId}/summary` with `Full recommendation trace` and return `Delivery-safe trace handle` plus traceable metadata.
2. Event flow: consume `RecommendationTraceRecorded` and emit `RecommendationTraceSummaryPrepared` after business rules and lifecycle checks pass.
3. Operator flow: use `Delivery trace summary preview` to inspect or change delivery trace handles and summary behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `explainability-and-auditability-service`, `explainability-and-auditability-api`, and `delivery-trace-handles-and-summary-worker` for async processing.
- Database tables or collections required: `delivery_trace_handles_and_summary`, `delivery_trace_handles_and_summary_history`, and `delivery_trace_handles_and_summary_projection`.
- Jobs or workers required: `delivery-trace-handles-and-summary-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Channel adapters, Security and redaction policy service.
- Frontend components required: Trace handle chip, Summary depth badge.
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

- What minimum trace summary belongs in external integrator payloads at launch?
- Should some channels receive only IDs while others receive compact summaries?
