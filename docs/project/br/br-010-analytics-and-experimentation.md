# BR-010: Analytics and experimentation

Trigger: issue-created automation from GitHub issue #84 (`workflow:br`).

## 1. Summary

Define the business requirements for how the AI Outfit Intelligence Platform measures recommendation performance, supports controlled experimentation, and reports optimization outcomes across recommendation surfaces and internal teams.

This BR covers the telemetry, experiment hooks, reporting expectations, and success metrics needed to optimize complete-look and context-aware recommendations without weakening merchandising governance, privacy controls, or auditability.

## 2. Traceability

- **Board item:** BR-010
- **Parent item:** None
- **Stage:** Business requirements
- **Trigger source:** `docs/project/business-requirements.md`; `docs/project/goals.md`; `docs/project/roadmap.md`
- **Related references:** `docs/project/data-standards.md`; `docs/project/standards.md`
- **Approval mode:** `AUTO_APPROVE_ALLOWED`
- **Downstream stage:** `boards/features.md` feature breakdown items for telemetry instrumentation, experimentation controls, analytics reporting, and optimization workflows

## 3. Problem statement

Recommendation quality cannot improve sustainably unless the platform can measure what was shown, how customers and internal users responded, which recommendation logic variant was active, and whether the resulting business outcomes justified the change.

Today the project goals and roadmap require recommendation telemetry, experimentation hooks, and optimization reporting, but downstream work would still have to guess the business expectations for:

- which recommendation events must be captured
- how recommendation influence should be attributed
- which metrics matter by surface, recommendation type, and rollout phase
- how experiments can run without violating merchandising rules or privacy constraints
- what reporting internal teams need to govern and improve the system

Without these requirements, the platform risks shipping recommendation outputs that appear relevant but cannot be measured, compared, or improved safely.

## 4. Target users

### Primary internal users

- Analytics and optimization teams evaluating recommendation effectiveness
- Product managers prioritizing recommendation improvements and rollout decisions
- Merchandising teams validating whether recommendation behavior supports brand and campaign goals

### Secondary internal users

- Marketing teams reviewing recommendation performance for email and lifecycle activations
- Clienteling and store leadership reviewing recommendation usefulness in stylist-assisted workflows
- Operations teams monitoring telemetry completeness, reporting quality, and experiment safety

### Indirect external users

- Ecommerce customers receiving recommendation sets on PDP, cart, homepage, and future digital surfaces
- RTW and CM customers whose journeys generate outcome data used to improve recommendations over time

## 5. Business value

This capability must create value in four ways:

1. **Optimization value:** Make it possible to improve recommendation performance through measurable iteration rather than opinion-only tuning.
2. **Commercial value:** Show whether recommendations drive conversion, attachment, AOV, repeat engagement, and channel-specific business outcomes.
3. **Governance value:** Give internal teams evidence to approve, reject, or refine recommendation changes while preserving merchandising control.
4. **Operational value:** Detect telemetry gaps, experiment risk, and underperforming recommendation strategies before they erode trust in the platform.

## 6. Scope boundaries

### In scope

- Business requirements for recommendation telemetry across digital, marketing, and future clienteling surfaces
- Impression and outcome event expectations for recommendation sets, recommended products, and complete-look interactions
- Attribution expectations linking recommendation exposure to downstream engagement and commercial outcomes
- Experimentation hooks for recommendation source, ranking, eligibility, presentation, and surface-level variants
- Reporting expectations for internal users by surface, recommendation type, region, and customer segment where permitted
- Success metrics required to judge recommendation quality and optimization effectiveness
- Governance constraints for experiments so they do not bypass brand, compatibility, campaign, inventory, or privacy rules
- Phase guidance for what must exist in Phase 1 versus what expands in later phases

### Out of scope

- Detailed implementation architecture for analytics pipelines, event transport, storage, or BI tooling
- Final statistical methodology, significance thresholds, or data science model design
- UI design for dashboards or reporting tools
- Broader enterprise analytics strategy unrelated to recommendation decisions
- Merge, release, or CI policy for future implementation stages

## 7. Recommendation and channel mapping

### Recommendation types affected

