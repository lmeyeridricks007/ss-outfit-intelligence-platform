# Bootstrap Project Docs

## Purpose

Define the exact initial project documents that must be created for a brand-new project from a master bootstrap issue.

These docs form the canonical `docs/project/` source-of-truth layer that later stages will depend on.

## Required Outputs

### 1. `docs/project/vision.md`

Must include:
- product vision
- long-term product ambition
- differentiators
- intended market or user impact
- why this product should exist

### 2. `docs/project/goals.md`

Must include:
- business goals
- user goals
- operational goals
- success criteria
- non-goals

### 3. `docs/project/problem-statement.md`

Must include:
- current problem
- who experiences it
- why current alternatives are insufficient
- urgency / why now
- consequence of not solving it

### 4. `docs/project/personas.md`

Must include:
- primary personas
- secondary personas if relevant
- their goals
- pain points
- behaviors
- decision-making context
- what success looks like for them

### 5. `docs/project/product-overview.md`

Must include:
- what the product is
- major user journeys
- primary surfaces/channels
- major workflows
- major capability areas
- high-level product boundaries

### 6. `docs/project/business-requirements.md`

Must include:
- business requirements for the product as a whole or the first intended release scope
- clear scope boundaries
- in-scope and out-of-scope items
- target users
- business value
- success measures
- major workflows
- constraints
- assumptions
- open questions
- approval or governance notes if relevant

### 7. `docs/project/roadmap.md`

Must include:
- phased delivery view
- recommended delivery order
- major phases
- key themes per phase
- what should happen earlier vs later
- dependencies between phases
- practical test/review checkpoints

The roadmap should be useful later for:
- issue fan-out
- phase-controlled UI/backend/integration work
- stop/continue decisions

### 8. `docs/project/architecture-overview.md`

Must include:
- high-level system view
- major subsystems or component areas
- data flow overview
- external integrations at a high level
- key technical boundaries
- operational assumptions
- implementation-oriented constraints

This is not full feature architecture yet. It is a product-level architecture overview.

### 9. `docs/project/standards.md`

Must include:
- cross-cutting delivery and design standards
- naming and structure expectations
- lifecycle and status expectations if useful
- documentation expectations
- traceability expectations
- quality expectations
- assumptions about APIs, data, UI, and integrations at a cross-cutting level

## Optional Standards Docs

Create these only if the product clearly needs them at bootstrap time.

### `docs/project/api-standards.md`
Create if the product clearly involves APIs, services, or contracts.

Should include:
- API style guidance
- versioning approach
- error model
- authentication expectations
- contract consistency rules

### `docs/project/data-standards.md`
Create if the product clearly involves significant structured data.

Should include:
- key data principles
- identifiers and ownership expectations
- event/data consistency rules
- privacy/governance expectations
- auditability expectations

### `docs/project/ui-standards.md`
Create if the product clearly has a user-facing interface.

Should include:
- UI consistency principles
- accessibility expectations
- state and feedback patterns
- analytics/telemetry expectations
- shared component expectations

### `docs/project/integration-standards.md`
Create if the product clearly depends on external/internal integrations.

Should include:
- integration principles
- auth and secret handling expectations
- retries/timeouts/idempotency guidance
- observability expectations
- dependency management expectations

## Authoring Rules

1. Be concrete, not generic.
2. Do not write placeholder fluff.
3. Use the issue body as the primary source of truth.
4. If the issue is incomplete, make reasonable bounded assumptions and call them out explicitly.
5. Keep terminology consistent across all docs.
6. Write docs that later prompts can use as source material.
7. Prefer implementation usefulness over marketing language.

## Output Quality Bar

Each document should be good enough that a later agent can reliably:
- generate feature deep-dives
- generate sub-feature specs
- seed boards
- plan architecture
- create implementation plans

## Explicit Non-Goals For This Prompt

Do not:
- create `docs/features/` deep-dives yet
- create sub-feature specs yet
- create board rows
- create GitHub issues
- create phase-specific build artifacts