# BR-003: Multi-surface delivery

## Traceability

- **Board item:** BR-003
- **GitHub issue:** #110
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #110 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/product-overview.md`, `docs/project/roadmap.md`
- **Related inputs:** `docs/project/goals.md`, surface versus channel standards, API-first delivery expectations
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 1 - Foundation and first recommendation loop

## 1. Requirement summary

SuitSupply needs one recommendation delivery model that serves multiple consuming surfaces without redefining recommendation logic for each channel. The platform must support ecommerce, email, clienteling, and future API consumers through a shared recommendation contract, shared telemetry model, and clear rollout sequence.

This business requirement defines which channels and surfaces must be supported, what each consumer needs from the shared platform, which expectations must remain common across consumers, and how rollout should progress from the initial ecommerce validation loop to broader activation.

## 2. Problem and opportunity

Recommendation value will be limited if every consumer must build its own version of look composition, ranking semantics, eligibility rules, and measurement logic. That would fragment business control, reduce consistency, and slow later channel expansion. The platform instead needs a reusable delivery layer that:

- gives ecommerce teams production-ready recommendation responses for high-signal customer journeys
- gives email and CRM teams reusable recommendation content that fits campaign and lifecycle workflows
- gives clienteling teams recommendation outputs that are credible in assisted-selling conversations
- gives future API consumers a stable contract that can power additional experiences without reworking the core business logic

The opportunity is to make recommendations a shared product capability rather than a series of disconnected widgets or campaign integrations.

## 3. Business outcomes

The multi-surface delivery requirement must support these business outcomes:

1. **Reuse recommendation intelligence across channels** so SuitSupply does not rebuild logic separately for ecommerce, email, clienteling, and later consumers.
2. **Preserve consistency of brand and business logic** so recommendation sets remain coherent even when rendered in different surfaces.
3. **Increase channel reach over time** by turning the recommendation engine into a shared delivery capability rather than a one-surface feature.
4. **Improve measurement and governance** by keeping recommendation IDs, trace context, and telemetry semantics aligned across consumers.
5. **Lower downstream delivery risk** by making rollout sequence, contract expectations, and fallback behavior explicit before multi-channel expansion.

## 4. Channels, surfaces, and target users

### 4.1 Ecommerce channel

This is the first rollout channel because it has the fastest commercial feedback loop and the clearest recommendation interaction telemetry.

#### Primary surfaces

- product detail page (PDP)
- cart
- later homepage and web personalization surfaces
- later style inspiration or look-builder experiences

#### Primary users

- anchor-product shoppers who want to complete an outfit quickly
- returning customers whose recommendations should improve across repeat visits
- occasion-led shoppers who will expand beyond the first phase

### 4.2 Email channel

This channel needs reusable recommendation outputs that can be inserted into campaign and lifecycle workflows without changing core recommendation meaning.

#### Primary surfaces

- lifecycle email modules
- campaign email content blocks
- triggered follow-up experiences tied to browse, cart, or purchase context

#### Primary users

- CRM and marketing managers
- customers receiving personalized or context-aware follow-up messages

### 4.3 Clienteling channel

This channel needs recommendation outputs that support assisted selling and stylist confidence rather than only self-serve digital browsing.

#### Primary surfaces

- in-store clienteling interfaces
- stylist-assisted appointment or follow-up tools
- future assisted-selling surfaces with customer profile context

#### Primary users

- in-store stylists
- clienteling associates
- customers receiving guided outfit advice

### 4.4 Future API consumers

The shared contract must leave room for future consumers beyond the initial channels.

#### Expected future consumers

- mobile app experiences
- partner or affiliate experiences where allowed
- internal admin or analytics consumers
- additional web surfaces not yet prioritized

#### Primary users

- downstream product teams
- internal platform integrators
- future channel owners who should not need channel-specific business logic forks

## 5. Surface-specific business needs

### 5.1 Ecommerce needs

Ecommerce consumers must receive recommendation outputs that:

1. respond quickly enough for PDP and cart usage
2. support outfit, cross-sell, and upsell recommendation types in the same response family
3. remain purchasable and inventory-aware at decision time
4. degrade gracefully when some personalization or enrichment inputs are missing
5. produce measurable impression, click, add-to-cart, and purchase telemetry

### 5.2 Email needs

Email consumers must receive recommendation outputs that:

