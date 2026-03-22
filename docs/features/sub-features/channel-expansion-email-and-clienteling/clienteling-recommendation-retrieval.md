# Sub-feature capability: Clienteling Recommendation Retrieval

**Parent feature:** `Channel expansion: email and clienteling`  
**Parent feature file:** `docs/features/channel-expansion-email-and-clienteling.md`  
**Parent feature priority:** `P3`  
**Sub-feature directory:** `docs/features/sub-features/channel-expansion-email-and-clienteling/`  
**Upstream traceability:** `docs/features/channel-expansion-email-and-clienteling.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-003, BR-006, BR-009, BR-011, BR-012); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`)  
**Tracked open decisions:** `DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`

---

## 1. Purpose

Retrieve recommendation sets for authenticated clienteling sessions so associates can confidently use outfit, cross-sell, upsell, and personal recommendations during live assisted selling.

The capability must preserve the same recommendation contract semantics used across channels while adding clienteling-specific context handling (appointment, associate role, share intent, and low-latency refresh).

## 2. Core Concept

Clienteling recommendation retrieval is a surface-specific consumer path on top of the shared recommendation delivery contract, not a separate recommendation engine.

It translates operator session context into a request to shared decisioning and returns:

- typed recommendation groups (for example `outfit`, `cross-sell`, `upsell`, `personal`)
- stable IDs (`recommendationSetId`, `traceId`)
- operator-safe explanation summary
- freshness and fallback state
- governance context needed for audits and downstream adaptation workflows

## 3. User Problems Solved

- **Stylist speed:** reduces manual product hunting during appointments by returning a coherent first-pass recommendation set quickly.
- **Cross-channel consistency:** prevents clienteling from drifting into a separate semantic model from ecommerce and email.
- **Operator trust:** provides bounded explanation and status metadata so associates understand if output is personalized, degraded, or fallback.
- **Audit safety:** records who retrieved which recommendation set for which customer/session context.

## 4. Trigger Conditions

- Associate opens an appointment or customer profile in the clienteling application.
- Associate selects an anchor product during a session and requests recommendations.
- Associate manually refreshes recommendations after customer preferences change.
- Session context updates (appointment type, location, mode, or customer identity confidence) require re-retrieval.

## 5. Inputs

Required request inputs:

- `associateId`, `associateRole`, and authenticated session token
- `customerId` (canonical) plus `identityConfidence`
- `surface = clienteling_session` and `channel = clienteling`
- requested recommendation types (`outfit`, `cross-sell`, `upsell`, `personal`, optional `occasion-based`)
- optional `appointmentId`
- optional `anchorProductId` or `lookId`
- optional session intent (`wedding`, `business`, `seasonal_refresh`, etc.)

Derived/lookup inputs:

- consent and suppression state
- style profile and recent signal summary
- market/store context
- inventory and catalog eligibility snapshot
- active governance context (campaigns, rules, and overrides)

## 6. Outputs

The capability returns a clienteling retrieval response containing:

- `recommendationSetId` and `traceId`
- `customerId`, `associateId`, optional `appointmentId`
- typed recommendation collections with ordered items
- `fallbackState` (`none`, `degraded_inventory`, `degraded_identity`, `suppressed`)
- freshness metadata (`generatedAt`, `freshUntil`)
- operator-safe explanation summary (source mix, active campaign/rule context, confidence tier)
- `adaptationAllowed` and policy version references for downstream operator actions

## 7. Workflow / Lifecycle

1. **Authorize and normalize context**
   - Validate associate auth and role access.
   - Resolve customer identity and confidence status.
2. **Build shared retrieval request**
   - Compose request using session, appointment, anchor, and recommendation-type intent.
3. **Call shared recommendation contract**
   - Retrieve recommendation output with stable IDs and channel/surface metadata.
4. **Apply clienteling retrieval policy**
   - Enforce suppression, fallback, and explanation-depth rules.
   - Mark degraded states explicitly if required inputs are weak.
5. **Persist retrieval audit**
   - Store retrieval record with session references and policy version.
