# UI Standards

## Purpose

These standards define how recommendation outputs should appear and behave across customer-facing and internal interfaces.

## 1. UI consistency principles

- Present recommendations as coherent outfit guidance rather than arbitrary item lists when the use case supports it.
- Match the recommendation presentation to the decision context of the surface.
- Preserve a consistent mental model across channels even when the visual treatment differs.
- Make it clear when recommendations relate to an anchor product, occasion, or personal profile.

## 2. Surface-specific expectations

### Ecommerce surfaces

- PDP modules should emphasize outfit completion and compatible next items.
- Cart modules should focus on add-on relevance, not distraction from checkout intent.
- Homepage and personalization modules should reflect customer or contextual relevance more strongly than generic merchandising.

### Style inspiration or look builder surfaces

- Show complete outfits with clear item composition.
- Make it easy to move from inspiration to item-level action.

### Email and campaign surfaces

- Recommendation payloads should be reusable in templated campaign blocks.
- Presentation should prioritize clarity and click intent over excessive explanation.

### Clienteling and internal surfaces

- Internal users should be able to see more context than customers, including occasion basis, recommendation source mix, or exclusions where appropriate.

## 3. State and feedback patterns

- Support clear states for loading, empty results, degraded fallback, and error handling.
- If personalized recommendations are unavailable, fall back to credible curated or rule-based alternatives.
- Avoid blank recommendation areas on major surfaces when a safe fallback exists.

## 4. Explanation and trust

- Customer-facing explanations should be short and practical, such as occasion or styling cues, rather than model-centric reasoning.
- Internal tools may expose richer recommendation provenance to support trust and auditing.
- Do not expose sensitive customer profile reasoning in public interfaces.

## 5. Accessibility expectations

- Recommendation modules must meet the accessibility bar of their host channel.
- Important recommendation information should not rely on imagery alone.
- Interactive recommendation elements must be keyboard reachable and screen-reader understandable.

## 6. Analytics expectations

- UI implementations must emit telemetry for impression, click, save, add-to-cart, purchase, and dismiss events where supported.
- Event payloads must include recommendation set ID and surface context.
- UI experiments must preserve consistent event semantics across variants.

## 7. Shared component expectations

- Where channels share front-end component libraries, recommendation modules should reuse common patterns for layout, tracking hooks, and fallback states.
- Channel-specific adaptations should not change the core meaning of recommendation types or event semantics.

## 8. Content and merchandising expectations

- Recommendation presentation should respect brand presentation standards and seasonal merchandising priorities.
- Outfit recommendations should avoid visually or semantically conflicting combinations even if individual items score well on narrow metrics.
