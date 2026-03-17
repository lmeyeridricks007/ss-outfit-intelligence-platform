# Feature Deep-Dive: A/B and Experimentation (F24)

**Feature ID:** F24  
**BR(s):** BR-10 (Analytics and optimization)  
**Capability:** Support A/B and experimentation on recommendations  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/domain-model.md`

---

## 1. Purpose

**Support A/B and multi-armed bandit** (where configured) for **strategies, layouts, and rules** with **defined primary metrics** and **attribution** so teams can optimize recommendation performance (BR-10). Experiments assign **variants** (e.g. strategy A vs B, or layout A vs B) to **users/sessions**; **outcome events** (F12) carry **experiment_id** and **variant** so **reporting** (F17) and experiment analysis can compute **lift** and **significance**.

## 2. Core Concept

- **Experiment:** experiment_id, name, placement(s), variants (e.g. control=strategy_curated, variant_a=strategy_similarity), traffic split (e.g. 50/50), primary metric (e.g. CTR, conversion), start/end date, status (draft, running, stopped). **Assignment:** On each **recommendation request** (F11), if placement is in an active experiment, **assign** user/session to a variant (deterministic hash or random). Pass **experiment_id** and **variant** to F9 (and in F11 response echo); **outcome events** (F12) must include experiment_id and variant so F17 or experiment service can **attribute** outcomes to variant.
- **A/B:** Two or more variants; equal or weighted traffic. **Multi-armed bandit (optional):** Dynamically shift traffic to better-performing variant; requires integration with assignment and metrics. **Primary metric:** e.g. CTR, add-to-cart rate, conversion; **sample size** and **significance** (e.g. 95% confidence) computed in reporting (F17 or dedicated experiment dashboard).

## 3. Why This Feature Exists

- **BR-10:** Support for A/B or experimentation on strategies/placements where configured. **Product goals:** Experiment velocity and optimization.
- **Merchandising/Product:** Test strategy or layout changes before full rollout; data-driven decisions.

## 4. User / Business Problems Solved

- **Merchandising, CRM, Product:** Run experiments (e.g. “curated vs similarity on PDP”); read results; promote winner. **Risk reduction:** Avoid bad rollout; validate with small % traffic.

## 5. Scope

### 6. In Scope

- **Experiment config:** Create experiment (name, placement, variants with config e.g. strategy_id, or layout_id), traffic %, start/end, primary metric. **Assignment:** For each F11 request, if placement in active experiment, **assign** variant (by session_id or customer_id hash, or random); **stable** assignment (same user gets same variant for experiment duration). **Pass-through:** F11 receives experiment_id and variant (or F11 calls experiment service to get assignment); F11 passes to F9; F9 uses variant to select strategy or config; F11 echoes experiment_id and variant in response (for client to send in F12 events). **Events:** F12 schema must support **experiment_id** and **variant** in outcome events; channels (F13–F15, F16, F23) send them when present. **Reporting:** F17 or experiment dashboard **segments** by experiment_id and variant; computes metric (CTR, conversion) per variant; **significance** (e.g. chi-squared or t-test) and **sample size**.
- **Multi-armed bandit (optional):** If supported, assignment service adjusts traffic (e.g. 70% to current best variant) based on running metric; requires real-time or batch metric feed and assignment update. **Stopping:** Experiment can be stopped (status=stopped); assignment stops; analysis on data so far.

### 7. Out of Scope

- **Recommendation engine logic** — F9; F9 receives variant and chooses strategy; F24 does not run engine. **Delivery API** — F11; F11 passes experiment_id/variant; F24 assigns and stores config. **Outcome event collection** — F12; F24 requires events to include experiment_id/variant. **Full experimentation platform** — F24 can be minimal (assign + config + report); advanced (MAB, multivariate) is later.

## 8. Main User Personas

- **Merchandising Manager, CRM, Product Manager** — Create experiments; read results; decide winner. **Data/analytics** — Build reporting and significance.

## 9. Main User Journeys

- **Create experiment:** User creates “PDP strategy test”: placement=pdp_complete_the_look, control=curated, variant_a=similarity, 50/50, primary_metric=CTR, start now. **Run:** F11 requests for that placement get assignment (control or variant_a); F9 runs corresponding strategy; response includes experiment_id, variant; widget sends events with experiment_id, variant. **Report:** User opens experiment report → sees CTR (and conversion) by variant, sample size, significance → stops experiment, promotes winner (e.g. change F20 config to winning strategy).
- **Stable assignment:** Same user always gets same variant for that experiment (hash(session_id + experiment_id) % 100 < 50 → control else variant_a).

## 10. Triggering Events / Inputs

- **Request-time:** F11 (or gateway) calls assignment service with (placement, session_id or customer_id) → returns experiment_id (or null), variant (or null). **Config:** Experiment create/update/stop (admin or API). **Events:** Outcome events from channels with experiment_id, variant (from F11 response).

## 11. States / Lifecycle

- **Experiment:** draft → running → stopped. **Assignment:** Only when experiment is running and placement matches. **Variant:** control | variant_a | variant_b | ... (configurable names).

## 12. Business Rules

- **Stable assignment:** Same user/session gets same variant for same experiment (deterministic). **Overlap:** If multiple experiments on same placement, define policy (e.g. one experiment per placement at a time, or layered with priority). **Primary metric:** Defined per experiment; reporting uses it for “winner” and significance. **Ethics:** No sensitive targeting (e.g. no experiment by race); document policy.

## 13. Configuration Model

- **Experiment:** experiment_id, name, placement_ids, variants [{ name, config (e.g. strategy_id) }], traffic_weights, primary_metric, start_date, end_date, status. **Assignment:** Hash function (session_id, experiment_id) → variant index. **Reporting:** Metric by (experiment_id, variant); significance test; sample size.

## 14. Data Model

- **Experiment:** experiment_id, name, placement_ids, variants (JSON), traffic_weights, primary_metric, start_date, end_date, status, created_at. **Assignment log (optional):** session_id, experiment_id, variant, assigned_at (for audit). **Events:** F12 schema: add experiment_id, variant to outcome events. **Report:** Aggregated (experiment_id, variant, impressions, clicks, conversions, revenue); computed from F12 events.

## 15. Read Model / Projection Needs

- **F11/F9:** Read assignment (experiment_id, variant) per request. **F17 / Experiment report:** Read F12 events filtered by experiment_id, variant; aggregate by metric. **Admin:** List experiments; experiment detail and report.

## 16. APIs / Contracts

- **Assignment (internal):** GET /experiments/assign?placement=...&session_id=... → { experiment_id, variant } or {}. **Experiment CRUD:** POST /experiments, GET /experiments, PUT /experiments/{id}, POST /experiments/{id}/stop. **Report:** GET /experiments/{id}/report → { variants: [ { name, metric_value, sample_size, significance } ] }.
- **F11 response:** Include experiment_id and variant when present so clients can send in F12 events. **F12 event:** Add experiment_id, variant (optional) to payload; required when F11 returned them.

## 17. Events / Async Flows

- **Consumed:** F11 request (for assignment). **Emitted:** None from F24; F12 events (from channels) must include experiment_id, variant. **Flow:** Request → assign → F9 uses variant → Response + experiment_id, variant → Channel sends event with experiment_id, variant → F12 → F17/report aggregates.

## 18. UI / UX Design

- **Admin:** Experiment list (name, placement, status, start/end); Create experiment (form: name, placement, variants, traffic, primary metric, dates); Experiment report (metric by variant, chart, significance, “Stop & promote”). **No customer-facing** experiment UI; transparent to customer.

## 19. Main Screens / Components

- **Screens:** Experiment list; Create/Edit experiment; Experiment report. **Components:** ExperimentForm, VariantEditor, TrafficSlider, ReportChart, SignificanceBadge.

## 20. Permissions / Security Rules

- **Create/edit/stop:** Product or merchandising role. **Report:** Same or viewer. **Assignment:** Internal only (F11). **No PII** in experiment config or report (only aggregates).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Experiment end date reached (optional auto-stop); significance reached (optional notify “winner ready”). **Side effects:** When experiment stopped and winner promoted, F20 config may be updated (manual or automated) to winning strategy.

## 22. Integrations / Dependencies

- **Upstream:** F11 (receives assignment); F9 (uses variant). **Downstream:** F12 (events with experiment_id, variant); F17 or experiment report (aggregates). **F20:** Winning variant may update placement config. **Shared:** BR-10; domain model (Experiment); F12 schema extension.

## 23. Edge Cases / Failure Cases

- **Assignment service down:** F11 proceeds without experiment (variant=control or no experiment); no 500. **Experiment stopped mid-flight:** Assignment returns empty; new requests get no variant; old events still valid for analysis. **Multiple experiments same placement:** Define: one active per placement, or merge (e.g. experiment_id = most recent). **Sample size too small:** Report shows “insufficient data”; do not declare winner until threshold.

## 24. Non-Functional Requirements

- **Assignment latency:** &lt; 10 ms (cache experiment config; hash is fast). **Report:** Refresh daily or hourly; or real-time from F12 stream. **Availability:** Fallback to no experiment on failure.

## 25. Analytics / Auditability Requirements

- **Audit:** Experiment create/update/stop (who, when). **Metrics:** Per variant (impressions, clicks, conversions); significance; sample size. **No PII** in report.

## 26. Testing Requirements

- **Unit:** Assignment (hash → variant); traffic weights. **Integration:** Create experiment; F11 request gets assignment; response includes experiment_id, variant; mock F12 event with experiment_id, variant → report shows variant. **A/A test:** Same variant for both; expect no significant difference (sanity).

## 27. Recommended Architecture

- **Component:** Experiment service (assignment + config) or part of F11/gateway. **Reporting:** F17 extension or dedicated experiment dashboard reading F12. **Pattern:** Request → assign (sync) → F9; Events → F12 → aggregate by experiment_id, variant.

## 28. Recommended Technical Design

- **Assignment:** In-memory or Redis cache of active experiments; hash(session_id + experiment_id) % 100 < weight_control → control else variant_a. **Config store:** experiments table; CRUD API. **Report:** Query F12 store (or F17 aggregate) WHERE experiment_id = X GROUP BY variant; compute metric and significance (e.g. prop test for CTR).

## 29. Suggested Implementation Phasing

- **Phase 1:** Experiment config (name, placement, 2 variants, 50/50); assignment in F11 or gateway; F11 response and F12 event include experiment_id, variant; simple report (CTR by variant). **Phase 2:** Primary metric config; significance and sample size in report; stop and promote; F20 update on promote (manual or auto). **Later:** MAB; multivariate; more than 2 variants.

## 30. Summary

**A/B and experimentation** (F24) enables **testing strategies, layouts, or rules** with **traffic split** and **primary metric**. **Assignment** (by session/customer hash) is **stable**; **F11** passes **experiment_id** and **variant** to F9 and in response; **channels** send them in **F12** outcome events. **Reporting** (F17 or experiment dashboard) **aggregates by variant** and computes **significance**. BR-10 and product goals (experiment velocity) are satisfied. Optional: multi-armed bandit and auto-promote winner.
