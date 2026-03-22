# Sub-feature capability: Degraded Outfit Fallback Controller

**Parent feature:** `Complete-look orchestration`  
**Parent feature file:** `docs/features/complete-look-orchestration.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/complete-look-orchestration/`  
**Upstream traceability:** `docs/features/complete-look-orchestration.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-001, BR-002, BR-005, BR-008, BR-011); `docs/project/glossary.md` (`look` vs `outfit`); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-018`, `DEC-019`, `DEC-020`)  
**Tracked open decisions:** `DEC-018`, `DEC-019`, `DEC-020`

---

## 1. Purpose

Control what happens when complete-look orchestration cannot fill every expected slot, and ensure the system returns an honest, policy-compliant `outfit` result (or suppresses it) rather than silently degrading into unrelated item recommendations.

This module exists to keep fallback behavior deterministic, explainable, and reusable across PDP, cart, and later surfaces.

## 2. Core Concept

`Degraded Outfit Fallback Controller` runs after initial slot assignment and validation. It decides whether to:

1. keep the assembled outfit as-is,
2. repair it with bounded substitutions,
3. drop only allowed optional slots,
4. emit a degraded-but-valid outfit, or
5. suppress the outfit set if minimum viability is not met.

The controller is policy-driven and trace-first. It never changes recommendation type: output remains `outfit` or explicit suppression.

## 3. User Problems Solved

- Prevents customer-facing modules from showing misleading "complete look" content when required items are missing.
- Gives merchandising and support teams machine-readable reasons for degraded or suppressed outcomes.
- Reduces channel drift by centralizing fallback semantics in one module rather than per-surface custom logic.
- Protects measurement quality by emitting explicit degraded-state metadata and reason codes.

## 4. Trigger Conditions

The controller executes when any of the following occurs:

- one or more required slots are unfilled after template selection and slot fill,
- a filled member fails governance or inventory checks during final validation,
- duplicate suppression removes a required slot candidate in cart flows,
- mode/surface constraints (RTW vs CM, PDP vs cart) invalidate current slot coverage,
- post-assembly freshness checks mark one or more members unavailable.

## 5. Inputs

| Input | Required | Notes |
| --- | --- | --- |
| `assemblyPlan` | Yes | Slot-labeled grouped assembly candidate from orchestration. |
| `slotPolicy` | Yes | Required vs optional slot definitions by surface/mode. |
| `fallbackPolicy` | Yes | Ordered fallback actions and suppress thresholds. |
| `validationFindings[]` | Yes | Hard-rule failures and reason codes from validator. |
| `backupCandidatesBySlot` | Optional | Ranked substitutes per slot from decisioning/catalog projections. |
| `surfaceContext` | Yes | `surface`, `placement`, `market`, `mode`, campaign/experiment refs. |
| `anchorContext` | Conditional | Required for anchor-led paths (PDP/cart). |
| `traceContext` | Yes | `traceId`, `recommendationSetId`, policy versions, timestamps. |

## 6. Outputs

| Output | Description |
| --- | --- |
| `fallbackDecision` | `valid`, `degraded`, or `suppressed`. |
| `resolvedAssemblyPlan` | Final grouped outfit payload if not suppressed. |
| `slotResolution[]` | Per-slot action: `kept`, `substituted`, `omitted`, `unresolved`. |
| `degradationSummary` | Machine-readable degradation code set and customer-safe message key. |
| `fallbackTrace` | Ordered decisions, candidate counts, policy references, and reason lineage. |
| `deliveryHints` | UI-safe flags (for example, show degraded badge, hide optional section). |

## 7. Workflow / Lifecycle

1. **Receive candidate assembly** after initial validation (`candidate_validated`).
2. **Detect gaps/failures** by slot (`gap_detected`).
3. **Build fallback plan** using policy precedence (`fallback_plan_built`).
4. **Apply bounded actions** in sequence: substitute required slots, omit optional slots, re-evaluate viability (`fallback_applied`).
5. **Revalidate outcome** against hard constraints (`fallback_revalidated`).
6. **Classify result** as `valid`, `degraded`, or `suppressed` (`fallback_classified`).
7. **Emit payload + trace metadata** to delivery and analytics (`fallback_emitted`).

