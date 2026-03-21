# UI Standards

## Purpose
Define shared UI expectations for customer-facing recommendation surfaces and internal operator interfaces.

## Practical usage
Use this document when designing recommendation modules, style inspiration pages, clienteling views, and merchandising interfaces.

## UI consistency principles
- Distinguish complete outfits from isolated item recommendations clearly.
- Make recommendation intent legible through module labels, grouping, and item relationships.
- Use consistent recommendation-type naming across surfaces.

## Accessibility expectations
- Support semantic structure, keyboard access, visible focus, sufficient contrast, and accessible media alternatives.
- Do not depend exclusively on color or imagery to communicate recommendation meaning.

## State and feedback patterns
- Define loading, empty, error, and degraded-fallback states for each recommendation surface.
- If personalization is unavailable, render a safe fallback rather than a broken or misleading module.
- Operator interfaces should show rule or campaign context where it affects decisions.

## Telemetry expectations
- UI surfaces must emit recommendation telemetry consistent with `docs/project/data-standards.md`.
- Track impression, click, add-to-cart, dismiss, purchase, and override where relevant.
- Include recommendation set ID and trace ID in emitted events when available.

## Shared component expectations
- Prefer reusable patterns for recommendation cards, look groupings, module headers, and explanation affordances.
- Keep merchandising or internal explanation details separate from customer-facing language unless intentionally designed.
