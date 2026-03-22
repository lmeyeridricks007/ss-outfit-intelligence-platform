# Sub-feature capability: Readiness Evaluation And Snapshots

**Parent feature:** `Catalog and product intelligence`  
**Parent feature file:** `docs/features/catalog-and-product-intelligence.md`  
**Parent feature priority:** `P0`  
**Sub-feature directory:** `docs/features/sub-features/catalog-and-product-intelligence/`  
**Upstream traceability:** `docs/features/catalog-and-product-intelligence.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-008, BR-004); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`)  
**Tracked open decisions:** `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`

---

## 1. Purpose

Evaluate recommendation readiness for each canonical product or variant and persist versioned snapshots that explain whether the entity is eligible, degraded, suppressed, or blocked for a specific market/channel/surface/mode context.

This capability converts changing catalog evidence into an auditable, deterministic readiness truth that can be consumed by decisioning, delivery, governance, explainability, and operator diagnostics without each consumer recomputing logic.

## 2. Core Concept

`Readiness Evaluation And Snapshots` is a policy engine plus snapshot ledger:

`canonical product truth + evidence dimensions + scoped policy -> dimension results -> final readiness state + reason codes -> immutable snapshot`

Key design principles:

- readiness is multi-dimensional, not binary
- readiness is scoped by `market`, `channel`, `surface`, `mode`, and recommendation type
- snapshots are immutable historical records used for replay, traceability, and audits
- policy version and source freshness must be explicit in every evaluated outcome

This capability evaluates readiness. It does not choose ranking order, render UX, or define final source-of-truth precedence policy; those dependencies stay explicit through `DEC-014` to `DEC-017`.

## 3. User Problems Solved

| User / stakeholder | Problem | Capability outcome |
| --- | --- | --- |
| Recommendation decisioning owners | Candidate generation uses inconsistent quality gates across services | A single snapshot contract provides deterministic eligibility context |
| Ecommerce surface teams | PDP/cart trust degrades when stale or unknown inventory is interpreted as valid | Strict scoped readiness states prevent unsafe candidate serving |
| Merchandising / governance operators | Manual suppression causes are unclear and hard to audit | Snapshot reason codes + policy version make outcomes explainable |
| Analytics / experimentation teams | Performance drops are conflated with catalog-quality regressions | Degraded/suppressed rates are measurable as separate causal signals |
| Explainability / support teams | Traces cannot reconstruct why an item was blocked | Historical snapshots preserve decision-time evidence and state |
| Architecture / planning teams | Downstream modules re-implement readiness logic differently | Shared module boundary removes semantic drift across channels |

## 4. Trigger Conditions

- `catalog.product.normalized` updates identity or recommendation-critical attributes.
- `catalog.assortment.updated` changes market/channel eligibility context.
- `inventory.snapshot.updated` or sellability updates affect freshness and availability.
- `imagery.asset.published` or invalidation updates visual-readiness evidence.
- `catalog.compatibility.updated` or look-membership changes alter compatibility evidence.
- `catalog.policy.readiness.updated` publishes a new readiness policy version.
- Operator actions (suppression, exception, override expiry) require recomputation.
- Replay/backfill jobs or incident remediation workflows request reevaluation.

## 5. Inputs

- Canonical product and variant identity records from mapping capability.
- Dimension evidence by scope:
  - attributes/completeness
  - assortment eligibility
  - inventory and freshness
  - imagery quality/coverage
  - compatibility and look-membership evidence
  - mode-specific readiness (`RTW`, `CM`)
- Policy configuration (`policyVersionId`) with scoped thresholds.
- Source provenance metadata and timestamps.
- Manual suppression/override records and effective windows.
- Existing snapshot history for delta/state-transition checks.

## 6. Outputs

- Immutable `ProductReadinessSnapshot` per evaluated scope.
- `DimensionReadinessResult[]` with per-dimension status and reason codes.
- Final `readinessState`:
  - `ELIGIBLE`
  - `DEGRADED`
  - `SUPPRESSED`
  - `BLOCKED`
- Projection update markers for downstream candidate/read-model refresh.
- Structured diagnostics for operators and trace consumers.

## 7. Workflow / Lifecycle

1. **Load scope + canonical entity**
   - Resolve canonical product/variant and requested scope (`market/channel/surface/mode/type`).
2. **Collect evidence**
   - Load latest dimension inputs and provenance timestamps.
