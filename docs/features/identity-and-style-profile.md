# Feature: Identity and style profile

**Upstream traceability:** `docs/project/business-requirements.md` (BR-012, BR-006, BR-011, BR-003); `docs/project/br/br-012-identity-and-profile-foundation.md`, `br-006-customer-signal-usage.md`, `br-011-explainability-and-auditability.md`; `docs/project/vision.md`; `docs/project/goals.md`; `docs/project/problem-statement.md`; `docs/project/personas.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md` (`style profile`, `profile service`, `trace ID`); `docs/project/roadmap.md` (Phase 2 personalization expansion, Phase 3 channel scale).

---

## 1. Purpose

Provide the shared customer foundation that lets the platform know when a shopper is the same person across ecommerce, email, CRM, store, and clienteling systems, and then expose a bounded **style profile** that ranking, suppression, and cross-channel activation can use safely.

This feature exists to answer all of the following consistently:

- who the platform believes the customer is
- how confident that belief is
- which source-system identifiers contributed to that belief
- which style or wardrobe signals are current and allowed for recommendation use
- which suppressions or channel restrictions apply
- how recommendation consumers should degrade when identity or profile certainty is weak

Without this feature, the platform can support **contextual** and session-aware recommendations, but it cannot safely scale **personal** recommendations across surfaces.

## 2. Core Concept

Identity and style profile are related but intentionally separate artifacts:

1. **Identity foundation** - canonical customer ID, source mappings, confidence, provenance, and conflict handling
2. **Style profile** - a recommendation-ready summary of allowed wardrobe, preference, fit, occasion, and suppression signals
3. **Activation envelope** - the request-time answer to "how much of this profile may the consumer use for this channel and purpose?"

The separation matters because the platform must not flatten all customer data into one opaque record. Downstream services need to know:

- whether the customer identity is trusted enough for durable personalization
- whether only bounded profile use is allowed
- whether current-session behavior should be used without durable profile context
- whether the system must fall back to governed non-personalized recommendations

The feature therefore acts as the bridge between:

- `customer-signal-ingestion.md`
- `recommendation-decisioning-and-ranking.md`
- `channel-expansion-email-and-clienteling.md`
- `analytics-and-experimentation.md`
- `explainability-and-auditability.md`

## 3. Why This Feature Exists

The product vision and goals require recommendations that feel like SuitSupply remembers the customer across touchpoints, but the platform must not over-trust weak matches or use customer history in a way that breaks privacy or operator trust.

This feature exists because:

- the problem statement explicitly calls out fragmented channel logic and weak combination of profile with context
- Phase 2 roadmap work depends on confidence-aware personalization rather than anonymous-only recommendation flows
- BR-012 requires stable canonical IDs, source mappings, explicit confidence, and usable style profile summaries
- BR-006 requires graceful degradation when identity confidence, freshness, or consent are weak
- BR-011 requires operators to understand what identity and profile state influenced a recommendation

In short, this feature turns "customer recognition" from an ad hoc integration problem into a governed platform capability.

## 4. User / Business Problems Solved

### Customer problems solved

- **P2 returning style-profile customer:** receives recommendations that complement prior wardrobe context rather than repeating owned products or ignoring known preferences.
- **P1 anchor-product shopper:** can be treated as a known customer when confidence is strong, without unsafe history activation when identity is weak.
- **P3 occasion-led shopper:** gets profile-aware support only when it strengthens the occasion mission instead of conflicting with it.

### Operator problems solved

- **S1 stylist / clienteling associate:** sees whether the displayed customer context is trusted, bounded, or degraded before using it in assisted selling.
- **S2 merchandiser:** can rely on consistent suppression and customer-state semantics across ecommerce, email, and clienteling.
- **S3 marketing manager:** gets a shared known-customer contract for outbound activation rather than separate identity logic per channel.
- **S4 product / analytics / optimization:** can measure recommendation outcomes by identity-confidence and profile-activation level.

### Business problems solved

- reduces duplicate or unsuitable recommendations caused by weak cross-system matching
- enables safe cross-channel personalization expansion in Phase 2 and later phases
- preserves governance and privacy boundaries while improving relevance
- creates one reusable profile-service contract for all consumers
- supports better auditability when operators investigate "why did we recommend this?"

