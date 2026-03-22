# Sub-feature capability: Inventory And Imagery Gating For Surfaces

**Parent feature:** `Catalog and product intelligence`  
**Parent feature file:** `docs/features/catalog-and-product-intelligence.md`  
**Parent feature priority:** `P0`  
**Sub-feature directory:** `docs/features/sub-features/catalog-and-product-intelligence/`  
**Upstream traceability:** `docs/features/catalog-and-product-intelligence.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-008, BR-004); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`)  
**Tracked open decisions:** `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`

---

## 1. Purpose

Ensure recommendation candidates are shown only when inventory and imagery evidence is trustworthy for the requesting surface, market, channel, and mode.

This capability protects customer trust by preventing recommendation modules from displaying products that are unsellable, stale, or visually unfit for the surface context.

## 2. Core Concept

`Inventory And Imagery Gating For Surfaces` is a policy-evaluated gate between catalog truth and recommendation delivery:

`inventory + imagery evidence -> surface policy evaluation -> pass/degrade/suppress verdict -> recommendation-safe candidate projection`

Key principle: readiness is scoped, not global. The same variant can be:

- `PASS` on clienteling (operator-assisted) with partial imagery
- `DEGRADED` on homepage if inventory freshness is stale
- `SUPPRESSED` on PDP/cart if sellability is unknown or failed

## 3. User Problems Solved

- Prevents PDP/cart modules from surfacing products that cannot be purchased with confidence.
- Avoids visual-quality regressions (wrong angle, missing hero, missing variant color) in customer-facing recommendation units.
- Keeps ranking and personalization from accidentally amplifying low-trust candidates.
- Gives operators clear, actionable reason codes rather than silent candidate drops.
- Standardizes gating semantics across surfaces so teams do not create conflicting local logic.

## 4. Trigger Conditions

- `inventory.snapshot.updated` for a variant or SKU.
- `inventory.sellability.changed` event (in stock, out of stock, unavailable, unknown).
- `imagery.asset.published`, `imagery.asset.invalidated`, or quality reclassification.
- Policy changes affecting thresholds by surface, category, or mode.
- Recommendation projection rebuild or replay jobs.
- Explicit eligibility checks from decisioning or delivery API workflows.

## 5. Inputs

- Variant-level inventory snapshot (`sellableState`, quantity bucket, captured timestamp, source).
- Inventory freshness metadata (age, expected update cadence, source-health state).
- Product/variant imagery metadata (asset role, quality state, published timestamp, color/variant match).
- Surface context (`pdp`, `cart`, `homepage`, `email`, `clienteling`, `operator`).
- Mode context (`RTW`, `CM`) and recommendation type (`outfit`, `cross-sell`, `upsell`, `style bundle`, `contextual`, `personal`).
- Market/channel context and assortment eligibility from sibling capabilities.
- Policy version and optional approved manual override records.

## 6. Outputs

- `SurfaceEvidenceVerdict` for product/variant scope:
  - `PASS`
  - `DEGRADED`
  - `SUPPRESSED`
- Dimension status and reason codes:
  - inventory (`PASS`, `STALE`, `UNKNOWN`, `FAIL`)
  - imagery (`PASS`, `PARTIAL`, `UNKNOWN`, `FAIL`)
- Replacement hints for candidate regeneration (when suppression is recoverable).
- Projection update markers for downstream decisioning, delivery, and analytics.

## 7. Workflow / Lifecycle

1. Resolve canonical product + variant identifiers and current scope (surface, mode, market, channel).
2. Load latest inventory evidence and imagery evidence with provenance.
3. Apply precedence rules for conflicting source values (linked to `DEC-014`).
4. Evaluate inventory freshness and sellability against surface policy (linked to `DEC-016`).
5. Evaluate imagery role/quality completeness against surface policy (linked to `DEC-015`).
6. Combine dimension outcomes into a verdict:
   - hard-fail on strict surfaces (`pdp`, `cart`) where required evidence is missing/unknown/stale
   - degraded outcome when policy allows bounded fallback (`homepage`, `email`, some clienteling flows)
7. Persist versioned verdict and emit reason codes.
8. Update candidate projections and invalidate stale read caches.
9. Surface suppression/degradation diagnostics in operator tooling.

Lifecycle states for this capability:

`evaluated -> pass | degraded | suppressed -> re-evaluated (on new evidence/policy)`

## 8. Business Rules

