# Sub-Feature Capability Specifications

**Purpose:** Fine-grained implementation documentation for the AI Outfit Intelligence Platform. Each **feature** (see `docs/features/*.md`) is decomposed into **sub-features**, and each sub-feature is documented in a separate capability spec.  
**Source:** Parent feature specs in `docs/features/`, `docs/project/feature-list.md`, architecture, domain model.  
**Traceability:** Sub-features implement capabilities described in parent feature specs; feed implementation tasks and build boards.  
**Approval mode:** HUMAN_REQUIRED — a passing review moves the set to READY_FOR_HUMAN_APPROVAL; a named human decision is required before APPROVED.  
**Review:** Assess per `docs/project/review-rubrics.md`; review record for this deliverable: [REVIEW-RECORD.md](./REVIEW-RECORD.md).

---

## Structure

- **Folder per feature:** `docs/features/sub-features/{feature-name}/`
- **One spec file per sub-feature:** `{sub-feature-name}.md` (e.g. `resolve-api.md`)
- **Index:** See [SUB-FEATURES-INDEX.md](./SUB-FEATURES-INDEX.md) for the full Feature → Sub-feature mapping and file paths.

## Spec Template (24 sections)

Each sub-feature spec includes:

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

Plus **example flows** (API payloads, DB records, events) and **implementation implications** (backend services, DB tables, jobs, APIs, frontend components).

## Quality Process (per prompt STEP 6–7 and review-rubrics)

- **Review (STEP 6):** For each sub-feature spec, create a review in `docs/features/reviews/`. Use the **required review output format** from `docs/project/review-rubrics.md`: overall disposition, scored dimensions (1–5), confidence rating, blocking issues, recommended edits, explicit recommendation (READY_FOR_HUMAN_APPROVAL / CHANGES_REQUESTED), propagation note, pending confirmation. **Threshold (review-rubrics):** average > 4.1 with no dimension < 4; confidence HIGH for promotion. If below threshold, improve spec and repeat review until thresholds met.
- **Audit (STEP 7):** When a spec reaches threshold quality, run a final audit in `docs/features/audits/`. Audit checks: internal consistency, missing workflows, missing integrations, missing technical detail, scalability risks. **Verdict:** Pass / Pass with improvements / Needs revision.  
- **Finalized:** Approved sub-feature specs remain in `docs/features/sub-features/{feature-name}/`.

**Deliverable review:** The sub-feature set (INDEX, README, and Done specs) is reviewed in [REVIEW-RECORD.md](./REVIEW-RECORD.md) per review-rubrics; all dimensions ≥ 4, average 5.0; recommendation READY_FOR_HUMAN_APPROVAL.  
**Example (single spec):** Resolve API has full spec, review (`reviews/sub-feature-resolve-api-review.md`), and audit (`audits/sub-feature-resolve-api-audit.md`) with Pass verdict. Use as template for other sub-features.

## References

- **Feature list:** `docs/project/feature-list.md`  
- **Parent specs:** `docs/features/*.md` (e.g. `identity-resolution.md`, `delivery-api.md`)  
- **Review rubrics:** `docs/project/review-rubrics.md`  
- **Summary:** `docs/features/SUMMARY.md`
