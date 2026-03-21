# BR-005: Curated plus AI recommendation model

## 1. Metadata

- BR ID: BR-005
- Issue: #112
- Stage: workflow:br
- Approval Mode: AUTO_APPROVE_ALLOWED
- Trigger: issue-created automation for workflow:br
- Parent Item: none
- Downstream stage: workflow:feature-spec
- Promotes to: boards/features.md
- Phase: Phase 1 - Foundation and first recommendation loop
- Upstream Sources:
  - docs/project/business-requirements.md
  - docs/project/vision.md
  - docs/project/goals.md
- Related Inputs:
  - Curated look model
  - rule-based compatibility
  - AI ranking goals
  - merchandising governance
  - docs/project/standards.md
- Downstream Consumers:
  - feature breakdown artifacts for recommendation-source blending, override behavior, and fallback logic
  - architecture and API contract work for decision traceability, source attribution, and ranking boundaries
  - operational planning for merchandising controls, experimentation, and optimization governance

## 2. Purpose

Define the business requirements for a blended recommendation model in which curated looks, rule-based compatibility, and AI-ranked ordering work together as one governed recommendation capability. This BR establishes how the sources should contribute, what each source is responsible for, where optimization must stop, and what controls are required so downstream work can improve relevance without weakening brand styling integrity or merchandising governance.

## 3. Scope summary

The platform must blend three recommendation sources instead of treating them as competing alternatives:

- **Curated** sources encode SuitSupply styling point of view, campaign intent, and explicitly authored looks.
- **Rule-based** sources protect compatibility, eligibility, and operational validity.
- **AI-ranked** sources optimize ordering and selection within governed boundaries using observed behavior and measurable outcomes.

This BR defines:
- the business purpose of each source in the blend
- the intended decision order between curated, rule-based, and AI-ranked logic
- the controls and override patterns that keep the blend governable
- the optimization boundaries that AI ranking must respect
- the phase-based rollout assumptions for introducing stronger AI influence safely

This BR does not define:
- specific model architectures, training pipelines, or feature engineering details
- low-level rule syntax or look-authoring UI workflows
- exact scoring formulas or final API schema fields
- the full experimentation program beyond the business constraints it must follow

## 4. Business problem and opportunity

SuitSupply already has meaningful styling knowledge in curated looks and merchandising judgment, but that knowledge alone does not scale across every customer journey, surface, and context. At the same time, pure algorithmic ranking is not acceptable as a first principle because recommendations must remain stylistically coherent, brand-safe, and operationally valid.

The business problem is therefore not whether curated or AI-driven recommendations should win. The real need is to blend them responsibly:

- curated looks provide trusted styling patterns and campaign direction
- rule-based compatibility prevents invalid or off-brand combinations
- AI ranking helps decide which valid options are most relevant for the active customer, surface, and context

Without this blend:
- recommendations become too manual and difficult to scale
- or they become too opaque and risky for merchandising teams to trust
- or they optimize narrow metrics such as click-through at the expense of look coherence and brand integrity

The opportunity is to create a recommendation model that:
- preserves SuitSupply's styling point of view
- scales curation through reusable look logic and governed rules
- improves performance through data-driven ranking where it is safe to do so
- gives internal teams explicit levers over what AI can and cannot optimize

## 5. Business value and intended outcomes

### 5.1 Customer-facing value

The blended model must help customers:
1. receive complete-look recommendations that feel intentional rather than random
2. see recommendations that remain compatible with the anchor product, occasion, and styling context
3. discover relevant alternatives and attachments without losing trust in the styling quality
4. receive better ordering of valid options as customer and journey signals improve

### 5.2 Internal business value

The blended model must help internal teams:
- scale merchandising expertise across more surfaces without manually curating every result
- protect brand and compatibility standards through explicit governance controls
- use AI to improve performance where curated and rule-based sources alone cannot prioritize effectively
- compare business lift from curation, rules, and ranking changes without losing traceability

### 5.3 Why the blend matters

The business value comes from the combination, not any single source:

- **Curated without ranking** can be high quality but static, harder to personalize, and less adaptive.
- **Rules without curation** can be safe but generic, producing technically valid yet uninspiring outfit suggestions.
- **AI without curated and rule-based boundaries** can overfit to short-term behavior, over-prioritize popularity, or surface combinations that weaken brand styling integrity.

## 6. Source roles in the blended model

### 6.1 Curated source role

Curated logic must represent explicit merchandising and styling intent. It should be used to:
- author complete looks and approved style patterns
- define campaign-led or season-led emphasis
- seed high-confidence outfit structures for important anchors, occasions, or assortments
- protect premium presentation where brand point of view matters strongly

Curated logic must not be treated as:
- a replacement for hard compatibility checks
- proof that every product in a look remains eligible in every context
- a guarantee that the same curated output should appear in the same order for every customer and surface

