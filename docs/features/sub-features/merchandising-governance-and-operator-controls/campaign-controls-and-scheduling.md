# Sub-feature capability: Campaign Controls And Scheduling

**Parent feature:** `Merchandising governance and operator controls`  
**Parent feature file:** `docs/features/merchandising-governance-and-operator-controls.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/merchandising-governance-and-operator-controls/`  
**Upstream traceability:** `docs/features/merchandising-governance-and-operator-controls.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-009, BR-011, BR-005, BR-010, BR-004); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-008`, `DEC-029`, `DEC-034`, `DEC-035`, `DEC-036`)  
**Tracked open decisions:** `DEC-008`, `DEC-029`, `DEC-034`, `DEC-035`, `DEC-036`

---

## 1. Purpose

Define time-bound campaign controls that safely inject promotional or editorial intent into recommendation flows without obscuring precedence, approvals, or analytics context.

The goal of this capability is to give architecture, planning, UI, backend, analytics, and governance work a bounded implementation module instead of leaving this behavior implicit inside the broader feature file.

## 2. Core Concept

This capability sits under `Merchandising governance and operator controls` and owns one clear responsibility: define time-bound campaign controls that safely inject promotional or editorial intent into recommendation flows without obscuring precedence, approvals, or analytics context.

It should be implemented as a reusable platform module whose contracts remain consistent across channels and environments rather than as surface-specific one-off logic.

## 3. User Problems Solved

- Reduces ambiguity for teams implementing `Merchandising governance and operator controls` by isolating a single capability boundary.
- Prevents downstream consumers from reinterpreting `Campaign Controls And Scheduling` behavior differently on each surface or channel.
- Keeps cross-cutting uncertainty explicit through open-decision references instead of forcing later stages to guess.

## 4. Trigger Conditions

- A campaign needs recommendation treatment on a specific surface or channel.
- A scheduled campaign becomes active or expires.
- Operators need to preview how a campaign will affect recommendation outputs.

## 5. Inputs

- campaign metadata and time windows
- target surfaces, channels, recommendation types, and modes
- linked curated looks, rules, or overrides
- priority and precedence settings
- approval and rollout state

## 6. Outputs

- versioned campaign control records
- effective schedule entries
- preview and simulation outputs
- campaign annotations for decisioning and analytics

## 7. Workflow / Lifecycle

1. Define campaign scope, timing, and linked recommendation controls.
2. Validate schedule overlaps, precedence implications, and target eligibility.
3. Publish or schedule the campaign according to approval policy.
4. Activate or expire campaign effects at the right time.
5. Emit analytics and governance annotations for each effective campaign state.

## 8. Business Rules

- Curated looks, rules, campaigns, and overrides are different governance families and must stay separately identifiable.
- Governance decisions are versioned; rollback is expressed as a new effective version rather than mutating historical records.
- AI ranking may operate within the allowed envelope, but governance must remain the source of precedence and emergency controls.
- This capability must stay aligned with `docs/features/merchandising-governance-and-operator-controls.md` as the feature-stage source of truth.
- Open decisions must remain explicit and must not be silently resolved in this spec: `DEC-008`, `DEC-029`, `DEC-034`, `DEC-035`, `DEC-036`.
- Stable `traceId` and `recommendationSetId` handling is required whenever the capability affects delivered recommendation behavior.

## 9. Configuration Model

- `enabled` flag to turn the capability on or off per environment.
- `policyVersion` reference so behavior stays traceable across changes.
- `market`, `channel`, `surface`, and `mode` scoping keys where applicable.
- Approval, precedence, and publication schedule settings.
- Trace, telemetry, and retention configuration for observability and audit.

## 10. Data Model

Primary entities:

- CampaignControl
- CampaignSchedule
- CampaignPreview
- CampaignActivationRecord
- CampaignAnnotation

Recommended shared fields across the entities above:

- stable canonical IDs and source references where applicable
- createdAt / updatedAt timestamps
- policy or schema version references
- traceable reason codes for degraded, blocked, or overridden outcomes

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- POST /governance/campaigns
- POST /governance/campaigns/{campaignId}/schedule
- GET /governance/campaigns/{campaignId}/preview

These endpoints are intentionally illustrative. Final transport, schema normalization, and versioning details should follow the eventual architecture-stage resolution of the relevant `DEC-###` items.

## 12. Events Produced

- campaign.schedule.activated
- campaign.schedule.expired

## 13. Events Consumed

- approval.record.created
- governance.rule.published

## 14. Integrations

- catalog and product intelligence
- recommendation decisioning and ranking
- shared contracts and delivery API
- analytics and experimentation
- explainability and auditability
- ecommerce surface experiences
- identity and style profile

## 15. UI Components

- rule builder
- campaign scheduler
- override timeline
- approval diff viewer

If the capability is primarily backend-oriented, these components still matter for operator, support, or diagnostics surfaces that need to expose its state safely.

## 16. UI Screens

- governance admin console
- approval queue
- effective snapshot inspector

## 17. Permissions & Security

- Restrict write operations to the service or operator role responsible for the capability.
- Expose only role-safe fields to support, operator, and consumer views.
- Keep audit fields on every state change that affects downstream recommendation behavior.
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

1. A request or upstream change triggers `Campaign Controls And Scheduling`.
2. The capability reads the required inputs, applies its policy, and emits the bounded output described above.
3. Downstream systems consume the result with stable identifiers, version references, and reason codes.

### Illustrative payload

```json
{
  "subFeature": "campaign-controls-and-scheduling",
  "feature": "merchandising-governance-and-operator-controls",
  "input": "campaign metadata and time windows",
  "output": "versioned campaign control records",
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

- Backend services: add or extend a `campaign-controls-and-scheduling` service boundary under the `merchandising-governance-and-operator-controls` domain.
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
