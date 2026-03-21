# Feature: Channel expansion - email and clienteling

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003, BR-006, BR-009, BR-011, BR-012); `docs/project/br/br-003-multi-surface-delivery.md`, `br-006-customer-signal-usage.md`, `br-009-merchandising-governance.md`, `br-011-explainability-and-auditability.md`, `br-012-identity-and-profile-foundation.md`; `docs/project/product-overview.md`; `docs/project/roadmap.md` (Phase 2 email, Phase 3 clienteling); `docs/project/data-standards.md`; `docs/project/standards.md`; `docs/features/open-decisions.md` (`DEC-008`, `DEC-010`, `DEC-011`, `DEC-016`).

---

## 1. Purpose

Extend the shared recommendation platform beyond ecommerce into **email** and **clienteling** so SuitSupply can reuse the same recommendation meaning, governance, identifiers, and telemetry across outbound and assisted-selling channels without creating separate channel-specific recommendation engines.

This feature exists to operationalize BR-003 for later-phase surfaces where:

- recommendations are not always consumed immediately
- freshness and consent constraints are stricter
- operator trust and explainability matter more
- cross-channel attribution becomes harder unless traceability is preserved deliberately

## 2. Core Concept

Email and clienteling are both **consumers** of the shared recommendation contract, but they consume it differently:

- **Email** is a delayed, packaging-oriented surface where recommendation outputs may be generated before exposure, so freshness, suppression, and campaign-safe orchestration are critical.
- **Clienteling** is an authenticated, operator-assisted surface where stylists or associates need recommendation outputs that are explainable enough to review, adapt, and share with confidence.

Both surfaces must preserve:

- explicit **recommendation type**
- **recommendation set ID**
- **trace ID**
- canonical product and customer identifiers
- governance context such as campaign, rule, and override influence

They must not redefine the core recommendation meaning just because the consuming surface differs from PDP or cart.

## 3. Why This Feature Exists

This feature unlocks two major parts of the product vision defined in `docs/project/vision.md` and `docs/project/product-overview.md`:

1. **Personalized email and lifecycle marketing activation**
   - lets marketing teams send recommendation content that reflects the same complete-look platform logic used elsewhere
   - supports repeat purchase, re-engagement, and occasion-based follow-up journeys

2. **In-store stylist and clienteling workflows**
   - lets associates retrieve coherent outfit and personal recommendation sets faster
   - improves consistency between digital and assisted-selling recommendation behavior

Without this feature, SuitSupply risks:

- channel-specific recommendation drift
- inconsistent profile and suppression handling between web, email, and store-assisted flows
- weak attribution across channels
- duplicated engineering work for each downstream consumer

## 4. User / Business Problems Solved

### Problems solved for customers

- **Returning customers (P2)** receive more coherent follow-up recommendations in email when identity confidence and consent allow.
- **Assisted-selling customers** get stylist-curated recommendations that still reflect governed platform logic instead of ad hoc product picks.
- Customers see fewer stale, duplicate, or ineligible recommendations across channels.

### Problems solved for internal users

- **Marketing managers (S3)** can activate recommendation content in campaigns with preserved traceability and measurable outcomes.
- **Stylists and clienteling associates (S1)** can start from a platform-generated outfit or personal set instead of building everything manually.
- **Merchandisers (S2)** can govern recommendation behavior consistently across ecommerce, email, and clienteling surfaces.
- **Analytics and product teams (S4)** can compare outcomes across web, email, and operator-assisted channels because IDs and event semantics remain shared.

### Business outcomes supported

- improved repeat engagement and follow-up conversion
- better attach rates from outbound and assisted-selling journeys
- reduced channel fragmentation
- stronger cross-channel merchandising and auditability

## 5. Scope

This feature covers the channel-specific delivery behavior needed for email and clienteling while keeping shared recommendation semantics intact.

### Included scope themes

- recommendation generation, packaging, and freshness validation for email
- authenticated recommendation retrieval and operator adaptation workflows for clienteling
- consent, suppression, and identity-confidence gating before personalized activation
- trace continuity from recommendation generation through exposure and outcome events
- operator-visible explanation depth appropriate for clienteling use
- governance parity with campaign, rule, and override controls already defined elsewhere

### Explicitly tracked open decisions

This feature depends on portfolio-level open decisions rather than inventing local unresolved placeholders:

