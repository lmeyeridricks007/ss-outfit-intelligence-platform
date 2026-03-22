# Sub-feature capability: Cross Channel Telemetry And Attribution

**Parent feature:** `Channel expansion: email and clienteling`  
**Parent feature file:** `docs/features/channel-expansion-email-and-clienteling.md`  
**Parent feature priority:** `P3`  
**Sub-feature directory:** `docs/features/sub-features/channel-expansion-email-and-clienteling/`  
**Upstream traceability:** `docs/features/channel-expansion-email-and-clienteling.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-003, BR-006, BR-009, BR-010, BR-011, BR-012); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`)  
**Tracked open decisions:** `DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`

---

## 1. Purpose

Capture, normalize, and attribute recommendation outcomes across email and clienteling so SuitSupply can compare channel performance with shared recommendation lineage, not channel-specific analytics silos.

This capability ensures every key interaction and outcome can be tied back to recommendation context (`recommendationSetId`, `traceId`, recommendation type, campaign/appointment context), while respecting consent, role boundaries, and identity-confidence rules.

## 2. Core Concept

`Cross Channel Telemetry And Attribution` provides a unified telemetry envelope and attribution pipeline for two non-web channels:

- **Email**: delayed, campaign-driven, potentially high-volume interactions where exposure and conversion can be far apart in time.
- **Clienteling**: operator-assisted interactions where adaptation/share actions become part of recommendation provenance and downstream attribution.

The module does not change recommendation decisioning. It captures channel-specific events and joins them to shared recommendation identifiers for reporting, auditability, and optimization.

## 3. User Problems Solved

- Marketing cannot reliably compare email recommendation impact against assisted-selling impact without a shared attribution model.
- Product and analytics teams lose optimization signal when clicks or purchases cannot be joined to a recommendation set.
- Merchandisers cannot see whether operator adaptations improve or harm outcomes if adaptation lineage is missing.
- Support and audit teams cannot reconstruct why a recommendation outcome was credited to a channel without durable trace metadata.

## 4. Trigger Conditions

- Email package lifecycle events occur (`generated`, `sent`, `open`, `click`, `unsubscribe`, downstream purchase).
- Clienteling events occur (`requested`, `viewed`, `adapted`, `shared`, follow-up purchase).
- Commerce outcomes arrive that may map to a recommendation exposure.
- Identity confidence or suppression state changes require attribution eligibility reevaluation.
- Scheduled recompute windows or backfills run to incorporate late events.

## 5. Inputs

- Shared recommendation metadata:
  - `recommendationSetId`
  - `traceId`
  - `recommendationType`
  - `channel`
  - `surface`
- Email context:
  - `campaignId`
  - package generation/sent timestamps
  - link metadata
- Clienteling context:
  - `associateId`
  - `appointmentId` (optional)
  - adaptation/share lineage
- Commerce and engagement outcomes:
  - orders, add-to-cart, save, click, dismiss
- Identity and policy context:
  - canonical customer ID or session ID
  - identity resolution confidence
  - consent/suppression state
  - market and policy scope

## 6. Outputs

- Normalized cross-channel recommendation events aligned with `docs/project/data-standards.md`.
- Attribution links between outcomes and recommendation exposures/interactions.
- Channel comparison projections for analytics and experimentation.
- Operator adaptation influence records for clienteling outcomes.
- Audit-ready correction records when attribution changes after late data arrival.

## 7. Workflow / Lifecycle

1. **Ingest** email/clienteling/commerce events from channel integrations.
2. **Normalize** to canonical schema and validate required IDs and policy context.
3. **Eligibility check** verifies consent, identity-confidence, and channel policy.
4. **Attribution candidate matching** links outcomes to recommendation exposures/interactions.
5. **Attribution decision** applies configured model/window and writes attribution records.
6. **Projection build** materializes reporting views for channel and recommendation-type comparisons.
7. **Correction/recompute** handles late or corrected events with immutable adjustment records.

