# Precedence and Conflict Resolution

## Parent Feature

- **Feature:** [Merchandising Governance](../../merchandising-governance.md)
- **Feature slug:** `merchandising-governance`
- **Sub-feature slug:** `precedence-and-conflict-resolution`
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

Resolve conflicts between campaigns, overrides, curated looks, and evergreen rules with deterministic precedence.

## 2. Core Concept

Precedence and Conflict Resolution is the capability slice of **Merchandising Governance** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need precedence and conflict resolution behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for precedence and conflict resolution so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when merchandising governance affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- Multiple governance objects target the same surface or slot
- A precedence policy changes
- A recommendation decision needs governance rationale

## 5. Inputs

- Active governance objects
- Precedence policy
- Recommendation request and slot context

## 6. Outputs

- Winning governance decision
- Conflict resolution rationale
- Suppressed object list

## 7. Workflow / Lifecycle

1. Collect all governance objects relevant to the request context.
2. Apply precedence and conflict rules in deterministic order.
3. Return the winning directives with rationale for suppressed alternatives.

## 8. Business Rules

- Precedence cannot rely on creation time alone.
- Conflict resolution outcomes must be traceable to specific object versions.
- Suppressed governance objects still need analytics visibility.

## 9. Configuration Model

- Precedence and Conflict Resolution policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `precedence_and_conflict_resolution` primary record storing the current precedence and conflict resolution state.
- `precedence_and_conflict_resolution_history` append-only history for lifecycle and trace reconstruction.
- `precedence_and_conflict_resolution_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/governance/resolve
- GET /internal/governance/precedence-policies

## 12. Events Produced

- GovernanceConflictResolved
- GovernancePrecedencePolicyChanged

## 13. Events Consumed

- GovernanceObjectPublished
- RecommendationRequestReceived

## 14. Integrations

- Recommendation orchestration
- Explainability trace service
- Analytics and experimentation

## 15. UI Components

- Precedence ladder
- Suppressed object tooltip

## 16. UI Screens

- Governance precedence settings
- Decision conflict preview

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

- Metrics: request count, success rate, degraded rate, and freshness for precedence and conflict resolution.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/governance/resolve` with `Active governance objects` and return `Winning governance decision` plus traceable metadata.
2. Event flow: consume `GovernanceObjectPublished` and emit `GovernanceConflictResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `Governance precedence settings` to inspect or change precedence and conflict resolution behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `merchandising-governance-service`, `merchandising-governance-api`, and `precedence-and-conflict-resolution-worker` for async processing.
- Database tables or collections required: `precedence_and_conflict_resolution`, `precedence_and_conflict_resolution_history`, and `precedence_and_conflict_resolution_projection`.
- Jobs or workers required: `precedence-and-conflict-resolution-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Explainability trace service, Analytics and experimentation.
- Frontend components required: Precedence ladder, Suppressed object tooltip.
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

- How should campaign priority interact with protected curated looks in the same slot?
- Are some conflicts severe enough to block publication until resolved manually?
