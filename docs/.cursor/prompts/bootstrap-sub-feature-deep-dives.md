# Bootstrap: Sub-Feature Deep-Dive Specifications

You are an AI Product Architect and System Designer working inside this repository.

Your task is to break down the product into **deep feature specifications and sub-feature capability specifications**.

This process should create **fine-grained implementation documentation**, not just feature summaries.

Each feature must be decomposed into smaller capability modules and documented in separate files.

The goal is to produce documentation detailed enough for engineers to implement the system.

## PRODUCT CONTEXT

Use all existing documentation as source of truth:
- Feature deep-dives in `docs/features/`
- Project docs in `docs/project/`

## GOAL

Create **fine-grained feature documentation** structured as:

```
Feature
   → Sub-Feature
       → Detailed capability specification
```

Each sub-feature should be documented separately.

## STEP 1 — IDENTIFY CORE FEATURES

Identify all major features/modules of the product from:

`docs/features/feature-spec-index.md`

Create:

`docs/features/feature-index.md`

Include:

- feature name
- description
- priority
- dependencies

## STEP 2 — BREAK FEATURES INTO SUB-FEATURES

Each feature must be decomposed into smaller capability areas.

Example:

Feature: Bill Processing

Sub-features:
- bill-upload
- bill-storage
- bill-parsing
- bill-normalization
- bill-validation
- bill-history
- bill-deduplication
- bill-reprocessing

Each sub-feature must become its own markdown document.

## STEP 3 — CREATE SUB-FEATURE SPEC FILES

Create a folder for each feature:

`docs/features/sub-features/{feature-name}/`

Example:

- `docs/features/sub-features/bill-processing/`
- `docs/features/sub-features/recommendations/`
- `docs/features/sub-features/tariff-intelligence/`

Inside each folder create a spec file for each sub-feature.

Example:

- `bill-upload.md`
- `bill-storage.md`
- `bill-parsing.md`
- `bill-normalization.md`
- `bill-validation.md`

## REQUIRED SPEC STRUCTURE

Each sub-feature spec must include detailed sections:

1. Purpose
2. Core Concept
3. User Problems Solved
4. Trigger Conditions
5. Inputs
6. Outputs
7. Workflow / Lifecycle
8. Business Rules
9. Configuration Model
10. Data Model
11. API Endpoints
12. Events Produced
13. Events Consumed
14. Integrations
15. UI Components
16. UI Screens
17. Permissions & Security
18. Error Handling
19. Edge Cases
20. Performance Considerations
21. Observability
22. Example Scenarios
23. Implementation Notes
24. Testing Requirements

The level of detail should be similar to a full module specification.

## STEP 4 — CREATE EXAMPLE FLOWS

Each sub-feature must include concrete examples.

Examples:

- API payloads
- database records
- event payloads
- UI interaction flows
- job execution flows

## STEP 5 — IMPLEMENTATION IMPLICATIONS

Each spec must explicitly describe:

- backend services involved
- database tables required
- jobs/workers required
- external APIs required
- frontend components required
- shared UI components required

## STEP 6 — ITERATION PROCESS

For each sub-feature spec:

1. Generate initial spec
2. Create a review document

`docs/features/deep-dives/reviews/`

The review must evaluate:

- clarity
- completeness
- workflow coverage
- data coverage
- integration coverage
- edge cases

3. Generate improved version
4. Repeat review

Continue until:

- every score ≥ 9/10
- confidence ≥ 95%

## STEP 7 — AUDIT

When a spec reaches threshold quality, run a final audit.

Store in:

`docs/features/sub-features/audits/`

Audit must check:

- internal consistency
- missing workflows
- missing integrations
- missing technical detail
- scalability risks

Audit verdict:

- Pass
- Pass with improvements
- Needs revision

## QUALITY REQUIREMENTS

Every specification must be:

- detailed
- structured
- implementation-oriented
- technically precise
- consistent with architecture

Avoid shallow descriptions.

The documentation should be actionable by engineers.

## COMMIT AND PUSH

After generating all sub-feature capability specifications:

1. Commit all changes with a clear message (e.g., "docs(features): generate sub-feature capability specifications")
2. Push to the branch provided by the orchestrator
3. Do NOT create downstream architecture/build issues in this milestone

Begin now.
