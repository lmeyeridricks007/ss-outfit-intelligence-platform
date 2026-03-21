# Sub-feature capability: Projections Feed Health And Operator Tooling

**Parent feature:** `Catalog and product intelligence`  
**Parent feature file:** `docs/features/catalog-and-product-intelligence.md`  
**Parent feature priority:** `P0`  
**Sub-feature directory:** `docs/features/sub-features/catalog-and-product-intelligence/`  
**Upstream traceability:** `docs/features/catalog-and-product-intelligence.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-008, BR-004); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`)  
**Tracked open decisions:** `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`

---

## 1. Purpose

Materialize low-latency catalog projections and operator-facing health views so downstream recommendation services and catalog operators can act on the same recommendation-safe readiness truth.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Catalog and product intelligence` and owns one clear responsibility: materialize low-latency catalog projections and operator-facing health views so downstream recommendation services and catalog operators can act on the same recommendation-safe readiness truth.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Catalog and product intelligence` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Projections Feed Health And Operator Tooling` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- Catalog normalization, readiness, or eligibility records change.
- Operators need to inspect feed health incidents or suppression reasons.
- Decisioning requires fast candidate-scope projections instead of raw catalog scans.

## 5. Inputs

- canonical product records
- readiness and eligibility snapshots
- feed incident records
- operator override or suppression actions
- projection consumers and cache invalidation signals

## 6. Outputs

- low-latency catalog eligibility projections
- feed health incident dashboards
- operator suppression and exception queues
- cache invalidation markers for downstream consumers

## 7. Workflow / Lifecycle

1. Project canonical and readiness data into consumer-specific read models.
2. Index the projections by market, channel, mode, and eligibility scope.
3. Update operator health views and suppression queues when incidents occur.
4. Notify downstream consumers that eligible-product projections have changed.
5. Measure feed latency, error rates, and reconciliation quality.

## 8. Business Rules

- Recommendation readiness must be computed from explicit policy, not inferred ad hoc by ranking or surfaces.
- Unknown, stale, partial, and failed readiness states must remain distinct because they drive different degraded behaviors.
- Mode-specific eligibility for `RTW` and `CM` must be explicit in product truth rather than reconstructed downstream.
- This capability must stay aligned with `docs/features/catalog-and-product-intelligence.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.

## 10. Data Model

Primary entities:

- CatalogProjection
- FeedHealthIncident
- SuppressionQueueItem
- ProjectionConsumer
- CacheInvalidationRecord

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- GET /catalog/projections/{scopeKey}
- GET /catalog/feed-health/incidents
- POST /catalog/projections/rebuild

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- catalog.projection.updated
- catalog.feed.incident.opened

## 13. Events Consumed

- catalog.eligibility.updated
- catalog.mapping.conflict.detected
- operator.suppression.requested

## 14. Integrations

- product information management and commerce data sources
- inventory and order-management systems
- digital asset management
- merchandising governance and operator controls
- recommendation decisioning and ranking
- shared contracts and delivery API
- explainability and auditability

## 15. UI Components

- catalog readiness table
- suppression reason tags
- feed health incidents list
- eligibility projection cards

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- catalog operations console
- product readiness detail page
- feed incident triage screen

## 17. Permissions & Security

- Restrict write operations to the service or operator role responsible for the capability.
- Expose only role-safe fields to support, operator, and consumer views.
- Keep audit fields on every state change that affects downstream recommendation behavior.

## 18. Error Handling

- Reject malformed requests or invalid references with structured validation errors and reason codes.
- Distinguish degraded or partial success from hard failure whenever the capability can still produce a safe output.
- Preserve traceability for failures so support and analytics can correlate them later.

## 19. Edge Cases

- Out-of-order upstream updates arrive and must not regress the effective state.
- A downstream consumer uses an older snapshot or contract version while the capability advances.
- Open decisions or policy changes alter behavior between stages and must remain traceable.

## 20. Performance Considerations

- Prefer projection-backed reads for request-time paths instead of recomputing from raw history.
- Keep payloads, indexes, and cache invalidation aligned with the surfaces that consume the capability.
- Track degraded-state rates so performance shortcuts do not silently erode recommendation quality.

## 21. Observability

- Emit metrics for throughput, failures, degraded outcomes, and stale-state usage.
- Log stable identifiers such as `traceId`, `recommendationSetId`, snapshot IDs, or job IDs where the capability affects downstream recommendation behavior.
- Publish structured reason codes so support, analytics, and audit tooling can bucket outcomes consistently.
- Alert on sustained data-quality regressions, schema failures, or provider lag.

## 22. Example Scenarios

### Scenario A: Typical happy-path execution

1. A request or upstream change triggers `Projections Feed Health And Operator Tooling`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "projections-feed-health-and-operator-tooling",
  "feature": "catalog-and-product-intelligence",
  "input": "canonical product records",
  "output": "low-latency catalog eligibility projections",
  "traceId": "trace_example_001",
  "recommendationSetId": "set_example_001"
}
```

## 23. Implementation Notes

- Backend services should own the business logic and expose read-optimized contracts to downstream consumers.
- Persist versioned records or snapshots rather than mutating the effective truth in place when the capability affects delivery or audit.
- Use background jobs or stream consumers where the capability depends on ingestion, projections, or recomputation.
- Prefer stable canonical IDs from `docs/project/data-standards.md` for products, customers, looks, rules, campaigns, experiments, and recommendation sets.

Specific implementation implications for this capability:

- Backend services: add or extend a `projections-feed-health-and-operator-tooling` service boundary under the `catalog-and-product-intelligence` domain.
- Database tables or documents: persist the primary entities listed in the data model with versioning and audit fields.
- Jobs or workers: add asynchronous processing where ingestion, recomputation, replay, or batch delivery is part of the lifecycle.
- External APIs: integrate only through the upstream systems explicitly referenced in the parent feature dependencies and inputs.
- Frontend or shared UI: expose only the UI components and screens listed above; do not create duplicate surface-specific semantics.

## 24. Testing Requirements

- Unit tests for state transitions, precedence rules, and reason-code assignment.
- Contract tests for the capability's illustrative API shapes and event payloads.
- Integration tests covering upstream dependency inputs and downstream consumer expectations.
- Regression tests for degraded, empty, or blocked paths.
- Traceability tests that verify stable identifiers and policy references propagate correctly.
