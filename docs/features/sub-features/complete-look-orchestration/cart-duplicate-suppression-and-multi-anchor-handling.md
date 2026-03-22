# Sub-feature capability: Cart Duplicate Suppression And Multi Anchor Handling

**Parent feature:** `Complete-look orchestration`  
**Parent feature file:** `docs/features/complete-look-orchestration.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/complete-look-orchestration/`  
**Upstream traceability:** `docs/features/complete-look-orchestration.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-001, BR-002, BR-005, BR-008); `docs/project/glossary.md` (`look` vs `outfit`); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-018`, `DEC-019`, `DEC-020`)  
**Tracked open decisions:** `DEC-018`, `DEC-019`, `DEC-020`

---

## 1. Purpose

Ensure complete-look `outfit` responses remain coherent, non-redundant, and actionable when:

- the shopper cart already contains one or more recommended members
- multiple plausible anchors exist in the same request (cart, occasion, or assisted-selling context)

This capability prevents duplicate leakage and anchor ambiguity from degrading the complete-look experience into a confusing or low-value module.

## 2. Core Concept

This module sits between initial outfit assembly and final delivery packaging. It performs two linked controls:

1. **Cart duplicate suppression**  
   Detect duplicate recommendations relative to cart state (exact SKU, canonical product, or policy-defined near-duplicate) and either suppress, substitute, or demote them.
2. **Primary anchor resolution**  
   Resolve a single lead anchor mission when multiple anchors are plausible, then revalidate slot coverage for the chosen anchor.

The output remains a typed `outfit` set with grouped semantics, preserved traceability, and explicit reason codes for every suppression or anchor decision.

## 3. User Problems Solved

- **Cart frustration:** avoids recommending products the shopper just added.
- **Mission drift:** avoids a mixed-anchor answer that feels like unrelated add-ons.
- **Inconsistent behavior across surfaces:** centralizes suppression and anchor tie-break logic so PDP/cart/clienteling do not diverge.
- **Support opacity:** emits reason codes and trace metadata for why an item was removed or why one anchor won.

## 4. Trigger Conditions

- request includes cart state and at least one outfit candidate
- request has two or more valid anchor candidates
- cart mutation causes a refresh of an already-rendered outfit set
- fallback controller asks for re-check after slot substitutions

## 5. Inputs

- normalized request context: `surface`, `mode`, `market`, `channel`, `placement`
- cart lines with canonical and variant IDs
- candidate outfit assemblies from upstream orchestration stages
- candidate anchor list with anchor rationale and confidence
- policy snapshot:
  - duplicate policy
  - anchor precedence policy
  - degraded-slot policy references
- governance and campaign context
- optional profile/context signals allowed by consent and confidence policy

## 6. Outputs

- deduplicated outfit assemblies ready for packaging
- `primaryAnchorDecision` record with deterministic tie-break evidence
- `suppressionRecords[]` with reason codes and actions (`suppress`, `substitute`, `demote`)
- adjusted slot plan (required vs optional coverage after suppression)
- machine-readable degradation indicators when minimum coverage is threatened

## 7. Workflow / Lifecycle

1. **Load policy snapshot** keyed by `surface`, `mode`, `market`, and policy version.
2. **Normalize identifiers** for cart lines and outfit members (canonical + variant references).
3. **Run duplicate classification**:
   - exact variant duplicate
   - canonical product duplicate
   - policy-defined near-duplicate
4. **Apply duplicate action policy** per slot and surface:
   - suppress duplicate member
   - substitute from eligible alternatives
   - demote to optional slot when allowed
5. **Resolve primary anchor** when multiple anchors remain:
   - score candidate anchors using policy criteria
   - apply deterministic tie-breakers
   - record winning and losing anchors with reasons
6. **Re-validate slot coverage** for the chosen anchor mission.
7. **Classify result** as `valid`, `degraded`, or `suppressed`.
8. **Emit response metadata and events** with `traceId`, `recommendationSetId`, policy version, and reason codes.

## 8. Business Rules

1. Output must remain recommendation type `outfit`; dedupe logic must not silently convert to cross-sell behavior.
2. Exact in-cart duplicates must not be emitted unless explicit substitution policy requires temporary retention for variant choice.
3. For cart-extension surfaces, primary anchor mission can be preserved even when the anchor product is omitted from emitted slots because it is already in cart; this must be tagged with an explicit reason code.
4. If duplicate suppression removes a required slot member, fallback behavior must follow degraded policy rather than silently dropping slot semantics.
5. Multi-anchor requests must resolve to one primary anchor mission for each returned outfit alternative.
6. Anchor resolution must be deterministic for a given input bundle and policy version.
7. Every suppression and anchor decision must be traceable with reason codes and policy references.
8. Internal `look` semantics and customer-facing `outfit` semantics remain distinct and explicitly labeled.
9. Open decisions remain explicit and unresolved in this spec:
   - `DEC-018`: mandatory vs optional slot composition by anchor/surface/mode
   - `DEC-019`: substitute vs omit thresholds before suppressing full outfit
   - `DEC-020`: final primary-anchor precedence model in mixed-intent flows

