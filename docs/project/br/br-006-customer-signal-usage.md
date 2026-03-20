# BR-006: Customer signal usage

## Traceability

- **Board item:** BR-006
- **Issue:** #55
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent item:** none
- **Source artifacts:** `docs/project/business-requirements.md` (BR-6), `docs/project/goals.md`, `docs/project/personas.md`, `docs/project/data-standards.md`, `docs/project/roadmap.md`
- **Planned downstream stage:** `boards/features.md` items for customer profile activation, consent-aware personalization, and measurement

## Problem statement

The platform needs to use customer behavior and history signals to make complete-look recommendations feel more relevant for returning and known customers without exceeding privacy, consent, or governance limits. Today, the source material establishes that personalization should improve over time, but it does not yet define which customer signals are permitted, where those signals can be activated, or what constraints apply when identity confidence or consent is limited. Without explicit business requirements, downstream feature and implementation work would either overreach into sensitive cross-channel use or underuse valuable signals such as order history, browsing intent, and saved looks.

This requirement defines the allowed customer signal classes, the business boundaries for using them, and the measurable outcomes expected from signal-driven personalization across ecommerce, marketing, and clienteling use cases.

## Target users

### Primary customer personas

- **Style-aware returning customer:** expects recommendations to reflect prior purchases, fit preferences, and repeat category behavior.
- **Occasion-led online shopper:** benefits when recent browsing, search, and cart behavior help complete an outfit quickly.
- **Custom Made customer:** benefits from historically informed guidance, but only when configuration state, appointments, and assisted-selling context are handled carefully.

### Internal personas

- **In-store stylist / clienteling associate:** needs trustworthy customer-context signals for assisted selling without exposing sensitive reasoning.
- **Marketing and CRM manager:** needs consent-aware personalization inputs for email and lifecycle activation.
- **Merchandiser / look curator:** needs clear boundaries so personalization does not override brand safety, compatibility rules, or campaign intent.
- **Product, analytics, and optimization lead:** needs measurable outcomes and traceability for personalized recommendation behavior.

## Business value

- Improve recommendation relevance for known customers so the experience feels progressively smarter across repeat visits.
- Increase conversion and average order value by using customer history to recommend more compatible complementary items and premium options.
- Improve repeat purchase, retention, and campaign effectiveness through consent-aware personalized recommendations.
- Preserve trust by making customer-signal usage explicit, governable, and auditable before broader multi-channel rollout.
- Prevent downstream teams from assuming cross-channel personalization is allowed before consent handling and identity maturity are ready.

## Scope boundaries

### In scope

- Define the customer signal categories that may be used for personalization and recommendation ranking.
- Define the business usage boundaries for those signals across ecommerce, email, and clienteling surfaces.
- Define privacy, consent, identity-confidence, and governance constraints that determine when a signal may be activated.
- Define how customer-signal usage differs across Phase 1 and Phase 2 roadmap maturity.
- Define measurable personalization outcomes tied to recommendation telemetry and business results.

### Out of scope

- Technical design for identity resolution, profile storage, consent services, or recommendation APIs.
- Automatic approval of any sensitive data use that requires legal, privacy, or policy review.
- Using customer signals for pricing, credit-like decisions, or non-recommendation decisions outside the recommendation product scope.
- Full free-text note mining, unrestricted cross-channel identity linking, or broad offline-to-online activation before explicit policy and identity maturity are in place.

## Personalization scope by phase

| Phase | Allowed personalization scope | Not yet allowed |
|---|---|---|
| **Phase 1 - foundation and first recommendation loop** | Same-session and same-account signals on initial digital surfaces such as PDP and cart; emphasis on RTW anchor-product flows and high-confidence behavior such as recent views, cart actions, search intent, and known order history where permitted. | Broad cross-channel activation, homepage-wide profile targeting, email activation without clear consent mapping, and low-confidence identity stitching. |
| **Phase 2 - personalization and context enrichment** | Broader customer-history activation, richer profile usage, and contextual plus personal recommendations when consent handling, canonical IDs, and identity confidence are visible and governable. | Unbounded use of store, appointment, or stylist-derived signals without policy validation; hidden cross-channel profile joins. |
| **Phase 3+ multi-channel activation** | Reusable personalized recommendation outputs for email and clienteling after governance, telemetry, and override controls are stable. | Any usage that bypasses merchandising controls, auditability, or region-specific policy requirements. |

## RTW / CM considerations

