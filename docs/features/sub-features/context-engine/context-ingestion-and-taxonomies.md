# Context Ingestion and Taxonomies

## Parent Feature

- **Feature:** [Context Engine](../../context-engine.md)
- **Feature slug:** `context-engine`
- **Sub-feature slug:** `context-ingestion-and-taxonomies`
- **Priority inheritance:** P1
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/context-engine.md`
- `docs/project/br/br-007-context-aware-logic.md`
- `docs/project/business-requirements.md`
- `docs/project/data-standards.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Ingest geographic, temporal, weather, and occasion context into shared taxonomies that recommendation services can use consistently.

## 2. Core Concept

Context Ingestion and Taxonomies is the capability slice of **Context Engine** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need context ingestion and taxonomies behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for context ingestion and taxonomies so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when context engine affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A request provides explicit context values
- A provider feed updates weather or calendar data
- Context taxonomies are revised

## 5. Inputs

- Request context fields
- Weather and calendar provider data
- Context taxonomy definitions

## 6. Outputs

- Normalized context attributes
- Taxonomy-aligned context codes
- Context provenance metadata

## 7. Workflow / Lifecycle

1. Ingest explicit request context and provider-derived context inputs.
2. Normalize values into governed taxonomies and stable codes.
3. Publish normalized context attributes for snapshot assembly and tracing.

## 8. Business Rules

- Taxonomies must support market-specific variations without changing stable codes.
- Explicit request context cannot be overwritten by weak inferred values.
- Provider-derived context must preserve confidence and freshness metadata.

## 9. Configuration Model

- Context Ingestion and Taxonomies policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `context_ingestion_and_taxonomies` primary record storing the current context ingestion and taxonomies state.
- `context_ingestion_and_taxonomies_history` append-only history for lifecycle and trace reconstruction.
- `context_ingestion_and_taxonomies_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/context/normalize
- GET /internal/context/taxonomies

## 12. Events Produced

- ContextNormalized
- ContextTaxonomyUpdated

## 13. Events Consumed

- ContextRequestReceived
- ProviderContextUpdated

## 14. Integrations

- Weather provider
- Calendar or holiday service
- Delivery API request contract

## 15. UI Components

- Context taxonomy table
- Context source badge

## 16. UI Screens

- Context taxonomy admin
- Context normalization preview

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

- Metrics: request count, success rate, degraded rate, and freshness for context ingestion and taxonomies.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/context/normalize` with `Request context fields` and return `Normalized context attributes` plus traceable metadata.
2. Event flow: consume `ContextRequestReceived` and emit `ContextNormalized` after business rules and lifecycle checks pass.
3. Operator flow: use `Context taxonomy admin` to inspect or change context ingestion and taxonomies behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `context-engine-service`, `context-engine-api`, and `context-ingestion-and-taxonomies-worker` for async processing.
- Database tables or collections required: `context_ingestion_and_taxonomies`, `context_ingestion_and_taxonomies_history`, and `context_ingestion_and_taxonomies_projection`.
- Jobs or workers required: `context-ingestion-and-taxonomies-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Weather provider, Calendar or holiday service, Delivery API request contract.
- Frontend components required: Context taxonomy table, Context source badge.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/context-engine.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Who owns regional calendar and occasion taxonomy updates?
- What location granularity is allowed for each market?
