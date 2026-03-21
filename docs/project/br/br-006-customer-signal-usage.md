# BR-006: Customer signal usage

## Traceability

- **Board item:** BR-006
- **GitHub issue:** #113
- **Stage:** `workflow:br`
- **Trigger source:** issue-created automation for GitHub issue #113 (`workflow:br`)
- **Parent item:** none
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Primary upstream sources:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/architecture-overview.md`
- **Related inputs:** orders, browsing, product views, add-to-cart, search, loyalty, email engagement, store signals, and permitted profile inputs
- **Downstream stage:** `workflow:feature-spec`
- **Promotes to:** `boards/features.md`
- **Phase context:** Phase 2 - Personalization and context enrichment

## 1. Requirement summary

SuitSupply needs a governed way to use customer signals so recommendations become more personal and more useful without becoming unsafe, opaque, or dependent on data that is too stale or not permitted. The platform must define which customer signals are allowed, how fresh those signals must be for different recommendation moments, what traceability must be preserved, and how personalization must remain inside compatibility, consent, and brand-safety boundaries.

This business requirement defines:

- the permitted customer signal classes for recommendation use
- the difference between default-allowed, policy-gated, and disallowed signal usage
- freshness expectations for active-session, operational, and slower-changing profile signals
- traceability requirements so downstream teams can audit why signal-driven recommendations were produced
- safety guardrails so personalization improves relevance without exposing sensitive reasoning or bypassing merchandising governance

This BR does not define:

- the final feature-store, warehouse, or streaming implementation design
- exact ranking formulas, model features, or identity-resolution algorithms
- the legal text or consent UX needed to collect customer permission
- the detailed clienteling workflow for every store or appointment system

## 2. Problem and opportunity

The recommendation platform cannot deliver meaningful personalization in Phase 2 if it treats every customer as anonymous, but it also cannot safely use every available signal without clear business boundaries. Orders, browsing, product views, search intent, add-to-cart actions, loyalty behavior, email engagement, store interactions, and profile inputs all provide value, yet each signal has a different risk profile, freshness expectation, and explanation burden.

Without a clear requirement for customer signal usage:

- personalization may use stale or weakly attributable data and reduce trust
- downstream teams may treat policy-sensitive data as just another ranking feature
- different surfaces may apply customer signals inconsistently
- internal teams may be unable to explain which inputs drove a recommendation set
- recommendation quality may improve in narrow metrics while harming brand safety, compatibility, or customer comfort

The opportunity is to create a signal-usage policy for the recommendation product that:

- improves complete-look relevance for returning and known customers
- preserves compatibility, merchandising control, and brand styling integrity
- keeps consent, region, and identity-confidence handling explicit
- gives downstream feature and architecture work clear rules for freshness, fallback, and traceability

## 3. Business outcomes

This requirement must support these outcomes:

1. **More useful personalization** on PDP, cart, homepage, email, and clienteling surfaces where signals are strong enough and permitted.
2. **Safer activation of customer data** by limiting recommendation use to approved signal classes and explicit policy boundaries.
3. **More trustworthy recommendations** because stale, low-confidence, or weakly attributable signals are degraded or ignored instead of silently influencing outputs.
4. **Auditability across channels** so internal teams can reconstruct which customer signal classes, identities, and policies were in play for a recommendation set.
5. **Stronger downstream readiness** for feature, architecture, and telemetry work around personal, contextual, and clienteling experiences.

## 4. Guiding business principles for customer signal usage

All downstream work must preserve these principles:

### 4.1 Personalization is bounded, not autonomous

Customer signals may improve ordering, selection, and prioritization of eligible recommendations, but they must not override hard compatibility rules, inventory and eligibility constraints, protected curated content, or required merchandising controls.

### 4.2 Permission and policy come before optimization

Signals are only in scope when their use is permitted by region, consent state, source policy, and company governance. A useful signal is still out of scope if policy does not allow it.

### 4.3 Stronger signals require stronger traceability

The more customer-specific a recommendation becomes, the more important it is to preserve signal provenance, identity confidence, recency, and decision context.

### 4.4 Stale signals should degrade relevance, not silently distort it

When freshness thresholds are missed, the system must fall back to weaker but safer personalization or to governed non-personalized recommendation behavior. It must not continue to use stale signals as if they were current.

### 4.5 Customer-facing surfaces must remain respectful

Recommendations may be informed by customer signals, but customer-facing explanations and presentation must not expose sensitive profile reasoning, create a surveillance feeling, or imply knowledge beyond what the customer would reasonably expect.

## 5. Permitted signal classes and usage boundaries

### 5.1 Default-allowed signal classes

The following signal classes are part of the default permitted set when identity confidence, consent, and regional policy allow their use:

| Signal class | Examples in scope | Primary recommendation value | Default freshness tier | Safety notes |
|---|---|---|---|---|
| Orders and returns | prior purchases, recency, category history, return patterns where governed | repeat purchase relevance, complementing owned items, avoiding redundant suggestions | Operational freshness | Must not imply sensitive conclusions or override current compatibility |
| Browsing behavior | sessions, category browsing, look exploration, navigation paths | near-term intent and journey interpretation | Active-session freshness | Best used with session scope when identity is weak |
| Product views | viewed products, viewed looks, repeated product interest | anchor affinity, intent reinforcement, look completion | Active-session freshness | Should decay quickly when no longer current |
| Add-to-cart behavior | current cart, recent cart additions, cart abandonment context where permitted | high-intent attachment and complete-look completion | Active-session freshness | Must respect live inventory and current anchor context |
| Search behavior | search queries, applied filters, on-site search refinements | explicit intent and occasion cues | Active-session freshness | Must not be used to infer prohibited sensitive categories |
| Loyalty and account behavior | loyalty tier, points state, known membership status, earned benefits | prioritization of premium or retention-aware experiences | Operational freshness | Must not become price discrimination logic or bypass merchandising rules |
| Email engagement | opens, clicks, campaign interactions, recent email-driven browse or purchase context | lifecycle relevance and cross-channel continuity | Operational freshness | Only for channels and journeys where email use is permitted |
| Store signals | store visits, appointments, in-store product interest, assisted-selling context, preferred store | clienteling and cross-channel continuity | Operational freshness; active appointment context can be active-session | Free-text notes are policy-gated, not default-allowed |
| Permitted profile inputs | saved looks, favorites, wishlists, fit preferences, size preferences, preferred categories, locale, preferred store, known exclusions | longer-lived preference shaping and safer persistence across visits | Profile freshness | Must be explicitly collected or policy-approved; inferred sensitive traits are out of scope |

### 5.2 Policy-gated signal classes

Some signals may be useful but require explicit policy validation before they can influence recommendations:

- free-text stylist notes
- sensitive customer-service annotations
- appointment notes with high subjectivity or sensitive content
- any derived trait that could reveal or proxy sensitive personal categories

These signals must not be part of the default personalization path. If later approved, downstream work must define stricter governance, narrower usage, and stronger auditability than the default signal set.

### 5.3 Disallowed usage patterns

The following usage patterns are out of scope for this BR:

- using sensitive or special-category personal data for recommendation personalization
- inferring or exposing personal characteristics that customers would not reasonably expect
- using low-confidence cross-channel identity merges as if they were certain
- using stale orders, session events, or appointment context without recency checks
- allowing customer signal strength to bypass hard compatibility, inventory, campaign, or suppression rules
- presenting customer-facing rationale that exposes private behavioral details

## 6. Freshness requirements by signal tier

Customer signals do not all need the same freshness. Downstream designs must preserve these business-level tiers and define fallbacks when a tier is missed.

### 6.1 Active-session freshness

This tier applies to signals that shape the current recommendation moment:

- browsing behavior
- product views
- add-to-cart behavior
- search behavior
- active store or appointment context when a customer is in a live assisted journey

Business expectation:

- These signals should be available in near-real-time for PDP, cart, homepage personalization, and live clienteling use.
- If this tier is stale, missing, or delayed, the system must fall back to broader profile, order-history, curated, or rule-based recommendation behavior.
- Old session intent must decay quickly rather than dominate later recommendation sets.

### 6.2 Operational freshness

This tier applies to signals that change more slowly but still need timely updates:

- orders and returns
- loyalty status or benefits
- email engagement
- store visits and appointment summaries
- saved looks, wishlists, and other persisted preference signals

Business expectation:

- These signals should be refreshed quickly enough to support current personalization and operational trust across returning-customer surfaces.
- Daily or change-driven synchronization is acceptable for most uses, but downstream teams must not treat multi-day lag as harmless when the signal influences active personalization.
- When freshness is uncertain, the system should reduce the weight of the signal class or suppress it from decisioning rather than present outdated personalization as current truth.

### 6.3 Profile freshness

This tier applies to more persistent profile inputs:

- size or fit preferences
- preferred categories
- preferred locale or store
- durable saved-style preferences where explicitly collected

Business expectation:

- These signals may be slower-changing than session intent, but they still require explicit recency and provenance so internal teams know whether a preference is current, self-declared, or derived.
- Profile inputs must not be treated as permanent facts without update history.
- When a profile signal conflicts with stronger current-session behavior, downstream logic should preserve room for recency-aware interpretation instead of blindly trusting the older preference.

### 6.4 Freshness failure behavior

If a required signal class is outside its freshness threshold, downstream implementations must:

1. mark the signal as stale or unavailable in internal decision context
2. reduce or remove its influence from personalization
3. preserve a governed fallback path such as curated, rule-based, contextual, or lower-confidence personal recommendations
4. avoid silently using stale signal classes in a way that makes recommendation reasoning unreconstructable

## 7. Traceability requirements

Customer-signal-driven recommendations must remain auditable for operators, analysts, and downstream feature teams.

### 7.1 Minimum traceability fields

Every recommendation set influenced by customer signals must preserve enough metadata to reconstruct:

- recommendation set ID
- trace ID
- canonical customer ID when known, or anonymous session ID when not
- source-system identifiers or source references for signal classes used
- signal class names that influenced the recommendation
- recency or freshness state for each signal class used
- consent or suppression state relevant to activation
- identity resolution confidence when cross-system merging is involved
- recommendation type, surface, and channel
- applied rule, campaign, experiment, and override context where relevant

### 7.2 Signal attribution expectation

Internal teams do not need raw event payloads in every trace, but they must be able to see:

- which signal classes were available
- which signal classes were actually used
- which signal classes were ignored because they were stale, low-confidence, or not permitted
- whether personalization came primarily from session behavior, longer-lived profile inputs, order history, or store context

### 7.3 Cross-channel traceability expectation

If a known customer moves across ecommerce, email, and clienteling surfaces, downstream systems must preserve enough shared identifiers and policy context to explain the continuity of personalization without assuming every channel identifier is globally reliable.

### 7.4 Auditability expectation

The trace model must support later investigation of:

- recommendation-quality complaints
- inappropriate use of stale signals
- identity mismatch or low-confidence profile merges
- policy-sensitive activation decisions
- differences between personalized, contextual, and non-personalized recommendation behavior

## 8. Safe personalization requirements

### 8.1 Compatibility and governance precedence

Customer signals may influence recommendation prioritization and selection among eligible candidates, but they must not override:

- hard compatibility rules
- inventory and assortment eligibility
- campaign suppressions and required priorities
- protected curated placements
- region, consent, and policy restrictions

### 8.2 Respectful personalization

Personalization should feel useful, not invasive. The platform must:

- avoid overreacting to a single weak or accidental signal
- avoid customer-facing language that reveals detailed behavioral observation
- avoid unstable recommendation swings caused by short-lived noise
- prefer explainable personalization paths over opaque or surprising behavior

### 8.3 Identity-confidence requirement

When personalization depends on cross-session or cross-channel identity, downstream logic must account for identity resolution confidence. Lower-confidence identity should produce weaker or no profile-based personalization rather than assertive personalization with uncertain attribution.

### 8.4 Sensitive-store-signal guardrail

Store and appointment context can be valuable, but the default recommendation path must distinguish structured store signals from subjective or sensitive human notes. Structured visit or appointment metadata may be used where permitted; sensitive free-text notes require explicit policy validation before use.

### 8.5 Channel-appropriate activation

Not every permitted signal must be used on every surface:

- PDP and cart should emphasize active-session and anchor-intent relevance
- homepage and web personalization may use broader profile and history where identity confidence is strong
- email should use signals that remain appropriate for asynchronous delivery and consented activation
- clienteling may use richer store context when policy, identity, and assisted-selling expectations support it

### 8.6 Fallback requirement

If customer-specific signals are weak, stale, low-confidence, or disallowed, the system must degrade gracefully to contextual, curated, or rule-based recommendation behavior instead of forcing low-quality personalization.

## 9. Functional business requirements

### 9.1 Permitted-signal requirement

The platform must support personalization using permitted customer signal classes including orders, browsing, product views, add-to-cart, search, loyalty, email engagement, store signals, and explicitly allowed profile inputs.

### 9.2 Policy-boundary requirement

The platform must distinguish default-allowed, policy-gated, and disallowed customer signals so downstream work does not treat every available customer datum as recommendation-ready.

### 9.3 Freshness requirement

The platform must define and preserve explicit freshness expectations for active-session, operational, and profile-based signal classes, with fallback behavior when those expectations are not met.

### 9.4 Traceability requirement

Each recommendation set influenced by customer signals must preserve enough trace context to identify which signal classes, identities, freshness states, and policy conditions contributed to the output.

### 9.5 Identity-confidence requirement

Profile-based and cross-channel personalization must account for identity resolution confidence and reduce or suppress personalization when identity confidence is not strong enough.

### 9.6 Safe-personalization requirement

Customer signals must improve recommendation relevance only within compatibility, inventory, merchandising, consent, and regional policy boundaries.

### 9.7 Respectful-experience requirement

Customer-facing experiences must not expose sensitive profile reasoning or create explanations that feel invasive, overly specific, or unsupported by high-confidence data.

### 9.8 Stale-signal fallback requirement

When required customer signals are stale, delayed, low-confidence, or unavailable, the platform must fall back to governed non-personalized or lower-confidence recommendation behavior rather than silently produce unstable personalization.

## 10. Surface and phase expectations

### 10.1 Phase 2 scope

Phase 2 is where customer signal usage becomes materially broader:

- stronger personalization on homepage and returning-customer ecommerce journeys
- better use of session intent on PDP and cart
- richer ranking and look prioritization for known customers
- clearer traceability for personal recommendation behavior

### 10.2 Surface interpretation

- **PDP:** prioritize current product context plus active-session signals and relevant order or profile history when allowed.
- **Cart:** prioritize current cart composition, high-intent attachment behavior, and known complement history when allowed.
- **Homepage / web personalization:** use broader profile, order, loyalty, and browsing history when identity and consent are strong enough.
- **Email:** use longer-lived and consented signals that remain safe for asynchronous activation; avoid overdependence on highly perishable session signals.
- **Clienteling:** use structured store and appointment context with strong emphasis on traceability, identity confidence, and respectful use.

### 10.3 Phase sequencing rule

Richer customer signal usage should expand only after the platform can preserve:

- explicit consent and region handling
- reliable identity confidence
- signal freshness visibility
- recommendation set and trace ID continuity
- safe fallback behavior when customer-specific inputs are weak

## 11. Success measures

### 11.1 Personalization quality measures

- improved engagement and conversion for known-customer or high-intent sessions versus non-personalized baselines
- better attachment and complete-look engagement when active-session signals are current
- lower rate of irrelevant repeat recommendations to known customers

### 11.2 Safety and governance measures

- percentage of personalized recommendation sets with valid recommendation set ID and trace ID
- percentage of personalized recommendation sets with recorded signal-class attribution and freshness state
- percentage of recommendation activations that respect consent, identity-confidence, and suppression rules
- rate of recommendation issues linked to stale, misattributed, or policy-inappropriate customer signal use

### 11.3 Operational measures

- freshness compliance by signal tier
- availability of active-session signals on real-time surfaces
- visibility into which signal classes are most often missing, stale, or policy-gated
- ability to compare personalized versus governed fallback performance by surface

## 12. Constraints and guardrails

- Customer signals must not bypass hard compatibility, inventory, or merchandising controls.
- Recommendation traces must not depend on hidden or unrecorded customer-signal usage.
- Sensitive or policy-uncertain inputs must not enter the default recommendation path.
- Customer-facing outputs must not expose sensitive profile reasoning.
- Downstream work must tolerate mixed latency across signal sources and degrade gracefully when some classes are unavailable.

## 13. Assumptions

- Phase 2 is the correct stage to expand from mostly shared recommendation behavior into richer customer-specific relevance.
- Orders, browsing, product views, add-to-cart, search, loyalty, email engagement, store signals, and persisted profile inputs together provide enough signal breadth to improve recommendation quality materially.
- Identity resolution, consent handling, and telemetry foundations will be mature enough to support safer personalization, even if some channels remain less complete than others.
- Structured store signals can be useful for recommendation continuity, while free-text stylist notes remain a more sensitive category that needs stronger policy validation.

## 14. Open questions for downstream feature breakdown

- What exact freshness thresholds should each surface enforce for active-session signals such as browse, product view, add-to-cart, and search?
- Which structured store and appointment fields are approved first for recommendation use, and which remain policy-gated?
- What minimum identity-confidence threshold should allow cross-channel personalization on homepage, email, and clienteling surfaces?
- Which customer-facing explanations, if any, should acknowledge personalization without exposing behavioral detail?
- How should stale-signal suppression be surfaced in operator tooling so quality issues can be debugged quickly?

## 15. Downstream handoff to feature breakdown

The next stage should turn this requirement into feature-level artifacts in `boards/features.md`, with at least:

1. feature scope for customer-signal eligibility, policy classification, and activation rules
2. feature scope for freshness handling, decay rules, and fallback behavior by surface
3. feature scope for signal traceability, recommendation set IDs, trace IDs, and operator auditability
4. feature scope for identity-confidence and consent-aware personalization gating
5. feature scope for store-signal handling and policy-gated input treatment

## 16. Exit criteria check

This BR is complete when downstream teams can see:

- which customer signal classes are permitted for recommendation use
- how freshness expectations differ across active-session, operational, and profile inputs
- what traceability must be preserved when customer signals shape recommendations
- how personalization must remain safe, respectful, and bounded by policy and governance
- where customer signal usage must degrade gracefully instead of forcing stale or low-confidence personalization

## 17. Review pass

Trigger: issue-created automation

Artifact under review: `docs/project/br/br-006-customer-signal-usage.md`

Approval mode: `AUTO_APPROVE_ALLOWED`

Blockers: none

Required edits: none

Scored dimensions:

- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5

Overall disposition: `APPROVED`

Confidence: HIGH

Approval-mode interpretation:

- This artifact exceeds the promotion threshold in the repo rubric.
- `AUTO_APPROVE_ALLOWED` is explicitly recorded on the board and in this artifact.
- No milestone human gate blocks completing this BR artifact, though downstream feature work must preserve policy-gated handling for sensitive store inputs and stronger identity-confidence controls.

Residual risks and open questions:

- Exact surface-level freshness thresholds remain a downstream feature and architecture decision.
- Policy treatment for subjective store or stylist-note data still requires narrower follow-up before any production use.
