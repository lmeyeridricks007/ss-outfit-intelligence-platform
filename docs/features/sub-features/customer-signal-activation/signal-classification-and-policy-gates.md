# Signal Classification and Policy Gates

## Parent Feature

- **Feature:** [Customer Signal Activation](../../customer-signal-activation.md)
- **Feature slug:** `customer-signal-activation`
- **Sub-feature slug:** `signal-classification-and-policy-gates`
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

Classify customer signals by activation policy so only approved signals influence recommendations.

## 2. Core Concept

Signal Classification and Policy Gates is the capability slice of **Customer Signal Activation** that turns the parent feature intent into a bounded implementation contract with explicit lifecycle, contracts, and operational behavior.

## 3. User Problems Solved

- Downstream teams need signal classification and policy gates behavior that is explicitly defined instead of inferred from the parent feature doc.
- Recommendation-serving paths need implementation-ready contracts for signal classification and policy gates so engineering does not guess at lifecycle or data semantics.
- Operators need auditable and debuggable behavior when customer signal activation affects recommendation quality, safety, or customer experience.

## 4. Trigger Conditions

- A normalized signal is ready for policy evaluation
- Policy definitions change
- A downstream system asks whether a signal is activation-safe

## 5. Inputs

- Normalized signal payloads
- Signal policy definitions
- Consent and data-usage constraints

## 6. Outputs

- Signal classification label
- Activation-safe or blocked decision
- Policy rationale for traceability

## 7. Workflow / Lifecycle

1. Evaluate each normalized signal against policy and consent rules.
2. Assign a classification such as allowed, gated, or disallowed.
3. Publish the decision to activation and explainability services.

## 8. Business Rules

- Policy gates must be explicit, versioned, and auditable.
- Disallowed signals cannot be silently downgraded into allowed classes.
- Classification reasons must be available for operator review without leaking sensitive content.

## 9. Configuration Model

- Signal Classification and Policy Gates policy version, rollout state, and owner metadata.
- Surface, channel, market, and mode scope where relevant.
- Thresholds, TTLs, ordering, or precedence controls derived from the business rules.
- Audit fields capturing who changed the configuration, why, and when it becomes active.

## 10. Data Model

- `signal_classification_and_policy_gates` primary record storing the current signal classification and policy gates state.
- `signal_classification_and_policy_gates_history` append-only history for lifecycle and trace reconstruction.
- `signal_classification_and_policy_gates_projection` read model optimized for downstream serving or operator lookup.
- Stable identifiers and source provenance fields aligned with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal contracts; final URI and auth details belong to the architecture stage.

- POST /internal/signals/classify
- GET /internal/signals/policies

## 12. Events Produced

- CustomerSignalClassified
- CustomerSignalBlockedByPolicy

## 13. Events Consumed

- CustomerSignalNormalized
- SignalPolicyPublished

## 14. Integrations

- Consent policy service
- Recommendation orchestration
- Explainability trace service

## 15. UI Components

- Policy reason badge
- Classification review panel

## 16. UI Screens

- Signal policy administration
- Blocked signal detail page

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

- Metrics: request count, success rate, degraded rate, and freshness for signal classification and policy gates.
- Structured logs with stable IDs for inputs, outputs, rule hits, and failure categories.
- Distributed traces that join upstream request IDs to downstream events and operator actions.
- Dashboards and alerts for sustained degradation, schema drift, or policy violations.

## 22. Example Scenarios

1. API flow: call `POST /internal/signals/classify` with `Normalized signal payloads` and return `Signal classification label` plus traceable metadata.
2. Event flow: consume `CustomerSignalNormalized` and emit `CustomerSignalClassified` after business rules and lifecycle checks pass.
3. Operator flow: use `Signal policy administration` to inspect or change signal classification and policy gates behavior, then verify the outcome in the linked trace or health view.

## 23. Implementation Notes

- Backend services involved: `customer-signal-activation-service`, `customer-signal-activation-api`, and `signal-classification-and-policy-gates-worker` for async processing.
- Database tables or collections required: `signal_classification_and_policy_gates`, `signal_classification_and_policy_gates_history`, and `signal_classification_and_policy_gates_projection`.
- Jobs or workers required: `signal-classification-and-policy-gates-worker`, nightly reconciliation, and replay tooling for operational recovery.
- External APIs or systems required: Consent policy service, Recommendation orchestration, Explainability trace service.
- Frontend components required: Policy reason badge, Classification review panel.
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

- Which policy-gated signals can become allowed after legal review?
- Do some surfaces require stricter signal classes than others at launch?
