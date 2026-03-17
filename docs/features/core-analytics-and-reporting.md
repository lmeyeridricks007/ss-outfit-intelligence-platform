# Feature Deep-Dive: Core Analytics and Reporting (F17)

**Feature ID:** F17  
**BR(s):** BR-10 (Analytics and optimization)  
**Capability:** Measure recommendation performance and attribution  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

**Report** core recommendation metrics (CTR, add-to-cart rate, conversion, revenue attribution, AOV) in an agreed **reporting tool or dashboard**, with **attribution** (revenue and conversion attributable to recommendation placements) using **recommendation set ID** and **trace ID** from outcome events (F12). BR-10: reporting availability and attribution are success criteria.

## 2. Core Concept

- **Data source:** Outcome events (impression, click, add-to-cart, purchase, dismiss) from **recommendation telemetry** (F12), each with recommendation_set_id and trace_id, placement, channel, and optional product_id, order_id, revenue.
- **Metrics:** **CTR** = clicks / impressions (per placement, channel, strategy if available). **Add-to-cart rate** = add_to_cart_events / impressions. **Conversion** = purchases attributed to recommendations / impressions or / clicks. **Revenue attribution** = sum of revenue from recommendation_purchase events (or attributed by model). **AOV** = attributed revenue / attributed orders. All by placement, channel, and time period.
- **Attribution model:** Last-click, first-click, or assisted (missing decision in BRs); applied consistently. **Reporting:** Dashboard or export (e.g. Looker, Tableau, or internal) available within N days of go-live (BR-10).

## 3. Why This Feature Exists

- **BR-10:** Core metrics and attribution must be available in reporting; success metric is “reporting availability” and “revenue/conversion attributable to recommendation placements.”
- **Product/Merchandising:** Need to optimize placements and strategies; A/B (F24) and tuning (F26) depend on this baseline.

## 4. User / Business Problems Solved

- **Merchandising, CRM, Product:** See what works (placement, strategy); prove ROI of recommendations.
- **Stakeholders:** Single source of truth for recommendation performance.

## 5. Scope

### 6. In Scope

- **Ingest** outcome events from F12 (stream or batch). **Aggregate** by placement, channel, date (and optional strategy, experiment_id). **Compute** CTR, add-to-cart rate, conversion rate, attributed revenue, AOV. **Store** in reporting DB or data warehouse. **Expose** via dashboard, API, or export.
- **Attribution:** Define model (e.g. last-click: purchase attributed to last recommendation_click before order). Apply to revenue (order_id linked to recommendation_purchase or to click trace_id). **Time window:** e.g. 30-day click-to-purchase. Document and implement consistently.
- **Dimensions:** Placement, channel, date, optional strategy, experiment_id (for F24). **Filters:** Date range, placement, channel. **Segments:** Optional (e.g. by customer segment) if data available.
- **SLA:** Core metrics available within N days of go-live (N TBD); refresh frequency (daily, hourly, or real-time) TBD.

### 7. Out of Scope

- **Event collection** — F12. F17 only consumes and aggregates.
- **A/B experiment assignment and reporting** — F24. F17 may provide baseline; F24 adds experiment dimension and significance.
- **Raw event exploration** — Optional; F17 focuses on aggregated metrics and attribution. Ad-hoc query on raw events can be separate (data lake).

## 8. Main User Personas

- **Merchandising Manager, CRM / Email Marketing Manager, Product Manager** — Primary consumers of reports.
- **Data/analytics engineers** — Build pipelines and dashboards.

## 9. Main User Journeys

- **View dashboard:** User opens reporting tool → selects date range, placement (or all) → sees CTR, add-to-cart, conversion, revenue by placement and channel. **Export:** User exports CSV or API for further analysis.
- **Attribution review:** User views “revenue from recommendations” (attributed) and “conversion rate (recommendation-driven)” for stakeholder reporting.
- **Refresh:** Pipeline runs daily (or hourly); new events from F12 aggregated; dashboard updates.

## 10. Triggering Events / Inputs

- **Scheduled:** Batch job (e.g. nightly) reads F12 event store, aggregates, writes to reporting store. **Stream (optional):** Real-time aggregation from F12 stream. **Ad-hoc:** User runs report with filters; query runs against pre-aggregated tables or raw events.

## 11. States / Lifecycle

- **Pipeline:** Idle → Running → Completed / Failed. **Report:** Rendered from latest aggregation. No state machine for end user.
- **Data freshness:** Last event timestamp; report shows “data as of X.”

## 12. Business Rules

- **Attribution:** One model (e.g. last-click) applied to all reports; document in BRs or technical architecture. **Double-count:** Do not attribute same order to multiple placements (last-click gives one placement per order).
- **Missing set_id/trace_id:** Events without IDs excluded from attribution; count in “unattributed” or discard. **Privacy:** No PII in dashboard; aggregate only. Customer_id in events used only for attribution logic (e.g. link click to purchase); not displayed.

## 13. Configuration Model

- **Attribution model:** Last-click, first-click, or assisted; time window (e.g. 30 days). **Refresh:** Schedule (cron). **Dimensions:** Which dimensions to store (placement, channel, strategy, experiment_id). **Tool:** Which BI tool or internal dashboard; read-only access by role.

## 14. Data Model

