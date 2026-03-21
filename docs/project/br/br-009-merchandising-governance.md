# BR-009: Merchandising governance

## Artifact metadata

- **Board Item ID:** BR-009
- **Issue:** #83
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent Item:** None
- **Primary Source Artifacts:** `docs/project/business-requirements.md` (BR-9), `docs/project/goals.md`, `docs/project/industry-standards.md`
- **Related Source Artifacts:** `docs/project/product-overview.md`, `docs/project/personas.md`, `docs/project/roadmap.md`
- **Downstream feature areas:** Merchandising rule builder, override workflow, campaign governance, audit history, and internal operations controls for recommendation management

## Problem statement

SuitSupply needs merchandising teams to shape recommendation outputs without relying on engineering for every campaign, exception, or brand-protection change. The platform blends curated looks, compatibility rules, campaign priorities, and AI-ranked recommendation logic across PDP, cart, homepage, email, and clienteling surfaces. If merchandising governance is not defined as a business requirement, recommendation behavior becomes too slow to adjust, too opaque to trust, and too dependent on engineering-only workflows for routine operational changes.

This is especially important for a premium retail recommendation system where styling credibility matters as much as conversion. Merchandisers must be able to curate looks, suppress invalid combinations, prioritize campaigns, and apply overrides while staying inside compatibility, inventory, privacy, and brand guardrails. Without explicit governance controls and operating boundaries, the business risks inconsistent outputs across channels, unmanaged override sprawl, poor auditability, and changes that optimize short-term metrics at the expense of brand trust.

## Target users

### Primary internal users

- **Merchandiser / look curator:** needs to define curated looks, compatibility rules, exclusions, and override logic that protect brand standards.
- **Campaign and CRM manager:** needs to activate time-bound priorities and recommendation shaping for seasonal, lifecycle, and promotional programs.
- **Merchandising governance lead or business owner:** needs clear approval, publishing, rollback, and audit controls for recommendation-affecting changes.
- **Product, analytics, and optimization lead:** needs governed experimentation and measurable override behavior without losing traceability.

### Secondary internal users

- **In-store stylist / clienteling associate:** needs recommendation outputs that already reflect governed curation and compatibility rules, reducing ad hoc manual look assembly.
- **Operations and support teams:** need auditable change history and explainable override behavior when recommendation issues are investigated.
- **Engineering teams:** need governance boundaries that reduce routine change requests and reserve engineering involvement for capability changes, not everyday merchandising tuning.

### Customer impact

- **Occasion-led online shopper**
- **Style-aware returning customer**
- **Custom Made customer**

These customers benefit when recommendation outputs stay coherent, campaign-aware, purchasable, and aligned with brand styling standards even as business priorities change.

## Business value

This requirement supports five business outcomes:

1. **Merchandising autonomy:** routine curation, exclusions, prioritization, and campaign changes can be made by business teams without engineering-only workflows.
2. **Brand and compatibility protection:** recommendation outputs stay within approved style, assortment, and quality boundaries even when overrides are applied.
3. **Faster commercial response:** seasonal priorities, campaign pushes, inventory exceptions, and issue remediation can be applied quickly and consistently across channels.
4. **Operational trust and accountability:** every governed change is attributable, reviewable, and reversible so the business can investigate impact and control risk.
5. **Phase 3 readiness:** multi-channel activation for ecommerce, email, and clienteling can scale only if merchandising governance is explicit and repeatable.

## Recommendation and channel mapping

- **Recommendation types in scope:** outfit, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendations.
- **Recommendation sources in scope:** curated looks, rule-based compatibility, campaign priorities, merchandising overrides, and AI-ranked ordering.
- **Consuming surfaces in scope:** PDP, cart, homepage or web personalization, email, clienteling, and internal admin workflows used to manage recommendation behavior.

## Scope boundaries

### In scope

- Business requirements for how merchandising teams govern curated looks, compatibility rules, exclusions, overrides, and campaign priorities.
- Override models that let business users shape eligibility, suppression, ordering, and fallback behavior without code changes for routine operations.
- Role and approval expectations for drafting, reviewing, publishing, reverting, and emergency-changing recommendation-affecting business controls.
- Operating boundaries that define what merchandising may change directly and what must remain protected by hard guardrails.
- Audit expectations for governed changes and recommendation-impacting business decisions.
- Governance expectations that apply across RTW and CM recommendation workflows where business controls differ.

### Out of scope

- Technical design for admin interfaces, storage models, APIs, or implementation details for rule engines.
- Replacing PIM, CMS, CRM, or other systems of record with recommendation governance tooling.
- Detailed organization design, staffing, or escalation policy outside recommendation-related workflows.
- A requirement that merchandisers can override privacy, consent, legal, or hard compatibility controls.
- Engineering-owned changes to fundamental recommendation capabilities, model architecture, or platform infrastructure.

