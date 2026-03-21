# Canonical Customer and Identifier Graph

## Parent Feature

- **Feature:** [Customer Identity and Profile](../../customer-identity-and-profile.md)
- **Feature slug:** `customer-identity-and-profile`
- **Sub-feature slug:** `canonical-customer-and-identifier-graph`
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

Resolve source-specific customer identifiers into a canonical customer graph that downstream recommendation services can trust.

## 2. Core Concept

Canonical Customer and Identifier Graph is the capability slice of **Customer Identity and Profile** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need canonical customer and identifier graph behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for canonical customer and identifier graph so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer identity and profile affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A new customer identifier appears in a channel event
- A profile import links two or more source IDs
- A downstream service requests canonical resolution

## 5. Inputs

- Source-system customer IDs
- Identity linkage evidence
- Historical identifier mappings

## 6. Outputs

- Canonical customer ID
- Identifier graph edges
- Resolution audit record

## 7. Workflow / Lifecycle

1. Ingest source identifiers and normalize them into a common identity envelope.
2. Link or create canonical nodes based on deterministic and approved probabilistic evidence.
3. Persist graph edges and expose a stable canonical resolution result.

## 8. Business Rules

- Canonical IDs remain stable even if source identifiers churn.
- Low-confidence merges must not silently overwrite verified links.
- Every graph mutation needs an audit record with evidence type.

## 9. Configuration Model

- Canonical Customer and Identifier Graph policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `canonical_customer_and_identifier_graph` primary record storing the current canonical customer and identifier graph state.
- `canonical_customer_and_identifier_graph_history` append-only history for lifecycle and trace reconstruction.
- `canonical_customer_and_identifier_graph_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/identity/resolve
- GET /internal/identity/customers/{canonicalCustomerId}

## 12. Events Produced

- CustomerIdentityResolved
- CustomerIdentityConflictDetected

## 13. Events Consumed

- CustomerIdentifierObserved
- CustomerProfileImported

## 14. Integrations

- CRM
- Commerce account service
- Loyalty or clienteling system

## 15. UI Components

- Identity graph viewer
- Conflict resolution table

## 16. UI Screens

- Customer identity operations
- Identity conflict review

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

- Metrics: request count, success rate, degraded rate, and freshness for canonical customer and identifier graph.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/identity/resolve` with `Source-system customer IDs` and return `Canonical customer ID` plus traceable metadata.
2. Event flow: consume `CustomerIdentifierObserved` and emit `CustomerIdentityResolved` after business rules and lifecycle checks pass.
3. Operator flow: use `Customer identity operations` to inspect or change canonical customer and identifier graph behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-identity-and-profile-service`, `customer-identity-and-profile-api`, and `canonical-customer-and-identifier-graph-worker` for async processing.
- Database tables or collections required: `canonical_customer_and_identifier_graph`, `canonical_customer_and_identifier_graph_history`, and `canonical_customer_and_identifier_graph_projection`.
- Jobs or workers required: `canonical-customer-and-identifier-graph-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: CRM, Commerce account service, Loyalty or clienteling system.
- Frontend components required: Identity graph viewer, Conflict resolution table.
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

- Which systems are authoritative for canonical identity at launch?
- How should cross-market customer identity be partitioned or shared?