## 5. Scope

This feature covers the shared semantics and system responsibilities for customer identity resolution, style profile formation, profile-safe activation, and cross-channel consistency.

### Core responsibilities

- maintain stable canonical customer IDs and preserved source mappings
- evaluate identity confidence and conflict state without hiding uncertainty
- compute recommendation-ready style profile summaries from governed signals
- expose activation-safe profile slices for ecommerce, email, and clienteling consumers
- apply customer-level suppressions, duplicate-ownership cues, and opt-out boundaries
- define degraded modes when identity, consent, freshness, or provenance are weak
- make identity and profile state visible in traces, analytics, and operator review flows

### Explicitly tracked open decisions

This feature depends on cross-cutting decisions that should remain in the portfolio register rather than as hidden local TODOs:

- `DEC-030` - identity-confidence thresholds and auto-link criteria by source and consuming channel
- `DEC-031` - allowed profile domains by channel, surface, and recommendation purpose
- `DEC-032` - ownership, returns, and duplicate-suppression windows for wardrobe-aware recommendations
- `DEC-033` - operator review workflow and escalation policy for conflicted or sensitive identity cases

## 6. In Scope

- canonical customer identity across commerce, CRM, ESP, loyalty, POS, and clienteling inputs
- explicit confidence states: `high`, `bounded`, `low`, `conflicted`, `unknown`
- source-mapping lifecycle and provenance for each linked identifier
- style profile domains such as wardrobe ownership, category affinities, fit tendencies, occasion tendencies, and price or assortment orientation
- suppression and activation controls tied to consent, confidence, freshness, and provenance
- cross-channel profile-service behavior for ecommerce, email packaging, and clienteling retrieval
- request-time profile activation modes such as full-profile, bounded-profile, session-only, and none
- internal operator surfaces for profile review, suppression visibility, and identity conflict handling
- trace and telemetry fields that explain what identity/profile state influenced recommendation delivery

## 7. Out of Scope

- a full standalone CDP or marketing-automation roadmap
- billing, payments, or fraud identity beyond recommendation needs
- third-party purchased identity graphs or non-permitted enrichment sources
- final probabilistic matching algorithm or ML model details for linkage scoring
- final infrastructure vendor choice for identity graph storage or profile serving
- final legal-policy wording by market beyond the business boundaries captured here
- final UI pixel-level design for customer-360 or clienteling screens

## 8. Main User Personas

| Persona | Why this feature matters |
| --- | --- |
| **P2 returning style-profile customer** | Needs recommendations that reflect prior wardrobe context consistently across web, email, and assisted selling. |
| **P1 anchor-product shopper** | May become a known customer during the session, but only if the system can safely upgrade identity confidence. |
| **P3 occasion-led shopper** | Benefits when trusted profile context complements occasion intent without overriding it. |
| **S1 stylist / clienteling associate** | Needs trusted customer context and visible degraded states before using recommendations in assisted selling. |
| **S3 marketing manager** | Needs channel-safe profile activation that respects consent and avoids wrong-person personalization. |
| **S4 product / analytics stakeholder** | Needs confidence-aware telemetry, traces, and experiment stratification by identity state. |

## 9. Main User Journeys

### Journey 1: Anonymous ecommerce session becomes known customer

1. Shopper browses anonymously and accumulates session-safe behavior.
2. Shopper logs in or uses a recognized identifier.
3. Identity service evaluates whether the source mapping can link to an existing canonical customer.
4. If confidence is high enough, a canonical customer ID becomes active for the session.
5. Recommendation requests may now use bounded or full profile context depending on consent and freshness.
6. Trace metadata records the upgrade path so operators can explain why personalization depth changed mid-session.

### Journey 2: Email click to ecommerce continuity

1. A marketing flow packages recommendations for a known customer using a shared canonical customer ID.
2. Customer opens and clicks through to ecommerce.
3. The web surface resolves the same canonical ID through governed source mappings rather than inventing a channel-local profile.
4. Shared suppressions and style-profile summaries remain consistent across both surfaces.
5. Telemetry ties email and ecommerce outcomes back to the same identity-confidence and profile-snapshot lineage.

