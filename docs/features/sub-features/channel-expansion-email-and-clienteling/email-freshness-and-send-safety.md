# Sub-feature capability: Email Freshness And Send Safety

**Parent feature:** `Channel expansion: email and clienteling`  
**Parent feature file:** `docs/features/channel-expansion-email-and-clienteling.md`  
**Parent feature priority:** `P3`  
**Sub-feature directory:** `docs/features/sub-features/channel-expansion-email-and-clienteling/`  
**Upstream traceability:** `docs/features/channel-expansion-email-and-clienteling.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-003, BR-006, BR-008, BR-009, BR-010, BR-011, BR-012); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`)  
**Tracked open decisions:** `DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`

---

## 1. Purpose

Validate recommendation-package freshness and send safety immediately before email send handoff, so outbound recommendation content does not go stale, violate suppression policy, or reference inventory-ineligible products.

This capability defines deterministic send-time gating behavior for recommendation packages: `send`, `regenerate_then_send`, `degrade_then_send`, `hold`, or `suppress`.

## 2. Core Concept

`Email Freshness And Send Safety` is a policy-evaluation module between email package generation and ESP handoff.

It does not generate recommendations itself. Instead, it evaluates whether an existing email package is still safe to send, based on:

- package freshness windows (`generatedAt`, `freshUntil`)
- inventory and catalog eligibility state
- consent/suppression posture
- governance constraints and campaign send-window policy

The output is a normalized `SendSafetyDecision` with reason codes and policy version, so campaign tooling, operators, and telemetry systems consume one consistent outcome model.

## 3. User Problems Solved

- **Marketing operators:** know whether a package is truly send-safe before launch, not after customer impact.
- **Customers:** receive fewer stale, unavailable, or policy-ineligible recommendations in email.
- **Merchandising/governance teams:** enforce safe fallback behavior instead of silent send failures or hidden substitutions.
- **Analytics/support teams:** get explicit reason-coded outcomes for hold, suppression, and regeneration decisions.

## 4. Trigger Conditions

- Scheduled send window opens for a recommendation package or send batch.
- Operator requests pre-send validation from campaign preview/approval UI.
- Inventory, suppression, or governance updates occur after package generation.
- Retry flow evaluates previously held packages.
- Policy version changes require re-evaluation of queued packages.

## 5. Inputs

Required inputs:

- `packageId`, `recommendationSetId`, `traceId`
- `campaignId`, `channel=email`, `surface`
- `generatedAt`, `freshUntil`, planned `sendAt`
- packaged item list (canonical product IDs, recommendation type per item)
- current inventory/readiness snapshot
- consent/suppression eligibility decision for target audience/customer
- active policy version and market/channel scope

Supporting inputs:

- fallback configuration (allowed recommendation types, min viable item count)
- governance context (campaign/rule/override references)
- prior regeneration history and retry counts

## 6. Outputs

Primary output: `SendSafetyDecision`

Core fields:

- `decisionId`
- `packageId`, `recommendationSetId`, `traceId`
- `decision` (`send`, `regenerate_then_send`, `degrade_then_send`, `hold`, `suppress`)
- `decisionStatus` (`pass`, `degraded`, `blocked`)
- `reasonCodes[]`
- `policyVersion`
- `evaluatedAt`
- `expiresAt`

Downstream action fields:

- `requiresRegeneration` (boolean)
- `requiresOperatorReview` (boolean)
- `hardenedFallbackState` (`none`, `degraded_inventory`, `degraded_freshness`, `suppressed`)
- `sendAllowedUntil`

## 7. Workflow / Lifecycle

1. **Load package context**
   - Retrieve package metadata, item list, and policy scope.
2. **Evaluate freshness gate**
   - Compare `sendAt`/current time to `freshUntil`.
3. **Evaluate inventory and eligibility gate**
   - Re-check item-level in-stock/eligibility status.
