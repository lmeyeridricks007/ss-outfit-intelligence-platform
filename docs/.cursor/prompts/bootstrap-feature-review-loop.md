# Bootstrap: Feature Review Loop

Apply a **review pass** while generating feature and sub-feature deep-dive documentation. This keeps quality high without requiring manual approval for this milestone.

## Instructions

1. **Read `docs/project/review-rubrics.md`** if it exists. **If it does not exist**, do not stop — apply general good-practice: clarity, consistency, completeness relative to the source docs, and sensible structure.

2. **Read `docs/project/agent-operating-model.md`** if present, for any agent-specific expectations (e.g. how to commit, what to document).

3. **First-pass review**: After drafting feature or sub-feature specs, run a practical first-pass review:
   - If rubrics exist, check each doc against them and improve where suggested.
   - If no rubrics file exists, use a minimal bar: consistent formatting, no contradictory statements across docs, coverage of the required sections.
   - Do **not** block waiting for human approval; complete the review pass and then commit.

4. **Review criteria** (from `docs/project/review-rubrics.md` if available):
   - **Clarity** — Language is clear and unambiguous; a new reader can understand intent.
   - **Consistency** — Terminology and structure are consistent across docs; no contradictory statements.
   - **Completeness** — Docs cover the scope implied by the source (e.g. feature spec, project docs); gaps are called out.
   - **Structure** — Sensible headings, lists, and cross-references; easy to navigate.
   - **Functional depth** — Detailed enough for implementation teams to act on.
   - **Technical usefulness** — APIs, data models, workflows are sufficiently specified.
   - **Cross-module consistency** — Interactions with other modules are clear.

5. **Outcome**: Generate and commit the full feature/sub-feature doc set. Never refuse to generate docs because `review-rubrics.md`, `agent-operating-model.md`, or other supporting docs are missing.

## Do not

- Wait for a human to approve before committing. This run is autonomous for the feature deep-dive milestone.
- **Stop or skip doc generation** because supporting files (review-rubrics, agent-operating-model) are missing. Proceed with the feature deep-dive prompts and project/feature docs.
- Add process or labels that assume a separate "review" step in the issue workflow. The review is your internal pass before commit.
- Create downstream architecture/build issues in this milestone. Stop at generated docs.

## Preserve assumptions

- Explicitly document any assumptions made during spec generation.
- Call out unresolved questions rather than hiding them.
- Note where more information is needed for later stages.
