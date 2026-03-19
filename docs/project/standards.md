# Standards

## Purpose
Define the cross-cutting standards that all downstream project artifacts and implementations should follow.

## Practical usage
Use this document as the baseline for naming, traceability, quality, review readiness, and cross-domain consistency across the project.

## Source
- GitHub issue #37: Master product spec: AI Outfit Intelligence Platform (SuitSupply Recommendation Engine)

## Domain terminology standards
Use the following terms consistently:
- Look: the platform-level grouping of compatible items and recommendation logic.
- Outfit: the customer-facing complete-look expression.
- Style profile: the customer representation derived from behavior, purchases, preferences, and context.
- Recommendation: a governed output that may be an outfit, cross-sell, upsell, style bundle, contextual, occasion-based, or personal suggestion.
- Merchandising rule: a business-authored control over inclusion, exclusion, ordering, or channel eligibility.
- RTW: Ready-to-Wear product and recommendation flows.
- CM: Custom Made product and recommendation flows.

## Documentation standards
- `docs/project/` is the canonical source-of-truth layer for product and delivery context.
- Documents must be concrete and implementation-oriented, not high-level marketing summaries.
- Every downstream artifact should identify its source inputs and trace back to the relevant project documents.
- Unknowns must be recorded explicitly as missing decisions rather than hidden in ambiguous language.
- File names should be lowercase with hyphens.

## Traceability standards
- Requirements, architecture, implementation plans, and reviews should preserve identifiers and source references.
- Recommendation outputs should be traceable to a recommendation set ID and trace ID.
- Business rules, curated looks, campaign overrides, and experiments should be attributable to an actor or system process.
- Cross-channel customer identity mappings should preserve source identifiers and confidence metadata.

## Quality standards
- Favor complete-look compatibility over simplistic item similarity.
- Support curated, rule-based, and AI-ranked recommendation sources with explicit precedence and fallback behavior.
- Never expose unavailable inventory on customer-facing surfaces.
- Ensure telemetry covers impression, click, save, add-to-cart, purchase, dismiss, and override events where the surface supports them.
- Preserve brand alignment and merchandising governance in all customer-visible recommendation experiences.

## Delivery and lifecycle standards
When boards and stage artifacts are created later, use the lifecycle states exactly as follows:
- TODO
- IN_PROGRESS
- NEEDS_REVIEW
- IN_REVIEW
- CHANGES_REQUESTED
- READY_FOR_HUMAN_APPROVAL
- APPROVED
- DONE

Additional delivery expectations:
- Do not skip review or dependency checks when promoting work between stages.
- Approval mode should be explicit when later boards are seeded.
- Downstream work should prefer narrow, auditable changes over broad speculative rewrites.

## API, data, UI, and integration assumptions
- APIs should be versioned, stable, and contract-oriented.
- Data contracts should use canonical IDs, schema validation, and explicit ownership boundaries.
- UI surfaces should use consistent empty, loading, fallback, and recommendation-explanation patterns.
- Integrations should define timeout, retry, idempotency, authentication, and observability behavior up front.

## Governance standards
- Respect customer consent and regional data policy requirements.
- Do not expose sensitive profile reasoning in customer-facing copy.
- Ensure merchandising overrides and experiment changes are auditable.
- Preserve a safe fallback path when personalization inputs are missing or degraded.

## Review-readiness standards
A downstream artifact is only ready for promotion when it is:
- clear enough for another agent or team to act on without guessing
- complete enough to avoid hidden dependencies
- explicit about assumptions and missing decisions
- consistent with the project vocabulary and scope boundaries