Lifecycle states for attribution records:

`pending_match -> matched -> attributed -> adjusted -> finalized`

## 8. Business Rules

- Events for this module must preserve shared recommendation semantics and IDs; no channel-specific identifier replacement.
- Telemetry event families must support recommendation outcomes defined in data standards: `impression`, `click`, `save`, `add-to-cart`, `purchase`, `dismiss`, `override`.
- Attribution must always record source channel and surface (`email` or `clienteling`) even when outcomes happen later in another surface.
- Clienteling adaptation and share actions must be represented as first-class lineage events and not collapsed into generic "click" telemetry.
- If identity confidence is below policy threshold, attribution may proceed only with allowed anonymous/session-safe logic.
- Suppression/consent revocation must prevent unauthorized personalization joins and must annotate affected attribution records.
- Late events are allowed to adjust attribution within configured recompute horizon; adjustments must be auditable, not destructive overwrites.
- Campaign versus personalization precedence remains unresolved for some flows and must remain explicitly tied to `DEC-008`.
- Freshness and send-time boundaries for email remain controlled by `DEC-010` and `DEC-016`; this module must ingest those states rather than redefine them.

## 9. Configuration Model

- `enabled` (boolean): turn module on/off by environment.
- `policyVersion` (string): immutable version reference for attribution behavior.
- `attributionModel` (enum): e.g., `last_touch`, `position_based`, `hybrid_channel_weighted`.
- `windowByEventType` (object): attribution windows per event type/channel pair.
- `identityConfidenceThresholdByChannel` (object): minimum confidence for profile-linked joins.
- `dedupeKeyStrategy` (enum): event deduplication strategy for retries/provider duplicates.
- `recomputeHorizonHours` (integer): max late-arrival adjustment window.
- `operatorAttributionWeighting` (object): clienteling adaptation/share influence controls.
- `publishCadence` (enum): near-real-time vs periodic projection publication.

## 10. Data Model

Primary entities:

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `ChannelTelemetryEvent` | Canonical event envelope from email/clienteling/commerce | `eventId`, `eventType`, `eventTime`, `channel`, `surface`, `recommendationSetId`, `traceId`, `customerIdOrSessionId`, `campaignId?`, `appointmentId?`, `associateId?`, `metadata` |
| `AttributionCandidate` | Candidate outcome-to-exposure relationship | `candidateId`, `outcomeEventId`, `sourceEventId`, `matchReason`, `identityConfidence`, `windowCheckResult`, `policyVersion` |
| `AttributionRecord` | Final or interim attribution decision | `attributionId`, `outcomeEventId`, `sourceEventId`, `model`, `credit`, `channel`, `surface`, `recommendationType`, `status`, `createdAt` |
| `AttributionAdjustment` | Immutable correction after late or fixed data | `adjustmentId`, `attributionId`, `reasonCode`, `oldCredit`, `newCredit`, `adjustedAt` |
| `OperatorInfluenceRecord` | Captures clienteling adaptation/share influence | `influenceId`, `recommendationSetId`, `associateId`, `adaptationId?`, `shareId?`, `influenceType`, `createdAt` |

Required cross-entity standards:

- Stable canonical IDs with source-system mappings.
- UTC timestamps and explicit timezone-safe parsing.
- Schema version and policy version fields.
- Reason codes for dropped, adjusted, or blocked attribution decisions.

## 11. API Endpoints

Illustrative feature-stage API surfaces:

- `POST /telemetry/recommendation-events`
- `POST /telemetry/attribution/recompute`
- `GET /telemetry/attribution/recommendation-sets/{recommendationSetId}`
- `GET /telemetry/channel-comparison?channel=email,clienteling&from=...&to=...`

These endpoints are illustrative. Final endpoint ownership, transport contracts, and versioning depend on architecture-stage decisions, especially `DEC-003`.

## 12. Events Produced

