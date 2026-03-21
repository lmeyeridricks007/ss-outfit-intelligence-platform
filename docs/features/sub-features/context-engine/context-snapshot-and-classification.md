# Context Snapshot and Classification

## Parent Feature

- **Feature:** [Context Engine](../../context-engine.md)
- **Feature slug:** `context-engine`
- **Sub-feature slug:** `context-snapshot-and-classification`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/context-engine.md`
- `docs/project/br/br-007-context-aware-logic.md`
- `docs/project/business-requirements.md`
- `docs/project/data-standards.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Assemble a request-specific context snapshot that classifies context by durability, confidence, and recommendation relevance.

## 2. Core Concept

Context Snapshot and Classification is the capability slice of **Context Engine** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need context snapshot and classification behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for context snapshot and classification so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when context engine affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation request starts
- Precomputed context snapshots expire
- Operators inspect why context affected ranking

## 5. Inputs

- Normalized context attributes
- Snapshot assembly rules
- Request and customer context metadata

## 6. Outputs

- ContextSnapshot record
- Context classification labels
- Snapshot freshness timestamp

## 7. Workflow / Lifecycle

1. Resolve the active normalized context inputs for the request.
2. Classify them as explicit, inferred, durable, or transient.
3. Persist a snapshot with confidence, freshness, and provenance fields.

## 8. Business Rules

- Snapshot contracts must expose both value and confidence.
- Missing provider data must not erase explicit request context.
- Snapshots need deterministic hashes so traces and caches can correlate decisions.

## 9. Configuration Model

- Context Snapshot and Classification policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `context_snapshot_and_classification` primary record storing the current context snapshot and classification state.
- `context_snapshot_and_classification_history` append-only history for lifecycle and trace reconstruction.
- `context_snapshot_and_classification_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/context/snapshots
- GET /internal/context/snapshots/{snapshotId}

## 12. Events Produced

- ContextSnapshotCreated
- ContextSnapshotExpired

## 13. Events Consumed

- ContextNormalized
- RecommendationRequestReceived

## 14. Integrations

- Recommendation orchestration
- Explainability trace service
- Analytics pipeline

## 15. UI Components

- Snapshot detail panel
- Confidence indicator

## 16. UI Screens

- Context snapshot explorer
- Recommendation trace context tab

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

- Metrics: request count, success rate, degraded rate, and freshness for context snapshot and classification.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/context/snapshots` with `Normalized context attributes` and return `ContextSnapshot record` plus traceable metadata.
2. Event flow: consume `ContextNormalized` and emit `ContextSnapshotCreated` after business rules and lifecycle checks pass.
3. Operator flow: use `Context snapshot explorer` to inspect or change context snapshot and classification behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `context-engine-service`, `context-engine-api`, and `context-snapshot-and-classification-worker` for async processing.
- Database tables or collections required: `context_snapshot_and_classification`, `context_snapshot_and_classification_history`, and `context_snapshot_and_classification_projection`.
- Jobs or workers required: `context-snapshot-and-classification-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Explainability trace service, Analytics pipeline.
- Frontend components required: Snapshot detail panel, Confidence indicator.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/context-engine.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which snapshots should be reused across a session versus regenerated per request?
- How much classification detail should be visible to operators outside engineering?
