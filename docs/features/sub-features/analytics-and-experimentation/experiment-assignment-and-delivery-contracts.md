# Sub-feature capability: Experiment Assignment And Delivery Contracts

**Parent feature:** `Analytics and experimentation`  
**Parent feature file:** `docs/features/analytics-and-experimentation.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/analytics-and-experimentation/`  
**Upstream traceability:** `docs/features/analytics-and-experimentation.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-010, BR-003, BR-002, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-006`, `DEC-007`)  
**Tracked open decisions:** `DEC-006`, `DEC-007`

---

## 1. Purpose

Provide deterministic experiment assignment and a stable delivery-facing experiment contract so recommendation responses and downstream telemetry always carry analyzable treatment context.

This capability ensures that variant effects can be measured across surfaces without requiring each consumer to implement custom assignment logic or mutable enrichment joins after the fact.

## 2. Core Concept

`experiment-assignment-and-delivery-contracts` defines two tightly coupled responsibilities:

1. **Assignment:** decide control/treatment/holdout membership for an eligible subject using a versioned policy.
2. **Contract propagation:** attach assignment context to delivery payloads and downstream events with stable identifiers.

The module must be reusable across ecommerce, email, clienteling, and future channels. Assignment behavior and contract fields are platform semantics, not channel-local conventions.

## 3. User Problems Solved

- **Experiment owners** can run controlled tests without relying on fragile post-hoc variant inference.
- **Delivery and ranking services** receive assignment context in-band and can apply variant behavior predictably.
- **Analytics teams** can slice outcomes by experiment and variant because assignment metadata is persisted with recommendation IDs.
- **Governance teams** can separate model effects from campaign/override effects using explicit combined context.
- **Support and audit users** can reconstruct exactly which assignment policy version applied to a request.

## 4. Trigger Conditions

Assignment and delivery-contract logic is triggered when:

- a recommendation request matches one or more active experiments
- a new subject (customer/session/household key) needs first-time assignment
- an already-assigned subject requests recommendations and stickiness must be enforced
- an experiment enters or exits active state and assignment eligibility changes
- fallback response generation still requires experiment context (`DEC-006` interplay)

## 5. Inputs

- active experiment definitions (eligibility, allocation, guardrails, precedence)
- request context (`channel`, `surface`, `placement`, market, recommendation type)
- assignment key inputs (customer ID, anonymous session ID, or configured unit)
- identity-confidence metadata for known vs anonymous behavior
- holdout policy and exclusions
- governance suppression/override state relevant to request scope
- policy and schema versions for assignment and delivery contract

## 6. Outputs

- resolved assignment decision (`control`, `treatment`, `holdout`, or `not-eligible`)
- persisted assignment record with stickiness metadata
- delivery-facing contract fields (`experimentId`, `variantId`, `assignmentKey`, `assignmentPolicyVersion`)
- assignment reason and exclusion details for auditability
- assignment telemetry events for monitoring and scorecards

## 7. Workflow / Lifecycle

1. **Eligibility check:** evaluate request against active experiment targeting and exclusions.
2. **Precedence resolution:** if multiple experiments are eligible, apply explicit policy ordering.
3. **Assignment resolution:** compute or retrieve sticky assignment using configured assignment unit.
4. **Persistence:** store assignment result with effective policy version and timestamps.
5. **Contract attachment:** enrich recommendation delivery payload with experiment fields.
6. **Emission:** publish assignment events for observability and analytics pipelines.
7. **Exposure continuity:** ensure impression/click/purchase telemetry references same experiment context.
8. **Lifecycle transitions:** retain historical assignments when experiments pause/stop; do not relabel past exposures.

## 8. Business Rules

- Assignment must be deterministic for a given assignment unit under an unchanged policy version.
- Stickiness is mandatory within configured experiment window unless explicit reassignment policy allows changes (`DEC-007`).
- Holdout is first-class and must be observable in delivery and analytics contracts.
- Experiment context must travel with `recommendationSetId` and `traceId` in delivery and outcome paths.
- Governance safety and suppression rules outrank experimental treatment behavior.
- Impression semantics remain tied to visible exposure or approved fallback; assignment alone does not imply exposure (`DEC-006`).
- Multiple concurrent experiments require explicit conflict policy; silent last-write-wins behavior is not permitted.
- Contract field semantics are shared across surfaces; local consumers cannot redefine variant meaning.
- Open decisions `DEC-006` and `DEC-007` remain unresolved and must not be silently closed in this document.

## 9. Configuration Model

Required configuration domains:

