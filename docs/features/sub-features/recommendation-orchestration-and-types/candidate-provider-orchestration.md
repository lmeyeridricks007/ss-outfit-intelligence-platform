# Candidate Provider Orchestration

## Parent Feature

- **Feature:** [Recommendation Orchestration and Types](../../recommendation-orchestration-and-types.md)
- **Feature slug:** `recommendation-orchestration-and-types`
- **Sub-feature slug:** `candidate-provider-orchestration`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/recommendation-orchestration-and-types.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Coordinate candidate providers across curated, graph, rule, context, and behavioral sources into a common retrieval flow.

## 2. Core Concept

Candidate Provider Orchestration is the capability slice of **Recommendation Orchestration and Types** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need candidate provider orchestration behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for candidate provider orchestration so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when recommendation orchestration and types affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation request starts
- A provider becomes available or degraded
- A provider strategy changes for a surface or mode

## 5. Inputs

- Recommendation request context
- Provider registry and ordering
- Anchor, profile, and context data

## 6. Outputs

- Candidate pool with provenance
- Provider participation metadata
- Provider degradation annotations

## 7. Workflow / Lifecycle

1. Resolve the provider strategy for the request type, surface, and mode.
2. Call candidate providers and normalize results into a common candidate model.
3. Return the combined candidate pool with provider provenance and health status.

## 8. Business Rules

- Provider ordering must be explicit and auditable.
- Provider failures cannot break the entire request when fallback paths exist.
- Candidate normalization must preserve source family, score, and rationale metadata.

## 9. Configuration Model

- Candidate Provider Orchestration policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `candidate_provider_orchestration` primary record storing the current candidate provider orchestration state.
- `candidate_provider_orchestration_history` append-only history for lifecycle and trace reconstruction.
- `candidate_provider_orchestration_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/recommendations/candidates
- GET /internal/recommendations/providers

## 12. Events Produced

- RecommendationCandidatesCollected
- RecommendationProviderDegraded

## 13. Events Consumed

- RecommendationRequestReceived
- LookAssemblyReadModelUpdated

## 14. Integrations

- Look graph and compatibility
- Customer signal activation
- Context engine

## 15. UI Components

- Provider participation summary
- Candidate provenance badge

## 16. UI Screens

- Candidate pipeline explorer
- Provider strategy settings

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

- Metrics: request count, success rate, degraded rate, and freshness for candidate provider orchestration.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/recommendations/candidates` with `Recommendation request context` and return `Candidate pool with provenance` plus traceable metadata.
2. Event flow: consume `RecommendationRequestReceived` and emit `RecommendationCandidatesCollected` after business rules and lifecycle checks pass.
3. Operator flow: use `Candidate pipeline explorer` to inspect or change candidate provider orchestration behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `recommendation-orchestration-and-types-service`, `recommendation-orchestration-and-types-api`, and `candidate-provider-orchestration-worker` for async processing.
- Database tables or collections required: `candidate_provider_orchestration`, `candidate_provider_orchestration_history`, and `candidate_provider_orchestration_projection`.
- Jobs or workers required: `candidate-provider-orchestration-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Look graph and compatibility, Customer signal activation, Context engine.
- Frontend components required: Provider participation summary, Candidate provenance badge.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/recommendation-orchestration-and-types.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which provider combinations are mandatory per recommendation type in Phase 1?
- Should provider retries happen inline or via cached last-known-good results?
