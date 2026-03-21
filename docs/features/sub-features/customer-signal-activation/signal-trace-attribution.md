# Signal Trace Attribution

## Parent Feature

- **Feature:** [Customer Signal Activation](../../customer-signal-activation.md)
- **Feature slug:** `customer-signal-activation`
- **Sub-feature slug:** `signal-trace-attribution`
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

Record which customer signals were used, ignored, stale, or blocked so recommendation traces remain explainable and measurable.

## 2. Core Concept

Signal Trace Attribution is the capability slice of **Customer Signal Activation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need signal trace attribution behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for signal trace attribution so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer signal activation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A recommendation set is assembled
- A signal is blocked or expires before serving
- An operator inspects why a recommendation was personalized

## 5. Inputs

- Recommendation request context
- Activation-safe signal set
- Signal exclusion reasons

## 6. Outputs

- Trace records describing used and ignored signals
- Signal attribution metadata for analytics
- Debuggable reason codes

## 7. Workflow / Lifecycle

1. Capture the signal set considered during recommendation assembly.
2. Annotate each signal with its usage state and reason.
3. Persist a trace-safe attribution record for analytics and operator debugging.

## 8. Business Rules

- Trace attribution must distinguish used, ignored, stale, and policy-blocked signals.
- Customer-facing surfaces cannot receive sensitive reasoning detail.
- Trace and analytics IDs must remain joinable across systems.

## 9. Configuration Model

- Signal Trace Attribution policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `signal_trace_attribution` primary record storing the current signal trace attribution state.
- `signal_trace_attribution_history` append-only history for lifecycle and trace reconstruction.
- `signal_trace_attribution_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/signals/traces/{traceId}
- POST /internal/signals/traces/search

## 12. Events Produced

- CustomerSignalTraceRecorded
- CustomerSignalTraceRedacted

## 13. Events Consumed

- RecommendationSetAssembled
- CustomerSignalBlockedByPolicy

## 14. Integrations

- Explainability trace service
- Analytics and experimentation
- Operator debugging UI

## 15. UI Components

- Signal attribution table
- Usage reason tooltip

## 16. UI Screens

- Recommendation trace detail
- Signal attribution search

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

- Metrics: request count, success rate, degraded rate, and freshness for signal trace attribution.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/signals/traces/{traceId}` with `Recommendation request context` and return `Trace records describing used and ignored signals` plus traceable metadata.
2. Event flow: consume `RecommendationSetAssembled` and emit `CustomerSignalTraceRecorded` after business rules and lifecycle checks pass.
3. Operator flow: use `Recommendation trace detail` to inspect or change signal trace attribution behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-signal-activation-service`, `customer-signal-activation-api`, and `signal-trace-attribution-worker` for async processing.
- Database tables or collections required: `signal_trace_attribution`, `signal_trace_attribution_history`, and `signal_trace_attribution_projection`.
- Jobs or workers required: `signal-trace-attribution-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Explainability trace service, Analytics and experimentation, Operator debugging UI.
- Frontend components required: Signal attribution table, Usage reason tooltip.
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

- How much signal-level detail should non-technical operators see?
- Which trace fields require redaction in cross-border support workflows?