- outfit
- cross-sell
- upsell
- style bundle
- occasion-based
- contextual
- personal

### Surfaces and channels affected

- PDP
- cart
- homepage or web personalization surfaces
- email and lifecycle activation channels
- future clienteling and internal recommendation consumers

### Recommendation sources to distinguish in measurement

- curated
- rule-based
- AI-ranked

Reporting and experiment analysis must preserve these distinctions so internal teams can compare source effectiveness and blended recommendation behavior.

## 8. RTW and CM considerations

### RTW

- Phase 1 optimization focuses on RTW anchor-product recommendation flows on high-signal digital surfaces such as PDP and cart.
- RTW reporting must emphasize purchasability, attachment behavior, and fast learning loops from impression through purchase.

### CM

- CM experimentation should expand later because journey length, appointment context, premium decisions, and configuration state make attribution more complex.
- CM telemetry must eventually distinguish recommendation outcomes tied to configured garments, fabric or palette guidance, and stylist-assisted journeys without oversimplifying the decision path.

## 9. Business requirements

### BR-010.1 Shared recommendation telemetry

The platform must capture a shared recommendation telemetry model for every recommendation surface so internal teams can compare performance across channels without redefining event meaning per surface.

At minimum, the telemetry model must support:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

The business meaning of each event must remain stable across surfaces even when presentation differs.

### BR-010.2 Recommendation context on every measurable event

Every recommendation-related event must preserve enough business context to explain what the customer or operator saw and why it was eligible for analysis.

At minimum, measurable context must include where applicable:

- recommendation set ID
- trace ID
- recommendation type
- surface
- channel
- product IDs or look IDs involved
- customer ID or anonymous session ID
- experiment ID and variant
- campaign or merchandising rule context
- timestamp

This aligns measurement with the project data standards and ensures outcomes can be attributed back to a specific recommendation set and decision context.

### BR-010.3 Impression and outcome linkage

The platform must support linkage between recommendation impressions and downstream outcomes so teams can measure influence rather than only raw interaction counts.

Required outcome linkage includes:

- which recommendation set was exposed
- which recommended item or look was engaged
- whether the engagement led to add-to-cart, purchase, save, or dismiss behavior
- whether the commercial outcome occurred in the same session or an attributable later window defined by policy

### BR-010.4 Experimentation hooks for optimization

The platform must support experiment hooks that allow controlled comparison of recommendation strategies without requiring ad hoc engineering changes for every optimization cycle.

Experimentation must be able to compare at minimum:

- ranking strategies
- recommendation source blends across curated, rule-based, and AI-ranked outputs
- eligibility or fallback logic
- presentation or slot ordering choices
- surface-specific recommendation treatments
- context-aware versus non-contextual variants where permitted

### BR-010.5 Governance-safe experimentation

Experimentation must not bypass:

- merchandising rules
- compatibility constraints
- campaign priorities
- inventory-aware eligibility
- privacy, consent, and regional data handling rules
- brand safety expectations for complete-look coherence

Experiments are optimization tools, not exceptions to governance.

### BR-010.6 Reporting for internal decision-making

The platform must provide reporting outputs that allow internal users to answer:

- which surfaces and recommendation types are improving conversion and AOV
- whether complete-look recommendations increase attachment across categories
- which variants outperform baseline experiences
- whether telemetry coverage is complete enough to trust the analysis
- where recommendation performance varies by region, channel, cohort, or recommendation source
- whether overrides, campaigns, or governance actions are improving or suppressing outcomes

### BR-010.7 Phase-aware measurement

Reporting and optimization expectations must follow phased rollout guidance:

- **Phase 1:** establish impression, click, add-to-cart, and purchase telemetry on one or two high-signal RTW surfaces; confirm telemetry completeness and baseline business signal
- **Phase 2:** add richer customer-signal and context-aware analysis, with stronger personalization comparisons
- **Phase 3:** expand reporting to merchandising, campaign, email, and clienteling workflows with broader experimentation controls
- **Phase 4+:** extend measurement to deeper CM and premium outfit-building journeys

### BR-010.8 Success metrics for optimization

The platform must define and monitor success metrics that can be used to judge optimization outcomes, not just system activity.

