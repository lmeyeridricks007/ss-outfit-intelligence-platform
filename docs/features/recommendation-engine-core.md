# Feature Deep-Dive: Recommendation Engine Core (F9)

**Feature ID:** F9  
**BR(s):** BR-5 (Recommendation strategies and algorithms), BR-1 (Outfit and complete-look recommendations)  
**Capabilities:** Generate outfit and complete-the-look recommendations; Support multiple recommendation strategies and fallbacks; Apply context-aware filtering  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/domain-model.md`

---

## 1. Purpose

Generate **outfit** and **complete-the-look** (cross-sell, upsell, style bundle) recommendations using **multiple strategies** (curated, rule-based, AI/ML), **hybrid ranking**, **context-aware filtering**, and **fallbacks** so placements never return empty or broken (BR-1, BR-5). The engine is the core of the recommendation & governance layer; it consumes product graph (F5), outfit graph (F6), profile (F7), context (F8), and applies merchandising rules (F10), then returns **ranked candidates** to the Delivery API (F11).

## 2. Core Concept

- **Recommendation engine** receives: customer_id (or session), context payload (from F8), placement, channel, anchor product or cart, optional campaign/experiment. It fetches **profile** (F7), **curated looks** (F6), **compatible/substitute products** (F5), and **merchandising rules** (F10). It runs one or more **strategies** (e.g. curated for this placement, collaborative filtering, co-occurrence, similarity, popularity), **merges** and **ranks** candidates, applies **context filters** (weather, season, occasion, inventory) and **rules** (pin, exclude, boost), and returns **ranked list** (product_ids and/or look_ids) with optional **reason/source** hints. If primary strategy returns too few items, **fallback** strategy (e.g. popular in category, default curated look) fills to requested size.
- **Strategies:** Curated (from F6), rule-based (graph + rules), collaborative filtering, co-occurrence, similarity, popularity. **Hybrid:** Combine strategies (e.g. 50% curated, 50% model) and re-rank. **Context-aware:** Filter out winter items in summer, formal for “interview” occasion, etc. **Fallback:** When primary returns &lt; N items, call fallback (e.g. “popular in category” or fixed curated set) so response size is consistent.

## 3. Why This Feature Exists

- **BR-5:** Engine must support multiple strategies, hybrid ranking, context-aware filtering, and fallbacks.
- **BR-1:** Platform must deliver complete-look and complete-the-look recommendations on PDP, cart, and inspiration surfaces; engine is where those are generated.
- **Architecture:** Single recommendation logic for all channels; no duplicate logic per channel (industry standard).

## 4. User / Business Problems Solved

- **Customers:** Relevant, coherent outfits and next-best items; no empty widgets; context-appropriate (season, occasion).
- **Merchandising:** Curated and rules take precedence; AI augments, does not override.
- **Channels:** Same logic for web, email, clienteling; only presentation differs.

## 5. Scope

### 6. In Scope

- **Candidate generation:** Per placement/strategy config: fetch curated looks (F6), compatible products (F5), profile-based (F7), co-occurrence/similarity/popularity (from model or precomputed). Combine into candidate set.
- **Context filtering:** Apply context (F8): season, weather, occasion, inventory. Remove or down-rank candidates that do not match.
- **Rules application:** Call **merchandising rules engine** (F10) to apply pin, include, exclude, boost, demotion, category/price/inventory constraints. Rules **take precedence** over raw algorithm output (architecture principle).
- **Ranking:** Hybrid rank: merge strategy scores, apply rules (pin first, then boost, then algorithm order), then demotion/exclude. Output: ordered list of product_ids and/or look_ids.
- **Fallback:** If after rules and filter the list has fewer items than requested (e.g. 10), call fallback strategy (e.g. popular in category, or default look). Configurable per placement.
- **Reason/source:** Attach to each item (or to response): source (curated, rule-based, graph-derived, model-ranked); optional reason code for explainability (BR-7, API standards).
- **Recommendation types:** Outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal (per glossary). Engine supports these types per placement config.
- **RTW vs CM:** Same engine; context and rules may differ (e.g. CM: appointment, fabric; RTW: stock). No separate engine.

### 7. Out of Scope

- **Delivery API contract** (request/response shape, set ID, trace ID) — F11. Engine returns **candidates + metadata**; F11 builds response and adds set_id, trace_id.
- **Telemetry** (impression, click, etc.) — F12. Engine does not emit events; F11 and channels do.
- **Admin UI** for strategy config — F20. Engine reads config from store or F20 backend.
- **A/B on strategies** — F24. Engine may receive experiment_id and return variant; F24 owns assignment and reporting.

## 8. Main User Personas

- **All customer-facing personas** — Benefit from relevant recommendations.
- **Merchandising** — Control via rules and curated content; engine respects both.
- **Backend/Data engineers** — Implement strategies, ranking, fallback.

## 9. Main User Journeys

- **Request:** F11 receives request → enriches with profile (F7), context (F8) → calls engine with (customer_id, context, placement, anchor, cart, campaign, experiment) → engine fetches candidates (F5, F6, model), applies context filter, calls F10 for rules, ranks, applies fallback if needed → returns ranked list + metadata → F11 adds set_id, trace_id, formats response → returns to channel.
- **Strategy config:** Admin (F20) sets “for placement PDP complete_the_look: strategy = curated + similarity, fallback = popular_in_category.” Engine reads config and runs accordingly.
- **Empty primary:** Curated returns 0 (e.g. no looks for this product) → engine runs fallback → returns 10 popular items (or default look) so widget is never empty.

## 10. Triggering Events / Inputs

- **Request-time only.** Inputs: customer_id, session_id, placement, channel, anchor_product_id, cart_product_ids, context (from F8), profile (from F7), campaign_id, experiment_id, limit (e.g. 10), optional filters. No async triggers; synchronous from F11.

## 11. States / Lifecycle

- **Request:** In progress → Completed (list returned) / Fallback used / Error (then F11 returns fallback or error response).
- **Strategy config:** Loaded from config store; no state machine in engine. Config changes (from F20) take effect on next deploy or config refresh (e.g. TTL).

## 12. Business Rules

- **Rules take precedence:** Pin first, then include, then algorithm order, then boost/demotion, then exclude. Per architecture and BR-6.
- **No empty response:** Fallback must be configured for each placement; engine must return at least 1 item (or 0 only if fallback also returns 0 and that is explicit config).
- **Context adherence:** When context says “summer,” do not recommend heavy winter items (filter or down-rank). BR-5 success: “context adherence” measured by sampling.
- **Inventory:** Respect inventory filter from context or rules (exclude out-of-stock when configured). RTW: shoppability is key.
- **Cold start:** When profile empty, use only non-personal strategies (curated, contextual, popular); do not fail.

## 13. Configuration Model

- **Per placement:** Primary strategy (or mix), fallback strategy, limit, context filters on/off, which rules apply (placement-scoped rules from F10).
- **Per strategy:** Params (e.g. similarity model id, co-occurrence min count). Curated: which look set (from F6). Popular: category or global.
- **Feature flags:** Disable a strategy; force fallback for testing.

## 14. Data Model

- **Input (per request):** customer_id, session_id, placement, channel, context (object), profile (object), anchor_product_id, cart_product_ids, campaign_id, experiment_id, limit. Not persisted by engine; transient.
- **Output (per request):** ranked_items: [ { product_id or look_id, type (product|look), score, source, reason_code } ], fallback_used: boolean. Passed to F11; not persisted by engine.
- **Strategy config (from F20 or config store):** placement_id, primary_strategy, fallback_strategy, params (JSON). Read-only by engine.

## 15. Read Model / Projection Needs

- **Engine reads:** F5 (compatible, substitute, similar), F6 (published looks), F7 (profile), F8 (context—passed in), F10 (rules result: pin list, exclude list, boost weights). No direct DB for products; only via F5/F6 and catalog if needed for attributes.
- **Delivery API (F11):** Only consumer of engine output. F11 builds Recommendation Result (set_id, trace_id, items, reason/source).

## 16. APIs / Contracts

- **Internal (called by F11):** `POST /engine/recommend` with body = { customer_id, session_id, placement, channel, context, profile, anchor_product_id, cart_product_ids, campaign_id, experiment_id, limit } → 200 OK { ranked_items, fallback_used, metadata }.
- **Example:**

```json
POST /engine/recommend
{
  "placement": "pdp_complete_the_look",
  "channel": "webstore",
  "context": { "season": "spring", "anchor_product_id": "prod-suit-1" },
  "profile": { "segment": "formal_focus", ... },
  "anchor_product_id": "prod-suit-1",
  "limit": 10
}
→ 200 OK
{
  "ranked_items": [
    { "look_id": "look-1", "type": "look", "source": "curated", "reason_code": "complete_the_look" },
    { "product_id": "prod-shirt-1", "type": "product", "source": "graph", "reason_code": "compatible" }
  ],
  "fallback_used": false
}
```

## 17. Events / Async Flows

- **No events emitted by engine.** F11 and channels emit outcome events (F12). Optional: engine emits internal metrics (latency, strategy used, fallback rate) for monitoring.
- **Flow:** Synchronous: F11 → engine → F11.

## 18. UI / UX Design

- **None.** Backend only. Strategy and placement config UI is F20.

## 19. Main Screens / Components

- None.

## 20. Permissions / Security Rules

- **Engine API:** Internal only (F11). No customer-facing exposure. Input may contain customer_id; do not log PII. Output is product/look IDs only.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Engine latency spike, fallback rate above threshold, F5/F6/F10 dependency failure (engine should still return fallback).
- **Side effects:** None; stateless. F11 returns response to channel; channel may send telemetry (F12).

## 22. Integrations / Dependencies

- **Upstream:** Product graph (F5), Outfit graph (F6), Customer profile (F7), Context engine (F8), Merchandising rules engine (F10). Delivery API (F11) calls engine.
- **Downstream:** Delivery API (F11) only.
- **Shared:** Domain model (Recommendation Request, Result); glossary (recommendation types, sources); BR-1, BR-5; architecture (single logic, rules precedence, fallback).

## 23. Edge Cases / Failure Cases

- **F5/F6/F7 down:** Use cached or fallback; if no candidates, use fallback strategy (popular). Do not fail entire request.
- **F10 timeout:** Proceed without rules (or use last-known rules); log and alert. Prefer degrading to “no rules” over failing.
- **All strategies return 0:** Fallback must return at least default set (e.g. global popular). If fallback also fails, return empty and log; F11 may return “no recommendations” or static fallback.
- **Very large candidate set:** Cap and rank; do not return 1000 items. Limit = min(request.limit, config max).
- **Cold start (new product):** No co-occurrence/similarity yet; rely on curated and graph compatibility.

## 24. Non-Functional Requirements

- **Latency:** p95 &lt; 200–500 ms (TBD in technical architecture) so total API latency (F11 + F8 + F9 + F10) meets SLA. Optimize: parallel calls to F5, F6, F7, F10 where possible; cache profile and config.
- **Availability:** High; fallback on dependency failure so response is always returned.
- **Correctness:** Rules and context filters must be applied consistently; no bypass of pin/exclude.

## 25. Analytics / Auditability Requirements

- **Metrics:** Latency, strategy mix, fallback rate, per-placement volume. Optional: reason/source distribution for explainability. No PII.
- **Audit:** Optional log of strategy and fallback_used per request (trace_id) for debugging; no PII.

## 26. Testing Requirements

- **Unit:** Ranking logic (pin first, then score); context filter (season, occasion); fallback when primary empty.
- **Integration:** Mock F5, F6, F7, F8, F10; run engine → verify order (pin first), fallback when F6 returns 0). Contract test: output schema for F11.
- **Rules:** F10 returns pin [A], exclude [B]; verify A first, B missing. **Context:** Context “summer”; verify winter items filtered.

## 27. Recommended Architecture

- **Component:** Central part of “Recommendation & governance” layer. Dedicated service or same process as F11; recommend separate for scale and isolation.
- **Pattern:** Orchestrator: fetch candidates from F5, F6, model; merge; call F10 for rules; apply context filter; rank; if size &lt; limit, call fallback; return. Parallelize independent fetches.

## 28. Recommended Technical Design

- **Service:** Stateless; horizontal scaling. **Strategy runners:** One module per strategy (curated, similarity, co-occurrence, popular); interface: (request) → candidates. **Ranker:** Merge + rules (F10) + context filter + sort. **Fallback:** Same interface; invoked when primary result size &lt; limit. **Config:** Load from F20 backend or config store with TTL. **Cache:** Profile (F7), optional F5/F6 cache for hot products.

## 29. Suggested Implementation Phasing

- **Phase 1:** Curated (F6) + graph compatible (F5) + rules (F10) + context filter (F8); single fallback (popular in category); return items + source. No ML.
- **Phase 2:** Add similarity, co-occurrence, or collaborative filtering (first-party or third-party); hybrid ranking; per-placement config (F20); reason codes.
- **Later:** Advanced models; A/B integration (F24); performance tuning.

## 30. Summary

**Recommendation engine core** (F9) **generates** outfit and complete-the-look recommendations using **curated looks** (F6), **product graph** (F5), **profile** (F7), **context** (F8), and **merchandising rules** (F10). It supports **multiple strategies**, **hybrid ranking**, **context-aware filtering**, and **fallbacks** so widgets never return empty. **Rules take precedence** over algorithm output. Output is a **ranked list** (product_ids/look_ids + source/reason) consumed only by **Delivery API** (F11). BR-1 and BR-5 are satisfied by this feature; latency and availability must meet API SLA (TBD).
