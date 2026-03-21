# Sub-feature capability: Cart Duplicate Suppression And Multi Anchor Handling

**Parent feature:** `Complete-look orchestration`  
**Parent feature file:** `docs/features/complete-look-orchestration.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/complete-look-orchestration/`  
**Upstream traceability:** `docs/features/complete-look-orchestration.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-001, BR-002, BR-005, BR-008); `docs/project/glossary.md` (`look` vs `outfit`); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-018`, `DEC-019`, `DEC-020`)  
**Tracked open decisions:** `DEC-018`, `DEC-019`, `DEC-020`

---

## 1. Purpose

Suppress duplicates already represented in cart or anchor context and resolve multi-anchor cases so complete-look answers stay useful instead of repeating what the shopper already has.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Complete-look orchestration` and owns one clear responsibility: suppress duplicates already represented in cart or anchor context and resolve multi-anchor cases so complete-look answers stay useful instead of repeating what the shopper already has.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Complete-look orchestration` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Cart Duplicate Suppression And Multi Anchor Handling` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- Cart context introduces exact or near-duplicate members.
- Multiple plausible lead items could seed an outfit.
- An assisted-selling or occasion flow mixes more than one anchor intent.

## 5. Inputs

- cart or session contents
- assembled outfit members
- duplicate-suppression policy
- anchor precedence policy
- surface and mode context

## 6. Outputs

- duplicate-suppressed outfit assembly
- primary-anchor selection record
- suppression reason codes
- reordered or reduced slot plan for final delivery

## 7. Workflow / Lifecycle

1. Compare outfit members to current cart or request context.
2. Remove or demote exact duplicates according to recommendation-type policy.
3. Choose the primary anchor when multiple anchors remain plausible.
4. Re-check slot coverage after suppression or anchor changes.
5. Emit final grouped assembly metadata for delivery and analytics.

## 8. Business Rules

- Internal look semantics and customer-facing outfit semantics must remain distinct and explicitly labeled.
- A degraded outfit must still read as a coherent complete-look answer, not a flat list of adjacent items.
- Anchor preservation and slot completeness rules may vary by surface or mode, but they must be policy-driven and traceable.
- This capability must stay aligned with `docs/features/complete-look-orchestration.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-018`, `DEC-019`, `DEC-020`.
- Internal `look` semantics and customer-facing `outfit` semantics must remain distinct where grouped recommendation meaning matters.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.

## 10. Data Model

Primary entities:

- DuplicateSuppressionRecord
- PrimaryAnchorDecision
- CartComparisonResult
- AdjustedSlotPlan
- SuppressionReasonCode

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /outfits/adjust-for-cart
- POST /outfits/select-primary-anchor

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- outfit.duplicate.suppressed
- outfit.primary-anchor.selected

## 13. Events Consumed

- cart.context.updated
- outfit.validation.passed
- identity.profile.resolved

## 14. Integrations

- catalog and product intelligence
- shared contracts and delivery API
- recommendation decisioning and ranking
- merchandising governance and operator controls
- analytics and experimentation
- explainability and auditability
- RTW and CM mode support

## 15. UI Components

- outfit slot cards
- grouped look preview panels
- assembly validation badges
- substitution explanation chips

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- operator outfit preview screen
- support assembly trace detail
- merchandising look validation screen

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
- Multiple lead items or duplicate candidates require deterministic tie-breaking.

## 20. Performance Considerations

- Prefer projection-backed reads for request-time paths instead of recomputing from raw history.
- Keep payloads, indexes, and cache invalidation aligned with the surfaces that consume the capability.
- Track degraded-state rates so performance shortcuts do not silently erode recommendation quality.
- Interactive web paths should meet the Phase 1 delivery latency target once `DEC-002` is resolved.

## 21. Observability

- Emit metrics for throughput, failures, degraded outcomes, and stale-state usage.
- Log stable identifiers such as `traceId`, `recommendationSetId`, snapshot IDs, or job IDs where the capability affects downstream recommendation behavior.
- Publish structured reason codes so support, analytics, and audit tooling can bucket outcomes consistently.

## 22. Example Scenarios

### Scenario A: Typical happy-path execution

1. A request or upstream change triggers `Cart Duplicate Suppression And Multi Anchor Handling`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "cart-duplicate-suppression-and-multi-anchor-handling",
  "feature": "complete-look-orchestration",
  "input": "cart or session contents",
  "output": "duplicate-suppressed outfit assembly",
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

- Backend services: add or extend a `cart-duplicate-suppression-and-multi-anchor-handling` service boundary under the `complete-look-orchestration` domain.
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
