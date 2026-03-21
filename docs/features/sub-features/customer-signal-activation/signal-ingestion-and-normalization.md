# Signal Ingestion and Normalization

## Parent Feature

- **Feature:** [Customer Signal Activation](../../customer-signal-activation.md)
- **Feature slug:** `customer-signal-activation`
- **Sub-feature slug:** `signal-ingestion-and-normalization`
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

Normalize web, commerce, loyalty, and clienteling signals into a shared recommendation event model.

## 2. Core Concept

Signal Ingestion and Normalization is the capability slice of **Customer Signal Activation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need signal ingestion and normalization behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for signal ingestion and normalization so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer signal activation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A customer event is emitted by a source system
- A new source feed is onboarded
- Replay is required for signal backfill or schema correction

## 5. Inputs

- Source event payloads
- Channel metadata
- Signal normalization rules

## 6. Outputs

- Normalized recommendation signal
- Schema validation result
- Replay-safe event envelope

## 7. Workflow / Lifecycle

1. Receive source events and map them to the canonical recommendation signal schema.
2. Attach channel, identity, and provenance metadata.
3. Persist normalized events for activation, analytics, and replay.

## 8. Business Rules

- Source events must be version-aware and replayable.
- Normalization cannot erase original provenance fields required for audit.
- Unknown event types are quarantined until mapped or explicitly ignored.

## 9. Configuration Model

- Signal Ingestion and Normalization policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `signal_ingestion_and_normalization` primary record storing the current signal ingestion and normalization state.
- `signal_ingestion_and_normalization_history` append-only history for lifecycle and trace reconstruction.
- `signal_ingestion_and_normalization_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/signals/ingest
- POST /internal/signals/replay

## 12. Events Produced

- CustomerSignalNormalized
- CustomerSignalQuarantined

## 13. Events Consumed

- CustomerEventObserved
- SignalReplayRequested

## 14. Integrations

- Web analytics stream
- Commerce order events
- CRM or clienteling notes feed

## 15. UI Components

- Signal schema inspector
- Replay request action

## 16. UI Screens

- Signal operations console
- Event normalization explorer

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

- Metrics: request count, success rate, degraded rate, and freshness for signal ingestion and normalization.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/signals/ingest` with `Source event payloads` and return `Normalized recommendation signal` plus traceable metadata.
2. Event flow: consume `CustomerEventObserved` and emit `CustomerSignalNormalized` after business rules and lifecycle checks pass.
3. Operator flow: use `Signal operations console` to inspect or change signal ingestion and normalization behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-signal-activation-service`, `customer-signal-activation-api`, and `signal-ingestion-and-normalization-worker` for async processing.
- Database tables or collections required: `signal_ingestion_and_normalization`, `signal_ingestion_and_normalization_history`, and `signal_ingestion_and_normalization_projection`.
- Jobs or workers required: `signal-ingestion-and-normalization-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Web analytics stream, Commerce order events, CRM or clienteling notes feed.
- Frontend components required: Signal schema inspector, Replay request action.
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

- Which clienteling and store signals are approved for Phase 1 ingestion?
- How much raw event history should remain available for replay?
