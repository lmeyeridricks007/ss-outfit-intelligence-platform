# BR-011: Explainability and auditability

## Metadata

- **Board item:** BR-011
- **Parent item:** none
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Source artifacts:** `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`, `docs/project/industry-standards.md`, `docs/project/roadmap.md`, `docs/project/data-standards.md`
- **Output:** `docs/project/br/br-011-explainability-and-auditability.md`
- **Next stage:** `boards/features.md` feature-breakdown work derived from this BR

## Problem statement

SuitSupply needs recommendation outputs that can be trusted, reviewed, and explained internally. As the platform expands from curated and rule-based recommendation flows into broader personalization, experimentation, campaign activation, and clienteling use cases, teams need to understand why a recommendation set was produced and what inputs or decisions materially shaped it.

Without explicit explainability and auditability requirements, recommendation behavior becomes hard to govern. Merchandisers cannot tell whether a recommendation came from a curated look, a rule outcome, a campaign priority, or an AI-ranked decision. Stylists and clienteling teams cannot judge whether a recommendation is credible for a live customer conversation. Product, analytics, and operations teams cannot reliably troubleshoot poor outcomes, measure experiment effects, or trace recommendation changes back to the decision path that produced them.

This business requirement defines the traceability, review, audit, and troubleshooting expectations needed so recommendation decisions remain operationally understandable, privacy-aware, and safe to scale across channels.

## Target users

### Primary internal users

- Merchandisers and look curators who need to review why a look, outfit, cross-sell, upsell, contextual, or personal recommendation appeared.
- In-store stylists and clienteling associates who need enough internal explanation to trust recommendation outputs during customer conversations.
- Product, analytics, and optimization leads who need to compare recommendation outcomes across rules, campaigns, experiments, and ranking strategies.
- Operations and support teams who need to troubleshoot unexpected recommendation behavior, data gaps, and degraded recommendation quality.

### Secondary internal users

- Marketing and CRM teams using recommendation outputs in campaigns and wanting visibility into campaign-linked recommendation selection.
- Governance, compliance, and data stewardship stakeholders who need auditable provenance and change history for governed recommendation inputs.

### Customer impact

Customers are indirect beneficiaries. They should receive more coherent, governable recommendations because internal teams can understand and correct recommendation behavior. Customer-facing surfaces should not expose sensitive internal reasoning or private profile details.

## Business value

This requirement supports the following outcomes:

- higher operator trust in complete-look and context-aware recommendations
- faster troubleshooting when recommendation quality drops or outputs appear inconsistent
- safer expansion into personalization and experimentation because decision paths remain reviewable
- stronger merchandising governance through clear provenance for rules, campaigns, overrides, and curated looks
- better measurement of what actually influenced commercial outcomes
- reduced operational risk when recommendation behavior changes across surfaces, regions, or phases

## Recommendation and channel mapping

### Recommendation types in scope

- outfit
- cross-sell
- upsell
- style bundle
- occasion-based
- contextual
- personal

### Consuming surfaces in scope

- PDP
- cart
- homepage and web personalization surfaces
- email and CRM activation surfaces
- in-store clienteling interfaces
- internal merchandising, analytics, and operator review surfaces

### Decision sources that must remain distinguishable

- curated looks
- rule-based compatibility and eligibility logic
- campaign priorities
- AI-ranked or heuristic ranking logic
- experiment assignment and variant treatment
- operator overrides

## Scope boundaries

### In scope

- Business requirements for preserving recommendation trace context from request through final recommendation set.
- Provenance for the governed inputs that affect recommendation selection, including looks, rules, campaigns, experiments, overrides, and recommendation source type.
- Internal review needs for understanding why a recommendation set was produced and why alternatives were filtered or deprioritized.
- Auditability for recommendation-affecting changes so teams can attribute behavior changes to the correct governed input or operating action.
- Troubleshooting needs for support and operations teams when recommendations are missing, degraded, inconsistent, or unexpected.
- Privacy-aware separation between internal explanation detail and any customer-facing explanation.
- Phase guidance for what traceability must exist early versus what can deepen as personalization and governance mature.

### Out of scope