These metrics must include commercial, product, and operational measures and must be available at least by surface and recommendation type.

## 10. Reporting expectations

### Required reporting slices

Internal reporting must support analysis by:

- surface
- channel
- recommendation type
- recommendation source mix
- experiment and variant
- region or country where permitted
- anonymous versus known customer state where permitted
- RTW versus CM flow where applicable

### Required reporting outputs

At minimum, reporting must enable:

- baseline versus experiment comparison
- trend reporting over time
- recommendation coverage and null-result visibility
- funnel views from impression to purchase
- override and campaign impact visibility
- telemetry completeness and freshness visibility

### Reporting consumers and cadence expectations

- **Product and analytics teams:** regular optimization review using near-current data and experiment comparisons
- **Merchandising teams:** operational visibility into recommendation quality, override impact, and campaign effects
- **Leadership and cross-functional stakeholders:** periodic roll-up views of commercial contribution, channel performance, and optimization progress

The exact dashboard cadence is implementation-stage detail, but the business requirement is that reporting be timely enough to guide phased rollout and optimization decisions.

## 11. Success metrics

### Commercial metrics

- conversion uplift on recommendation-enabled surfaces
- AOV uplift for recommendation-influenced sessions
- attachment rate across categories and complete-look components
- repeat engagement or repeat purchase improvement for personalized cohorts
- recommendation-driven contribution to email and clienteling outcomes as those channels come online

### Product metrics

- impression volume and recommendation coverage by surface
- recommendation click-through rate
- add-to-cart rate from recommendation interactions
- purchase conversion from recommendation-influenced sessions
- complete-look engagement rate
- dismiss rate and null-result rate
- experiment participation and variant allocation integrity

### Operational metrics

- percentage of recommendation sets with full telemetry traceability
- telemetry freshness and reporting lag
- event completeness across required impression and outcome events
- experiment guardrail compliance
- reporting availability and internal adoption by optimization stakeholders

## 12. Constraints and guardrails

- Recommendation measurement must respect privacy, consent, and regional restrictions.
- Customer-facing experiences must not expose sensitive profile reasoning even when richer telemetry exists internally.
- Experimentation must preserve styling integrity and purchasability.
- Internal reports must distinguish data gaps from true performance changes so teams do not optimize against incomplete telemetry.
- Recommendation attribution must be transparent enough for audit and operator review.

## 13. Dependencies

- Stable canonical IDs for products, customers, looks, rules, campaigns, experiments, recommendation sets, and traces
- Shared event and telemetry standards from `docs/project/data-standards.md`
- Surface definitions and recommendation contracts from downstream feature and implementation work
- Merchandising governance rules that define which outputs are eligible for experimentation
- Identity, consent, and regional policy handling for customer-level analysis

## 14. Missing decisions

- Missing decision: what attribution window should count a purchase or repeat engagement as recommendation-influenced for each surface?
- Missing decision: which baseline metrics and minimum detectable improvements will gate rollout decisions by phase?
- Missing decision: which internal teams own experiment review and stop/go decisions for high-risk variants?
- Missing decision: what reporting latency is acceptable per surface for operational decision-making?
- Missing decision: when Phase 3 begins, which email and clienteling metrics are authoritative for channel-specific optimization?
- Missing decision: what level of CM-specific attribution is required before deeper CM experimentation expands in Phase 4?

## 15. Acceptance criteria for downstream work

This BR is complete for downstream feature breakdown when:

- telemetry requirements explicitly cover recommendation impressions and outcome events
- experiment hooks are defined as business requirements rather than left implicit
- reporting expectations are clear enough for downstream feature and architecture work
- success metrics span commercial, product, and operational optimization needs
- phased rollout guidance clarifies what must exist in Phase 1 versus later stages
- missing decisions are recorded instead of guessed

## 16. Recommended board update

Update `boards/business-requirements.md` for `BR-010`:

- status `IN_PROGRESS` while this artifact is being drafted
- status `DONE` once the artifact is committed and pushed on `br/issue-84`
- preserve `AUTO_APPROVE_ALLOWED`
- note that Phase 1 establishes measurable telemetry and later phases expand experimentation depth and reporting breadth
