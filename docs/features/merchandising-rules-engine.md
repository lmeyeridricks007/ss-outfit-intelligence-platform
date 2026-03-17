# Feature Deep-Dive: Merchandising Rules Engine (F10)

**Feature ID:** F10  
**BR(s):** BR-6 (Merchandising control and governance), BR-12 (Governance and safety)  
**Capability:** Apply merchandising rules  
**Source:** `docs/project/feature-list.md`, `docs/project/domain-model.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

**Apply** pin, include, exclude, boost, demotion, and category/price/inventory constraints so **merchandising controls** what appears where; **rules take precedence** over raw algorithm output (BR-6, BR-12). The rules engine does not **author** rules (that is Admin F19); it **evaluates** rules for each recommendation request and returns **filtered and ordered** candidate set (or instructions) to the recommendation engine (F9).

## 2. Core Concept

- **Merchandising rules** (see domain model): pin (always show), include (whitelist), exclude (blacklist), boost (increase rank), demotion (decrease rank), category/price/inventory constraint, channel or campaign override. Each rule has rule_id, effective dates, owner, approval status, and optional scope (placement, campaign).
- **Rules engine:** Given **request context** (placement, channel, campaign, customer segment, anchor product, etc.) and **candidate list** (from F9 before rules, or F10 is called by F9 with candidates), **evaluate** all applicable rules: apply pin first (add to top), then include, then apply exclude (remove), then boost/demotion (reorder), then category/price/inventory filter (remove out-of-scope). Return **ordered list** and optionally **reason per item** (e.g. “pinned by rule R1”). F9 uses this as the final list (or F9 merges rules result with its own ranking—architecture must define: F9 ranks then F10 filters, or F10 returns full ordering; typically F9 passes candidates to F10 and F10 returns filtered+ordered list).

## 3. Why This Feature Exists

- **BR-6:** Merchandisers must be able to define and edit rules (pin, suppression, category/price/inventory) and approve or override high-visibility AI; rules must be auditable.
- **BR-12:** Rules respect brand and compliance; high-visibility changes can be gated (approval in F21); rules engine applies only **approved** and **effective** rules.
- **Architecture:** “Merchandising rules take precedence”; engine (F9) must not deliver results that violate rules.

## 4. User / Business Problems Solved

- **Merchandising:** Control exactly which items appear (pin), which never appear (exclude), and relative order (boost/demotion); inventory and category constraints keep recommendations shoppable and on-brand.
- **Customers:** See on-brand, in-stock, and intentionally curated results rather than pure algorithm.
- **Compliance:** No unapproved bulk overrides; audit trail of which rules applied.

## 5. Scope

### 6. In Scope

- **Rule types:** Pin (product or look always at top), Include (whitelist: only these if specified), Exclude (blacklist: remove these), Boost (multiply score or move up), Demotion (move down), Category constraint (e.g. only from category X), Price constraint (min/max), Inventory constraint (only in-stock), Channel/campaign override (different rule set per channel or campaign). Per domain model and BR-6.
- **Scope/targeting:** Rules can be scoped to placement(s), campaign(s), segment, region, date range. Evaluation: for each request, load rules that match (placement, campaign, date effective) and apply in defined **priority order** (e.g. pin > exclude > boost > demotion > filter).
- **Effective dates and approval:** Only **approved** and **currently effective** (start_date ≤ now ≤ end_date) rules are applied. Draft or expired rules ignored.
- **Input:** Request context (placement, channel, campaign, experiment, customer_id for segment, region) + **candidate list** (product_ids and/or look_ids with optional scores from F9). Output: **filtered and ordered** list + optional per-item reason (rule_id that pinned/boosted/excluded).
- **Inventory:** “Only in-stock” can be a global rule or placement-level; engine or context supplies inventory signal; rules engine filters out out-of-stock when rule applies.
- **Audit:** Log which rules were applied per request (trace_id, rule_ids) for “rule execution” (BR-4) and governance. No PII in audit.

### 7. Out of Scope

- **Authoring/editing rules** — Admin rule builder (F19). Rules engine only **reads** rule definitions and **evaluates**.
- **Approval workflow** — F21. Rules engine reads “approval status” from store; F21 updates status.
- **Recommendation candidate generation** — F9. Rules engine receives candidates; does not fetch from F5/F6.
- **Delivery API** — F11. F11 receives final list from F9 (after F9 has applied F10 result); F10 does not talk to F11.

## 8. Main User Personas

- **Merchandising Manager** — Benefits from rules being applied reliably and auditably.
- **Customers** — Indirect; see rule-driven results (pinned, excluded, on-brand).
- **Backend engineers** — Implement evaluation and priority order.

## 9. Main User Journeys

- **Request:** F9 generates candidates → F9 calls F10 with (request context, candidates) → F10 loads applicable rules, applies pin/exclude/boost/demotion/filters, returns ordered list → F9 uses this as final list (or F9 merges; define contract) → F9 returns to F11.
- **Rule change:** Merchandising edits rule in F19 → rule saved with effective dates and approval status → on next request, F10 loads new rule set and applies. No deployment required (rules are data).
- **Override:** Merchandising pins product P for placement PDP → rule created and approved → F10 adds P at top for PDP requests; F9’s algorithm output is overridden.

## 10. Triggering Events / Inputs

- **Request-time only.** Inputs: placement, channel, campaign_id, customer_id (for segment), region, candidate list (from F9), optional experiment_id. No async triggers.

## 11. States / Lifecycle

- **Rule (stored):** draft → under_review → approved → effective (date range) → expired. Only approved + effective are applied.
- **Evaluation:** Stateless per request; no state machine in engine.

## 12. Business Rules

- **Precedence order:** Pin (add and place at top) → Include (if rule says “only these,” restrict to list) → Exclude (remove) → Boost (reorder up) → Demotion (reorder down) → Category/price/inventory (remove non-compliant). Document and test; do not allow “exclude” to be overridden by algorithm.
- **No unapproved bulk override:** A rule that applies to “all placements” or “all users” must have approval status = approved (and optionally gated by F21). Rules engine does not apply draft rules.
- **Effective date:** Rule with start_date in future or end_date in past is not loaded. Timezone: use platform or placement timezone (TBD).
- **Conflict:** If two rules conflict (e.g. pin A and exclude A), define precedence (e.g. exclude wins for safety, or pin wins for merchandising intent). Recommend: exclude wins over pin for compliance; document.

## 13. Configuration Model

- **Rule definition (from F19):** rule_id, type, scope (placement, campaign, segment, region), target (product_ids, look_ids, category, price range), effective dates, priority (for same-type rules), approval status. Stored in rule store (DB or config).
- **Evaluation config:** Priority order of rule types; max rules to apply per request (optional); timeout for evaluation (do not block F9 too long).
- **Feature flags:** Disable rules for placement (e.g. for A/B control in F24).

## 14. Data Model

- **Rule:** rule_id, type (pin|include|exclude|boost|demotion|category|price|inventory|channel_override), scope (placement_ids, campaign_id, segment, region), target (product_ids, look_ids, category_id, price_min, price_max, inventory_filter), priority (integer), start_date, end_date, approval_status, owner_id, created_at, updated_at.
- **Evaluation input:** request_id/trace_id, placement, channel, campaign_id, customer_id, region, candidates: [ { id, type (product|look), score } ]. Output: ordered_candidates: [ { id, type, reason_rule_id } ], applied_rule_ids: [ ].
- **Audit log:** trace_id, rule_ids_applied, timestamp. No PII.

## 15. Read Model / Projection Needs

- **Recommendation engine (F9):** Only consumer. F9 calls F10 with candidates; F10 returns filtered+ordered list. F9 then returns to F11 (or F9 returns F10 output as-is).
- **Admin (F19):** Reads rules for edit; F19 writes rules. Rules engine only reads for evaluation.
- **Analytics:** Optional: which rules drove which recommendations (from audit or from reason_rule_id in result); for “rule execution” BR-4 and reporting.

## 16. APIs / Contracts

- **Internal (called by F9):** `POST /rules/evaluate` with body = { placement, channel, campaign_id, customer_id, region, candidates: [ { id, type, score } ] } → 200 OK { ordered_candidates: [ { id, type, reason_rule_id } ], applied_rule_ids: [ ] }.
- **Example:**

```json
POST /rules/evaluate
{
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "candidates": [ { "id": "prod-1", "type": "product", "score": 0.9 }, { "id": "look-1", "type": "look", "score": 0.8 } ]
}
→ 200 OK
{
  "ordered_candidates": [
    { "id": "prod-pinned", "type": "product", "reason_rule_id": "rule-pin-1" },
    { "id": "prod-1", "type": "product", "reason_rule_id": null },
    { "id": "look-1", "type": "look", "reason_rule_id": null }
  ],
  "applied_rule_ids": ["rule-pin-1"]
}
```

## 17. Events / Async Flows

- **Consumed:** Optional: RuleCreated/RuleUpdated from F19 to invalidate cache (if rules are cached). Or load rules on each request with short TTL cache.
- **Emitted:** None required. Optional: RuleEvaluated (trace_id, rule_ids) for audit pipeline.
- **Flow:** Synchronous: F9 → F10 → F9.

## 18. UI / UX Design

- **None.** Rule authoring UI is F19. Rules engine is backend only.

## 19. Main Screens / Components

- None.

## 20. Permissions / Security Rules

- **Evaluate API:** Internal only (F9). No external exposure. Rule store: read by engine and F19; write by F19 only (and F21 for approval status). Audit log: read by governance/ops only.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Evaluation timeout; rule store unavailable (F9 should proceed without rules and alert); high exclude rate (possible misconfiguration).
- **Side effects:** F9 output changes when rules change (expected). No other side effects.

## 22. Integrations / Dependencies

- **Upstream:** Admin rule builder (F19) and approval (F21) for rule definitions and approval status. Recommendation engine (F9) calls F10 with candidates.
- **Downstream:** Recommendation engine (F9) only.
- **Shared:** Domain model (Merchandising Rule); BR-6, BR-12; architecture (rules take precedence).

## 23. Edge Cases / Failure Cases

- **Rules store down:** Return candidates unchanged (no rules applied); log and alert. Prefer “no rules” over failing request.
- **Timeout:** Cap evaluation time (e.g. 50 ms); if timeout, return candidates with best-effort partial application or unchanged; log.
- **Pin product not in candidates:** Add pinned product to top (fetch from catalog if needed) or skip if not in catalog. Define: pin can add new items or only reorder existing. Recommend: pin can add (so merchandising can force a specific product).
- **Exclude all candidates:** Return empty; F9 fallback will then run (F9 must handle empty list from F10 by running fallback).
- **Conflicting rules:** Document precedence (e.g. exclude > pin); test.

## 24. Non-Functional Requirements

- **Latency:** p95 &lt; 50 ms so F9 total latency is acceptable. Cache rule set by (placement, campaign) with TTL (e.g. 1 min).
- **Availability:** High; fallback to “no rules” on failure.
- **Correctness:** Pin and exclude must never be reversed; audit must record applied rules.

## 25. Analytics / Auditability Requirements

- **Audit:** For each evaluation (or sample), log trace_id, applied_rule_ids, timestamp. Required for BR-6 (audit) and “rule execution” (BR-4). No PII.
- **Metrics:** Rules applied per request; pin/exclude/boost counts; evaluation latency.

## 26. Testing Requirements

- **Unit:** Priority order (pin first, then exclude, then boost); effective date filter; scope match (placement, campaign).
- **Integration:** Create rule (pin P), send candidates without P → verify P added at top. Exclude P → verify P removed. F9 integration: F9 calls F10 → verify final list order and content.
- **Contract:** Evaluate request/response schema for F9.

## 27. Recommended Architecture

- **Component:** Part of “Recommendation & governance” layer. Can be same service as F9 or separate; separate recommended for clear ownership and scaling.
- **Pattern:** Load rules (with cache) → filter by scope and date → apply in priority order → return. Stateless.

## 28. Recommended Technical Design

- **Rule store:** DB (rules table + scope/target JSON). **Cache:** (placement, campaign) → list of rules; TTL 1–5 min. **Evaluator:** Apply pin (add to set), include (intersect), exclude (remove), boost (reorder), demotion (reorder), category/price/inventory filter. **Audit:** Append trace_id + rule_ids to audit log (async or sync). **Timeout:** 50 ms; on timeout return candidates unchanged.

## 29. Suggested Implementation Phasing

- **Phase 1:** Pin, exclude, include; placement scope; effective dates; approval status check; return ordered list to F9. Audit log. No boost/demotion.
- **Phase 2:** Boost, demotion; campaign and segment scope; category/price/inventory constraints; cache; F19 integration.
- **Later:** Channel override; advanced targeting; performance at scale.

## 30. Summary

**Merchandising rules engine** (F10) **evaluates** rules (pin, include, exclude, boost, demotion, category/price/inventory) for each recommendation request and returns a **filtered and ordered** candidate list to the **recommendation engine** (F9). Rules **take precedence** over raw algorithm output. Only **approved** and **effective** rules are applied. Rule **authoring** is in Admin (F19); **approval** is in F21. F10 does not generate candidates; it only filters and reorders. BR-6 and BR-12 are satisfied; audit and correctness are critical. Failure must not break the API (fallback to no rules).
