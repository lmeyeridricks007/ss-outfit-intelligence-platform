# Review: Ecommerce Surface Activation

**Artifact under review:** `docs/features/ecommerce-surface-activation.md`  
**Trigger:** Documentation milestone review (manual / agent pass).  
**Approval mode:** Not applicable to this review artifact; no board or lifecycle status changes are recorded or implied here.

## 1. Overall Assessment

The ecommerce surface deep-dive correctly centers **Phase 1 PDP and cart** (RTW, outfit + cross-sell + upsell), maps behaviors to **BR-001** and **BR-002** surface-by-type guidance, and defers **delivery contract specifics** to the delivery feature—preserving separation of concerns. It is **appropriate for this milestone** as UX/module and telemetry guidance ahead of UI implementation plans.

## 2. Strengths

- Clear **phase expansion path** (homepage, personalization, look-builder) aligned with `docs/project/roadmap.md`.
- Strong emphasis on **typed module labeling** and analytics IDs, consistent with BR-010.
- **Degradation and consent** called out early for later personalization phases.

## 3. Missing Business Detail

- **Copy and brand voice** for module titles is placeholder-level; merchandising will need a content matrix—expected post-milestone.

## 4. Missing Workflow Detail

- **Look-builder → PDP handoff** parameters are intentionally open; journey mapping workshops should refine.

## 5. Missing Data / API Detail

- Impression **threshold constants** (viewport %, dwell time) are flagged as open—data standards doc should own canonical values.

## 6. Missing UI Detail

- No breakpoint-specific layouts; acceptable for feature spec—UI build stage should add responsive specs.

## 7. Missing Integration Detail

- **Price freshness** source-of-truth decision is explicitly open; requires joint decision with commerce platform owners.

## 8. Missing Edge Cases

- **Wishlist/save** interaction parity if introduced mid-phase—not required for Phase 1 but should align with BR-006 when that surfaces in UI specs.

## 9. Missing Implementation Detail

- Choice of **data layer vs tag manager** for analytics is not fixed; integration plan should select.

## 10. Suggested Improvements

- After merge, add explicit **cross-references** to `docs/features/delivery-api-and-channel-adapters.md` for required response fields (`recommendationSetId`, `traceId`).
- Add a one-page **module inventory table** (surface × module × allowed types × phase) in a future revision.

## 11. Scorecard

### 11.1 Bootstrap deep-dive scorecard (each dimension scored x/10; target ≥ 9)

| Dimension | Score | Notes |
|-----------|------:|-------|
| Clarity | 9 | Surface scope and phase boundaries are explicit. |
| Completeness | 9 | Open questions capture impression and pricing decisions. |
| Functional depth | 9 | States, journeys, and telemetry hooks are substantive. |
| Technical usefulness | 9 | Actionable for frontend and analytics integrators. |
| Cross-module consistency | 9 | Consistent with BR-001/002/003 and delivery separation. |
| Implementation readiness | 9 | Ready for UI plan; not a build spec. |

### 11.2 Repository rubric scorecard (`docs/project/review-rubrics.md`, each dimension x/5)

| Dimension | Score | Notes |
|-----------|------:|-------|
| Clarity | 5 | Terminology matches `standards.md`. |
| Completeness | 4 | Impression rules and pricing source TBD. |
| Implementation Readiness | 4 | Strong patterns; detailed integration TBD. |
| Consistency With Standards | 5 | Surface vs channel and telemetry expectations aligned. |
| Correctness Of Dependencies | 5 | Roadmap and BR citations fit. |
| Automation Safety | 5 | No implied approvals; assumptions explicit. |

**Average (repo rubric):** 4.67 — suitable for documentation-stage progression pending cross-doc alignment on telemetry thresholds and pricing.

## 12. Confidence Rating

**95%** — HIGH for milestone scope; main residual risk is cross-team agreement on analytics and commerce data freshness.

## 13. Recommendation

For **this documentation milestone only**, the ecommerce surface activation deep-dive is **suitable to proceed** as guidance for Phase 1 PDP/cart activation and later-phase expansion. Next steps should resolve **impression definition** and **price snapshot vs live** with analytics and commerce stakeholders. This review does **not** update any board or workflow lifecycle status.
