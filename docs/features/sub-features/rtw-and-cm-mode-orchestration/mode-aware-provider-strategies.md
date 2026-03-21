# Mode-Aware Provider Strategies

## Parent Feature

- **Feature:** [RTW and CM Mode Orchestration](../../rtw-and-cm-mode-orchestration.md)
- **Feature slug:** `rtw-and-cm-mode-orchestration`
- **Sub-feature slug:** `mode-aware-provider-strategies`
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

Choose provider mixes and ordering differently for RTW and CM journeys while preserving shared orchestration contracts.

## 2. Core Concept

Mode-Aware Provider Strategies is the capability slice of **RTW and CM Mode Orchestration** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need mode-aware provider strategies behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for mode-aware provider strategies so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when rtw and cm mode orchestration affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation mode is resolved
- Provider availability changes
- A rollout updates provider strategy by mode

## 5. Inputs

- Resolved recommendation mode
- Provider registry
- Mode-specific strategy rules

## 6. Outputs

- Mode-specific provider plan
- Provider fallback path
- Mode strategy metadata

## 7. Workflow / Lifecycle

1. Resolve the active provider strategy for RTW, CM, or mixed mode.
2. Select and order providers accordingly.
3. Return provider participation and fallback metadata to orchestration.

## 8. Business Rules

- RTW and CM strategies may differ, but must still emit a common candidate model.
- Mode strategy changes require rollout controls.
- Provider fallback must preserve mode semantics instead of collapsing everything to generic RTW.

## 9. Configuration Model

- Mode-Aware Provider Strategies policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `mode_aware_provider_strategies` primary record storing the current mode-aware provider strategies state.
- `mode_aware_provider_strategies_history` append-only history for lifecycle and trace reconstruction.
- `mode_aware_provider_strategies_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/modes/provider-strategies
- POST /internal/modes/provider-strategies/resolve

## 12. Events Produced

- ModeProviderStrategyResolved
- ModeProviderStrategyChanged

## 13. Events Consumed

- RecommendationModeResolved
- RecommendationProviderDegraded

## 14. Integrations

- Recommendation orchestration
- Look graph and compatibility
- CM configuration service

## 15. UI Components

- Mode strategy ladder
- Provider mix preview

## 16. UI Screens

- Mode provider settings
- Mode strategy preview

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

- Metrics: request count, success rate, degraded rate, and freshness for mode-aware provider strategies.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/modes/provider-strategies` with `Resolved recommendation mode` and return `Mode-specific provider plan` plus traceable metadata.
2. Event flow: consume `RecommendationModeResolved` and emit `ModeProviderStrategyResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `Mode provider settings` to inspect or change mode-aware provider strategies behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `rtw-and-cm-mode-orchestration-service`, `rtw-and-cm-mode-orchestration-api`, and `mode-aware-provider-strategies-worker` for async processing.
- Database tables or collections required: `mode_aware_provider_strategies`, `mode_aware_provider_strategies_history`, and `mode_aware_provider_strategies_projection`.
- Jobs or workers required: `mode-aware-provider-strategies-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Look graph and compatibility, CM configuration service.
- Frontend components required: Mode strategy ladder, Provider mix preview.
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

- Which providers are mandatory in CM mode even when degraded?
- How should mixed-mode journeys split candidate budgets across RTW and CM?
