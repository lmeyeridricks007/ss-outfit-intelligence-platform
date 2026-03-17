# Project Standards

**Purpose:** Cross-cutting standards for lifecycle, promotion rules, naming, and delivery state. Used by boards, agents, reviews, and automation.  
**Source:** Review rubrics, agent operating model, boards README, feature list, roadmap.  
**Traceability:** Referenced by boards, review outputs, agent-operating-model, and prompts; aligns with `docs/project/review-rubrics.md`.  
**Status:** Living document; update when process or naming changes.  
**Review:** Standards-stage artifact; assess per `docs/project/review-rubrics.md` (clarity, completeness, consistency).  
**Approval mode:** HUMAN_REQUIRED for material changes to standards; this doc does not assert approval of any board item.

---

## Related Standards Documents

- **Review rubrics:** `docs/project/review-rubrics.md` — scoring dimensions, thresholds, approval modes, required review output.
- **Agent operating model:** `docs/project/agent-operating-model.md` — workflow stages, promotion pattern, board structure, automation vs human gates.
- **Boards:** `docs/boards/README.md` — board file structure, Current Items, promotion rules per board.
- **Industry standards & best practices:** `docs/project/industry-standards-and-best-practices.md` — recommendation and personalization norms.
- **Data, API, domain:** `docs/project/data-standards.md`, `docs/project/api-standards.md`, and recommendation-domain-language rule.

---

## Lifecycle

Every stage follows the same baseline loop. No artifact should bypass it.

```
Create → Review → Edit → Review → Ready for human approval → Approved → Done
```

- **Create:** Work is drafted (artifact or board item created).
- **Review:** Artifact is reviewed per `docs/project/review-rubrics.md` (disposition, scored dimensions, confidence, recommendation).
- **Edit:** If review returns CHANGES_REQUESTED, rework is done; human rejection comments must be folded into the artifact and any invalidated upstream docs.
- **Review (again):** Re-review until thresholds are met.
- **Ready for human approval:** When review recommends promotion and approval mode is HUMAN_REQUIRED, item moves to READY_FOR_HUMAN_APPROVAL; a named human decision is required next.
- **Approved:** Human (or governed auto-approval when AUTO_APPROVE_ALLOWED) approves; item may promote to next stage.
- **Done:** Work and any merge-aware checks are complete; item is closed or archived as the board defines.

Automation-triggered reviews may accelerate the loop but do not remove the need for human approval or merge-aware completion where the stage requires it.

---

## Delivery State Model

Board items use a **standard state set**. Each board file declares allowed states in its **Lifecycle States** section; the canonical set is:

| State | Meaning |
|--------|--------|
| `TODO` | Not started; backlog. |
| `IN_PROGRESS` | Work in progress. |
| `NEEDS_REVIEW` | Work complete; ready for review. |
| `IN_REVIEW` | Under review (agent or human). |
| `CHANGES_REQUESTED` | Review requested rework; do not promote until updated and re-reviewed. |
| `READY_FOR_HUMAN_APPROVAL` | Review passed; awaiting human approval (when approval mode is HUMAN_REQUIRED). |
| `APPROVED` | Approved; may promote to next stage or mark DONE per board rules. |
| `DONE` | Required work and any merge-aware checks are complete. |

**Transitions:**

- Promotion to the **next stage** happens only from `APPROVED`. Do not promote from READY_FOR_HUMAN_APPROVAL without explicit approval.
- If approval mode is `AUTO_APPROVE_ALLOWED`, a passing review may move directly from `IN_REVIEW` to `APPROVED` when the stage is so configured.
- When a human rejects with comments, set (or keep) status to `CHANGES_REQUESTED`; the next agent pass must incorporate comments and re-submit for review.
- If a board item depends on **merge or CI**, it cannot be marked effectively done until the relevant GitHub state exists; use GitHub Actions for deterministic post-merge promotion where applicable.

---

## Promotion Rules

- **Approval mode** must be declared per board item or stage:
  - **`HUMAN_REQUIRED`:** A passing review moves the item to `READY_FOR_HUMAN_APPROVAL`. A named human must approve before `APPROVED` or promotion.
  - **`AUTO_APPROVE_ALLOWED`:** A passing review may move the item directly to `APPROVED` when the configured window explicitly allows it. Use only for clearly bounded phases (e.g. rapid decomposition); restore a human gate before high-impact stages.

- **Review thresholds** (from `docs/project/review-rubrics.md`):
  - Average score **below 3.5** or **any dimension ≤ 2** → automatic `CHANGES_REQUESTED`.
  - Average **3.5–4.1** with no dimension below 3 → may remain in review with targeted edits.
  - Average **above 4.1** with **no dimension below 4** → eligible for promotion after review; move to READY_FOR_HUMAN_APPROVAL (if HUMAN_REQUIRED) or to APPROVED (if AUTO_APPROVE_ALLOWED and so configured).

- **Required review output:** Every review must produce disposition, scored dimensions, confidence, blocking issues, recommended edits, explicit recommendation (READY_FOR_HUMAN_APPROVAL / APPROVED / CHANGES_REQUESTED), propagation note, and (when relevant) what must still be confirmed by GitHub Actions or human before completion.

- **Stage-specific promotion:** Business requirements promote to features only after scope and value are approved; features to architecture after decomposition and dependencies; architecture to implementation plan after contracts and boundaries; implementation plan to build boards after sequencing; build to QA after readiness; QA to release after defects resolved or accepted. Milestone human gates (e.g. UI readiness before backend) block downstream promotion until the gate is passed.

---

## Naming Conventions

### Paths and locations