4. **Evaluate consent/suppression gate**
   - Validate personalization and activation posture.
5. **Apply decision matrix**
   - Choose `send`, `regenerate_then_send`, `degrade_then_send`, `hold`, or `suppress`.
6. **Persist decision and state transition**
   - Write immutable decision record and update package status.
7. **Trigger follow-up actions**
   - Regeneration job, hold notification, or send handoff as applicable.
8. **Emit telemetry and audit events**
   - Publish normalized events with reason codes and IDs.

Package state progression:

`generated -> pending_send_validation -> send_safe | regenerate_requested | degraded_send_ready | held | suppressed -> sent | expired`

## 8. Business Rules

1. A package must not be sent if freshness window is exceeded.
2. Suppression/consent-denied posture overrides all send intents.
3. Out-of-stock or ineligible items must trigger either regeneration or governed degradation, never silent send.
4. Degraded send is allowed only when fallback policy minimums are met (for example minimum item count by recommendation type).
5. Every decision must preserve `recommendationSetId` and `traceId` for telemetry/audit continuity.
6. Decision outcomes must be explicit; consumers may not infer safety from missing fields.
7. Campaign vs personalization precedence behavior remains linked to `DEC-008`.
8. Final freshness thresholds and regeneration policy remain linked to `DEC-010`.
9. Surface-level inventory freshness windows remain linked to `DEC-016`.
10. Final transport/contract freeze remains linked to `DEC-003`.
11. This capability stays aligned with `docs/features/channel-expansion-email-and-clienteling.md`.

## 9. Configuration Model

Representative keys:

- `emailSendSafety.enabled`
- `emailSendSafety.policyVersion`
- `emailSendSafety.maxPackageAgeMinutes`
- `emailSendSafety.sendValidationLeadMinutes`
- `emailSendSafety.inventoryFailureAction` (`regenerate`, `degrade`, `hold`)
- `emailSendSafety.minItemsByRecommendationType`
- `emailSendSafety.maxRegenerationAttempts`
- `emailSendSafety.holdEscalationMinutes`
- `emailSendSafety.marketPolicy[marketCode]`
- `emailSendSafety.requireOperatorApprovalForDegradedSend`

Scope dimensions:

- environment
- market/region
- channel/surface
- campaign type

## 10. Data Model

Primary entities:

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `EmailPackageSendSafetyCheck` | one evaluation run for a package | `checkId`, `packageId`, `campaignId`, `evaluatedAt`, `policyVersion`, `freshnessResult`, `inventoryResult`, `suppressionResult`, `decision`, `reasonCodes[]` |
| `SendSafetyDecision` | canonical decision record used by consumers | `decisionId`, `packageId`, `recommendationSetId`, `traceId`, `decision`, `decisionStatus`, `requiresRegeneration`, `requiresOperatorReview`, `expiresAt` |
| `PackageRegenerationRequest` | tracks regeneration attempts after failed safety checks | `regenerationId`, `packageId`, `attempt`, `triggerReason`, `requestedAt`, `status` |
| `PackageHoldRecord` | explicit hold lifecycle for blocked sends | `holdId`, `packageId`, `holdReasonCodes[]`, `createdAt`, `releasedAt`, `releasedBy` |
| `SendSafetyAuditEntry` | immutable audit line for policy and operator actions | `auditId`, `decisionId`, `actorType`, `action`, `actionAt`, `inputSnapshotRefs[]` |

Data standards alignment:

- canonical IDs and source mappings per `docs/project/data-standards.md`
- timezone-safe UTC timestamps
- explicit null vs unknown values where safety logic depends on presence
- stable reason-code enums for analytics and support

## 11. API Endpoints

Illustrative feature-stage operations:

- `POST /email/packages/{packageId}:validate-send-safety`
- `GET /email/packages/{packageId}/send-safety-decisions/{decisionId}`
- `POST /email/packages/{packageId}:regenerate`
- `POST /email/send-batches/{batchId}:validate-send-safety`