## 9. Configuration Model

| Configuration key | Description |
| --- | --- |
| `enabled` | Enables/disables this module by environment. |
| `policyVersion` | Immutable policy snapshot ID used for replay and audit. |
| `scope` | `market`, `channel`, `surface`, `mode` selectors. |
| `duplicatePolicy` | Matching level (`variant`, `canonical`, `near`) and slot-specific actions. |
| `anchorPolicy` | Anchor scoring criteria and deterministic tie-break order. |
| `slotRetentionPolicy` | Required/optional slot behavior after suppression or substitution. |
| `degradedThresholdPolicy` | Minimum viable outfit thresholds passed to fallback controller. |
| `telemetryPolicy` | Required event fields and sampling controls for traces. |

## 10. Data Model

Primary entities:

- `CartComparisonResult`
- `DuplicateSuppressionRecord`
- `PrimaryAnchorDecision`
- `SecondaryAnchorDisposition`
- `AdjustedSlotPlan`
- `AnchorResolutionReasonCode`
- `DuplicateReasonCode`

Required shared fields:

- stable canonical IDs and source-system mappings where applicable
- `traceId`, `recommendationSetId`, and `requestId`
- `policyVersion` and schema version
- timestamps (`createdAt`, `updatedAt`)
- `reasonCode` and `reasonDetail` (machine-readable + operator-readable)
- actor/source (`system`, `operatorOverride`, `replay`)

### Illustrative `PrimaryAnchorDecision`

```json
{
  "requestId": "req_18377",
  "traceId": "tr_98ab",
  "policyVersion": "anchor_policy_v5",
  "candidateAnchors": [
    { "productId": "P-SUIT-001", "source": "cart", "score": 0.84 },
    { "productId": "P-SHOE-227", "source": "cart", "score": 0.72 }
  ],
  "selectedAnchor": {
    "productId": "P-SUIT-001",
    "selectionReasonCode": "ANCHOR_SCORE_HIGHEST"
  },
  "tieBreakerApplied": "CATEGORY_PRECEDENCE",
  "secondaryAnchors": [
    { "productId": "P-SHOE-227", "disposition": "KEPT_AS_SLOT_MEMBER" }
  ]
}
```

## 11. API Endpoints

Illustrative feature-stage endpoints and operations:

- `POST /outfits/resolve-cart-duplicates`
- `POST /outfits/resolve-primary-anchor`
- `POST /outfits/reconcile-after-anchor-resolution`

Illustrative request fields:

- `requestContext`
- `cartLines[]`
- `candidateOutfits[]`
- `candidateAnchors[]`
- `policySnapshotId`

Illustrative response fields:

- `resolvedOutfits[]`
- `primaryAnchorDecision`
- `suppressionRecords[]`
- `degradedStatus`

Transport and canonical schema choices remain architecture-stage concerns and should align with `DEC-001` and `DEC-003` as applicable.

## 12. Events Produced

- `outfit.duplicate.suppressed`
- `outfit.duplicate.substituted`
- `outfit.primary-anchor.selected`
- `outfit.primary-anchor.conflict`
- `outfit.dedupe-anchor.reconciled`

## 13. Events Consumed

- `cart.context.updated`
- `outfit.intent.resolved`
- `outfit.validation.passed`
- `governance.snapshot.selected`
- `inventory.snapshot.updated`

## 14. Integrations

- catalog and product intelligence
- shared contracts and delivery API
- recommendation decisioning and ranking
- merchandising governance and operator controls
- analytics and experimentation
- explainability and auditability
- RTW and CM mode support

## 15. UI Components

- cart complete-look grouped module
- outfit slot cards with duplicate suppression messaging
- anchor badge / anchor rationale chip
- "why this changed" explanation chips for substitutions
- operator trace panel for anchor conflict inspection

## 16. UI Screens

- cart page complete-look placement
- PDP follow-up cart drawer (when cart context is available)
- clienteling outfit builder (operator view)
- support trace inspection screen

## 17. Permissions & Security

- Only orchestration services and authorized operator tools may write suppression/anchor overrides.
- Customer-facing responses must not expose sensitive profile or internal score details.
- Operator trace depth is role-gated; raw scoring internals are restricted to approved roles.
- All override actions must be audited with actor identity and reason.

## 18. Error Handling

- Reject malformed payloads with structured validation errors (`INVALID_CART_CONTEXT`, `MISSING_POLICY_SNAPSHOT`, `INVALID_ANCHOR_SET`).
- Return partial/degraded responses when safe rather than hard-failing full request.
- If no valid anchor can be resolved, emit explicit suppression state with reason code (`ANCHOR_UNRESOLVABLE`).
- Preserve trace fields on every failure path for support and analytics correlation.

## 19. Edge Cases

