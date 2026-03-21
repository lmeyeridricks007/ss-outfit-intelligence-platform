# Governance Audit Linkage

## Parent Feature

- **Feature:** [Explainability and Auditability](../../explainability-and-auditability.md)
- **Feature slug:** `explainability-and-auditability`
- **Sub-feature slug:** `governance-audit-linkage`
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

Link recommendation traces to governance audit history so operators can move from an outcome to the exact merchandising change history behind it.

## 2. Core Concept

Governance Audit Linkage is the capability slice of **Explainability and Auditability** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need governance audit linkage behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for governance audit linkage so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when explainability and auditability affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation trace references governance objects
- A governance object changes after a trace is recorded
- An audit lookup is requested from a trace view

## 5. Inputs

- Recommendation trace governance references
- Governance audit records
- Linkage policies and schemas

## 6. Outputs

- Trace-to-audit linkage record
- Governance history summary
- Linkage completeness status

## 7. Workflow / Lifecycle

1. Capture governance object version references inside the recommendation trace.
2. Resolve those references against governance audit history on lookup or precompute.
3. Expose linked governance history in operator tooling and exports.

## 8. Business Rules

- Linkage must use immutable governance object version identifiers.
- Historical traces must remain valid even after later governance changes.
- Audit linkage exports must obey access and retention policies.

## 9. Configuration Model

- Governance Audit Linkage policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `governance_audit_linkage` primary record storing the current governance audit linkage state.
- `governance_audit_linkage_history` append-only history for lifecycle and trace reconstruction.
- `governance_audit_linkage_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/traces/{traceId}/governance-history
- POST /internal/traces/{traceId}/governance-linkage/refresh

## 12. Events Produced

- RecommendationGovernanceLinkageBuilt
- RecommendationGovernanceLinkageDegraded

## 13. Events Consumed

- RecommendationTraceRecorded
- GovernanceAuditRecorded

## 14. Integrations

- Governance audit pipeline
- Operator trace UI
- Compliance export tooling

## 15. UI Components

- Governance history timeline
- Audit linkage status chip

## 16. UI Screens

- Trace governance tab
- Governance history explorer

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

- Metrics: request count, success rate, degraded rate, and freshness for governance audit linkage.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/traces/{traceId}/governance-history` with `Recommendation trace governance references` and return `Trace-to-audit linkage record` plus traceable metadata.
2. Event flow: consume `RecommendationTraceRecorded` and emit `RecommendationGovernanceLinkageBuilt` after business rules and lifecycle checks pass.
3. Operator flow: use `Trace governance tab` to inspect or change governance audit linkage behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `explainability-and-auditability-service`, `explainability-and-auditability-api`, and `governance-audit-linkage-worker` for async processing.
- Database tables or collections required: `governance_audit_linkage`, `governance_audit_linkage_history`, and `governance_audit_linkage_projection`.
- Jobs or workers required: `governance-audit-linkage-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Governance audit pipeline, Operator trace UI, Compliance export tooling.
- Frontend components required: Governance history timeline, Audit linkage status chip.
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

- How much governance history should render inline versus via deep links?
- What retention class applies when traces outlive live governance records?
