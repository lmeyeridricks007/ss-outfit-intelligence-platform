# Consent Suppression Profile Facets

## Parent Feature

- **Feature:** [Customer Identity and Profile](../../customer-identity-and-profile.md)
- **Feature slug:** `customer-identity-and-profile`
- **Sub-feature slug:** `consent-suppression-profile-facets`
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

Project only consent-approved and suppression-aware customer profile facets into recommendation-serving paths.

## 2. Core Concept

Consent Suppression Profile Facets is the capability slice of **Customer Identity and Profile** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need consent suppression profile facets behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for consent suppression profile facets so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer identity and profile affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- Consent or privacy preferences change
- A source profile feed updates customer facets
- A recommendation-serving path requests profile activation data

## 5. Inputs

- Consent state
- Profile source facets
- Suppression and retention policies

## 6. Outputs

- Approved profile facet bundle
- Suppression flags
- Retention-aware activation record

## 7. Workflow / Lifecycle

1. Evaluate customer facets against the latest consent and suppression rules.
2. Filter or transform disallowed facets for activation-safe use.
3. Publish a profile facet projection with explicit provenance and retention metadata.

## 8. Business Rules

- Disallowed facets may be retained for audit only when policy permits.
- Suppression must propagate before the next recommendation-serving decision.
- Profile projections must preserve source provenance and consent reason codes.

## 9. Configuration Model

- Consent Suppression Profile Facets policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `consent_suppression_profile_facets` primary record storing the current consent suppression profile facets state.
- `consent_suppression_profile_facets_history` append-only history for lifecycle and trace reconstruction.
- `consent_suppression_profile_facets_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- GET /internal/profile/customers/{canonicalCustomerId}/facets
- POST /internal/profile/consent/re-evaluate

## 12. Events Produced

- CustomerProfileFacetsProjected
- CustomerConsentSuppressionApplied

## 13. Events Consumed

- CustomerConsentChanged
- CustomerProfileImported

## 14. Integrations

- Consent management platform
- CRM or CDP
- Recommendation profile projection service

## 15. UI Components

- Consent status badge
- Profile facet inspector

## 16. UI Screens

- Customer privacy console
- Profile activation detail page

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

- Metrics: request count, success rate, degraded rate, and freshness for consent suppression profile facets.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `GET /internal/profile/customers/{canonicalCustomerId}/facets` with `Consent state` and return `Approved profile facet bundle` plus traceable metadata.
2. Event flow: consume `CustomerConsentChanged` and emit `CustomerProfileFacetsProjected` after business rules and lifecycle checks pass.
3. Operator flow: use `Customer privacy console` to inspect or change consent suppression profile facets behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-identity-and-profile-service`, `customer-identity-and-profile-api`, and `consent-suppression-profile-facets-worker` for async processing.
- Database tables or collections required: `consent_suppression_profile_facets`, `consent_suppression_profile_facets_history`, and `consent_suppression_profile_facets_projection`.
- Jobs or workers required: `consent-suppression-profile-facets-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Consent management platform, CRM or CDP, Recommendation profile projection service.
- Frontend components required: Consent status badge, Profile facet inspector.
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

- Which profile facets are activation-safe in each region at launch?
- How should operator tooling display suppressed-but-retained fields?
