# Versioned Core Delivery Contract

## Parent Feature

- **Feature:** [Delivery API and Channel Adapters](../../delivery-api-and-channel-adapters.md)
- **Feature slug:** `delivery-api-and-channel-adapters`
- **Sub-feature slug:** `versioned-core-delivery-contract`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/delivery-api-and-channel-adapters.md`
- `docs/project/br/br-003-multi-surface-delivery.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-009-merchandising-governance.md`
- `docs/project/br/br-010-analytics-and-experimentation.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Expose the versioned core API contract that client channels use to request and receive recommendation results safely.

## 2. Core Concept

Versioned Core Delivery Contract is the capability slice of **Delivery API and Channel Adapters** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need versioned core delivery contract behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for versioned core delivery contract so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when delivery api and channel adapters affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A client sends a recommendation request
- A contract version is introduced or deprecated
- A compatibility validation run starts

## 5. Inputs

- Core request payload
- Contract version metadata
- Recommendation orchestration result

## 6. Outputs

- Versioned delivery response
- Compatibility status
- Contract deprecation metadata

## 7. Workflow / Lifecycle

1. Accept a delivery request under a declared contract version.
2. Validate request shape and route it to orchestration.
3. Return a versioned response with explicit contract metadata and safe defaults.

## 8. Business Rules

- Breaking contract changes require version changes and migration guidance.
- Every response must include durable request and set identifiers.
- Unsupported contract versions require explicit error responses.

## 9. Configuration Model

- Versioned Core Delivery Contract policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `versioned_core_delivery_contract` primary record storing the current versioned core delivery contract state.
- `versioned_core_delivery_contract_history` append-only history for lifecycle and trace reconstruction.
- `versioned_core_delivery_contract_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /v1/recommendations
- GET /internal/delivery/contracts

## 12. Events Produced

- DeliveryResponsePrepared
- DeliveryContractVersionDeprecated

## 13. Events Consumed

- RecommendationSetAssembled
- RecommendationFallbackApplied

## 14. Integrations

- Recommendation orchestration
- API gateway
- Client contract documentation tooling

## 15. UI Components

- Contract version badge
- Sample payload viewer

## 16. UI Screens

- Delivery API reference
- Contract compatibility dashboard

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

- Metrics: request count, success rate, degraded rate, and freshness for versioned core delivery contract.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /v1/recommendations` with `Core request payload` and return `Versioned delivery response` plus traceable metadata.
2. Event flow: consume `RecommendationSetAssembled` and emit `DeliveryResponsePrepared` after business rules and lifecycle checks pass.
3. Operator flow: use `Delivery API reference` to inspect or change versioned core delivery contract behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `delivery-api-and-channel-adapters-service`, `delivery-api-and-channel-adapters-api`, and `versioned-core-delivery-contract-worker` for async processing.
- Database tables or collections required: `versioned_core_delivery_contract`, `versioned_core_delivery_contract_history`, and `versioned_core_delivery_contract_projection`.
- Jobs or workers required: `versioned-core-delivery-contract-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, API gateway, Client contract documentation tooling.
- Frontend components required: Contract version badge, Sample payload viewer.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/delivery-api-and-channel-adapters.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- How many active contract versions must be supported concurrently?
- Which clients need phased migration windows versus immediate cutover?
