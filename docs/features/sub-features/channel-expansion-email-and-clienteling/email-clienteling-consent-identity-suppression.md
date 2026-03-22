# Sub-feature capability: Email Clienteling Consent Identity Suppression

**Parent feature:** `Channel expansion: email and clienteling`  
**Parent feature file:** `docs/features/channel-expansion-email-and-clienteling.md`  
**Parent feature priority:** `P3`  
**Sub-feature directory:** `docs/features/sub-features/channel-expansion-email-and-clienteling/`  
**Upstream traceability:** `docs/features/channel-expansion-email-and-clienteling.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-003, BR-006, BR-009, BR-011, BR-012); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`)  
**Tracked open decisions:** `DEC-003`, `DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`

---

## 1. Purpose

Ensure email and clienteling recommendation flows use customer identity and profile data only when channel consent, suppression policy, and identity confidence allow it, and degrade safely when they do not.

This sub-feature prevents unauthorized personalization drift between channels and makes permission decisions explicit, traceable, and auditable.

## 2. Core Concept

`Email Clienteling Consent Identity Suppression` is a policy-evaluation capability that sits between recommendation request orchestration and recommendation activation:

- **Email path:** determines whether personalized content can be packaged/sent for a campaign or lifecycle message.
- **Clienteling path:** determines whether profile-driven personalization can be shown to an authenticated associate during a session.

The output is a normalized decision object (allow, degrade, suppress, block) with reason codes and policy version, reused by channel-specific consumers.

## 3. User Problems Solved

- **Customers:** reduced risk of receiving recommendations after opt-out/suppression or under low-confidence identity linkage.
- **Marketing operators:** clear send-time posture (`eligible`, `degraded`, `suppressed`) before campaign launch.
- **Clienteling associates:** clear understanding of what recommendation depth is allowed for the current customer/session.
- **Analytics/governance teams:** explainable reason codes for why personalization was applied, downgraded, or blocked.

## 4. Trigger Conditions

- Email package generation or pre-send validation requests personalization eligibility.
- Clienteling session opens or refreshes recommendation retrieval for a customer.
- Consent/suppression state changes for a customer already queued for email send.
- Identity resolution confidence changes for a customer in active clienteling workflow.
- Policy configuration version changes (market/channel/surface scope).

## 5. Inputs

Required inputs:

- `customerId` (canonical) and source identity mappings.
- `identityConfidence` and merge/conflict indicators.
- `channel` (`email` or `clienteling`) and `surface`.
- `purposeOfUse` (`lifecycle_email`, `campaign_email`, `clienteling_session`, etc.).
- Consent records by purpose and market.
- Suppression/opt-out status and effective timestamps.
- Recommendation context (`recommendationSetId` when available, requested recommendation types).
- Market/region policy context.

Supporting inputs:

- appointment context (clienteling only, optional).
- campaign context (email only, optional).
- governance context (active campaign/rule/override references).

## 6. Outputs

Primary output: `ChannelPersonalizationDecision`.

Core fields:

- `decisionId`
- `channel`, `surface`, `purposeOfUse`
- `eligibility` (`allow_personalized`, `allow_non_personalized`, `allow_session_only`, `suppress`, `deny`)
- `suppressionApplied` (boolean)
- `identityGateResult` (`high`, `medium`, `low`, `conflicted`, `unknown`)
- `reasonCodes[]`
- `policyVersion`
- `effectiveAt`, `expiresAt`
- `traceId`

Downstream impact fields:

- `recommendedAction` (`proceed`, `degrade_to_contextual`, `degrade_to_non_personal`, `suppress_content`, `block_send`)
- `auditRequired` (boolean)

## 7. Workflow / Lifecycle

1. **Normalize request context**
   - Validate channel/surface/purpose inputs and customer identifier shape.
2. **Resolve identity posture**
   - Load canonical identity confidence and conflict state.
3. **Evaluate consent and suppression**
   - Apply market and purpose-of-use checks.