6. **Return response to clienteling UI**
   - Surface recommendation groups, explanation summary, and refresh metadata.
7. **Refresh cycle**
   - On manual refresh or context change, issue new `recommendationSetId` linked by lineage.

## 8. Business Rules

1. Clienteling retrieval must preserve shared recommendation semantics from BR-003; no surface-specific taxonomy is allowed.
2. All retrieval responses must include `recommendationSetId` and `traceId`.
3. Personalized retrieval requires acceptable consent and identity confidence; otherwise return bounded degraded output.
4. Clienteling can include richer explanation than customer-facing channels, but must remain privacy-safe (BR-011).
5. Recommendation types returned must remain explicit; do not flatten outfit outputs into generic item lists.
6. Recommendation precedence and campaign/personalization conflict handling must follow `DEC-008` once resolved.
7. Retrieval must expose freshness state so operators can identify stale or regenerated sets (`DEC-016` dependency).
8. Open decisions must remain explicit and unresolved in this artifact: `DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`.

## 9. Configuration Model

Representative configuration keys:

- `clientelingRetrieval.enabled`
- `clientelingRetrieval.allowedRecommendationTypes[]`
- `clientelingRetrieval.explanationTierByRole`
- `clientelingRetrieval.maxIdentityConfidenceForPersonalization`
- `clientelingRetrieval.defaultFallbackStrategy`
- `clientelingRetrieval.refreshCooldownSeconds`
- `clientelingRetrieval.cacheTtlSeconds`
- `clientelingRetrieval.auditRetentionDays`
- `clientelingRetrieval.policyVersion`

Configuration scope:

- environment
- market
- store group
- channel/surface
- mode (`RTW`, `CM` where applicable)

## 10. Data Model

Core entities:

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `ClientelingRetrievalRequest` | normalized request envelope | `requestId`, `associateId`, `customerId`, `appointmentId?`, `surface`, `channel`, `requestedTypes[]`, `anchorProductId?`, `mode`, `requestedAt` |
| `ClientelingSessionRecommendation` | primary retrieval response record | `recommendationSetId`, `traceId`, `requestId`, `customerId`, `associateId`, `generatedAt`, `freshUntil`, `fallbackState`, `policyVersion` |
| `ClientelingRecommendationItem` | ordered recommendation member | `recommendationSetId`, `itemId`, `productId`, `recommendationType`, `position`, `sourceMix`, `reasonCodes[]` |
| `ClientelingRetrievalAudit` | retrieval-level audit trail | `auditId`, `recommendationSetId`, `traceId`, `associateId`, `customerId`, `action`, `actionAt`, `sessionContext`, `securityContext` |
| `ClientelingRefreshLineage` | links refresh cycles | `lineageId`, `previousRecommendationSetId`, `newRecommendationSetId`, `refreshTrigger`, `createdAt` |

Standards alignment:

- canonical IDs and source mappings follow `docs/project/data-standards.md`
- timestamp fields are timezone-safe and normalized
- null values are distinguishable from unknown/not-applicable for ranking and governance logic

## 11. API Endpoints

Illustrative operations (feature-stage, non-normative transport/version):

- `GET /clienteling/customers/{customerId}/recommendations`
- `POST /clienteling/sessions/{sessionId}/recommendations:refresh`
- `GET /clienteling/recommendations/{recommendationSetId}`

Example retrieval request:

```json
{
  "associateId": "assoc_789",
  "appointmentId": "appt_456",
  "customerId": "cust_123",
  "requestedTypes": ["outfit", "cross-sell", "personal"],
  "anchorProductId": "prod_suit_navy_001",
  "mode": "RTW",
  "surface": "clienteling_session",
  "channel": "clienteling"
}
```

Example retrieval response:

