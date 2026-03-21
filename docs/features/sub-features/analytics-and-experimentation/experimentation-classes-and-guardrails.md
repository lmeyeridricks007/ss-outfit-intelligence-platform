# Experimentation Classes and Guardrails

## Parent Feature

- **Feature:** [Analytics and Experimentation](../../analytics-and-experimentation.md)
- **Feature slug:** `analytics-and-experimentation`
- **Sub-feature slug:** `experimentation-classes-and-guardrails`
- **Priority inheritance:** P0/P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/analytics-and-experimentation.md`
- `docs/project/br/br-010-analytics-and-experimentation.md`
- `docs/project/br/br-009-merchandising-governance.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/data-standards.md`
- `docs/project/goals.md`
- `docs/project/standards.md`

## 1. Purpose

Run recommendation experiments within guardrails that preserve compatibility, privacy, governance, and brand safety constraints.

## 2. Core Concept

Experimentation Classes and Guardrails is the capability slice of **Analytics and Experimentation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need experimentation classes and guardrails behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for experimentation classes and guardrails so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when analytics and experimentation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A new experiment is configured
- An experiment assignment is evaluated during serving
- Guardrail policies change

## 5. Inputs

- Experiment definitions
- Assignment and bucketing rules
- Guardrail policies and exclusions

## 6. Outputs

- Experiment assignment
- Guardrail-compliant variant plan
- Experiment audit metadata

## 7. Workflow / Lifecycle

1. Create an experiment with explicit hypothesis, scope, and guardrails.
2. Assign requests or users to variants under the approved bucketing policy.
3. Apply guardrails before variant logic can influence serving behavior.

## 8. Business Rules

- Experiments cannot bypass hard compatibility, consent, or governance constraints.
- Experiment scope and metrics must be explicit before launch.
- Assignments need durable experiment and variant identifiers for downstream telemetry.

## 9. Configuration Model

- Experimentation Classes and Guardrails policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `experimentation_classes_and_guardrails` primary record storing the current experimentation classes and guardrails state.
- `experimentation_classes_and_guardrails_history` append-only history for lifecycle and trace reconstruction.
- `experimentation_classes_and_guardrails_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/experiments
- POST /internal/experiments/assign

## 12. Events Produced

- ExperimentAssigned
- ExperimentGuardrailBlocked

## 13. Events Consumed

- RecommendationRequestReceived
- GovernanceSnapshotApplied

## 14. Integrations

- Recommendation orchestration
- Merchandising governance
- Analytics pipeline

## 15. UI Components

- Experiment scope matrix
- Guardrail warning banner

## 16. UI Screens

- Experiment setup wizard
- Guardrail review page

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

- Metrics: request count, success rate, degraded rate, and freshness for experimentation classes and guardrails.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/experiments` with `Experiment definitions` and return `Experiment assignment` plus traceable metadata.
2. Event flow: consume `RecommendationRequestReceived` and emit `ExperimentAssigned` after business rules and lifecycle checks pass.
3. Operator flow: use `Experiment setup wizard` to inspect or change experimentation classes and guardrails behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `analytics-and-experimentation-service`, `analytics-and-experimentation-api`, and `experimentation-classes-and-guardrails-worker` for async processing.
- Database tables or collections required: `experimentation_classes_and_guardrails`, `experimentation_classes_and_guardrails_history`, and `experimentation_classes_and_guardrails_projection`.
- Jobs or workers required: `experimentation-classes-and-guardrails-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Merchandising governance, Analytics pipeline.
- Frontend components required: Experiment scope matrix, Guardrail warning banner.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/analytics-and-experimentation.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which experiment classes launch first: ranking, source blending, layout, or fallback behavior?
- How should holdouts be handled for channels with sparse traffic?
