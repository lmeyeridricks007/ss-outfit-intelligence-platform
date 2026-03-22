# Sub-feature capability: Canonical Recommendation Events

**Parent feature:** `Analytics and experimentation`  
**Parent feature file:** `docs/features/analytics-and-experimentation.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/analytics-and-experimentation/`  
**Upstream traceability:** `docs/features/analytics-and-experimentation.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-010, BR-003, BR-002, BR-011); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-006`, `DEC-007`)  
**Tracked open decisions:** `DEC-006`, `DEC-007`

---

## 1. Purpose

Define one canonical event contract for recommendation telemetry so all producers (web, server fallback, backend jobs, commerce outcome pipelines, and later channel integrations) emit the same seven event families with consistent semantics:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

This capability exists to prevent surface-specific event drift and to make experiment and outcome analysis trustworthy across PDP, cart, homepage expansion, email, and clienteling.

## 2. Core Concept

`canonical-recommendation-events` is the semantic boundary between recommendation behavior and analytics ingestion. It standardizes:

1. **Event names** and allowed transitions
2. **Required identifiers** (`recommendationSetId`, `traceId`, product / look references, experiment context)
3. **Required dimensions** (channel, surface, placement, recommendation type, source mix, event source)
4. **Validation and rejection behavior** (schema checks, enum checks, quarantine for invalid payloads)
5. **Versioning** so contracts can evolve without breaking downstream consumers

The sub-feature does not choose final transport technology; it defines the minimum event semantics that every implementation path must preserve.

## 3. User Problems Solved

- **Analytics teams** can compare performance across surfaces because "impression" and "purchase" mean the same thing everywhere.
- **Product and experimentation teams** can trust uplift reporting because experiment and variant context is carried on all relevant events.
- **Merchandising and governance teams** can separate model effects from override/campaign effects because override telemetry is first-class, not an afterthought.
- **Engineering teams** can integrate once against a stable schema instead of reinventing event payloads per channel.
- **Audit and support teams** can reconstruct recommendation journeys from a shared identifier model.

## 4. Trigger Conditions

Canonical recommendation events are emitted when:

- a recommendation response is delivered and exposed (impression, including governed fallback path)
- a customer interacts with recommended content (click, save, dismiss, add-to-cart)
- a downstream commerce outcome is linked to recommendation context (purchase)
- an operator intervention changes recommendation behavior (override)
- schema version changes require producer updates or dual-write migration windows

## 5. Inputs

- recommendation delivery contract payloads from shared delivery API
- surface interaction signals (web/mobile/clienteling surfaces)
- commerce / OMS outcome events (orders, line items, cancellations if modeled)
- governance annotation feeds (override/campaign context)
- experiment assignment metadata (`experimentId`, `variantId`, `assignmentKey`)
- identity context (`canonicalCustomerId` or anonymous session ID with confidence state)
- schema registry / allowed enum configuration

## 6. Outputs

- validated canonical recommendation events ready for ingestion
- normalized event records with schema version and source metadata
- rejected-event records with reason codes and remediation metadata
- idempotency decisions (accepted duplicate, dropped duplicate, retried)
- downstream-ready event streams/tables for attribution and reporting

## 7. Workflow / Lifecycle

1. **Producer capture:** producer emits a candidate event with recommendation IDs and context.
2. **Validation:** schema, required-field, and enum validation executes against active version.
3. **Enrichment:** attach market/channel metadata, governance context, and identity-confidence fields where available.
4. **Idempotency check:** dedupe key check prevents double-counting from retries and re-renders.
5. **Publish:** accepted events are written to canonical ingestion stream/table.
6. **Quarantine:** invalid or unsafe events are routed to rejected-event storage.
7. **Projection:** accepted events feed attribution logic, experiment scorecards, and health dashboards.
8. **Replay support:** corrected payloads or historical backfills can be replayed with explicit provenance.

## 8. Business Rules

- The canonical event families are fixed: impression, click, save, add-to-cart, purchase, dismiss, override.
- `recommendationSetId` and `traceId` are required for all event families where recommendation attribution is expected.
- Impression represents visible exposure (or policy-approved fallback), not delivery API success alone.
- `eventSource` must distinguish browser, server fallback, backend, import, or operator origin.
- Recommendation type must use shared domain values (outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal).
- Source mix context must preserve curated/rule-based/AI-ranked/mixed semantics.
- Producers may add optional fields, but cannot redefine canonical field meanings.
- Invalid payloads must not be silently dropped; they require explicit rejection reason codes.
- Open decisions `DEC-006` and `DEC-007` remain unresolved and must not be implicitly closed here.