### Journey 3: Clienteling retrieval with bounded profile use

1. An associate opens a customer profile before an appointment.
2. Identity service finds the canonical customer but with only bounded confidence for some attached sources.
3. Profile service exposes trusted domains such as known purchases and approved fit cues while withholding lower-trust signals.
4. Recommendations remain profile-informed but conservative.
5. Associate UI shows explanation-safe badges such as `bounded profile` and `confidence limited`.

### Journey 4: Conflict detection and conservative fallback

1. A new source identifier appears that could belong to multiple existing customer records.
2. Identity service cannot safely auto-link.
3. Identity state moves to `conflicted` for that source mapping or case.
4. Durable cross-channel personalization is suppressed.
5. Consumers fall back to session-only or governed non-personalized recommendations.
6. Operators can review the case without the live recommendation path making unsafe assumptions.

## 10. Triggering Events / Inputs

### Identity triggers

- login or authenticated session start
- email clickthrough with known channel identifier
- order creation, return, exchange, or guest-to-known-customer conversion
- loyalty enrollment or update
- POS or store visit linked to a known customer
- clienteling appointment or associate lookup
- CRM import or source-system synchronization

### Profile triggers

- purchase history changes
- browsing, product-view, search, or add-to-cart events that are eligible for profile enrichment
- consent or opt-out changes
- operator-reviewed preference or fit updates
- suppression rule changes such as do-not-repeat windows or category blocks
- profile expiry or recomputation windows

### Required input families

| Input family | Example sources | Primary use |
| --- | --- | --- |
| Source identifiers | commerce account ID, email platform ID, CRM contact ID, loyalty ID, POS customer ID | canonical mapping and provenance |
| Identity evidence | explicit login, customer-initiated linking, trusted store lookup, repeated source confirmation | confidence evaluation |
| Durable history | orders, returns, loyalty status, reviewed stylist preferences | style profile and suppressions |
| Session signals | active browse or cart context | bounded activation and degradation when durable identity is weak |
| Consent state | marketing permission, profile-use permission, region-specific status | activation gating |
| Governance signals | suppression rules, blocked categories, reviewed customer preferences | safe personalization boundaries |

## 11. States / Lifecycle

This feature has multiple related lifecycles: source mappings, identity cases, and profile snapshots.

### Source-mapping lifecycle

| State | Meaning | Downstream behavior |
| --- | --- | --- |
| `observed` | source identifier seen but not linked | source cannot drive known-customer activation yet |
| `proposed` | candidate link exists pending threshold or review | usable only for internal investigation, not live durable personalization |
| `active` | source linked to canonical customer | may participate in known-customer activation based on confidence and consent |
| `superseded` | mapping replaced by newer canonical linkage | retained for history and audit, not active use |
| `revoked` | link removed due to error, policy, or deletion | must not be used for recommendation activation |

### Identity-case lifecycle

| State | Meaning | Downstream behavior |
| --- | --- | --- |
| `unknown` | no trusted known-customer identity available | session-only or non-personalized mode |
| `resolved_high` | trusted canonical identity available | full profile mode may be allowed |
| `resolved_bounded` | customer likely known, but some restrictions apply | bounded-profile mode |
| `conflicted` | multiple plausible identities or contradictory evidence | conservative fallback and review path |
| `restricted` | identity known but consent or policy blocks profile use | known customer for traceability, but no durable personalization |

### Profile-snapshot lifecycle

| State | Meaning | Downstream behavior |
| --- | --- | --- |
| `computed` | fresh profile snapshot ready | consumers may use allowed domains |
| `partially_computed` | some domains missing or withheld | consumers use available domains with domain-level flags |
| `stale` | snapshot exists but freshness has degraded | bounded use or recomputation required |
| `recomputing` | refresh in progress | consumers use last valid snapshot only if policy allows |
| `expired` | no longer acceptable for current purpose | fall back to session-only or non-personalized behavior |
| `deleted` | profile removed due to deletion or policy | no profile activation; only non-personalized modes remain |

## 12. Business Rules

### Identity-confidence rules

