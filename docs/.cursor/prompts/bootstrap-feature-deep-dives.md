# Bootstrap: Feature Deep-Dive Specifications

You are an AI Product Architect and Feature Specification Writer operating inside this repository.

Your job is to create a dedicated deep-dive specification file for EACH major feature/module in this product.

This is NOT a lightweight feature list.

The goal is to produce highly detailed, implementation-grade feature/module specifications, with one dedicated markdown file per feature.

Each feature spec must explain in fine-grained detail:
- what the feature is
- why it exists
- how it works
- how it behaves
- what triggers it
- what data it owns or uses
- how users interact with it
- how it integrates with other modules
- what APIs, workflows, states, rules, UI, and edge cases it needs
- how it should be implemented

The level of detail should be similar to a full deep-dive module spec such as a Tasks module specification.

## OBJECTIVE

Generate deep-dive specification files for all major product capabilities/features.

These files must go beyond high-level feature descriptions and become module-level design documents.

They must be detailed enough for:
- product managers
- architects
- backend engineers
- frontend engineers
- QA engineers

## SOURCE OF TRUTH

Use the approved/final documentation in this repository as source of truth:
- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/problem-statement.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## OUTPUT FOLDER STRUCTURE

Create if not present:

```
docs/features
```

Also create:

- `docs/features/README.md`
- `docs/features/feature-spec-index.md`

## STEP 1 — IDENTIFY FEATURES

First identify all major features/modules of the product and create:

`docs/features/feature-spec-index.md`

This index must include:
- feature/module name
- short description
- priority
- dependencies
- file name

The list must include all major product capabilities required for the full product.

Do not stop at a shallow list.

## STEP 2 — GENERATE ONE FILE PER FEATURE

For each identified feature/module, create a dedicated markdown file in:

`docs/features/`

Examples:
- `authentication.md`
- `organizations.md`
- `locations.md`
- `bill-upload.md`
- `bill-parsing.md`
- `bills-and-data.md`
- `tariff-catalog.md`
- `tariff-comparison.md`
- `consumption-analysis.md`
- `recommendations.md`
- `anomalies-and-alerts.md`
- `reports.md`
- `connectors.md`
- `notifications.md`
- `settings.md`
- `admin-configuration.md`

If a shared operational workflow feature similar to Tasks exists, include it too.

## REQUIRED STRUCTURE FOR EACH FEATURE FILE

Every feature/module deep-dive file must use a detailed structure like this:

1. Purpose
2. Core Concept
3. Why This Feature Exists
4. User / Business Problems Solved
5. Scope
6. In Scope
7. Out of Scope
8. Main User Personas
9. Main User Journeys
10. Triggering Events / Inputs
11. States / Lifecycle
12. Business Rules
13. Configuration Model
14. Data Model
15. Read Model / Projection Needs
16. APIs / Contracts
17. Events / Async Flows
18. UI / UX Design
19. Main Screens / Components
20. Permissions / Security Rules
21. Notifications / Alerts / Side Effects
22. Integrations / Dependencies
23. Edge Cases / Failure Cases
24. Non-Functional Requirements
25. Analytics / Auditability Requirements
26. Testing Requirements
27. Recommended Architecture
28. Recommended Technical Design
29. Suggested Implementation Phasing
30. Summary

## LEVEL OF DETAIL REQUIREMENT

These must be true deep-dives.

For each feature, include detailed subsections where relevant such as:
- trigger types
- rule evaluation
- state transition examples
- example data records
- example APIs
- example events
- example UI layouts
- example workflows
- cross-module interactions
- admin configuration details
- reporting/read model implications
- implementation guidance

Do not keep sections shallow.

If a feature needs additional sections beyond the required list, add them.

## IMPORTANT REQUIREMENTS

1. Each feature gets its own file.
2. Each file must be detailed and implementation-oriented.
3. Do not reduce to MVP-only thinking.
4. Cover the full product design.
5. Align with existing architecture and stack.
6. Be concrete, not generic.
7. Where useful, include examples.
8. Explicitly define interactions with other modules.
9. Explicitly define backend, frontend, and data implications.

## ITERATION WORKFLOW

For each feature file, follow this process:

STEP 1 — Create the first version
STEP 2 — Review it critically
STEP 3 — Improve it
STEP 4 — Review again
STEP 5 — Audit it
STEP 6 — Finalize it

## REVIEW REQUIREMENTS

Store reviews in:

`docs/features/deep-dives/reviews/`

Each review must include:
1. Overall Assessment
2. Strengths
3. Missing Business Detail
4. Missing Workflow Detail
5. Missing Data / API Detail
6. Missing UI Detail
7. Missing Integration Detail
8. Missing Edge Cases
9. Missing Implementation Detail
10. Suggested Improvements
11. Scorecard
12. Confidence Rating
13. Recommendation

Review categories:
- clarity
- completeness
- functional depth
- technical usefulness
- cross-module consistency
- implementation readiness

Threshold:
- every score >= 9/10
- confidence >= 95%

## AUDIT REQUIREMENTS

Store audits in:

`docs/features/audits/`

Audit must check:
- depth is sufficient
- feature is not still too abstract
- interactions with other modules are clear
- APIs/events/data are sufficiently specified
- UI and backend implications are covered
- implementation teams could act on the document

Audit verdict:
- Pass
- Pass with minor improvements
- Needs revision

## FINAL OUTPUT

Store final files in:

`docs/features/`

## COMMIT AND PUSH

After generating all feature deep-dive files:

1. Commit all changes with a clear message (e.g., "docs(features): generate feature deep-dive specifications")
2. Push to the branch provided by the orchestrator
3. Do NOT create downstream architecture/build issues in this milestone

Begin now.