## 9. Configuration Model

Required configuration domains:

- `schemaVersion`: active and allowed-compatible event schema versions
- `requiredFieldsByEventType`: per-family required field map
- `enumPolicies`: allowed values for recommendation type, source mix, event source, channel, and surface
- `idempotency`: key composition and dedupe window settings
- `fallbackPolicyRefs`: links to impression fallback policy decisions and rollout flags
- `enrichmentPolicies`: when to attach identity confidence, campaign IDs, or governance snapshots
- `retentionAndQuarantine`: accepted/rejected event retention periods by environment
- `alertThresholds`: failure-rate, duplicate-rate, and missing-ID thresholds

All configuration changes should be versioned and auditable.

## 10. Data Model

Primary entities:

1. **RecommendationEvent**
   - `eventId`, `eventType`, `eventTs`, `schemaVersion`
   - `channel`, `surface`, `placement`
   - `recommendationSetId`, `traceId`
   - `recommendationType`, `sourceMix`, `eventSource`
   - `itemId` or `lookId`, `anchorProductId` (where applicable)
   - `experimentId`, `variantId`, `assignmentKey` (where applicable)
   - `ruleContext`, `campaignId`, `overrideFlag`
   - `customerIdOrSessionId`, `identityConfidence`

2. **EventIngestionResult**
   - `eventId`, `ingestionStatus`, `processedAt`
   - `idempotencyKey`, `duplicateDisposition`
   - `errorCode` and `errorDetail` (if rejected)

3. **EventSchemaVersion**
   - `schemaVersion`, `effectiveFrom`, `compatibilityMode`, `requiredFields`

4. **RejectedEvent**
   - original payload snapshot, rejection reason, producer metadata, replay eligibility

## 11. API Endpoints

Illustrative contract-level endpoints:

- `POST /analytics/recommendation-events`
- `POST /analytics/recommendation-events/batch`
- `GET /analytics/recommendation-events/schemas/{schemaVersion}`
- `GET /analytics/recommendation-events/validation-rules`

Transport choices remain architecture-stage decisions, but wire contracts must preserve the canonical fields and validation semantics above.

## 12. Events Produced

- `recommendation.events.accepted`
- `recommendation.events.rejected`
- `recommendation.events.duplicate-detected`
- `recommendation.events.schema-mismatch`
- `recommendation.events.replayed`

## 13. Events Consumed

- `recommendation.delivery.served`
- `surface.impression.detected`
- `surface.recommendation.clicked`
- `surface.recommendation.saved`
- `surface.recommendation.dismissed`
- `commerce.cart.added`
- `commerce.order.completed`
- `governance.override.applied`
- `experimentation.assignment.resolved`

## 14. Integrations

- shared contracts and delivery API (source of recommendation identifiers)
- ecommerce surface experiences (primary producer for interaction events)
- impression-policy-and-server-fallback (fallback source semantics)
- outcome-attribution-and-confidence (purchase linkage downstream)
- experiment-assignment-and-delivery-contracts (variant metadata integrity)
- governance-annotations-for-analysis (override/campaign analysis context)
- identity and style profile (identity confidence and mapping)
- explainability and auditability (trace reconstruction)

## 15. UI Components

Internal/operator-facing components:

- schema explorer table (required vs optional fields by event type)
- ingestion health cards (accept/reject/duplicate rates)
- rejection reason distribution chart
- sample payload inspector with field-level validation results
- event lineage panel keyed by `traceId` and `recommendationSetId`

## 16. UI Screens

- telemetry health console
- schema/version management view
- rejected event triage screen
- trace-linked analytics drilldown panel

## 17. Permissions & Security

- Only trusted producer services and approved collectors can submit canonical events.
- Raw payload access is restricted by role; aggregate metrics are broader.
- Sensitive identity fields must be masked or omitted by role and region.
- All schema/config changes require auditable actor identity and timestamp.
- Access to replay tooling and rejected-event exports should be tightly scoped.

## 18. Error Handling

- Validation failures return structured errors with machine-readable reason codes.
- Unknown schema versions are rejected with explicit upgrade guidance.
- Missing required identifiers (`recommendationSetId`, `traceId` when required) are hard failures for accepted ingestion.
- Temporary downstream outages must use retry/backoff with idempotency-safe behavior.
- Rejected events are quarantined, not discarded, to support diagnosis and replay.

## 19. Edge Cases