- `DEC-003` - canonical delivery contract freeze for shared multi-surface consumers
- `DEC-008` - campaign vs personalization/context precedence across email and clienteling
- `DEC-010` - email freshness threshold and regeneration policy before send
- `DEC-011` - clienteling platform and operator explanation depth for first rollout
- `DEC-016` - inventory freshness windows and bounded fallback policy by surface

## 6. In Scope

### Email

- lifecycle and campaign-oriented recommendation content assembly
- send-time or pre-send recommendation generation workflows
- freshness validation before content is approved for send
- suppression-safe and consent-safe personalized recommendation packaging
- campaign linkage and attribution continuity
- recommendation-safe fallback behavior when profile, inventory, or freshness is weak

### Clienteling

- authenticated recommendation retrieval for stylist or associate workflows
- customer, appointment, or anchor-driven request contexts
- recommendation review and bounded adaptation by operators
- internal explanation summaries suitable for assisted selling
- share and follow-up flows that preserve recommendation provenance
- operator override and audit capture

### Shared channel concerns

- stable IDs and trace metadata
- consistent recommendation-type semantics
- governance-safe surface behavior
- telemetry continuity with recommendation events

## 7. Out of Scope

- full ESP replacement or migration strategy
- full CRM or clienteling platform replacement
- POS replacement
- final visual design for all campaign-builder or clienteling screens
- final legal-policy wording for market-specific privacy disclosures
- architecture-stage endpoint freezing, transport selection, or exact storage technology

The feature spec defines what these channels must do, not the final vendor or infrastructure decisions behind them.

## 8. Main User Personas

### Primary personas

- **Persona S3: Marketing manager**
  - needs recommendation outputs that can be packaged into lifecycle or campaign emails
  - needs traceability between sent content and downstream outcomes

- **Persona S1: In-store stylist or clienteling associate**
  - needs fast access to trustworthy outfit and personal recommendations
  - needs enough explanation to adapt recommendations confidently for a customer

- **Persona P2: Returning style-profile customer**
  - may receive personalized follow-up email recommendations
  - may appear in clienteling workflows where durable profile context improves assisted selling

### Secondary personas

- **Persona S2: Merchandiser** for campaign and governance consistency
- **Persona S4: Product / analytics / optimization** for cross-channel measurement and troubleshooting
- privacy, compliance, and governance stakeholders for consent-safe activation

## 9. Main User Journeys

### Journey 1: Personalized lifecycle email

1. A customer qualifies for a marketing journey such as back-in-stock, post-purchase follow-up, or seasonal wardrobe refresh.
2. The email system requests recommendation content using campaign, customer, and market context.
3. Identity and consent state are checked before any durable personalization is applied.
4. Recommendation sets are generated or refreshed with explicit freshness metadata.
5. Packaging logic validates that results remain send-safe.
6. The email is sent with recommendation set ID, trace ID, recommendation type, and campaign linkage preserved.
7. Open, click, and downstream purchase events carry enough metadata for attribution.

### Journey 2: Batch campaign email preview and approval

1. Marketing configures a campaign segment and recommendation module placement.
2. A preview job generates sample recommendation packages for representative customer states.
3. Operators review freshness state, product eligibility, and campaign-safe rendering.
4. If a package is stale or inventory-risky, regeneration or fallback logic runs before approval.
5. Approved content is sent during the allowed window with trace continuity preserved.

### Journey 3: Appointment-driven clienteling session

1. A stylist opens an appointment or customer profile in the clienteling application.
2. The application requests recommendation sets using customer, appointment, and possibly anchor-product context.
3. The platform returns typed outputs such as **outfit**, **cross-sell**, **upsell**, or **personal** recommendations with operator-safe explanation summaries.
4. The stylist reviews and optionally adapts the set within governed boundaries.
5. The stylist shares the recommendations through approved channels such as link, follow-up email, or saved look workflow.
6. Operator actions and downstream customer engagement are logged with shared IDs and override telemetry where applicable.

### Journey 4: In-session clienteling refresh

1. Customer preferences or appointment context change during a consultation.
2. The stylist manually refreshes recommendations.
3. The platform re-evaluates the context with current inventory and customer-state constraints.
4. Updated outputs are returned with a new recommendation set ID and linked trace lineage for audit.

## 10. Triggering Events / Inputs

### Email triggers

- scheduled campaign send windows
- lifecycle automation triggers
- post-purchase or browse-follow-up triggers
- manually requested campaign preview generation
- pre-send validation or regeneration jobs

### Clienteling triggers

