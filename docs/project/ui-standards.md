# UI Standards

## Purpose

These standards define how recommendation experiences should behave across user-facing and operator-facing interfaces without prescribing final visual design.

## 1. Experience principles

- Present recommendations as complete-look or clearly labeled recommendation groups, not as ambiguous item grids.
- Make it easy for customers to understand how to act on a recommendation, including viewing products, adding items, and exploring a full look.
- Preserve SuitSupply's premium, style-led brand feel through coherent grouping and presentation.
- Allow human-assisted channels to adapt recommendations without hiding the underlying suggestion context.

## 2. Consistency expectations

- Use consistent naming for recommendation groups such as outfit, cross-sell, upsell, or style bundle.
- Use a shared pattern for empty states, loading states, and unavailable recommendations across surfaces.
- Ensure anchor-product context is visible when recommendations are derived from a viewed or purchased item.
- Where appropriate, distinguish curated looks from algorithmically ranked suggestions.

## 3. Recommendation module expectations

- Recommendation modules should clearly indicate whether the customer is seeing a full outfit, complementary products, or a premium or alternative option.
- Multi-item looks should make it easy to inspect individual products without losing the context of the full look.
- Surfaces should support direct product action paths such as view, add-to-cart, save, or expand look details when appropriate.
- The UI should avoid presenting incompatible items as equivalent substitutes when the intent is outfit completion.

## 4. Accessibility expectations

- Recommendation modules must be keyboard accessible and screen-reader navigable.
- Recommendation labels, calls to action, and state changes must be understandable without relying on imagery alone.
- Visual grouping of a look should not block accessible access to individual item details.

## 5. State and feedback patterns

- Loading states should communicate that recommendations are being prepared without creating layout instability.
- Empty states should provide a graceful fallback, not a broken or blank container.
- Customer actions such as add-to-cart, save, or dismiss should provide clear feedback and emit telemetry.
- When recommendations are influenced by strong context such as occasion or season, the UI may communicate that context if it improves trust and clarity.

## 6. Explanation and trust guidance

- Customer-facing explanation copy should remain simple and style-oriented, not overly technical or invasive.
- Do not expose sensitive personal reasoning or identity-resolution details.
- Assisted-selling surfaces may show richer internal context than customer-facing surfaces, but still should not expose unnecessary sensitive data.

## 7. Telemetry expectations

- UI implementations must emit impression events only when recommendations are actually viewable.
- Click, save, add-to-cart, dismiss, and look-expansion interactions should be tracked consistently.
- Recommendation set metadata required for attribution must travel with the rendered module and associated actions.

## 8. Shared component expectations

- Recommendation surfaces should reuse component patterns where feasible for cards, look groupings, badges, and calls to action.
- Surface-specific differences should be deliberate and documented, not accidental drift.
- Operator-facing interfaces for merchandising should prioritize clarity, editability, and audit visibility over consumer visual patterns.

## 9. Operator UI expectations

- Merchandising and operator tools should show the source of a recommendation such as curated, rule-based, or AI-ranked.
- Operator UIs should support inspection of applicable rules, suppressions, and experiment context.
- Override actions should be explicit and attributable, not hidden behind ambiguous editing flows.
