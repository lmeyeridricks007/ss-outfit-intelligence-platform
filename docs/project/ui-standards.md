# UI Standards

## Purpose

These standards apply to recommendation surfaces that expose outfit intelligence to customers, stylists, merchandisers, or operators. The goal is to create a consistent interaction model across surfaces without forcing identical presentation everywhere.

## Experience principles

- Present recommendations as style guidance, not as undifferentiated item grids.
- Make complete outfits and complementary items easy to understand from the anchor product or occasion context.
- Preserve brand credibility through visually coherent groupings and copy.
- Keep recommendations actionable with clear next steps such as view look, add item, save, or replace.

## Consistency expectations

- Recommendation surfaces should consistently distinguish complete outfits from single-item cross-sell or upsell suggestions.
- Recommendation modules should expose enough structure that analytics, experiments, and operator debugging remain comparable across channels.
- RTW and CM journeys may differ in interaction design, but their recommendation source and outcome tracking should remain consistent.

## Accessibility expectations

- Recommendation components should support keyboard navigation and screen-reader-friendly structure.
- Visual grouping, status, and feedback should not rely on color alone.
- Critical state changes such as loading, errors, or successful add-to-cart should be perceivable and clear.

## State and feedback patterns

- Support loading, empty, degraded, and unavailable states explicitly.
- When recommendation quality must fall back, the UI should remain coherent rather than showing broken or misleading modules.
- If a recommended item becomes unavailable, the UI should support either replacement or clear removal behavior.

## Explainability and trust

- Customer-facing explanation should be lightweight and brand-appropriate.
- Avoid exposing sensitive personal inference details.
- Internal operator interfaces may expose deeper diagnostic context than customer-facing surfaces.

## Analytics expectations

- UI interactions should emit telemetry that can be joined to the originating recommendation set.
- Track impression visibility, clicks, saves, dismissals, add-to-cart actions, and other surface-specific outcomes.
- Preserve experiment and variant context in emitted analytics events.

## Shared component expectations

- Reuse component patterns for recommendation cards, outfit groups, action controls, and fallback states where practical.
- Keep rendering concerns separate from recommendation decisioning so surfaces can evolve without rewriting platform logic.