4. **Apply channel policy**
   - Email: choose send-safe posture before package activation.
   - Clienteling: choose role-safe personalization depth for session.
5. **Emit decision object**
   - Attach reason codes, policy version, and expiry.
6. **Persist audit entry**
   - Record input snapshot references and final decision.
7. **Notify consumers**
   - Return synchronous decision for request-time flows.
   - Publish async event for downstream orchestration and reporting.

## 8. Business Rules

1. Suppression or explicit opt-out always overrides personalization requests.
2. Low-confidence or conflicted identity must not enable profile-heavy personalization.
3. Email personalization requires both valid consent and send-time eligibility; if not, downgrade or suppress before send.
4. Clienteling may use richer internal context than customer-facing email, but only for authenticated, role-authorized users and privacy-safe explanation depth.
5. All decisions must be tied to canonical customer identifiers and trace metadata per `docs/project/data-standards.md`.
6. Consumers must not infer policy from missing fields; they must rely on explicit `eligibility` + `reasonCodes`.
7. Precedence between campaign and personalization logic remains linked to `DEC-008`.
8. This spec does not freeze final contract structure or transport; that remains under `DEC-003`.
9. Email freshness/regeneration coupling remains dependent on `DEC-010` and `DEC-016`.
10. Clienteling rollout and explanation-depth boundaries remain dependent on `DEC-011`.

## 9. Configuration Model

Representative configuration keys:

- `consentIdentitySuppression.enabled`
- `consentIdentitySuppression.policyVersion`
- `consentIdentitySuppression.marketPolicy[marketCode]`
- `consentIdentitySuppression.channelPolicy[email|clienteling]`
- `consentIdentitySuppression.minIdentityConfidenceForPersonalization`
- `consentIdentitySuppression.allowSessionOnlyWhenLowConfidence` (clienteling)
- `consentIdentitySuppression.emailSuppressionFallback` (`suppress` vs `non_personalized`)
- `consentIdentitySuppression.decisionTtlSeconds`
- `consentIdentitySuppression.requiredReasonCodes[]`

Scope dimensions:

- environment
- market/region
- channel/surface
- purpose-of-use

## 10. Data Model

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `ChannelPersonalizationDecision` | canonical decision record | `decisionId`, `customerId`, `channel`, `surface`, `purposeOfUse`, `eligibility`, `reasonCodes[]`, `policyVersion`, `effectiveAt`, `expiresAt`, `traceId` |
| `ConsentSnapshotRef` | consent source reference used at decision time | `snapshotId`, `customerId`, `consentState`, `consentUpdatedAt`, `sourceSystem`, `market` |
| `SuppressionSnapshotRef` | suppression source reference used at decision time | `snapshotId`, `customerId`, `suppressed`, `suppressionType`, `effectiveAt` |
| `IdentityGateSnapshot` | identity confidence state used by policy | `snapshotId`, `customerId`, `identityConfidence`, `mergeStatus`, `resolutionVersion` |
| `PermissionAuditEntry` | immutable audit log | `auditId`, `decisionId`, `evaluatedBy`, `inputRefs[]`, `result`, `reasonCodes[]`, `createdAt` |

Standards alignment:

- canonical IDs must follow `docs/project/data-standards.md`
- decisions must retain source snapshot references, not copied raw PII payloads
- reason codes must be stable enumerations for analytics and support

## 11. API Endpoints

Illustrative operations (feature-stage, non-normative):

- `POST /channel-personalization-decisions:evaluate`
- `GET /channel-personalization-decisions/{decisionId}`
- `POST /channel-personalization-decisions:re-evaluate` (on upstream state change)

Example evaluate request:

```json
{
  "customerId": "cust_123",
  "channel": "email",
  "surface": "lifecycle_followup",
  "purposeOfUse": "lifecycle_email",
  "market": "NL",
  "recommendationSetId": "recset_01HXYZ",
  "traceId": "trace_01HXYZ"
}
```

Example response:

