# Feature Request To Business Requirements

## Objective
Turn an incoming feature request into a business-requirements artifact aligned to the AI Outfit Intelligence Platform context. The output must be specific enough that a feature breakdown can be done without guessing scope or success criteria.

## Required Inputs
- Request summary (issue body, email, or structured intake)
- Project context: `docs/project/product-overview.md`, roadmap, capability map (if present)
- Personas (from project docs or explicit in request)
- Goals and roadmap alignment
- Approval mode for the BR stage if already defined (else default HUMAN_REQUIRED and note as open decision)

## Section-by-section guidance
- **Problem statement:** A complete statement of who has the problem, what the problem is, and why it matters now. Use as much detail as needed; avoid jargon. Use product/domain terms from `docs/project/glossary.md` (e.g. look, outfit, recommendation, merchandising rule).
- **Target users:** All relevant persona(s) or roles. If the request is vague ("customers"), narrow to the full set of concrete segments (e.g. "PDP visitors on mobile", "stylists in clienteling"). Do not limit to a single user type when the scope implies more.
- **Business value:** Complete outcomes and, where possible, measurable impact (e.g. conversion, engagement, time-to-outfit). If metrics are unknown, say "Metrics TBD" and add to Open decisions.
- **Scope boundaries:** Complete and explicit in-scope list (e.g. PDP outfit recommendations for RTW only; cart cross-sell; admin rule editor) and out-of-scope list (e.g. email recommendations out of scope for v1). Cover all surfaces and capabilities implied by the request; without this, downstream work will expand or contract arbitrarily.
- **RTW and CM considerations:** If the feature touches both Ready-to-Wear and Custom Made, state all relevant differences (e.g. immediacy vs appointment, product attributes). If only one, state it. Omit only if clearly not applicable.
- **Success metrics:** The full set of measurable criteria (e.g. click-through rate on recommendation module, time to complete look). Include every metric the business will use to judge success; prefer metrics that tie to recommendation telemetry (impression, click, add-to-cart, purchase per `docs/project/data-standards.md`).
- **Open decisions:** List every unresolved question (e.g. "Which surfaces in scope: PDP only or PDP + cart?"). Mark as "Missing decision" so the board or human can resolve; do not invent answers.
- **Approval / milestone-gate notes:** State whether BR stage is HUMAN_REQUIRED or AUTO_APPROVE_ALLOWED; if there is a known milestone gate (e.g. "Human review at UI readiness before backend"), note it here.

## Recommendation and channel mapping
Tie the request to all that apply: recommendation type (outfit, cross-sell, upsell, contextual, personal, style bundle), consuming surface (PDP, cart, homepage, email, clienteling, admin), and data source (curated, rule-based, AI-ranked). Use project terminology (look, outfit, merchandising rule, campaign) from the glossary.

## Anti-patterns (avoid)
- Vague scope ("improve recommendations") without boundaries or surfaces.
- Invented metrics or targets without source or "TBD".
- Skipping Open decisions when the request leaves options ambiguous.
- Including technical architecture (APIs, components, tech stack); keep BR product/business only.
- Copy-pasting the request as the problem statement; synthesize and narrow.

## Required Output
- Problem statement, target users, business value, scope boundaries (in/out), RTW/CM considerations, success metrics, open decisions, approval/milestone-gate notes, recommended board update.

## Quality Rules
- Do not produce technical architecture.
- Tie the request to recommendation types and channels (see above).
- Call out missing decisions in Open decisions; do not invent them.
- If the latest human feedback rejected an earlier BR draft, incorporate those comments into the revised requirement and note any upstream assumptions that changed.

## Board Instruction
Update `boards/business-requirements.md`: add or update row with status (TODO or IN_PROGRESS), owner, reviewer, Approval Mode, link to issue/source. If approval mode is unknown, set HUMAN_REQUIRED and add "Approval mode for BR stage TBD" to Notes.

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: produce the BR artifact, update the board row, then **commit and push** the branch (e.g. `br/issue-<number>-<slug>`). Do not stop for human approval or "Mark as ready." Allow PR creation. Use non-blocking statuses so the run completes (e.g. IN_PROGRESS or NEEDS_REVIEW as appropriate).

## Example (snippet)
**Problem statement:** Merchandisers need to control which products appear in PDP "Complete the look" for RTW so that looks align with campaign and inventory. Today, recommendations are fully system-driven and cannot be constrained by rule.

**Scope boundaries:** In scope: PDP RTW complete-the-look module; admin UI to define inclusion/exclusion rules per campaign or category. Out of scope: cart recommendations, email, CM flows.

**Success metrics:** Time to configure rules for a new campaign (target TBD); reduction in manual overrides (baseline TBD). **Open decisions:** Exact KPIs and baselines; whether rules are global or per-campaign.

## Output template
```markdown
## Business requirements: [Feature/request title]

**Problem statement:** [Complete statement of problem, who, what, why]

**Target users:** [List]

**Business value:** [Metrics and outcomes]

**Scope boundaries:** In scope: [...]. Out of scope: [...].

**RTW / CM considerations:** [If applicable]

**Success metrics:** [Measurable]

**Open decisions:** [List; mark as missing decision if unknown]

**Approval / milestone-gate notes:** [e.g. BR stage AUTO_APPROVE_ALLOWED until first human gate at UI readiness]

**Recommended board update:** Add/update row in `boards/business-requirements.md`: Status TODO | IN_PROGRESS, Approval Mode [HUMAN_REQUIRED | AUTO_APPROVE_ALLOWED], link to issue/source.
```
