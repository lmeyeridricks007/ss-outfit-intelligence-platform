# UI Standards

## Purpose

Define shared UI standards for customer-facing and internal recommendation experiences powered by the AI Outfit Intelligence Platform.

## Practical usage

Use this document when designing recommendation widgets, look exploration flows, clienteling interfaces, merchandising controls, and analytics-facing admin views.

## UI consistency principles

1. Present recommendations as coherent outfit or complementary decisions, not as an unstructured list of unrelated products.
2. Make the customer's next action obvious: explore the look, add an item, refine the outfit, or save it.
3. Preserve a consistent mental model across PDP, cart, homepage, email, and clienteling surfaces.
4. Show inventory or availability constraints clearly when they affect the recommendation.
5. Keep explanation cues helpful and brand-safe without exposing overly technical model reasoning.

## Shared experience expectations

### Recommendation presentation

Recommendation UI should clearly communicate:
- the recommendation type, when relevant
- the anchor context, such as current product, occasion, or personal relevance
- the key items in the outfit or recommendation set
- clear calls to action for add-to-cart, explore, or save flows

### Recommendation card or module anatomy

Where a surface uses cards or modules, include as many of the following as appropriate:
- look or outfit title
- primary imagery
- key included items
- price summary or price range where useful
- contextual label such as seasonal, occasion-based, or because-you-bought
- availability or fallback handling

## Accessibility expectations

- Follow accessible semantic structure for headings, lists, buttons, and grouped recommendation modules.
- Ensure keyboard navigation works for interactive recommendation items and look builders.
- Provide meaningful text alternatives for recommendation imagery.
- Avoid using color alone to communicate recommendation state or priority.
- Preserve readable loading, empty, and error states for screen-reader users.

## State and feedback patterns

Design explicit states for:
- loading recommendation modules
- empty or no-match conditions
- fallback recommendations when personalization is unavailable
- unavailable or low-inventory items
- save, dismiss, or add-to-cart feedback
- experiment or personalization variants that may alter presentation

Surfaces should fail gracefully. If complete-look recommendations are unavailable, show the best supported fallback rather than a broken container.

## Analytics and telemetry expectations

UI implementations must emit the recommendation telemetry required by `docs/project/data-standards.md`, including impression and downstream interaction events.

At minimum, UI layers should preserve:
- `recommendationSetId`
- `traceId`
- `recommendationType`
- `surface`
- relevant `productId` or `lookId`

## Shared component expectations

- Reuse common recommendation module patterns where possible across shopper surfaces.
- Keep internal and external components aligned on shared metadata even if visual design differs.
- Do not hard-code channel-specific interpretation of recommendation types that conflicts with API contracts.

## Surface-specific notes

### PDP and cart

- Optimize for quick outfit completion and complementary-item confidence.
- Keep modules compact enough to support conversion-oriented layouts.

### Homepage and inspiration surfaces

- Allow broader look storytelling and occasion-led discovery.
- Support more exploratory layouts than PDP or cart.

### Email

- Ensure recommendation content can degrade gracefully when richer interactive behavior is unavailable.
- Preserve identifiers needed for click-through attribution.

### Clienteling and internal tools

- Show enough recommendation context, rule influence, and customer state to support human judgment.
- Make overrides or substitutions explicit when supported.

### Merchandising or admin interfaces

- Prioritize clarity of rule impact, preview behavior, and auditability over customer-facing polish.

## Missing decisions

- Missing decision: how much explanatory text should appear on customer-facing surfaces versus only internal tools.
- Missing decision: whether saved looks and dismiss actions are supported in the first shopper-facing release.
