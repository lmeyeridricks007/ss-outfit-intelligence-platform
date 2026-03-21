# Feature: Customer signal ingestion

**Upstream traceability:** `docs/project/business-requirements.md` (BR-006, BR-010, BR-012); `docs/project/br/br-006-customer-signal-usage.md`, `br-010-analytics-and-experimentation.md`, `br-012-identity-and-profile-foundation.md`; `docs/project/product-overview.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/roadmap.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`).

---

## 1. Purpose

Ingest, normalize, and govern **customer signals** so the platform can use orders, browsing, cart, search, email, loyalty, store, and stylist context safely for **contextual** and **personal** recommendations without turning every raw event into automatically trusted personalization truth.

This feature exists to make BR-006 operational. It is the shared ingestion and policy layer that ensures customer-signal use is:

- freshness-aware
- provenance-preserving
- consent-safe
- confidence-aware
- replayable and auditable
- optional rather than mandatory for recommendation delivery

The platform should still return coherent **outfit**, cross-sell, upsell, and governed fallback recommendation sets even when customer signals are missing, stale, low-confidence, or prohibited.

## 2. Core Concept

Customer signal ingestion is not just "collect events." The feature must convert heterogeneous source records into a **canonical signal envelope** that carries:

- a stable signal identifier
- source provenance
- freshness and decay metadata
- consent and permitted-use evaluation
- identity linkage state
- activation eligibility for downstream profile and ranking use

The critical distinction is:

1. **raw signal captured**
2. **raw signal normalized**
3. **signal evaluated for allowed use**
4. **signal made eligible for profile or recommendation activation**

That separation prevents unsafe behavior such as:

- using stale cart data as fresh intent
- treating weak identity matches as durable customer truth
- allowing unreviewed stylist notes to drive customer-facing ranking
- preserving analytics lineage without exposing raw sensitive content to every consumer

## 3. Why This Feature Exists

The product vision depends on recommendations that feel relevant across ecommerce, email, and clienteling, but BR-006 explicitly requires that personalization remain privacy-aware, explainable, and bounded. Without a dedicated signal-ingestion feature:

- each consuming surface would invent its own signal vocabulary
- source freshness would drift by team and channel
- consent enforcement would happen too late or inconsistently
- identity and profile features would over-trust weak source mappings
- analytics could not explain which signal families influenced outcomes

This feature therefore creates the governed customer-data plane that later Phase 2 and Phase 3 personalization work depends on.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| **P2 returning customer** | Recommendations ignore owned wardrobe, prior purchases, or recent intent | Durable and recent signals can inform complementarity, suppression, and personalization when allowed |
| **P1 anchor-product shopper** | Current-session intent is underused or treated too slowly | Near-real-time session signals feed bounded ecommerce intent handling |
| **P3 occasion-led shopper** | Search and browsing intent are lost between surfaces | Signal normalization preserves explicit short-term intent for downstream context and ranking |
| **S1 stylist / clienteling associate** | Store and stylist-entered context is unavailable or unsafe to trust | Reviewed, provenance-rich operator signals can inform assisted-selling flows |
| **S2 merchandiser / governance** | Personalization appears opaque and hard to constrain | Signal families, freshness, and eligibility rules become explicit and auditable |
| **S4 analytics / optimization** | Hard to explain why personalization helped or failed | Signal usage can be traced by family, freshness tier, and degraded-state path |
| **Privacy / legal / security stakeholders** | Customer data may be activated beyond what is permitted | Consent, residency, retention, and deletion controls are enforced before downstream activation |

Business outcomes supported:

- more relevant repeat-customer recommendations
- better duplicate suppression and wardrobe complementarity
- safer cross-channel activation
- measurable degraded-state behavior instead of hidden personalization failure

## 5. Scope

This feature covers the shared ingestion and normalization layer for customer-signal families defined in BR-006 and used by downstream identity, profile, analytics, explainability, and channel-delivery work.

### Core responsibilities

- capture signal records from web, commerce, CRM, loyalty, store, and operator systems
- normalize them into a shared canonical envelope
- preserve source-system IDs, timestamps, and provenance
- evaluate freshness, consent, permitted use, and identity-confidence dependencies
- deduplicate and classify signals for downstream use
- publish signal-derived projections for profile building, suppression, analytics, and debugging
- handle retention, deletion, revocation, and replay safely

### Explicitly tracked open decisions