- `channel_telemetry.normalized`
- `channel_telemetry.rejected`
- `recommendation_attribution.candidate_matched`
- `recommendation_attribution.assigned`
- `recommendation_attribution.adjusted`
- `recommendation_attribution.finalized`
- `clienteling_operator.influence_recorded`

Each produced event should include, where applicable:

- `eventId`
- `eventTime`
- `recommendationSetId`
- `traceId`
- `channel`
- `surface`
- `recommendationType`
- `policyVersion`
- `reasonCode` (for rejects/adjustments)

## 13. Events Consumed

- `recommendation_package.generated`
- `recommendation_package.sent`
- `email.opened`
- `email.clicked`
- `clienteling_recommendation.viewed`
- `clienteling_recommendation.adapted`
- `clienteling_recommendation.shared`
- `commerce.add_to_cart`
- `commerce.purchase.completed`
- `identity.resolution.updated`
- `suppression.state.changed`

## 14. Integrations

- **Shared contracts and delivery API**: recommendation IDs and channel/surface semantics.
- **Analytics and experimentation**: experiment assignment and result slicing.
- **Identity and style profile**: canonical customer mapping and confidence.
- **Customer signal ingestion**: standardized event intake and lineage.
- **Explainability and auditability**: trace lookup and timeline reconstruction.
- **Merchandising governance and operator controls**: campaign/rule/override context.
- **Email systems (ESP/campaign orchestration)**: send/open/click event feeds.
- **Clienteling application**: session view/adaptation/share events.
- **Commerce platform**: add-to-cart/purchase outcomes for attribution closure.

## 15. UI Components

- Attribution timeline component keyed by `recommendationSetId` and `traceId`.
- Channel comparison chart component (email vs clienteling).
- Operator influence badge (adapted/shared/original path).
- Attribution quality indicator (confidence, late-adjusted, suppressed).
- Telemetry reject/reason-code table for support diagnostics.

## 16. UI Screens

- Cross-channel attribution dashboard for analytics and product teams.
- Campaign telemetry detail screen for marketing.
- Clienteling effectiveness screen for store/associate operations.
- Trace-level support screen showing event-to-outcome lineage and adjustments.

## 17. Permissions & Security

- Only authorized backend services may ingest or mutate attribution records.
- Role-based read access:
  - marketing: campaign/channel aggregates
  - stylists/managers: clienteling performance and operator influence summaries
  - support/audit: full trace timeline with governed redaction
- Customer-facing surfaces must not expose sensitive profile reasoning.
- PII handling must follow regional policy constraints and suppression rules.
- Access to recompute operations should require elevated operational permissions.

## 18. Error Handling

- Reject malformed events with structured validation errors and reason codes.
- Quarantine schema-invalid provider payloads for replay after correction.
- Mark missing-ID events as non-attributable without dropping raw observability.
- On dependency failures (identity or commerce lag), retain pending candidates for retry.
- Ensure recompute failures are resumable and idempotent.

## 19. Edge Cases

- Email click occurs after attribution window but before delayed purchase.
- Multiple channel exposures precede one purchase (email plus clienteling share).
- Duplicate provider events due to retries or webhook replays.
- Identity merge/split changes customer mapping after initial attribution.
- Associate adaptation significantly changes product set before share/purchase.
- Suppression state changes between exposure and conversion.
- Out-of-order event arrival (purchase ingested before click/open).

## 20. Performance Considerations

- Use append-only event storage plus projection tables for dashboard latency.
- Keep attribution matching incremental to avoid full-table recompute by default.
- Partition and index by time/channel/recommendation IDs for high-volume email bursts.
- Bound recompute windows to protect service stability during backfills.
- Support eventual consistency while exposing freshness metadata on projections.

## 21. Observability

- Metrics:
  - ingest throughput and lag by channel
  - reject rate and reason-code distribution
  - attribution match rate
  - late-adjustment rate
  - dedupe rate
