# Review: Catalog and Eligibility Foundation

**Artifact under review:** `docs/features/catalog-and-eligibility-foundation.md`  
**Trigger:** Feature-spec drafting pass (repository documentation workflow)  
**Approval mode:** Not applicable to this review artifact (see Recommendation)

## 1. Overall Assessment

The specification traces clearly to BR-8 language in `business-requirements.md` and the architecture/data standards, explicitly noting the absence of a dedicated BR-8 file under `docs/project/br/`. It defines scope, lifecycle, contracts at an appropriate feature-spec depth, and ties eligibility to **outfit** usefulness and **look** inputs without conflating **surface** with **channel**. The document is suitable as a foundation for architecture and implementation planning once open inventory/source-system decisions are recorded downstream.

## 2. Strengths

- Strong traceability block and honest sourcing for BR-8.
- Clear separation of descriptive catalog vs operational eligibility; aligns with `architecture-overview.md`.
- RTW vs CM called out where attributes diverge.
- Edge cases (partial updates, conflicts, zero eligible complements) are explicit.
- Phasing aligns with `roadmap.md` Phase 1 RTW emphasis.

## 3. Missing Business Detail

- Specific business rules for **exclude vs downrank** when inventory signals are ambiguous remain delegated to §32; acceptable at this milestone but still a decision gap.
- Per-market assortment exceptions (e.g. franchise or wholesale exclusions) not enumerated—likely unknown until source mapping is fixed.

## 4. Missing Workflow Detail

- Operational workflow for quarantine review (who approves, SLA) is only sketched; appropriate to defer to implementation plan but not yet specified.

## 5. Missing Data / API Detail

- Field-level schema for inventory states and regional flags is intentionally illustrative; canonical field names await source-system discovery.

## 6. Missing UI Detail

- Intentionally light on internal admin UI; sufficient for feature-spec stage if ecommerce surface spec owns customer presentation.

## 7. Missing Integration Detail

- Adapter patterns per upstream system are high-level only; integration standards docs will need to extend this.

## 8. Missing Edge Cases

- Omnichannel inventory (ship-from-store vs DC) could affect eligibility—worth a future bullet when OMS semantics are known.

## 9. Missing Implementation Detail

- Caching TTLs, SLO numerics, and strict eligibility feature flags referenced but not numerically set—expected pre-architecture.

## 10. Suggested Improvements

- When source systems are chosen, add an appendix table mapping source fields → canonical attributes → eligibility logic.
- Cross-link the forthcoming look-graph spec for compatibility prerequisites once that file exists.

## 11. Scorecard (bootstrap-style)

| Category | Score (/10) |
| --- | --- |
| Clarity | 9 |
| Completeness | 9 |
| Functional depth | 9 |
| Technical usefulness | 9 |
| Cross-module consistency | 10 |
| Implementation readiness | 9 |

## 12. Scorecard (repo rubric)

| Dimension | Score (/5) |
| --- | --- |
| Clarity | 5 |
| Completeness | 4 |
| Implementation Readiness | 4 |
| Consistency With Standards | 5 |
| Correctness Of Dependencies | 5 |
| Automation Safety | 5 |

**Average:** 4.67 — no dimension below 4.

## 13. Confidence Rating

**HIGH** — Source material is explicit; BR-8 gap is acknowledged and covered via canonical docs.

## 14. Recommendation

The document meets the quality bar for the **feature-spec milestone**: it is coherent, traceable, and actionable enough for the next stage (technical architecture and integration design) without pretending all inventory decisions are finalized. **No board status or lifecycle mutations are proposed from this review**; downstream work should resolve the open questions in §32 during architecture and planning.