3. **Validate evidence freshness**
   - Mark dimensions as `STALE` or `UNKNOWN` when inputs are outside policy bounds.
4. **Evaluate dimensions**
   - Apply policy rules independently for each dimension.
5. **Compose final state**
   - Combine dimension outcomes into final readiness state with deterministic precedence.
6. **Persist snapshot**
   - Write immutable snapshot with policy version, source context, reason codes, and evaluation metadata.
7. **Publish updates**
   - Emit events and mark projection invalidations for decisioning/delivery/read models.
8. **Expose diagnostics**
   - Make snapshot and transition history queryable for operators, support, and explainability.

Lifecycle for a scoped entity:

`evaluated -> ELIGIBLE | DEGRADED | SUPPRESSED | BLOCKED -> re-evaluated on new evidence or policy`

## 8. Business Rules

- Readiness must be evaluated before ranking and delivery selection; ranking cannot bypass hard suppression.
- Each dimension keeps explicit states (`PASS`, `PARTIAL`, `FAIL`, `UNKNOWN`, `STALE`); these states are not interchangeable.
- `UNKNOWN` and `STALE` are safety-relevant states, not informational-only flags.
- Final state precedence must be deterministic and documented (for example, `BLOCKED`/`SUPPRESSED` over `DEGRADED` over `ELIGIBLE`).
- Customer-facing eligibility cannot be inferred from product existence alone; scoped policy checks are mandatory.
- Curated look membership does not bypass hard readiness failures.
- Mode-specific behavior (`RTW` vs `CM`) must remain explicit in snapshot context.
- Overrides are time-bounded, role-controlled, and auditable.
- This spec does not silently resolve open decisions:
  - `DEC-014` source precedence policy,
  - `DEC-015` threshold calibration,
  - `DEC-016` inventory freshness windows,
  - `DEC-017` CM minimum evidence for customer-facing claims.

## 9. Configuration Model

Core policy objects:

- `ReadinessPolicy`
  - `policyVersionId`
  - scoped applicability (`market`, `channel`, `surface`, `mode`, `recommendationType`)
  - dimension rules and final-state composition rules
- `DimensionThresholdPolicy`
  - threshold rules by dimension/category/surface
  - stale and unknown handling behavior
- `OverridePolicy`
  - allowed roles and scope
  - max duration and renewal constraints
  - audit requirements
- `ReevaluationPolicy`
  - event-triggered vs scheduled reevaluation windows
  - replay safety constraints

Configuration requirements:

- versioned and immutable references at evaluation time
- rollout-safe policy transition support
- auditable changes with actor, rationale, and timestamp

## 10. Data Model

### Core entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `ProductReadinessSnapshot` | Immutable readiness outcome for one scoped entity | `snapshotId`, `entityId`, `entityType`, `scope`, `readinessState`, `policyVersionId`, `evaluatedAt` |
| `DimensionReadinessResult` | Dimension-specific evaluation details | `snapshotId`, `dimension`, `status`, `reasonCodes`, `evidenceRefs`, `evaluatedAt` |
| `ReadinessTransition` | Derived state transition timeline | `entityId`, `scope`, `fromState`, `toState`, `trigger`, `occurredAt` |
| `SnapshotProjectionMarker` | Downstream update marker | `snapshotId`, `projectionType`, `status`, `requestedAt` |
| `OverrideReference` | Override metadata linked to snapshot | `overrideId`, `scope`, `effectiveFrom`, `effectiveTo`, `actorRef` |

### Example snapshot payload

```json
{
  "snapshotId": "prdready_01JQ1M5TVM1D9B8QZ1D8JZJH44",
  "entityId": "variant_12345_blue_48",
  "entityType": "variant",
  "scope": {
    "market": "NL",
    "channel": "web",
    "surface": "pdp",
    "mode": "RTW",
    "recommendationType": "outfit"
  },
  "dimensionResults": [
    {
      "dimension": "attributes",
      "status": "PASS",
      "reasonCodes": []
    },
    {
      "dimension": "inventory",
      "status": "STALE",
      "reasonCodes": [
        "inventory_freshness_exceeded_pdp_window"
      ]
    },
    {
      "dimension": "imagery",
      "status": "PASS",
      "reasonCodes": []
    }
  ],
  "readinessState": "SUPPRESSED",
  "policyVersionId": "readiness_policy_v12",
  "catalogVersionId": "catalog_v2026_03_22_0900",
  "evaluatedAt": "2026-03-22T09:16:03Z"
}
```