## RTW and CM considerations

- **RTW:** merchandising teams need faster campaign and assortment governance because RTW recommendation flows operate at higher scale and often require broad channel-level or category-level adjustments.
- **CM:** governance must be stricter for overrides that affect configuration compatibility, appointment context, premium options, or styling credibility in high-consideration journeys.
- **Shared requirement:** both RTW and CM flows need explicit business controls, but hard brand and compatibility guardrails must remain stronger than local override convenience.

## Merchandising governance outcomes

The platform must support the following business outcomes for governed recommendation management:

### BR-009.1 Merchandising-managed control plane

Merchandising teams must be able to manage the following recommendation-shaping inputs without engineering intervention for routine changes:

- curated looks and look eligibility
- compatibility and exclusion rules owned by the business
- campaign priorities and time-bound boosts or suppressions
- override instructions for products, looks, categories, or surfaces
- recommendation eligibility boundaries for business-defined scenarios

This requirement does not remove engineering ownership of platform capabilities. It establishes that day-to-day recommendation tuning should not require code deployment when the change stays within approved governance boundaries.

### BR-009.2 Override model with explicit precedence

The override model must distinguish between hard guardrails and business-tunable controls so internal teams understand what can and cannot be changed operationally.

| Governance layer | Purpose | Who controls it | Override allowed? |
| --- | --- | --- | --- |
| Hard guardrails | Protect brand safety, compatibility, consent, regional policy, and critical inventory or operational constraints | Platform and governance policy owners | No; these constraints take precedence |
| Business rules | Define curated look eligibility, approved exclusions, category or surface boundaries, and repeatable merchandising logic | Merchandising governance owners | Yes, but only within hard guardrails |
| Campaign priorities | Push or suppress recommendation behavior for seasonal, lifecycle, or promotional intent | Merchandising and campaign owners | Yes, time-bound and auditable |
| Local overrides | Handle specific look, SKU, category, or surface exceptions | Authorized merchandisers | Yes, auditable and reversible |
| Ranking optimization | Order eligible candidates using AI-ranked or heuristic logic | Platform optimization logic under governance | Only after higher-priority controls are applied |

The business expectation is that:

- hard guardrails always win over campaign or local overrides
- campaign priorities can shape eligible outputs but cannot bypass compatibility or consent constraints
- local overrides can correct or tune outputs but should not silently become permanent substitutes for governed rules
- AI ranking operates only inside the set of outputs that remain eligible after governance controls are applied

### BR-009.3 Role-based operating model

Merchandising governance must define clear decision rights so recommendation-affecting changes are not made by ambiguous or overly broad access.

| Role | Primary responsibilities | Typical authority |
| --- | --- | --- |
| Merchandiser / look curator | Curate looks, define exclusions, tune recommendation behavior for assortment and brand fit | Draft and publish low-risk changes inside approved guardrails |
| Campaign or CRM manager | Configure campaign-aware priorities and time-bound recommendation shaping | Draft and activate campaign controls inside approved guardrails |
| Governance owner | Approve high-impact changes, policy-sensitive overrides, and emergency decisions | Final approval for high-risk or cross-channel changes |
| Analytics / optimization lead | Review performance impact, override usage, and experiment interaction | Recommend tuning and flag governance issues |
| Support / operations | Trigger rollback or escalation when governed changes create visible defects | Emergency escalation, not broad policy authoring |

The business must be able to separate routine tuning from high-risk changes. Routine merchandising updates should be self-service within governance boundaries. Cross-channel, policy-sensitive, or high-visibility changes should require stronger review.

### BR-009.4 Publishing, approval, and rollback controls

Governed recommendation changes must support a publish model that matches business risk:

- low-risk routine changes may be publishable directly by authorized merchandising users
- high-risk changes must require an explicit approval step before activation
- time-bound campaign changes must have start and end controls so priorities expire predictably
- emergency suppressions or reversions must be available when a recommendation behavior is visibly wrong or unsafe
- rollback must restore the previous governed state quickly enough for customer-facing use

The exact risk thresholds remain a business operating decision, but the governance model must support different approval paths rather than treating every change the same.

### BR-009.5 Auditability for governed changes

Every recommendation-affecting governance change must be auditable for operational and business review. At minimum, the business must be able to answer:

- who made the change
- when the change was made
- what governed artifact changed
- what the intended business reason was
- when the change became active
- whether the change was later reverted, superseded, or expired

Audit expectations apply to:

- curated looks
- exclusions and compatibility rules
- campaign priorities
- local overrides
- emergency suppressions
- approval and publish actions tied to governed changes

### BR-009.6 Operating boundaries for merchandising autonomy

Merchandising teams must be empowered to shape outputs, but only inside explicit operating boundaries.

#### Merchandising may directly control

