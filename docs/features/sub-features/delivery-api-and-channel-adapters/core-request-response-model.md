# Core Request Response Model

## Parent Feature

- **Feature:** [Delivery API and Channel Adapters](../../delivery-api-and-channel-adapters.md)
- **Feature slug:** `delivery-api-and-channel-adapters`
- **Sub-feature slug:** `core-request-response-model`
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

Define the canonical request and response DTOs used by all channel adapters to exchange recommendation data.

## 2. Core Concept

Core Request Response Model is the capability slice of **Delivery API and Channel Adapters** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need core request response model behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for core request response model so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when delivery api and channel adapters affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A channel adapter needs canonical request or response fields
- A new recommendation field is proposed
- A schema validation test run starts

## 5. Inputs

- Surface and channel metadata
- Anchor, cart, context, and identity inputs
- Assembled recommendation set and metadata

## 6. Outputs

- Canonical request DTO
- Canonical response DTO
- Schema validation artifacts

## 7. Workflow / Lifecycle

1. Normalize inbound client data into the canonical request model.
2. Populate the canonical response model from orchestration output and decision metadata.
3. Validate schema completeness before adapter-specific shaping occurs.

## 8. Business Rules

- Canonical models must separate request facts from delivery-only enrichments.
- Unknown optional fields cannot be repurposed as transport for internal-only data.
- Schema fields require stable naming and explicit nullability rules.

## 9. Configuration Model

- Core Request Response Model policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `core_request_response_model` primary record storing the current core request response model state.
- `core_request_response_model_history` append-only history for lifecycle and trace reconstruction.
- `core_request_response_model_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/delivery/models/validate
- GET /internal/delivery/models/schema

## 12. Events Produced

- DeliveryModelValidated
- DeliveryModelSchemaChanged

## 13. Events Consumed

- RecommendationDecisionMetadataRecorded
- RecommendationTypeRegistryUpdated

## 14. Integrations

- Channel adapter layer
- Analytics and experimentation
- Trace redaction service

## 15. UI Components

- Schema explorer
- Field-level compatibility note

## 16. UI Screens

- Canonical schema browser
- Schema diff view

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

- Metrics: request count, success rate, degraded rate, and freshness for core request response model.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/delivery/models/validate` with `Surface and channel metadata` and return `Canonical request DTO` plus traceable metadata.
2. Event flow: consume `RecommendationDecisionMetadataRecorded` and emit `DeliveryModelValidated` after business rules and lifecycle checks pass.
3. Operator flow: use `Canonical schema browser` to inspect or change core request response model behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `delivery-api-and-channel-adapters-service`, `delivery-api-and-channel-adapters-api`, and `core-request-response-model-worker` for async processing.
- Database tables or collections required: `core_request_response_model`, `core_request_response_model_history`, and `core_request_response_model_projection`.
- Jobs or workers required: `core-request-response-model-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Channel adapter layer, Analytics and experimentation, Trace redaction service.
- Frontend components required: Schema explorer, Field-level compatibility note.
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

- Which fields are required for every channel versus channel-specific opt-ins?
- How much trace metadata belongs in the canonical response versus adapter metadata?
