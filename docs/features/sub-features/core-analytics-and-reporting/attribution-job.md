# Sub-Feature: Attribution Job (Core Analytics and Reporting)

**Parent feature:** F17 — Core analytics and reporting (`docs/features/core-analytics-and-reporting.md`)  
**BR(s):** BR-10  
**Capability:** Join recommendation outcome events (click, purchase) by set_id/trace_id and compute attributed revenue per placement/campaign.

---

## 1. Purpose

**Attribution job** reads outcome events (impression, click, add-to-cart, purchase) from F12 pipeline, joins click to purchase by trace_id (or session/customer + time window), and writes **attribution table** (placement, campaign, attributed revenue, conversion count) for dashboard and reporting. See parent F17.

## 2. Core Concept

**Batch or streaming job:** Read events with set_id, trace_id → join click events to order/purchase events → assign revenue to placement/campaign (e.g. last-click 30-day). Write to attribution store. Dashboard/BI reads from store. See parent §2, §16.

## 3. User Problems Solved

- **Measure recommendation ROI:** Attributed revenue per placement. **Reporting:** CTR, conversion, AOV in dashboard. See parent §4.

## 4.–24. Trigger through Testing

Scheduled (daily/hourly) or streaming. Inputs: events from F12. Outputs: attribution table. Integrations: F12, BI tool. See parent F17 full spec.

---

**Status:** Placeholder. Parent: `docs/features/core-analytics-and-reporting.md`.
