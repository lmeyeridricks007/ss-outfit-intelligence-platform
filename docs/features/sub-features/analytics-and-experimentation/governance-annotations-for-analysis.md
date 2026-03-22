# Sub-feature capability: Governance Annotations For Analysis

**Parent feature:** `Analytics and experimentation`  
**Parent feature file:** `docs/features/analytics-and-experimentation.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/analytics-and-experimentation/`  
**Upstream traceability:** `docs/features/analytics-and-experimentation.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-010, BR-003, BR-002, BR-011, BR-009); `docs/project/data-standards.md`; `docs/features/merchandising-governance-and-operator-controls.md`; `docs/features/open-decisions.md` (`DEC-006`, `DEC-007`)  
**Tracked open decisions:** `DEC-006`, `DEC-007`

---

## 1. Purpose

Attach explicit governance context (campaigns, rules, suppressions, overrides, emergency controls, and approval lineage) to recommendation telemetry so analysis can separate:

- model and ranking movement
- governance policy intervention
- inventory safety controls
- experiment treatment effects

This capability prevents false conclusions such as "model quality dropped" when the actual change was a campaign launch, override, or emergency suppression.

## 2. Core Concept

`governance-annotations-for-analysis` is the analytics contract layer for governance context. It does not execute governance policy; it captures and persists policy context so metrics and experiments remain interpretable.

It standardizes:

1. **What governance context is captured** (campaign IDs, rule IDs, override flags, snapshot version, approval level).
2. **Where that context is attached** (delivery records, exposure events, attribution records, read models).
3. **How context survives replay and late outcomes** (immutable references to effective governance state at exposure time).
4. **How analysts query impact** (governance-aware dimensions and side-by-side views with experiment context).

## 3. User Problems Solved

- **Analytics and product users** can distinguish governance-driven movement from ranking-driven movement.
- **Merchandising operators** can verify campaign/override impact without relying on ad hoc log digging.
- **Experiment owners** avoid misattributing treatment uplift/regression when governance changed concurrently.
- **Support and audit users** can reconstruct what policy state was active when a recommendation was shown.
- **Engineering teams** get one shared annotation contract rather than channel-specific governance tagging logic.

## 4. Trigger Conditions

Governance annotation logic is triggered when:

- a recommendation payload is delivered under an active governance snapshot
- a campaign/override/suppression state changes for a relevant scope
- an impression/click/add-to-cart/purchase event is validated and requires enrichment
- attribution records are created or adjusted and governance context must be retained
- read models are recomputed, replayed, or backfilled

## 5. Inputs

- delivery envelope fields (`recommendationSetId`, `traceId`, placement, channel, surface)
- governance snapshot metadata (snapshot ID, policy version, effective window)
- active campaign metadata (campaign ID, activation window, priority)
- rule and override metadata (rule IDs, override type, emergency flags)
- experiment context (`experimentId`, `variantId`, `assignmentKey`)
- canonical telemetry events and attribution records
- identity-confidence and market/region scope where required for policy scoping

## 6. Outputs

- annotation-enriched telemetry records
- annotation-enriched attribution records
- governance impact dimensions for projections and dashboards
- immutable lineage links from events to governance snapshots
- governance impact incident signals (for abrupt policy-driven metric shifts)

## 7. Workflow / Lifecycle

1. **Ingest governance state:** consume snapshot/campaign/override updates from governance systems.
2. **Resolve effective context:** identify which governance state applies at delivery/exposure time for each recommendation record.
3. **Attach annotation:** add governance fields to canonical events and attribution records.
4. **Persist lineage:** store links to immutable governance snapshot references.
5. **Project and publish:** build governance-aware read models and dashboard dimensions.
6. **Monitor drift:** detect missing or stale governance context in telemetry.
7. **Replay support:** rebuild annotations during replay/backfill without mutating historical effective state.

Recommended annotation lifecycle state:
`pending -> resolved -> attached -> projected -> queryable`

## 8. Business Rules

- Governance annotation must never redefine canonical event semantics (impression, click, save, add-to-cart, purchase, dismiss, override).
- `recommendationSetId` and `traceId` are required for analytics records that claim governance-linked attribution.
- Governance and experiment context must be queryable together; neither can overwrite the other.
- Annotation references the governance state effective at exposure time, not current policy at query time.
- Emergency controls and hard suppressions must be explicitly flagged so they are not mistaken for model behavior.
- Missing governance context is a measurable degraded state and must be surfaced in health views.
- Local channel teams cannot invent alternate governance annotation fields.
- Open decisions remain unresolved and explicit: `DEC-006`, `DEC-007`.

## 9. Configuration Model

Required configuration domains:

- `annotation.enabled` per environment
- `annotation.policyVersion`
- `annotation.requiredFields` by event family
- `annotation.scope` by channel/surface/placement/market/mode
- `annotation.precedence` when multiple governance controls apply
- `annotation.stalenessThreshold` for snapshot freshness checks
- `annotation.replayMode` behavior for backfill and historical recompute
- `annotation.alertThresholds` for missing-context rate and stale-context rate
- `annotation.retention` for annotation lineage tables

All config changes should be versioned and attached to projected outputs.

## 10. Data Model

Primary entities:

1. **`GovernanceAnnotation`**
   - `annotationId`, `recommendationSetId`, `traceId`
   - `governanceSnapshotId`, `governancePolicyVersion`
   - `campaignId`, `ruleIds`, `overrideFlag`, `suppressionFlag`, `emergencyFlag`
   - `effectiveFrom`, `effectiveTo`, `resolvedAt`
2. **`GovernanceSnapshotRef`**
   - `governanceSnapshotId`, `sourceSystem`, `publishedAt`, `hash`, `status`
3. **`AnnotatedEventRef`**
   - `eventId`, `eventType`, `annotationId`, `attachedAt`, `attachStatus`, `reasonCode`
4. **`AnnotatedAttributionRef`**
   - `attributionId`, `annotationId`, `confidence`, `attachedAt`
5. **`GovernanceImpactSlice`**
   - dimension key set for campaign/rule/override/suppression/emergency and metric fields

### Example annotation payload

```json
{
  "annotationId": "ann_01JQAF5K4Q8R3YB0D6F5V4E2M1",
  "recommendationSetId": "recset_01JQAF55X3A5R2G8P0N4Y7T9VK",
  "traceId": "trace_01JQAF54QZ2X4V7D8N1S6K5M3P",
  "governanceSnapshotId": "govsnap_2026_03_22_1400",
  "governancePolicyVersion": "gov.v2.4",
  "campaignId": "camp_spring_wedding",
  "ruleIds": ["rule_inventory_guard", "rule_premium_suppression"],
  "overrideFlag": true,
  "suppressionFlag": false,
  "emergencyFlag": false,
  "effectiveFrom": "2026-03-22T14:00:00Z",
  "effectiveTo": null
}
```

## 11. API Endpoints

Illustrative contract-level surfaces:

- `POST /analytics/governance-annotations/resolve`
- `POST /analytics/governance-annotations/attach`
- `GET /analytics/governance-annotations/{recommendationSetId}`
- `GET /analytics/governance-annotations/by-trace/{traceId}`
- `GET /analytics/governance-impact?campaignId=&overrideFlag=&window=`

Transport and storage implementation are architecture-stage choices, but semantics and core fields above are mandatory.

## 12. Events Produced

- `analytics.governance-annotation.resolved`
- `analytics.governance-annotation.attached`
- `analytics.governance-annotation.missing-context`
- `analytics.governance-impact.shift-detected`

## 13. Events Consumed

- `governance.snapshot.published`
- `governance.campaign.activated`
- `governance.override.applied`
- `recommendation.delivery.served`
- `analytics.event.validated`
- `analytics.attribution.created`

## 14. Integrations

- **Merchandising governance and operator controls** (source of campaign/rule/override state)
- **Shared contracts and delivery API** (stable recommendation identifiers)
- **Canonical recommendation events** (records requiring annotation)
- **Experiment assignment and delivery contracts** (coexisting experiment dimensions)
- **Outcome attribution and confidence** (annotation continuity into outcomes)
- **Analytics read models and health** (governance-aware projections and quality monitoring)
- **Explainability and auditability** (trace-linked investigation workflows)

## 15. UI Components

Internal/operator-facing components:

- governance filter rail (campaign/rule/override/emergency toggles)
- governance-context badge on metric tiles
- policy timeline ribbon (snapshot/version transitions)
- side-by-side compare card (with governance vs without governance filters)
- annotation completeness card (missing/stale governance context rates)

## 16. UI Screens

- experiment scorecard screen with governance overlays
- analytics metric explorer with governance dimensions
- telemetry health console with governance annotation quality
- trace drilldown panel showing active governance state at exposure time

## 17. Permissions & Security

- Only authorized services can publish governance snapshots and attach privileged annotations.
- Raw annotation lineage access is role-restricted; aggregate governance slices are broader.
- Region and market policy boundaries apply to governance fields where they imply sensitive operator actions.
- All annotation writes and replay actions require audit trails (actor, timestamp, reason).
- Support and analyst tooling should expose only role-safe governance details.

## 18. Error Handling

- Unknown `governanceSnapshotId` or stale snapshot references return structured attach failures with reason codes.
- Missing required IDs (`recommendationSetId`, `traceId`) blocks attach for records claiming governance context.
- Partial attach success must be explicit; silently dropping annotation is not allowed.
- Enrichment pipeline outages should queue retryable work with idempotent keys.
- Failed attach records route to quarantine with replay metadata.

## 19. Edge Cases

- Multiple governance controls apply simultaneously (campaign + override + suppression); precedence must be explicit and auditable.
- Governance changes mid-session between delivery and impression; annotation should reflect effective state at exposure time.
- Attribution arrives after governance policy version changed; historical linkage must keep original effective context.
- Replayed telemetry references archived snapshots; replay must still resolve lineage via immutable snapshot refs.
- Same recommendation appears across channels with different governance scope; channel/surface scope must remain explicit.
- Emergency override windows expire during active experiments; analysis must retain both experiment and governance context.

## 20. Performance Considerations

- Annotation attachment should be low-latency for ingestion paths and not block unrelated event processing.
- Index annotation lookup by `recommendationSetId`, `traceId`, and `governanceSnapshotId`.
- Batch attach operations should support high-throughput replay/backfill workloads.
- Avoid join-heavy query-time reconstruction; persist attach results for read-model projection.
- Track and alert on attach lag to avoid stale governance context in near-real-time dashboards.

## 21. Observability

Track at minimum:

- annotation attach success/failure rate
- missing governance-context rate by channel/surface
- stale snapshot-reference rate
- attach latency percentiles
- governance-impact shift detection counts
- replay attach correction counts

Operational logs should include:
`eventId`, `traceId`, `recommendationSetId`, `annotationId`, `governanceSnapshotId`, `campaignId`, `reasonCode`.

## 22. Example Scenarios

### Scenario A: Campaign launch during experiment

1. An experiment is active on PDP ranking.
2. Merchandising launches a campaign targeting the same placement.
3. Governance annotation attaches campaign and rule context to exposure and outcome records.
4. Scorecards show variant metrics with governance filters, preventing false model regression conclusions.

### Scenario B: Emergency suppression event

1. Operator activates emergency suppression for a product family.
2. Delivery continues for unaffected products, but affected records carry `emergencyFlag=true`.
3. Analytics view shows sudden conversion change with explicit emergency annotation.
4. Teams avoid rolling back model changes that were not the root cause.

### Illustrative attached event payload

```json
{
  "eventId": "evt_01JQAF8S7A4Q3N8B2F9R5D6M1K",
  "eventType": "impression",
  "traceId": "trace_01JQAF54QZ2X4V7D8N1S6K5M3P",
  "recommendationSetId": "recset_01JQAF55X3A5R2G8P0N4Y7T9VK",
  "experimentId": "exp_rank_mix_2026_q2",
  "variantId": "treatment_b",
  "governanceAnnotation": {
    "annotationId": "ann_01JQAF5K4Q8R3YB0D6F5V4E2M1",
    "governanceSnapshotId": "govsnap_2026_03_22_1400",
    "campaignId": "camp_spring_wedding",
    "ruleIds": ["rule_inventory_guard", "rule_premium_suppression"],
    "overrideFlag": true,
    "suppressionFlag": false,
    "emergencyFlag": false
  },
  "schemaVersion": "1.0"
}
```

## 23. Implementation Notes

- Implement annotation as a dedicated analytics-domain module, not ad hoc dashboard transforms.
- Treat governance snapshot references as immutable lineage data for replay and auditability.
- Attach annotations early in ingestion flow so downstream projections remain consistent.
- Keep experiment and governance context coupled but independently queryable.
- Ensure contracts align with canonical ID standards from `docs/project/data-standards.md`.

Implementation implications:

- **Backend services:** governance annotation resolver + attachment worker boundary.
- **Storage:** annotation lineage tables plus snapshot reference store and attach-result store.
- **Jobs/workers:** enrichment workers, stale-context detectors, replay/backfill annotation workers.
- **External dependencies:** governance snapshot feed, campaign/override events, canonical telemetry stream.
- **UI/ops tooling:** governance filter controls, annotation quality views, trace-linked inspection.

Explicitly unresolved in this sub-feature:

- exact server-side fallback coupling details with governance annotations (`DEC-006`)
- final attribution-window and experiment-stickiness policy interactions (`DEC-007`)

## 24. Testing Requirements

- unit tests for precedence resolution and annotation field attachment rules
- contract tests for annotation payload fields and required ID enforcement
- integration tests across delivery -> annotation -> telemetry -> attribution flows
- replay/backfill tests to confirm immutable historical governance linkage
- degraded-path tests for missing snapshot, stale snapshot, and partial attach behavior
- performance tests for attach throughput and lookup latency under peak ingestion
- permission tests for raw lineage access vs aggregate reporting access
- observability tests validating required metrics/log fields and alert conditions