## 11. API Endpoints

Illustrative feature-stage contracts:

- `POST /catalog/readiness/evaluate`
  - evaluate one or many entities for scoped contexts
- `GET /catalog/readiness/entities/{entityId}`
  - latest snapshot per scope
- `GET /catalog/readiness/entities/{entityId}/history`
  - paged historical snapshots and transitions
- `GET /catalog/readiness/policies/{policyVersionId}`
  - policy metadata and dimension definitions
- `POST /catalog/readiness/recompute`
  - controlled replay/recompute for incident or policy migrations

Required response concepts:

- canonical IDs and full scope keys
- per-dimension status and reason codes
- final readiness state
- `policyVersionId`, `catalogVersionId`, timestamps
- traceability fields used downstream (`traceId`, when applicable)

## 12. Events Produced

- `catalog.readiness.evaluated`
- `catalog.readiness.state_changed`
- `catalog.readiness.suppressed`
- `catalog.readiness.degraded`
- `catalog.readiness.recovered`
- `catalog.projection.invalidate_requested`

## 13. Events Consumed

- `catalog.product.normalized`
- `catalog.assortment.updated`
- `inventory.snapshot.updated`
- `imagery.asset.published`
- `catalog.compatibility.updated`
- `catalog.policy.readiness.updated`
- `governance.override.approved`
- `catalog.readiness.recompute.requested`

## 14. Integrations

- Canonical identity and mapping capability (entity IDs and source lineage).
- Market/channel/mode eligibility capability.
- Inventory and imagery gating capability.
- Compatibility and look-membership inputs capability.
- Projection/feed-health/operator-tooling capability.
- Recommendation decisioning and ranking consumers.
- Shared contracts and delivery API for consistent readiness semantics.
- Explainability and auditability pipelines.
- Merchandising governance controls for suppressions and overrides.

## 15. UI Components

- Readiness state badge (`ELIGIBLE`, `DEGRADED`, `SUPPRESSED`, `BLOCKED`).
- Dimension matrix component (status + reason codes by dimension).
- Snapshot timeline component (state transitions over time).
- Scope selector (market/channel/surface/mode/type).
- Policy version indicator and linked change metadata.

## 16. UI Screens

- Catalog operations console (health and suppression trends).
- Product/variant readiness detail page (current and historical snapshots).
- Feed/incident triage screen (readiness impact per incident).
- Governance override review screen (active and expiring overrides).

## 17. Permissions & Security

- Snapshot evaluation writes are restricted to trusted services and authorized workflows.
- Override-linked evaluations require governance-approved role permissions.
- Read views are role-filtered (operator/support/analytics) with least-privilege fields.
- All snapshot mutations and recompute actions are audit logged with actor and rationale.
- Keep capability product-data scoped; do not attach customer PII to snapshot records.

## 18. Error Handling

- Return structured validation errors for invalid IDs, scope keys, or policy references.
- If evidence dependency is unavailable, emit safe deterministic outcomes (`UNKNOWN`/`STALE` leading to degraded or suppressed state per policy), not silent pass.
- Ensure recompute APIs are idempotent and replay-safe.
- Preserve partial-dimension diagnostics when one evidence source fails.
- Standardize machine reason codes, for example:
  - `policy_not_found`
  - `scope_not_supported`
  - `evidence_source_unavailable`
  - `inventory_freshness_unknown`
  - `cm_required_fields_missing`

## 19. Edge Cases

- Out-of-order events attempt to regress snapshot state with older evidence timestamps.
- Variant-level readiness fails while product-level attributes still pass.
- Policy version change causes broad state transitions that must remain explainable.
- A stale downstream consumer queries cached snapshot after a state change.
- Conflicting source evidence requires policy-driven precedence (`DEC-014`) and conflict visibility.
- CM entity has partial compatibility evidence and must be blocked on customer-facing contexts (`DEC-017`).
- Emergency override expires mid-traffic and requires immediate reevaluation.

## 20. Performance Considerations

- Keep evaluation path deterministic and cache-friendly; avoid heavy joins on request path.
- Use projection-backed reads for high-frequency downstream consumers.
- Support bursty reevaluation from inventory churn without full catalog recompute.
- Partition snapshot storage/indexes by scope dimensions and evaluation time.
- Provide batch reevaluation jobs for policy migrations and incident recovery.
- Keep snapshot payloads compact for delivery and analytics consumers.

