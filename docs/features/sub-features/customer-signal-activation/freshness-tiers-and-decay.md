# Freshness Tiers and Decay

## Parent Feature

- **Feature:** [Customer Signal Activation](../../customer-signal-activation.md)
- **Feature slug:** `customer-signal-activation`
- **Sub-feature slug:** `freshness-tiers-and-decay`
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

Group signals into freshness tiers and decay windows so recent behavior can influence recommendations without overpowering durable profile facts.

## 2. Core Concept

Freshness Tiers and Decay is the capability slice of **Customer Signal Activation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need freshness tiers and decay behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for freshness tiers and decay so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer signal activation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A newly classified signal arrives
- Freshness windows expire
- A recommendation request computes activation weights

## 5. Inputs

- Classified customer signals
- Freshness and decay policies
- Surface-specific activation rules

## 6. Outputs

- Signal freshness tier
- Decay-adjusted activation state
- Expiration or staleness annotation

## 7. Workflow / Lifecycle

1. Assign signals to freshness tiers such as active-session, operational, or profile-tier.
2. Apply decay and expiration policies over time.
3. Expose freshness-aware activation state to recommendation orchestration.

## 8. Business Rules

- Freshness windows must be explicit by signal type and surface.
- Expired signals remain auditable but cannot continue to affect ranking.
- Decay policies cannot override hard governance or consent constraints.

## 9. Configuration Model

- Freshness Tiers and Decay policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `freshness_tiers_and_decay` primary record storing the current freshness tiers and decay state.
- `freshness_tiers_and_decay_history` append-only history for lifecycle and trace reconstruction.
- `freshness_tiers_and_decay_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/signals/freshness/{signalId}
- POST /internal/signals/freshness/recompute

## 12. Events Produced

- CustomerSignalFreshnessEvaluated
- CustomerSignalExpired

## 13. Events Consumed

- CustomerSignalClassified
- FreshnessPolicyPublished

## 14. Integrations

- Recommendation orchestration
- Analytics pipeline
- Signal operations tooling

## 15. UI Components

- Freshness badge
- Decay trend sparkline

## 16. UI Screens

- Signal freshness report
- Customer activation timeline

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

- Metrics: request count, success rate, degraded rate, and freshness for freshness tiers and decay.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/signals/freshness/{signalId}` with `Classified customer signals` and return `Signal freshness tier` plus traceable metadata.
2. Event flow: consume `CustomerSignalClassified` and emit `CustomerSignalFreshnessEvaluated` after business rules and lifecycle checks pass.
3. Operator flow: use `Signal freshness report` to inspect or change freshness tiers and decay behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-signal-activation-service`, `customer-signal-activation-api`, and `freshness-tiers-and-decay-worker` for async processing.
- Database tables or collections required: `freshness_tiers_and_decay`, `freshness_tiers_and_decay_history`, and `freshness_tiers_and_decay_projection`.
- Jobs or workers required: `freshness-tiers-and-decay-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Recommendation orchestration, Analytics pipeline, Signal operations tooling.
- Frontend components required: Freshness badge, Decay trend sparkline.
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

- What are the initial decay windows for browse, cart, search, and purchase signals?
- Which surfaces need hard freshness cutoffs instead of continuous decay?
