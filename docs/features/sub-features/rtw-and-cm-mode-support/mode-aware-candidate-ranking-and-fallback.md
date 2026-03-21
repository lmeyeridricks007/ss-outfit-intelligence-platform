# Sub-feature capability: Mode Aware Candidate Ranking And Fallback

**Parent feature:** `RTW and CM mode support`  
**Parent feature file:** `docs/features/rtw-and-cm-mode-support.md`  
**Parent feature priority:** `P1 (RTW) / P4 (CM depth)`  
**Sub-feature directory:** `docs/features/sub-features/rtw-and-cm-mode-support/`  
**Upstream traceability:** `docs/features/rtw-and-cm-mode-support.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-004, BR-008, BR-005, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-012`, `DEC-015`, `DEC-016`, `DEC-017`, `DEC-025`, `DEC-027`, `DEC-036`)  
**Tracked open decisions:** `DEC-012`, `DEC-015`, `DEC-016`, `DEC-017`, `DEC-025`, `DEC-027`, `DEC-036`

---

## 1. Purpose

Apply mode-aware ranking objectives, candidate constraints, and fallback behavior so RTW and CM recommendations stay truthful to different shopping missions without forking the platform.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `RTW and CM mode support` and owns one clear responsibility: apply mode-aware ranking objectives, candidate constraints, and fallback behavior so rtw and cm recommendations stay truthful to different shopping missions without forking the platform.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `RTW and CM mode support` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Mode Aware Candidate Ranking And Fallback` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A ranking mission is selected with explicit mode context.
- Fallback or degraded-state logic differs for RTW and CM.
- Governance or curated ordering policy changes by mode or surface.

## 5. Inputs

- mode-normalized request
- ranking mission and governed candidate pool
- mode-specific eligibility and fallback policy
- configuration snapshot when relevant
- surface and channel context

## 6. Outputs

- mode-aware ranked result
- mode-specific fallback annotations
- operator-review-required markers for CM
- mode-sliced source-mix and telemetry metadata

## 7. Workflow / Lifecycle

1. Receive the ranking mission with explicit mode and candidate context.
2. Apply mode-specific ranking objectives and hard constraints.
3. Choose fallback or degraded behavior appropriate for RTW or CM.
4. Preserve shared identifiers and recommendation semantics in the final output.
5. Publish mode-aware trace and analytics records.

## 8. Business Rules

- Mode must be explicit end-to-end in request, response, telemetry, and trace contracts.
- Customer-facing CM behavior requires stricter evidence and explanation controls than baseline RTW behavior.
- Shared delivery and governance semantics stay common across modes, while eligibility, fallback, and explanation depth remain mode-aware.
- This capability must stay aligned with `docs/features/rtw-and-cm-mode-support.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-012`, `DEC-015`, `DEC-016`, `DEC-017`, `DEC-025`, `DEC-027`, `DEC-036`.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Mode-specific minimum evidence and fallback rules.

## 10. Data Model

Primary entities:

- ModeAwareRankingResult
- ModeFallbackDecision
- ConfigurationInfluenceRecord
- ModeSourceMixSummary
- OperatorReviewRequirement

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /decisioning/rank
- POST /decisioning/fallback

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- mode.ranking.completed
- mode.fallback.applied

## 13. Events Consumed

- mode.normalized
- decisioning.governance.applied
- cm.configuration.validated

## 14. Integrations

- shared contracts and delivery API
- catalog and product intelligence
- recommendation decisioning and ranking
- merchandising governance and operator controls
- explainability and auditability
- channel expansion: email and clienteling
- ecommerce surface experiences
- identity and style profile

## 15. UI Components

- mode badges
- CM configuration summaries
- operator review required banners
- mode-sliced reporting filters

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- RTW PDP or cart modules
- CM clienteling session view
- mode policy admin screen

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

1. A request or upstream change triggers `Mode Aware Candidate Ranking And Fallback`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "mode-aware-candidate-ranking-and-fallback",
  "feature": "rtw-and-cm-mode-support",
  "input": "mode-normalized request",
  "output": "mode-aware ranked result",
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

- Backend services: add or extend a `mode-aware-candidate-ranking-and-fallback` service boundary under the `rtw-and-cm-mode-support` domain.
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
