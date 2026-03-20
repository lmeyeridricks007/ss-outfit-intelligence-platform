# Standards

## Purpose
This document defines cross-cutting standards for product artifacts, delivery work, and platform behavior. Detailed standards for APIs, data, UI, and integrations are split into companion documents where needed.

## Canonical project documentation
- `docs/project/` is the canonical source-of-truth layer for product intent, scope, architecture direction, and delivery standards.
- Product terminology must stay consistent across all artifacts, issues, and implementation specs.
- When assumptions are required, record them explicitly rather than implying certainty.
- New feature or implementation artifacts should trace back to these bootstrap docs.

## Core domain terminology
- **Outfit:** the customer-facing complete-look recommendation.
- **Look:** the underlying curated or modeled combination of products used to compose an outfit.
- **Recommendation type:** one of outfit, cross-sell, upsell, curated style bundle, occasion-based, contextual, or personal.
- **RTW:** Ready-to-Wear product flows.
- **CM:** Custom Made product flows.
- **Curated:** selected by merchandising or styling teams.
- **Rule-based:** generated or filtered by explicit business or compatibility logic.
- **AI-ranked:** ordered by learned or model-assisted scoring.

## Naming and structure expectations
- Prefer clear business-facing names for documents, APIs, events, rules, and surfaces.
- Maintain stable identifiers for products, customers, looks, recommendation sets, campaigns, experiments, and rules.
- Use the same surface names across docs and code: PDP, cart, homepage, inspiration, email, clienteling, mobile/API.
- Separate product-level documentation from downstream feature or implementation artifacts.

## Delivery lifecycle expectations
When work moves beyond bootstrap, use the exact lifecycle states defined by the operating model:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Do not invent alternate state names for stage or board tracking.

## Documentation expectations
- Every major artifact should state scope, dependencies, assumptions, and open questions.
- Architecture and implementation documents must distinguish confirmed decisions from provisional direction.
- Requirements should remain implementation-oriented without locking in unnecessary low-level design.
- Downstream artifacts should reference their upstream requirement or roadmap context.

## Traceability expectations
- Recommendation outputs must be traceable to their inputs, rules, campaign context, and ranking version.
- Customer-affecting changes must be attributable to a rule change, experiment, campaign, or model update.
- Metrics and experiments should be linked to the consuming surface and recommendation type.
- Internal governance actions such as overrides, approvals, and rollbacks should be auditable.

## Quality expectations
- Customer-facing recommendations must be stylistically coherent, contextually relevant, and availability-aware.
- Internal tools must support preview, validation, and rollback before broad activation.
- Platform changes should include validation for fallback behavior and degraded-data scenarios.
- Recommendation quality should be measured both by engagement signals and by downstream business outcomes.

## Cross-cutting API, data, UI, and integration standards
- APIs should be versioned, contract-first, and explicit about recommendation metadata.
- Data handling must respect consent, privacy, identifier ownership, and event auditability.
- UI experiences should explain recommendation value clearly and provide consistent interaction patterns.
- Integrations should define ownership, authentication, retry behavior, and observability.

See also:
- `docs/project/api-standards.md`
- `docs/project/data-standards.md`
- `docs/project/ui-standards.md`
- `docs/project/integration-standards.md`