1. `high` confidence is required before durable cross-channel **personal** recommendations can rely on the full style profile.
2. `bounded` confidence may allow lower-risk domains such as obvious duplicate suppression or broad category tendencies, but not unrestricted history use.
3. `low` or `conflicted` confidence must not activate durable personal ranking as if the customer were confirmed.
4. `unknown` identity supports only session-safe or non-personalized behavior.

### Style-profile rules

1. Style profile must remain separate from raw source mappings and raw event history.
2. Every profile domain must carry freshness and trust metadata.
3. Absence of evidence must not be treated as explicit dislike or negative preference.
4. Session behavior must not silently overwrite durable customer truth.
5. Returned, exchanged, or cancelled orders must temper ownership-based suppressions once policy decisions are finalized.

### Activation and suppression rules

1. Consent and channel permission are hard constraints, not ranking hints.
2. Customer-level suppressions may operate at item, look, category, channel, or message scope depending on available evidence.
3. Duplicate-ownership suppression must be confidence-aware and freshness-aware.
4. Clienteling may expose richer reviewed context than ecommerce, but still cannot bypass consent or conflict boundaries.
5. Explanation and telemetry must indicate whether profile use was full, bounded, session-only, or none.

## 13. Configuration Model

This feature requires governed configuration instead of consumer-specific heuristics.

### Key configuration domains

- auto-link thresholds by source type and market
- review-required thresholds for ambiguous mappings
- allowed profile domains by channel and recommendation purpose
- freshness policies by profile domain
- duplicate-ownership and return-aware suppression windows
- consent and opt-out policy mapping by channel and region
- retention and deletion behavior for source mappings and profile snapshots

### Example configuration objects

| Object | Purpose | Example fields |
| --- | --- | --- |
| `IdentityLinkPolicy` | define auto-link and review behavior | `policyId`, `sourceType`, `autoLinkThreshold`, `reviewThreshold`, `market`, `allowedEvidenceTypes[]` |
| `ProfileDomainPolicy` | govern domain activation by consumer | `channel`, `purpose`, `allowedDomains[]`, `minConfidence`, `maxSnapshotAge`, `requiresConsent` |
| `SuppressionPolicy` | customer-specific suppression behavior | `policyId`, `scope`, `lookbackWindow`, `returnAdjustmentRule`, `hardBlockTypes[]` |
| `DeletionPolicy` | govern revocation and erasure behavior | `region`, `retentionClass`, `profileDeletionDelay`, `mappingRevocationMode` |

## 14. Data Model

### Core entities

| Entity | Purpose | Key fields |
| --- | --- | --- |
| `CanonicalCustomer` | durable internal customer identity | `canonicalCustomerId`, `status`, `createdAt`, `updatedAt`, `activeSourceCount` |
| `SourceMapping` | link from external identifier to canonical customer | `mappingId`, `sourceType`, `externalId`, `canonicalCustomerId`, `status`, `confidence`, `firstSeenAt`, `lastConfirmedAt`, `linkReason`, `market` |
| `IdentityCase` | reviewable conflict or ambiguity record | `identityCaseId`, `caseType`, `candidateCustomers[]`, `status`, `severity`, `openedAt`, `resolvedAt` |
| `ProfileSnapshot` | immutable style profile state | `profileSnapshotId`, `canonicalCustomerId`, `computedAt`, `expiresAt`, `profileState`, `domainSummaries[]`, `suppressionSummary[]` |
| `ProfileDomainSummary` | one bounded profile domain | `domain`, `valueSummary`, `confidence`, `freshnessTs`, `lineage[]`, `allowedFor[]` |
| `ActivationEnvelope` | request-time allowed profile use | `activationEnvelopeId`, `canonicalCustomerId?`, `identityConfidence`, `consentState`, `mode`, `allowedDomains[]`, `restrictionCodes[]`, `profileSnapshotId?` |

### Example profile snapshot