- `experimentState`: `draft|scheduled|active|paused|stopped`
- `assignmentUnit`: `customer|session|household|channel-specific` (policy-governed)
- `allocation`: variant split percentages and holdout fraction
- `stickinessPolicy`: retention duration and reassignment conditions
- `eligibilityRules`: channel/surface/market/type filters
- `conflictResolution`: priority and mutual-exclusion groups
- `contractVersion`: required delivery fields and compatibility behavior
- `fallbackContractRules`: treatment context requirements for server-side fallback paths
- `observabilityThresholds`: assignment failure, imbalance, and unknown-variant alerting

Configuration changes must be versioned and queryable historically.

## 10. Data Model

Primary entities:

1. **ExperimentDefinition**
   - `experimentId`, `name`, `status`, `allocationConfig`, `eligibilityConfig`
   - `assignmentUnit`, `stickinessPolicy`, `policyVersion`, `effectiveFrom`, `effectiveTo`

2. **ExperimentAssignment**
   - `assignmentId`, `experimentId`, `variantId`, `assignmentKey`, `assignmentUnit`
   - `assignedAt`, `stickyUntil`, `assignmentPolicyVersion`, `holdoutFlag`
   - `eligibilitySnapshot`, `reasonCode`

3. **DeliveryExperimentContext**
   - `recommendationSetId`, `traceId`, `experimentId`, `variantId`
   - `assignmentKeyHash`, `assignmentPolicyVersion`, `contractVersion`
   - `surface`, `channel`, `placement`

4. **AssignmentAuditRecord**
   - actor/system identity, decision inputs, decision output, timestamps, policy references

### Example delivery context payload

```json
{
  "recommendationSetId": "recset_01JQ5WQ3YYD4K4CJ1SY3M62YCM",
  "traceId": "trace_01JQ5WQ2VPH8J5K3S2EA8J3Y89",
  "experimentContext": {
    "experimentId": "exp_outfit_rank_mix_2026_q2",
    "variantId": "treatment_b",
    "assignmentKey": "sess_8b2d91",
    "assignmentUnit": "session",
    "assignmentPolicyVersion": "v3",
    "holdoutFlag": false
  },
  "surface": "pdp",
  "channel": "web",
  "placement": "complete_the_look_primary"
}
```

## 11. API Endpoints

Illustrative contract-level endpoints:

- `GET /experiments/assignments/{assignmentKey}?surface=&channel=&placement=`
- `POST /experiments/assignments/resolve`
- `GET /experiments/{experimentId}/contract`
- `POST /experiments/{experimentId}/lifecycle-transition`

Delivery integrations may be synchronous or event-driven, but they must preserve assignment semantics and contract fields.

## 12. Events Produced

- `experiment.assignment.resolved`
- `experiment.assignment.reused`
- `experiment.assignment.not-eligible`
- `experiment.assignment.conflict-detected`
- `experiment.assignment.policy-version-changed`

## 13. Events Consumed

- `experiment.definition.published`
- `experiment.lifecycle.changed`
- `delivery.request.normalized`
- `identity.mapping.updated`
- `governance.override.applied`
- `surface.exposure.fallback-required`

## 14. Integrations

- **Shared contracts and delivery API** for recommendation response packaging
- **Recommendation decisioning and ranking** for variant-aware model/rule behavior
- **Canonical recommendation events** for assignment-aware telemetry
- **Impression policy and server fallback** for exposure continuity under blocked browser telemetry
- **Outcome attribution and confidence** for downstream treatment effectiveness analysis
- **Governance annotations for analysis** for campaign/override context separation
- **Identity and style profile** for assignment key quality and confidence handling
- **Explainability and auditability** for trace reconstruction and support workflows

## 15. UI Components

Internal components needed by experiment and support users:

- assignment distribution card (control/treatment/holdout split by surface)
- stickiness diagnostics table (new vs reused assignments)
- variant conflict detector panel
- policy-version timeline component
- assignment lookup widget keyed by `traceId` or `assignmentKey`

## 16. UI Screens

- experiment detail screen (assignment health + delivery-contract snapshot)
- assignment diagnostics console
- telemetry health screen with assignment-context completeness checks
- trace drilldown screen showing assignment + governance context together

## 17. Permissions & Security

- only authorized experimentation services/operators can publish definitions and force transitions
- assignment lookups with sensitive identifiers require role-based access and audit logging
- assignment keys in analytics contexts should be hashed or tokenized where direct exposure is unnecessary
- cross-market access must respect region and data-use policy boundaries
- all policy/config edits require immutable audit records with actor, timestamp, and change reason

## 18. Error Handling

