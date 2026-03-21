# Feature: RTW and CM mode support

**Upstream traceability:** `docs/project/business-requirements.md` (BR-004); `docs/project/br/br-004-rtw-and-cm-support.md`, `br-008-product-and-inventory-awareness.md`, `br-001-complete-look-recommendation-capability.md`, `br-005-curated-plus-ai-recommendation-model.md`; `docs/project/glossary.md` (RTW, CM); `docs/project/roadmap.md` (Phase 1 RTW, Phase 4 CM depth).

---

## 1. Purpose

Keep **RTW** and **CM** journeys explicitly distinct in data, compatibility, governance, surfaces, and phased rollout while sharing taxonomy and telemetry (BR-004).

## 2. Core Concept

Mode flag on requests/responses drives eligibility, compatibility depth, fallback posture, and operator involvement—RTW optimizes immediate purchasable **outfits**; CM optimizes configuration-safe, premium-credible guidance (BR-004 comparison table).

## 3. Why This Feature Exists

Collapsing modes produces invalid CM suggestions or weak RTW speed (`product-overview.md` boundaries by mode).

## 4. User / Business Problems Solved

- RTW shoppers: fast valid attach.
- CM customers/stylists: fabric/palette/shirt-tie coordination trust.
- Analytics: separable measurement.

## 5. Scope

Mode-aware fields in catalog, rules, ranking objectives, UI modules, traces. **Missing decisions:** how much CM appears in self-serve digital early vs stylist-only (`business-requirements.md`).

## 6. In Scope

- Contract field `mode: RTW|CM` and consumer handling.
- CM compatibility dimensions: garment config, fabrics, palettes, premium options (BR-004).
- Phased feature flags restricting CM depth.

## 7. Out of Scope

Manufacturing MES integration; bespoke tailoring operations beyond recommendation.

## 8. Main User Personas

P1 RTW; CM customer; S1 stylist; S2 merchandiser.

## 9. Main User Journeys

RTW PDP complete look (Phase 1); CM appointment styling with configuration-aware suggestions (Phase 3–4); digital CM bounded flows when enabled.

## 10. Triggering Events / Inputs

Product mode from catalog; appointment context; configurator state payload from CM tools.

## 11. States / Lifecycle

Configurator `incomplete → valid → recommendation eligible`; on invalid config, narrow or curated-only paths.

## 12. Business Rules

- CM must not claim configuration support without validated fields (BR-008).
- Premium styling governance stricter for CM (BR-004 premium styling).
- AI ranking cannot bypass CM hard rules (BR-005).

## 13. Configuration Model

Per-market CM enablement; category CM templates; risk classes for automatic CM suggestions.

## 14. Data Model

Extend product/look with `mode`, `cmConfiguration` blob (structured), compatibility edges tagged with mode constraints.

**Example:** `{ mode: CM, selectedGarment: {...}, paletteId: "P-22" }` feeds candidate filter.

## 15. Read Model / Projection Needs

Mode-specific eligibility indexes; stylist-facing enriched product cards.

## 16. APIs / Contracts

Delivery API requires mode; responses include mode-specific metadata e.g. `configurationWarnings[]`.

## 17. Events / Async Flows

Configurator changes trigger recommendation invalidation events.

## 18. UI / UX Design

RTW: purchase-forward **outfit** modules. CM: explain limited automation; emphasize stylist review; avoid overclaim in copy.

## 19. Main Screens / Components

RTW modules per `ecommerce-surface-experiences.md`; CM stylist console; optional digital CM advisor (Phase 4).

## 20. Permissions / Security Rules

CM configuration data may be sensitive; restrict APIs; log access.

## 21. Notifications / Alerts / Side Effects

Alert if CM suggestion rate exceeds governance thresholds; merchandising review queues.

## 22. Integrations / Dependencies

CM configurator systems, catalog mode fields, clienteling, governance.

## 23. Edge Cases / Failure Cases

Partial CM data → suppress AI expansions, offer curated safe picks; conflicting customer vs stylist selections → operator precedence policy **missing decision**.

## 24. Non-Functional Requirements

CM validation may be heavier computationally—async precompute acceptable in assisted flows.

## 25. Analytics / Auditability Requirements

Slice metrics by mode; traces include mode + configuration snapshot ids (BR-011).

## 26. Testing Requirements

Mode-specific golden scenarios; regression when toggling flags; stylist UAT for CM.

## 27. Recommended Architecture

Shared decision pipeline with mode strategy pattern; CM-specific compatibility validators as plugins.

## 28. Recommended Technical Design

`ModeStrategy` interface: `eligibleProducts`, `rankingObjective`, `fallbackBehavior`; configured via governance.

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW-only ecommerce surfaces; mode field present in contracts for forward compatibility.
- **Phase 3:** CM in clienteling with curated-first posture.
- **Phase 4:** Deeper CM digital + advanced ranking (`roadmap.md`).

## 30. Summary

RTW/CM separation prevents premium trust failures (BR-004). Ship RTW value first with mode-aware contracts, expand CM where data and operators are ready. Self-serve CM scope remains a key **missing decision**.
