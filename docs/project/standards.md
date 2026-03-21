# Standards

## Purpose
Define the cross-cutting standards for documentation, delivery, naming, quality, lifecycle, and traceability for the AI Outfit Intelligence Platform.

## Practical usage
Use this document whenever creating or reviewing artifacts under `docs/`, `boards/`, APIs, data contracts, UI work, and integration plans.

## Core standards
1. Prefer implementation-oriented artifacts over generic summaries.
2. Record assumptions and missing decisions explicitly; do not hide uncertainty.
3. Use the project glossary consistently: look, outfit, style profile, recommendation, merchandising rule, RTW, and CM are required terms.
4. Keep recommendation logic explainable to internal operators even when ranking uses ML.
5. Preserve governance, traceability, and auditability as first-class product concerns.

## Naming and structure expectations
- Use lowercase kebab-case for documentation files.
- Use stable identifiers for board and stage items, such as BR-001 and FEAT-001.
- Name recommendation types explicitly: outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal.
- Separate canonical product docs in `docs/project/` from downstream feature or implementation artifacts.

## Delivery lifecycle expectations
Use lifecycle states exactly as follows:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Approval mode must be explicit on board items:
- `HUMAN_REQUIRED`
- `AUTO_APPROVE_ALLOWED`

Do not invent alternate states or assume approval mode when it is not recorded.

## Documentation expectations
Every source-of-truth artifact should include:
- purpose
- practical usage
- clear scope boundaries
- assumptions
- missing decisions where relevant
- dependencies or downstream implications when relevant

## Traceability expectations
- Canonical product docs must support downstream BR, feature, architecture, plan, build, and QA artifacts without reinterpretation.
- Recommendation delivery must include recommendation set IDs and trace IDs.
- Telemetry must preserve linkage between recommendation delivery, rule context, experiment context, and outcomes.
- Rule changes, overrides, and campaign priorities must be auditable.

## Quality expectations
- Recommendations must be stylistically coherent, not only statistically correlated.
- Inventory-invalid items must not be presented without an intentional fallback policy.
- Personalization must degrade gracefully when identity confidence or consent is insufficient.
- Cross-channel consumers must share a common contract and taxonomy.
- Downstream artifacts should be concrete enough that the next stage can proceed without guessing.

## API assumptions
- APIs should be contract-first and versioned.
- Error responses should be structured, stable, and safe for consumer handling.
- Authentication, authorization, trace IDs, and idempotency rules should be documented for integrations.

## Data assumptions
- Stable canonical IDs are required across products, customers, looks, campaigns, rules, recommendation sets, and experiments.
- Event timestamps should be normalized and timezone-safe.
- Source provenance and identity confidence should be preserved rather than flattened away.
- Privacy and consent constraints must be enforceable in data access and activation flows.

## UI assumptions
- Recommendation modules should clearly distinguish complete outfits from isolated item suggestions.
- UI should expose enough context for customers and operators to understand the recommendation intent.
- Loading, empty, fallback, and degraded states are required for recommendation surfaces.

## Integration assumptions
- External dependencies must define retries, timeout behavior, fallback behavior, and secret handling.
- Integration contracts should specify freshness expectations and ownership boundaries.

## Never use automation to
- bypass required human approvals where approval mode demands them
- mark work as done without merge or CI evidence when those are required
- invent missing business decisions or approval modes
- replace deterministic policy enforcement that should live in code or CI
