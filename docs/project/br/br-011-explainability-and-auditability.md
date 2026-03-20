# BR-011: Explainability and auditability

## Document control

- BR ID: BR-011
- GitHub issue: #60
- Stage: workflow:br
- Status: In PR
- Trigger: issue-created automation
- Parent requirement: `docs/project/business-requirements.md` BR-11
- Source artifacts:
  - `docs/project/vision.md`
  - `docs/project/goals.md`
  - `docs/project/business-requirements.md`
  - `docs/project/data-standards.md`
  - `docs/project/standards.md`

## Problem statement

SuitSupply needs recommendation outputs that internal teams can trust, govern, and debug without turning the customer experience into a dump of opaque system logic. The platform blends curated looks, compatibility rules, campaign priorities, experiments, and AI ranking across ecommerce, email, and clienteling surfaces. Without a clear business requirement for explainability and auditability, merchandisers, stylists, analysts, and governance stakeholders cannot reliably answer why a recommendation set was produced, whether it respected brand and policy constraints, or which change caused a commercial or operational outcome. This is especially important when recommendations span RTW and CM journeys, use customer and context signals, and are optimized over time.

## Target users

### Primary internal users

- Merchandisers who need to understand why a look or item appeared, was suppressed, or was prioritized.
- Analytics and optimization teams who need traceable recommendation context for experiments, performance measurement, and regression analysis.
- Operations and support teams who need to debug recommendation behavior and investigate incidents.
- Product and governance stakeholders who need audit evidence that recommendation behavior stayed within policy, consent, and brand guardrails.

### Secondary internal users

- Stylists and clienteling teams who need enough explanation to trust and use recommendations in customer conversations.
- Campaign managers who need to understand how campaign logic influenced recommendation outputs.

### External users

- Customers who may receive high-level, customer-safe explanation cues that improve trust and actionability without exposing sensitive internal logic or profile reasoning.

## Business value

- Improves merchandiser trust by making recommendation decisions reviewable instead of opaque.
- Supports safe optimization by linking performance outcomes to rules, campaigns, experiments, and ranking context.
- Reduces operational debugging time when recommendation behavior changes unexpectedly.
- Strengthens governance by making recommendation-impacting decisions observable, reviewable, and attributable.
- Preserves customer trust by limiting customer-facing explanations to safe, useful reasons instead of internal scoring or sensitive personal inferences.

## Recommendation and channel mapping

- Recommendation types in scope: outfit, cross-sell, upsell, occasion-based, contextual, personal, and style bundle recommendations.
- Recommendation sources in scope: curated looks, rule-based constraints and overrides, campaign logic, experiment treatments, and AI-ranked ordering.
- Consuming surfaces in scope: PDP, cart, homepage, email, clienteling, and internal admin or operational views where recommendation context is reviewed.

## Scope boundaries

### In scope

- Business requirements for traceability across recommendation generation, filtering, prioritization, ranking, and delivery.
- Explanation boundaries for internal users versus customer-facing surfaces.
- Audit context for governed entities including rules, campaigns, experiments, ranking decisions, and recommendation sets.
- Requirements for using auditability to support governance, incident investigation, optimization analysis, and operational support.
- Requirements that apply across RTW and CM recommendation flows where recommendation logic or user expectations differ.

### Out of scope

- Detailed technical design for storage models, APIs, event schemas, or UI implementations.
- A promise that every customer-facing surface must show an explanation message on first release.
- Exposing raw model scores, internal experiment labels, or sensitive customer attributes directly to customers.
- Replacing approval, legal review, or policy decisions with automated explanations alone.

## RTW and CM considerations

- RTW recommendations must be explainable in ways that support immediate purchase journeys, inventory-aware reasoning, and fast operational debugging.
- CM recommendations may require stronger internal traceability because compatibility, styling constraints, appointment context, and premium upsell logic can be more nuanced and higher touch.
- Customer-facing explanations should remain simple in both modes, but internal traceability must preserve whether a decision came from RTW, CM, or shared logic so teams can investigate the correct workflow.

## Business requirements

### BR-011.1 Recommendation-set traceability

Each recommendation set must be traceable to the business and decision context that produced it, including:

- recommendation set ID and trace ID
- consuming surface and channel
- recommendation type
- anchor product, look, intent, or journey context where applicable
- whether the result came from curated, rule-based, AI-ranked, or blended logic

This traceability must support downstream analysis of impression, click, add-to-cart, purchase, dismiss, and override outcomes.

### BR-011.2 Rule and eligibility traceability

The platform must preserve traceability for recommendation rules and eligibility decisions so internal users can understand:

- which rules or compatibility constraints affected the result
- which items or looks were excluded and why
- which overrides were applied
- when hard safety or brand constraints took precedence over ranking

### BR-011.3 Campaign traceability

The platform must preserve campaign context whenever campaign logic influences recommendation behavior, including campaign identity, priority, activation context, and whether campaign logic boosted, constrained, or replaced default recommendations.

### BR-011.4 Experiment traceability

The platform must preserve experiment and variant context for recommendation decisions so analytics and optimization teams can attribute outcomes to the correct treatment and investigate unexpected behavior without ambiguity.

### BR-011.5 Ranking traceability

The platform must preserve sufficient ranking context for internal analysis of why recommendation candidates were ordered as they were. At the business-requirement level, this means internal users must be able to see the factors, rule interactions, and treatment context that materially influenced ranking, without requiring that raw model internals be shown to every audience.

### BR-011.6 Explanation boundaries by audience