```json
{
  "recommendationSetId": "recset_01HABC",
  "traceId": "trace_01HABC",
  "customerId": "cust_123",
  "associateId": "assoc_789",
  "appointmentId": "appt_456",
  "surface": "clienteling_session",
  "channel": "clienteling",
  "generatedAt": "2026-03-22T10:15:00Z",
  "freshUntil": "2026-03-22T10:45:00Z",
  "fallbackState": "none",
  "recommendations": [
    {
      "type": "outfit",
      "items": [
        { "productId": "prod_suit_navy_001", "position": 1 },
        { "productId": "prod_shirt_white_014", "position": 2 }
      ]
    },
    {
      "type": "cross-sell",
      "items": [
        { "productId": "prod_belt_brown_020", "position": 1 }
      ]
    }
  ],
  "explanationSummary": {
    "sourceMix": "curated_plus_rules_plus_ai",
    "profileConfidence": "high",
    "activeCampaignIds": ["cmp_wedding_season"]
  },
  "adaptationAllowed": true,
  "policyVersion": "clienteling-retrieval-v1"
}
```

Final contract freeze remains dependent on `DEC-003`.

## 12. Events Produced

Required event families:

- `clienteling_recommendation.requested`
- `clienteling_recommendation.retrieved`
- `clienteling_recommendation.refresh_requested`
- `clienteling_recommendation.refreshed`
- `clienteling_recommendation.retrieval_failed`
- `clienteling_recommendation.degraded`

Minimum event payload fields:

- `eventTimestamp`
- `associateId`
- `customerId` (or policy-safe surrogate when required)
- `channel`, `surface`
- `recommendationSetId`
- `traceId`
- `recommendationTypes[]`
- `fallbackState`
- `ruleContext`
- `experimentContext`

## 13. Events Consumed

- `identity.activation.evaluated`
- `customer.profile.updated`
- `appointment.context.updated`
- `catalog.inventory_snapshot.updated`
- `governance.snapshot.published`
- `consent.suppression.updated`

Consumed events should invalidate stale session context or trigger safe refresh prompts in the clienteling surface.

## 14. Integrations

Core integrations:

- shared contracts and delivery API
- identity and style profile service
- customer signal ingestion
- merchandising governance and operator controls
- explainability and auditability services
- analytics and experimentation pipeline
- catalog and product intelligence

Adjacent integrations:

- clienteling application and associate auth provider
- appointment/store scheduling system
- share/adaptation sub-feature APIs in the same feature domain

## 15. UI Components

- Clienteling recommendation panel (grouped by recommendation type)
- Recommendation type tabs/chips (`outfit`, `cross-sell`, `upsell`, `personal`)
- Explanation summary drawer (role-scoped)
- Freshness/fallback status badges
- Manual refresh control with lineage indicator
- Retrieval error/degraded state component

## 16. UI Screens

- Appointment detail screen (recommended outfits for active appointment)
- Customer profile clienteling screen (history + current retrieval)
- Session consultation screen (live retrieval + refresh)
- Retrieval diagnostics view for support/governance roles

## 17. Permissions & Security

- Retrieval requires authenticated associate identity and role.
- Role determines explanation depth visibility and whether personal recommendation types may be requested.
- Access to raw trace details is restricted to authorized internal roles.
- Logs and events must redact sensitive profile reasoning for non-privileged contexts.
- Shareable outputs are out of scope for this retrieval endpoint and should pass through governed share flows.
- Every retrieval stores access audit fields (`who`, `when`, `for which customer`, `from which surface`).

## 18. Error Handling

Error classes:

- **Validation errors:** malformed request, invalid type list, missing required context.
- **Authorization errors:** associate role not permitted, session invalid/expired.
- **Dependency errors:** identity/governance/catalog service unavailable.
- **Policy errors:** suppression or consent blocks personalized retrieval.

Required handling behavior:

- Return structured error codes and machine-readable reason fields.
- Distinguish hard failures from degraded successful responses.
- Preserve `traceId` even on failure paths where technically possible.
- Emit failure telemetry for retry and support workflows.

## 19. Edge Cases

- Identity confidence drops mid-session after a successful earlier retrieval.
- Two associates open concurrent sessions for the same customer.
- Anchor product becomes ineligible between request and render.
- Appointment switches from RTW-oriented to CM-oriented intent during consultation.
- Governance override is activated while a cached retrieval response is still fresh.
- Clienteling app is online but one dependency is degraded (partial data available).