`degraded` is a successful response state with constrained quality, not a processing failure.

## 8. Business Rules

- Recommendation type must remain `outfit`; fallback cannot auto-convert to cross-sell or upsell sets.
- Required vs optional slot definitions come only from versioned policy/config, not hardcoded surface logic.
- Anchor slot is immutable for anchor-led requests unless request mode explicitly changes.
- Optional slots may be omitted before required slots are substituted.
- Required slot omission is allowed only if current `fallbackPolicy` explicitly allows a degraded minimum that remains a credible outfit.
- If minimum viable outfit criteria are not satisfied, controller must return `suppressed` with explicit reason codes.
- Customer-safe explanation text must be abstracted via message keys; no sensitive rule or profile reasoning in consumer payloads.
- All fallback decisions must include `traceId`, `recommendationSetId`, and policy version references.
- Open decisions remain unresolved here and must be honored as policy inputs:
  - `DEC-018`: required vs optional slot composition by anchor/surface/mode,
  - `DEC-019`: substitution vs omission policy and suppress threshold,
  - `DEC-020`: primary anchor rules in multi-anchor contexts.

## 9. Configuration Model

### Core config groups

- `fallbackPolicy` - action precedence and suppression thresholds.
- `slotCriticalityPolicy` - required/optional slot classification per template and surface.
- `surfaceFallbackPolicy` - PDP/cart/other surface behavior and messaging keys.
- `modeFallbackPolicy` - RTW vs CM allowances.
- `reasonCodePolicy` - standard code taxonomy and consumer-safe mapping.

### Example configuration shape (illustrative)

```json
{
  "policyVersion": "fallback-v3",
  "surface": "pdp",
  "mode": "rtw",
  "actionOrder": ["substitute_required", "omit_optional", "suppress_if_below_minimum"],
  "minimumViable": {
    "mustIncludeSlots": ["anchor", "shirt", "shoes"],
    "allowOptionalOmission": true
  },
  "reasonCodePolicy": {
    "inventory_gap": "INV_GAP",
    "governance_block": "GOV_BLOCK",
    "template_gap": "TPL_GAP"
  }
}
```

## 10. Data Model

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `OutfitFallbackPlan` | Decision plan for current assembly | `planId`, `traceId`, `policyVersion`, `inputAssemblyId`, `decisionState` |
| `SlotResolution` | Per-slot outcome after fallback | `slotName`, `action`, `fromProductId`, `toProductId`, `reasonCodes[]` |
| `DegradationSummary` | Aggregate explanation of degraded result | `degradationLevel`, `degradationCodes[]`, `customerMessageKey` |
| `FallbackAuditRecord` | Persisted operator/support replay record | `recommendationSetId`, `traceId`, `policyRefs`, `candidateCounts`, timestamps |
| `SuppressionRecord` | Explicit no-delivery result | `suppressionCode`, `blockingSlots[]`, `surface`, `mode`, `market` |