Example request:

```json
{
  "packageId": "pkg_001",
  "campaignId": "cmp_spring_refresh",
  "sendAt": "2026-03-22T12:30:00Z",
  "channel": "email",
  "surface": "lifecycle_followup",
  "traceId": "trace_01HXYZ"
}
```

Example response:

```json
{
  "decisionId": "ssd_101",
  "packageId": "pkg_001",
  "recommendationSetId": "recset_01HXYZ",
  "traceId": "trace_01HXYZ",
  "decision": "regenerate_then_send",
  "decisionStatus": "blocked",
  "reasonCodes": ["FRESHNESS_WINDOW_EXCEEDED", "INVENTORY_ITEM_UNAVAILABLE"],
  "requiresRegeneration": true,
  "requiresOperatorReview": false,
  "policyVersion": "email-send-safety-v2",
  "evaluatedAt": "2026-03-22T12:05:00Z"
}
```

Final endpoint naming, schema freeze, and versioning remain dependent on `DEC-003`.

## 12. Events Produced

- `email_package.send_safety_checked`
- `email_package.send_allowed`
- `email_package.regeneration_requested`
- `email_package.degraded_send_ready`
- `email_package.send_held`
- `email_package.send_suppressed`

## 13. Events Consumed

- `email_package.generated`
- `campaign.send_window.started`
- `catalog.inventory_snapshot.updated`
- `channel_personalization.decision_changed`
- `suppression.state.changed`
- `governance.rule_context.updated`

## 14. Integrations

- email recommendation packaging capability
- consent/identity/suppression decision capability
- catalog and product intelligence (inventory/readiness state)
- merchandising governance and operator controls
- analytics and experimentation
- explainability and auditability
- campaign orchestration and ESP handoff system
- shared recommendation delivery contracts

## 15. UI Components

- send-readiness status badge per package
- package safety decision timeline
- hold/suppression reason-code panel
- regeneration action card with attempt history
- degraded-send warning badge with approval action

These are operator/support components and do not alter customer-facing recommendation meaning.

## 16. UI Screens

- campaign preview and approval screen
- send batch readiness screen
- package validation diagnostics screen
- support/audit trace lookup screen

## 17. Permissions & Security

- Validation and decision-write endpoints are service-to-service only.
- Operator override or degraded-send approval requires elevated role permissions.
- Non-privileged users may view status but not policy internals or sensitive suppression detail.
- All state transitions must include actor identity and immutable audit timestamps.
- Logs and exports must redact sensitive identity/suppression payloads while preserving reason codes.

## 18. Error Handling

Error classes:

- `VALIDATION_ERROR` (missing IDs, invalid timestamps, malformed package state)
- `DEPENDENCY_UNAVAILABLE` (inventory or suppression source unavailable)
- `POLICY_CONFIGURATION_ERROR` (missing market policy)
- `STATE_CONFLICT` (package already sent/expired/locked)

Handling rules:

- Never default to `send` when required safety inputs are missing.
- On dependency failure, return configured safe posture (`hold` or `suppress`) with explicit reason codes.
- Distinguish degraded-safe outcomes from hard failures.
- Preserve `traceId` across all failure paths for downstream debugging.

## 19. Edge Cases

- Package passes validation, then inventory changes before actual send handoff.
- Consent/suppression status changes between validation and send execution.
- Multiple concurrent validators race on same package.
- Regeneration loop repeatedly fails and approaches max attempts.
- Batch has mixed outcomes (some packages send-safe, others held/suppressed).
- Out-of-order events cause stale decision replay attempts.

## 20. Performance Considerations

- Support high-throughput batch validation near campaign send windows.
- Use projection-backed lookups for package/inventory/suppression state to keep validation latency bounded.
- Ensure idempotent decision writes to avoid duplicate regeneration/hold actions.
- Separate hot-path decision store from analytics projections for stable send-time performance.
- Monitor validation queue lag to avoid missing send windows.

