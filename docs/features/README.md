# Feature specifications (`docs/features/`)

This directory holds **feature-spec deep dives**: implementation-oriented specifications for major platform capabilities, derived from canonical product documentation and business-requirements (BR) artifacts.

## Source of truth

Authoritative inputs live under:

- **`docs/project/`** — vision, goals, problem statement, personas, product overview, business requirements, roadmap, architecture overview, standards, operating model, review rubrics, and related standards (for example data standards).
- **`docs/project/br/`** — BR deep dives where they exist (for example `br-006-customer-signal-usage.md`, `br-007-context-aware-logic.md`).

Feature specs in this folder **must** stay aligned with that material and record traceability to the specific files used.

## What belongs here

- One markdown file per major feature (see `feature-spec-index.md` for the agreed set and filenames).
- Each spec follows the structure defined in `docs/.cursor/prompts/bootstrap-feature-deep-dives.md` (required sections 1–30, plus **31. Assumptions** and **32. Open Questions / Missing Decisions**).

## `deep-dives/reviews/`

Structured review passes for individual feature specs: strengths, gaps, scorecards, confidence, and a **recommendation** focused on readiness for the feature-spec milestone. Reviews do not replace human approval where the operating model requires it.

## `audits/`

Shorter audits that check depth, cross-module clarity, contract coverage, and whether delivery teams could execute from the spec. Verdicts are **Pass**, **Pass with minor improvements**, or **Needs revision**.

## Note on BR-8 (catalog / inventory awareness)

There is **no** dedicated `docs/project/br/br-008-*.md` deep-dive file in this repository. The **catalog and eligibility foundation** feature spec is therefore sourced from **`docs/project/business-requirements.md`** (BR-8 and related catalog workflow language), plus **`docs/project/architecture-overview.md`**, **`docs/project/product-overview.md`**, **`docs/project/roadmap.md`**, **`docs/project/data-standards.md`**, and **`docs/project/standards.md`**, as cited in that spec’s traceability block.

## Terminology

Use repo terminology consistently: **look** vs **outfit**, **RTW** vs **CM**, **curated** / **rule-based** / **AI-ranked**, and **surface** (e.g. PDP, cart) vs **channel** (e.g. ecommerce, email, clienteling). See `docs/project/standards.md`.