This feature should rely on portfolio-level tracked decisions instead of feature-local untracked placeholders:

- `DEC-021` - signal-family consent matrix and permitted-use policy by region and surface
- `DEC-022` - numeric freshness windows and decay policy by signal family and consuming surface
- `DEC-023` - store / stylist signal governance depth, structured taxonomy, and reviewed free-text policy
- `DEC-024` - raw signal retention, PII minimization, replay strategy, and regional residency model

## 6. In Scope

### Signal families

- orders, returns, and exchanges
- browsing and navigation behavior
- product views
- add-to-cart and cart mutation events
- search queries and search interactions
- loyalty state and program events
- email send / open / click / unsubscribe events
- store visits, appointments, and assisted-selling interactions
- reviewed stylist notes and structured preference capture

### Pipeline and policy behavior

- source registration and schema expectations per family
- canonical IDs and source mappings
- freshness classification and decay metadata
- consent and permitted-use evaluation
- identity linkage handoff to downstream profile services
- dedupe, quarantine, replay, and reprocessing workflows
- deletion and revocation propagation

### Downstream-ready outputs

- session-intent projections
- durable customer-history summaries
- profile-builder inputs with lineage
- analytics-safe signal lineage and usage markers
- operator troubleshooting views

## 7. Out of Scope

- final ranking models or weighting formulas
- final identity-resolution algorithm
- full CRM or CDP roadmap
- final BI dashboard implementation
- final clienteling note-authoring UX
- free-form NLP enrichment of unstructured stylist notes for Phase 2 rollout
- freezing the final event bus, warehouse, or storage vendor choice

## 8. Main User Personas

| Persona | Why this feature matters |
| --- | --- |
| **P1 anchor-product shopper** | Needs session and cart signals to influence recommendations quickly and safely. |
| **P2 returning style-profile customer** | Needs durable purchase and preference signals to be remembered without privacy or identity mistakes. |
| **P3 occasion-led shopper** | Needs search, browse, and campaign-entry intent to remain visible to downstream personalization. |
| **S1 stylist / clienteling associate** | Needs store and stylist-entered context to be reviewable, attributable, and bounded for use. |
| **S2 merchandiser / governance operator** | Needs signal usage to remain auditable and subordinate to policy, curation, and overrides. |
| **S4 product / analytics stakeholder** | Needs signal lineage, degraded-state visibility, and experiment-safe telemetry. |

## 9. Main User Journeys

### Journey 1: Anonymous ecommerce session becomes session-aware

1. A shopper lands on a PDP anonymously.
2. Product views, browse actions, and cart mutations are ingested with a session ID.
3. Signals are normalized as **session-scoped** and evaluated for current-session use only.
4. PDP and cart recommendations can use the recent-intent projection if consent allows.
5. No durable profile activation occurs unless identity later becomes trustworthy.

### Journey 2: Known customer order enriches durable profile

1. Commerce emits a completed order and later a return-state update.
2. Order and return signals are ingested with canonical product IDs, timestamps, and source record IDs.
3. Identity linkage confirms a high-confidence canonical customer.
4. Durable ownership and category-affinity summaries update.
5. Downstream profile and suppression logic can avoid obvious duplicates and support follow-up recommendations.

### Journey 3: Stylist note enters the system safely

1. A stylist records a fit or preference note in a clienteling tool.
2. The note enters ingestion tagged as operator-entered and not yet activation-safe.
3. Review status and structured taxonomy determine whether the note remains analytics-only, clienteling-only, or customer-facing eligible.
4. If approved under policy, a bounded profile contribution becomes available with provenance and review metadata.

### Journey 4: Consent revocation invalidates activation

1. A customer opts out of a recommendation-related use or channel.
2. Consent-change ingestion updates the permitted-use evaluation for affected signal families.
3. Signal eligibility projections are recalculated.
4. Personal recommendation activation is blocked or downgraded.
5. Traces and analytics show the recommendation set as degraded or non-personalized rather than silently continuing prior behavior.

## 10. Triggering Events / Inputs

Customer signal ingestion is triggered by:

- browser and app telemetry events
- commerce webhooks for order, cart, and return activity
- email platform events such as send, open, click, and unsubscribe
- loyalty-program updates
- POS, appointment, or store-visit feeds
- clienteling-tool saves for stylist preferences or reviewed notes
- identity-resolution updates that link session and customer context
- consent, suppression, or privacy-policy changes
- data repair, replay, or backfill workflows
- deletion or data-subject requests

