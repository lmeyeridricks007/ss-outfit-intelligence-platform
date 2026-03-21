# Governance Object Lifecycle

## Parent Feature

- **Feature:** [Merchandising Governance](../../merchandising-governance.md)
- **Feature slug:** `merchandising-governance`
- **Sub-feature slug:** `governance-object-lifecycle`
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

Manage the draft, review, scheduled, active, and retired lifecycle of merchandising governance objects.

## 2. Core Concept

Governance Object Lifecycle is the capability slice of **Merchandising Governance** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need governance object lifecycle behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for governance object lifecycle so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when merchandising governance affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A governance object is created or edited
- A publish or schedule action occurs
- An object expires or is rolled back

## 5. Inputs

- Governance object definitions
- Lifecycle transition commands
- Approval and scheduling metadata

## 6. Outputs

- Versioned governance object
- Lifecycle state transition record
- Publication or rollback audit trail

## 7. Workflow / Lifecycle

1. Create or modify a governance object in draft state.
2. Validate and promote it through review and scheduled publication states.
3. Activate, expire, or roll back the object with explicit audit history.

## 8. Business Rules

- Lifecycle transitions must be explicit and audited.
- Active objects must retain immutable version references used by recommendation traces.
- Rollbacks cannot delete historical approval evidence.

## 9. Configuration Model

- Governance Object Lifecycle policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `governance_object_lifecycle` primary record storing the current governance object lifecycle state.
- `governance_object_lifecycle_history` append-only history for lifecycle and trace reconstruction.
- `governance_object_lifecycle_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/governance/objects
- POST /internal/governance/objects/{objectId}/transition

## 12. Events Produced

- GovernanceObjectDraftSaved
- GovernanceObjectPublished

## 13. Events Consumed

- ApprovalDecisionRecorded
- GovernanceRollbackRequested

## 14. Integrations

- Recommendation orchestration
- Audit logging
- Operator notifications

## 15. UI Components

- Lifecycle timeline
- Publish scheduling control

## 16. UI Screens

- Governance object detail page
- Publication calendar

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

- Metrics: request count, success rate, degraded rate, and freshness for governance object lifecycle.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/governance/objects` with `Governance object definitions` and return `Versioned governance object` plus traceable metadata.
2. Event flow: consume `ApprovalDecisionRecorded` and emit `GovernanceObjectDraftSaved` after business rules and lifecycle checks pass.
3. Operator flow: use `Governance object detail page` to inspect or change governance object lifecycle behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `merchandising-governance-service`, `merchandising-governance-api`, and `governance-object-lifecycle-worker` for async processing.
- Database tables or collections required: `governance_object_lifecycle`, `governance_object_lifecycle_history`, and `governance_object_lifecycle_projection`.
- Jobs or workers required: `governance-object-lifecycle-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Audit logging, Operator notifications.
- Frontend components required: Lifecycle timeline, Publish scheduling control.
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

- Which governance object types require second-person approval before activation?
- How much schedule preview is needed before publication becomes active?