| Area | RTW expectation | CM expectation |
|---|---|---|
| **Primary customer signals** | Recent browsing, product views, add-to-cart behavior, order history, saved items, and category affinity can shape outfit completion and cross-sell suggestions. | Prior CM purchases, appointment history, saved configurations, and structured preference signals can shape assisted recommendations when identity and consent requirements are met. |
| **Personalization style** | Favor fast, purchasable recommendations that reduce styling friction on ecommerce surfaces. | Favor guided recommendations that reinforce configuration choices and work well in higher-consideration journeys. |
| **Governance sensitivity** | Lower-risk signals can be used earlier when tied to clear commerce behavior. | Appointment and stylist-assisted signals require tighter governance because they may contain more sensitive or nuanced customer context. |
| **Customer-facing explanation** | Explanations should stay generic, such as "recommended for your current look" or "matches your recent browsing." | Avoid exposing detailed reasoning tied to appointments, notes, or inferred preferences in customer-facing surfaces. |

## Recommendation type and surface mapping

| Recommendation type | Primary surfaces | How customer signals may be used | Boundary notes |
|---|---|---|---|
| **Outfit / complete-look** | PDP, cart, style inspiration, clienteling | Use order history, recent browsing, saved looks, and cart composition to select more relevant complementary items around an anchor product or occasion. | Must still honor compatibility, inventory, and brand styling rules before personalization ranking. |
| **Cross-sell** | PDP, cart, email, clienteling | Use recent journey behavior and historical category affinity to pick complementary products customers are more likely to add. | Cross-channel cross-sell activation requires consent and identity confidence that support reuse beyond the active session. |
| **Upsell** | PDP, cart, clienteling | Use purchase history, loyalty behavior, and fit or style preference signals to identify premium but credible alternatives. | Must not use account or loyalty data to create unfair treatment or opaque premium pressure. |
| **Contextual** | Homepage, web personalization, email | Blend customer history with season, location, occasion, and campaign context when the customer is known and activation is allowed. | If customer consent or identity confidence is missing, fall back to context-only ranking. |
| **Personal** | Homepage, email, clienteling, future lifecycle surfaces | Use the richest permitted profile view, including durable preferences and repeat behavior, to deliver distinctly individualized recommendations. | Personal recommendations are Phase 2+ and depend on governed cross-channel identity and consent handling. |

## Permitted customer signals

| Signal class | Examples | Permitted recommendation usage | Initial activation scope | Key boundaries |
|---|---|---|---|---|
| **Order history** | Prior purchases, returns, category mix, recency | Rank complementary items, avoid irrelevant repeats, tailor outfit completion, support premium follow-ons where relevant | Same-account personalization; linked profile use when identity confidence is high | Do not use to infer sensitive personal attributes; honor deletion and suppression rules. |
| **Browsing and product views** | Recent sessions, viewed products, viewed categories, dwell or recency indicators | Detect short-term intent, prioritize compatible looks, recover current shopping journey context | Same-session for anonymous or logged-in users; profile carryover when permitted | Anonymous history must have bounded retention and clear consent handling where required. |
| **Add-to-cart and cart behavior** | Items added, removed, cart composition, cart recency | Complete the look, identify missing complementary items, sequence upsell or cross-sell recommendations | PDP and cart surfaces first; later reuse in other channels with consent | Do not use cart behavior to trigger cross-channel outreach unless marketing consent permits it. |
| **Search behavior** | Query terms, filters, occasion keywords, size or fit filters | Interpret explicit intent, occasion, and category focus for recommendation ranking | Same-session and same-account flows | Prefer normalized facets over unrestricted free-text retention where policy requires minimization. |
| **Saved looks, favorites, and wishlists** | Saved products, saved looks, favorites | Represent durable taste, repeat interest, and follow-up outfit suggestions | Logged-in customers and clienteling contexts | Respect delete or unsave actions promptly; do not treat stale saved items as current intent indefinitely. |
| **Loyalty and account behavior** | Tier, engagement cadence, account activity | Tailor assortment emphasis and premium recommendations where brand-appropriate | Logged-in customers with permitted account usage | Must not create unfair eligibility or pricing treatment. |
| **Email engagement** | Opens, clicks, recommendation interactions in email | Improve content relevance and follow-up recommendation selection | Only where marketing consent exists and activation is policy-approved | Email engagement cannot substitute for missing marketing consent. |
| **Store visits and appointments** | Recorded visit events, appointment bookings, attended styling sessions | Support clienteling preparation, regional relevance, and appointment-aware recommendations | Phase 2+ only, with explicit consent and high-confidence identity linking | Do not treat passive location or unverified visit data as a personalization signal. |
| **Stylist notes and assisted-selling inputs** | Structured preference tags, appointment outcomes, curated customer notes | Support internal clienteling recommendations and stylist-assisted look building | Phase 2+ internal surfaces only, after explicit policy validation | Free-text or sensitive notes are not permitted for general customer-facing personalization unless redacted, structured, and policy-approved. |

## Usage boundaries