## 11. States / Lifecycle

### Canonical signal lifecycle

`received -> validated -> normalized -> consent-evaluated -> identity-linked or session-scoped -> eligible-for-activation or analytics-only or quarantined -> aggregated -> expired or deleted`

### State meanings

- **received** - source payload accepted or staged for processing
- **validated** - schema, required fields, enum values, and source registration checks passed
- **normalized** - canonical IDs, source metadata, timestamps, market context, and signal-family classification assigned
- **consent-evaluated** - permitted-use policy applied for region, channel, and signal family
- **identity-linked** - trusted canonical customer linkage available
- **session-scoped** - signal remains usable only as anonymous or current-session evidence
- **eligible-for-activation** - signal or derived projection may feed profile / recommendation use
- **analytics-only** - signal retained for reporting or audit but blocked from customer-specific activation
- **quarantined** - malformed, contradictory, or untrusted data isolated for inspection
- **aggregated** - signal has contributed to session, profile, or suppression projections
- **expired / deleted** - no longer valid for use because of decay, retention, or data-subject handling

### Derived projection lifecycle

`computed -> published -> stale -> recomputed or invalidated`

- **computed** - derived summary built from one or more normalized signals
- **published** - available to profile, ranking, or analytics consumers according to eligibility rules
- **stale** - freshness threshold passed or upstream source changed materially
- **recomputed / invalidated** - refreshed from current truth or revoked after consent / deletion / source corrections

## 12. Business Rules

- **No signal family is universally trusted.** Orders, session events, email engagement, store context, and stylist notes must retain distinct trust and freshness semantics.
- **Unknown freshness must not drive personalized ranking.** Signals with missing or unusable timing can remain analytics-visible but cannot act as trusted activation inputs.
- **Permitted use is checked before activation.** Consent, regional policy, and channel restrictions outrank personalization goals.
- **Low-confidence identity blocks durable activation.** Weakly linked customer records cannot use order history, loyalty state, or stylist context as if the mapping were certain.
- **Session-safe is not profile-safe.** Anonymous or short-lived session signals may support active ecommerce context without becoming durable cross-channel profile truth.
- **Returns and cancellations modify order-derived truth.** Purchase signals are not immutable positive evidence if subsequent order state contradicts them.
- **Store and stylist signals require stronger governance.** Operator-entered data must preserve author, review, and taxonomy metadata before activation.
- **Fresher explicit intent outranks older inferred preference.** Recent browse, search, and cart behavior should normally outrank old durable affinity when the customer is actively shopping.
- **Analytics and activation can differ.** A signal may remain reportable after it is no longer eligible for live personalization.
- **Deletion and revocation propagate downstream.** If a signal becomes ineligible, derived profile or suppression projections must be recalculated or invalidated.
- **Recommendation delivery must degrade safely.** Missing or blocked signals reduce personalization depth rather than causing hard failure.

## 13. Configuration Model

The feature requires a configuration model that can express:

- source-system registry and source ownership
- signal-family classification rules
- per-family required fields and schema versions
- freshness windows and decay tiers by surface and use case (`DEC-022`)
- consent and permitted-use mappings by region and channel (`DEC-021`)
- identity-linkage gating rules for durable vs session-only use
- retention schedules and deletion handling by data class (`DEC-024`)
- note-review and structured-taxonomy policy for store and stylist signals (`DEC-023`)
- quarantine thresholds and replay permissions
- observability thresholds for lag, duplicate rate, and schema failures

Configurations must be versioned so downstream traces and audits can explain:

- which policy set was active
- which signal families were allowed
- why a signal was activation-eligible, analytics-only, or blocked

## 14. Data Model

### Core entities

| Entity | Purpose | Required core fields |
| --- | --- | --- |
| `CustomerSignalEnvelope` | Canonical normalized signal record | `signalId`, `signalFamily`, `signalType`, `eventTs`, `ingestedAt`, `sourceSystem`, `sourceRecordId`, `market`, `channel`, `customerIdOrSessionId`, `identityConfidence`, `consentState`, `permittedUseState`, `freshnessTier`, `payloadRef`, `schemaVersion` |
| `SignalEligibility` | Activation outcome for a signal or derived summary | `signalId`, `eligibilityState`, `allowedSurfaces`, `allowedChannels`, `reasonCodes`, `evaluatedAt`, `policyVersion` |
| `SignalLineage` | Provenance and transformation history | `signalId`, `sourceSystem`, `sourceRecordId`, `transformationSteps`, `owner`, `reviewState`, `reviewedBy`, `reviewedAt` |
| `SignalProjection` | Derived projection for downstream consumers | `projectionId`, `projectionType`, `customerIdOrSessionId`, `inputSignalIds`, `freshnessExpiresAt`, `publishedAt`, `useScope` |
| `SignalDeletionOrRevocation` | Privacy-driven invalidation tracking | `requestId`, `targetSignalIds`, `reason`, `requestedAt`, `processedAt`, `downstreamStatus` |

