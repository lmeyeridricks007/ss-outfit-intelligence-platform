# Governance Snapshot for Execution

## Parent Feature

- **Feature:** [Merchandising Governance](../../merchandising-governance.md)
- **Feature slug:** `merchandising-governance`
- **Sub-feature slug:** `governance-snapshot-for-execution`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/merchandising-governance.md`
- `docs/project/br/br-009-merchandising-governance.md`
- `docs/project/br/br-010-analytics-and-experimentation.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/br/br-003-multi-surface-delivery.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Compile active governance objects into a low-latency snapshot that serving paths can evaluate without reconstructing lifecycle logic.

## 2. Core Concept

Governance Snapshot for Execution is the capability slice of **Merchandising Governance** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need governance snapshot for execution behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for governance snapshot for execution so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when merchandising governance affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A governance object is published or expires
- A serving path requests the current snapshot
- A snapshot build or propagation failure occurs

## 5. Inputs

- Active governance objects
- Snapshot build configuration
- Propagation and cache policies

## 6. Outputs

- Compiled governance snapshot
- Snapshot version metadata
- Snapshot propagation status

## 7. Workflow / Lifecycle

1. Compile active governance objects into a serving-friendly snapshot.
2. Distribute the snapshot to recommendation-serving systems and caches.
3. Monitor propagation success and fallback to last-known-good behavior when necessary.

## 8. Business Rules

- Snapshot versions must be immutable and traceable.
- Serving paths cannot evaluate unpublished draft governance objects.
- Propagation failures require explicit degraded-mode signaling.

## 9. Configuration Model

- Governance Snapshot for Execution policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `governance_snapshot_for_execution` primary record storing the current governance snapshot for execution state.
- `governance_snapshot_for_execution_history` append-only history for lifecycle and trace reconstruction.
- `governance_snapshot_for_execution_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/governance/snapshots/current
- POST /internal/governance/snapshots/rebuild

## 12. Events Produced

- GovernanceSnapshotApplied
- GovernanceSnapshotPropagationDegraded

## 13. Events Consumed

- GovernanceObjectPublished
- GovernanceConflictResolved

## 14. Integrations

- Recommendation orchestration
- Cache infrastructure
- Observability stack

## 15. UI Components

- Snapshot version badge
- Propagation status card

## 16. UI Screens

- Governance snapshot dashboard
- Snapshot rebuild page

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

- Metrics: request count, success rate, degraded rate, and freshness for governance snapshot for execution.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/governance/snapshots/current` with `Active governance objects` and return `Compiled governance snapshot` plus traceable metadata.
2. Event flow: consume `GovernanceObjectPublished` and emit `GovernanceSnapshotApplied` after business rules and lifecycle checks pass.
3. Operator flow: use `Governance snapshot dashboard` to inspect or change governance snapshot for execution behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `merchandising-governance-service`, `merchandising-governance-api`, and `governance-snapshot-for-execution-worker` for async processing.
- Database tables or collections required: `governance_snapshot_for_execution`, `governance_snapshot_for_execution_history`, and `governance_snapshot_for_execution_projection`.
- Jobs or workers required: `governance-snapshot-for-execution-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Cache infrastructure, Observability stack.
- Frontend components required: Snapshot version badge, Propagation status card.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/merchandising-governance.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- What propagation SLA is acceptable before ecommerce surfaces must degrade?
- Which consumers need push-based snapshot updates versus pull?
