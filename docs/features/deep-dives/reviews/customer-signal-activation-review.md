# Review: Customer Signal Activation

**Artifact under review:** `docs/features/customer-signal-activation.md`  
**Trigger:** Feature-spec drafting pass (repository documentation workflow)  
**Approval mode:** Not applicable to this review artifact (see Recommendation)

## 1. Overall Assessment

The specification faithfully operationalizes **BR-006** (`br-006-customer-signal-usage.md`) and BR-6 in `business-requirements.md`, including freshness tiers, policy-gated vs default-allowed classes, traceability fields, and **surface**-appropriate activation. It preserves the distinction between **curated**, **rule-based**, and **AI-ranked** consumption of signals without embedding ranking formulas. Suitable for feature-spec milestone handoff to architecture and data pipeline design.

## 2. Strengths

- Strong alignment with BR-006 principles (bounded personalization, stale-signal fallback, respectful UX).
- Explicit trace and attribution model hooks to `data-standards.md` (recommendation set ID, trace ID).
- Channel-specific expectations echo BR-006 §10 without confusing **channel** with **surface**.
- Phasing matches `roadmap.md` Phase 1 vs Phase 2 expansion.

## 3. Missing Business Detail

- Numeric freshness thresholds still open (inherited from BR-006 open questions)—documented, not hidden.

## 4. Missing Workflow Detail

- Operator debugging UX for stale suppression is referenced but not designed—acceptable at this stage.

## 5. Missing Data / API Detail

- Event schema field names illustrative; concrete Avro/JSON contracts belong to architecture/integration.

## 6. Missing UI Detail

- Intentionally minimal; no customer-facing invasive rationale—good.

## 7. Missing Integration Detail

- Per-source latency and replay semantics outlined at high level only.

## 8. Missing Edge Cases

- Cross-device identity switching mid-session could use a short explicit note in a future revision.

## 9. Missing Implementation Detail

- Technology choices for streaming vs batch rightly deferred.

## 10. Suggested Improvements

- When thresholds are decided, add a single summary table: signal class × tier × **surface** × max age.

## 11. Scorecard (bootstrap-style)

| Category | Score (/10) |
| --- | --- |
| Clarity | 10 |
| Completeness | 9 |
| Functional depth | 10 |
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

**HIGH** — BR-006 is detailed upstream; this spec translates it without distortion.

## 14. Recommendation

The document is **ready for the feature-spec milestone** and provides clear constraints for pipeline and orchestration design. **No board status or lifecycle mutations are proposed from this review.** Downstream work should close numeric thresholds and structured store field approvals without blocking this artifact’s completeness at the spec layer.