- Inventory and imagery gates run before ranking; ranking cannot override hard suppression.
- Strict interactive ecommerce surfaces (`pdp`, `cart`) must treat `inventory=UNKNOWN|STALE|FAIL` as non-pass.
- Customer-facing surfaces require minimum imagery role coverage (for example, hero image and variant-correct asset) per policy.
- Operator-facing screens may allow degraded imagery views if explicitly configured, but must preserve warnings.
- A product may pass imagery and fail inventory (or vice versa); reason codes must remain dimension-specific.
- Curated `look` membership does not bypass hard inventory/imagery gates for customer-facing `outfit` output.
- Manual overrides are time-bounded and audited; overrides cannot permanently bypass core safety semantics.
- CM behavior must remain explicit: configuration-aware customer-facing recommendations require CM evidence minimums (`DEC-017`), even when imagery appears complete.

## 9. Configuration Model

Policy entities:

- `SurfaceGatePolicy`
  - `policyVersionId`
  - `surface`
  - `mode`
  - `recommendationTypes`
  - `inventoryRules`
  - `imageryRules`
  - `fallbackPolicy`
- `InventoryFreshnessWindowPolicy`
  - per-surface freshness max age
  - stale grace behavior (`degrade` vs `suppress`)
- `ImageryMinimumPolicy`
  - required asset roles by category/surface
  - quality thresholds and variant-match requirements
- `EmergencyOverridePolicy`
  - allowed roles, max duration, audit requirement

Config requirements:

- Versioned and immutable-at-runtime references for traceability.
- Scoped by `market`, `channel`, `surface`, `mode`.
- Backward-compatible rollout support for policy updates.

## 10. Data Model

Primary entities:

- `InventoryEvidenceSnapshot`
  - `snapshotId`, `variantId`, `sellableState`, `inventoryBucket`, `capturedAt`, `sourceSystem`, `sourceVersion`
- `ImageryEvidenceSnapshot`
  - `snapshotId`, `entityId`, `assetRole`, `qualityState`, `variantMatchState`, `publishedAt`, `sourceSystem`
- `SurfaceEvidenceVerdict`
  - `verdictId`, `entityId`, `surface`, `mode`, `market`, `channel`, `inventoryStatus`, `imageryStatus`, `finalVerdict`, `reasonCodes`, `policyVersionId`, `evaluatedAt`
- `OverrideRecord`
  - `overrideId`, `scope`, `actorId`, `reason`, `effectiveFrom`, `effectiveTo`, `approvalContext`

Example verdict payload:

```json
{
  "verdictId": "svg_01JQ0N8XRJ4SKY9M9NG7M2H8V1",
  "entityId": "variant_12345_blue_48",
  "surface": "pdp",
  "mode": "RTW",
  "market": "NL",
  "channel": "web",
  "inventoryStatus": "STALE",
  "imageryStatus": "PASS",
  "finalVerdict": "SUPPRESSED",
  "reasonCodes": [
    "inventory_freshness_exceeded_pdp_window"
  ],
  "policyVersionId": "surface_gate_v15",
  "evaluatedAt": "2026-03-22T10:35:04Z"
}
```

## 11. API Endpoints

Illustrative feature-stage contracts:

- `GET /catalog/variants/{variantId}/surface-gate?surface=...&mode=...&market=...&channel=...`
- `POST /catalog/surface-gates/evaluate`
- `POST /catalog/surface-gates/recompute`
- `GET /catalog/surface-gates/policies/{policyVersionId}`
- `GET /catalog/surface-gates/suppressions?surface=...&reasonCode=...`

Required response fields:

- canonical IDs and scope fields
- inventory/imagery statuses
- `finalVerdict`
- reason codes
- policy version and evaluation timestamp

## 12. Events Produced

- `catalog.surface_gate.evaluated`
- `catalog.surface_gate.degraded`
- `catalog.surface_gate.suppressed`
- `catalog.surface_gate.recovered`
- `catalog.projection.invalidate_requested`

## 13. Events Consumed

- `inventory.snapshot.updated`
- `inventory.sellability.changed`
- `imagery.asset.published`
- `imagery.asset.invalidated`
- `catalog.policy.updated`
- `catalog.readiness.rebuild.requested`
- `governance.override.approved`

## 14. Integrations

- PIM and commerce systems for entity identity and lifecycle context.
- OMS/inventory services for sellability and freshness evidence.
- DAM/asset systems for imagery quality and variant match metadata.
- Market/channel eligibility capability for final scope alignment.
- Readiness evaluation/snapshot capability for consolidated product state.
- Projection and feed-health tooling for downstream read performance.
- Recommendation decisioning and ranking consumers.
- Shared contracts and delivery API for surfaced verdict semantics.
- Explainability/auditability pipeline for trace reconstruction.

## 15. UI Components

- Surface gate status badge (`PASS`, `DEGRADED`, `SUPPRESSED`).
- Reason-code chips grouped by dimension (`inventory`, `imagery`).
- Freshness countdown indicator for inventory evidence age.
- Imagery coverage widget (required roles present/missing).
- Override banner with expiry and actor audit metadata.