- inclusion or exclusion of looks or items within approved categories or surfaces
- campaign-aware prioritization and time-bound recommendation shaping
- local corrections for brand, styling, assortment, or commercial reasons
- preference for curated looks or approved business rules over default ranking behavior

#### Merchandising may not directly override

- privacy and consent restrictions
- hard compatibility protections
- region or policy prohibitions
- engineering-owned platform behavior outside approved governance tooling
- safety-critical operational blocks such as invalid inventory or unavailable assortment states that must remain protected

#### Business expectation

When a requested business change falls outside approved governance tooling or conflicts with a hard guardrail, it should become an explicit escalation to product, governance, or engineering rather than an undocumented workaround.

### BR-009.7 Campaign governance

Campaign-aware recommendation shaping must support:

- explicit campaign identity and priority
- defined applicability by channel, surface, region, category, customer segment, or look family where approved
- start and end timing
- conflict handling when multiple campaigns apply
- predictable fallback behavior when a campaign expires or is removed

Campaign governance should let the business align recommendations with seasonal or promotional strategy without creating hidden long-lived behavior that outlives the campaign.

### BR-009.8 Override hygiene and lifecycle management

The governance model must discourage override sprawl by treating overrides as managed business instruments rather than permanent hidden patches.

The business should be able to distinguish between:

- permanent governed rules
- time-bound campaign controls
- temporary corrective overrides
- emergency suppressions

Overrides should be reviewable for age, reason, reuse, and cleanup so merchandising behavior remains intentional instead of accumulating opaque exceptions.

### BR-009.9 Cross-channel consistency

Governance controls must apply consistently across all consuming surfaces that use the shared recommendation foundation. Channel-specific presentation can differ, but the business should not need separate incompatible governance logic for ecommerce, email, and clienteling when the underlying business rule is the same.

Where channel differences are intentional, those differences must be explicit, governed, and auditable.

## Operating model summary

| Governance area | Required business outcome |
| --- | --- |
| Curated look management | Merchandising can create and maintain approved looks and suppress invalid ones without code changes |
| Compatibility governance | Business-owned compatibility and exclusion rules shape eligibility before ranking |
| Campaign control | Campaign teams can activate time-bound priorities and suppressions with explicit scope and expiration |
| Override handling | Authorized users can correct recommendation behavior quickly, with audit history and rollback |
| Approval model | Higher-risk changes receive stronger review than routine tuning |
| Auditability | Every governed change is attributable, reviewable, and reversible |
| Boundary protection | Hard brand, compatibility, privacy, and policy controls cannot be bypassed by routine overrides |

## Success metrics

The business should evaluate this requirement through downstream execution using measures such as:

- percentage of routine recommendation-governance changes completed without engineering deployment
- time required for merchandisers to launch, update, or end a campaign-related recommendation adjustment
- time required to suppress or roll back an invalid recommendation behavior
- audit completeness rate for governed changes
- override usage rate segmented by permanent rule, campaign control, temporary correction, and emergency suppression
- reduction in engineering tickets for routine merchandising tuning
- reduction in recommendation incidents caused by unmanaged or conflicting overrides
- adoption of governance tooling by merchandising, campaign, and clienteling support teams

## Constraints

- Merchandising governance must preserve brand styling integrity before optimizing short-term metrics.
- Business overrides must remain subordinate to hard compatibility, consent, and policy constraints.
- Governance must support traceability across curated, rule-based, campaign-driven, and AI-ranked recommendation sources.
- The operating model must scale across multiple channels without requiring business users to learn disconnected workflows for the same underlying rule intent.

## Missing decisions

- **Missing decision:** Which types of recommendation changes require two-person approval versus direct publish by an authorized merchandiser.
- **Missing decision:** Whether regional teams may create local overrides independently or must route all governance through a central merchandising owner.
- **Missing decision:** What service expectation should apply for emergency override and rollback response on customer-facing surfaces.
- **Missing decision:** Whether clienteling teams can request or apply channel-specific overrides directly, or only consume centrally governed outputs.
- **Missing decision:** How long governed audit records and expired overrides must be retained for operational and compliance review.

## Approval and milestone-gate notes

- **Approval Mode:** `AUTO_APPROVE_ALLOWED`, consistent with the current seeded BR board for the autonomous workflow milestone.
- **Trigger note:** Trigger: issue-created automation.
- **Milestone note:** Governance maturity is a Phase 3 dependency for broader multi-channel activation, experimentation control, and merchandising-managed recommendation operations.

## Recommended board update

Update `boards/business-requirements.md` for BR-009 with:

- **Status:** `DONE` after branch push for the autonomous issue run
- **Output:** `docs/project/br/br-009-merchandising-governance.md`
- **Notes:** Branch pushed on `br/issue-83`; artifact defines override precedence, business roles, approval and rollback expectations, and operating boundaries for merchandising-managed recommendation governance
