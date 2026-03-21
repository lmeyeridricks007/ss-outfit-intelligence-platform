# BR-005: Curated plus AI recommendation model

## Purpose
Define the business requirements for blending curated looks, rule-based compatibility and governance logic, and AI ranking so downstream feature, architecture, and implementation work can preserve operator trust, explainability, and measurable optimization boundaries.

## Practical usage
Use this artifact to guide feature breakdown for recommendation source blending, precedence rules, fallback handling, governance workflows, ranking-policy design, and audit requirements across ecommerce, marketing, and clienteling surfaces.

## Trigger and approval context
- **Trigger:** issue-created automation from GitHub issue #142
- **Board item:** BR-005
- **Stage:** workflow:br
- **Approval mode:** AUTO_APPROVE_ALLOWED
- **Parent item:** none
- **Promotes to:** feature breakdown artifacts for source blending, ranking policy, governance controls, fallback design, and explainability workflows

## Source artifacts
- `docs/project/business-requirements.md`
- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/product-overview.md`
- `docs/project/roadmap.md`
- `boards/business-requirements.md`

## Requirement summary
The platform must blend three recommendation sources in one governed decision stack:
- **Curated:** merchandiser- or stylist-authored looks, bundles, priorities, and campaign inputs
- **Rule-based:** compatibility, policy, inventory, market, and business-control logic
- **AI-ranked:** model-driven ordering and scoring that uses customer, context, and commercial signals inside allowed boundaries

The blend must not behave like three equal peers competing without control. Rule-based constraints define the safe operating boundary, curated inputs remain a first-class source of recommendation truth, and AI ranking optimizes only within the set of candidates and ordering freedoms the business allows.

The output must remain:
- stylistically coherent
- operationally valid
- explainable to operators
- measurable through shared telemetry
- resilient when one source is weak, missing, or temporarily unavailable

## Business problem
SuitSupply wants recommendations that feel as tasteful and trustworthy as an in-store styling suggestion while still improving relevance and commercial performance through AI. That outcome is not possible if the platform depends only on generic model scoring, and it is not scalable if every recommendation is fully hand-curated.

Without an explicit blend model:
- AI may optimize for clicks or short-term conversion while violating brand coherence or operator intent
- curated looks may become static content that is disconnected from customer context and business measurement
- rules may be applied inconsistently across surfaces, creating trust and quality problems
- teams may not know whether a recommendation came from curation, compatibility logic, or model ranking
- fallback behavior may degrade into generic item similarity instead of safe complete-look guidance
- downstream teams may implement conflicting precedence rules in APIs, clients, and admin workflows

## Users and stakeholders
### Primary customer-facing users
- **Persona P1: Anchor-product shopper** who wants a coherent complete-look recommendation from a browsed item
- **Persona P2: Returning style-profile customer** who expects ranking to reflect history and preference without losing brand fit
- **Persona P3: Occasion-led shopper** who needs recommendations that feel intentional, not random or over-optimized

### Primary operators
- **Persona S1: In-store stylist or clienteling associate** who needs outputs they can trust, explain, and adapt during assisted selling
- **Persona S2: Merchandiser** who needs curation, rules, and campaigns to remain effective even as AI ranking matures
- **Persona S4: Product, analytics, and optimization team member** who needs measurable source mix behavior, traceability, and safe optimization controls

## Desired outcomes
- Curated looks remain a first-class recommendation source rather than an edge-case override.
- Rules reliably enforce compatibility, governance, inventory validity, and campaign constraints before customer exposure.
- AI ranking improves ordering and candidate selection quality without bypassing curated intent or governed boundaries.
- Operators can understand why a recommendation was shown and what source mix contributed to it.
- Recommendation sets degrade gracefully when curation, rules, customer signals, or model services are incomplete.
- Optimization focuses on complete-look quality, trust, and commercial value rather than click-through alone.

## Source roles in the blend
### Curated source role
Curated looks provide explicit styling taste, campaign intent, premium examples, and high-confidence brand-approved combinations. Curated inputs may:
- seed full looks or partial looks
- pin or prioritize specific products or grouped looks
- define campaign-led storylines or seasonal direction
- provide premium or high-formality examples where operator trust must be highest
- act as a safe fallback when other signals are weak

Curated inputs are not only marketing content. They are business-operational recommendation truth that should influence both candidate generation and ranking behavior.

### Rule-based source role
Rule-based logic provides the non-negotiable operating boundary. Rules may enforce:
- compatibility across category, color, pattern, formality, season, and price-tier relationships
- inventory, assortment, market, and sellability constraints
- governance controls such as exclusions, suppressions, mandatory inclusions, and campaign priorities
- RTW versus CM mode-specific compatibility boundaries
- privacy, consent, and profile-confidence usage boundaries where personal ranking is involved

Rules must distinguish between:
- **hard rules:** cannot be bypassed by curation or AI ranking
- **soft rules or preferences:** may guide scoring or tie-breaking without fully excluding candidates

### AI-ranked source role
AI ranking may use customer, context, product, and commercial signals to:
- prioritize the best eligible curated or non-curated candidates
- personalize ordering within a governed candidate pool
- balance multiple eligible looks or items for likely relevance
- improve bundle quality, attach likelihood, and overall recommendation usefulness

AI ranking is an optimization layer, not the source of business authority. It must not:
- violate hard compatibility or policy constraints
- suppress curated priorities without an explicit business rule allowing that behavior
- optimize solely for clicks if doing so harms outfit quality, brand coherence, or operator trust

## Blend model and precedence
### Precedence principles
- Safety, policy, and compatibility boundaries come before optimization.
- Curated truth has higher precedence than unconstrained model preference.
- AI ranking has freedom only inside the eligible candidate pool and any allowed ordering windows.
- Fallback behavior must preserve complete-look credibility rather than returning arbitrary item similarity.

### Required precedence order
The blend must apply recommendation logic in the following order:

1. **Eligibility and governance gate**
   - consent, profile-usage permission, market eligibility, inventory validity, assortment availability, and channel readiness
2. **Hard exclusions and hard compatibility rules**
   - products, looks, or combinations that violate policy, compatibility, premium-style, or operational constraints are removed
3. **Operator controls and curated priorities**
   - curated looks, pinned products, campaign boosts, mandatory inclusions, suppressions, and source-priority settings are applied
4. **AI ranking inside the allowed pool**
   - model scoring orders or selects among the remaining eligible candidates according to the ranking objective for the recommendation type and surface
5. **Deterministic fallback selection**
   - if the eligible set is too small, confidence is too weak, or ranking services are unavailable, the system returns the safest governed fallback set

### Precedence implications
- A curated look that violates a hard compatibility or inventory rule must not be shown unchanged; rules still win over curated content for customer-facing delivery.
- AI ranking may reorder curated candidates only when merchandising policy explicitly permits reordering within that curated set.
- When a campaign or operator pin exists, AI may rank around the pin but must not silently demote or remove it unless a stronger governing rule requires suppression.
- When no curated content exists for a request, the platform may still produce recommendations from rule-eligible catalog candidates, but those outputs remain subject to the same rule and explainability requirements.

## Candidate generation and ranking expectations
### Candidate generation requirements
Downstream work must preserve at least these candidate sources:
- curated full looks
- curated partial looks or anchor-product associations
- rule-eligible catalog candidates for complete-look completion
- campaign-prioritized products or looks
- context- or profile-eligible candidates where permitted

Candidate generation must keep source lineage visible so operators can tell whether a candidate originated from:
- curated-only input
- rule-generated catalog matching
- mixed curated plus catalog completion
- AI-selected from a governed eligible pool

### Ranking requirements
AI ranking must score or order candidates against business goals that are subordinate to governance. Ranking goals may include:
- complete-look coherence
- complementarity to the anchor or basket
- occasion, season, and context fit
- profile fit and wardrobe complementarity when identity confidence allows
- commercial usefulness such as attach likelihood or average order value contribution

Ranking must not optimize one narrow metric in isolation. In particular:
- click-through rate alone is not a sufficient objective
- margin alone is not a sufficient objective
- personalization alone is not a sufficient objective

The ranking objective must preserve balanced performance across:
- outfit credibility
- brand coherence
- governance compliance
- commercial value
- operator trust

## Guardrails and governance requirements
### Hard guardrails
- AI ranking must not surface products or looks excluded by policy, compatibility, inventory, market, or consent rules.
- AI ranking must not create unsupported category combinations that the compatibility layer cannot validate.
- Customer-facing outputs must not imply higher confidence than the source evidence supports.
- Personal or contextual ranking must not activate when consent, identity confidence, or context quality is below the required threshold.
- CM and premium recommendation scenarios must apply stricter compatibility and operator-trust rules than generic RTW attachment flows.

### Operator governance requirements
- Merchandisers must be able to control whether curated sets are fixed-order, reorderable-within-set, or reorderable-versus-rule-generated candidates.
- Operators must be able to pin, suppress, exclude, or campaign-prioritize looks or products without changing model code.
- Governance must define which recommendation contexts are curated-first, mixed-source, or AI-led within rules.
- Premium and formalwear use cases must support stronger curated control than routine attachment use cases where appropriate.
- Rule and curation changes must be auditable, reviewable, and attributable to an operator or system process.

### Explainability requirements
For every recommendation set, internal teams must be able to determine:
- what source mix contributed to the set
- which hard rules filtered or constrained candidates
- whether curated content was used, pinned, or used as fallback
- whether AI ranking reordered candidates and against which rationale category
- whether the final result reflects a degraded or fallback state

Customer-facing explanation, if used later, must remain high-level and privacy-safe. The business requirement is for internal operational explainability first.

## Fallback behavior
### Fallback principles
- Fallbacks must remain governed and credible, not generic.
- The system should prefer a smaller, safer recommendation set over a larger, weakly justified set.
- Fallback choice should preserve source transparency and auditability.

### Required fallback scenarios
#### Missing or sparse curated looks
- Use rule-eligible catalog candidates and AI ranking where enough compatibility evidence exists.
- If compatibility confidence is weak, return a narrower curated-adjacent or deterministic compatible set rather than a broad speculative result.

#### Weak customer or context signals
- Fall back to curated-first or rule-first default ranking behavior rather than forcing low-confidence personalization.
- Do not present personal or contextual outputs as if they were strongly individualized when confidence is weak.

#### AI ranking unavailable or degraded
- Return a deterministic governed ordering using curated priority, business rules, and compatibility-safe defaults.
- Preserve telemetry indicating that the result was non-model-ranked fallback output.

#### Candidate pool too small
- Return a smaller complete-look or complementary set, or the safest partial recommendation set, rather than padding with low-quality items.
- Surface the degraded-state flag for audit and optimization analysis.

#### Curated content conflicts with hard rules
- Suppress or repair the curated output through rule-safe substitution where policy allows.
- If safe repair is not possible, prefer no recommendation or a smaller safe set over showing a violating curated combination.

## Optimization boundaries
### What AI ranking is allowed to optimize
- recommendation relevance within governed candidates
- complete-look coherence and complementarity
- attach and basket expansion likelihood
- occasion and context fit
- repeat-customer usefulness where personal signals are permitted
- ordering efficiency among multiple eligible curated or compatible looks

### What AI ranking must not optimize past
- hard brand and premium-style boundaries
- compatibility and operational validity
- curated campaign or operator intent where explicit priority exists
- privacy, consent, and identity-confidence limits
- explainability requirements needed for operator trust

### Business optimization hierarchy
Downstream ranking-policy work must assume this hierarchy:
1. protect governance, compatibility, and operational validity
2. preserve brand coherence and operator trust
3. honor curated and campaign intent inside defined policy
4. improve complete-look quality and customer relevance
5. improve commercial outcomes such as conversion, attach, and average order value
6. optimize secondary interaction metrics such as clicks only when the higher-order objectives remain satisfied

## Surface implications
### Ecommerce PDP and cart
- Phase 1 flows should usually behave as mixed-source systems: curated where available, rule-safe completion always enforced, and AI ranking used to order eligible results.
- These surfaces must not silently degrade into pure similarity recommendations if the complete-look logic is weak.

### Homepage, inspiration, and occasion-led surfaces
- Curated and campaign-led priorities may carry more weight, but rule safety and explainability still apply.
- AI ranking may personalize or contextualize ordering only inside the approved operating envelope for the surface.

### Email and lifecycle marketing
- Weak identity, stale context, or limited explainability should push behavior toward safer curated or rule-default outputs.
- Personal ranking in outbound channels must remain consent-safe and freshness-aware.

### Clienteling and assisted selling
- Source transparency is especially important so stylists can understand whether an output is curated-led, rule-led, or AI-ranked.
- Premium and CM-oriented outputs may require curated-first or tightly governed mixed-source behavior.

## Phase and rollout expectations
### Phase 1: Core ecommerce RTW recommendations
In scope:
- explicit precedence between curated, rules, and AI ranking
- curated look ingestion as a first-class input
- hard compatibility and inventory filtering
- AI ranking bounded by governance on PDP and cart
- deterministic fallback behavior when curation or ranking is weak

Phase 1 emphasis:
- operational trust over aggressive optimization
- traceability and telemetry from the first release
- measurable source-mix behavior for later tuning

### Phase 2: Context and personalization expansion
In scope:
- stronger AI ranking using customer and contextual signals
- confidence-aware expansion of personal and contextual ranking
- richer fallback logic for weak identity or context

Boundary:
- expanded AI freedom still does not override curated priority or hard rules

### Phase 3: Operator scale and channel expansion
In scope:
- richer governance controls for source weighting and campaign control
- broader explainability and audit tooling
- consistent source-blend behavior across ecommerce, email, and clienteling

### Phase 4: CM depth and advanced optimization
In scope:
- tighter CM and premium-style rule enforcement
- curated-first or tightly governed mixed-source strategies for premium recommendation contexts
- more advanced model optimization only after operator trust and compatibility confidence are established

## Scope boundaries
### In scope
- business definition of curated, rule-based, and AI-ranked source roles
- required precedence and blend behavior across the decision stack
- guardrails for compatibility, governance, explainability, and operator trust
- fallback behavior when sources are sparse, weak, or unavailable
- optimization boundaries for AI ranking
- downstream implications for feature, architecture, telemetry, and governance work

### Out of scope
- final model architecture or algorithm choice
- exact API schema for source-mix payloads
- exact scoring formula or feature engineering details
- admin UI workflow design for merchandising controls
- final experiment design for every source-mix strategy

## Dependencies
- `BR-001` complete-look recommendation capability for outfit-centered decision quality
- `BR-002` multi-type recommendation support for ranking intent by recommendation type
- `BR-003` multi-surface delivery for source-blend consistency across channels
- `BR-004` RTW and CM support for stricter premium and CM governance boundaries
- `BR-008` product and inventory awareness for valid eligibility and compatibility filtering
- `BR-009` merchandising governance for curated controls, overrides, and campaign priority
- `BR-010` analytics and experimentation for source-mix telemetry and optimization measurement
- `BR-011` explainability and auditability for operator trust and troubleshooting
- `BR-012` identity and profile foundation for safe personal ranking expansion

## Constraints
- AI ranking must remain inside governed candidate boundaries rather than acting as an unrestricted recommendation engine.
- Curated recommendations cannot bypass hard safety, compatibility, or inventory constraints in customer-facing delivery.
- Source-blend behavior must stay consistent enough across surfaces that operators can reason about it and govern it.
- Early phases must prefer dependable recommendation quality and operator trust over maximum personalization depth.
- Explainability must be sufficient for internal troubleshooting from the first production release.

## Assumptions
- Merchandising teams will maintain curated looks, pinned priorities, and campaign controls as part of normal operations.
- Compatibility and inventory services can provide dependable hard-rule filtering before ranking decisions are finalized.
- Downstream contracts can carry source lineage, fallback state, and trace metadata at recommendation-set level.
- Later personalization work will have confidence-aware identity and consent handling rather than assuming every request is safe for personal ranking.
- The roadmap sequence remains RTW-first in Phase 1, with deeper optimization and CM nuance expanding later.

## Missing decisions
- Missing decision: which surfaces should be strictly curated-first versus mixed-source by default in the first production releases.
- Missing decision: when AI ranking may reorder curated looks versus only choose among curated-approved candidates.
- Missing decision: what minimum compatibility or confidence threshold requires suppressing a recommendation rather than returning a degraded partial set.
- Missing decision: which premium or formalwear contexts require curated-only control until stronger operator trust is established.
- Missing decision: how source-mix behavior should be exposed in operator tooling without overwhelming merchandisers and stylists.

## Downstream implications
- Feature breakdown work must define source-blend behaviors separately from recommendation-type taxonomy so intent and source governance do not become conflated.
- Architecture work must preserve a decision pipeline that applies hard-rule filtering before ranking and returns source lineage with the recommendation set.
- Delivery work must support degraded-state handling and must not flatten source distinctions into one opaque ordered list.
- Governance tooling must let operators control pins, suppressions, curated priorities, and allowed AI freedom by surface or use case.
- Analytics work must measure performance by source mix, fallback mode, and recommendation type so optimization does not reward unsafe behavior.

## Review snapshot
Trigger: issue-created automation from GitHub issue #142.

Disposition: APPROVED

Scores:
- Clarity: 5
- Completeness: 5
- Implementation Readiness: 4
- Consistency With Standards: 5
- Correctness Of Dependencies: 5
- Automation Safety: 5
- Average: 4.8

Confidence: HIGH - the source business requirements, vision, goals, product overview, and roadmap provide enough context to define source roles, precedence, guardrails, fallback behavior, and optimization boundaries without inventing implementation details.

Blocking issues:
- None.

Required edits:
- None for BR-stage promotion. Downstream feature and architecture work should resolve the listed missing decisions before locking source-weighting and operator-control details.

Approval-mode interpretation:
- Board item is `AUTO_APPROVE_ALLOWED`, so this review is eligible for `APPROVED`.

Upstream artifacts to update:
- None.

Recommended board update and note:
- Move BR-005 to `DONE` once the artifact is committed and branch push evidence exists for this autonomous run.

Remaining human, milestone-gate, merge, or CI requirements:
- No human gate blocks completion of this BR documentation run.
- Later-stage feature, architecture, and implementation work still need their own review and evidence, especially for source-weighting decisions in premium and CM contexts.