- **Project context:** `docs/project/` — architecture, BRs, roadmap, standards, glossary, domain model, data/API standards.
- **Boards:** `docs/boards/` — one markdown file per stage (e.g. `business-requirements.md`, `features.md`, `implementation-plan.md`). Live board = **Current Items** (or **Board**) table in the same file.
- **Feature specs:** `docs/features/` — one deep-dive per feature; sub-features under `docs/features/sub-features/{feature-name}/`.

### Identifiers

- **Features:** `F1`–`F26` (from `docs/project/feature-list.md`). Use in boards, issues, and docs (e.g. “F11 Delivery API”).
- **Business requirements:** `BR-1`–`BR-12` (from business requirements). Use in feature list, specs, and architecture.
- **Phases:** `phase-1` … `phase-5` for roadmap and labels (e.g. GitHub issue labels). Phase 0 = foundation (no features).
- **Board item IDs:** Stable per stage (e.g. `BR-001`, `ARCH-004`). Format is stage-specific; document in each board’s Item Structure.

### States and approval

- **Lifecycle states:** `UPPER_SNAKE_CASE` — e.g. `TODO`, `IN_PROGRESS`, `NEEDS_REVIEW`, `IN_REVIEW`, `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, `DONE`.
- **Approval modes:** `HUMAN_REQUIRED`, `AUTO_APPROVE_ALLOWED` (exact spelling in artifacts and boards).

### Terminology (product)

- **Look** = product grouping (curated set of SKUs). **Outfit** = customer-facing complete look. See `docs/project/glossary.md`.
- **Placement**, **channel**, **recommendation set ID**, **trace ID** — per glossary and domain model; use consistently in specs and APIs.

---

## Working Principles

1. **GitHub** is the source of truth for work state and history (issues, PRs, code, merge, approvals).
2. **Cursor Cloud Agents** are the primary repo-aware execution engine for drafting, reviewing, and implementation support.
3. **Cursor Automations** may trigger agent work when events or schedules simplify the workflow.
4. **GitHub Actions** remain the deterministic automation layer for CI, merge-aware state changes, safety checks, and explicit promotion logic.
5. **Humans** approve stage transitions that materially change scope, architecture, live behavior, or release readiness.

---

## Hybrid Orchestration Standards

### Use Cursor Automations when

- An issue event should trigger intake or planning help.
- A PR event should trigger an agent review pass.
- A schedule should scan for stale items, waiting reviews, or next-ready work (without being the final authority).

### Keep GitHub Actions when

- Checks must be deterministic and auditable.
- Post-merge state transitions depend on merge success.
- Promotion logic must run only after explicit GitHub conditions (e.g. merge, CI green).

### Never use Cursor Automations to

- Replace human approval gates.
- Mark board items `APPROVED` or `DONE` without evidence and required approvals.
- Imply final approval or deterministic completion when the stage requires human or merge confirmation.

Review agents may recommend status changes but must not collapse review, approval, and completion into a single step. If auto-approval is enabled for a stage, the approval-mode setting must be visible in the artifact or board so reviewers can distinguish governed auto-approval from accidental skipping.

---

## References

- **Review rubrics:** `docs/project/review-rubrics.md`
- **Agent operating model:** `docs/project/agent-operating-model.md`
- **Boards README:** `docs/boards/README.md`
- **Feature list:** `docs/project/feature-list.md`
- **Glossary:** `docs/project/glossary.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Project standards (this document).  
**Stage:** Standards / cross-cutting process.  
**Approval mode:** HUMAN_REQUIRED for material changes to standards.

### Overall disposition

**Eligible for promotion.** The standards doc is complete for lifecycle, delivery state model, promotion rules, and naming; it aligns with review-rubrics and agent-operating-model. All dimensions score 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL** for any material change to this doc.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Scope, intent, and structure (lifecycle, state model, promotion, naming, working principles, orchestration) are clear without restating the prompt. |
| **Completeness** | 5 | Required areas covered: lifecycle loop, delivery state set and transitions, promotion rules and thresholds, naming (paths, identifiers, states, terminology), working principles, hybrid orchestration; dependencies and edge cases (merge/CI, rework propagation) included. |
| **Implementation Readiness** | 5 | Boards, agents, and reviewers can apply the standards; next stage (using the doc) can proceed with limited ambiguity. |
| **Consistency With Standards** | 5 | Aligns with review-rubrics (thresholds, approval modes, required review output) and agent-operating-model (states, promotion pattern); terminology matches glossary and feature-list. |
| **Correctness Of Dependencies** | 5 | Source docs (review-rubrics, agent-operating-model, boards README, feature-list, glossary) referenced accurately; no incorrect upstream/downstream claims. |
| **Automation Safety** | 5 | Doc states guardrails (never replace human gates, never mark APPROVED/DONE without evidence); does not imply approval or completion of any board item. |

**Average:** 5.0. **Minimum dimension:** 5.

### Confidence rating

**HIGH.** Inputs (review-rubrics, agent-operating-model, boards) are stable; scope and usage are clear; standards are actionable.

### Blocking issues

**None.**

### Recommended edits

**None required.** Optional: when escalation rules (from review-rubrics) are invoked in practice, consider adding a one-line reference or cross-link here.

### Explicit recommendation

Per approval mode **HUMAN_REQUIRED** for changes to standards: this artifact is suitable for use as the cross-cutting reference. Any material edit to the standards doc should be reviewed and moved to READY_FOR_HUMAN_APPROVAL before adoption. No automatic APPROVED implied for any board item.

### Propagation to upstream

**None required.** No human rejection comments. If review-rubrics or agent-operating-model change, update this doc to stay aligned.

### Pending confirmation

- **Human approval** for any material change to this standards document.
- Downstream (boards, agents, prompts) should continue to reference this doc and review-rubrics for consistent behavior.
