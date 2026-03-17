# Review: Sub-Feature Resolve API (Identity Resolution)

**Spec:** `docs/features/sub-features/identity-resolution/resolve-api.md`  
**Parent feature:** F4 — Identity Resolution  
**Reviewed:** (date TBD)  
**Reviewer:** (agent / human)

---

## 1. Overall Assessment

The Resolve API sub-feature spec is **implementation-grade**. It clearly defines purpose (request-time resolution to customer_id), inputs/outputs, workflow, business rules, API contract (POST /identity/resolve), error handling, and integration with link store, consent-check, and identity-cache. Engineers can implement the endpoint and consumers (F2, F7, F11) can integrate against the contract. All 24 required sections are present with concrete examples and implementation implications.

## 2. Strengths

- **Purpose and scope** are clear; single responsibility (resolve only; no link creation).
- **Inputs/Outputs** and **API Endpoints** with example request/response (resolved and anonymous).
- **Workflow/Lifecycle** and **Business Rules** (no invented IDs, anonymous and consent_required handling).
- **Error Handling** table (400, 503, fail-open policy); **Edge Cases** (all identifiers null, merge precedence, cache staleness).
- **Integrations** (link store, consent-check, identity-cache, consumers) and **Implementation Implications Summary** (backend, DB, jobs, APIs, frontend).
- **Example Scenarios** (A/B/C) and **Testing Requirements** (unit, integration, contract, failure).
- **Consistency** with parent F4 and data-standards (canonical customer_id, confidence).

## 3. Missing Business Detail

- **None.** Consent and anonymous behavior are stated; policy for “fail open” vs 503 when link store down is documented.

## 4. Missing Workflow Detail

- **None.** Request flow (validate → lookup → consent check → respond) is clear. Optional: one sentence on cache read (identity-cache) before link store if that order is fixed.

## 5. Missing Data / API Detail

- **Minor:** OpenAPI snippet could be added in §11 (request/response schema). Example JSON is present; formal schema would round out. Not blocking.

## 6. Missing UI Detail

- **N/A.** Spec correctly states no UI. No gap.

## 7. Missing Integration Detail

- **None.** Link store, consent-check, cache, F2/F7/F11 are listed. Dependency on consent-check sub-feature is explicit.

## 8. Missing Edge Cases

- **None.** No identifier, multiple identifiers, unlinked status, cache staleness covered.

## 9. Missing Implementation Detail

- **None.** Backend, DB (none owned), jobs (none), external APIs (none), frontend (none) are stated. Optional: one line on tech (e.g. HTTP framework, serverless) in Implementation Notes.

## 10. Suggested Improvements

- Add **one sentence** in §23: “Resolve API can be implemented as an HTTP handler (e.g. Express, Spring, Lambda) calling link store and consent-check.”
- Optionally add **OpenAPI 3.0 snippet** (path, request body, 200 response) in §11 or appendix.

## 11. Scorecard

| Category                  | Score (1–10) | Notes                                      |
|---------------------------|--------------|--------------------------------------------|
| Clarity                    | 10           | Purpose, flow, contract are clear           |
| Completeness               | 9            | All 24 sections; OpenAPI snippet optional  |
| Workflow coverage          | 10           | Request flow and error paths covered        |
| Data coverage              | 10           | Inputs, outputs, reads from link/consent    |
| Integration coverage        | 10           | F4 sub-features and F2/F7/F11 listed        |
| Edge cases                 | 10           | Anonymous, consent, cache, fail open        |
| Implementation readiness    | 10           | Engineers can implement from this spec      |

**Average:** 9.9. **Minimum:** 9.

## 12. Confidence Rating

**98%.** Spec is stable, aligned with parent F4 and data-standards; only minor optional additions suggested. No blocking gaps.

## 13. Recommendation

**PASS.** Eligible for promotion per threshold (every score ≥ 9, confidence ≥ 95%). Suggested improvements are optional. Proceed to audit when ready.

---

## 14. Review record (per `docs/project/review-rubrics.md`)

Required review output for requirements-stage artifact (1–5 scale; threshold: average > 4.1, no dimension < 4):

| Dimension | Score (1–5) | Notes |
|-----------|-------------|-------|
| Clarity | 5 | Scope, intent, and structure are clear. |
| Completeness | 5 | Required 24 sections; dependencies and edge cases covered. |
| Implementation Readiness | 5 | Next stage can begin; engineers can implement from this spec. |
| Consistency With Standards | 5 | Aligns with parent F4, data-standards, glossary. |
| Correctness Of Dependencies | 5 | Link store, consent-check, cache, F2/F7/F11 referenced accurately. |
| Automation Safety | 5 | N/A; no automation-triggered promotion implied. |

**Average:** 5.0. **Confidence:** HIGH. **Blocking issues:** None. **Recommended edits:** Optional (OpenAPI snippet).  
**Recommendation:** Move to READY_FOR_HUMAN_APPROVAL (approval mode HUMAN_REQUIRED). **Propagation:** None. **Pending:** Human approval before APPROVED.
