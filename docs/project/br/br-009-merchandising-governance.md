# BR-009 Merchandising governance

| Field | Value |
|-------|-------|
| Board Item ID | BR-009 |
| GitHub Issue | #58 |
| Parent Item | None |
| Stage | workflow:br |
| Trigger Source | `docs/project/business-requirements.md` (BR-9), `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/roadmap.md`, `docs/project/standards.md` |
| Output Artifact | `docs/project/br/br-009-merchandising-governance.md` |
| Downstream Stage | Feature breakdown (`FEAT-TBD`) |

## 1. Problem statement

SuitSupply needs a business governance model for recommendation decisions so curated looks, overrides, campaign priorities, and eligibility rules can scale beyond one-off manual interventions. As recommendation activation expands in Phase 3 to email, clienteling, and broader internal teams, merchandising must be able to shape outcomes without relying on engineering for routine changes, while analytics and operations retain enough traceability to explain why a look or recommendation set was shown.

Without explicit governance, the platform risks conflicting campaign rules, stale curated looks, inconsistent regional behavior, weak override discipline, and limited auditability when teams need to understand commercial impact or investigate recommendation incidents. Merchandising governance is therefore required to preserve brand control, protect recommendation quality, and make cross-channel activation operationally safe.

## 2. Target users and stakeholders

### Primary internal users

- Merchandisers responsible for curated looks, assortment strategy, and brand standards.
- Campaign and CRM teams activating recommendations for launches, promotions, and editorial moments.
- Clienteling and styling leads who depend on governed recommendation outputs for assisted selling.

### Secondary internal stakeholders

- Analytics and optimization teams measuring recommendation performance, override usage, and campaign impact.
- Product and operations teams responsible for operating reliability and change control.
- Compliance, regional business owners, and other governance stakeholders who may review policy-sensitive decisions.

## 3. Business value

This requirement supports the following business outcomes:

- Preserve brand and merchandising control as recommendation usage expands across more channels and teams.
- Reduce time to launch, tune, and retire campaign-led recommendation behavior without engineering intervention for routine changes.
- Prevent conflicting or stale recommendation decisions that could hurt conversion, attachment, or trust in internal tooling.
- Give analytics teams auditable decision context so performance changes can be tied back to curated looks, overrides, campaigns, and eligibility logic.
- Establish a shared operating model for cross-functional recommendation governance instead of ad hoc process by team or channel.

## 4. Recommendation and channel mapping

### Recommendation types influenced by this BR

- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Contextual recommendations
- Personal recommendations
- Style bundles and curated look outputs

### Channels and surfaces affected

- Ecommerce surfaces such as PDP, cart, homepage, and style inspiration experiences
- Email and campaign personalization placements
- In-store clienteling and styling workflows
- Internal admin and governance workflows used to control recommendation behavior

### Recommendation sources under governance

- Curated looks authored by merchandising teams
- Rule-based eligibility and compatibility controls
- AI-ranked outputs that must remain bounded by merchandising and campaign controls

## 5. Scope boundaries

### In scope

- Governance requirements for curated look lifecycle, ownership, and publication controls
- Governance requirements for manual overrides, campaign priorities, and emergency suppressions
- Eligibility controls for recommendation inclusion, exclusion, and fallback expectations
- Approval expectations for business-critical recommendation changes
- Audit, history, and reporting expectations for recommendation decision changes
- Internal operating outcomes needed to support routine recommendation tuning across teams

### Out of scope

- Technical architecture, storage design, or service decomposition
- Detailed UI design for internal governance tooling
- Final implementation of ranking algorithms or experimentation systems
- Customer-facing copy or explanation design beyond the need for internal traceability
- Organization staffing decisions or team restructuring

## 6. RTW and CM considerations

- RTW governance must support faster operational tuning because assortment, inventory, and campaign changes can require more frequent override or eligibility updates.
- CM governance must preserve stronger review discipline for premium or appointment-led styling decisions where human brand judgment remains especially important.
- Shared governance concepts should apply across RTW and CM, but the approval rigor, eligible assortment scope, and review cadence may differ by journey.

## 7. Business requirements

### 7.1 Curated look governance

The platform must define governance expectations for curated looks so internal teams can:

- assign clear ownership for each curated look or look set by business area, market, campaign, or channel where applicable;
- manage lifecycle states such as draft, reviewed, published, superseded, and retired at the business-process level;
- specify where a look is allowed to influence recommendations, including product scope, market or region, season, channel, and customer segment where relevant;
- control effective dates so curated looks do not remain active beyond their intended campaign or merchandising window; and
- retire or replace outdated looks without losing historical traceability of prior recommendation behavior.

### 7.2 Override governance

The platform must define override controls so authorized internal users can shape recommendation outcomes without bypassing governance. Override expectations must include:

- the ability to pin, boost, suppress, or replace recommendation content at an appropriate business scope such as campaign, channel, market, anchor product, or look family;
- a required business reason for each override, especially when it changes default recommendation behavior;
- effective start and end conditions so overrides are intentionally temporary unless explicitly maintained;
- conflict handling rules when multiple overrides or campaigns affect the same recommendation context; and
- rollback expectations so teams can quickly reverse a problematic override.

