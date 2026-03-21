# Sub-feature capability: Experiment Context In Traces

**Parent feature:** `Explainability and auditability`  
**Parent feature file:** `docs/features/explainability-and-auditability.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/explainability-and-auditability/`  
**Upstream traceability:** `docs/features/explainability-and-auditability.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-011, BR-009, BR-010, BR-012); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-011`, `DEC-025`, `DEC-026`, `DEC-027`, `DEC-028`, `DEC-029`)  
**Tracked open decisions:** `DEC-011`, `DEC-025`, `DEC-026`, `DEC-027`, `DEC-028`, `DEC-029`

---

## 1. Purpose

Record experiment assignments and holdout context in traces so operators can tell whether observed recommendation behavior reflects product logic, experimentation, or governance changes.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Explainability and auditability` and owns one clear responsibility: record experiment assignments and holdout context in traces so operators can tell whether observed recommendation behavior reflects product logic, experimentation, or governance changes.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Explainability and auditability` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Experiment Context In Traces` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A recommendation request is subject to an experiment or holdout.
- A trace is generated for a recommendation set affected by experimentation.
- A reviewer needs to compare behavior across variants in trace detail.

## 5. Inputs

- experiment assignment records
- delivery and ranking trace context
- holdout and variant metadata
- trace ID and recommendation-set ID
- redaction rules for operator visibility

## 6. Outputs

- trace experiment context block
- variant and holdout references in trace views
- experiment-linked search metadata
- cross-variant comparison hints

## 7. Workflow / Lifecycle

1. Read the experiment assignment associated with the recommendation request.
2. Embed variant, holdout, and experiment identifiers into the trace payload.
3. Index the trace so experiment-filtered lookups are possible.
4. Respect redaction policy for roles that should not see sensitive experiment detail.
5. Expose the context in trace viewers and audit exports.

## 8. Business Rules

- Every meaningful recommendation set must be reconstructable by trace ID and recommendation-set ID.
- Trace depth is role-bound and privacy-safe; customer-facing explanation depth is intentionally shallower than internal diagnostic detail.
- Historical trace references must point to versioned governance, profile, and experiment context rather than current mutable state only.
- This capability must stay aligned with `docs/features/explainability-and-auditability.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-011`, `DEC-025`, `DEC-026`, `DEC-027`, `DEC-028`, `DEC-029`.
- Stable `traceId` and `recommendationSetId` handling is required whenever the capability affects delivered recommendation behavior.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Approval, precedence, and publication schedule settings.
- Trace, telemetry, and retention configuration for observability and audit.

## 10. Data Model

Primary entities:

- TraceExperimentContext
- VariantReference
- HoldoutReference
- ExperimentFilterIndex
- VariantComparisonHint

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- GET /traces/{traceId}/experiments
- GET /traces/search?experimentId={experimentId}

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- trace.experiment.context.linked

## 13. Events Consumed

- experiment.assignment.created
- trace.record.created

## 14. Integrations

- shared contracts and delivery API
- recommendation decisioning and ranking
- merchandising governance and operator controls
- analytics and experimentation
- identity and style profile
- ecommerce surface experiences
- channel expansion: email and clienteling
- weather and market-calendar providers

## 15. UI Components

- trace timeline
- governance context panels
- redaction badges
- export bundle actions

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- trace search screen
- trace detail screen
- audit export screen

## 17. Permissions & Security

- Restrict write operations to the service or operator role responsible for the capability.
- Expose only role-safe fields to support, operator, and consumer views.
- Keep audit fields on every state change that affects downstream recommendation behavior.
- Treat identity, profile, and trace detail as sensitive data; apply redaction and access logging.
- Use separation-of-duty and approval checks where policy marks the control as high risk.

## 18. Error Handling

- Reject malformed requests or invalid references with structured validation errors and reason codes.
- Distinguish degraded or partial success from hard failure whenever the capability can still produce a safe output.
- Preserve traceability for failures so support and analytics can correlate them later.

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

1. A request or upstream change triggers `Experiment Context In Traces`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "experiment-context-in-traces",
  "feature": "explainability-and-auditability",
  "input": "experiment assignment records",
  "output": "trace experiment context block",
  "traceId": "trace_example_001",
  "recommendationSetId": "set_example_001"
}
```

## 23. Implementation Notes

- Backend services should own the business logic and expose read-optimized contracts to downstream consumers.
- Persist versioned records or snapshots rather than mutating the effective truth in place when the capability affects delivery or audit.
- Use background jobs or stream consumers where the capability depends on ingestion, projections, or recomputation.
- Prefer stable canonical IDs from `docs/project/data-standards.md` for products, customers, looks, rules, campaigns, experiments, and recommendation sets.
- Retain enough lineage to join behavior back to source events, governance snapshots, and outcomes without rereading raw logs.

Specific implementation implications for this capability:

- Backend services: add or extend a `experiment-context-in-traces` service boundary under the `explainability-and-auditability` domain.
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
