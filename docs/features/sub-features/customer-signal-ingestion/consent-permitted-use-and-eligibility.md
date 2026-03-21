# Sub-feature capability: Consent Permitted Use And Eligibility

**Parent feature:** `Customer signal ingestion`  
**Parent feature file:** `docs/features/customer-signal-ingestion.md`  
**Parent feature priority:** `P2`  
**Sub-feature directory:** `docs/features/sub-features/customer-signal-ingestion/`  
**Upstream traceability:** `docs/features/customer-signal-ingestion.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-006, BR-010, BR-012); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`)  
**Tracked open decisions:** `DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`

---

## 1. Purpose

Evaluate whether a signal may be stored, analyzed, or activated for recommendation use according to consent, regional policy, and channel-specific permitted-use rules.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Customer signal ingestion` and owns one clear responsibility: evaluate whether a signal may be stored, analyzed, or activated for recommendation use according to consent, regional policy, and channel-specific permitted-use rules.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Customer signal ingestion` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Consent Permitted Use And Eligibility` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A new signal envelope is ready for eligibility evaluation.
- Consent or privacy policy changes affect stored signals.
- A downstream consumer requests activation-safe signal projections.

## 5. Inputs

- customer-signal envelope
- consent state and region
- permitted-use policy matrix
- channel and purpose of use
- identity confidence when applicable

## 6. Outputs

- signal eligibility record
- permitted-use state
- activation-blocking reason codes
- analytics-only or quarantined classifications

## 7. Workflow / Lifecycle

1. Look up the current consent and policy context for the signal subject and region.
2. Evaluate whether the signal is allowed for storage, analytics, session use, or durable activation.
3. Persist the resulting eligibility state and reason codes.
4. Prevent downstream activation when policy prohibits it.
5. Re-evaluate signals when consent or regulatory state changes.

## 8. Business Rules

- Signals must remain governed by family, freshness, and permitted-use state rather than being treated as universally reliable profile truth.
- Consent and permitted use are hard gating rules for activation, not downstream suggestions.
- Session-safe signal use and durable profile-safe signal use must remain distinct because identity confidence and privacy rules differ.
- This capability must stay aligned with `docs/features/customer-signal-ingestion.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`.
- Customer data usage must degrade safely when consent, identity confidence, or allowed-use scope is insufficient.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Identity-confidence, consent, and permitted-use thresholds.

## 10. Data Model

Primary entities:

- SignalEligibility
- PermittedUseState
- ConsentDecisionRecord
- EligibilityReasonCode
- PolicyMatrixReference

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /signals/eligibility/evaluate
- GET /signals/{signalId}/eligibility

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- signal.eligibility.updated
- signal.activation.blocked

## 13. Events Consumed

- signal.ingested
- privacy.policy.updated
- consent.state.changed

## 14. Integrations

- commerce and order-management systems
- web and app telemetry
- email and CRM systems
- POS and appointment systems
- identity and style profile
- analytics and experimentation
- explainability and auditability

## 15. UI Components

- signal lineage tables
- quarantine review cards
- projection freshness badges
- consent eligibility chips

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- signal operations console
- customer signal detail page
- quarantine review queue

## 17. Permissions & Security

- Restrict write operations to the service or operator role responsible for the capability.
- Expose only role-safe fields to support, operator, and consumer views.
- Keep audit fields on every state change that affects downstream recommendation behavior.
- Treat identity, profile, and trace detail as sensitive data; apply redaction and access logging.

## 18. Error Handling

- Reject malformed requests or invalid references with structured validation errors and reason codes.
- Distinguish degraded or partial success from hard failure whenever the capability can still produce a safe output.
- Preserve traceability for failures so support and analytics can correlate them later.
- Downgrade or block activation when identity or consent checks fail instead of leaking sensitive data.

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

## 22. Example Scenarios

### Scenario A: Typical happy-path execution

1. A request or upstream change triggers `Consent Permitted Use And Eligibility`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "consent-permitted-use-and-eligibility",
  "feature": "customer-signal-ingestion",
  "input": "customer-signal envelope",
  "output": "signal eligibility record",
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

- Backend services: add or extend a `consent-permitted-use-and-eligibility` service boundary under the `customer-signal-ingestion` domain.
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
- Privacy and permission tests that verify redaction, gating, and revocation behavior.