- appointment open
- customer profile open
- stylist manual refresh
- anchor-product selection during a consultation
- share or follow-up flow initiation

### Shared input categories

- customer identity and confidence state
- consent and suppression state
- campaign or appointment context
- market and channel context
- anchor product, cart, or look context when relevant
- inventory freshness and product eligibility state
- merchandising campaign, rule, and override context

## 11. States / Lifecycle

### Email recommendation package lifecycle

`requested -> generated -> freshness_checked -> approved_for_send -> sent -> interacted -> attributed -> expired`

#### State meanings

- **requested** - campaign or lifecycle workflow requests recommendation content
- **generated** - recommendation package is assembled with IDs and metadata
- **freshness_checked** - package validated against email-specific freshness policy
- **approved_for_send** - content passed policy and operational checks
- **sent** - outbound message delivered to ESP for sending
- **interacted** - open, click, or downstream re-entry observed
- **attributed** - outcomes joined back to recommendation and campaign context
- **expired** - package no longer valid for resend or replay

### Clienteling recommendation lifecycle

`requested -> returned -> reviewed_by_associate -> optionally_adapted -> shared_or_saved -> outcome_recorded -> archived`

#### State meanings

- **requested** - clienteling app requests a recommendation set
- **returned** - recommendation set delivered to the operator
- **reviewed_by_associate** - stylist sees summary explanation and set composition
- **optionally_adapted** - operator applies bounded overrides or substitutions
- **shared_or_saved** - set is turned into a shareable or saved workflow artifact
- **outcome_recorded** - downstream customer action or operator completion logged
- **archived** - session context retained for audit and analytics

## 12. Business Rules

### Cross-channel rules

- Email and clienteling must preserve shared recommendation types rather than flattening all outputs into generic product lists.
- Recommendation delivery must preserve **recommendation set ID** and **trace ID** through packaging, rendering, and telemetry.
- Governance rules, suppressions, and campaign context must apply consistently unless an explicit surface-specific exception is later approved.

### Email-specific rules

- Personalized email recommendation content may only activate when channel permission, customer identity confidence, and permitted-use boundaries allow it.
- Stale or inventory-risky recommendation packages must not be sent silently; they must be regenerated, downgraded, or suppressed according to `DEC-010` and `DEC-016`.
- Email packages must preserve recommendation meaning at generation time even if final visual rendering differs by template.
- Unsubscribe, suppression, or profile-ineligible states override personalization, not just downstream tracking.
- Email must not expose sensitive internal reasoning or deep profile detail to the customer.

### Clienteling-specific rules

- Clienteling users must authenticate and operate under role-based permissions.
- Clienteling explanation must be richer than customer-facing explanation but still privacy-safe per BR-011.
- Associates may adapt recommendations only through visible, auditable workflows; hidden manual exceptions are not acceptable.
- Shared contract semantics must remain intact even when an associate reorders or substitutes items.
- Assisted-selling flows may use richer profile context than anonymous ecommerce only when confidence, provenance, and policy support it.

### Cross-feature precedence rule

Campaign and personalization conflict behavior for email and clienteling must follow the portfolio decision register and downstream governance work under `DEC-008`.

## 13. Configuration Model

### Email configuration

- campaign ID and campaign scope
- allowed recommendation types by template slot
- freshness threshold and regeneration policy
- send-window constraints by market
- fallback strategy by audience or campaign type
- suppression behavior when no safe personalized package is available

### Clienteling configuration

- associate or role permissions
- explanation-detail tier
- allowed adaptation actions
- appointment-context requirements
- allowed share channels and token lifetime

### Shared configuration

- channel and surface constants
- telemetry enablement and event routing
- recommendation-module ordering rules
- market-specific policy toggles
- audit and retention settings

## 14. Data Model

### Core entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `RecommendationPackage` | email-safe recommendation bundle | `recommendationSetId`, `traceId`, `campaignId`, `customerIdOrAudienceKey`, `channel`, `surface`, `generatedAt`, `freshUntil`, `recommendationTypes[]`, `renderedItems[]`, `fallbackState`, `inventoryStateSummary` |
| `ClientelingSessionRecommendation` | recommendation set returned to an associate | `recommendationSetId`, `traceId`, `customerId`, `appointmentId?`, `associateId`, `surface`, `generatedAt`, `recommendationTypes[]`, `explanationSummary`, `adaptationAllowed`, `governanceContext[]` |
| `RecommendationShareArtifact` | operator-generated shareable recommendation object | `shareId`, `sourceRecommendationSetId`, `traceId`, `associateId`, `customerId`, `channel`, `createdAt`, `expiresAt`, `shareState` |
| `RecommendationAdaptation` | operator change record | `adaptationId`, `sourceRecommendationSetId`, `traceId`, `associateId`, `changeType`, `reasonCode`, `createdAt`, `scope`, `overrideContext` |