- Logs should include `recommendationSetId`, `traceId`, `eventId`, `channel`, and `policyVersion`.
- Traces should connect ingestion, matching, attribution assignment, and projection publication.
- Alerts:
  - sustained schema rejection spikes
  - abnormal attribution drop for a channel
  - recompute backlog growth beyond SLA

## 22. Example Scenarios

### Scenario A: Email recommendation click to purchase attribution

1. Package `recset_1001` is sent for campaign `cmp_spring`.
2. Customer clicks email recommendation link (event includes `recommendationSetId` + `traceId`).
3. Purchase occurs within configured email window.
4. Attribution engine matches purchase to click and records credited outcome for channel `email`.

Example normalized click event:

```json
{
  "eventId": "evt_click_001",
  "eventType": "click",
  "eventTime": "2026-03-22T11:15:00Z",
  "channel": "email",
  "surface": "lifecycle_followup",
  "customerIdOrSessionId": "cust_123",
  "recommendationSetId": "recset_1001",
  "traceId": "trace_1001",
  "recommendationType": "outfit",
  "campaignId": "cmp_spring",
  "policyVersion": "attrib_v1"
}
```

### Scenario B: Clienteling adaptation + share with downstream purchase

1. Associate retrieves recommendations for appointment `appt_456`.
2. Associate adapts one item and shares curated set with customer.
3. Customer purchases from share link later that day.
4. Attribution links purchase to clienteling source set and records operator influence metadata.

Example attribution record:

```json
{
  "attributionId": "attr_9001",
  "outcomeEventId": "evt_purchase_777",
  "sourceEventId": "evt_share_222",
  "channel": "clienteling",
  "surface": "clienteling_session",
  "recommendationSetId": "recset_2002",
  "traceId": "trace_2002",
  "recommendationType": "personal",
  "credit": 1.0,
  "model": "last_touch",
  "status": "attributed"
}
```

## 23. Implementation Notes

- Keep this as a distinct backend module within the `channel-expansion-email-and-clienteling` domain to avoid coupling all attribution logic into channel adapters.
- Reuse canonical event envelope and ID standards from `docs/project/data-standards.md`; do not introduce incompatible event identities.
- Use append-only event ingest with idempotency keys and dedupe strategy to handle provider retries.
- Materialize read models for dashboards separately from raw event storage.
- Represent attribution changes with immutable adjustments, not hard overwrites.
- Preserve explicit linkage to open decisions:
  - `DEC-003`: contract/version governance
  - `DEC-008`: campaign versus personalization precedence
  - `DEC-010` and `DEC-016`: freshness policy impact on attributable sends
  - `DEC-011`: clienteling explanation depth and operator context

Specific implementation implications:

- Backend services: telemetry ingest service, attribution engine, projection publisher.
- Data stores: canonical events, attribution records, attribution adjustments, operator influence records.
- Jobs/workers: recompute/backfill workers, dead-letter replay workers, projection refresh workers.
- External interfaces: ESP event feeds, clienteling interaction feed, commerce outcome feed.
- UI/shared components: attribution dashboards and trace support views only; no alternate recommendation semantics.

## 24. Testing Requirements

- **Unit tests**
  - event validation and normalization
  - attribution window logic
  - dedupe and idempotency
  - confidence/suppression gating
- **Contract tests**
  - telemetry event schema compatibility
  - attribution API response schema/version fields
- **Integration tests**
  - email send->click->purchase flow
  - clienteling adapt/share->purchase flow
  - identity merge/suppression change impact
- **Data quality tests**
  - required identifier completeness rates
  - reject reason distribution thresholds
  - projection parity against raw attribution records
- **Resilience tests**
  - out-of-order events
  - late-arriving outcomes and adjustments
  - dependency outages and replay correctness
- **Auditability tests**
  - end-to-end trace reconstruction from recommendation set to attributed outcome
  - immutable adjustment trail validation