Use canonical IDs and source references from `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal endpoints:

- `POST /internal/outfit-fallback/evaluate`
  - Input: `assemblyPlan`, `validationFindings`, `policyContext`.
  - Output: `fallbackDecision`, `resolvedAssemblyPlan`, trace fields.
- `POST /internal/outfit-fallback/replay`
  - Input: `traceId` or `recommendationSetId` + historical policy version.
  - Output: deterministic replay decision for support/audit.
- `GET /internal/outfit-fallback/policies/{policyVersion}`
  - Read-only policy inspection for operator/debug tooling.

Transport and envelope details remain architecture-stage decisions.

## 12. Events Produced

- `outfit.fallback.applied`
- `outfit.fallback.degraded`
- `outfit.fallback.suppressed`
- `outfit.fallback.replay.completed`

Minimum event fields:

- `eventId`, `occurredAt`, `traceId`, `recommendationSetId`,
- `surface`, `mode`, `market`, `policyVersion`,
- `decisionState`, `degradationCodes[]`, `slotResolution[]`.

## 13. Events Consumed

- `outfit.validation.blocked`
- `outfit.validation.partial`
- `catalog.inventory.changed`
- `governance.snapshot.published`
- `outfit.anchor.resolved` (for anchor context in multi-anchor/cart flows)

## 14. Integrations

- **Template selection and slot filling**: receives initial slot coverage and candidate pool lineage.
- **Governance and inventory validation**: consumes hard-rule failures and freshness constraints.
- **Internal assemble contract and trace emission**: forwards final fallback-classified payload and metadata.
- **Shared contracts and delivery API**: ensures output is packaged as `outfit` or explicit suppression.
- **Analytics and experimentation**: emits reason-coded degraded/suppressed telemetry.
- **Explainability and auditability**: persists policy/decision lineage for operator replay.

## 15. UI Components

Consumer components (surface teams):

- grouped outfit card with optional degraded-state indicator,
- slot-level missing/substituted presentation hooks,
- optional slot section that can collapse when omitted.

Operator/support components:

- fallback timeline panel (decision steps),
- slot resolution diff table (`from` -> `to`),
- reason-code chips with policy version badges.

## 16. UI Screens

- **PDP complete-look module**: supports degraded-but-valid rendering without misleading "full look" claims.
- **Cart complete-the-look module**: highlights duplicate-aware substitutions and suppressed outcomes cleanly.
- **Merchandising review screen**: filters repeated degradation patterns by anchor class and market.
- **Support trace screen**: replay and inspect fallback decisions by `traceId` or `recommendationSetId`.

## 17. Permissions & Security

- Only orchestration services may execute fallback write decisions in production paths.
- Operator replay endpoints are read-only and role-gated.
- Consumer payloads must not expose sensitive profile/governance rationale.
- Trace access should be scoped by role and audited (read and replay actions).
- Persisted fallback records must follow platform retention and redaction policies.

## 18. Error Handling

Error classes:

- `FALLBACK_INPUT_INVALID` - malformed or incomplete input payload.
- `POLICY_NOT_FOUND` - missing policy version for request scope.
- `FALLBACK_REVALIDATION_FAILED` - fallback outcome still violates hard constraints.
- `TRACE_WRITE_FAILED` - decision computed but trace persistence failed.

Handling requirements:

- distinguish computation errors from valid `suppressed` outcomes,
- return deterministic reason codes for all non-success paths,
- fail closed to suppression (not unsafe delivery) when hard constraints cannot be evaluated.

## 19. Edge Cases

- **Anchor unavailable after late inventory change**: required anchor becomes unsellable between fill and delivery.
- **No substitute for required slot**: candidate pool exhausted after governance blocks.
- **Conflicting policy snapshots**: policy version mismatch between validator and fallback controller.
- **Cart multi-anchor ambiguity**: fallback receives competing anchor candidates and must respect resolved primary anchor.
- **CM mode boundaries**: request context asks for CM depth not allowed in self-serve path.
- **Duplicate reintroduction**: substitution candidate would re-add in-cart duplicate.

## 20. Performance Considerations

- Keep fallback evaluation in the interactive serving path budget for PDP/cart.
- Prefer projection-backed backup candidate reads (avoid full recomputation at request time).
- Use bounded substitution search depth per slot to avoid latency spikes.
- Cache policy snapshots by `policyVersion` + scope (`surface`, `market`, `mode`).
- Emit lightweight decision traces synchronously; heavy analytics enrichment can be async.

## 21. Observability

Required metrics:

- fallback invocation count by surface/mode,
- degraded rate and suppressed rate,
- top degradation reason codes,
- average required-slot substitution attempts,
- replay volume and replay mismatch rate.

Required logs/traces:

- `traceId`, `recommendationSetId`, policy versions, slot-resolution summary,
- deterministic decision path (`actionOrder` and first successful action),
- linkage to upstream validation and downstream delivery events.

Alert examples:

- sudden suppression spike for a major anchor class,
- policy-not-found errors above threshold,
- sustained increase in `inventory_gap` degradation codes.

## 22. Example Scenarios

### Scenario A: PDP suit anchor, optional slot omission

1. Suit-led outfit is assembled with `anchor`, `shirt`, `tie`, `shoes`, optional `belt`.
2. `belt` fails inventory freshness check.
3. Policy allows optional omission; controller removes `belt`, marks `degraded`.
4. Output remains a valid `outfit` with degradation code `INV_GAP_OPTIONAL`.

### Scenario B: Cart flow, required shirt substitution

1. Cart-based outfit has valid anchor and shoes; shirt becomes governance-blocked.
2. Controller finds next ranked shirt candidate that passes rules.
3. Slot action: `substituted`; result classified `degraded`.
4. Trace includes old/new product IDs and governance reason lineage.

### Scenario C: No viable required-slot recovery

1. Anchor is valid, but both required `shirt` and `shoes` cannot be filled.
2. Policy minimum viable criteria are not met.
3. Controller emits `suppressed` with `blockingSlots = ["shirt","shoes"]`.
4. Delivery receives explicit suppression state, not a flat item list.

### Illustrative response payload

```json
{
  "fallbackDecision": "degraded",
  "traceId": "TR-12345",
  "recommendationSetId": "RS-9001",
  "policyVersion": "fallback-v3",
  "slotResolution": [
    { "slotName": "anchor", "action": "kept", "reasonCodes": [] },
    { "slotName": "shirt", "action": "substituted", "fromProductId": "P-210", "toProductId": "P-212", "reasonCodes": ["GOV_BLOCK"] },
    { "slotName": "belt", "action": "omitted", "reasonCodes": ["INV_GAP"] }
  ],
  "degradationSummary": {
    "degradationLevel": "partial",
    "degradationCodes": ["GOV_BLOCK_REQUIRED_RECOVERED", "INV_GAP_OPTIONAL"],
    "customerMessageKey": "outfit.partial_availability"
  }
}
```

## 23. Implementation Notes

### Backend/service implications

- Implement as a distinct module in complete-look orchestration pipeline, called after validation and before delivery packaging.
- Keep deterministic rule execution order via policy (`actionOrder`) to support replay and incident triage.
- Persist fallback decisions in an audit-friendly store keyed by `recommendationSetId` and `traceId`.

### Data/storage implications

- Store per-request fallback record plus compact per-slot resolution records.
- Partition by event date and surface for operational analytics.
- Keep policy snapshot reference, not policy body duplication, where possible.

### Worker/async implications

- Synchronous path computes decision for serving.
- Async worker enriches analytics aggregates (reason-code trend tables, hot-anchor suppression monitors).

### Cross-module alignment

- Do not duplicate validation logic from governance/inventory validator.
- Do not mutate ranking logic; consume ranked backup candidates as inputs.
- Preserve shared contract semantics from `shared-contracts-and-delivery-api`.

## 24. Testing Requirements

Minimum test suite:

- **Unit tests**
  - action precedence (substitute before omit, suppress threshold behavior),
  - reason-code mapping and message-key mapping,
  - deterministic replay for identical inputs and policy version.
- **Contract tests**
  - `fallbackDecision` envelope and slot-resolution schema,
  - event payload fields for degraded/suppressed states.
- **Integration tests**
  - validator -> fallback -> delivery pipeline behavior,
  - cross-surface policy scoping (`pdp`, `cart`, RTW/CM hooks),
  - duplicate suppression interactions in cart flows.
- **Regression tests**
  - known degraded fixtures for top anchor classes,
  - suppression behavior when minimum viability is not met.
- **Observability tests**
  - metrics emitted for degraded/suppressed outcomes,
  - trace linkage (`traceId`, `recommendationSetId`) preserved through outcome events.

Exit criteria for this capability in implementation planning:

- no silent downgrade from `outfit` semantics,
- all degraded/suppressed outcomes carry reason codes and trace linkage,
- replay endpoint reproduces classification for fixed input + policy version.
