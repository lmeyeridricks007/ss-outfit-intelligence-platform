# Fallback and Empty States

## Parent Feature

- **Feature:** [Recommendation Orchestration and Types](../../recommendation-orchestration-and-types.md)
- **Feature slug:** `recommendation-orchestration-and-types`
- **Sub-feature slug:** `fallback-and-empty-states`
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

Define the fallback ladder and explicit empty-state behavior for recommendation sets when data, providers, or policies prevent ideal results.

## 2. Core Concept

Fallback and Empty States is the capability slice of **Recommendation Orchestration and Types** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need fallback and empty states behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for fallback and empty states so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when recommendation orchestration and types affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- No candidates survive filtering
- A provider or model is unavailable
- A surface needs a non-empty module decision

## 5. Inputs

- Assembly failure reasons
- Fallback policies
- Surface-specific empty-state behavior

## 6. Outputs

- Fallback recommendation set or empty-state result
- Empty reason code
- Fallback trace metadata

## 7. Workflow / Lifecycle

1. Detect why the preferred recommendation path failed or produced too few candidates.
2. Walk the configured fallback ladder until a valid outcome is found.
3. Return the fallback result or explicit empty-state reason with trace metadata.

## 8. Business Rules

- Fallbacks cannot bypass hard eligibility, governance, or consent constraints.
- Empty states must be explicit and analyzable by reason code.
- Fallback origin and depth must be visible in traces and analytics.

## 9. Configuration Model

- Fallback and Empty States policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `fallback_and_empty_states` primary record storing the current fallback and empty states state.
- `fallback_and_empty_states_history` append-only history for lifecycle and trace reconstruction.
- `fallback_and_empty_states_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/recommendations/fallback-policies
- POST /internal/recommendations/fallback/preview

## 12. Events Produced

- RecommendationFallbackApplied
- RecommendationEmptyStateReturned

## 13. Events Consumed

- RecommendationAssemblyDegraded
- RecommendationProviderDegraded

## 14. Integrations

- Delivery API
- Analytics and experimentation
- Ecommerce surface activation

## 15. UI Components

- Fallback origin tag
- Empty-state reason banner

## 16. UI Screens

- Fallback policy admin
- Surface empty-state preview

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

- Metrics: request count, success rate, degraded rate, and freshness for fallback and empty states.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/recommendations/fallback-policies` with `Assembly failure reasons` and return `Fallback recommendation set or empty-state result` plus traceable metadata.
2. Event flow: consume `RecommendationAssemblyDegraded` and emit `RecommendationFallbackApplied` after business rules and lifecycle checks pass.
3. Operator flow: use `Fallback policy admin` to inspect or change fallback and empty states behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `recommendation-orchestration-and-types-service`, `recommendation-orchestration-and-types-api`, and `fallback-and-empty-states-worker` for async processing.
- Database tables or collections required: `fallback_and_empty_states`, `fallback_and_empty_states_history`, and `fallback_and_empty_states_projection`.
- Jobs or workers required: `fallback-and-empty-states-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Analytics and experimentation, Ecommerce surface activation.
- Frontend components required: Fallback origin tag, Empty-state reason banner.
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

- Which fallback ladders must differ by recommendation type or surface?
- When should a surface hide a module versus show an explicit empty state?
