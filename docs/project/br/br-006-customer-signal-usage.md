# Business requirements: BR-006 Customer signal usage

## Metadata

- **BR ID:** BR-006
- **Issue:** #80
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent item:** none
- **Source artifacts:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/architecture-overview.md`, `docs/project/roadmap.md`
- **Related standards:** `docs/project/data-standards.md`, `docs/project/standards.md`
- **Promotes to:** FEAT-006

## Problem statement

The platform needs to use customer signals to improve complete-look and context-aware recommendations without creating unsafe, opaque, or non-compliant personalization behavior. Today, the canonical project documents state that orders, browsing, product views, add-to-cart, search, loyalty, email engagement, store signals, and permitted profile inputs should influence recommendation quality, but they do not yet define the business boundaries for which signals are allowed, how fresh each signal class must be, or what traceability is required to explain why a recommendation set was produced.

Without a clear business requirement, downstream work could either underuse valuable customer context and produce generic outfit recommendations, or overuse sensitive or stale inputs in ways that undermine trust, brand safety, and regional policy compliance. The business requirement must therefore specify the permitted customer signals, the conditions under which those signals may shape recommendation outcomes, the freshness and provenance expectations required for reliable use, and the guardrails that keep personalization useful without exposing sensitive reasoning on customer-facing surfaces.

## Target users

### Primary personas
- Occasion-led online shoppers who need outfit, cross-sell, and upsell suggestions that match current intent without forcing them to build a look from scratch.
- Style-aware returning customers who expect recommendations to reflect prior purchases, browsing behavior, and repeat preferences across visits and channels.
- Custom Made customers whose recommendations should respect configuration state, appointment context, and premium styling sensitivity.

### Secondary personas
- In-store stylists and clienteling associates who need recommendation outputs informed by store and customer context, but still governed by policy and merchandising rules.
- Merchandisers and look curators who need confidence that personalization uses approved signals and does not bypass curated looks, compatibility rules, or campaign priorities.
- Marketing and CRM managers who need reusable recommendation outputs that can safely incorporate email engagement and customer history.
- Product, analytics, and optimization leads who need traceable signal usage, freshness visibility, and outcome telemetry for audit and experimentation.

## Business value

This requirement should create value by:
- improving relevance for personal, contextual, outfit, cross-sell, and upsell recommendations across PDP, cart, homepage, email, and clienteling surfaces
- increasing conversion, attachment rate, and average order value by using customer history and in-session behavior to surface more compatible products and looks
- improving repeat engagement and customer lifetime value by making recommendations feel progressively smarter for returning customers
- preserving customer trust by ensuring personalization uses only permitted inputs and avoids exposing sensitive profile reasoning
- reducing operational risk by requiring clear provenance, recency, and traceability for every signal class used in recommendation decisions
- giving merchandising, analytics, and governance teams auditable evidence of which inputs affected recommendation sets

## Recommendation and channel mapping

### Recommendation types in scope
- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- contextual recommendations
- personal recommendations
- style bundles when customer history or engagement should influence bundle ranking

### Consuming surfaces in scope
- PDP
- cart
- homepage and web personalization surfaces
- style inspiration and look-builder pages
- email activation
- in-store clienteling interfaces

### Recommendation sources affected
- curated looks
- rule-based compatibility logic
- AI-ranked recommendation outputs

Customer signals may shape ranking, filtering, prioritization, fallback ordering, and eligibility decisions, but they must not override hard compatibility, inventory, consent, or merchandising safety rules.

## Scope boundaries

### In scope
- Defining the permitted signal classes that may be used for recommendation generation and ranking when allowed by region, consent state, and company policy.
- Defining how order history, browsing, product views, add-to-cart, search, loyalty, email engagement, store signals, and permitted profile inputs may influence recommendation decisions.
- Defining which profile-derived inputs are permitted, including stable preference indicators, size or fit preferences, loyalty tier, preferred categories, saved looks, wishlists, and derived affinities where sourced from permitted upstream data.
- Defining signal usage boundaries for anonymous sessions versus known customers with resolved identity.
- Defining freshness expectations for each signal class so downstream implementations can decide when signals are actionable, stale, or only suitable for batch-oriented use.
- Defining traceability requirements so each recommendation set can be audited back to signal classes, source provenance, identity confidence, and applicable rules or experiments.
- Defining safety and governance requirements that prevent personalization from using prohibited or weakly governed data in customer-facing recommendations.
- Defining phase guidance for when broader personalization should expand beyond foundational surfaces.

### Out of scope
- Detailed technical architecture for ingestion pipelines, APIs, storage models, or feature engineering.
- Final legal or policy interpretation for sensitive internal signals; this BR can require explicit validation but does not replace policy review.
- UI copy, explanation treatments, or channel-specific rendering specifications.
- Full identity-resolution design or deterministic matching rules.
- Model-specific ranking algorithms, feature weights, or experimentation design.

## Permitted customer signals

The platform may use the following signal classes for recommendation use cases when permitted by region, consent state, source policy, and activation context.

### 1. Order history
- Completed purchases, returned items, and owned-category history may inform personal recommendations, replenishment-adjacent styling, and suppression of irrelevant repeats.
- Order history should be treated as a high-confidence long-lived signal for preference and wardrobe context, subject to recency weighting and return-aware interpretation.
- Recent purchase events may also support near-term outfit completion suggestions when compatible with the current journey.

### 2. Browsing behavior
- Browsing sessions, category navigation, dwell behavior, and page sequence may inform current intent and context-aware ranking.
- Anonymous browsing may be used at session level even when identity is unresolved, provided traceability remains session-scoped.

### 3. Product views
- Product detail views may influence anchor-product affinity, category interest, color or style preference inference, and follow-on outfit recommendations.
- Repeated product views in the current session should be treated as a strong short-term intent signal.

### 4. Add-to-cart events
- Add-to-cart events may influence cross-sell, upsell, and outfit completion logic.
- Current-cart activity is one of the highest-priority short-term signals because it reflects active purchase intent and current compatibility needs.

### 5. Search behavior
- Search queries, refinements, and zero-result recovery behavior may inform inferred occasion, formality, category, color, fit, or use-case intent.
- Search signals may be used to bias candidate selection or ranking, but should not be treated as stable long-term preference without supporting evidence.

### 6. Loyalty and account behavior
- Loyalty tier, loyalty engagement, account activity, saved looks, favorites, and wishlists may inform personalization and premium treatment where permitted.
- Loyalty-derived signals may support differentiation for returning customers, but must not create unfair or non-transparent exclusion from core recommendation quality.

### 7. Email engagement
- Email opens, clicks, and downstream visit behavior may inform campaign-aware follow-up recommendations and recency of known interests.
- Email engagement may support activation and ranking, but should carry lower confidence than on-site purchase or cart behavior unless reinforced by other signals.

### 8. Store signals
- Store visits, appointments, clienteling interactions, and inventory-aware store context may inform recommendation relevance for in-store and cross-channel journeys.
- Stylist notes are sensitive internal signals and may only be used after explicit policy validation confirms they are permitted for recommendation use cases in the target region and channel.

### 9. Permitted profile inputs
- Stable profile inputs may include preferred categories, preferred fits, size or tailoring preferences, region, country, loyalty tier, prior occasion patterns, and saved style affinities when sourced from permitted data.
- Profile inputs must retain source provenance, recency, and identity-confidence context.
- Sensitive inferred traits that are unrelated to outfit relevance or not explicitly permitted are out of scope for recommendation use.

## Prohibited or restricted signal usage

- The platform must not use customer data that is not permitted by region, consent state, or company policy.
- The platform must not expose raw sensitive inputs or sensitive profile reasoning on customer-facing surfaces.
- Sensitive internal notes, including stylist notes, must remain restricted until explicit policy approval is recorded for the intended recommendation use case.
- Low-confidence identity joins must not silently cause one person’s history to influence another person’s recommendation set.
- Stale signals must not be treated as if they reflect current intent when fresher session or cart signals contradict them.
- Customer signal usage must not bypass hard compatibility constraints, inventory eligibility, campaign exclusions, or merchandising safety rules.

## Freshness and recency requirements

The platform must preserve signal recency by class and use it explicitly in recommendation decisions.

### Short-horizon signals
These signals should support same-session or near-real-time recommendation decisions because they reflect active intent:
- current browsing session activity
- recent product views
- add-to-cart events
- search behavior
- current store-session context where available

These signals should be considered stale for active-intent ranking once the session context meaningfully changes, the customer becomes inactive for an extended period, or fresher contradictory behavior is observed.

### Medium-horizon signals
These signals may support recent-interest personalization over days to weeks, with explicit recency weighting:
- recent browsing history across sessions
- recent email engagement
- recent loyalty interactions
- recent appointments or store visit history when permitted

### Long-horizon signals
These signals may inform enduring preference and wardrobe context, but should still carry provenance and recency metadata:
- order history
- returns history
- saved looks or wishlists
- stable profile preferences
- long-term category or fit affinities

### Freshness business requirements
- Every signal class used in recommendation decisions must include a recency timestamp or freshness indicator.
- Recommendation logic must be able to distinguish current-intent signals from long-term preference signals.
- Implementations must degrade gracefully when a signal is missing, stale, or unavailable rather than fabricating confidence.
- Operational reporting must make freshness lag visible for recommendation-critical signal classes.
- Phase 1 should prioritize short-horizon session and commerce signals on PDP and cart; broader cross-channel personalization should expand in Phase 2 once identity, consent handling, and freshness visibility are reliable.

## Traceability and auditability requirements

Every recommendation set influenced by customer signals must be traceable enough for operational review, experimentation, and policy audit.

### Required traceability elements
- recommendation set ID
- trace ID
- recommendation type
- consuming surface and channel
- signal classes used in the decision
- source provenance for each signal class
- signal recency or freshness metadata
- canonical customer or anonymous session identifier, with identity-resolution confidence where applicable
- applicable curated look, rule, campaign, and experiment references
- timestamp of recommendation generation

### Traceability expectations
- Internal teams must be able to reconstruct which signal categories affected a recommendation set without exposing sensitive reasoning to customers.
- Audit and analytics workflows must be able to differentiate recommendations driven mainly by session intent from those driven by historical profile or campaign context.
- Outcome telemetry for impression, click, save, add-to-cart, purchase, dismiss, and override must remain linked to the originating recommendation set and trace context.
- Source-system mappings for customer identifiers and profile inputs must remain explicit so signal provenance is reviewable across systems.

## Safe personalization requirements

Customer signal usage must support personalization safely rather than maximizing personalization volume.

### Safe-use principles
- Personalization should improve outfit relevance, not undermine style coherence or brand standards.
- Short-term intent and hard compatibility should take precedence over weak historical inference.
- Recommendation quality for anonymous or low-data customers must remain acceptable through curated and rule-based fallbacks.
- Personalization must be explainable internally at the signal-class level even when ranking implementation is more complex.
- Customer-facing explanations, if present, must remain high level and non-sensitive.

### Governance requirements
- Merchandisers must retain the ability to constrain or override recommendation behavior when signal-driven ranking conflicts with campaign, assortment, or styling goals.
- Signal usage policies must be reviewable and updateable as new channels, regions, and signal sources are introduced.
- Sensitive signal classes must have explicit approval checkpoints before activation in production use cases.
- Recommendation experimentation must preserve the same consent, traceability, and governance rules as default ranking.

## RTW and CM considerations

### RTW
- RTW recommendations may use session and order signals more aggressively for fast-moving PDP, cart, and homepage journeys because purchase intent is often immediate.
- Inventory-aware attachment logic should remain tightly coupled to fresh cart, product-view, and browsing signals.

### CM
- CM recommendations must weight in-progress configuration context, appointment context, and stylist support more carefully because the journey is higher consideration and more sensitive to trust failures.
- Sensitive store or stylist inputs must not be used in CM recommendation logic unless explicitly permitted and traceable.

## Success metrics

### Business outcomes
- Improved conversion and attachment rate on surfaces where permitted customer signals are active.
- Higher average order value for recommendation-influenced sessions that use customer signals responsibly.
- Improved repeat engagement and recommendation effectiveness for returning-customer cohorts.

### Product and operational outcomes
- Recommendation sets record signal provenance, freshness, and trace context at a rate sufficient for downstream audit and analytics.
- Personal recommendations outperform non-personalized baselines where identity confidence and permitted data are available.
- Low-data and anonymous sessions still receive coherent recommendation outputs through governed fallback logic.
- Policy-restricted signals are visibly suppressed rather than silently used.
- Data freshness lag for recommendation-critical signals is observable and within agreed operational thresholds per channel.

## Open decisions

- **Missing decision:** What explicit freshness thresholds should distinguish actionable, stale, and expired data for each signal class by surface?
- **Missing decision:** Which regions and channels permit the use of store appointments and stylist notes for recommendation use cases?
- **Missing decision:** Which permitted profile inputs can be exposed to marketing activation versus ecommerce-only surfaces?
- **Missing decision:** What minimum identity-confidence threshold is required before cross-session or cross-channel history may personalize a recommendation set?
- **Missing decision:** What customer-facing explanation policy, if any, should be used when personal recommendations are shown?

## Approval and milestone-gate notes

- **Approval mode:** autonomous
- **Current run note:** Trigger is issue-created automation, and autonomous mode is enabled for completion of this BR stage run.
- **Milestone note:** Sensitive store signals, especially stylist notes, require explicit policy validation before downstream feature or implementation work activates them.

## Recommended board update

Update `boards/business-requirements.md` row `BR-006` to reflect this artifact:
- status: `Pushed` after branch push
- approval mode: `autonomous`
- output: `docs/project/br/br-006-customer-signal-usage.md`
- notes: signal freshness thresholds and sensitive store-signal policy remain non-blocking follow-ups for downstream planning