1. can be requested ahead of send time or assembled for campaign workflows without redefining recommendation semantics
2. support customer, campaign, locale, and timing context where available
3. remain traceable to a recommendation set, experiment, and decision source
4. distinguish between reusable look content and presentation-specific email formatting
5. allow no-recommendation and fallback cases without ambiguous failures

### 5.3 Clienteling needs

Clienteling consumers must receive recommendation outputs that:

1. support stylist trust with coherent looks and explainable provenance
2. account for known customer context, prior purchases, and assisted-selling workflows where permitted
3. preserve merchandising and compatibility rules rather than allowing ad hoc unsupported combinations
4. support slower, guided interaction patterns than ecommerce while still keeping the core business contract consistent
5. leave room for deeper RTW and later CM guidance in assisted workflows

### 5.4 Future API consumer needs

Future consumers must be able to rely on a shared contract that:

1. is consumer-agnostic at the core API layer
2. uses explicit versioning for externally consumed changes
3. separates recommendation data from rendering assumptions
4. keeps recommendation type, source context, and trace metadata stable
5. allows new adapters and extensions without fragmenting the core recommendation model

## 6. Shared delivery expectations across all consumers

All channels and surfaces must share these expectations:

### 6.1 Shared business contract

- Recommendation delivery is API-first.
- The core contract must identify the consuming surface or channel context without embedding presentation-specific UI logic into the response.
- The response must preserve recommendation set ID, recommendation type, ordered items or looks, and trace context for internal analysis where appropriate.
- Recommendation semantics must remain consistent whether the consumer is ecommerce, email, clienteling, or a future API client.

### 6.2 Shared governance expectations

- Merchandising rules, curated looks, and compatibility constraints must apply consistently across consumers.
- Channel expansion must not bypass override, audit, or campaign-governance expectations.
- Hard compatibility constraints must take precedence over channel-specific optimization pressure.

### 6.3 Shared measurement expectations

- Consumers must emit or preserve recommendation telemetry using the shared recommendation set ID and trace context.
- Outcome tracking should align around impression, click, save, add-to-cart, purchase, dismiss, and override semantics where the surface supports them.
- Surface-specific metrics may vary, but measurement definitions must stay comparable across channels.

### 6.4 Shared data and identity expectations

- Requests and responses must use stable canonical IDs for products, customers, looks, campaigns, and experiments.
- Cross-channel identity handling must respect confidence, consent, and regional data policy boundaries.
- Missing enrichment inputs should reduce recommendation richness, not silently corrupt contract meaning.

### 6.5 Shared reliability expectations

- Every consumer must have explicit timeout, fallback, and no-recommendation behavior.
- Degraded upstream dependencies should not create ambiguous consumer behavior.
- Contract changes must be versioned or explicitly coordinated for downstream consumers.

## 7. Rollout sequence and phase boundaries

### 7.1 Phase 1: foundation and first ecommerce loop

Phase 1 must prioritize ecommerce surfaces that validate business value quickly:

- **Primary channel:** ecommerce
- **Primary surfaces:** PDP and cart
- **Primary goal:** prove that shared recommendation delivery can support high-signal digital surfaces with measurable outcomes
- **Why first:** these surfaces offer the strongest validation loop for recommendation usefulness, category attachment, conversion, and telemetry completeness

Phase 1 must include:

- a shared recommendation API with surface-aware request context
- contract support for outfit, cross-sell, and upsell outputs
- telemetry support for the first ecommerce loop
- enough governance and fallback behavior to keep outputs safe and reviewable

Phase 1 must not depend on:

- immediate email activation
- immediate clienteling rollout
- full multi-channel identity maturity before the first ecommerce launch
- deep channel-specific adapters that fork the core logic

### 7.2 Phase 2: broader web personalization expansion

After the first ecommerce loop is stable, delivery expands within the ecommerce channel:

- homepage and web personalization surfaces
- stronger contextual and personal recommendation use
- more explicit support for returning-customer and occasion-led experiences

This phase builds on the same shared contract rather than introducing a new channel-specific recommendation model.

### 7.3 Phase 3: email and clienteling activation

Once contract stability, telemetry, and governance are proven, delivery expands to:

- email campaign and lifecycle consumers
- in-store clienteling and stylist-assisted consumers

This phase must confirm:

- stable API contracts and telemetry schemas
- clear internal workflow definitions for CRM and styling teams
- governance for overrides, campaigns, and auditability across non-ecommerce channels

### 7.4 Later phases: future consumer expansion

Later phases may extend the same delivery capability to:

