# Roadmap

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description plus bootstrap project docs.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Capability-level BR fan-out, architecture sequencing, and implementation-plan gating.
- **Key assumption:** The first live slice should validate RTW PDP outfit recommendations before broader channel and CM expansion.
- **Approval note:** This roadmap sets directional phase order; later BR and architecture artifacts should refine phase content without contradicting the sequence unless the roadmap is updated.

## Purpose
Provide a phased delivery sequence for the AI Outfit Intelligence Platform that is practical for staged architecture, implementation, and rollout work.

## Delivery principles
- Build the data and control foundation before scaling customer-facing surfaces.
- Deliver one dependable recommendation path before widening channel coverage.
- Separate foundational platform capabilities from later optimization and expansion work.
- Keep RTW breadth earlier than deep CM sophistication, while preserving CM in the platform design from the start.

## Recommended phases

### Phase 0 - Bootstrap and operating foundation
**Theme:** Establish canonical project docs, operating model, review criteria, and initial roadmap.

**Why first:** Later work needs a shared source of truth before feature decomposition starts.

**Checkpoint:** `docs/project/` is complete enough to drive business-requirements and architecture fan-out.

### Phase 1 - Data and recommendation foundation
**Theme:** Create the minimum viable platform core.

**Focus areas**
- Catalog and inventory ingestion for RTW and CM attributes
- Customer event ingestion and session tracking
- Identity resolution approach and customer profile foundation
- Product relationship graph and curated look model
- Initial merchandising rule framework
- Recommendation telemetry model and analytics basics

**Dependencies**
- Requires agreement on source systems, canonical identifiers, and privacy constraints.

**Checkpoint**
- The platform can assemble eligible complete-look candidates and record recommendation telemetry even before every channel consumes it.

**First fan-out candidates**
- BR-002: catalog, event, identity, and recommendation telemetry foundation
- BR-003: product relationship graph, curated looks, and merchandising-rule controls

### Phase 2 - Recommendation engine and delivery API
**Theme:** Turn foundational data into usable recommendation services.

**Focus areas**
- Context engine inputs such as location, season, and weather
- Recommendation retrieval, ranking, and rule orchestration
- Recommendation delivery API contracts
- Recommendation-set tracing, observability, and performance targets
- Early experimentation hooks

**Dependencies**
- Depends on Phase 1 data quality, identity boundaries, and catalog normalization.

**Checkpoint**
- A stable API can return outfit, cross-sell, upsell, and style-bundle recommendation sets for controlled test cases.

**First fan-out candidates**
- BR-004: recommendation delivery API and trace contract
- Architecture slice for ranking, rule orchestration, and context-engine composition

### Phase 3 - Initial customer-facing rollout
**Theme:** Launch the first high-impact customer surfaces and learn from real behavior.

**Focus areas**
- PDP complete-the-look or outfit recommendations
- Cart cross-sell and upsell recommendations where scope allows
- Style inspiration or look-builder experience if included in phase scope
- Recommendation measurement dashboards and experiment readouts

**Dependencies**
- Depends on delivery API readiness, channel integration work, and telemetry validation.

**Checkpoint**
- At least one primary ecommerce surface is live with measurable recommendation outcomes.

**First fan-out candidates**
- BR-001: PDP RTW outfit recommendation experience
- Follow-on cart or inspiration BR only after the PDP slice is explicitly approved

### Phase 4 - Personalization and operator tooling
**Theme:** Strengthen relevance and operational control.

**Focus areas**
- Returning-customer personalization and wardrobe-aware logic
- Merchandising admin workflows for rules, bundles, and curation
- Experimentation management and governance workflows
- Clienteling and email activation using shared recommendation logic

**Dependencies**
- Depends on trustworthy telemetry, operator workflows, and identity confidence for known customers.

**Checkpoint**
- Teams can tune, test, and reuse recommendations beyond a single onsite surface.

### Phase 5 - CM depth and contextual sophistication
**Theme:** Expand platform intelligence into deeper CM and context-aware scenarios.

**Focus areas**
- CM configuration compatibility and premium-option guidance
- More advanced occasion, climate, and locale-aware logic
- Better cross-channel continuity across ecommerce, clienteling, and outreach
- Optimization loops using accumulated recommendation outcomes

**Dependencies**
- Depends on earlier foundation and control layers; CM sophistication should not be an afterthought, but it should build on a stable platform.

**Checkpoint**
- The platform supports materially richer recommendation quality across both RTW and CM contexts.

## Canonical fan-out order
To keep downstream work consistent, later agents should use this order unless an updated artifact supersedes it:
1. BR-002: catalog, event, identity, and recommendation telemetry foundation
2. BR-003: product relationship graph, curated looks, and merchandising-rule controls
3. BR-004: recommendation delivery API and trace contract
4. BR-001: PDP RTW outfit recommendation experience
5. Returning-customer personalization, clienteling, email, and operator-tooling BR artifacts
6. CM-specific recommendation-depth artifacts

## Earlier versus later guidance
### Prioritize earlier
- Canonical identifiers and event taxonomy
- Core recommendation eligibility and tracing
- PDP and other high-intent surfaces
- Merchandising rule controls needed to keep early launches safe

### Defer until later unless a phase-specific case justifies otherwise
- Broad multi-market rollout
- Full channel parity across every surface
- Deep CM decision support beyond the first compatible combinations
- Sophisticated optimization loops that depend on substantial production telemetry

## Review and test checkpoints
- Bootstrap doc review before feature or BR fan-out.
- Data-model and identity review before personalization work expands.
- API contract review before channel integrations multiply.
- Surface-specific validation before new customer-facing launches.
- QA and human rollout review before production expansion to new channels or markets.

## Missing decisions

| Missing decision | Why it matters | Temporary bootstrap direction | Proposed resolution stage | Recommended owner |
| --- | --- | --- | --- | --- |
| Exact first-release surface and geography combination | Determines rollout risk, telemetry baselines, and integration scope. | Default to one PDP-focused pilot rollout. | First downstream BR fan-out and rollout planning. | Product and ecommerce leadership. |
| Whether merchandising admin tooling ships before or alongside the first live recommendations | Affects operational readiness and build sequencing. | Start with lightweight operator workflows, then mature the admin surface in Phase 4 unless safety needs force earlier tooling. | BR and implementation planning for merchandising controls. | Merchandising and product operations. |
| Whether CM enters Phase 3 in a limited form or stays a Phase 5 expansion theme | Affects domain-model prioritization and early delivery complexity. | Preserve CM in the platform model now but plan deep CM execution later by default. | BR refinement before Phase 3 execution. | Product and CM business owners. |
