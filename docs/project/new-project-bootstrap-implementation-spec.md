# New Project Bootstrap Implementation Spec

## Artifact metadata
- **Upstream source:** Repository bootstrap prompts and GitHub issue #37 master product description.
- **Bootstrap stage:** Bootstrap support documentation.
- **Next downstream use:** Future bootstrap runs and validation of required bootstrap outputs.
- **Key assumption:** New-project bootstrap may need to create directly required support docs when a fresh repository does not yet contain them.
- **Missing decisions:** No additional bootstrap-only decisions remain beyond the product-scope questions tracked in the main project docs.

## Purpose
Define what a bootstrap run must produce in this repository when the project starts from a single master product description and no canonical `docs/project/` layer exists yet.

## Scope of the bootstrap run
The bootstrap run should create the minimum document set needed for later agents to work responsibly.

### Required canonical docs
- `vision.md`
- `goals.md`
- `problem-statement.md`
- `personas.md`
- `product-overview.md`
- `business-requirements.md`
- `roadmap.md`
- `architecture-overview.md`
- `standards.md`

### Required supporting docs when absent but referenced by prompts or rules
- `review-rubrics.md`
- `agent-operating-model.md`

### Conditional standards docs
Create these during bootstrap when the product clearly depends on them:
- `api-standards.md`
- `data-standards.md`
- `ui-standards.md`
- `integration-standards.md`

## What bootstrap docs must enable
Later agents should be able to:
- write business requirements for distinct capabilities without restating the entire product;
- derive feature areas and architecture candidates;
- understand phase order and why it exists;
- respect data, privacy, and identity constraints;
- know how review, approval, and traceability are supposed to work.

## Authoring expectations
- Be implementation-oriented rather than promotional.
- Use consistent domain language: look, outfit, recommendation, style profile, merchandising rule, RTW, CM.
- Call out assumptions and missing decisions explicitly.
- Avoid downstream issue fan-out, sub-feature specs, or board seeding in the bootstrap run.
- Keep architecture high level but concrete enough for later decomposition.

## Review expectations
A bootstrap run should include an internal consistency pass covering:
- vision versus goals;
- problem statement versus personas;
- product overview versus business requirements;
- roadmap versus architecture sequence;
- standards versus product and architecture shape.

## Completion criteria
The bootstrap run is complete when:
- the required docs exist under `docs/project/`;
- the docs are coherent as a set;
- the biggest unresolved decisions are recorded rather than implied;
- the branch is committed, pushed, and ready for downstream phased delivery work.