The platform must separate what is explainable internally from what may be exposed on customer-facing surfaces.

#### Internal explanation boundary

Internal users may access detailed recommendation context needed for merchandising governance, operational debugging, and optimization analysis, including governed rule, campaign, experiment, suppression, and ranking-factor context, subject to role-appropriate data access policy.

#### Customer-facing explanation boundary

Customer-facing surfaces may expose concise, useful explanation cues such as compatibility, occasion relevance, seasonal relevance, or broad preference alignment when those explanations are:

- understandable without internal tooling knowledge
- safe for the region and consent context
- free of sensitive profile reasoning
- free of internal scores, hidden business logic, or experimental labeling that would confuse or mislead customers

#### Never expose to customers

The platform must not expose customer-facing explanations that reveal:

- sensitive personal or inferred profile reasoning
- internal scoring, ranking weights, or confidence values
- hidden rule thresholds, suppression logic, or campaign priority mechanics
- identity resolution confidence or source-system conflicts
- internal experiment assignment unless the business intentionally designs that disclosure

### BR-011.7 Auditability for governed artifacts

Changes to governed recommendation artifacts must be auditable. For business purposes, this includes preserving who changed a governed artifact, when it changed, what changed, and the stated reason or business context for the change for:

- curated looks
- compatibility or exclusion rules
- campaign configuration that affects recommendations
- experiment setup that changes recommendation behavior

### BR-011.8 Governance support

Auditability must support governance outcomes, including:

- verifying that recommendation behavior remained within merchandising and brand guardrails
- investigating whether consent, suppression, or regional policy constraints were respected
- explaining significant commercial changes after a rule, campaign, or experiment update
- enabling reviewable change history for operational and stakeholder accountability
- supporting controlled rollback or remediation decisions when a governed change causes harm

### BR-011.9 Cross-phase operational debugging

The platform must preserve enough trace and audit context that internal teams can debug recommendation issues across ingestion, decisioning, delivery, and measurement phases without guessing which layer changed the observed behavior.

## Traceability matrix

| Decision area | What must be traceable | Primary internal consumers | Governance purpose |
|---|---|---|---|
| Recommendation set production | Recommendation set ID, trace ID, recommendation type, surface, channel, anchor context | Analytics, support, product | Reconstruct what was delivered and where |
| Rules and constraints | Applied rules, suppressed items, override context, hard-constraint precedence | Merchandising, support | Verify guardrail compliance and diagnose exclusions |
| Campaign influence | Campaign ID, campaign priority context, activation influence | Merchandising, campaign managers, analytics | Confirm campaign intent and attribution |
| Experiments | Experiment ID, variant, treatment influence | Analytics, product | Attribute lift, regressions, and anomalies |
| Ranking | Material ranking factors and interaction with rules or campaigns | Merchandising, analytics | Explain ordering changes and safe optimization |
| Outcome telemetry | Impression, click, save, add-to-cart, purchase, dismiss, override linked to trace context | Analytics, product | Connect behavior and business outcomes back to decisions |
| Artifact changes | Author, timestamp, reason, changed governed artifact | Governance, product, merchandising | Establish accountability and change history |

## Explanation boundary matrix

| Audience | May be exposed | Must not be exposed |
|---|---|---|
| Merchandisers and governed internal users | Rule, campaign, experiment, suppression, ranking-factor, and override context needed to manage recommendation quality | Data beyond role entitlement or policy-approved access |
| Stylists and clienteling users | Enough context to use and trust recommendations in customer conversations, including high-level compatibility or occasion rationale | Sensitive profile reasoning or internal scoring detail not needed for service workflows |
| Customers | High-level reasons such as "pairs well with this suit," "works for this occasion," or "relevant for the season" when policy-safe | Sensitive personal inferences, raw scores, hidden rule logic, experiment labels, or internal governance metadata |

## Success measures

- Internal teams can reliably reconstruct why a recommendation set was produced for operational analysis.
- Recommendation outcomes can be attributed to relevant rule, campaign, experiment, and ranking context.
- Customer-facing explanations remain understandable and useful without exposing sensitive or confusing internal logic.
- Governance stakeholders can review change history and recommendation decision context when investigating incidents, regressions, or policy questions.
- The percentage of recommendation sets with full trace context becomes a tracked operational quality measure.

## Constraints

- Explainability must respect privacy, consent, and regional policy constraints.
- Customer trust is improved by clear reasons, not by exposing every internal system detail.
- Auditability must cover blended recommendation logic, not only AI ranking.
- Governance needs must be met across all recommendation phases, not only after delivery.

## Open decisions

- Missing decision: which customer-facing surfaces, if any, must display explanation text in the first delivery phase versus only preserving the capability internally.
- Missing decision: what approval or review workflow should apply to especially sensitive governed changes such as CM recommendation rules or stylist-note usage.
- Missing decision: how long trace and audit records must be retained for governance, support, and analytical use cases.
- Missing decision: which internal roles may access full ranking-factor and suppression detail versus a redacted explanation view.

## Approval and milestone notes

- Approval mode for this BR stage is treated as autonomous for this issue run, consistent with the board prompt and autonomous automation instructions in this repository.
- No additional human gate blocks completion of this BR artifact in the current autonomous run; any follow-up policy decisions remain non-blocking notes for later stages.

## Recommended board update

Update `boards/business-requirements.md` for BR-011 / GitHub issue #60 with a non-blocking status. Use `In PR` once the branch is pushed and include a note that the artifact captures traceability requirements, explanation boundaries, and governance-supporting auditability, with open decisions retained as non-blocking follow-ups.
