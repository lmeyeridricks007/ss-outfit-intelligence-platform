# Sub-feature capability: Impression Policy And Server Fallback

**Parent feature:** `Analytics and experimentation`  
**Parent feature file:** `docs/features/analytics-and-experimentation.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/analytics-and-experimentation/`  
**Upstream traceability:** `docs/features/analytics-and-experimentation.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-010, BR-003, BR-002, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-006`, `DEC-007`)  
**Tracked open decisions:** `DEC-006`, `DEC-007`

---

## 1. Purpose

Govern impression semantics and server-side fallback emission so exposure measurement stays honest when browser instrumentation is blocked, delayed, or unsupported.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Analytics and experimentation` and owns one clear responsibility: govern impression semantics and server-side fallback emission so exposure measurement stays honest when browser instrumentation is blocked, delayed, or unsupported.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Analytics and experimentation` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Impression Policy And Server Fallback` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A recommendation module becomes visible in the client.
- Browser instrumentation is unavailable or degraded.
- A server-rendered or channel-driven surface requires an approved fallback policy.

## 5. Inputs

- surface visibility observations
- fallback policy settings
- delivery envelope metadata
- client capability and failure signals
- surface and channel scope

## 6. Outputs

- impression event or approved server fallback event
- event-source annotation
- fallback audit detail
- telemetry health alerts when fallback rates spike

## 7. Workflow / Lifecycle

1. Prefer client-side visibility detection when the surface supports it.
2. Determine whether a server fallback is allowed for the current surface and failure condition.
3. Emit the correct impression event with `eventSource` metadata.
4. Record fallback frequency and reason codes for monitoring.
5. Escalate when fallback usage exceeds safe thresholds or violates policy.

## 8. Business Rules

- Impression means visible exposure or an explicitly governed fallback, not mere API success.
- Experiment and governance context must be carried together so analysis does not misattribute lift or regressions.
- Stable recommendation-set IDs and trace IDs are required for trustworthy attribution and outcome joins.
- This capability must stay aligned with `docs/features/analytics-and-experimentation.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-006`, `DEC-007`.
- Stable `traceId` and `recommendationSetId` handling is required whenever the capability affects delivered recommendation behavior.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Trace, telemetry, and retention configuration for observability and audit.

## 10. Data Model

Primary entities:

- ImpressionPolicy
- VisibilityObservation
- ServerFallbackRecord
- EventSourceAnnotation
- FallbackHealthMetric

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /analytics/impressions
- POST /analytics/impressions/server-fallback

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- analytics.impression.recorded
- analytics.impression.server-fallback.recorded

## 13. Events Consumed

- surface.impression.detected
- browser.telemetry.failed
- delivery.envelope.packaged

## 14. Integrations

- shared contracts and delivery API
- ecommerce surface experiences
- channel expansion: email and clienteling
- identity and style profile
- merchandising governance and operator controls
- explainability and auditability
- commerce and order systems
- warehouse and reporting projections

## 15. UI Components

- experiment scorecards
- telemetry health cards
- event schema tables
- governance annotation filters

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- analytics dashboard
- experiment detail screen
- telemetry health console

## 17. Permissions & Security

- Restrict write operations to the service or operator role responsible for the capability.
- Expose only role-safe fields to support, operator, and consumer views.
- Keep audit fields on every state change that affects downstream recommendation behavior.

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

1. A request or upstream change triggers `Impression Policy And Server Fallback`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "impression-policy-and-server-fallback",
  "feature": "analytics-and-experimentation",
  "input": "surface visibility observations",
  "output": "impression event or approved server fallback event",
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

- Backend services: add or extend a `impression-policy-and-server-fallback` service boundary under the `analytics-and-experimentation` domain.
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