```json
{
  "decisionId": "cpd_01J001",
  "eligibility": "allow_non_personalized",
  "suppressionApplied": true,
  "identityGateResult": "low",
  "reasonCodes": ["CONSENT_MISSING_FOR_PURPOSE", "LOW_IDENTITY_CONFIDENCE"],
  "recommendedAction": "degrade_to_non_personal",
  "policyVersion": "consent-suppression-v3",
  "effectiveAt": "2026-03-22T09:00:00Z",
  "expiresAt": "2026-03-22T13:00:00Z",
  "traceId": "trace_01HXYZ"
}
```

## 12. Events Produced

- `channel_personalization.decision_evaluated`
- `channel_personalization.decision_changed`
- `channel_personalization.suppression_applied`
- `channel_personalization.personalization_blocked`

Minimum event fields:

- `decisionId`
- `customerId` (or approved surrogate where required)
- `channel`, `surface`, `purposeOfUse`
- `eligibility`
- `reasonCodes[]`
- `policyVersion`
- `traceId`

## 13. Events Consumed

- `consent.state.changed`
- `suppression.state.changed`
- `identity.resolution.updated`
- `campaign.send_window.started` (email)
- `clienteling.session.opened` (clienteling)

Consumed events should trigger either immediate re-evaluation or cache invalidation for next request-time evaluation.

## 14. Integrations

Core integrations:

- identity and style profile service
- customer signal ingestion for consent/suppression feeds
- shared contracts and delivery API consumers
- email packaging/send-safety orchestration
- clienteling recommendation retrieval workflow
- explainability and auditability services
- analytics and experimentation event pipeline

Adjacent integrations:

- ESP/campaign orchestration platform
- associate authentication and role service
- governance/rule context service

## 15. UI Components

- Email campaign preview consent/suppression badge.
- Email send-readiness panel reason-code list.
- Clienteling recommendation eligibility banner (personalized vs downgraded).
- Operator explanation summary chip showing policy posture.
- Support diagnostics component for decision lookup by `decisionId`/`traceId`.

## 16. UI Screens

- Campaign recommendation preview and approval screen.
- Email package validation/send-readiness screen.
- Clienteling appointment session screen.
- Clienteling customer profile recommendation panel.
- Internal trace/audit inspection screen (authorized roles only).

## 17. Permissions & Security

- Evaluation APIs are internal service-to-service endpoints; direct end-user access is disallowed.
- Associate-facing clienteling responses expose only policy-safe posture, not raw consent internals.
- Audit endpoints require privileged roles and access logging.
- Sensitive identity/consent payload details must be redacted from non-privileged logs.
- Every decision write includes actor/service identity, policy version, and immutable timestamp.
- Share/export workflows must not bypass suppression/consent posture already computed.

## 18. Error Handling

Error classes:

- `VALIDATION_ERROR` (missing/invalid channel, surface, purpose, IDs)
- `DEPENDENCY_UNAVAILABLE` (identity/consent/suppression source unavailable)
- `POLICY_CONFIGURATION_ERROR` (missing policy for market/channel)
- `STALE_INPUT_REFERENCE` (snapshot references expired/unavailable)

Handling rules:

- On dependency failure, return safe fallback (`allow_non_personalized` or `deny`) based on configured fail-safe policy.
- Preserve `traceId` and emit decision failure telemetry with reason codes.
- Distinguish hard deny from temporary degradation.
- Never default to personalized behavior when required consent/identity data is missing.

## 19. Edge Cases

- Consent revoked after email package generation but before send window.
- Identity confidence fluctuates during active clienteling consultation.
- Multiple source systems publish conflicting suppression state updates.
- Customer appears under merged identities with unresolved mapping conflict.
- Campaign requests personalization for suppressed segment due to stale audience snapshot.
- Partial outage in consent service during peak send window.

## 20. Performance Considerations

