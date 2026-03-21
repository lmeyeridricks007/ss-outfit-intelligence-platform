# Graph Lifecycle and Events

## Parent Feature

- **Feature:** [Look Graph and Compatibility](../../look-graph-and-compatibility.md)
- **Feature slug:** `look-graph-and-compatibility`
- **Sub-feature slug:** `graph-lifecycle-and-events`
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

Operate look graph publication, rebuild jobs, and downstream notifications so compatible candidate retrieval remains current and auditable.

## 2. Core Concept

Graph Lifecycle and Events is the capability slice of **Look Graph and Compatibility** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need graph lifecycle and events behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for graph lifecycle and events so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when look graph and compatibility affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- Look publication occurs
- A graph rebuild is requested or scheduled
- Downstream caches subscribe to graph lifecycle events

## 5. Inputs

- Look publication events
- Rebuild commands and schedules
- Subscriber registrations for graph events

## 6. Outputs

- Graph lifecycle events
- Build status and audit records
- Downstream invalidation signals

## 7. Workflow / Lifecycle

1. Start or schedule graph rebuild work when source inputs change.
2. Track build status and publish lifecycle events at each major transition.
3. Notify downstream systems when new projections are ready or degraded.

## 8. Business Rules

- Graph lifecycle events must be idempotent and replay-safe.
- Partial build failures require explicit degraded-mode signaling.
- Build history must tie back to source look and catalog versions.

## 9. Configuration Model

- Graph Lifecycle and Events policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `graph_lifecycle_and_events` primary record storing the current graph lifecycle and events state.
- `graph_lifecycle_and_events_history` append-only history for lifecycle and trace reconstruction.
- `graph_lifecycle_and_events_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/look-graph/lifecycle/rebuild
- GET /internal/look-graph/lifecycle/runs/{runId}

## 12. Events Produced

- GraphRebuildRequested
- GraphRebuildCompleted

## 13. Events Consumed

- LookPublished
- CatalogEligibilityChanged

## 14. Integrations

- Job scheduler
- Recommendation orchestration caches
- Observability and alerting

## 15. UI Components

- Rebuild run timeline
- Lifecycle status badge

## 16. UI Screens

- Graph operations dashboard
- Run detail page

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

- Metrics: request count, success rate, degraded rate, and freshness for graph lifecycle and events.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/look-graph/lifecycle/rebuild` with `Look publication events` and return `Graph lifecycle events` plus traceable metadata.
2. Event flow: consume `LookPublished` and emit `GraphRebuildRequested` after business rules and lifecycle checks pass.
3. Operator flow: use `Graph operations dashboard` to inspect or change graph lifecycle and events behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `look-graph-and-compatibility-service`, `look-graph-and-compatibility-api`, and `graph-lifecycle-and-events-worker` for async processing.
- Database tables or collections required: `graph_lifecycle_and_events`, `graph_lifecycle_and_events_history`, and `graph_lifecycle_and_events_projection`.
- Jobs or workers required: `graph-lifecycle-and-events-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Job scheduler, Recommendation orchestration caches, Observability and alerting.
- Frontend components required: Rebuild run timeline, Lifecycle status badge.
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

- What rebuild SLA is acceptable before recommendation freshness becomes risky?
- Which graph lifecycle events need external consumers versus internal-only use?
