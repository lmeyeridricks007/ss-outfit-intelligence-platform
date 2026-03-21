# Result-Level Inclusion Exclusion

## Parent Feature

- **Feature:** [Explainability and Auditability](../../explainability-and-auditability.md)
- **Feature slug:** `explainability-and-auditability`
- **Sub-feature slug:** `result-level-inclusion-exclusion`
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

Capture result-level inclusion and exclusion rationale so operators can understand why specific items appeared or were removed.

## 2. Core Concept

Result-Level Inclusion Exclusion is the capability slice of **Explainability and Auditability** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need result-level inclusion exclusion behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for result-level inclusion exclusion so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when explainability and auditability affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A final recommendation result set is assembled
- An operator inspects a missing or included item
- A ranking or governance rationale changes

## 5. Inputs

- Final recommendation set
- Candidate evaluation metadata
- Exclusion and suppression reasons

## 6. Outputs

- Result-level rationale records
- Top exclusion reasons
- Operator-safe explanation snippets

## 7. Workflow / Lifecycle

1. Capture rationale for each included result in the final set.
2. Store a bounded set of top exclusion reasons for key missing candidates.
3. Expose operator-safe explanations through trace and support tooling.

## 8. Business Rules

- Result-level rationale must remain bounded and queryable.
- Exclusion reasons need stable categories for analytics and support.
- Customer-facing explanation depth must stay within policy limits.

## 9. Configuration Model

- Result-Level Inclusion Exclusion policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `result_level_inclusion_exclusion` primary record storing the current result-level inclusion exclusion state.
- `result_level_inclusion_exclusion_history` append-only history for lifecycle and trace reconstruction.
- `result_level_inclusion_exclusion_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/traces/{traceId}/results
- GET /internal/traces/{traceId}/exclusions

## 12. Events Produced

- RecommendationResultRationaleRecorded
- RecommendationExclusionReasonCaptured

## 13. Events Consumed

- RecommendationSetAssembled
- GovernanceConflictResolved

## 14. Integrations

- Recommendation orchestration
- Support tooling
- Analytics pipeline

## 15. UI Components

- Result rationale table
- Exclusion reason pill

## 16. UI Screens

- Trace result detail tab
- Missing item investigation panel

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

- Metrics: request count, success rate, degraded rate, and freshness for result-level inclusion exclusion.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/traces/{traceId}/results` with `Final recommendation set` and return `Result-level rationale records` plus traceable metadata.
2. Event flow: consume `RecommendationSetAssembled` and emit `RecommendationResultRationaleRecorded` after business rules and lifecycle checks pass.
3. Operator flow: use `Trace result detail tab` to inspect or change result-level inclusion exclusion behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `explainability-and-auditability-service`, `explainability-and-auditability-api`, and `result-level-inclusion-exclusion-worker` for async processing.
- Database tables or collections required: `result_level_inclusion_exclusion`, `result_level_inclusion_exclusion_history`, and `result_level_inclusion_exclusion_projection`.
- Jobs or workers required: `result-level-inclusion-exclusion-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Support tooling, Analytics pipeline.
- Frontend components required: Result rationale table, Exclusion reason pill.
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

- How many exclusion reasons should be retained per missing candidate?
- Which result-level explanations are safe for non-technical operator roles?