### 6.2 Rule-based source role

Rule-based logic must enforce hard and soft boundaries around recommendation validity. It should be used to:
- exclude incompatible product combinations
- enforce inventory, assortment, regional, and operational eligibility
- preserve required merchandising priorities and suppression rules
- encode source-specific governance such as premium guardrails or campaign precedence

Rule-based logic must not be treated as:
- a substitute for curation when style point of view is needed
- a personalization system on its own
- permission for AI ranking to ignore stronger governance or compatibility constraints

### 6.3 AI-ranked source role

AI ranking must optimize the ordering and selection of already-governed candidates. It should be used to:
- rank eligible recommendations based on customer, context, and journey relevance
- choose among multiple valid curated or rule-generated candidates
- improve attachment, conversion, and engagement outcomes over static ordering
- learn which valid looks or product combinations perform better on different surfaces or for different cohorts

AI ranking must not be used to:
- override hard compatibility rules
- surface combinations excluded by merchandising governance
- optimize solely for clicks or order value when that would reduce outfit coherence or brand trust
- replace explicit curated placement where merchandising has intentionally pinned or protected a result

## 7. Blend order and decisioning expectations

### 7.1 Required decision sequence

Downstream features and architecture must preserve this business interpretation of the blend:

1. **Source candidate generation:** curated looks, rule-driven retrieval logic, or both produce candidate items or looks.
2. **Eligibility and compatibility filtering:** rule-based controls remove invalid, suppressed, or operationally unsafe options.
3. **Governance and merchandising controls:** overrides, pinned placements, campaign priorities, and protected content are applied.
4. **AI-ranked ordering and selection:** the model ranks the remaining eligible candidates within the allowed boundaries.
5. **Surface assembly and fallback selection:** the system assembles the recommendation set and falls back to safer governed defaults if ranking inputs are weak.

### 7.2 Practical interpretation

This sequence means:
- AI ranking happens after compatibility and governance boundaries are known
- curated content can participate as candidates, as pinned outputs, or as protected anchors in the set
- rule-based logic is both a filter and a control layer, not just a retrieval mechanism
- the final set may blend curated and non-curated candidates, but only after they pass shared governance

### 7.3 Fallback rule

When signals are incomplete, model confidence is low, or policy constraints limit personalization, the platform must prefer safer, explainable outputs such as:
- curated looks with governed ordering
- rule-based compatible complements
- surface-specific defaults that preserve styling quality and operational validity

## 8. Functional business requirements

### 8.1 Blended-source requirement

The platform must support recommendation sets that can combine curated looks, rule-based compatibility logic, and AI-ranked ordering rather than forcing a single recommendation source for every surface or journey.

### 8.2 Source attribution requirement

Each recommendation set must preserve enough source attribution to distinguish whether a result came from curated input, rule-based generation, AI-ranked ordering, or a governed blend of those sources.

### 8.3 Governance precedence requirement

Hard compatibility rules, suppression rules, inventory and eligibility constraints, and explicit merchandising overrides must take precedence over AI optimization.

### 8.4 Curated-protection requirement

The platform must support the ability for merchandising teams to pin, protect, or prioritize curated looks or specific components when brand presentation or campaign intent requires it.

### 8.5 AI-optimization requirement

AI ranking must optimize among eligible candidates for relevance and business value, but only within the boundaries created by compatibility logic, governance controls, and protected curated content.

### 8.6 Fallback requirement

When AI-ranked ordering is unavailable, low-confidence, or disallowed by policy or missing inputs, the platform must fall back to governed curated and rule-based recommendation behavior instead of returning opaque or weakly supported outputs.

### 8.7 Explainability requirement

Internal teams must be able to understand why a recommendation was surfaced or ordered, including the role of curated input, rule-based filtering, overrides, and AI ranking.

### 8.8 Optimization-boundary requirement

Downstream designs must define optimization goals that improve recommendation performance without allowing AI ranking to trade away styling coherence, compatibility safety, or merchandising governance.

## 9. Controls and governance expectations

### 9.1 Merchandising control model

Merchandising and styling teams must be able to:
- author curated looks and source priorities
- define rule-based compatibility and suppression boundaries
- set campaign emphasis or protected placements
- review how AI ranking changed the ordering of otherwise eligible candidates
- override recommendation behavior when quality, brand, or business needs require it

### 9.2 Governance boundaries for AI

AI ranking must operate inside explicit controls for:
- hard exclusions and mandatory compatibility
- protected curated placements
- category and assortment boundaries
- regional, consent, and policy constraints
- premium or brand-sensitive scenarios that require extra governance

### 9.3 Auditability expectations

The blended model must support auditability for:
- what curated source or look contributed to a recommendation
- which rule-based filters or overrides were applied
- whether AI ranking reordered or selected candidates
- which experiment, campaign, or variant context influenced the final set

