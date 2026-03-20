# BR-010 Analytics and experimentation

## Metadata

- Board item ID: BR-010
- GitHub issue: #59
- Stage: workflow:br
- Trigger: issue-created automation
- Source artifacts:
  - docs/project/business-requirements.md (BR-10)
  - docs/project/goals.md
  - docs/project/data-standards.md
  - docs/project/roadmap.md
  - docs/project/standards.md

## Problem statement

The platform needs a measurable optimization loop for recommendation quality, commercial impact, and operational safety. Today the project documents establish that recommendation telemetry must start in Phase 1 and that richer analytics and experimentation must expand in later phases, but the business requirement for how those capabilities should be used has not been specified in one place. Product, analytics, merchandising, and channel teams need a shared requirement for what recommendation events must be captured, what experiments must be supported, what reporting must be available, and how success will be judged so recommendation logic can improve over time without losing brand control or auditability.

## Target users

- Analytics and optimization teams responsible for performance measurement, experiment readouts, and recommendation tuning
- Product managers responsible for prioritizing recommendation improvements and rollout decisions
- Merchandising teams responsible for validating that optimization does not override style, campaign, or compatibility rules
- Ecommerce channel owners using recommendation performance on PDP and cart to guide ongoing iteration
- Marketing and clienteling stakeholders who will consume reporting when recommendation activation expands to email and in-store workflows

## Business value

- Creates a closed feedback loop between recommendation delivery and measurable business outcomes
- Allows the business to compare curated, rule-based, and AI-ranked recommendation approaches instead of relying on intuition alone
- Makes recommendation changes safer by exposing operational regressions, data quality problems, and brand-governance impacts early
- Supports the platform goals for conversion uplift, higher basket size, stronger attachment, and better repeat engagement by making optimization evidence available to the teams that own those outcomes
- Reduces the risk of expanding recommendation surfaces before telemetry, reporting, and experiment controls are reliable

## Recommendation and channel mapping

### Recommendation types in scope

- Phase 1 foundation: outfit, cross-sell, and upsell recommendations on initial high-signal ecommerce surfaces
- Expansion phases: contextual, personal, and style-bundle recommendations as customer and context signals mature

### Surfaces and channels in scope

- Phase 1: PDP and cart as the initial optimization loop
- Later phases: homepage or web personalization, email, and clienteling once telemetry schemas and reporting are stable

### Recommendation source context

- Curated looks
- Rule-based compatibility and governance logic
- AI-ranked ordering or selection logic

The analytics and experimentation layer must let internal teams evaluate each source independently and in blended recommendation sets.

## Scope boundaries

### In scope

- Define the recommendation telemetry foundation that must exist from Phase 1 onward
- Define the experimentation hooks required to compare recommendation strategies, rule sets, and presentation variants
- Define the reporting outputs needed by product, analytics, merchandising, and channel teams
- Define commercial, product, and operational success metrics used to judge optimization outcomes
- Define phased expectations so early telemetry supports later experimentation and multi-channel analysis
- Define auditability, traceability, and governance expectations for recommendation decision measurement

### Out of scope

- Selecting a specific analytics vendor, BI tool, or experimentation platform
- Detailed event schema implementation, API contracts, or warehouse design
- Automated decisioning that bypasses merchandising governance or approval controls
- Replacing existing commerce analytics, finance reporting, or campaign tooling
- Finalizing legal or policy decisions for sensitive data use beyond recording the required open decisions

## Telemetry requirements

### Phase 1 telemetry foundation

The platform must capture a minimum recommendation event model for impression, click, add-to-cart, and purchase events on the first live recommendation surfaces. That telemetry foundation must support comparison across recommendation types, surfaces, and variants rather than only raw event counting.

Every recommendation-related event must capture, where applicable:

- recommendation set ID
- trace ID
- recommendation type
- surface and channel
- anchor product or journey context
- product IDs and look IDs shown or acted on
- customer ID or anonymous session ID
- timestamp
- experiment ID and variant when the interaction is part of a test
- campaign, curated-look, and rule context needed to explain why the recommendation was shown

### Expanded telemetry expectations

As recommendation workflows mature, the telemetry model must also support:

- save and dismiss events where the consuming surface exposes those actions
- override events when internal users replace or suppress recommendations
- visibility into fallback or no-recommendation outcomes so coverage gaps are measurable
- traceability of which curated, rule-based, and AI-ranked inputs contributed to the final recommendation set
- operational telemetry for recommendation latency, availability, data freshness, and ingestion health

### Data governance expectations

- Telemetry must use stable canonical identifiers for products, customers, looks, rules, campaigns, experiments, and recommendation sets
- Consent, suppression, and regional data-handling constraints must be enforced before customer-level telemetry is used for optimization
- Sensitive internal signals, including stylist notes or appointment context, must not enter optimization workflows until policy approval is explicit

## Experimentation requirements