### Example email package shape

```json
{
  "recommendationSetId": "recset_01HXYZ",
  "traceId": "trace_01HXYZ",
  "campaignId": "cmp_spring_refresh",
  "channel": "email",
  "surface": "lifecycle_followup",
  "generatedAt": "2026-03-21T09:00:00Z",
  "freshUntil": "2026-03-21T13:00:00Z",
  "recommendationTypes": ["outfit", "cross-sell"],
  "renderedItems": [
    { "productId": "prod_suit_navy_001", "recommendationType": "outfit", "position": 1 },
    { "productId": "prod_shirt_white_014", "recommendationType": "outfit", "position": 2 }
  ],
  "fallbackState": "none"
}
```

### Example clienteling session shape

```json
{
  "recommendationSetId": "recset_01HABC",
  "traceId": "trace_01HABC",
  "customerId": "cust_123",
  "appointmentId": "appt_456",
  "associateId": "assoc_789",
  "surface": "clienteling_session",
  "recommendationTypes": ["outfit", "personal"],
  "explanationSummary": {
    "sourceMix": "governed_mixed_source",
    "profileConfidence": "high",
    "activeCampaignIds": ["cmp_wedding_season"]
  },
  "adaptationAllowed": true
}
```

## 15. Read Model / Projection Needs

### Email read models

- audience-ready customer eligibility projection
- campaign preview projection with representative customer examples
- recommendation package freshness status by campaign or send batch
- inventory-safe email product projection

### Clienteling read models

- low-latency customer context slice for stylist requests
- appointment-context projection
- recent recommendation history by customer and associate
- operator adaptation history and audit view

### Shared projection needs

- campaign-to-recommendation linkage
- recommendation exposure and outcome linkage across channels
- suppression and identity-confidence summaries safe for delivery-time decisions

## 16. APIs / Contracts

This feature depends on the shared delivery contract and should not invent a separate email-only or clienteling-only taxonomy.

### Email-facing contract expectations

- batch generation or async packaging request
- preview request for sample customer states
- freshness validation response
- explicit degraded or suppressed package states

#### Example operations

- `POST /recommendation-packages:generate`
- `POST /recommendation-packages:preview`
- `POST /recommendation-packages/{id}:validate-freshness`

### Clienteling-facing contract expectations

- authenticated recommendation retrieval
- request support for customer, appointment, and anchor-product context
- operator-safe explanation summary in responses
- adaptation and share actions tied back to source recommendation IDs

#### Example operations

- `GET /clienteling/customers/{id}/recommendations`
- `POST /clienteling/recommendations/{recommendationSetId}/adaptations`
- `POST /clienteling/recommendations/{recommendationSetId}/share`

### Required contract semantics

- `channel`
- `surface`
- `recommendationType`
- `recommendationSetId`
- `traceId`
- canonical product IDs
- customer-state and fallback-state indicators
- campaign or appointment context where relevant

The normative endpoint and versioning model remain downstream architecture work under `DEC-003`.

## 17. Events / Async Flows

### Email async flows

1. Campaign or lifecycle trigger creates a packaging job.
2. Recommendation package is generated using current customer, campaign, and governance context.
3. Freshness validation checks inventory and send policy.
4. If stale or invalid, regeneration or fallback logic runs.
5. Approved package is handed to the ESP or outbound delivery orchestration.
6. Open, click, and downstream commerce events rejoin the recommendation trace.

### Clienteling async flows

1. Associate opens a customer or appointment.
2. Clienteling app requests recommendation content.
3. Recommendation service returns operator-safe output.
4. Associate adaptation or sharing actions create audit events.
5. Customer follow-up interactions or commerce outcomes join back to the originating recommendation set.

### Required event families

- `recommendation_package.generated`
- `recommendation_package.freshness_failed`
- `recommendation_package.regenerated`
- `recommendation_package.sent`
- `clienteling_recommendation.requested`
- `clienteling_recommendation.viewed`
- `clienteling_recommendation.adapted`
- `clienteling_recommendation.shared`

### Telemetry linkage

All channel events should preserve, where applicable:

