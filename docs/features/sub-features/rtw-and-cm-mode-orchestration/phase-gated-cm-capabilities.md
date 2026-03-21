# Phase-Gated CM Capabilities

## Parent Feature

- **Feature:** [RTW and CM Mode Orchestration](../../rtw-and-cm-mode-orchestration.md)
- **Feature slug:** `rtw-and-cm-mode-orchestration`
- **Sub-feature slug:** `phase-gated-cm-capabilities`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/rtw-and-cm-mode-orchestration.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/personas.md`
- `docs/project/roadmap.md`

## 1. Purpose

Roll out CM recommendation depth progressively by phase without breaking shared recommendation contracts.

## 2. Core Concept

Phase-Gated CM Capabilities is the capability slice of **RTW and CM Mode Orchestration** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need phase-gated cm capabilities behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for phase-gated cm capabilities so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when rtw and cm mode orchestration affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A roadmap phase activates new CM capabilities
- A surface requests CM-specific features
- Operators preview phase-gated behavior

## 5. Inputs

- Roadmap phase configuration
- Surface capability flags
- CM feature readiness status

## 6. Outputs

- Enabled CM capability set
- Phase-specific degraded behavior
- Rollout audit metadata

## 7. Workflow / Lifecycle

1. Resolve the current roadmap phase and feature flags for the request.
2. Enable only the CM capabilities that are ready for that phase.
3. Return explicit degraded behavior when later-phase CM features are not yet active.

## 8. Business Rules

- Phase gating cannot change core contract semantics unexpectedly.
- Disabled capabilities must return explicit unsupported or degraded reasons.
- Rollout changes require traceable configuration history.

## 9. Configuration Model

- Phase-Gated CM Capabilities policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `phase_gated_cm_capabilities` primary record storing the current phase-gated cm capabilities state.
- `phase_gated_cm_capabilities_history` append-only history for lifecycle and trace reconstruction.
- `phase_gated_cm_capabilities_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/cm/phases
- POST /internal/cm/phases/preview

## 12. Events Produced

- CmCapabilityPhaseResolved
- CmCapabilityFlagChanged

## 13. Events Consumed

- RoadmapPhaseUpdated
- SurfacePolicyPublished

## 14. Integrations

- Roadmap and feature flag service
- Recommendation orchestration
- Delivery API

## 15. UI Components

- Phase readiness matrix
- Feature flag summary badge

## 16. UI Screens

- CM rollout controls
- Phase preview panel

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

- Metrics: request count, success rate, degraded rate, and freshness for phase-gated cm capabilities.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/cm/phases` with `Roadmap phase configuration` and return `Enabled CM capability set` plus traceable metadata.
2. Event flow: consume `RoadmapPhaseUpdated` and emit `CmCapabilityPhaseResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `CM rollout controls` to inspect or change phase-gated cm capabilities behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `rtw-and-cm-mode-orchestration-service`, `rtw-and-cm-mode-orchestration-api`, and `phase-gated-cm-capabilities-worker` for async processing.
- Database tables or collections required: `phase_gated_cm_capabilities`, `phase_gated_cm_capabilities_history`, and `phase_gated_cm_capabilities_projection`.
- Jobs or workers required: `phase-gated-cm-capabilities-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Roadmap and feature flag service, Recommendation orchestration, Delivery API.
- Frontend components required: Phase readiness matrix, Feature flag summary badge.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/rtw-and-cm-mode-orchestration.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which CM surfaces enter first after ecommerce RTW launch?
- How much preview access should operators have before a phase is live?