- The platform must support controlled comparison of recommendation strategies, including curated versus blended ranking approaches, rule-set changes, eligibility changes, and presentation changes on supported surfaces
- Experiments must be traceable by experiment ID and variant in recommendation telemetry and downstream reporting
- Experimentation must support surface-specific and channel-specific analysis rather than only one global average
- The business must be able to compare experiment performance by recommendation type, customer cohort, region, and major channel where sample size allows
- Experimentation must preserve hard compatibility rules, campaign priorities, and brand-safety constraints rather than testing changes that bypass governance
- The optimization workflow must support a measurable baseline or holdout so teams can judge uplift against a known comparison point
- Later-phase experimentation must support multi-channel activation analysis when recommendation outputs are reused in email and clienteling contexts

## Reporting expectations

The platform must provide reporting that helps different internal users answer different questions without rebuilding the recommendation context manually.

### Core reporting views

- Surface performance reporting for PDP, cart, and later recommendation surfaces
- Recommendation-type reporting for outfit, cross-sell, upsell, contextual, personal, and style-bundle experiences
- Commercial outcome reporting for recommendation-influenced sessions and orders
- Operational reporting for latency, availability, freshness, event completeness, and telemetry health
- Governance reporting for overrides, campaign influence, and rule participation in recommendation outcomes
- Experiment readouts that compare control and variant performance using the same recommendation telemetry source of truth

### Required reporting dimensions

Reporting must allow slicing by:

- surface
- channel
- recommendation type
- region or market
- device or session cohort where useful
- anonymous versus known-customer journeys where policy allows
- experiment and variant
- curated, rule-based, and AI-ranked source mix

### Reporting cadence expectations

- Ongoing dashboarding for operational health and recommendation performance on active surfaces
- Regular experiment readouts for optimization decisions
- Periodic business reporting for commercial impact, coverage, and attachment trends across channels

## Success metrics

### Commercial success metrics

- conversion uplift on targeted recommendation surfaces
- average order value uplift for recommendation-influenced sessions
- attachment-rate improvement across categories included in complete-look recommendations
- stronger repeat engagement and repeat purchase behavior for customers exposed to more relevant recommendations

### Product and recommendation metrics

- recommendation click-through rate
- add-to-cart rate from recommendation interactions
- purchase conversion from recommendation-influenced sessions
- complete-look engagement rate
- recommendation coverage by surface, category, and region
- save and dismiss rates on surfaces that expose those interactions

### Experimentation and reporting success metrics

- percentage of recommendation interactions attributable to a recommendation set ID and trace ID
- percentage of active experiments with complete telemetry coverage and analyzable variant data
- time from experiment completion to an internal readout that can support a rollout decision
- share of recommendation logic changes that can be tied back to experiment, rule, or campaign context

### Operational success metrics

- recommendation API latency and availability for recommendation-enabled surfaces
- freshness of catalog, inventory, customer-event, and context data used in recommendation decisions
- completeness and timeliness of telemetry ingestion
- rate of detected fallback, no-recommendation, or telemetry-loss conditions

Where target thresholds are not already defined in project goals, the business baseline and target values remain a missing decision for downstream planning.

## RTW and CM considerations

- Phase 1 optimization should center on RTW surfaces with high interaction volume, especially anchor-product flows on PDP and cart
- CM workflows remain in scope for future analytics and experimentation design, but they require stricter handling because recommendation journeys may involve appointments, stylist intervention, and configuration-aware compatibility
- CM experimentation must not be treated as equivalent to RTW ecommerce testing; later stages must define how assisted journeys, premium options, and appointment outcomes are measured

## Constraints and guardrails

- Analytics and experimentation must preserve merchandising control and compatibility safety rules
- Customer-facing experiences must not expose sensitive profile reasoning just because richer telemetry exists internally
- Recommendation performance must be measurable across regions without violating local consent or policy requirements
- The optimization loop must remain auditable so recommendation changes can be reviewed and reversed when needed

## Open decisions

- Missing decision: define the primary attribution model and reporting window for recommendation-influenced sessions and purchases
- Missing decision: define who owns the canonical experiment-readout process across product, analytics, and merchandising
- Missing decision: define the first-release reporting audience and whether a single dashboard or role-specific views are required
- Missing decision: define which later-phase surfaces must support save and dismiss events versus impression, click, add-to-cart, and purchase only
- Missing decision: define when CM-specific recommendation experimentation can begin and what non-ecommerce success signals must be included
- Missing decision: confirm any required human approval path for experiments that use sensitive internal signals or cross-channel identity stitching

## Approval and milestone-gate notes

- Approval mode for this BR item is autonomous for the current milestone and automation run
- Human review remains a non-blocking downstream note for any future experimentation that expands into sensitive data usage, CM-assisted journeys, or material merchandising-governance changes

## Recommended board update

Add or update `boards/business-requirements.md` with BR-010, output `docs/project/br/br-010-analytics-and-experimentation.md`, status `In Progress` while drafting and `In PR` after branch push, and note the phased scope: telemetry starts in Phase 1 while richer analytics and experimentation workflows expand in Phase 3.