- mobile and app consumers
- partner or affiliate consumers where appropriate
- deeper clienteling and CM-aware assisted workflows
- internal analytics or operational consumers that need recommendation traces

Future expansion must continue to use the shared core contract and shared governance expectations.

## 8. Functional business requirements

### 8.1 Shared-consumer delivery requirement

The platform must expose recommendation outputs through a shared, API-first delivery model that can serve ecommerce, email, clienteling, and future API consumers.

### 8.2 Surface-context requirement

The request contract must allow explicit consumer context such as surface, channel, locale, session, and customer identifiers where relevant to recommendation generation and interpretation.

### 8.3 Contract consistency requirement

The response contract must preserve consistent recommendation semantics across consumers, including recommendation set ID, recommendation type, ordered results, and internal trace metadata where appropriate.

### 8.4 Consumer-adapter requirement

Channel-specific delivery needs may be handled by adapters or extensions, but they must not fork the core recommendation model or redefine shared business rules.

### 8.5 Telemetry continuity requirement

Every production consumer must preserve enough recommendation context for consistent telemetry, attribution, experimentation, and auditability.

### 8.6 Governance continuity requirement

Merchandising controls, compatibility rules, and campaign priorities must apply consistently across surfaces and channels.

### 8.7 Rollout sequencing requirement

The platform must roll out multi-surface delivery incrementally, starting with high-signal ecommerce surfaces before broader email, clienteling, and future consumer expansion.

### 8.8 Future-consumer readiness requirement

The business requirement must leave clear contract and governance room for future API consumers without forcing the team to redesign the recommendation delivery layer later.

## 9. Success measures

### 9.1 Phase 1 delivery success measures

- PDP and cart consumers can request and render shared recommendation outputs without consumer-specific business logic forks
- recommendation telemetry for ecommerce surfaces is complete enough to attribute engagement and conversion outcomes
- recommendation quality remains coherent and purchasable across the initial surfaces
- downstream feature work can reference a stable contract and rollout boundary

### 9.2 Multi-channel readiness measures

- email and clienteling consumers can be onboarded through adapters or integrations rather than new recommendation engines
- shared contract fields are sufficient for multiple consumers without repeated schema redefinition
- recommendation set ID and trace context remain usable across channels for reporting and auditability

### 9.3 Business and operational measures

- expansion from ecommerce to email and clienteling does not require re-authoring the core recommendation semantics
- merchandising governance remains consistent across channels
- fallback and no-recommendation behavior is explicit and reliable per consumer
- contract changes are versioned and operationally manageable for downstream teams

## 10. Constraints and guardrails

- Surface-specific rendering should remain outside the core recommendation contract.
- No consumer should require a forked version of compatibility rules or recommendation-type definitions.
- Privacy, consent, and regional policy constraints must apply consistently across ecommerce, email, and clienteling consumers.
- Phase 1 must stay focused on ecommerce validation rather than broad channel activation.
- Future API readiness must not be interpreted as a requirement to launch every possible consumer in the first phase.

## 11. Assumptions

- Ecommerce PDP and cart are the best first surfaces for validating shared delivery expectations.
- Email and clienteling teams will need reusable recommendation outputs, but not in the first delivery loop.
- A shared recommendation API can remain consumer-agnostic enough to support future channels while still carrying explicit surface context.
- Adapter-level differences can satisfy channel rendering needs without fragmenting core business rules.

## 12. Open questions for downstream feature breakdown

- What freshness expectations should email consumers use for recommendation generation versus send-time rendering?
- Which clienteling workflows need real-time recommendation retrieval versus precomputed recommendation support?
- What minimum trace metadata must be exposed to internal consumers without overexposing implementation detail?
- Which future consumer types need first-class extensions versus standard adapters?
- How should no-recommendation fallback be presented differently by channel while preserving the same business semantics?

## 13. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for shared recommendation delivery API and contract behavior
2. feature scope for PDP and cart consumers in Phase 1
3. feature scope for recommendation telemetry continuity across consumers
4. feature scope for channel adapters or integration boundaries for email and clienteling
5. feature scope for contract versioning, fallback behavior, and future consumer extensibility

## 14. Exit criteria check

This BR is complete when downstream teams can see:

- the business needs for ecommerce, email, clienteling, and future API consumers
- the difference between channel-specific needs and shared delivery expectations
- the rollout order from initial ecommerce surfaces to later multi-channel activation
- the API-first and contract-consistency expectations that must remain common
- the governance, telemetry, and fallback requirements that make shared delivery operationally safe
