# Feature specifications (`docs/features`)

## Purpose

This folder holds **implementation-oriented deep-dive specifications** for major capabilities of the AI Outfit Intelligence Platform. Each spec decomposes product intent from `docs/project/` and `docs/project/br/` into concrete behavior, data, APIs, events, UI, governance, and telemetry expectations suitable for architecture, planning, and build stages.

Canonical upstream context lives in:

- `docs/project/vision.md`, `goals.md`, `problem-statement.md`, `personas.md`, `product-overview.md`, `business-requirements.md`, `roadmap.md`, `architecture-overview.md`, `standards.md`, `data-standards.md`, `glossary.md`
- Individual business requirements under `docs/project/br/` (BR-001 through BR-012)

## How to use these specs

1. **Start from the index** — `feature-spec-index.md` lists every feature file, priority, dependencies, and BR mapping.
2. **Read the relevant feature file** when scoping architecture (`docs/architecture/`), implementation plans (`docs/implementation/`), or surface-specific build work.
3. **Preserve traceability** — Each feature file cites upstream BR IDs and project docs; when you change product truth in `docs/project/` or BR artifacts, update affected feature specs or record explicit deferrals.
4. **Treat missing decisions as first-class** — Specs call out unresolved business or technical choices; do not silently invent decisions in downstream artifacts without updating upstream docs.

## Phase framing (roadmap alignment)

Specs align with `docs/project/roadmap.md`:

| Phase | Theme | What these specs assume |
| --- | --- | --- |
| Phase 0 | Foundation | Vocabulary, standards, and BR taxonomy are stable enough for feature decomposition. |
| Phase 1 | Core ecommerce RTW | PDP/cart, outfit/cross-sell/upsell types, delivery API, catalog/inventory gates, governance baseline, telemetry, traces. |
| Phase 2 | Context and personalization | Identity/profile, context engine, occasion-led and expanded ecommerce, email where dependencies are met. |
| Phase 3 | Operator scale and channels | Clienteling, richer governance UX, cross-channel reporting and experimentation maturity. |
| Phase 4 | CM depth | Configuration-aware CM logic, premium paths, advanced ranking—after RTW maturity. |

Each feature file’s **Suggested Implementation Phasing** section states Phase 1 vs later explicitly.

## Traceability expectations

- **BR → feature:** `feature-spec-index.md` maps each file to one or more BR IDs.
- **Feature → downstream:** Architecture and plans should reference feature filenames or stable feature names used in the index.
- **Telemetry:** Recommendation **recommendation set ID**, **trace ID**, and event taxonomy follow `docs/project/data-standards.md`.
- **Terminology:** Use `docs/project/glossary.md` (e.g. *look* vs *outfit*, recommendation *types*, RTW vs CM).
- **Open decisions:** Cross-cutting unresolved items are consolidated in `open-decisions.md` so downstream stages can resolve them without scanning every feature file.

## Relationship to `docs/project` and `docs/project/br`

- **`docs/project/`** — Product vision, goals, roadmap, architecture overview, cross-cutting standards. Feature specs **interpret and operationalize** this layer; they do not replace it.
- **`docs/project/br/*.md`** — Formal business requirements (BR-001–BR-012). Feature specs **trace to** BR IDs and surface assumptions or gaps where BR text leaves room for engineering judgment.

When BRs and feature specs diverge, **BRs and `business-requirements.md` win** unless the repo records an explicit change decision.

## Reviews and audits

- Portfolio review: `deep-dives/reviews/feature-spec-portfolio-review.md` (rubric-scored review artifact for the feature portfolio; originally produced from the issue #167 batch and later refined in the dedicated FEAT-008 review pass).
- Portfolio audit: `audits/feature-spec-portfolio-audit.md` (depth, implementability, cross-module clarity).
- Portfolio open decisions: `open-decisions.md` (deduplicated unresolved product, architecture, analytics, and governance choices referenced by the feature specs, with owners and downstream impact).
- Open decisions review and audit: `deep-dives/reviews/open-decisions-review.md` and `audits/open-decisions-audit.md` (dedicated FEAT-013 refinement evidence for the portfolio decision register).

## File naming

Feature files use **lowercase kebab-case** per `docs/project/standards.md`.