### Example canonical envelope

```json
{
  "signalId": "sig_01JQ0Y0Q0MXJQ62P1E0YV9K8A1",
  "signalFamily": "product_view",
  "signalType": "pdp_view",
  "eventTs": "2026-03-21T11:42:12Z",
  "ingestedAt": "2026-03-21T11:42:14Z",
  "sourceSystem": "web-storefront",
  "sourceRecordId": "evt_993184773",
  "market": "nl",
  "channel": "web",
  "surface": "pdp",
  "customerIdOrSessionId": "sess_82c9b2",
  "identityConfidence": "anonymous",
  "consentState": "session_allowed",
  "permittedUseState": "session_only",
  "freshnessTier": "immediate",
  "payloadRef": {
    "anchorProductId": "prod_12345",
    "category": "suit",
    "locale": "en-NL"
  },
  "schemaVersion": "1.0"
}
```

### Data-model notes

- payload details may differ by family, but the canonical envelope semantics must remain stable
- `identityConfidence` and `permittedUseState` are required for downstream safety
- reviewed operator signals must preserve review metadata separately from raw text or attachments
- canonical product and customer IDs should coexist with source-system mappings rather than replacing them

## 15. Read Model / Projection Needs

The feature must publish downstream-friendly read models, not just raw records.

Required projections include:

- **session-intent window** - recent browse, product-view, search, and cart summaries by session
- **durable customer-history summary** - owned categories, recent orders, return-adjusted ownership, loyalty context
- **email-engagement summary** - recent engagement windows and channel suppression state
- **store / appointment context summary** - appointment recency, location, and approved associate context
- **stylist-preference summary** - structured, reviewed preference signals only
- **signal-usage timeline** - operator-facing view of which signals were available and eligible at a point in time
- **data-quality / quarantine dashboard** - lag, duplicate rate, missing fields, review backlog, revocation backlog

These projections should support profile, analytics, and explainability consumers without requiring each consumer to scan raw event history directly.

## 16. APIs / Contracts

This feature depends on semantic contracts more than one mandated transport.

### Required contract surfaces

- **signal ingestion contract** for streaming or request-based producers
- **batch import contract** for legacy or scheduled source drops
- **signal eligibility contract** exposing whether a family or projection is activation-safe
- **signal projection contract** for profile, recommendation, and debug consumers
- **deletion / revocation contract** to invalidate downstream projections safely

### Example implementation-facing interfaces

- `POST /signals/events`
- `POST /signals/batches`
- `GET /signals/projections/{customerIdOrSessionId}?scope=recommendation`
- `POST /signals/replay`
- `POST /signals/deletions`

### Contract requirements

- idempotency keys or equivalent dedupe semantics
- schema versioning
- source ownership and authentication
- traceable response codes for accepted, quarantined, rejected, or replayed records
- policy and eligibility reasons visible to internal consumers

## 17. Events / Async Flows

### Flow A: Web product-view ingestion

1. Storefront emits product-view event with session ID and PDP context.
2. Validation confirms source registration and schema compatibility.
3. Normalization assigns canonical product ID, market, and freshness tier.
4. Consent evaluation marks the signal as `session_only`.
5. Session-intent projection updates for ecommerce recommendation use.
6. Analytics lineage records the signal family and policy version.

### Flow B: Order and return reconciliation

1. Commerce emits order-completed event.
2. OMS later emits return or exchange update for one or more line items.
3. Ingestion normalizes both records under the same order lineage.
4. Durable projections update ownership and complementarity context.
5. If the order is fully reversed, derived ownership signals are invalidated or downgraded.

### Flow C: Reviewed stylist signal publication

1. Clienteling system stores a stylist note or structured preference.
2. Signal enters ingestion as operator-entered and activation-blocked by default.
3. Review process applies taxonomy and review state.
4. If approved, a bounded projection publishes to clienteling and possibly customer-facing profile use depending on policy.
5. Trace metadata preserves note source, review timing, and use scope.

