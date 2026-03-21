# Multi-Type Response Policies

## Parent Feature

- **Feature:** [Recommendation Orchestration and Types](../../recommendation-orchestration-and-types.md)
- **Feature slug:** `recommendation-orchestration-and-types`
- **Sub-feature slug:** `multi-type-response-policies`
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

Control how multiple recommendation types can be requested and returned in a single response without semantic ambiguity.

## 2. Core Concept

Multi-Type Response Policies is the capability slice of **Recommendation Orchestration and Types** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need multi-type response policies behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for multi-type response policies so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when recommendation orchestration and types affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A client requests multiple recommendation types
- A surface policy defines the allowed type mix
- A partial failure affects one type but not others

## 5. Inputs

- Requested recommendation types
- Surface and channel policy
- Assembled type-specific sets

## 6. Outputs

- Bundled multi-type response policy result
- Per-type success or degraded status
- Cross-type ordering metadata

## 7. Workflow / Lifecycle

1. Validate the requested type mix against surface policy.
2. Assemble or fetch each eligible type-specific set.
3. Package them into a single response with per-type status and ordering semantics.

## 8. Business Rules

- Responses must preserve the identity of each returned recommendation type.
- A degraded or empty type cannot masquerade as another type.
- Cross-type ordering rules must be explicit for UI consumers.

## 9. Configuration Model

- Multi-Type Response Policies policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `multi_type_response_policies` primary record storing the current multi-type response policies state.
- `multi_type_response_policies_history` append-only history for lifecycle and trace reconstruction.
- `multi_type_response_policies_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/recommendations/multi-type
- GET /internal/recommendations/multi-type/policies

## 12. Events Produced

- MultiTypeRecommendationResponsePrepared
- MultiTypeRecommendationPolicyChanged

## 13. Events Consumed

- RecommendationSetAssembled
- RecommendationTypeRegistryUpdated

## 14. Integrations

- Delivery API
- Ecommerce surface activation
- Analytics and experimentation

## 15. UI Components

- Per-type status banner
- Multi-type ordering preview

## 16. UI Screens

- Client contract preview
- Type mix policy editor

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

- Metrics: request count, success rate, degraded rate, and freshness for multi-type response policies.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/recommendations/multi-type` with `Requested recommendation types` and return `Bundled multi-type response policy result` plus traceable metadata.
2. Event flow: consume `RecommendationSetAssembled` and emit `MultiTypeRecommendationResponsePrepared` after business rules and lifecycle checks pass.
3. Operator flow: use `Client contract preview` to inspect or change multi-type response policies behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `recommendation-orchestration-and-types-service`, `recommendation-orchestration-and-types-api`, and `multi-type-response-policies-worker` for async processing.
- Database tables or collections required: `multi_type_response_policies`, `multi_type_response_policies_history`, and `multi_type_response_policies_projection`.
- Jobs or workers required: `multi-type-response-policies-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Ecommerce surface activation, Analytics and experimentation.
- Frontend components required: Per-type status banner, Multi-type ordering preview.
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

- Should the first delivery contract favor one bundled endpoint or multiple single-type calls?
- Which surfaces need hard caps on simultaneous type modules?
