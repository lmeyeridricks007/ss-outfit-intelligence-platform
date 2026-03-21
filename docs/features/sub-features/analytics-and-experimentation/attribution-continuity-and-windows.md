# Attribution Continuity and Windows

## Parent Feature

- **Feature:** [Analytics and Experimentation](../../analytics-and-experimentation.md)
- **Feature slug:** `analytics-and-experimentation`
- **Sub-feature slug:** `attribution-continuity-and-windows`
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

Link recommendation impressions and interactions to downstream outcomes using explicit attribution windows and continuity rules.

## 2. Core Concept

Attribution Continuity and Windows is the capability slice of **Analytics and Experimentation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need attribution continuity and windows behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for attribution continuity and windows so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when analytics and experimentation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- An impression or interaction event occurs
- A purchase or other outcome event arrives
- Attribution window policy changes

## 5. Inputs

- Recommendation impression and interaction events
- Commerce outcome events
- Attribution window definitions

## 6. Outputs

- Attributed outcome record
- Attribution continuity state
- Unattributed or partial-join reason

## 7. Workflow / Lifecycle

1. Track recommendation exposure and interaction sequences for a customer or session.
2. Evaluate outcome events against attribution continuity and timing rules.
3. Publish attributed or unattributed outcome records with explicit reasoning.

## 8. Business Rules

- Attribution windows must be explicit by surface and outcome type.
- Partial joins cannot be silently treated as full attribution.
- Attribution logic must remain auditable and reproducible.

## 9. Configuration Model

- Attribution Continuity and Windows policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `attribution_continuity_and_windows` primary record storing the current attribution continuity and windows state.
- `attribution_continuity_and_windows_history` append-only history for lifecycle and trace reconstruction.
- `attribution_continuity_and_windows_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/analytics/attribution/evaluate
- GET /internal/analytics/attribution/policies

## 12. Events Produced

- RecommendationOutcomeAttributed
- RecommendationOutcomeJoinPartial

## 13. Events Consumed

- RecommendationEventSchemaPublished
- CommerceOutcomeObserved

## 14. Integrations

- Commerce order events
- Client telemetry
- Analytics warehouse

## 15. UI Components

- Attribution path timeline
- Join completeness indicator

## 16. UI Screens

- Attribution policy admin
- Outcome trace explorer

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

- Metrics: request count, success rate, degraded rate, and freshness for attribution continuity and windows.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/analytics/attribution/evaluate` with `Recommendation impression and interaction events` and return `Attributed outcome record` plus traceable metadata.
2. Event flow: consume `RecommendationEventSchemaPublished` and emit `RecommendationOutcomeAttributed` after business rules and lifecycle checks pass.
3. Operator flow: use `Attribution policy admin` to inspect or change attribution continuity and windows behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `analytics-and-experimentation-service`, `analytics-and-experimentation-api`, and `attribution-continuity-and-windows-worker` for async processing.
- Database tables or collections required: `attribution_continuity_and_windows`, `attribution_continuity_and_windows_history`, and `attribution_continuity_and_windows_projection`.
- Jobs or workers required: `attribution-continuity-and-windows-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Commerce order events, Client telemetry, Analytics warehouse.
- Frontend components required: Attribution path timeline, Join completeness indicator.
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

- What attribution windows apply to PDP, cart, homepage, and email?
- How should multiple modules in a session share credit for a single conversion?