- `recommendationSetId`
- `traceId`
- `campaignId`
- `recommendationType`
- `channel`
- `surface`
- `ruleContext`
- `experimentContext`

## 18. UI / UX Design

### Email UX expectations

- email modules should visually preserve whether content represents an **outfit**, **style bundle**, or another recommendation type
- recommendation content should feel curated and coherent rather than like a generic product dump
- recommendation blocks should degrade safely if valid personalized content is unavailable
- rendering should support market-safe copy and template variation without changing recommendation meaning

### Clienteling UX expectations

- clienteling UI should show grouped recommendation meaning clearly, especially for **outfit** outputs
- operators should see a concise explanation summary before drilling into detail
- adapted versus original recommendation state should be visually distinguishable
- governance indicators such as campaign influence, fallback state, or adaptation status should be visible to authorized users

### Usability principles

- fast understanding for stylists in-session
- safe preview and approval for marketing operators
- explicit empty, degraded, stale, and loading states
- role-appropriate explanation depth

## 19. Main Screens / Components

### Email-oriented components

- campaign recommendation preview panel
- recommendation package validation status view
- template slot mapping for recommendation modules
- send-readiness summary for package freshness and suppression outcomes

### Clienteling-oriented components

- customer recommendation panel
- appointment recommendation panel
- explanation summary drawer
- adaptation action sheet
- share workflow modal or link builder
- recent recommendation history panel

### Shared support components

- recommendation trace lookup by ID
- cross-channel attribution inspector
- fallback-state and freshness status badge components

## 20. Permissions / Security Rules

### Email permissions

- only authorized campaign or marketing workflows may request recommendation packages for outbound use
- recommendation package logs must minimize direct PII exposure
- channel permission and suppression state must be enforced before personalized package generation

### Clienteling permissions

- clienteling access requires authenticated associate identity
- role-based access must control who can view deeper explanation detail, customer profile context, and adaptation history
- share links or share artifacts must be scoped, time-bound, and revocable

### Security rules across both channels

- avoid exposing raw profile reasoning or sensitive event detail outside authorized operator views
- preserve auditability for operator actions
- protect customer identifiers and source mappings in logs and exports
- respect regional policy boundaries for cross-channel customer data usage

## 21. Notifications / Alerts / Side Effects

### Email alerts

- alert when recommendation packaging backlog exceeds acceptable send windows
- alert when freshness validation failures exceed threshold for a campaign
- alert when suppression or degraded fallback rates spike unexpectedly

### Clienteling alerts

- alert on repeated retrieval failures during active store or appointment hours
- alert on abnormal override or adaptation volume that may indicate trust issues or platform drift

### Side effects

- email clicks should re-enter traceable commerce journeys when possible
- clienteling shares should create auditable follow-up artifacts
- operator adaptations should generate override-style telemetry where applicable

## 22. Integrations / Dependencies

### Core dependencies

- shared recommendation delivery contract
- identity and style profile service
- customer signal ingestion
- merchandising governance and operator controls
- explainability and auditability capability
- analytics and experimentation
- catalog and product intelligence, especially inventory freshness

### External or surrounding integrations

- ESP or outbound campaign platform
- CRM or lifecycle orchestration tooling
- clienteling application or associate-facing surface
- commerce platform for downstream click and purchase attribution
- appointment or store context source

### Dependency sensitivity

- email depends more heavily on freshness-safe orchestration
- clienteling depends more heavily on explanation quality and auth boundaries

## 23. Edge Cases / Failure Cases

### Email edge cases

- recommendation package generated successfully but inventory changes before send
- customer consent changes between package generation and send
- campaign template supports fewer products than returned recommendation set size
- same customer appears in multiple campaign journeys with conflicting recommendation goals
- click occurs long after package generation, making exposure-time context different from generation-time context

### Clienteling edge cases

- associate opens a customer with low-confidence identity
- appointment context exists but profile or purchase history is stale
- operator is offline or on degraded connectivity during a session
- associate adapts a recommendation heavily enough that original trace lineage could be obscured
- multiple associates interact with the same customer context in a short period

### Shared failure handling expectations

- degraded states must be explicit
- fallback should prefer governed safe outputs over silence when appropriate
- traceability must survive regeneration, adaptation, and sharing flows

## 24. Non-Functional Requirements

### Email non-functional requirements

- support high-throughput batch generation and validation jobs
- preserve deterministic package status and retry handling
- handle send-window deadlines reliably
- maintain freshness and trace metadata through asynchronous orchestration