- Customer-facing UI copy or detailed customer explanation design.
- Technical architecture, storage design, logging implementation, or API schema details.
- General-purpose legal policy definitions beyond identifying missing decisions that require policy input.
- Approval workflow design for every downstream authoring tool.
- Broader observability requirements unrelated to recommendation decisions.

## RTW and CM considerations

### RTW

- Early phases focus on RTW anchor-product recommendation flows on PDP and cart.
- RTW explainability must still distinguish curated, rule-based, campaign, and ranked influences on final recommendations.
- Inventory and assortment eligibility are especially important to explain when RTW recommendations appear, disappear, or change.

### CM

- CM explainability must preserve richer compatibility context, such as configuration state, fabric or palette constraints, and premium-option interactions.
- Stylist-assisted and appointment-based journeys raise stronger trust requirements because recommendation mistakes can undermine premium guidance quickly.
- Human-in-the-loop review remains especially important for sensitive CM recommendation logic, even when the traceability model is shared with RTW.

## Business requirements

### BR-011.1 Recommendation decision traceability

Every recommendation set must be traceable to a stable recommendation set identifier and trace identifier so internal teams can reconstruct why that set was produced.

### BR-011.2 Request and context visibility

Internal review must be able to see the business-relevant request context that materially influenced the recommendation decision, including surface, channel, anchor product or look, customer or anonymous session context, region, and relevant contextual factors such as season, weather, or occasion signal where used.

### BR-011.3 Source-type explainability

Internal users must be able to distinguish whether each recommended look or item was primarily driven by curated content, rule-based compatibility, campaign selection, experiment treatment, AI-ranked logic, or a combination of those sources.

### BR-011.4 Rule and eligibility provenance

Recommendation review and audit workflows must preserve which rules, exclusions, compatibility constraints, inventory or assortment checks, and other hard governance conditions affected the final result so teams can understand why products were included, removed, or reordered.

### BR-011.5 Campaign provenance

When campaign priorities or campaign-linked recommendation strategies influence the final recommendation set, operators must be able to identify that campaign influence and review the relevant campaign provenance during troubleshooting or audit.

### BR-011.6 Experiment visibility

When experiments affect recommendation behavior, operators and analysts must be able to identify experiment participation, variant treatment, and the resulting recommendation context so commercial outcomes can be compared and explained safely.

### BR-011.7 Override history

The platform must preserve override history for recommendation-affecting actions, including who made the change, what changed, when it changed, and the reason captured for the change where governance requires it.

### BR-011.8 Recommendation change auditability

Material changes to governed recommendation inputs, including curated looks, compatibility rules, campaign settings, and override actions, must remain auditable so teams can connect behavior changes to the responsible business action.

### BR-011.9 Troubleshooting support

Operations and support workflows must have enough recommendation decision context to investigate missing recommendations, degraded relevance, inconsistent cross-channel outputs, and sudden behavior shifts without requiring ad hoc engineering-only reconstruction for routine cases.

### BR-011.10 Telemetry correlation

Recommendation review must correlate decision traces with downstream telemetry so internal teams can connect recommendation sets to impression, click, add-to-cart, purchase, dismiss, and override outcomes for analysis and troubleshooting.

### BR-011.11 Privacy-aware explanation boundaries

Internal explainability must be more detailed than customer-facing explanation. Customer-facing surfaces must not expose sensitive profile reasoning, identity-resolution detail, or restricted internal decision context unless explicitly approved by policy.

### BR-011.12 Access and trust boundaries

Recommendation explanation and audit detail must respect role-appropriate access boundaries so merchandising, analytics, clienteling, and operations users can review what they need without exposing more sensitive data than their workflow requires.

### BR-011.13 Cross-channel consistency

Recommendation decisions delivered across ecommerce, email, and clienteling surfaces must remain consistently traceable through shared identifiers and provenance so cross-channel behavior can be reviewed without channel-specific guesswork.

### BR-011.14 Operational completeness threshold

The business must be able to define and monitor what percentage of recommendation sets have complete enough trace data for routine review and troubleshooting, because explainability that exists only for a small minority of decisions is not operationally sufficient.

## Review and operator workflow expectations

Internal users must be able to answer these questions for a recommendation set without reconstructing the decision manually:

- What recommendation type and surface produced this set?
- What anchor product, look, or context initiated the request?
- Which business rules, compatibility checks, or eligibility conditions materially affected the result?
- Was campaign logic involved?
- Was an experiment or variant involved?
- Was an override or manual governance action involved?
- Which recommendation source types contributed to the final ranking or selection?
- Which downstream outcomes are associated with this recommendation set?
- If the result looks wrong, what business-owned factor should be reviewed first?

## Phased rollout guidance

### Phase 1 - Foundation and first recommendation loop

Must establish:

- recommendation set ID and trace ID on initial recommendation flows
- traceability for anchor-product context, surface, and recommendation type
- visibility into curated versus rule-based versus ranked contribution at a business-meaningful level
- provenance for hard eligibility conditions, especially product attribute and inventory constraints
- linkage from recommendation sets to core telemetry events on initial surfaces

Phase 1 should prioritize high-confidence RTW flows on PDP and cart, where trust and troubleshooting are needed early.

### Phase 2 - Personalization and context enrichment

Must expand traceability to include:

- richer customer and session context where permitted
- contextual features such as weather, region, season, and occasion signals
- clearer visibility into personalization and ranking influence
- experiment participation and variant context for recommendation analysis

This phase increases audit needs because more dynamic, customer-aware logic raises the risk of opaque recommendation behavior.

### Phase 3 - Merchandising control and multi-channel activation

Must strengthen:

- campaign provenance
- override history and approval context where applicable
- operator review workflows for merchandising, CRM, and styling teams
- cross-channel traceability across ecommerce, email, and clienteling

This is the phase where operator-facing explainability and governance workflows become essential for routine business operations.

### Phase 4 - CM and advanced outfit intelligence

Must extend the explainability model to:

- CM configuration-aware recommendation logic
- premium-option and fabric-compatibility reasoning
- stylist-assisted and appointment-sensitive recommendation review

### Phase 5 - Optimization and platform expansion

Must mature:

- operational completeness monitoring for trace coverage
- deeper experiment comparison and optimization analysis
- durable auditability for broader regional and channel expansion

## Success metrics

Metrics should be finalized downstream, but this BR requires the business to measure at least:

- percentage of recommendation sets with usable recommendation set ID and trace ID
- percentage of recommendation sets with complete provenance for rules, campaigns, experiments, and overrides where applicable
- mean time for operators to diagnose a recommendation-quality issue or unexpected recommendation set
- percentage of routine recommendation investigations resolved without bespoke engineering reconstruction
- percentage of recommendation-related commercial outcomes attributable back to a recommendation set and variant context
- internal user trust and usability feedback from merchandising, analytics, and clienteling teams

## Constraints

- Explainability must remain privacy-aware and region-aware.
- Customer-facing explanation must remain bounded and must not expose sensitive internal reasoning.
- Explainability requirements must work across curated, rule-based, and AI-ranked recommendation sources rather than assuming a single decision model.
- Traceability must remain consistent across channels that share recommendation outputs.
- The business requirement should improve operational understanding without requiring that every internal user understand low-level model mechanics.

## Open decisions

- **Missing decision:** What retention period is required for recommendation traces and override history by region and use case?
- **Missing decision:** Which roles need access to full trace detail versus summarized explanation across merchandising, analytics, operations, support, CRM, and clienteling?
- **Missing decision:** What minimum completeness threshold should define an operationally acceptable trace for routine troubleshooting?
- **Missing decision:** Which customer-facing surfaces, if any, should receive a simplified explanation and what policy review is required before exposure?
- **Missing decision:** What audit or export obligations apply when recommendation-affecting data includes stylist notes, appointments, or other sensitive internal signals?

## Approval and milestone-gate notes

- BR stage approval mode is `AUTO_APPROVE_ALLOWED` per the business requirements board.
- Trigger source is issue-created automation for GitHub issue #85.
- This artifact is intended to unblock downstream feature breakdown for explainability, operator review, telemetry correlation, and governance workflows.
- Human review remains important in downstream stages for sensitive data-policy, CM, and role-based-access decisions, but those future checkpoints do not block completing this BR artifact.

## Recommended board update

Update `boards/business-requirements.md` for BR-011 to reflect work completed on `br/issue-85`, with the note that the artifact now defines recommendation traceability, operator review, audit, and troubleshooting requirements for downstream feature breakdown.