### Flow D: Consent revocation

1. Consent-change event arrives from privacy / CRM systems.
2. Policy evaluation recomputes eligibility for affected signal families.
3. Profile and recommendation projections depending on those signals are invalidated.
4. Downstream consumers receive updated degraded-state or suppression context.
5. Audit trail preserves what changed and when.

## 18. UI / UX Design

This feature is primarily internal-facing. Customer-facing UX impact is indirect through safer personalization behavior and cleaner degraded states.

### Internal UX principles

- make signal-family differences visible rather than collapsing everything into "customer data"
- show freshness, consent, and identity-confidence state together
- clearly separate raw source records from activation-eligible projections
- allow operators to inspect why a signal is blocked, stale, or quarantined
- show data-subject revocation and replay status explicitly

### Customer-facing implications

- no raw signal details should be exposed to customers
- customer-facing surfaces may reflect degraded non-personalized behavior, but not sensitive reasoning
- if explanation surfaces exist later, they should reference broad categories such as "recent browsing" or "past purchases" only when policy allows

## 19. Main Screens / Components

- **source health dashboard** - ingestion lag, error rate, duplicate rate, schema version drift
- **signal timeline inspector** - customer or session-scoped timeline of normalized signal families and eligibility state
- **quarantine workbench** - malformed or contradictory record inspection and replay controls
- **consent / eligibility inspector** - reason-coded view of why a family is allowed, blocked, or session-only
- **stylist-signal review queue** - reviewed vs pending operator-entered signals
- **replay / backfill tool** - controlled reprocessing of corrected source data

## 20. Permissions / Security Rules

- raw signal access must be role-based and more restrictive than aggregate projection access
- sensitive payload content should be masked or tokenized where possible
- source-system secrets and authentication should remain isolated by producer
- only approved roles may inspect operator-entered note content
- privacy or legal roles may require access to deletion and revocation workflows without broad read access to all signal content
- encryption at rest and in transit is mandatory for raw and normalized records
- regional residency and retention behavior must align to `DEC-024`
- audit logs are required for access to sensitive signal detail, replay actions, and note-review changes

## 21. Notifications / Alerts / Side Effects

The feature must support alerts for:

- ingestion lag above policy threshold
- duplicate spikes suggesting retry storms or source bugs
- schema validation failure increases
- source outages or stale batch arrivals
- replay failure or growing quarantine backlog
- consent / deletion requests not processed within the required window
- review backlog for store or stylist signals that blocks downstream availability

Operational side effects include:

- profile-feature invalidation when signal eligibility changes
- analytics annotations when source quality materially degrades
- session or profile projection refresh after reprocessing
- downstream suppression changes after order, return, or revocation events

## 22. Integrations / Dependencies

- **commerce / OMS** - orders, returns, carts, and fulfillment state
- **web / app telemetry** - browse, PDP, search, and cart interactions
- **email / CRM / ESP** - engagement, suppression, and campaign context
- **loyalty platform** - membership and status updates
- **POS / appointment systems** - store visit and appointment context
- **clienteling tooling** - stylist-entered and reviewed preference context
- **identity and style profile** - canonical customer linkage and profile contribution
- **analytics and experimentation** - signal lineage, degraded-state measurement, attribution continuity
- **explainability and auditability** - trace reconstruction of which signal families were used
- **channel expansion: email and clienteling** - downstream consumers of governed signal projections

## 23. Edge Cases / Failure Cases

- **clock skew across producers** - event time and ingest time differ materially; normalization must preserve both
- **duplicate browser emissions** - re-renders or retries should not inflate signal counts
- **anonymous to known transition** - session signals may become linkable later, but only within policy and confidence rules
- **conflicting identity links** - order history and session state point to different customer candidates; durable activation must remain blocked
- **late-arriving returns** - order-derived ownership must be corrected after the fact
- **orphaned store events** - appointment or POS activity arrives without trustworthy customer linkage
- **unreviewed stylist free text** - remains blocked from customer-facing activation
- **consent revoked mid-session** - future recommendation requests must stop using blocked signal families immediately
- **source outage with replay later** - backfilled signals must not overwrite newer truth incorrectly
- **policy version changes** - prior traces must remain interpretable against the policy active at the time

## 24. Non-Functional Requirements