- Target request-time decision latency suitable for interactive clienteling paths; use read-optimized snapshots.
- Precompute/refresh consent-suppression projections for email batch workflows.
- Use bounded decision caching with invalidation on consent/suppression/identity updates.
- Ensure re-evaluation jobs are idempotent to avoid duplicate decision churn.
- Monitor degradation rates to prevent performance optimizations from silently over-suppressing or under-suppressing.

## 21. Observability

Required metrics:

- decision throughput by channel/surface
- p50/p95/p99 evaluation latency
- eligibility distribution (`allow_personalized`, `allow_non_personalized`, `suppress`, `deny`)
- top reason-code frequency
- dependency failure rate and fail-safe mode activation

Required logs/traces:

- correlation by `decisionId`, `traceId`, `recommendationSetId` (if present)
- policy version and market context in each decision record
- audit trail for decision changes caused by upstream state updates

Operational dashboards should separate email and clienteling posture trends.

## 22. Example Scenarios

### Scenario A: Email lifecycle send with revoked consent

1. Package generation requests personalization decision for `lifecycle_email`.
2. Consent snapshot shows revoked channel permission.
3. Decision returns `allow_non_personalized` with suppression reason codes.
4. Email package is downgraded before send and recorded in audit/telemetry.

Example decision event:

```json
{
  "eventName": "channel_personalization.decision_evaluated",
  "decisionId": "cpd_01J010",
  "customerId": "cust_123",
  "channel": "email",
  "surface": "lifecycle_followup",
  "purposeOfUse": "lifecycle_email",
  "eligibility": "allow_non_personalized",
  "reasonCodes": ["CONSENT_REVOKED", "SUPPRESSION_ACTIVE"],
  "policyVersion": "consent-suppression-v3",
  "traceId": "trace_01HX1"
}
```

### Scenario B: Clienteling session with low identity confidence

1. Associate opens customer profile and requests `personal` recommendations.
2. Identity snapshot returns `low` confidence with unresolved merge.
3. Decision returns `allow_session_only` and blocks profile-heavy personalization.
4. UI displays degraded badge and serves contextual/non-personal alternatives.

## 23. Implementation Notes

Implementation implications:

- **Backend services:** add a dedicated channel-permission evaluation module in the channel-expansion domain; keep decisioning logic centralized and channel policy-specific behavior configurable.
- **Database tables/documents:** persist `ChannelPersonalizationDecision`, snapshot references, and immutable permission audit records.
- **Jobs/workers:** add re-evaluation workers listening to consent/suppression/identity events; add batch pre-evaluation support for email windows.
- **External APIs:** consume identity, consent, suppression, and auth context through canonical internal interfaces only.
- **Frontend/shared UI:** expose posture/status badges and reason summaries in campaign preview and clienteling screens without exposing sensitive internals.

Assumptions:

- Upstream systems publish versioned consent, suppression, and identity snapshots with stable customer IDs.
- Policy configuration is centrally managed and deployable by market/channel.
- Architecture stage will finalize endpoint versioning and error taxonomy under `DEC-003`.

Unresolved questions carried forward (do not resolve here):

- exact campaign vs personalization precedence behavior under `DEC-008`
- final email freshness-regeneration tie-in under `DEC-010` and `DEC-016`
- final operator explanation depth and platform constraints under `DEC-011`

## 24. Testing Requirements

Unit tests:

- policy rule precedence (suppression vs consent vs identity confidence)
- reason-code assignment and fallback action mapping
- fail-safe behavior when dependencies are unavailable

Contract tests:

- evaluate/re-evaluate API request-response schemas
- required fields (`decisionId`, `eligibility`, `reasonCodes`, `policyVersion`, `traceId`)
- produced event payload schema conformance

Integration tests:

- consent revoke/restore propagation into email and clienteling decisions
- identity confidence transitions during live clienteling sessions
- suppression update handling for queued email sends
- market-specific policy overrides and scoping

Non-functional and security tests:

- latency and throughput for request-time and batch paths
- cache invalidation correctness after upstream change events
- audit completeness, redaction behavior, and access controls
- regression tests verifying no personalization leakage when gating data is missing