- if experiment definition is invalid, reject activation and emit explicit reason codes
- if assignment cannot be resolved synchronously, return deterministic safe fallback context and flag degraded status
- if contract attachment fails, block unsafe partial responses or apply governed degraded response mode with annotation
- if unknown variant IDs appear downstream, quarantine records and alert; do not silently coerce
- ensure retry logic is idempotent for assignment writes and event emission

## 19. Edge Cases

- **Anonymous-to-known transition:** preserve or reconcile assignment according to configured policy without breaking attribution lineage.
- **Multiple active experiments on same placement:** apply explicit precedence or exclusion set; avoid dual assignment ambiguity.
- **Policy version rollover mid-session:** preserve old assignment for sticky window unless reassignment policy explicitly allows migration.
- **Experiment paused after assignment but before exposure:** keep assignment history; exposure events must still reflect actual state.
- **Fallback-only exposure path:** server fallback must preserve experiment context compatibility with browser-emitted events.
- **Cross-channel journey:** session-assigned web exposure followed by email/clienteling outcome requires confidence-aware linkage.

## 20. Performance Considerations

- assignment resolution must remain low-latency for request-time delivery paths
- cache hot experiment definitions with fast invalidation on lifecycle changes
- persist assignments in write-optimized storage with indexed lookups by assignment key and experiment ID
- batch lifecycle transitions and reindexing tasks asynchronously
- monitor assignment read/write amplification to avoid telemetry-related request degradation

## 21. Observability

Track at minimum:

- assignment resolution rate and latency by surface/channel
- eligibility-to-assignment conversion by experiment
- control/treatment/holdout distribution drift
- assignment reuse rate (stickiness effectiveness)
- assignment-context missing-field rate in delivery payloads
- unknown/invalid variant rate in downstream telemetry
- degraded-assignment fallback rate

Operational logs should include `traceId`, `recommendationSetId`, `experimentId`, `variantId`, `assignmentPolicyVersion`, and reason codes.

## 22. Example Scenarios

### Scenario A: First-time PDP assignment

1. PDP request qualifies for an active outfit-ranking experiment.
2. Assignment service resolves `treatment_b` using session-level assignment key.
3. Delivery response includes full experiment context alongside recommendation identifiers.
4. Subsequent impression and click events use the same context for analysis.

```json
{
  "experimentId": "exp_outfit_rank_mix_2026_q2",
  "variantId": "treatment_b",
  "assignmentKey": "sess_8b2d91",
  "assignmentUnit": "session",
  "assignmentPolicyVersion": "v3",
  "holdoutFlag": false,
  "traceId": "trace_01JQ5WQ2VPH8J5K3S2EA8J3Y89",
  "recommendationSetId": "recset_01JQ5WQ3YYD4K4CJ1SY3M62YCM"
}
```

### Scenario B: Sticky reassignment check after identity resolution

1. Customer starts anonymous and receives assignment.
2. Later login resolves identity to canonical customer ID.
3. Stickiness policy keeps original assignment through experiment window.
4. Audit record captures identity transition and reconciliation reason code.

## 23. Implementation Notes

- implement assignment resolution as a dedicated backend boundary rather than embedded UI/client logic
- persist assignment and policy-version lineage in immutable or append-friendly form
- keep delivery contract helpers centralized so every consumer receives identical field names and semantics
- expose integration libraries for delivery services to reduce contract drift
- align IDs with `docs/project/data-standards.md` canonical standards

Implementation implications:

- **Backend services:** assignment engine + contract attachment layer
- **Storage:** experiment definitions, assignments, lifecycle history, audit records
- **Jobs/workers:** distribution checks, stale-policy cleanup, backfill/replay tooling
- **External dependencies:** identity mapping feed, governance annotation feed, telemetry pipeline
- **Operator tooling:** assignment diagnostics and policy-version diff views

Explicitly unresolved by this sub-feature:

- exact experimentation platform ownership and stickiness policy defaults (`DEC-007`)
- exact fallback exposure policy coupling for blocked client telemetry (`DEC-006`)

## 24. Testing Requirements

- unit tests for eligibility logic, assignment determinism, and precedence/conflict handling
- contract tests for delivery payload experiment-context fields and schema-version compatibility
- integration tests across assignment -> delivery -> impression -> purchase attribution flows
- stickiness tests for repeat requests, lifecycle transitions, and identity resolution changes
- load tests for high-throughput assignment resolution on ecommerce request paths
- failure-mode tests for definition errors, missing variant configuration, and degraded fallback behavior
- security tests for permission boundaries and assignment-key redaction
- observability tests validating required metrics/log fields and alert thresholds