```json
{
  "profileSnapshotId": "ps_01HXYZ...",
  "canonicalCustomerId": "cust_01HXYZ...",
  "computedAt": "2026-03-21T09:30:00Z",
  "expiresAt": "2026-03-28T09:30:00Z",
  "profileState": "computed",
  "domainSummaries": [
    {
      "domain": "owned_categories",
      "valueSummary": ["suiting", "formal_shirts"],
      "confidence": "high",
      "freshnessTs": "2026-03-20T12:05:00Z",
      "lineage": ["orders"],
      "allowedFor": ["ecommerce", "email", "clienteling"]
    },
    {
      "domain": "occasion_tendencies",
      "valueSummary": ["business_formal", "wedding_guest"],
      "confidence": "bounded",
      "freshnessTs": "2026-03-01T10:00:00Z",
      "lineage": ["orders", "reviewed_preferences"],
      "allowedFor": ["ecommerce", "clienteling"]
    }
  ],
  "suppressionSummary": [
    {
      "scope": "category",
      "value": "duplicate_suiting_within_window",
      "source": "orders"
    }
  ]
}
```

## 15. Read Model / Projection Needs

- low-latency canonical-customer lookup by trusted source identifier
- source-mapping projection optimized for login, email click, and clienteling retrieval flows
- profile-snapshot projection optimized for interactive recommendation requests
- domain-level eligibility projection that combines consent, confidence, freshness, and allowed-purpose rules
- suppression projection for ownership and channel opt-out checks
- analytics projection showing recommendation outcomes by identity-confidence and activation mode
- operator review projection for conflicted identities and recent mapping changes

## 16. APIs / Contracts

This feature should expose shared internal contracts rather than making each consumer recreate identity logic.

### Internal service operations

- `POST /internal/identity/resolve`
  - input: source identifiers, channel, market, optional session context
  - output: canonical customer state, confidence, mapping summary, restriction codes
- `GET /internal/customers/{canonicalCustomerId}/profile`
  - input: purpose, channel, market
  - output: style profile snapshot plus domain-level eligibility metadata
- `POST /internal/profile/evaluate-activation`
  - input: canonical customer state, channel, purpose, session context
  - output: `ActivationEnvelope`
- `POST /internal/identity/link`
  - input: reviewed or explicit link request
  - output: updated source mapping and audit reference

### Required contract metadata for recommendation consumers

Every recommendation path that uses known-customer logic should be able to carry:

- `canonicalCustomerId` when known
- `identityConfidence`
- `activationEnvelopeId`
- `profileSnapshotId`
- `personalizationMode`
- `restrictionCodes[]`
- `recommendationSetId`
- `traceId`

### Example activation response

```json
{
  "activationEnvelopeId": "ae_01HXYZ...",
  "canonicalCustomerId": "cust_01HXYZ...",
  "identityConfidence": "bounded",
  "consentState": "granted",
  "mode": "bounded_profile",
  "allowedDomains": ["owned_categories", "broad_style_affinities"],
  "restrictionCodes": ["NO_EMAIL_ACTIVATION", "WITHHOLD_OPERATOR_NOTES"],
  "profileSnapshotId": "ps_01HXYZ..."
}
```

## 17. Events / Async Flows

### Key events

- `identity.source.observed`
- `identity.mapping.activated`
- `identity.mapping.superseded`
- `identity.case.opened`
- `identity.case.resolved`
- `profile.snapshot.computed`
- `profile.snapshot.expired`
- `profile.activation.evaluated`
- `profile.suppression.updated`
- `consent.state.changed`
- `customer.deletion.requested`

### Async flows

1. **Profile recomputation after durable-signal change**
   - order or return event lands in customer signal ingestion
   - identity service resolves canonical customer
   - eligible domains are recomputed
   - new snapshot is published and caches are invalidated

2. **Conflict detection**
   - a new source identifier or synchronization produces ambiguous evidence
   - identity case is opened
   - live consumers degrade to safer activation mode
   - operators can review without blocking all non-personalized recommendation traffic

3. **Deletion and revocation**
   - deletion or policy revocation event arrives
   - mappings and profile snapshots are marked restricted or deleted according to policy
   - downstream consumers stop profile activation
   - analytics and audit paths preserve only allowed historical linkage

## 18. UI / UX Design

### Customer-facing expectations

- customer-facing experiences should benefit from profile context without exposing raw identity-confidence or profile internals
- copy may imply relevance at a high level, but should not reveal sensitive reasoning such as "because we merged your store and email profiles"
- if a customer is not safely known, the UI should still behave normally through session-aware or governed defaults rather than showing trust warnings

