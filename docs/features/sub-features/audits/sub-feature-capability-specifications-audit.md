# Sub-feature capability specifications audit

**Artifact under audit:** `docs/features/feature-index.md` and `docs/features/sub-features/`  
**Primary audit file:** `docs/features/sub-features/audits/sub-feature-capability-specifications-audit.md`  
**Trigger source:** Issue-created automation for GitHub issue #184  
**References:** `docs/.cursor/prompts/bootstrap-sub-feature-deep-dives.md`, `docs/.cursor/prompts/bootstrap-feature-review-loop.md`, `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`

---

## Scope

This audit covers:

- `docs/features/feature-index.md`
- `docs/features/sub-features/README.md`
- 13 feature folders under `docs/features/sub-features/`
- 78 capability-spec markdown files under those folders
- review evidence in `docs/features/deep-dives/reviews/sub-feature-capability-specifications-review.md`

The audit checks whether the generated capability portfolio is concrete enough for the **feature-to-architecture and feature-to-planning handoff** without inventing unresolved architecture or policy decisions.

## Audit method

The generated docs were checked against the repository prompts and canonical feature-stage sources by verifying:

1. every indexed feature from `docs/features/feature-spec-index.md` has a matching sub-feature folder;
2. every generated spec follows the required 24-section structure from `bootstrap-sub-feature-deep-dives.md`;
3. parent-feature traceability and `DEC-###` references remain visible in each file;
4. the docs cover APIs, events, data, UI, integrations, observability, implementation notes, and tests at a capability level rather than only repeating feature summaries; and
5. review posture and approval language stay consistent with `docs/project/review-rubrics.md` and `docs/project/agent-operating-model.md`.

## Portfolio inventory snapshot

| Portfolio area | Current state |
| --- | --- |
| Parent feature inventory | 13 indexed features |
| Generated capability specs | 78 files under `docs/features/sub-features/` |
| Support docs | `docs/features/feature-index.md`, `docs/features/sub-features/README.md` |
| Review evidence | `docs/features/deep-dives/reviews/sub-feature-capability-specifications-review.md` |
| Audit coverage | this file |

## Canonical-source alignment

**Aligned.** The generated capability set references the existing feature deep-dives and project standards instead of replacing them. Each file points back to the relevant parent feature and preserves the open decisions already recorded in `docs/features/open-decisions.md`.

No required canonical source was missing during this pass, so no `needs-info` escalation was required.

## Structural consistency

**Passed.** The generated specs use one consistent structure across the portfolio:

- bounded capability title and parent-feature metadata
- 24 required sections from the bootstrap prompt
- illustrative API, event, and payload examples
- implementation notes that call out services, storage, jobs, external integrations, and UI implications
- testing requirements and observability guidance in each file

## Depth

**Adequate for feature-stage sub-feature documentation.** The portfolio does more than restate feature names: it breaks the feature deep-dives into implementable capability slices such as request normalization, readiness evaluation, governance snapshot building, attribution, activation envelopes, context precedence, package freshness checks, and mode-aware fallback.

The remaining uncertainty is intentionally bounded by existing `DEC-###` items, not hidden as shallow drafting.

## Concreteness

**Good.** Each capability spec names:

- concrete inputs and outputs
- lifecycle or workflow steps
- data entities and illustrative APIs
- events produced and consumed
- UI, security, error, edge-case, and observability implications

This is sufficient for architecture and implementation planning teams to continue decomposition without first rewriting the feature stage from scratch.

## Cross-module clarity

**Strong.** The capability set preserves the system-level connections already present in the feature deep-dives:

- shared delivery and trace IDs flow into analytics and explainability
- catalog readiness, governance, and decisioning boundaries remain explicit
- identity, consent, and personalization posture stay distinct but connected
- ecommerce, email, clienteling, RTW, and CM consumers are described as channel or mode consumers of one platform rather than separate product silos

## Automation safety and approval notes

This audit is **descriptive evidence**, not a board-state transition.

- The trigger source is automation, and that is stated explicitly here.
- This audit does **not** claim the artifact set is `APPROVED` or `DONE`.
- Approval mode is not recorded on the audited artifact set itself, so this audit should be interpreted as readiness evidence for the normal repository approval path.

## Verdict

**Pass**

The generated sub-feature capability portfolio is suitable as the feature-stage decomposition layer under `docs/features/sub-features/`. It is concrete enough for downstream architecture and implementation planning work while keeping unresolved contract, policy, and rollout decisions visible and traceable.

## Non-blocking improvement suggestions

1. When architecture artifacts are created later, add direct cross-links from each sub-feature spec to its downstream architecture or plan artifact.
2. If the repository formalizes portfolio-wide `FEAT-###` IDs beyond the existing feature-stage references, update `docs/features/feature-index.md` and related review artifacts together.
3. Replace the illustrative API examples in the generated specs with normative architecture references once transport and schema decisions are finalized.
