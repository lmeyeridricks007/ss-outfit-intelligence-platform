# Feature: Merchandising governance and operator controls

**Upstream traceability:** `docs/project/business-requirements.md` (BR-009); `docs/project/br/br-009-merchandising-governance.md`, `br-005-curated-plus-ai-recommendation-model.md`, `br-010-analytics-and-experimentation.md`, `br-011-explainability-and-auditability.md`, `br-004-rtw-and-cm-support.md`; `docs/project/goals.md`; `docs/project/personas.md`; `docs/project/product-overview.md`; `docs/project/roadmap.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (DEC-008, DEC-029, DEC-034, DEC-035, DEC-036).

---

## 1. Purpose

Define the governed operator-control plane that lets authorized teams shape recommendation behavior without relying on ad hoc engineering changes and without allowing optimization systems to bypass brand, campaign, inventory, privacy, or premium-service intent.

This feature exists to make recommendation behavior operable at production scale across ecommerce, clienteling, email, and admin surfaces by providing:

- curated **look** authoring and activation
- merchandising rules with explicit precedence
- scheduled campaigns and scoped boosts
- emergency and routine overrides
- approval and separation-of-duty boundaries
- traceable rollback, expiry, and audit history

## 2. Core Concept

Merchandising governance is a versioned control stack that sits between authoring workflows and recommendation decisioning.

The stack has four primary control families:

1. **Curated look controls** - brand-authored look groupings, fixed or reorderable placements, and curated priorities
2. **Rule controls** - hard exclusions, hard inclusions, compatibility policies, soft boosts, demotions, pins, and suppressions
3. **Campaign controls** - time-bounded market, channel, surface, and recommendation-type priorities
4. **Override controls** - temporary exceptions used to respond quickly to live business, catalog, or recommendation-quality issues

Every control must declare:

- who owns it
- where it applies
- when it activates and expires
- whether it is hard, soft, scheduled, or emergency in nature
- what it can outrank
- what approval path it requires
- how it will be audited, reviewed, and rolled back

Governance therefore defines the allowed operating envelope. Decisioning and **AI-ranked** optimization operate inside that envelope rather than redefining it.

## 3. Why This Feature Exists

The platform vision depends on combining curated taste, compatibility logic, context, identity, and AI ranking into one shared recommendation system. That mix becomes risky without explicit operator control.

This feature exists because SuitSupply needs to:

- preserve brand coherence while scaling recommendation reach
- let merchandisers influence outputs without engineering-only workflows
- schedule seasonal or channel-specific campaigns safely
- contain incidents quickly through bounded overrides
- keep premium and **CM** experiences under tighter review than routine **RTW** attachment flows
- show support, analytics, and governance teams exactly which business controls shaped a recommendation set

Without this feature, campaign intent, curated knowledge, and incident response would be fragmented across hidden process knowledge, one-off requests, and inconsistent local logic in downstream channels.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| **S2 merchandiser** | Cannot scale curated styling intent or enforce seasonal priorities quickly | Self-serve look, rule, campaign, and override controls with approval and rollback |
| **Marketing / CRM operator** | Needs campaign influence without causing uncontrolled recommendation drift | Scoped, scheduled campaign controls tied to explicit precedence |
| **S1 stylist / clienteling associate** | Needs recommendation behavior that stays trustworthy in assisted selling | Visible governance boundaries and higher-trust premium / CM controls |
| **S4 product / analytics / optimization** | Cannot interpret performance changes if campaign or override effects are invisible | Governance annotations, control IDs, and change markers tied to analytics and traces |
| **Support / operations** | Needs rapid incident containment for bad, stale, or harmful recommendations | Emergency override path with TTL, rationale, audit trail, and rollback |
| **Engineering / architecture** | Downstream teams guess at approval rules and precedence semantics | Canonical control taxonomy, state model, contracts, and propagation rules |

## 5. Scope

This feature covers the implementation-oriented requirements for:

- control families and their stable semantics
- authoring, approval, scheduling, activation, and archival workflows
- deterministic precedence and conflict resolution
- propagation of effective controls into delivery and trace layers
- approval boundaries by risk and scope
- auditability, rollback, and expiry discipline
- operator tooling required to manage governance safely

This feature does **not** freeze the final admin-UI technology choice, internal org chart, or database engine. It defines the business and system behaviors that architecture and implementation must preserve.

**Primary open decisions:** `DEC-008`, `DEC-029`, `DEC-034`, `DEC-035`, and `DEC-036`.

## 6. In Scope

- Curated **look** authoring, versioning, scheduling, and retirement
- Rule authoring for hard exclusions, hard inclusions, suppressions, boosts, demotions, and pins
- Campaign creation with time windows, scope boundaries, and priority levels
- Routine, scheduled, emergency, and system-applied overrides
- Draft, approval, publish, activate, expire, archive, and rollback states
- Risk-based approvals and separation-of-duty requirements
- Effective-control materialization for recommendation decisioning
- Admin views for conflicts, audit history, diffing, and preview simulation
- Propagation of rule, campaign, and override IDs into trace and telemetry paths

## 7. Out of Scope

- Financial planning, margin-strategy tooling, or pricing optimization
- Final legal workflow beyond recording required approval and audit evidence
- Final enterprise IAM vendor choice or final group names in every market
- Consumer-facing explanation copy for governance controls
- Full incident-management tooling outside recommendation-affecting actions
- Final build-vs-buy decision for admin UI platforms

## 8. Main User Personas

- **S2: Merchandiser** - primary author and approver for curated looks, rules, and campaign controls
- **Marketing / CRM operator** - uses governed campaign influence on recommendation surfaces
- **S1: Stylist / clienteling associate** - consumes governed outputs and, in limited contexts, may use narrower assisted-selling overrides
- **S4: Product / analytics / optimization** - evaluates the effect of governance changes and monitors override usage
- **Support / operations** - triggers emergency suppressions or escalation when recommendation incidents occur
- **Governance / compliance reviewers** - verify approval, access, and audit requirements for higher-risk controls

## 9. Main User Journeys

### Journey A: Launch a seasonal ecommerce campaign
1. Merchandiser creates a spring formalwear campaign with market, surface, and recommendation-type scope.
2. Associated curated looks and boosts are linked to the campaign window.
3. The control enters `pending_approval`.
4. After approval, the campaign is scheduled for activation.
5. At start time, the governance service publishes a new effective snapshot.
6. Decisioning consumes the snapshot and analytics records a change marker for later evaluation.

### Journey B: Respond to an inventory or brand-risk incident
1. Support or merchandising identifies a bad recommendation caused by catalog withdrawal or brand conflict.
2. Authorized operator opens the override console and applies a scoped emergency suppression or replacement.
3. The override activates immediately with a mandatory reason and expiry.
4. Notification and audit records are created.
5. Recommendation traces and telemetry include the override ID.
6. The override auto-expires or is formally closed after review.

### Journey C: Manage curated premium / CM experiences
1. A merchandiser assembles curated looks for a premium clienteling scenario.
2. The look set is marked with **CM** or premium constraints and fixed-order policy.
3. Approval flow requires stronger review than a routine **RTW** boost.
4. Once active, the governed ordering policy controls whether decisioning can reorder within the look.
5. Operators later compare performance and trace impact before promoting the pattern to broader use.

### Journey D: Roll back an unintended governance change
1. Merchandiser notices that a new campaign overpowered baseline recommendations on PDP.
2. Audit timeline shows the exact published version and related approvals.
3. Operator previews the prior effective state and selects rollback.
4. A superseding version is published and caches are invalidated.
5. Analytics and trace systems mark the rollback window so downstream analysis stays interpretable.

## 10. Triggering Events / Inputs

Governance workflows are triggered by:

- merchandiser creation or editing of a curated look, rule, or campaign
- scheduled activation or expiration windows
- API or batch import from assortment-planning or campaign systems
- analytics or support signals that suggest live recommendation harm
- inventory and catalog events that invalidate previously active controls
- premium or **CM** review workflows requiring explicit human approval
- operator rollback requests
- experiment or channel launches that require temporary governance boundaries

Primary inputs include:

- product, look, and assortment identifiers
- market, channel, surface, and recommendation-type scope
- `RTW` vs `CM` mode
- start and end times
- priority and precedence class
- reason codes and approval metadata
- governance snapshot references for traceability

## 11. States / Lifecycle

### Standard control lifecycle
`draft -> pending_approval -> approved -> scheduled -> active -> expired -> archived`

- **draft:** editable, not effective
- **pending_approval:** waiting for required reviewer or approver
- **approved:** approved but not yet active
- **scheduled:** activation is future-dated
- **active:** part of the effective control set
- **expired:** no longer effective because end time passed or dependency invalidated
- **archived:** retained for audit and diffing, not eligible for reactivation without cloning

### Emergency override lifecycle
`draft -> active -> pending_review -> expired -> archived`

- emergency overrides may bypass normal pre-approval only when policy allows
- they must always create post-change review work and a hard expiry or review deadline

### Rollback lifecycle
`candidate_previous_version -> previewed -> published_superseding_version -> active`

Rollback should restore a known-good prior configuration through a new versioned publish, not by mutating history in place.

## 12. Business Rules

- **Hard boundaries outrank everything else.** Consent, inventory validity, market restrictions, premium restrictions, and compatibility disqualifiers outrank campaigns, boosts, and AI ranking.
- **Deterministic precedence is mandatory.** Downstream services must not invent local tie-break behavior.
- **Control families remain distinct.** Curated looks, campaigns, rules, and overrides cannot be collapsed into one generic rule type in a way that hides their semantics.
- **No silent control drift.** Every active control must have an owner, scope, version, and effective window.
- **Temporary controls must expire.** Emergency and routine overrides require TTL or review deadline and cannot become permanent through neglect.
- **More specific scope wins at the same precedence class.** Surface-specific beats channel-wide; market-specific beats global.
- **Pins are not boosts.** A fixed-position pin must be explicit and auditable rather than simulated through very large boost values.
- **Curated order policy must be declared.** A curated look or set must say whether order is fixed, partially reorderable, or fully reorderable inside governed bounds.
- **Approval must match risk.** Broad-scope, premium, or hard-rule changes require stricter review than narrow soft changes.
- **Every effective recommendation set must be explainable through governance references.** Rule IDs, campaign IDs, suppression IDs, and override IDs must flow into trace and analytics paths.

### Required precedence order

1. Hard eligibility, policy, consent, and compatibility gates
2. Hard exclusions and suppressions
3. Emergency overrides
4. Mandatory inclusions, fixed pins, and fixed-order curated controls
5. Approved campaign priorities and scoped boosts
6. Soft preferences and **AI-ranked** optimization inside the remaining allowed set
7. Deterministic fallback behavior when no strong governed result is possible

## 13. Configuration Model

The governance layer requires configuration for:

- supported control families and rule subtypes
- scope dimensions: market, region, channel, surface, recommendation type, audience, and mode
- risk classes and required approval path
- environment promotion policies where lower environments are used for previewing
- expiry defaults and renewal rules for temporary controls
- preview datasets and anchor examples for simulation
- notification thresholds for conflicts, overlaps, and aging overrides
- export or import mappings for planning tools
- redaction and access rules for audit detail

Configurations must be versioned because decisioning, analytics, and explainability need to reconstruct what policy existed at recommendation time.

## 14. Data Model

### Core entities

| Entity | Purpose | Required core fields |
| --- | --- | --- |
| `CuratedLook` | Authoritative curated grouping used as seed, fixed presentation, or governed recommendation input | `lookId`, `version`, `title`, `owner`, `marketScope`, `surfaceScope`, `recommendationTypes[]`, `mode`, `orderingPolicy`, `status`, `effectiveFrom`, `effectiveTo` |
| `MerchandisingRule` | Hard or soft control affecting eligibility or ordering | `ruleId`, `version`, `ruleType`, `hardness`, `scope`, `owner`, `priorityClass`, `status`, `rationale`, `effectiveWindow`, `linkedCampaignId?` |
| `CampaignControl` | Time-bounded business priority or seasonal influence | `campaignId`, `version`, `name`, `priorityLevel`, `scope`, `effectiveFrom`, `effectiveTo`, `controlRefs[]`, `status`, `owner` |
| `OverrideControl` | Temporary exception to baseline governed behavior | `overrideId`, `version`, `overrideType`, `scope`, `reasonCode`, `rationale`, `initiatedBy`, `approvedBy?`, `expiresAt`, `status`, `emergencyFlag` |
| `ApprovalRecord` | Approval evidence for one control version | `approvalId`, `controlRef`, `requiredRole`, `actorId`, `decision`, `decidedAt`, `note` |
| `GovernanceSnapshot` | Effective, decisioning-ready projection of active controls | `snapshotId`, `generatedAt`, `scopePartitions[]`, `activeControlRefs[]`, `supersedesSnapshotId?`, `checksum` |
| `AuditEvent` | Immutable audit log entry for change, activation, access, or rollback | `auditEventId`, `eventType`, `controlRef`, `actorId`, `occurredAt`, `beforeRef`, `afterRef`, `reason`, `metadata` |

### Example override payload

```json
{
  "overrideId": "ovr_01JPG1YAH4J83YFWSB6F4SR2Q9",
  "version": 3,
  "overrideType": "emergency_suppress",
  "scope": {
    "market": "NL",
    "surface": "pdp",
    "recommendationType": "outfit",
    "mode": "RTW",
    "productIds": ["prod_12345"]
  },
  "reasonCode": "catalog_withdrawal",
  "rationale": "Suppress withdrawn anchor replacement until corrected imagery and inventory sync complete.",
  "initiatedBy": "user_456",
  "approvedBy": null,
  "expiresAt": "2026-03-23T10:00:00Z",
  "status": "active",
  "emergencyFlag": true
}
```

### Data-model notes

- Every entity needs a stable canonical ID and version history.
- `GovernanceSnapshot` is the decisioning-facing read model; it should not replace immutable authoring records.
- Ordering policy must be first-class rather than implied from control type.
- Snapshot generation must preserve links back to all contributing versions.

## 15. Read Model / Projection Needs

The feature requires read models for:

- **effective controls by scope** for low-latency decisioning lookups
- **active conflict view** showing overlapping campaigns, contradictory pins, and incompatible suppressions
- **approval inbox** for pending medium- and high-risk changes
- **override watchlist** for active and soon-to-expire overrides
- **audit timeline** filtered by control, actor, market, surface, or incident
- **diff viewer** comparing versions or rollback candidates
- **simulation preview projection** that answers "what would be effective for this anchor, surface, market, and mode?"
- **governance impact view** that can link active controls to recommendation traces and experiment periods

Decisioning read paths need compact projections keyed by market, surface, recommendation type, and mode so that runtime services do not execute full admin-oriented queries.

## 16. APIs / Contracts

This feature needs internal contracts for both authoring and effective-read access.

### Required authoring capabilities

- create, update, clone, archive, approve, reject, schedule, publish, and rollback controls
- preview effective behavior before activation
- search by control family, scope, risk, owner, and status
- retrieve audit history and version diffs

### Required effective-read capabilities

- resolve the active governance snapshot by request context
- retrieve active control references for tracing and operator drilldown
- expose change markers to analytics and explainability systems

### Example implementation-facing interfaces

- `POST /governance/looks`
- `POST /governance/rules`
- `POST /governance/campaigns`
- `POST /governance/overrides`
- `POST /governance/controls/{controlRef}/approve`
- `POST /governance/controls/{controlRef}/publish`
- `POST /governance/controls/{controlRef}/rollback`
- `POST /governance/preview/effective`
- `GET /governance/effective?market=...&surface=...&recommendationType=...&mode=...`
- `GET /governance/snapshots/{snapshotId}`

Wire-level design remains architecture work, but these semantic operations are required.

## 17. Events / Async Flows

### Flow A: Publish a scheduled campaign
1. Operator approves a campaign-linked control bundle.
2. Governance service marks the versions as approved and scheduled.
3. At activation time, a new `GovernanceSnapshot` is generated.
4. Snapshot publication invalidates decisioning caches and notifies analytics and explainability systems.
5. Recommendation traces start referencing the new snapshot ID.

### Flow B: Apply emergency override
1. Authorized operator creates an emergency suppression or replacement.
2. Governance service validates scope and risk policy.
3. Override becomes active immediately with required TTL and rationale.
4. `override.applied` event is emitted.
5. Snapshot is regenerated or delta cache updated.
6. Notifications are sent to governance owners and audit history is recorded.

### Flow C: Automatic expiration
1. Scheduled job or event timer reaches `expiresAt`.
2. Control moves to `expired`.
3. New effective snapshot is generated.
4. `control.expired` marker is emitted for analytics and trace viewers.
5. If the expired control was an emergency override, post-change review status is checked.

### Reliability expectations

- snapshot publish must be idempotent
- failed downstream invalidation must be retryable
- decisioning must have a defined fallback if the newest snapshot is temporarily unavailable
- audit events must remain append-only even when publish or notification fails

## 18. UI / UX Design

The admin experience should emphasize control clarity over raw flexibility.

### UX principles

- make control family and precedence obvious
- show scope in business terms first, raw IDs second
- preview impact before publish
- make risk class visible and explain why stronger approval may be required
- distinguish fixed-order curated behavior from reorderable governed completion
- surface overlaps, conflicts, and stale temporary controls early
- keep rollback discoverable and low-friction for authorized users

Operator UX should reduce accidental blast radius by guiding users through scope selection, approval requirements, and preview simulation rather than presenting one generic "rule builder" for everything.

## 19. Main Screens / Components

- **Look library** - browse, clone, diff, schedule, and retire curated looks and look sets
- **Rule builder** - define hard vs soft rules, suppressions, boosts, pins, and mandatory inclusions
- **Campaign manager** - schedule windows, scopes, linked controls, and priority handling
- **Override console** - apply, monitor, renew, or close temporary and emergency overrides
- **Approval inbox** - review pending changes by risk class and scope
- **Conflict center** - detect overlapping campaigns, contradictory pins, or incompatible suppressions
- **Simulation preview** - test effective control behavior against an anchor product, market, and surface
- **Audit timeline** - show before/after state, actor, rationale, and linked trace or incident references

## 20. Permissions / Security Rules

- all admin access must be authenticated and role-based
- author, approver, and publisher permissions must be separable for medium- and high-risk controls
- emergency override capability must be narrower than ordinary low-risk editing
- premium and **CM** control changes require stricter permissions than routine **RTW** boosts
- audit history and rollback access may be broader than full editing but still role-bound
- trace-linked governance detail must respect redaction rules from explainability and audit features
- no anonymous or shared generic admin identity is allowed for recommendation-affecting changes

## 21. Notifications / Alerts / Side Effects

The feature must support notifications for:

- pending approvals awaiting action
- overlapping campaigns or contradictory control scopes
- active overrides approaching expiry
- emergency override creation
- failed snapshot publication or delayed propagation
- unusually high override frequency on a major surface

Side effects include:

- cache invalidation for decisioning and rendering layers
- change markers for analytics and experimentation
- trace annotations for explainability and support tooling
- optional integrations to incident or collaboration systems, provided they remain secondary to the canonical audit log

## 22. Integrations / Dependencies

- **Recommendation decisioning and ranking** - consumes effective control snapshots and precedence rules
- **Catalog and product intelligence** - provides eligibility, inventory, category, and compatibility data that governance rules rely on
- **Shared contracts and delivery API** - propagates `governanceSnapshotId`, rule IDs, campaign IDs, and override IDs downstream where required
- **Explainability and auditability** - reconstructs why governance changed a recommendation set
- **Analytics and experimentation** - measures governance impact and records override events
- **Ecommerce surface experiences** - primary Phase 1 consumer of governance behavior on PDP and cart
- **Channel expansion: email and clienteling** - later consumers that need the same semantics across channels
- **Identity and style profile** - informs where personalization may operate inside governance boundaries

Governance depends on these integrations exposing stable IDs and scopeable context. It cannot safely operate if downstream consumers silently reinterpret rule meaning or omit trace references.

## 23. Edge Cases / Failure Cases

- **Conflicting pins at the same precedence and scope:** system must reject publish or force deterministic resolution before activation
- **Campaign overlaps with equal priority:** apply explicit tie-break rules and record the winning basis in audit metadata
- **Curated look references withdrawn or ineligible products:** mark the look degraded, suppress invalid members, or block activation depending on policy and surface
- **Emergency override expires during live traffic:** snapshot transition must be atomic enough to avoid prolonged stale behavior
- **Approval actor loses permission before scheduled activation:** scheduled control should stay valid if approval remains auditable, but policy should be explicit
- **Cross-surface scope too broad by mistake:** preview and blast-radius warnings must surface before publish
- **System-applied suppression triggered by inventory or trust rules:** must remain visible as governed behavior, not invisible ranking output
- **Rollback target depends on now-missing catalog entities:** rollback preview should warn and require explicit confirmation or partial restore policy

## 24. Non-Functional Requirements

- effective-read path must be fast enough for interactive recommendation requests on primary ecommerce surfaces
- audit store must be append-only and tamper-evident at the application level
- authoring flows should support optimistic concurrency or equivalent conflict prevention
- snapshot generation and propagation must be reliable and observable
- publish and rollback actions should complete quickly enough for incident response
- control search and diff views should remain responsive for operators managing large rule and campaign inventories
- retention and archival policy must preserve enough history for analytics and governance review

## 25. Analytics / Auditability Requirements

This feature must emit enough evidence for downstream measurement and investigation to answer:

- which controls were active for a recommendation set
- whether performance changed because of campaign influence, override behavior, or baseline optimization
- how often operators rely on emergency vs routine overrides
- which controls create frequent conflicts, expirations, or rollback events
- whether premium or **CM** control changes are reviewed differently from routine **RTW** changes

At minimum:

- recommendation telemetry must include rule, campaign, suppression, and override references where applicable
- `override` events must be first-class analytics events
- traces must include `governanceSnapshotId`
- audit logs must preserve before/after differences, actor, time, and rationale
- dashboards should distinguish active, expired, and archived temporary controls

## 26. Testing Requirements

- contract tests for control entity schemas and effective-read contracts
- precedence tests covering exclusions, pins, boosts, campaigns, and emergency overrides
- approval-path tests for low-, medium-, high-, and emergency-risk flows
- expiry and rollback tests, including auto-expiration and post-change review behavior
- simulation-preview tests against representative anchors, markets, and modes
- performance tests for effective snapshot lookup on high-traffic PDP and cart paths
- permissions matrix tests across author, approver, publisher, and support roles
- integration tests ensuring analytics and trace systems receive correct control references

## 27. Recommended Architecture

Recommended logical shape:

`admin authoring layer -> workflow and approval service -> immutable version store -> governance snapshot builder -> effective snapshot cache / API -> decisioning consumers -> analytics / trace / audit integrations`

Supporting components:

- immutable control version store
- workflow engine or approval orchestration
- effective snapshot builder
- search and diff index for operator tooling
- append-only audit log
- event publisher for analytics, explainability, and incident integrations

The core architectural boundary is that authoring records and audit history remain authoritative, while decisioning consumes a compact effective snapshot built from approved active controls.

## 28. Recommended Technical Design

- use stable IDs and version numbers for all control families
- materialize a `GovernanceSnapshot` keyed by market, surface, recommendation type, and mode
- include `governanceSnapshotId` in recommendation responses and traces
- model precedence class explicitly, not as implicit numeric boosts only
- represent ordering policy as a dedicated field for curated looks and pins
- implement optimistic concurrency on edits and explicit compare-before-publish checks
- store approval records separately from mutable authoring content
- emit domain events for create, approve, publish, expire, rollback, and access-review milestones

## 29. Suggested Implementation Phasing

- **Phase 1:** Core ecommerce **RTW** governance foundation for PDP and cart; curated look management; hard and soft rules; scoped campaigns; emergency override path; approval inbox; audit timeline; effective snapshot propagation; trace and analytics linkage
- **Phase 2:** Richer simulation previews; stronger conflict center; broader support for personalization and context interaction once `DEC-008` is resolved
- **Phase 3:** Cross-channel governance dashboards; richer clienteling and marketing control surfaces; more mature import/export workflows
- **Phase 4:** Stricter premium and **CM** approval boundaries; curated-first policies for high-trust selling contexts; advanced operator tooling once earlier governance behavior is proven trustworthy

Phase 1 should optimize for correctness, determinism, and auditability rather than maximum rule expressiveness.

## 30. Summary

Merchandising governance and operator controls is the platform's production control plane for recommendation behavior.

The implementation bar for this feature is:

- distinct, versioned control families
- deterministic precedence
- scoped approvals and separation of duty
- reliable activation, expiry, and rollback
- effective snapshots for decisioning
- complete trace and analytics linkage

The key unresolved areas are visible rather than hidden:

- `DEC-008` - campaign vs personalization / context precedence
- `DEC-029` - emergency override visibility in operator traces
- `DEC-034` - approval-role matrix and dual-approval thresholds
- `DEC-035` - maximum duration and renewal policy for emergency overrides
- `DEC-036` - default curated ordering policy by surface and mode

If those decisions are resolved cleanly, downstream architecture and implementation work can build a governance subsystem that keeps recommendation behavior operable, measurable, and trustworthy across channels.
