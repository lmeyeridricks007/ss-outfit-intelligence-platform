# Standards

## Artifact metadata
- **Upstream source:** Repository rules and GitHub issue #37 master product description.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Shared authoring, review, and terminology guidance for every later artifact.
- **Key assumption:** The repository will introduce boards and stage artifacts after bootstrap, so standards must be usable before code delivery begins.
- **Missing decisions:** Board schemas and stage-specific artifact templates can be added later without changing these baseline standards.

## Purpose
Define cross-cutting standards for documents, delivery artifacts, terminology, traceability, and quality across the AI Outfit Intelligence Platform repository.

## Naming and structure
- Use lowercase kebab-case filenames for docs.
- Treat `docs/project/` as the canonical product and workflow layer.
- Keep stage artifacts separated by purpose: project docs, business requirements, architecture, implementation plans, build artifacts, and QA artifacts.
- Prefer tables and explicit lists when they make downstream action easier.

## Required terminology
Use these terms consistently:
- **look**: the modeled group of compatible items maintained by curation or rules.
- **outfit**: the customer-facing complete-look recommendation concept.
- **recommendation**: any ranked or selected suggestion output by the platform.
- **style profile**: the customer preference and history context used for personalization.
- **merchandising rule**: an operator-defined control that constrains or prioritizes recommendation behavior.
- **RTW**: Ready-to-Wear products and flows.
- **CM**: Custom Made products and flows.

## Recommendation-source language
When relevant, specify whether a recommendation is:
- curated;
- rule-based;
- AI-ranked;
- or a blend of the above.

Do not describe the platform as a simple similarity engine when the requirement is complete-look and context-aware recommendation.

## Lifecycle and review expectations
Use the exact lifecycle states defined in `agent-operating-model.md`:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Use `review-rubrics.md` for scoring and disposition. Do not invent alternative scoring systems or lifecycle labels.

## Traceability expectations
Every non-trivial artifact should record:
- its upstream source or parent artifact;
- the next intended downstream artifact or board stage;
- assumptions;
- missing decisions;
- any milestone gate or approval-mode interpretation that affects downstream work.

## Documentation standards
- Write for downstream execution, not only for summary.
- Separate confirmed scope from assumptions and open questions.
- Record missing decisions explicitly rather than leaving ambiguity implicit.
- Avoid hiding critical constraints in prose when a table or bullet list would be clearer.
- Keep product and business artifacts free of unnecessary technical implementation detail, but concrete enough for architecture to start.

## Quality standards
- Recommendation outputs should be measurable through consistent telemetry.
- Customer-facing experiences should avoid exposing sensitive profile reasoning.
- Inventory, availability, and compatibility constraints should be treated as hard-quality requirements for live recommendations.
- Operator controls should be auditable and role-appropriate.
- New work should include a clear validation approach before it is considered complete.

## API, data, UI, and integration assumptions
- APIs should be contract-first and preserve recommendation tracing metadata.
- Data models should use stable canonical identifiers and explicit source mappings.
- UI surfaces should communicate loading, empty, fallback, and unavailable states clearly.
- Integrations should define ownership, retries, timeouts, and failure handling explicitly.

## Automation and approval safety
- Automation may draft, review, and propose, but it must not overclaim approval or production completion without the configured evidence.
- Human-required stages remain human-required unless the recorded approval path explicitly allows otherwise.
- Autonomous runs may complete commit and push behavior, but artifacts must still state unresolved gates and dependencies honestly.

## Missing-decision rule
If a topic matters to product scope, governance, or downstream implementation and the source material does not settle it, record it as `Missing decision` in the artifact instead of guessing.