1. **Recommendation-only use:** Customer signals defined here are permitted only for recommendation relevance, look composition, ranking, measurement, and governed campaign activation within this product scope.
2. **Consent before cross-channel activation:** Same-session or same-account personalization may begin earlier, but broader cross-channel reuse depends on consent handling and identity maturity called out in the roadmap.
3. **Identity confidence gating:** Signals from multiple systems may only be combined when the customer profile records identity resolution confidence and that confidence meets the agreed business threshold.
4. **Merchandising and compatibility precedence:** Personalization cannot override hard compatibility rules, curated exclusions, campaign guardrails, or inventory constraints.
5. **Data minimization:** Use the least sensitive signal that can achieve the recommendation outcome. Do not retain or expose more customer context than the use case requires.
6. **No sensitive reasoning in customer-facing surfaces:** Recommendation explanations must stay generic and should not reveal internal profile details, stylist notes, or inferred sensitive preferences.
7. **Fallback behavior is required:** If consent is absent, identity confidence is low, or a signal is stale, the platform must fall back to contextual, curated, or rules-based recommendations rather than degrade into hidden policy violations.
8. **Traceability is mandatory:** Personalized recommendation events must remain measurable through recommendation set IDs, trace IDs, experiment context, and source provenance for the activated signals.

## Privacy, consent, and governance constraints

| Constraint | Requirement |
|---|---|
| **Regional policy compliance** | Signal usage must vary by region and company policy; a signal that is permitted in one region cannot be assumed permitted globally. |
| **Consent-aware activation** | Profiles must record consent or suppression state relevant to recommendation activation, email activation, and any cross-channel use. |
| **Identity transparency** | Profiles must record source mappings and identity resolution confidence before combining behavior across systems. |
| **Sensitive-signal review** | Stylist notes, appointment details, and similar internal signals require explicit policy validation before use beyond tightly governed assisted-selling workflows. |
| **Retention and deletion handling** | Suppression, delete, and unsubscribe actions must stop or limit downstream activation of affected signals according to policy. |
| **Auditability** | Recommendation decisions that use customer signals must remain reconstructable from trace metadata, rule context, and experiment context. |
| **Human-governed overrides** | Merchandisers and internal teams need override paths when personalization would conflict with styling integrity, campaign rules, or brand safety. |
| **Customer trust** | Customer-facing messaging must avoid surprising or overly specific personal reasoning, especially when signals originate from offline or assisted-selling interactions. |

## Measurable personalization outcomes

| Outcome | Measurement approach | Target or expectation |
|---|---|---|
| **Higher conversion on personalized surfaces** | Compare conversion rate on targeted recommendation surfaces for personalized cohorts against the non-personalized or pre-personalization baseline. | Align with project goal of **5% to 10% uplift** on targeted surfaces where personalized recommendations are active. |
| **Higher recommendation-influenced AOV** | Measure average order value for sessions influenced by personalized recommendations versus the baseline cohort. | Align with project goal of **10% to 25% uplift** for recommendation-influenced sessions. |
| **Better repeat purchase and retention** | Track repeat purchase rate, return visit rate, and cohort retention for customers exposed to signal-driven recommendations. | Improvement required for personalized cohorts; exact baseline and threshold are a missing decision for feature planning. |
| **Higher engagement for known customers** | Compare recommendation CTR, add-to-cart rate, save rate, and purchase influence for consented returning customers versus anonymous or contextual-only experiences. | Returning-customer personalization should be materially better than contextual-only recommendations; exact thresholds are a missing decision. |
| **Improved complete-look usefulness** | Measure complete-look engagement, outfit completion rate, and complementary item attachment in sessions using customer-signal personalization. | Must show measurable lift relative to rules-only or context-only recommendation sets. |
| **Governed activation quality** | Track the share of personalized recommendation events that include valid trace IDs, recommendation set IDs, source provenance, and consent-aware eligibility. | Target should approach full coverage for production activation; threshold to be finalized during downstream feature definition. |

## Open decisions

- **Missing decision:** Which regions and legal policies allow appointment-derived and store-derived signals in the initial rollout?
- **Missing decision:** What business threshold defines sufficient identity resolution confidence for cross-channel personalization?
- **Missing decision:** Which consent states distinguish onsite personalization, email personalization, and clienteling activation?
- **Missing decision:** Are structured stylist preference tags available, or does current data exist mostly as free-text notes that require additional governance work?
- **Missing decision:** Which surface expands first beyond PDP and cart for profile-based personalization: homepage, email, or clienteling?
- **Missing decision:** What exact success thresholds should define "materially better" performance for returning-customer personalization versus contextual-only recommendations?

## Approval / milestone-gate notes

- **Default approval mode:** `HUMAN_REQUIRED` until the board records a different mode.
- **Autonomous-run note:** This artifact is produced by issue-created automation in autonomous mode, so the branch, push, and PR should complete without waiting for a manual "Mark as ready" step.
- **Phase dependency note:** Broader cross-channel signal usage depends on consent handling and identity maturity in Phase 2; downstream work should treat this as a requirement boundary, not as a blocker to documenting Phase 1 scope.
- **Downstream expectation:** Feature breakdown should split this BR into consent-aware personalization policy, permitted signal activation, profile/identity gating, and personalization measurement work items.