### Operator-facing expectations

- clienteling and admin surfaces need clear status badges such as `high confidence`, `bounded profile`, `conflicted`, or `suppressed for email`
- operators should be able to tell which domains are available and which are withheld
- review tooling should summarize why a profile is limited without forcing raw event-log inspection

## 19. Main Screens / Components

- identity-resolution admin console
- conflicted-identity review queue
- customer profile summary panel for clienteling
- suppression and consent summary drawer
- operator trace view showing identity/profile state used in a recommendation set
- profile-domain inspection view with freshness and lineage summaries
- audit-history panel for link, unlink, and profile-change events

## 20. Permissions / Security Rules

- PII-bearing source mappings must be encrypted at rest and tightly access controlled
- customer profile domain visibility must be role-based and purpose-limited
- clienteling roles may see more reviewed profile detail than broad merchandising or analytics roles
- email and marketing consumers may use only domains explicitly allowed for outbound activation
- audit access for identity cases and sensitive overrides may require narrower permissions than routine recommendation traces
- deletion, consent, and revocation updates must propagate with strong consistency relative to activation decisions

## 21. Notifications / Alerts / Side Effects

- alert when identity conflict rates spike for a source system or market
- alert when auto-link or revocation volume exceeds expected ranges
- notify operators when a high-value clienteling record is moved into `conflicted` or `restricted` state if policy requires
- emit operational notices when profile recomputation backlog causes stale-snapshot rates to rise
- surface internal warnings when a consumer repeatedly requests channels or domains that are not allowed

## 22. Integrations / Dependencies

### Direct dependencies

- `customer-signal-ingestion.md` for governed raw-signal families and freshness semantics
- `shared-contracts-and-delivery-api.md` for stable delivery and trace metadata
- `recommendation-decisioning-and-ranking.md` for request-time use of activation envelopes and suppressions
- `analytics-and-experimentation.md` for cohorting and outcome measurement by identity state
- `explainability-and-auditability.md` for trace reconstruction, operator review, and audit linkage
- `channel-expansion-email-and-clienteling.md` for outbound and assisted-selling activation semantics
- `context-engine-and-personalization.md` for interplay between customer context and request-time personalization modes

### External integrations

- commerce account system
- CRM and ESP identity sources
- loyalty platform
- POS or store customer systems
- clienteling platform
- privacy and consent source of truth where separate from commerce or CRM

## 23. Edge Cases / Failure Cases

- forwarded email causing an email identifier to appear in a different active session
- shared household device producing ambiguous session-to-customer associations
- guest checkout later converted to an authenticated customer account
- returns or exchanges making ownership-based suppression incorrect if not adjusted
- duplicate CRM and commerce contacts created in separate markets
- stylist-entered preferences conflicting with fresher explicit purchase or browse behavior
- consent revoked after profile snapshot was computed but before outbound packaging or recommendation delivery
- clienteling lookup requiring a customer recommendation session while identity remains `conflicted`

### Failure-handling expectations

- when identity is ambiguous, degrade personalization depth rather than guessing
- when profile freshness is insufficient, fall back to session-only or non-personalized recommendations
- when consent changes, hard-stop further disallowed activation even if cached profile data exists
- when source systems are unavailable, continue serving recommendations using unaffected modes and last valid allowed data only if policy permits

## 24. Non-Functional Requirements

- interactive identity resolution and activation evaluation must fit within ecommerce request-time budgets
- email and batch packaging may allow asynchronous profile refresh, but must enforce freshness and permission checks before send
- canonical ID and profile snapshot references must be reproducible enough for audit and analytics
- consent and revocation propagation must prioritize correctness over stale-cache convenience
- the feature must support multi-market scale and multiple source systems without channel-specific forks
- degraded known-customer behavior must be a first-class supported mode, not an exceptional failure path

## 25. Analytics / Auditability Requirements

### Required telemetry

