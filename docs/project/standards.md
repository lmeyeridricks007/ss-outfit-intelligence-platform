# Standards

## Purpose

This document defines cross-cutting standards for the AI Outfit Intelligence Platform so later requirements, architecture, planning, and implementation work remain consistent.

## Documentation standards

- `docs/project/` is the canonical source of truth for project-level product, architecture, and operating guidance.
- New downstream artifacts must trace back to these bootstrap docs and identify the upstream source they elaborate.
- Requirements should use stable identifiers where practical (for example `BR-001`).
- Open questions must remain explicit until resolved; downstream artifacts must not silently assume an answer.
- Documents should prefer implementation usefulness over marketing language.

## Terminology standards

- Use **look** for the internal grouping of compatible products.
- Use **outfit** for the customer-facing complete-look concept.
- Use **recommendation set** for a served unit of recommendations tied to a request, surface, and context.
- Distinguish **RTW** and **CM** when logic, workflows, or constraints differ.
- Distinguish **curated**, **rule-based**, and **AI-ranked** inputs when describing recommendation logic.

## Product and delivery standards

- Recommendation experiences must optimize for complete-look usefulness, not only product similarity.
- Merchandising control is a first-class requirement; production recommendation behavior must be governable.
- Customer-facing recommendation quality must include compatibility, availability, and context relevance.
- Anonymous users and known customers must both be supported, with safe fallback behavior when signals are sparse.
- Recommendation outputs should be measurable across surface, audience, variant, and recommendation type.

## Naming and structure expectations

- Use stable canonical IDs for products, customers, looks, campaigns, rules, and experiments.
- Preserve source-system identifier mappings rather than overwriting them.
- Use consistent names for recommendation types across APIs, telemetry, and UI.
- Group platform capabilities into reusable services rather than channel-specific one-off logic wherever practical.

## Traceability expectations

- Feature, architecture, and implementation artifacts must reference the business requirements and roadmap phases they satisfy.
- Recommendation logic changes should be traceable to either a curated rule, experiment, or versioned implementation change.
- Telemetry should tie outcomes back to recommendation set ID and variant context.
- Open questions affecting downstream work must be copied forward until resolved by an explicit decision.

## Quality expectations

- Recommendations should be stylistically coherent before being considered optimized.
- Every production-facing recommendation surface should define fallback behavior.
- Cross-category outputs must respect compatibility constraints and brand presentation standards.
- Performance measurement must include both engagement and downstream business outcomes where feasible.
- Production launches should support controlled rollout and experimentability.

## Lifecycle and status expectations

When the project later introduces board-based stage tracking, use the standard lifecycle states:

- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Approval behavior and promotion rules should be explicit in the relevant artifact or board item; they must not be assumed.

## API assumptions

- Recommendation delivery should use versioned contracts.
- Request and response schemas should be consistent across channels unless a documented adapter is required.
- Responses should include metadata needed for attribution, troubleshooting, and experimentation.

See also: `api-standards.md`.

## Data assumptions

- Data usage must be consent-aware and region-appropriate.
- Identity resolution should record mapping confidence.
- Event and telemetry schemas should preserve timestamps, source, channel, and recommendation context.
- Freshness expectations must be explicit by data domain.

See also: `data-standards.md`.

## UI assumptions

- User-facing recommendation modules should clearly communicate item purpose within an outfit or bundle.
- Surfaces should handle loading, empty, fallback, and unavailable states consistently.
- Accessibility and analytics are mandatory, not optional.

See also: `ui-standards.md`.

## Integration assumptions

- External system integrations must define ownership, retry behavior, timeouts, and failure handling.
- Secrets and credentials must be handled through secure runtime configuration, never hardcoded artifacts.
- Source-system dependency limits and freshness characteristics should be documented before launch.

See also: `integration-standards.md`.

## Automation and governance guardrails

- Do not present recommendations that use customer data outside allowed consent or regional policy boundaries.
- Do not treat recommendation output as ungoverned model output; operator controls and auditability are required.
- Do not mark delivery work complete without evidence from review, integration validation, and applicable GitHub/CI state.
