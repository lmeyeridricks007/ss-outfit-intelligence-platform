# Standards

## Purpose

Define the cross-cutting delivery, documentation, naming, lifecycle, and quality standards for the AI Outfit Intelligence Platform project.

## Practical usage

Use this document as the default standards reference when creating requirements, architecture, plans, reviews, APIs, data contracts, UI artifacts, integrations, and board items.

## Cross-cutting principles

1. Prefer implementation-oriented documentation over general summaries.
2. Record missing decisions explicitly; do not hide uncertainty or invent unsupported detail.
3. Keep recommendation behavior brand-safe, measurable, and traceable.
4. Treat curated looks, merchandising rules, and AI ranking as complementary layers, not competing systems.
5. Reuse shared platform contracts across channels whenever possible.
6. Build RTW and CM on shared foundations while allowing targeted logic differences.
7. Preserve clear boundaries between source systems, platform intelligence, and surface rendering.

## Required domain terminology

Use these terms consistently across project artifacts:

| Term | Meaning |
| --- | --- |
| `look` | The internally modeled grouping of compatible products and recommendation logic inputs. |
| `outfit` | The customer-facing complete-look concept presented on a surface. |
| `style profile` | The structured representation of customer taste, purchase history, behavior, and inferred preferences used for recommendation decisions. |
| `recommendation` | Any platform-generated suggestion, including outfit, cross-sell, upsell, contextual, or personal outputs. |
| `merchandising rule` | A governed business rule that constrains, prioritizes, excludes, or boosts recommendation outcomes. |
| `RTW` | Ready-to-Wear catalog recommendation context. |
| `CM` | Custom Made recommendation context for configured garments and premium options. |

## Naming and structure expectations

### Repository documentation

- Canonical project-level source-of-truth docs live in `docs/project/`.
- Future feature deep-dives should live outside the bootstrap doc set and reference the relevant project docs.
- File names should use lowercase with hyphens.
- Operational documents should begin with a clear purpose and practical usage section.

### Identifier conventions

- Use stable canonical IDs for products, customers, looks, rules, campaigns, experiments, recommendation sets, and trace records.
- Preserve source-system ID mappings explicitly rather than overloading one external ID as universal truth.
- Requirement and workflow identifiers should use readable prefixes such as `BR-001` and `WF-001`.

## Lifecycle and status expectations

Use lifecycle states exactly as follows:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Do not invent substitutes or abbreviations for these states in project artifacts or boards.

## Documentation expectations

- Every source-of-truth document should be understandable on its own and link back to upstream intent where relevant.
- Separate confirmed decisions, assumptions, and missing decisions.
- Call out dependencies, readiness criteria, and exit criteria when an artifact will drive downstream work.
- Prefer structured tables for requirements, phases, integrations, and metrics.
- Keep terminology consistent across vision, requirements, roadmap, architecture, and standards.

## Traceability expectations

- Business requirements should be traceable to later feature and architecture work.
- Recommendation surfaces, recommendation types, and major workflows should use stable names across artifacts.
- Recommendation events should preserve recommendation set identifiers and trace identifiers through downstream outcomes.
- If assumptions change, affected upstream and downstream artifacts should be updated together.

## Quality expectations

All project artifacts should be:
- clear enough that a later agent can act without guessing
- complete enough to support downstream planning
- explicit about dependencies and missing decisions
- consistent with the documented product scope
- cautious about privacy, governance, and automation authority

## Cross-cutting standards by discipline

### API expectations

- Recommendation APIs should use stable versioned contracts.
- Requests should accept structured context rather than channel-specific ad hoc parameters.
- Responses should include metadata for rendering, tracing, experimentation, and outcome measurement.
- Error handling should be predictable and machine-readable.

See also: `docs/project/api-standards.md`.

### Data expectations

- Event and entity schemas must use canonical identifiers and source mappings.
- Identity resolution confidence must be explicit where profile merges are not deterministic.
- Consent and regional privacy constraints must be represented in data use decisions.
- Recommendation outcome telemetry must support impression-to-purchase analysis.

See also: `docs/project/data-standards.md`.

### UI expectations

- Customer-facing surfaces should present recommendations in a way that emphasizes complete looks and clear next actions.
- Internal tools should surface recommendation context, rule influence, and actionable overrides where relevant.
- Loading, empty, fallback, and unavailable states must be designed intentionally.

See also: `docs/project/ui-standards.md`.

### Integration expectations

- External dependencies must have clear contracts, ownership, retry behavior, and observability.
- Recommendation-serving paths should not depend on unbounded latency from third-party context providers.
- Integration changes should be versioned and tested to avoid silent recommendation degradation.

See also: `docs/project/integration-standards.md`.

## Automation guardrails

Never use automation to:
- assume an approval mode that is not explicitly recorded
- mark work `APPROVED` or `DONE` without the required evidence
- replace human governance where the process requires human approval
- bypass milestone review gates when they are part of the delivery model
- claim production readiness when CI, merge state, or deterministic validation is still missing

Automation may draft artifacts, run reviews, summarize evidence, and complete autonomous bootstrap runs when that mode is explicitly enabled.

## Recommendation-specific standards

- Frame outputs as complete-look and context-aware recommendations, not only similar-item suggestions.
- Identify the recommendation type and consuming surface when describing behavior.
- Preserve merchandising control, analytics, and governance in production-facing features.
- Do not expose sensitive internal profile reasoning directly in customer-facing messaging.

## Missing decisions handling

- Use a dedicated `Missing decisions` section when unresolved choices affect scope, architecture, or delivery.
- Phrase each missing decision so a later owner can act on it directly.
- Do not use "TBD" as a substitute for a meaningful missing-decision statement.

## Standards review trigger

Update this standards layer when:
- new channels or recommendation types change shared assumptions
- identity, privacy, or governance requirements materially change
- later feature work exposes a missing cross-cutting standard that affects multiple downstream artifacts
