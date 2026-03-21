# Recommendation Profile Projection

## Parent Feature

- **Feature:** [Customer Identity and Profile](../../customer-identity-and-profile.md)
- **Feature slug:** `customer-identity-and-profile`
- **Sub-feature slug:** `recommendation-profile-projection`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/customer-identity-and-profile.md`
- `docs/project/business-requirements.md`
- `docs/project/data-standards.md`
- `docs/project/architecture-overview.md`
- `docs/project/product-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Serve recommendation-specific customer profile projections that contain only the fields needed for personalization and traceability.

## 2. Core Concept

Recommendation Profile Projection is the capability slice of **Customer Identity and Profile** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need recommendation profile projection behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for recommendation profile projection so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer identity and profile affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation request references a canonical customer
- A downstream service precomputes profile projections
- Profile schemas change and projection rebuilding is required

## 5. Inputs

- Canonical customer ID
- Consent-approved profile facets
- Surface or channel request context

## 6. Outputs

- Recommendation profile projection
- Projection freshness metadata
- Field-level inclusion rationale

## 7. Workflow / Lifecycle

1. Load approved profile facets for the customer and request context.
2. Shape them into a recommendation-specific projection with surface-aware filtering.
3. Expose the projection with explicit freshness and provenance fields.

## 8. Business Rules

- Projection contracts must be stable for downstream consumers.
- Internal reason fields cannot leak into customer-facing payloads.
- Missing optional fields must degrade safely rather than force a request failure.

## 9. Configuration Model

- Recommendation Profile Projection policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `recommendation_profile_projection` primary record storing the current recommendation profile projection state.
- `recommendation_profile_projection_history` append-only history for lifecycle and trace reconstruction.
- `recommendation_profile_projection_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/profile/projections/recommendation
- GET /internal/profile/projections/{projectionId}

## 12. Events Produced

- RecommendationProfileProjectionBuilt
- RecommendationProfileProjectionExpired

## 13. Events Consumed

- CustomerProfileFacetsProjected
- CustomerPersonalizationGateChanged

## 14. Integrations

- Recommendation orchestration
- Delivery API
- Explainability trace service

## 15. UI Components

- Projection payload inspector
- Field provenance tooltip

## 16. UI Screens

- Projection explorer
- Field-level trace panel

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

- Metrics: request count, success rate, degraded rate, and freshness for recommendation profile projection.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/profile/projections/recommendation` with `Canonical customer ID` and return `Recommendation profile projection` plus traceable metadata.
2. Event flow: consume `CustomerProfileFacetsProjected` and emit `RecommendationProfileProjectionBuilt` after business rules and lifecycle checks pass.
3. Operator flow: use `Projection explorer` to inspect or change recommendation profile projection behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-identity-and-profile-service`, `customer-identity-and-profile-api`, and `recommendation-profile-projection-worker` for async processing.
- Database tables or collections required: `recommendation_profile_projection`, `recommendation_profile_projection_history`, and `recommendation_profile_projection_projection`.
- Jobs or workers required: `recommendation-profile-projection-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Delivery API, Explainability trace service.
- Frontend components required: Projection payload inspector, Field provenance tooltip.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/customer-identity-and-profile.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which projections should be precomputed versus request-time only?
- How much profile detail should operators see by role?