- recommendation outcomes by `identityConfidence`
- recommendation outcomes by `personalizationMode`
- profile-domain usage by channel and surface
- degraded-known-customer rate and reason codes
- suppression-trigger rate for duplicate ownership, channel opt-out, and withheld profile domains
- profile freshness distribution for domains used in live delivery

### Required audit fields

- `canonicalCustomerId`
- `sourceMappingId`
- `identityCaseId`
- `profileSnapshotId`
- `activationEnvelopeId`
- `identityConfidence`
- `restrictionCodes[]`
- `traceId`
- `recommendationSetId`
- `policyVersion`

### Measurement expectations

- experiment and reporting views must be able to stratify results by identity-confidence band
- profile-aware recommendation performance must be separable from session-only and non-personalized behavior
- teams must be able to distinguish failures caused by weak identity, stale profile, and poor ranking quality

## 26. Testing Requirements

### Functional tests

- source-mapping lifecycle tests from observed to active, superseded, and revoked
- confidence-band activation tests across ecommerce, email, and clienteling purposes
- profile-domain eligibility tests by consent, freshness, and channel
- suppression tests for duplicate ownership, return adjustments, and channel opt-outs
- conflict-case tests ensuring conservative fallback instead of unsafe auto-linking

### Data and contract tests

- canonical ID stability tests across source updates
- schema tests for identity resolution, profile snapshot, and activation envelope payloads
- trace-field completeness tests for recommendation consumers that use known-customer logic
- deletion and revocation propagation tests

### Scenario tests

- known customer opens ecommerce from an email and receives consistent profile use
- ambiguous email identifier causes bounded or no personalization rather than full profile activation
- return event removes a duplicate-ownership suppression after recomputation
- clienteling session uses reviewed profile domains while withholding disallowed email-only domains
- consent revoked between package generation and send prevents activation

## 27. Recommended Architecture

- a dedicated **identity service** that owns canonical customer IDs, source mappings, and conflict management
- a related **profile service** that owns immutable profile snapshots and domain-level eligibility summaries
- a lightweight **activation evaluation component** that converts stored identity/profile state into request-time allowed-use answers
- event-driven recomputation from eligible signal changes
- read-optimized projections for interactive resolution, profile retrieval, and operator review

This architecture keeps identity mechanics, profile computation, and request-time activation distinct while still interoperating through stable IDs and contracts.

## 28. Recommended Technical Design

- issue immutable `profileSnapshotId` values rather than mutating one in-place profile blob
- separate raw source mappings from recommendation-ready domain summaries
- store domain-level freshness and lineage so consumers can understand partial validity
- represent conflicts explicitly through `IdentityCase` records instead of burying them in low-level logs
- generate `activationEnvelopeId` per evaluation so traces can reconstruct what was allowed at decision time
- keep domain-level allowed-purpose metadata close to the profile snapshot or activation projection to prevent consumer-side guessing

## 29. Suggested Implementation Phasing

### Phase 1

- anonymous and session identifiers only
- recommendation delivery and telemetry contracts prepared to carry future canonical customer and profile references
- no strong durable **personal** recommendation activation beyond session-safe behavior

### Phase 2

- canonical identity across major digital and commerce sources
- confidence-aware style profile snapshots for ecommerce and email-safe uses
- duplicate-ownership suppression and bounded known-customer activation
- shared identity and profile metadata in traces and analytics

### Phase 3

- richer clienteling and reviewed store-signal integration
- conflicted-identity review tooling and stronger operator inspection flows
- broader cross-channel consistency and reporting

### Phase 4 and later

- deeper CM-aware profile domains where allowed
- more nuanced premium and appointment-driven profile logic
- tighter optimization based on proven confidence and suppression quality

## 30. Summary

Identity and style profile is the platform's answer to "who is this customer, how much do we trust that answer, and what customer context may we safely use right now?" It makes **personal** recommendations trustworthy by:

- separating canonical identity from profile summaries
- exposing explicit confidence and activation modes
- preserving source mappings, freshness, provenance, and suppressions
- giving ecommerce, email, and clienteling one shared customer contract
- degrading gracefully when certainty, freshness, or consent are weak

The remaining major uncertainties are tracked explicitly in `docs/features/open-decisions.md` (`DEC-030` through `DEC-033`) rather than being hidden inside the feature text.
