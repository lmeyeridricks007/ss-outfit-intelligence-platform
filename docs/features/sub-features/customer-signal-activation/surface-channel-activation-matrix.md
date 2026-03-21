# Surface Channel Activation Matrix

## Parent Feature

- **Feature:** [Customer Signal Activation](../../customer-signal-activation.md)
- **Feature slug:** `customer-signal-activation`
- **Sub-feature slug:** `surface-channel-activation-matrix`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/customer-signal-activation.md`
- `docs/project/br/br-006-customer-signal-usage.md`
- `docs/project/business-requirements.md`
- `docs/project/data-standards.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Define which signal classes can influence each surface and channel so personalization remains predictable and governable.

## 2. Core Concept

Surface Channel Activation Matrix is the capability slice of **Customer Signal Activation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need surface channel activation matrix behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for surface channel activation matrix so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer signal activation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A channel or surface is onboarded
- Policy owners update surface-specific activation rules
- A recommendation request resolves eligible signal classes

## 5. Inputs

- Signal classification results
- Surface and channel metadata
- Activation matrix policy

## 6. Outputs

- Allowed signal set per surface and channel
- Blocked signal reasons
- Surface-specific activation configuration

## 7. Workflow / Lifecycle

1. Load the active activation matrix for the request surface and channel.
2. Intersect the matrix with classified and freshness-valid signals.
3. Return the allowed signal set and excluded reasons for traceability.

## 8. Business Rules

- The matrix must distinguish ecommerce, email, and clienteling contexts.
- Identity confidence and consent may further restrict the allowed set.
- Matrix updates require audit evidence and rollout controls.

## 9. Configuration Model

- Surface Channel Activation Matrix policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `surface_channel_activation_matrix` primary record storing the current surface channel activation matrix state.
- `surface_channel_activation_matrix_history` append-only history for lifecycle and trace reconstruction.
- `surface_channel_activation_matrix_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/signals/activation-matrix
- POST /internal/signals/activation-matrix/preview

## 12. Events Produced

- SignalActivationMatrixResolved
- SignalActivationMatrixChanged

## 13. Events Consumed

- CustomerSignalFreshnessEvaluated
- SurfaceActivationPolicyPublished

## 14. Integrations

- Delivery API
- Recommendation orchestration
- Analytics and experimentation

## 15. UI Components

- Matrix grid editor
- Surface preview panel

## 16. UI Screens

- Signal activation matrix settings
- Surface policy preview

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

- Metrics: request count, success rate, degraded rate, and freshness for surface channel activation matrix.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/signals/activation-matrix` with `Signal classification results` and return `Allowed signal set per surface and channel` plus traceable metadata.
2. Event flow: consume `CustomerSignalFreshnessEvaluated` and emit `SignalActivationMatrixResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `Signal activation matrix settings` to inspect or change surface channel activation matrix behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-signal-activation-service`, `customer-signal-activation-api`, and `surface-channel-activation-matrix-worker` for async processing.
- Database tables or collections required: `surface_channel_activation_matrix`, `surface_channel_activation_matrix_history`, and `surface_channel_activation_matrix_projection`.
- Jobs or workers required: `surface-channel-activation-matrix-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Recommendation orchestration, Analytics and experimentation.
- Frontend components required: Matrix grid editor, Surface preview panel.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/customer-signal-activation.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which activation differences are required at launch between PDP, homepage, email, and clienteling?
- How should matrix changes be rolled out across markets?