## 21. Observability

Track at minimum:

- evaluation throughput and latency by dimension and scope
- readiness-state distribution and transition rates
- suppression/degraded reason-code concentration
- stale/unknown evidence incidence by source
- recompute backlog and completion success rates

Log and trace fields:

- `snapshotId`, `entityId`, scope keys
- `policyVersionId`, `catalogVersionId`
- `traceId`, and `recommendationSetId` when available in downstream flow context
- event trigger and dependency source timestamps

Alerting focus:

- sudden suppression spikes by category/surface
- prolonged stale evidence on strict surfaces
- repeated policy-evaluation failures

## 22. Example Scenarios

### Scenario A: PDP suppression from stale inventory

1. `inventory.snapshot.updated` stops arriving within PDP freshness policy.
2. Reevaluation marks inventory dimension `STALE`.
3. Final readiness state becomes `SUPPRESSED`.
4. Snapshot is persisted and projection invalidation event is emitted.

### Scenario B: Homepage degraded but still serveable

1. Attributes, assortment, and inventory pass.
2. Imagery dimension is `PARTIAL` for optional role on homepage.
3. Policy composes final state `DEGRADED`.
4. Delivery may still serve candidate with degraded metadata for analytics and traceability.

### Scenario C: CM customer-facing block

1. CM entity is present with strong imagery and availability.
2. Required CM compatibility field groups are incomplete.
3. Mode-specific dimension fails and final state becomes `BLOCKED`.
4. Operator surfaces can inspect remediation reason code; customer-facing recommendation is withheld.

### Illustrative event payload

```json
{
  "eventType": "catalog.readiness.state_changed",
  "snapshotId": "prdready_01JQ1M5TVM1D9B8QZ1D8JZJH44",
  "entityId": "variant_12345_blue_48",
  "scope": {
    "market": "NL",
    "channel": "web",
    "surface": "pdp",
    "mode": "RTW",
    "recommendationType": "outfit"
  },
  "fromState": "ELIGIBLE",
  "toState": "SUPPRESSED",
  "reasonCodes": [
    "inventory_freshness_exceeded_pdp_window"
  ],
  "policyVersionId": "readiness_policy_v12",
  "occurredAt": "2026-03-22T09:16:03Z"
}
```

## 23. Implementation Notes

Implementation implications:

- **Backend services**
  - dedicated readiness evaluator service boundary in `catalog-and-product-intelligence`
  - deterministic rule engine and final-state composer
- **Storage**
  - append-only snapshot table/collection
  - indexed latest-snapshot projection by scope
  - transition history for audit and support workflows
- **Jobs/workers**
  - event-driven reevaluation worker
  - batch recompute/replay worker for policy or incident recoveries
  - projection invalidation/refresh worker
- **External APIs**
  - consume only canonical catalog, inventory, imagery, eligibility, and compatibility contracts
- **Frontend/operator surfaces**
  - show dimension-level diagnostics, not only final state badges
  - keep state semantics consistent across all operator screens

Assumptions preserved for later stages:

- Threshold calibration remains open (`DEC-015`) and must be finalized in architecture/planning artifacts.
- Source precedence policy remains open (`DEC-014`), so evaluator must consume precedence as configuration, not hard-coded logic.
- Inventory freshness windows by surface remain open (`DEC-016`) and must remain explicit in policy references.
- CM minimum evidence for customer-facing contexts remains open (`DEC-017`); this spec preserves the dependency and does not invent final thresholds.

## 24. Testing Requirements

- **Unit tests**
  - per-dimension evaluation logic
  - final-state composition precedence
  - reason-code assignment and override handling
- **Contract tests**
  - evaluate/history API schema compatibility
  - produced event payload schema/version compatibility
- **Integration tests**
  - full event flow from evidence updates to snapshot publication
  - projection invalidation and downstream consumption behavior
  - governance override and expiry-driven transitions
- **Replay and determinism tests**
  - identical inputs produce identical snapshot outcomes
  - policy-version migration and backfill correctness
- **Resilience tests**
  - dependency outages producing safe degraded/suppressed outputs
  - out-of-order/duplicate event handling
- **Performance tests**
  - high-frequency reevaluation under inventory churn
  - snapshot history query latency at operational scale
- **Traceability tests**
  - verify snapshot fields required by explainability and analytics propagate end-to-end