### 9.4 Human-in-the-loop note

Human review remains especially important for major changes to:
- curated source priorities
- hard compatibility rule sets
- premium or brand-sensitive ranking objectives
- overrides that materially change recommendation behavior across surfaces

This does not block autonomous completion of the BR artifact, but it must remain visible for downstream governance design.

## 10. Optimization boundaries and non-goals

### 10.1 What AI ranking is allowed to optimize

Within governed boundaries, AI ranking may optimize for:
- recommendation relevance to the active customer or session
- attachment and complete-look engagement
- conversion and AOV lift from valid complementary items
- surface-specific usefulness such as PDP or cart actionability
- measurable improvement over static ordering baselines

### 10.2 What AI ranking must not optimize away

AI ranking must not degrade:
- complete-look coherence
- compatibility and purchasability
- brand styling integrity
- required campaign and merchandising intent
- customer trust through unstable, hard-to-explain ordering changes

### 10.3 Explicit non-goals for this BR

This BR does not authorize:
- unconstrained end-to-end model control over recommendation selection
- removing curated authoring because ranking exists
- replacing governance review with performance metrics alone
- optimizing on short-term metrics without preserving traceability and explainability

## 11. Surface and phase expectations

### 11.1 Phase 1 expectations

Phase 1 should establish the first governed blend on RTW-first ecommerce surfaces such as PDP and cart:
- curated looks and high-confidence rule-based compatibility provide the starting foundation
- AI ranking can be introduced in bounded ways to order eligible candidates or select among valid complements
- the emphasis is on safe performance lift, not full personalization depth

### 11.2 Phase 2 expectations

Phase 2 should expand the role of AI ranking by introducing richer customer and context signals:
- stronger ordering for returning and contextual sessions
- more adaptive prioritization among curated and rule-valid candidates
- clearer measurement of uplift versus the Phase 1 baseline

### 11.3 Phase 3 expectations

Phase 3 should strengthen internal controls around the blend:
- merchandising workflows for source priorities and overrides
- experiment controls for ranking strategies
- broader multi-channel activation where source attribution and governance remain visible

### 11.4 Phase 4 expectations

Phase 4 should extend the governed blend into more complex CM and premium scenarios only when compatibility, governance, and explanation depth are strong enough to support higher-risk styling decisions.

## 12. Success measures

### 12.1 Commercial measures

- conversion uplift on recommendation-influenced PDP and cart sessions
- AOV and attachment lift from complete-look recommendations
- measurable improvement from ranked ordering versus static governed baselines

### 12.2 Quality and governance measures

- percentage of recommendation sets that remain fully compatible after rule filtering
- percentage of recommendation sets with valid source attribution and decision traceability
- override frequency and reasons, indicating where the blend still needs improvement
- rate of recommendation-quality issues caused by ranking conflicting with curation or rules

### 12.3 Operational measures

- coverage of curated looks for priority anchors, campaigns, or occasions
- latency and reliability of governed candidate selection and ranking
- experiment visibility by surface, variant, and source blend
- ability to compare performance of curated-only, governed static, and AI-ranked blends

## 13. Assumptions

- Curated looks and compatibility rules provide the safest initial foundation for Phase 1.
- AI ranking should enter the first release as a bounded optimization layer rather than an unconstrained decision maker.
- Merchandising teams can define enough protected looks, overrides, and governance rules to keep the blend trustworthy.
- Downstream telemetry and traceability work can preserve the source and control context needed to evaluate the blend responsibly.

## 14. Open questions and non-blocking follow-ups

- Which recommendation surfaces should allow pinned curated placements versus fully rankable eligible sets?
- What minimum level of model confidence should trigger fallback to curated and rule-based defaults?
- Which business objectives should be primary for ranking on PDP versus cart when they conflict?
- How should campaign-specific curation interact with customer-specific ranking when both are strong signals?
- Which premium or CM scenarios should require stricter human review before stronger AI influence is allowed?

## 15. Review pass

Trigger: issue-created automation

Artifact under review: docs/project/br/br-005-curated-plus-ai-recommendation-model.md

Approval mode: AUTO_APPROVE_ALLOWED

Blockers: none

Required edits: none

Scored dimensions:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5

Overall disposition: APPROVED

Confidence: HIGH

Approval-mode interpretation:
- This artifact exceeds the promotion threshold in the repo rubric.
- AUTO_APPROVE_ALLOWED is explicitly recorded on the board and in this artifact.
- No milestone human gate blocks completing this BR artifact, though downstream ranking, experimentation, and premium-governance work must preserve the optimization boundaries documented here.

Residual risks and open questions:
- Exact ranking-objective trade-offs remain a downstream feature and architecture decision.
- The confidence thresholds and fallback heuristics for AI-ranked ordering still need more explicit definition in later artifacts.
