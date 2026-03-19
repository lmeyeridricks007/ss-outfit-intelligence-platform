# UI Standards

## Purpose
Define cross-surface interface expectations for recommendation modules and internal control surfaces.

## Practical usage
Use these standards when designing customer-facing widgets, look-builder experiences, and internal merchandising or clienteling interfaces.

## UI consistency principles
- Recommendation modules should present complete-look intent clearly, not as a generic related-items carousel.
- Surfaces should distinguish recommendation types when it helps user understanding, such as outfit versus upsell.
- Customer-facing interfaces should keep copy simple and brand-aligned; internal interfaces may expose richer provenance and debugging details.
- RTW and CM interfaces may differ in interaction depth, but should reuse shared terminology where possible.

## Accessibility expectations
- Recommendation components must support keyboard navigation, screen-reader labeling, and sufficient contrast.
- State changes such as loading, saved, error, or add-to-cart feedback must be perceivable to assistive technologies.
- Important outfit-composition information should not be conveyed only through imagery or color.

## State and feedback patterns
Every consuming surface should define:
- loading state behavior
- empty state behavior
- fallback state behavior when personalization is unavailable
- error handling behavior when recommendations cannot be loaded
- inventory or availability feedback behavior

Recommended behavior:
- Fall back to curated or rule-based recommendations when personalization inputs are missing.
- Avoid empty modules on high-value surfaces unless policy requires suppression.
- Make unavailable or low-confidence items non-actionable or remove them before display.

## Recommendation explanation patterns
- Customer-facing rationale should be concise and non-sensitive, for example season, occasion, or "pairs well with" language.
- Internal surfaces may expose richer explanation data such as source type, applied rule, and confidence or eligibility notes.
- Do not expose sensitive profile reasoning or internal-only signals directly to customers.

## Shared component expectations
- Recommendation cards should reuse common product identity, pricing, availability, and imagery patterns.
- Complete-look modules should make outfit composition visually understandable and easy to act on.
- Internal editing tools should support preview, override, and audit-friendly change workflows.

## Analytics and telemetry expectations
- UI events must preserve recommendation set ID and trace ID.
- Impression measurement rules should be explicit per surface to avoid inconsistent reporting.
- User interactions such as click, save, dismiss, and add-to-cart should map to the shared telemetry model.