- Browser blocked events require server fallback while preserving canonical fields.
- Multiple recommendation sets may reference the same item before purchase; attribution may become low-confidence, but event semantics stay fixed.
- Late-arriving purchase events must still reference prior recommendation context when available.
- Replayed historical events must preserve original event time and mark replay provenance.
- Same-session rerenders can emit duplicate impressions; idempotency policy prevents inflated counts.
- Event producers on mixed schema versions require compatibility windows and explicit deprecation policy.

## 20. Performance Considerations

- Handle high-volume ingestion paths without dropping canonical validation guarantees.
- Keep validation fast via cached schema registries and enum maps.
- Use batch endpoints for high-throughput producers where practical.
- Ensure idempotency lookups are indexed for write-heavy workloads.
- Preserve near-real-time availability for telemetry health and experiment monitoring views.

## 21. Observability

Track at minimum:

- accepted events per second by event type/channel/surface
- rejection rate and top rejection reasons
- duplicate detection rate
- missing critical-field rate (`recommendationSetId`, `traceId`, event source)
- ingestion latency (event time to accepted time)
- schema-version distribution
- fallback-source distribution (browser vs server fallback)

Operational logs should always include `eventId`, `traceId`, `recommendationSetId`, `schemaVersion`, and producer identity.

## 22. Example Scenarios

### Scenario A: PDP impression with browser event source

1. Delivery API returns outfit recommendations with IDs and experiment context.
2. Module visibility threshold is met on PDP.
3. Browser producer emits canonical `impression` event.
4. Validator accepts event and publishes to canonical stream.

```json
{
  "eventId": "evt_01JQ4D2MFK3V6PK5V4X9S2K7CR",
  "eventType": "impression",
  "eventTs": "2026-03-22T11:45:03Z",
  "channel": "web",
  "surface": "pdp",
  "placement": "complete_the_look_primary",
  "recommendationSetId": "recset_01JQ4D2K7Q7M8X5TZ7A9B9D3AV",
  "traceId": "trace_01JQ4D2JQK9V4S6E2Y1Z8N6W0R",
  "recommendationType": "outfit",
  "itemId": "prod_67890",
  "position": 1,
  "eventSource": "browser",
  "experimentId": "exp_rank_mix_2026_03",
  "variantId": "treatment_b",
  "sourceMix": "curated_plus_ai_ranked",
  "schemaVersion": "1.0"
}
```

### Scenario B: Purchase event linked to prior exposure

1. OMS emits order completion.
2. Attribution service links order line to prior `recommendationSetId` and `traceId`.
3. Canonical `purchase` event is emitted with confidence metadata for downstream reporting.

```json
{
  "eventId": "evt_01JQ4DBW1D0R9Y4A9P3C5N7L2X",
  "eventType": "purchase",
  "eventTs": "2026-03-22T14:10:26Z",
  "channel": "web",
  "surface": "checkout",
  "recommendationSetId": "recset_01JQ4D2K7Q7M8X5TZ7A9B9D3AV",
  "traceId": "trace_01JQ4D2JQK9V4S6E2Y1Z8N6W0R",
  "recommendationType": "outfit",
  "itemId": "prod_67890",
  "eventSource": "backend",
  "outcomeOrderId": "ord_20260322_11872",
  "attributionConfidence": "high",
  "schemaVersion": "1.0"
}
```

## 23. Implementation Notes

- **Backend services:** create a canonical event-ingestion boundary inside analytics domain; avoid per-surface ingestion logic forks.
- **Database/storage:** separate accepted events, rejected events, schema definitions, and idempotency ledgers.
- **Jobs/workers:** run enrichment, replay, and reconciliation jobs asynchronously; preserve event immutability.
- **External interfaces:** keep producer SDKs thin and schema-driven to reduce contract drift.
- **UI/ops tooling:** provide schema health and rejection triage views for rapid producer remediation.

Implementation boundaries to keep explicit:

- This sub-feature owns event semantics and validation.
- Attribution-window policy and experiment-stickiness policy remain open under `DEC-007`.
- Detailed server fallback policy remains open under `DEC-006`.

## 24. Testing Requirements

- Unit tests for event-family validators and required-field enforcement.
- Contract tests for all seven canonical event families.
- Compatibility tests for schema version upgrades and dual-version periods.
- Idempotency tests for retry, rerender, and replay scenarios.
- Integration tests across delivery -> interaction -> purchase -> override paths.
- Failure-path tests for rejection quarantine and replay workflows.
- Permissions tests for raw payload access and sensitive-field masking.
- Observability tests asserting required metrics/log fields are emitted.