## 16. UI Screens

- Catalog operations console: suppression queues and trend views.
- Product/variant readiness detail page: per-surface evidence and verdict history.
- Feed incident triage view: correlates source incidents with gating impact.
- Merchandising governance panel: override request/approval workflow.

## 17. Permissions & Security

- Service-level write access only for gating evaluator and authorized governance workflows.
- Read access partitioned by role (operator vs support vs analytics).
- Override creation restricted to approved governance roles; all changes auditable.
- No customer PII required for this capability; keep payloads product-data scoped.
- Ensure policy changes and overrides include actor, timestamp, and rationale.

## 18. Error Handling

- Validation errors for unknown IDs or invalid scope combinations return structured reason codes.
- If inventory or imagery source is unavailable, emit explicit `UNKNOWN`/`STALE` status rather than silent success.
- Recompute jobs must be idempotent and replay-safe to recover from partial failures.
- Downstream consumers should receive a deterministic fallback verdict (`DEGRADED` or `SUPPRESSED`) when evaluation cannot confirm pass safety.

## 19. Edge Cases

- Inventory says sellable while freshness is beyond strict surface window.
- Product-level imagery exists but variant-specific imagery is missing or mismatched.
- Out-of-order source events arrive and attempt to overwrite newer evidence.
- Cached decisioning results use stale verdict after a suppression update.
- Category policy updates reclassify required imagery roles, causing broad suppression waves.
- CM item has high-quality imagery but lacks required configuration compatibility proof (`DEC-017`).

## 20. Performance Considerations

- Use projection-backed reads for request-time gate lookups.
- Support high-frequency inventory updates without full projection rebuilds.
- Separate fast-path invalidation (inventory) from slower-path recomputation (imagery policy changes).
- Keep verdict payload compact for low-latency downstream consumption.
- Index by `variantId + surface + mode + market + channel` for hot read paths.

## 21. Observability

Required metrics:

- evaluation throughput and latency by surface/mode
- suppression/degraded/pass rates
- top reason-code distribution
- stale evidence percentage by source
- recovery time from suppressed to pass

Required logs/traces:

- `traceId`, `recommendationSetId` (when applicable), `verdictId`, `policyVersionId`
- source snapshot IDs and timestamps
- override linkage when an override influenced output

Alerting:

- suppression spikes by category/surface
- sustained stale inventory on strict surfaces
- imagery-role coverage regressions on high-traffic categories

## 22. Example Scenarios

### Scenario A: PDP strict suppression on stale inventory

1. Inventory update feed lags; latest variant snapshot exceeds PDP freshness window.
2. Imagery remains valid.
3. Gate returns `SUPPRESSED` with `inventory_freshness_exceeded_pdp_window`.
4. Decisioning replaces candidate and logs trace context.

### Scenario B: Homepage degraded due to partial imagery

1. Product passes inventory checks.
2. One optional imagery role is missing for homepage tile policy.
3. Gate returns `DEGRADED` with `imagery_optional_role_missing_homepage`.
4. Delivery still serves candidate but flags degraded context for analytics.

### Scenario C: Clienteling allowed with warning

1. Variant inventory is current; imagery is partial but acceptable for operator-assisted context.
2. Gate returns `DEGRADED` (not suppressed) for `clienteling`.
3. Operator UI shows warning and reason codes; no customer-facing overclaim.

## 23. Implementation Notes

- Implement evaluator as a deterministic policy engine with explicit rule ordering.
- Persist immutable verdict snapshots to support replay and audit.
- Use asynchronous projection updates plus fast invalidation events for strict surfaces.
- Keep reason-code taxonomy stable and versioned to avoid analytics drift.
- Align all entity IDs and telemetry fields to `docs/project/data-standards.md`.

Assumptions carried forward:

- Surface strictness differs and must remain configurable (not hardcoded).
- Customer trust takes precedence over short-term candidate volume on strict surfaces.
- Open decisions `DEC-014` to `DEC-017` are unresolved and must remain explicit in architecture/planning.

## 24. Testing Requirements

- Unit tests for rule precedence, verdict composition, and reason-code assignment.
- Contract tests for API response shape and event payload schema.
- Integration tests with inventory and DAM update streams.
- Replay/backfill tests validating deterministic output for identical inputs.
- Surface matrix tests (`pdp`, `cart`, `homepage`, `email`, `clienteling`) across `RTW` and `CM`.
- Chaos/failure tests for stale or missing source feeds.
- Override governance tests for approval, expiry, and audit trail correctness.
- Performance tests for high-volume inventory churn and projection invalidation latency.
