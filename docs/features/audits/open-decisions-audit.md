# Open decisions feature audit

**Scope:** `docs/features/open-decisions.md`  
**Method:** Check whether the portfolio-level open-decisions deep-dive is concrete enough for architecture and implementation planning, with sufficient detail on traceability, lifecycle semantics, owner expectations, dependency impact, and safe downstream handling of unresolved choices.  
**Trigger source:** Issue-created automation for GitHub issue #180

---

## Depth

**Sufficient.** The document now goes beyond a flat register and defines the operating model for how portfolio-level uncertainty should be recorded, referenced, triaged, and reconciled. It includes feature-stage purpose, lifecycle semantics, business rules, derived decision views, owner emphasis, phase guidance, and the full canonical decision table.

## Feature abstraction check

**Not too abstract.** The deep-dive names concrete artifact contracts, explicit update rules, conceptual decision states, recommended resolution timing, and failure modes such as hidden uncertainty, stale reconciliations, ID reuse, and upstream-truth drift.

## Interaction clarity

**Clear.** Interactions with feature deep-dives, canonical `docs/project/` sources, BR artifacts, review outputs, and downstream architecture/planning artifacts are directly described. The document makes it clear that resolved truth must flow back into canonical sources first before this register and dependent feature specs are reconciled.

## API / events / data sufficiency

**Appropriate for a documentation-stage feature.** There is no runtime API to freeze here, but the artifact-level contract is explicit:

- feature docs must reference stable `DEC-###` IDs
- portfolio decisions must remain semantically stable across review cycles
- downstream resolution artifacts must update the proper source-of-truth layer first
- the decision register preserves the canonical record shape needed for cross-feature traceability

This is enough for architecture and planning teams to rely on the register safely.

## UI and backend implications

**Covered at the right level.** The markdown-first information design is intentional and sufficient for the repository’s stage workflow. Backend implications are represented as repository-process expectations rather than software services, which is appropriate for this feature.

## Implementability assessment

**Pass.** Downstream stages can now use this feature as a reliable portfolio dependency and decision-handling artifact. The document is explicit enough that architecture and implementation-planning work can distinguish:

- acceptable feature-stage uncertainty
- decisions that are Phase 1 or architecture critical
- owner groups responsible for resolution
- canonical docs that must change when a decision resolves

---

## Verdict

**Pass**

The open-decisions feature deep-dive is now specific enough for safe downstream architecture and planning work. It preserves the original decision register while making the repository’s missing-decision handling materially clearer and more implementation-ready.

---

## Minor improvements to consider later

1. If the repository formalizes machine-readable decision tracking, add explicit fields for status, resolution stage, and canonical update target rather than deriving them from prose.
2. If architecture creates a dependency map or handoff dashboard, add a direct cross-link from this file’s priority buckets to those downstream artifacts.
