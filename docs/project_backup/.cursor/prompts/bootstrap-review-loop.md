# Bootstrap Review Loop

## Purpose

Apply a practical review-and-improve loop to the initial bootstrap docs so the first generated project documentation is coherent, useful, and suitable as source material for later stages.

This bootstrap review loop is lighter than a fully human-gated approval workflow, but it must still preserve quality discipline.

## Required Inputs

Read:
- `docs/project/review-rubrics.md`
- the newly drafted bootstrap docs in `docs/project/`

At minimum review:
- `vision.md`
- `goals.md`
- `problem-statement.md`
- `personas.md`
- `product-overview.md`
- `business-requirements.md`
- `roadmap.md`
- `architecture-overview.md`
- `standards.md`

Also review optional standards docs if created.

## Review Objective

Check whether the bootstrap docs are:
- internally consistent
- clear
- sufficiently complete for later feature/spec generation
- sufficiently concrete for later architecture and implementation planning
- aligned with the issue that triggered the run

## Review Dimensions

Use the rubric in `docs/project/review-rubrics.md`, especially:
- Clarity
- Completeness
- Implementation Readiness
- Consistency With Standards
- Correctness Of Dependencies
- Automation Safety

For bootstrap docs, interpret them as:
- clear enough for downstream agents
- complete enough to derive features and roadmap phases
- concrete enough to support later architecture and planning
- safe enough not to overstate certainty where the issue is vague

## Required Review Process

1. Generate first-pass docs.
2. Review them as a set, not only file-by-file.
3. Identify:
   - missing business detail
   - missing user detail
   - missing roadmap logic
   - missing architecture assumptions
   - contradictions between docs
   - scope ambiguity
   - unclear terminology
4. Improve the docs.
5. Perform one more pass for consistency and implementation usefulness.
6. Finalize the bootstrap docs for commit.

## Practical Threshold For Bootstrap

For this bootstrap flow, do not block waiting for human approval.

Instead:
- improve until the docs are coherent and practically usable;
- explicitly record notable assumptions or unresolved questions;
- preserve open questions rather than pretending they are resolved.

## What “Good Enough” Means Here

The bootstrap output is ready when:
- the product can be understood from the docs alone
- the business requirements are explicit
- the roadmap has useful phases
- the architecture overview is directionally clear
- standards are sufficient to guide later generation
- downstream feature/spec generation would have enough context to proceed

## Required Cross-Doc Checks

Verify that:
- `vision.md` and `goals.md` are aligned
- `problem-statement.md` and `personas.md` describe the same user reality
- `product-overview.md` reflects the business requirements
- `roadmap.md` matches the product scope
- `architecture-overview.md` supports the intended product workflows
- `standards.md` does not contradict the architecture or product shape

## Output Behavior

Do not create separate review artifacts unless the repository already expects them for bootstrap.
Instead:
- improve the docs directly
- mention key assumptions and unresolved questions in the final issue response or relevant doc sections

## Finalization Rules

Once the docs are coherent:
- commit and push the bootstrap docs
- do not stop for manual review in this bootstrap flow
- do not create downstream issues yet
- do not seed boards yet

## Final Issue Response Guidance

When responding on the issue, include:
- which docs were created
- the major assumptions made
- the biggest open questions still unresolved
- confirmation that the repo now has a usable initial project doc layer