## 21. Observability

Required metrics:

- validation throughput by campaign and market
- validation latency (p50/p95/p99)
- decision distribution (`send`, `regenerate`, `degrade`, `hold`, `suppress`)
- regeneration attempt rate and success rate
- hold backlog age and escalation rate

Required logs/traces:

- correlation by `packageId`, `recommendationSetId`, `traceId`, `campaignId`
- policy version in every decision record
- reason-code distribution for blocked/degraded outcomes

Alerts:

- spike in `hold`/`suppress` outcomes for active campaign
- validation lag approaching send window
- repeated regeneration failures above threshold

## 22. Example Scenarios

### Scenario A: Happy path, send-safe package

1. Package `pkg_100` enters pre-send validation 20 minutes before send.
2. Freshness, inventory, and suppression checks pass.
3. Decision is `send`; package moves to ESP handoff queue.

### Scenario B: Stale package with inventory drift

1. Package `pkg_200` is validated after `freshUntil`.
2. One core outfit item is now unavailable.
3. Decision is `regenerate_then_send`; regeneration job is queued.
4. If regeneration fails beyond retry limit, package transitions to `hold` with escalation.

Illustrative event payload:

```json
{
  "eventName": "email_package.send_safety_checked",
  "decisionId": "ssd_210",
  "packageId": "pkg_200",
  "campaignId": "cmp_wedding_season",
  "decision": "regenerate_then_send",
  "decisionStatus": "blocked",
  "reasonCodes": ["FRESHNESS_WINDOW_EXCEEDED", "INVENTORY_ITEM_UNAVAILABLE"],
  "recommendationSetId": "recset_200",
  "traceId": "trace_200",
  "policyVersion": "email-send-safety-v2",
  "evaluatedAt": "2026-03-22T11:58:00Z"
}
```

## 23. Implementation Notes

Implementation implications:

- **Backend services:** implement as dedicated send-safety evaluator in channel-expansion domain; keep decisioning deterministic and idempotent.
- **Data stores:** persist immutable safety checks, decisions, holds, and regeneration records with policy versioning.
- **Jobs/workers:** run batch validator and regeneration workers with retry/backoff and dead-letter handling.
- **Integrations:** consume package, suppression, and inventory snapshots through canonical internal contracts only.
- **Operator UI:** expose reason-coded status and controlled override actions without exposing sensitive internals.

Assumptions:

- Upstream systems provide timely inventory and suppression snapshots near send-time windows.
- Campaign orchestration supports hold/retry/suppress package states.

Unresolved decisions carried forward:

- `DEC-010` for exact freshness threshold and regeneration policy.
- `DEC-016` for inventory freshness window specifics by surface.
- `DEC-008` for campaign-vs-personalization precedence when fallback choices conflict.
- `DEC-003` for final contract transport/versioning.
- `DEC-011` for clienteling explanation boundaries where shared reason taxonomy is reused.

## 24. Testing Requirements

Unit tests:

- freshness boundary evaluation (`freshUntil` edge conditions)
- decision matrix precedence (suppression > freshness > inventory fallback)
- reason-code assignment for each decision branch
- idempotent decision-write behavior

Contract tests:

- validate-send-safety API schema and required fields
- produced event payload schema (`decision`, `reasonCodes`, IDs, policy version)
- hold/regeneration state transition payload compatibility

Integration tests:

- package generation -> send safety -> send handoff happy path
- stale package -> regeneration -> revalidation flow
- suppression change before send causing hold/suppress outcome
- inventory change between validation and send requiring recheck

Non-functional and resilience tests:

- batch validation throughput near campaign peaks
- retry and dead-letter behavior for failed regenerations
- dependency outage fail-safe behavior (`hold`/`suppress`, never implicit send)
- observability assertions for metrics, logs, and reason-code dashboards
