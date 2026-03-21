# Sub-feature capability: Activation Envelope Evaluation

**Parent feature:** `Identity and style profile`  
**Parent feature file:** `docs/features/identity-and-style-profile.md`  
**Parent feature priority:** `P2`  
**Sub-feature directory:** `docs/features/sub-features/identity-and-style-profile/`  
**Upstream traceability:** `docs/features/identity-and-style-profile.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-012, BR-006, BR-011, BR-003); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-030`, `DEC-031`, `DEC-032`, `DEC-033`)  
**Tracked open decisions:** `DEC-030`, `DEC-031`, `DEC-032`, `DEC-033`

---

## 1. Purpose

Evaluate how much identity and profile data may influence a specific recommendation request by producing an activation envelope that reflects confidence, consent, channel, and purpose of use.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Identity and style profile` and owns one clear responsibility: evaluate how much identity and profile data may influence a specific recommendation request by producing an activation envelope that reflects confidence, consent, channel, and purpose of use.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Identity and style profile` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Activation Envelope Evaluation` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A recommendation request includes customer or session context.
- A channel or surface has a bounded allowed-use profile policy.
- A support or trace flow needs to understand why personalization was or was not active.

## 5. Inputs

- canonical customer identity and confidence
- profile snapshot reference
- channel, surface, and recommendation purpose
- consent and suppression state
- allowed profile-domain policy

## 6. Outputs

- activation envelope record
- personalization mode (`full_profile`, `bounded_profile`, `session_only`, or `none`)
- restriction codes
- traceable activation decision rationale

## 7. Workflow / Lifecycle

1. Read identity, consent, profile, and channel policy for the current request.
2. Determine the maximum allowed personalization posture for the request.
3. Attach any domain restrictions, suppressions, or confidence-based limits.
4. Emit the activation envelope for ranking, delivery, and trace systems.
5. Retain the envelope for audit and analytics joins.

## 8. Business Rules

- Canonical identity, style profile, and activation envelope are separate concepts and must not collapse into one opaque customer record.
- Consent and allowed profile domains are hard constraints before personalization or suppression logic executes.
- Absence of evidence is not equivalent to a dislike signal; durable suppressions require stronger evidence and policy support.
- This capability must stay aligned with `docs/features/identity-and-style-profile.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-030`, `DEC-031`, `DEC-032`, `DEC-033`.
- Customer data usage must degrade safely when consent, identity confidence, or allowed-use scope is insufficient.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Identity-confidence, consent, and permitted-use thresholds.

## 10. Data Model

Primary entities:

- ActivationEnvelope
- PersonalizationMode
- RestrictionCode
- ActivationDecisionRecord
- AllowedDomainSet

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /profiles/evaluate-activation
- GET /profiles/activation/{activationEnvelopeId}

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- identity.activation.evaluated

## 13. Events Consumed

- profile.snapshot.computed
- privacy.policy.updated
- consent.state.changed

## 14. Integrations

- customer signal ingestion
- shared contracts and delivery API
- recommendation decisioning and ranking
- analytics and experimentation
- explainability and auditability
- channel expansion: email and clienteling
- context engine and personalization

## 15. UI Components

- identity case queue
- profile summary cards
- activation envelope inspector
- suppression history tables

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- identity review console
- profile snapshot detail
- customer suppression management screen

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
- Conflicted identity or low-confidence links require safe fallback instead of speculative personalization.

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

1. A request or upstream change triggers `Activation Envelope Evaluation`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "activation-envelope-evaluation",
  "feature": "identity-and-style-profile",
  "input": "canonical customer identity and confidence",
  "output": "activation envelope record",
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

- Backend services: add or extend a `activation-envelope-evaluation` service boundary under the `identity-and-style-profile` domain.
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
