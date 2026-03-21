# Compatibility and Exclusion Rules

## Parent Feature

- **Feature:** [Look Graph and Compatibility](../../look-graph-and-compatibility.md)
- **Feature slug:** `look-graph-and-compatibility`
- **Sub-feature slug:** `compatibility-and-exclusion-rules`
- **Priority inheritance:** P0
- **Primary downstream stage:** Technical architecture and implementation planning

## Traceability / Sources

The following documents are the source of truth for this sub-feature capability specification:

- `docs/features/look-graph-and-compatibility.md`
- `docs/project/br/br-001-complete-look-recommendation-capability.md`
- `docs/project/br/br-002-multi-type-recommendation-support.md`
- `docs/project/br/br-004-rtw-and-cm-support.md`
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`
- `docs/project/br/br-011-explainability-and-auditability.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## 1. Purpose

Apply hard and soft compatibility rules so invalid combinations are blocked and valid combinations carry explicit rationale.

## 2. Core Concept

Compatibility and Exclusion Rules is the capability slice of **Look Graph and Compatibility** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need compatibility and exclusion rules behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for compatibility and exclusion rules so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when look graph and compatibility affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A compatibility rule is created or changed
- A recommendation candidate pair needs evaluation
- A look publication validation run starts

## 5. Inputs

- Canonical product attributes
- Compatibility rule definitions
- Pair or bundle candidates

## 6. Outputs

- Compatibility decision
- Exclusion or downgrade reason
- Rule-hit metadata

## 7. Workflow / Lifecycle

1. Load the active rule set for the product pair or bundle under evaluation.
2. Apply hard exclusions before any soft influence scoring.
3. Return the decision with rule identifiers for traceability.

## 8. Business Rules

- Hard exclusions must be deterministic and unskippable.
- Soft compatibility signals cannot resurrect hard-failed combinations.
- Rule conflicts require deterministic precedence and auditability.

## 9. Configuration Model

- Compatibility and Exclusion Rules policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `compatibility_and_exclusion_rules` primary record storing the current compatibility and exclusion rules state.
- `compatibility_and_exclusion_rules_history` append-only history for lifecycle and trace reconstruction.
- `compatibility_and_exclusion_rules_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/compatibility/evaluate
- GET /internal/compatibility/rules

## 12. Events Produced

- CompatibilityEvaluated
- CompatibilityRuleChanged

## 13. Events Consumed

- CatalogAttributesGoverned
- GovernanceObjectPublished

## 14. Integrations

- Merchandising governance
- Recommendation orchestration
- Explainability trace service

## 15. UI Components

- Rule precedence table
- Compatibility result badge

## 16. UI Screens

- Compatibility rule admin
- Pair evaluation preview

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

- Metrics: request count, success rate, degraded rate, and freshness for compatibility and exclusion rules.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/compatibility/evaluate` with `Canonical product attributes` and return `Compatibility decision` plus traceable metadata.
2. Event flow: consume `CatalogAttributesGoverned` and emit `CompatibilityEvaluated` after business rules and lifecycle checks pass.
3. Operator flow: use `Compatibility rule admin` to inspect or change compatibility and exclusion rules behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `look-graph-and-compatibility-service`, `look-graph-and-compatibility-api`, and `compatibility-and-exclusion-rules-worker` for async processing.
- Database tables or collections required: `compatibility_and_exclusion_rules`, `compatibility_and_exclusion_rules_history`, and `compatibility_and_exclusion_rules_projection`.
- Jobs or workers required: `compatibility-and-exclusion-rules-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Merchandising governance, Recommendation orchestration, Explainability trace service.
- Frontend components required: Rule precedence table, Compatibility result badge.
- Shared UI components required: status badges, audit timeline, trace drawer.
- Final contract shapes, storage choices, and deployment boundaries belong to the architecture stage, but the capability contract in this spec should remain stable.

## 24. Testing Requirements

- Unit tests for business rules, state transitions, and invalid input handling.
- Contract tests for APIs, event payloads, and read-model shape stability.
- Integration tests covering happy path, degraded path, and replay or retry behavior.
- Permission and redaction tests wherever operator or downstream access differs by role or channel.
- Observability assertions for key metrics, reason codes, and alert-triggering conditions.

## Assumptions

- The parent feature deep-dive (`docs/features/look-graph-and-compatibility.md`) remains the source of truth for scope and terminology.
- API paths, event names, and table names in this spec are implementation-oriented examples that the architecture stage may refine without changing the capability boundary.
- Open questions are intentionally recorded rather than guessed so downstream stages can resolve them explicitly.

## Open Questions / Missing Decisions

- Which rule conflicts require explicit operator resolution instead of automatic precedence?
- How should missing attribute values affect compatibility in early phases?