- support high-throughput ingestion without treating duplicates as normal truth
- preserve at-least-once delivery safety through idempotent processing
- maintain observability for every major source family
- support replay and backfill without losing provenance
- keep raw-to-projection latency low enough for immediate-session use where required
- retain stable canonical fields even as source payload shapes evolve
- make deletion, revocation, and retention handling operationally reliable
- keep policy evaluation deterministic and explainable

## 25. Analytics / Auditability Requirements

This feature must make it possible to answer:

- which signal families were available at recommendation time
- which were blocked, stale, low-confidence, or ineligible
- whether a recommendation set used session-only, bounded, or durable profile context
- what source record and policy version produced a downstream projection
- how a later replay or revocation changed the truth

Required analytics and audit outputs:

- signal-family usage markers linked to `recommendationSetId` and `traceId`
- freshness-tier and degraded-state dimensions in telemetry
- identity-confidence dimension when customer linkage affects eligibility
- audit records for reviewed operator signals
- visibility into blocked vs analytics-only vs activation-eligible volumes by family

## 26. Testing Requirements

- contract tests for each registered source family
- schema compatibility tests across version changes
- idempotency and dedupe tests
- consent and permitted-use enforcement tests
- identity-confidence gating tests
- revocation and deletion propagation tests
- replay / backfill correctness tests
- load tests for high-volume web and commerce sources
- note-review workflow tests for operator-entered signals
- traceability tests ensuring lineage survives into profile and analytics outputs

## 27. Recommended Architecture

Recommended logical flow:

`producers -> validation / schema registry -> normalization -> policy evaluation -> identity handoff -> projection builders -> raw + normalized storage -> downstream profile / analytics / explainability consumers`

Key architectural responsibilities:

- keep raw and normalized layers distinct
- apply policy and eligibility evaluation centrally, not separately in each consumer
- publish projections optimized for session use, durable profile use, and operator debugging
- preserve replayability and lineage so downstream consumers can trust derived summaries

The exact serving stack, storage engine, or transport does not need to be frozen at the feature stage, but the logical separation of raw capture, policy evaluation, and downstream publication is required.

## 28. Recommended Technical Design

- use a canonical envelope with stable IDs and schema versioning
- attach idempotency keys or equivalent dedupe metadata at ingress
- preserve both source and canonical identifiers
- keep `eligibilityState`, `identityConfidence`, and `freshnessTier` as first-class fields
- version policy evaluation outputs so traces can explain historical decisions
- store reviewed operator metadata separately from raw note content where possible
- publish projection snapshots with referenced input signal IDs for reproducibility
- isolate quarantine and replay paths so bad data does not silently pollute downstream projections

## 29. Suggested Implementation Phasing

- **Phase 1 prerequisite foundation:** make sure shared IDs, telemetry compatibility, and source registration patterns exist, but do not expand broad cross-channel personal activation yet
- **Phase 2 core rollout:** web / commerce / email / loyalty signal ingestion, session-intent projections, durable order-based summaries, consent-safe eligibility handling, and identity-confidence gating for ecommerce and email personalization
- **Phase 3 operator scale:** store, appointment, and reviewed stylist-signal workflows; richer debugging, replay, and governance tooling; stronger clienteling-specific projections
- **Later maturity:** deeper structured preference models, richer cross-channel suppression logic, and more advanced decay or relevance modeling once `DEC-021` through `DEC-024` are resolved

Phase alignment should remain consistent with `docs/project/roadmap.md`: this feature is foundational for Phase 2 personalization expansion and continues to mature in Phase 3 when operator and clienteling workflows scale up.

## 30. Summary

Customer signal ingestion is the governed intake and policy layer behind BR-006. Its job is not merely to collect events, but to turn heterogeneous customer evidence into trusted, bounded, and explainable downstream signal projections.

The implementation bar for this feature is:

- stable canonical signal envelopes
- explicit freshness and decay handling
- pre-activation consent and policy evaluation
- identity-confidence-aware durable use
- replayable provenance and deletion handling
- clear degraded-state behavior when safe personalization is not available

If done well, this feature gives downstream identity, profile, analytics, explainability, email, and clienteling work a shared customer-signal foundation they can reuse without inventing unsafe local rules. The remaining unresolved portfolio questions are already tracked in `DEC-021` through `DEC-024`, which should be resolved before later stages claim final regional policy, freshness windows, note-governance depth, or retention architecture.