- **Aggregated (reporting):** placement, channel, date, impressions, clicks, add_to_carts, purchases, attributed_revenue, attributed_orders. Optional: strategy, experiment_id. **Raw (from F12):** event_id, event_name, set_id, trace_id, placement, channel, product_id, order_id, revenue, event_timestamp. **Attribution table (optional):** order_id, trace_id, placement, attributed_revenue (for last-click or model).

## 15. Read Model / Projection Needs

- **Dashboard:** Reads aggregated tables. **Attribution job:** Reads raw events (click, purchase), joins by trace_id and order_id (or session/customer), computes attributed revenue, writes attribution table. **Export/API:** Reads aggregated or attribution table.
- **F24 (A/B):** May read same events with experiment_id; F24 can use F17 aggregates or own pipeline.

## 16. APIs / Contracts

- **Internal (to dashboard):** Query API or direct SQL to reporting DB. Example: GET /reporting/metrics?placement=*&channel=*&from=2025-03-01&to=2025-03-17 → { placements: [ { placement, ctr, add_to_cart_rate, conversion_rate, attributed_revenue, attributed_orders } ] }.
- **Export:** CSV or API for external tools. **No public API;** internal or authenticated BI only.

## 17. Events / Async Flows

- **Consumed:** F12 event stream or batch export. **No emitted events** from F17 (reporting is sink). **Flow:** F12 → F17 pipeline (aggregate) → reporting store → dashboard/API.

## 18. UI / UX Design

- **Dashboard:** Filters (date, placement, channel); tables or charts (CTR, conversion, revenue over time); summary cards. **Export:** Button to download CSV or link to API. **Documentation:** Attribution methodology and definitions.

## 19. Main Screens / Components

- **Screens:** Main dashboard (overview); placement drill-down; channel comparison; attribution summary. **Components:** Date picker, placement filter, metric cards, line/bar charts, table export.

## 20. Permissions / Security Rules

- **Access:** Role-based (merchandising, CRM, product); read-only. **Data:** Aggregates only; no PII. **Audit:** Log who accessed report (optional).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Pipeline failure; data freshness stale. **Side effects:** None; reporting only. Decisions (e.g. turn off placement) are human; F17 only informs.

## 22. Integrations / Dependencies

- **Upstream:** Recommendation telemetry (F12) for outcome events. **Downstream:** Stakeholders (dashboard users); A/B (F24) may consume same events. **Shared:** BR-10; attribution model (missing decision; document when chosen).

## 23. Edge Cases / Failure Cases

- **Late purchase events:** Attribution window (e.g. 30 days) includes late events; reprocess or backfill when purchase arrives. **Duplicate events:** F12 deduplication; F17 should not double-count (use event_id or (trace_id, event_type) in aggregation).
- **Missing placement:** Event with null placement grouped as “unknown”; alert if high. **No events:** Dashboard shows zeros; no error.

## 24. Non-Functional Requirements

- **Refresh:** Daily or hourly within SLA. **Query performance:** Dashboard load &lt; 5 s with pre-aggregation. **Retention:** Aggregates retained per policy; raw events per F12 retention.

## 25. Analytics / Auditability Requirements

- **Methodology:** Document attribution model and definitions. **Audit:** Pipeline run log; no PII. **Compliance:** Aggregate data only; no customer-level export without governance.

## 26. Testing Requirements

- **Unit:** Attribution logic (last-click: link click to purchase by trace_id); aggregation (sum, count). **Integration:** Load sample F12 events; run pipeline; query dashboard; verify CTR and revenue. **Sanity:** Real F12 data (staging); verify numbers plausible.

## 27. Recommended Architecture

- **Component:** “Admin & analytics” layer. Pipeline: F12 → ETL or stream job → reporting DB. **Dashboard:** BI tool (Looker, Tableau, Metabase) or custom internal app reading reporting DB.
- **Pattern:** Batch or micro-batch aggregation; materialized views or aggregate tables; dashboard reads only.

## 28. Recommended Technical Design

- **Pipeline:** Spark, dbt, or streaming (Flink, etc.) to aggregate by (placement, channel, date). **Attribution:** Join click events to purchase events by trace_id (or session/customer + time window); assign revenue to placement. **Store:** Snowflake, BigQuery, Redshift, or PostgreSQL; aggregate tables. **Dashboard:** Connect BI tool to store; or build lightweight React dashboard with query API.

## 29. Suggested Implementation Phasing

- **Phase 1:** Daily batch from F12; aggregate impressions, clicks, add-to-cart, purchases; last-click attribution (or simple: revenue from recommendation_purchase events); one dashboard (placement + channel + date). **Phase 2:** Refined attribution (time window, first-click option); AOV; export API; strategy dimension if available. **Later:** Real-time or hourly; experiment dimension for F24; self-serve segments.

## 30. Summary

**Core analytics and reporting** (F17) **consumes outcome events** from **recommendation telemetry** (F12) and produces **aggregated metrics** (CTR, add-to-cart rate, conversion, attributed revenue, AOV) by placement and channel, with **attribution** applied consistently (model TBD). Reports are available in an agreed **tool or dashboard** within N days of go-live (BR-10). F17 does not collect events (F12) or run A/B (F24); it is the **reporting and attribution** layer for recommendation performance.
