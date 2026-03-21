# Operator Impact and Health UX

## Parent Feature

- **Feature:** [Merchandising Governance](../../merchandising-governance.md)
- **Feature slug:** `merchandising-governance`
- **Sub-feature slug:** `operator-impact-and-health-ux`
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

Provide operator tools that preview governance impact, highlight risky changes, and surface governance health metrics.

## 2. Core Concept

Operator Impact and Health UX is the capability slice of **Merchandising Governance** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need operator impact and health ux behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for operator impact and health ux so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when merchandising governance affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- An operator edits a governance object
- A publication preview is requested
- Health metrics indicate governance drift or override overuse

## 5. Inputs

- Governance object draft
- Impact preview models
- Operational health metrics

## 6. Outputs

- Impact preview
- Risk warnings
- Governance health dashboard

## 7. Workflow / Lifecycle

1. Generate an impact preview for the proposed governance change.
2. Highlight risk factors such as broad suppression or campaign overlap.
3. Expose health metrics for ongoing governance performance and hygiene.

## 8. Business Rules

- Preview tooling must clearly separate simulated impact from live behavior.
- Risk warnings need stable severity levels and reason codes.
- Health UX cannot imply operational approval that has not happened.

## 9. Configuration Model

- Operator Impact and Health UX policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `operator_impact_and_health_ux` primary record storing the current operator impact and health ux state.
- `operator_impact_and_health_ux_history` append-only history for lifecycle and trace reconstruction.
- `operator_impact_and_health_ux_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/governance/impact-preview
- GET /internal/governance/health

## 12. Events Produced

- GovernanceImpactPreviewGenerated
- GovernanceHealthUpdated

## 13. Events Consumed

- GovernanceObjectDraftSaved
- GovernanceSnapshotApplied

## 14. Integrations

- Operator admin UI
- Analytics and experimentation
- Observability stack

## 15. UI Components

- Affected slots summary
- Risk severity banner

## 16. UI Screens

- Governance impact preview
- Governance health dashboard

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

- Metrics: request count, success rate, degraded rate, and freshness for operator impact and health ux.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/governance/impact-preview` with `Governance object draft` and return `Impact preview` plus traceable metadata.
2. Event flow: consume `GovernanceObjectDraftSaved` and emit `GovernanceImpactPreviewGenerated` after business rules and lifecycle checks pass.
3. Operator flow: use `Governance impact preview` to inspect or change operator impact and health ux behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `merchandising-governance-service`, `merchandising-governance-api`, and `operator-impact-and-health-ux-worker` for async processing.
- Database tables or collections required: `operator_impact_and_health_ux`, `operator_impact_and_health_ux_history`, and `operator_impact_and_health_ux_projection`.
- Jobs or workers required: `operator-impact-and-health-ux-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Operator admin UI, Analytics and experimentation, Observability stack.
- Frontend components required: Affected slots summary, Risk severity banner.
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

- Which impact previews need historical performance overlays versus structural previews only?
- How should override overuse be summarized for non-technical merchandising users?
