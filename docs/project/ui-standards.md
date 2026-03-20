# UI Standards

## Purpose

Define cross-surface UI expectations for customer-facing and internal recommendation experiences.

## 1. Experience principles

- Present recommendations as useful styling guidance, not generic product clutter.
- Favor complete-look clarity over showing the maximum number of items.
- Make recommendation intent obvious: outfit, cross-sell, upsell, style bundle, occasion-based, contextual, or personal.
- Preserve trust by ensuring displayed recommendations are coherent and purchasable.

## 2. Customer-facing surface standards

- Recommendation modules should identify the anchor context when useful, such as an occasion or anchor garment.
- Complete-look recommendations should group related items clearly.
- Complementary items should be easy to act on from PDP and cart surfaces.
- Surfaces should handle partial availability gracefully instead of showing broken looks.
- Presentation should degrade cleanly when personalization data is unavailable.

## 3. Internal-facing surface standards

- Clienteling and merchandising interfaces should expose more decision context than customer-facing surfaces.
- Internal users should be able to identify recommendation source, applicable rules, and eligibility constraints when needed.
- Override and curation workflows should prioritize clarity and auditability over visual density.

## 4. Accessibility expectations

- Recommendation modules should meet baseline accessibility requirements for navigation, semantics, and readable state changes.
- Grouped look and outfit content should remain understandable to assistive technologies.
- Interaction patterns should not rely on imagery alone to convey recommendation meaning.

## 5. State and feedback patterns

- Loading, empty, fallback, and error states must be explicit.
- No-recommendation scenarios should guide the user to a sensible next step rather than failing silently.
- Saved-look, add-to-cart, and dismiss interactions should return immediate visible feedback.
- When experiments change presentation, telemetry must still preserve comparable event semantics.

## 6. Consistency expectations

- Recommendation labels, grouping rules, and action affordances should remain consistent across surfaces unless the workflow requires a documented exception.
- Use shared recommendation terminology from `docs/project/standards.md`.
- Keep recommendation UI contracts aligned with API payload structure to reduce surface-specific reinterpretation.

## 7. Telemetry expectations

- Customer-facing modules must emit impression, click, add-to-cart, purchase, and dismiss telemetry where applicable.
- Internal-facing tools should emit override, curation, and rule-inspection telemetry as relevant.
- All surface events must preserve recommendation set ID and trace context.