## 20. Performance Considerations

- Optimize for in-session retrieval latency through read models and bounded caching.
- Prefetch likely customer/session context when appointment opens.
- Keep response payloads compact for first paint; defer deep trace detail to drill-in views.
- Use refresh cooldown and idempotent request keys to prevent accidental burst traffic.
- Track p95/p99 latency and degraded response ratio by store and market.

## 21. Observability

Required metrics:

- retrieval request rate and success rate
- retrieval latency percentiles
- degraded/suppressed response rate
- refresh frequency and refresh success rate
- dependency error distribution

Required logs/traces:

- correlation by `traceId` and `recommendationSetId`
- associate, session, and customer linkage (policy-safe)
- reason-code distribution for fallbacks and errors

Operational dashboards should separate normal retrieval, degraded retrieval, and failed retrieval paths.

## 22. Example Scenarios

### Scenario A: Appointment happy path (RTW outfit retrieval)

1. Associate opens appointment `appt_456` for customer `cust_123`.
2. Clienteling app requests `outfit` and `cross-sell` recommendations using anchor suit product.
3. Retrieval service returns recommendation set with `fallbackState = none`.
4. Associate sees explanation summary and proceeds to adaptation/share flow if needed.

Emitted event sample:

```json
{
  "eventName": "clienteling_recommendation.retrieved",
  "eventTimestamp": "2026-03-22T10:15:01Z",
  "associateId": "assoc_789",
  "customerId": "cust_123",
  "recommendationSetId": "recset_01HABC",
  "traceId": "trace_01HABC",
  "channel": "clienteling",
  "surface": "clienteling_session",
  "recommendationTypes": ["outfit", "cross-sell"],
  "fallbackState": "none"
}
```

### Scenario B: Degraded identity path during live consultation

1. Associate requests `personal` recommendations for a customer with unresolved identity merge.
2. Service receives `identityConfidence = low`.
3. Service returns recommendation set with `fallbackState = degraded_identity`, excluding profile-heavy personal ranking.
4. UI presents a clear degraded-state badge and allows non-personal types only until confidence improves.

## 23. Implementation Notes

Service boundaries:

- Implement retrieval as a dedicated clienteling-facing orchestration layer over shared recommendation delivery.
- Keep recommendation decisioning centralized in shared services; retrieval layer handles channel policy and response shaping.

Persistence and projections:

- Persist retrieval audit records and refresh lineage.
- Maintain read-optimized session context projections for low-latency request-time assembly.

Backend/worker implications:

- Add cache invalidation consumers for identity, governance, and inventory update events.
- Add lightweight async enrichment where retrieval response needs post-processing metadata.

Assumptions and open decisions:

- Assumes clienteling app can provide stable associate/session identifiers and appointment context.
- Assumes architecture stage will finalize endpoint contract/versioning (`DEC-003`).
- Assumes precedence and explanation-depth policy will be finalized through `DEC-008` and `DEC-011`.
- Freshness and regeneration policy remains linked to portfolio decisions (`DEC-010`, `DEC-016`).

## 24. Testing Requirements

Unit tests:

- request normalization and validation logic
- permission and role-gating behavior
- fallback-state selection (`none`, degraded, suppressed)
- refresh lineage linking behavior

Contract tests:

- request/response schema compatibility with shared delivery contract
- required fields (`recommendationSetId`, `traceId`, `recommendationType`, `fallbackState`)
- event payload schema compliance with telemetry standards

Integration tests:

- identity confidence transitions and consent enforcement
- governance override changes during active sessions
- inventory freshness impacts on retrieval payload
- clienteling UI integration for refresh and degraded state rendering

Non-functional tests:

- latency and throughput under store-hour load
- resilience under dependency timeouts/failures
- audit log completeness and PII redaction validation

Regression tests:

- RTW and CM mode retrieval differences remain explicit
- recommendation type semantics remain stable across API versions
- cross-channel ID continuity for analytics and audit workflows