- cart contains same canonical product in different sizes/variants
- duplicate suppression removes anchor candidate itself
- two anchors tie on score and both are inventory-valid
- occasion-led request plus anchor-rich cart creates mixed-intent conflict
- stale cart snapshot arrives after fresh snapshot (out-of-order updates)
- curated look insists on member already present in cart
- low-confidence identity changes after initial anchor resolution

## 20. Performance Considerations

- Use projection-backed cart and candidate views for request-time dedupe checks.
- Keep anchor scoring inputs lightweight and cacheable by policy snapshot.
- Avoid N x M slot comparisons by pre-indexing cart IDs and canonical mappings.
- Track latency by sub-step (dedupe, anchor resolution, revalidation) to isolate bottlenecks.
- Interactive paths must align with Phase 1 latency expectations once `DEC-002` is finalized.

## 21. Observability

- Metrics:
  - duplicate suppression rate (by reason code and surface)
  - multi-anchor conflict rate
  - anchor tie-break frequency
  - degraded-after-dedupe rate
  - suppression-to-empty-outfit rate
- Logs/traces must include:
  - `traceId`, `recommendationSetId`, `requestId`
  - `policyVersion`
  - winning anchor and tie-break key
  - suppression actions and reason codes
- Publish structured reason-code dimensions for analytics and support dashboards.

## 22. Example Scenarios

### Scenario A: Cart dedupe with two anchor candidates

1. Cart contains a suit jacket and matching trousers; outfit candidate also includes those exact products.
2. Module suppresses duplicate jacket/trouser recommendations.
3. Anchor policy selects jacket as primary anchor due to category precedence.
4. Suppressed slots are refilled with shirt/tie/shoes alternatives.
5. Response returns valid grouped `outfit` with suppression and anchor decision records.

### Scenario B: Occasion-led request with mixed cart anchors

1. Request intent is wedding occasion; cart has casual shoes and formal blazer.
2. Anchor policy prioritizes occasion-formality alignment over recency.
3. Formal blazer wins as primary anchor.
4. Casual-shoe anchor is retained only if compatible as optional slot member; otherwise suppressed with reason code.
5. If required formal slots cannot be filled after suppression, output is marked `degraded` per policy.

### Illustrative response payload

```json
{
  "feature": "complete-look-orchestration",
  "subFeature": "cart-duplicate-suppression-and-multi-anchor-handling",
  "recommendationType": "outfit",
  "requestId": "req_18377",
  "traceId": "tr_98ab",
  "recommendationSetId": "rs_2210",
  "primaryAnchorDecision": {
    "selectedAnchorProductId": "P-SUIT-001",
    "reasonCode": "ANCHOR_SCORE_HIGHEST",
    "tieBreaker": "CATEGORY_PRECEDENCE"
  },
  "suppressionRecords": [
    {
      "productId": "P-SUIT-001",
      "slot": "anchor",
      "action": "suppress",
      "reasonCode": "ANCHOR_IN_CART_MISSION_PRESERVED"
    }
  ],
  "degradedStatus": null
}
```

## 23. Implementation Notes

- Implement as a deterministic post-processing stage in orchestration service, not in UI clients.
- Keep duplicate matching and anchor scoring policy-driven and versioned.
- Use canonical ID maps from `docs/project/data-standards.md` to avoid source-ID mismatches.
- Persist suppression/anchor decisions in trace storage so replay and support paths can reconstruct output.
- Prefer stateless request-time computation with projection reads; avoid mutating long-lived recommendation objects.
- Keep UI responsibilities to rendering explanations; do not duplicate business logic client-side.

Implementation implications:

- **Backend service boundary:** `complete-look-orchestration` module containing:
  - `dedupeEngine`
  - `anchorResolver`
  - `slotReconciler`
- **Storage:** trace records for `DuplicateSuppressionRecord` and `PrimaryAnchorDecision`.
- **Async support:** optional projection refresh workers for cart and anchor neighborhood views.
- **External dependencies:** catalog, inventory, governance snapshot, delivery packaging.

## 24. Testing Requirements

- **Unit tests**
  - exact vs canonical vs near-duplicate classification
  - deterministic anchor scoring and tie-break ordering
  - reason-code assignment for every suppression action
- **Contract tests**
  - response includes `recommendationSetId`, `traceId`, `policyVersion`, and decision records
  - event payloads carry required telemetry fields from `data-standards.md`
- **Integration tests**
  - cart update -> dedupe -> anchor resolve -> slot revalidation end-to-end
  - governance and inventory snapshot changes affecting duplicate/anchor outcomes
- **Regression tests**
  - duplicate leakage (same item reappears after refresh)
  - anchor flip-flop under identical input bundle
  - degraded output when required slots cannot be recovered
- **Performance tests**
  - high cart-line count scenarios
  - high candidate-anchor count scenarios
- **Traceability tests**
  - replay with same inputs and policy version yields same anchor and suppression outcomes
  - operator override actions are logged and auditable
