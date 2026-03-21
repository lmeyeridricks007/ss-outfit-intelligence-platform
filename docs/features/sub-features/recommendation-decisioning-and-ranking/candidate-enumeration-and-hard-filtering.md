# Sub-feature capability: Candidate Enumeration And Hard Filtering

**Parent feature:** `Recommendation decisioning and ranking`  
**Parent feature file:** `docs/features/recommendation-decisioning-and-ranking.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/recommendation-decisioning-and-ranking/`  
**Upstream traceability:** `docs/features/recommendation-decisioning-and-ranking.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-005, BR-002, BR-001, BR-008, BR-010, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-008`, `DEC-015`, `DEC-016`, `DEC-036`)  
**Tracked open decisions:** `DEC-008`, `DEC-015`, `DEC-016`, `DEC-036`

---

## 1. Purpose

Enumerate candidates from curated, rule-based, and learned sources and then apply hard catalog, inventory, consent, compatibility, and suppression rules before scoring begins.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Recommendation decisioning and ranking` and owns one clear responsibility: enumerate candidates from curated, rule-based, and learned sources and then apply hard catalog, inventory, consent, compatibility, and suppression rules before scoring begins.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Recommendation decisioning and ranking` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Candidate Enumeration And Hard Filtering` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A decision mission needs an eligible candidate pool.
- Catalog or governance projections change candidate availability.
- A request has privacy, identity, or consent constraints that narrow the pool.

## 5. Inputs

- decision mission and objective
- catalog eligibility projections
- curated look and rule outputs
- identity, context, and consent envelopes
- governance snapshot and suppression rules

## 6. Outputs

- eligible candidate pool
- rejected candidate records with reason codes
- source lineage for remaining candidates
- counts and coverage metrics for downstream ranking

## 7. Workflow / Lifecycle

1. Load candidates from all configured sources that apply to the current mission.
2. Normalize candidates into a shared internal representation with lineage attached.
3. Apply hard filters for readiness, compatibility, consent, inventory, and suppressions.
4. Emit the eligible pool and detailed rejection reasons.
5. Forward the filtered pool to ordering-freedom and scoring logic.

## 8. Business Rules

- AI ranking operates inside governed candidate and ordering bounds; it does not define the contract or bypass hard rules.
- Recommendation objectives must be selected by recommendation type, surface, and mode instead of reused blindly across all missions.
- Delivery consumers must not locally rerank the ordered result returned by this feature.
- This capability must stay aligned with `docs/features/recommendation-decisioning-and-ranking.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-008`, `DEC-015`, `DEC-016`, `DEC-036`.
- Customer data usage must degrade safely when consent, identity confidence, or allowed-use scope is insufficient.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Freshness windows and degraded-state thresholds for inventory or package reuse.
- Identity-confidence, consent, and permitted-use thresholds.

## 10. Data Model

Primary entities:

- CandidateSeed
- EligibleCandidate
- RejectedCandidate
- CandidateLineage
- HardFilterReason

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /decisioning/candidates/enumerate
- POST /decisioning/candidates/filter

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- decisioning.candidates.ready
- decisioning.candidates.rejected

## 13. Events Consumed

- catalog.eligibility.updated
- governance.snapshot.published
- identity.activation.evaluated

## 14. Integrations

- catalog and product intelligence
- complete-look orchestration
- merchandising governance and operator controls
- shared contracts and delivery API
- analytics and experimentation
- explainability and auditability
- identity and style profile
- context engine and personalization
- RTW and CM mode support

## 15. UI Components

- ranking explanation badges
- candidate comparison tables
- source-mix chips
- override precedence indicators

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- operator ranking debugger
- campaign and ranking comparison screen
- support decision trace detail

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

1. A request or upstream change triggers `Candidate Enumeration And Hard Filtering`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "candidate-enumeration-and-hard-filtering",
  "feature": "recommendation-decisioning-and-ranking",
  "input": "decision mission and objective",
  "output": "eligible candidate pool",
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

- Backend services: add or extend a `candidate-enumeration-and-hard-filtering` service boundary under the `recommendation-decisioning-and-ranking` domain.
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