### 7.3 Campaign priority governance

The platform must define how campaign priorities interact with ongoing recommendation logic so:

- campaign-led curation can take precedence when the business intends a launch, editorial story, or promotional push to shape outcomes;
- priority handling remains explicit rather than hidden inside ranking logic;
- multiple concurrent campaigns do not create ambiguous recommendation behavior; and
- non-campaign recommendation quality can recover cleanly after a campaign window ends.

### 7.4 Eligibility governance

The platform must define recommendation eligibility controls that separate hard business constraints from ranking preferences. Eligibility governance must cover:

- which products, looks, or recommendation types are allowed or disallowed in a given region, channel, segment, or campaign context;
- compatibility and brand-safety constraints that must never be bypassed by personalization or campaign pressure;
- operational exclusions such as unavailable, discontinued, embargoed, or otherwise unsuitable products;
- consent or policy-sensitive usage boundaries where recommendation activation depends on permitted data usage; and
- fallback expectations when eligibility rules reduce recommendation coverage so surfaces degrade gracefully instead of showing misleading outputs.

### 7.5 Approval and operating expectations

The platform must support an internal operating model in which:

- recommendation governance changes have clear roles for author, reviewer, and approver when the change has material commercial or brand impact;
- routine merchandising and campaign changes can be executed by business users without engineering mediation, provided they stay within governed controls;
- higher-risk changes such as market-wide suppressions, campaign conflicts, or CM-sensitive overrides can require stronger review or dual control; and
- governance processes align with launch calendars, regional operating needs, and incident response expectations.

### 7.6 Audit and traceability expectations

The platform must preserve an audit trail for recommendation governance actions so internal teams can understand what changed, why it changed, and what business context applied. Audit expectations must include:

- who created, changed, approved, published, retired, or rolled back a governance action;
- when the action occurred and when it became effective;
- the reason, campaign reference, or operational context attached to the change;
- the before-and-after business state for curated looks, overrides, priority rules, or eligibility settings; and
- enough decision context to connect recommendation outcomes back to the governing look, rule, campaign, override, experiment, and trace identifiers used at run time.

### 7.7 Internal operating outcomes

This governance capability is complete only when internal teams can:

- activate and tune recommendation behavior across merchandising, campaign, and clienteling workflows without ad hoc engineering dependency for routine changes;
- understand which governance decision drove a recommendation outcome during performance review or incident investigation;
- maintain confidence that campaign priorities, curated looks, and eligibility rules are applied consistently across channels; and
- scale recommendation usage to more teams in Phase 3 without weakening control, auditability, or accountability.

## 8. Success metrics

Target values are to be defined during downstream planning, but this BR should enable measurement of:

- time required to publish or update a governed curated look or campaign rule;
- percentage of overrides with an owner, business reason, and expiration or review condition;
- percentage of recommendation sets with traceable governance context;
- number and rate of governance conflicts, expired overrides, or stale campaign rules detected;
- adoption of governed recommendation workflows by merchandising, CRM, and clienteling teams; and
- incident investigation time for recommendation behavior changes that require audit review.

## 9. Constraints and assumptions

### Constraints

- Governance must preserve brand safety and compatibility rules ahead of ranking optimization.
- Governance expectations must work across multiple channels without assuming one team owns every recommendation surface.
- Recommendation controls must respect privacy, consent, and regional policy boundaries.
- Auditability must be sufficient for operational review without exposing sensitive customer reasoning in customer-facing contexts.

### Assumptions

- Merchandising, campaign, and analytics teams will share responsibility for governed recommendation operations in Phase 3.
- The platform will maintain stable identifiers for looks, campaigns, overrides, rules, and recommendation traces.
- Downstream feature and architecture work will define how governance is implemented, but this BR sets the minimum business operating expectations first.

## 10. Open decisions

- Missing decision: which governance actions require single review versus dual approval by policy or region.
- Missing decision: how long audit history must be retained for operational review, compliance needs, and performance analysis.
- Missing decision: whether campaign priority precedence is global, regional, channel-specific, or some combination of those scopes.
- Missing decision: which CM recommendation changes are sensitive enough to require an explicit human checkpoint beyond normal merchandising review.

## 11. Approval and milestone notes

- BR stage approval mode is not explicitly defined in the current checkout; treat it as `HUMAN_REQUIRED` until the board or an upstream artifact states otherwise.
- This issue was completed under autonomous issue-run instructions, so artifact creation, commit, push, and PR creation must not block on a manual "Mark as ready" step.
- Internal controls and campaign governance deepen in Phase 3 as more teams activate recommendation outputs across email and clienteling workflows.

## 12. Downstream readiness

The next stage should break this BR into feature work covering at least:

- curated look lifecycle and ownership controls;
- override, suppression, and campaign priority management;
- eligibility policy and fallback governance;
- audit history, reporting, and operational review workflows; and
- role-based operating expectations for merchandising, CRM, styling, analytics, and regional stakeholders.
