# Mode Contracts and Labeling

## Parent Feature

- **Feature:** [RTW and CM Mode Orchestration](../../rtw-and-cm-mode-orchestration.md)
- **Feature slug:** `rtw-and-cm-mode-orchestration`
- **Sub-feature slug:** `mode-contracts-and-labeling`
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

Represent RTW, CM, and mixed eligibility as explicit request and response fields so downstream surfaces and analytics do not guess journey mode.

## 2. Core Concept

Mode Contracts and Labeling is the capability slice of **RTW and CM Mode Orchestration** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need mode contracts and labeling behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for mode contracts and labeling so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when rtw and cm mode orchestration affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation request declares or infers mode
- A downstream adapter renders mode-specific copy
- Analytics joins need mode lineage

## 5. Inputs

- Request mode selection
- Catalog and configuration context
- Mode policy definitions

## 6. Outputs

- Mode-labeled request context
- Mode-labeled recommendation response
- Mode analytics dimensions

## 7. Workflow / Lifecycle

1. Resolve the active journey mode for the request.
2. Tag orchestration inputs and outputs with explicit mode values.
3. Expose mode labels to delivery and analytics consumers.

## 8. Business Rules

- Mode labels must be explicit, not inferred downstream from item types.
- Mixed-eligibility responses require clear handling instructions.
- Mode changes must be traceable across a session and recommendation set.

## 9. Configuration Model

- Mode Contracts and Labeling policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `mode_contracts_and_labeling` primary record storing the current mode contracts and labeling state.
- `mode_contracts_and_labeling_history` append-only history for lifecycle and trace reconstruction.
- `mode_contracts_and_labeling_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/modes/resolve
- GET /internal/modes/contracts

## 12. Events Produced

- RecommendationModeResolved
- RecommendationModeContractUpdated

## 13. Events Consumed

- RecommendationRequestReceived
- ConfigurationSnapshotCreated

## 14. Integrations

- Delivery API
- Analytics and experimentation
- Ecommerce surface activation

## 15. UI Components

- Mode badge
- Mixed-eligibility warning chip

## 16. UI Screens

- Mode contract preview
- Session mode timeline

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

- Metrics: request count, success rate, degraded rate, and freshness for mode contracts and labeling.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/modes/resolve` with `Request mode selection` and return `Mode-labeled request context` plus traceable metadata.
2. Event flow: consume `RecommendationRequestReceived` and emit `RecommendationModeResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `Mode contract preview` to inspect or change mode contracts and labeling behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `rtw-and-cm-mode-orchestration-service`, `rtw-and-cm-mode-orchestration-api`, and `mode-contracts-and-labeling-worker` for async processing.
- Database tables or collections required: `mode_contracts_and_labeling`, `mode_contracts_and_labeling_history`, and `mode_contracts_and_labeling_projection`.
- Jobs or workers required: `mode-contracts-and-labeling-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Delivery API, Analytics and experimentation, Ecommerce surface activation.
- Frontend components required: Mode badge, Mixed-eligibility warning chip.
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

- Which journeys can infer mode versus requiring explicit client declaration?
- How should mixed RTW and CM results be labeled for shoppers versus operators?
