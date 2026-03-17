# Rules

## Purpose
Persistent project guidance for agents working in the AI Outfit Intelligence Platform repository. Rules are **`.mdc`** files (Markdown with YAML frontmatter) in `.cursor/rules/`. They apply to all agent runs; doc/board rules also apply when editing files under their `globs` patterns.

## File format
- **Extension:** `.mdc` (preferred for rules with frontmatter; Cursor supports both `.md` and `.mdc`).
- **Frontmatter:** `description` (required), optional `globs`, optional `alwaysApply: true/false`.
- **Body:** Markdown. Keep rules actionable and referenced to project docs where detail lives.

## Rules (complete set)

### project-operating-model.mdc
**Always applied.** Enforces:
- Source of truth: `docs/project/`, `boards/`, GitHub; artifact locations (`.cursor/prompts/`, `.cursor/rules/`, `.cursor/skills/`).
- Lifecycle and promotion: exact states, approval mode, evidence-based promotion, no skipped gates.
- **Traceability:** Link artifacts across stages; update upstream when rejection invalidates assumptions.
- **Completeness:** Produce complete requirements, feature sets, and deliverables; no artificial caps; record unknown items as missing decisions.
- Roles: Cloud Agents, Automations, GitHub Actions, Humans.

### docs-and-boards-standards.mdc
**Applied when editing `docs/**/*.md` or `boards/**/*.md`.** Enforces:
- Implementation-oriented content; explicit dependencies, readiness, and exit criteria.
- **Missing decisions:** Record unknowns as missing decisions; do not invent or omit.
- Terminology (glossary) and lifecycle states (exact spelling).
- Board structure: required columns (ID, Status, Owner, Reviewer, Approval Mode, Notes, etc.); Approval Mode and Notes usage.
- Document structure and naming (standards.md).

### recommendation-domain-language.mdc
**Always applied.** Enforces:
- Recommendation framing (complete-look, context-aware); recommendation types and consuming surfaces; look vs outfit.
- RTW vs CM; curated vs rule-based vs AI-ranked.
- Merchandising, analytics, governance; event/telemetry alignment with data-standards (recommendation set ID, trace ID).
- Identity (canonical IDs, source mappings, identity resolution confidence); privacy and consent.

### review-rigor.mdc
**Always applied.** Enforces:
- Scoring and disposition from `review-rubrics.md` (six dimensions, thresholds, approval-mode application).
- Confidence handling; stage-specific focus (requirements, architecture, build, QA).
- Rejection and rework: treat human comments as required rework; identify upstream artifacts to update.
- Escalation triggers (scope conflict, architecture trade-offs, org decisions, legal/policy, non-convergence, automation vs human state).
- Automation-triggered reviews: state trigger; do not collapse review/approval/completion.

### automation-safety.mdc
**Always applied.** Enforces:
- Authority boundaries: automation may draft, review, suggest; may not approve or complete without evidence and configured path.
- Never: replace human gates; set APPROVED/DONE without evidence; replace CI; invent approval mode.
- Stop conditions: insufficient context (request clarification); wrong or missing target (do not suggest status changes).
- Transparency: state trigger; narrow mutations; state evidence and remaining human/deterministic validation.

### approval-and-rework.mdc
**Always applied.** Enforces:
- Approval mode: HUMAN_REQUIRED (recommend READY_FOR_HUMAN_APPROVAL only; APPROVED only with human evidence); AUTO_APPROVE_ALLOWED (may recommend APPROVED when review passes).
- Milestone human gates: block downstream until gate approved; record in Notes or plan.
- Human rejection: set CHANGES_REQUESTED; treat comments as rework inputs; update current and upstream artifacts; do not self-approve after rework; list upstream artifacts to revise.

## Coverage summary
Together the rules cover: operating model and roles, traceability and completeness, docs and board structure and terminology, domain language and data/identity, review scoring and escalation, automation authority and stop conditions, and approval-mode and rejection-rework behavior. For full detail, see the linked project docs in each rule.