### Clienteling non-functional requirements

- low-latency retrieval suitable for in-session assisted selling
- dependable read performance during store hours
- resilient operation under moderate network instability
- fast explanation-summary rendering for operator trust

### Shared requirements

- auditability
- structured error handling
- version-safe contract evolution
- secure customer-data handling

## 25. Analytics / Auditability Requirements

### Email analytics

- track generation, send, open, click, and downstream commerce events with preserved recommendation IDs
- preserve campaign, surface, and recommendation-type context
- distinguish normal personalized sends from degraded or fallback sends

### Clienteling analytics

- track recommendation retrieval, view, adaptation, share, and downstream customer outcomes
- preserve associate, session, and appointment context where policy allows
- log operator adaptation as governed override-style activity when it changes default output

### Auditability expectations

- recommendation packages must be traceable back to generation-time context
- clienteling sessions must preserve who viewed, adapted, or shared recommendation outputs
- explanation and governance context must be reconstructable for both surfaces

## 26. Testing Requirements

### Email testing

- freshness validation tests
- suppression and consent enforcement tests
- package regeneration and retry tests
- template rendering tests for recommendation-type semantics
- attribution continuity tests from send to click and purchase

### Clienteling testing

- auth and permission tests
- low-latency retrieval tests
- operator adaptation audit tests
- share token expiry and revocation tests
- explanation-summary usability tests with stylist workflows

### Shared tests

- schema contract tests
- event payload validation
- degraded-state rendering tests
- recommendation ID continuity tests across flows

## 27. Recommended Architecture

### Email architecture direction

- recommendation packaging service layered on top of the shared recommendation contract
- asynchronous batch generation and validation pipeline
- freshness check stage between generation and send approval
- campaign-safe handoff into ESP or lifecycle orchestration

### Clienteling architecture direction

- authenticated clienteling consumer using the shared recommendation API
- low-latency retrieval path with bounded cached customer context
- separate operator-action service for adaptations and share artifacts
- explanation-summary and audit lookups backed by shared trace infrastructure

### Architectural principle

Keep recommendation decisioning shared and move surface-specific behavior into orchestration, packaging, and rendering layers rather than creating separate recommendation engines.

## 28. Recommended Technical Design

### Email technical design guidance

- store `generatedAt`, `freshUntil`, and validation status with each recommendation package
- use content hashes or package version IDs to detect stale or superseded packages
- propagate campaign ID and recommendation metadata into downstream telemetry
- preserve package-level fallback-state markers for reporting and suppression analysis

### Clienteling technical design guidance

- return concise explanation summaries in the primary response and deeper trace detail through follow-up views or endpoints
- preserve source recommendation IDs when an operator adapts or shares output
- use explicit adaptation records rather than mutating recommendation history in place
- support share artifacts with secure, expiring references instead of embedding unrestricted raw payloads

### Shared technical design guidance

- maintain stable canonical IDs and mapping fields
- keep event schemas aligned with `docs/project/data-standards.md`
- preserve additive contract evolution for later channel expansion

## 29. Suggested Implementation Phasing

### Phase 2

- email recommendation packaging and preview flows
- consent-safe personalized lifecycle activation
- campaign linkage and attribution continuity for email
- freshness validation foundation for non-interactive surfaces

### Phase 3

- clienteling recommendation retrieval and explanation summary
- operator adaptation and share workflows
- cross-channel reporting comparing ecommerce, email, and clienteling outcomes
- stronger operator-facing audit and troubleshooting support

### Later enhancements

- richer clienteling explanation depth once `DEC-011` resolves
- more advanced cross-channel suppression and fatigue policies
- deeper premium and CM-aware clienteling scenarios in alignment with later roadmap phases

## 30. Summary

Channel expansion to email and clienteling proves that the recommendation platform is a true multi-surface system rather than a web-only feature. The feature must preserve one shared recommendation meaning while adapting safely to:

- delayed exposure and freshness-sensitive packaging in **email**
- operator trust, explanation, and adaptation needs in **clienteling**

The main implementation risks are not recommendation semantics themselves, but the operational rules around:

- freshness and regeneration (`DEC-010`, `DEC-016`)
- campaign versus personalization precedence (`DEC-008`)
- operator explanation depth and rollout shape (`DEC-011`)

If those decisions are handled explicitly, email and clienteling become strong extensions of the same governed recommendation platform already defined for ecommerce and later cross-channel growth.
