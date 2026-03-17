# Feature Deep-Dive: Email and CRM Recommendation Payloads (F16)

**Feature ID:** F16  
**BR(s):** BR-8 (Email and CRM recommendation payloads)  
**Capability:** Provide recommendation payloads for email and CRM  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Supply **recommendation content** (e.g. “recommended looks,” “complete the look”) for **email and CRM campaigns** (e.g. Customer.io) so campaigns can use personalized or audience-based recommendation blocks. Payloads respect **audience, region, and availability** where specified (BR-8).

## 2. Core Concept

Email/CRM system (or batch job) calls the **Delivery API** (F11) with **placement=email_block** (or similar), **channel=email**, and **audience context** (e.g. list of customer_ids, or segment + region). F11 returns recommendation set per request; the **payload** is the F11 response (items, set_id, trace_id) formatted for email (e.g. product/look IDs + image URLs, links). **Open-time** (at open) or **batch** (at send time) resolution supported as designed. Outcome events (click, conversion) can be sent back to F12 with set_id/trace_id for attribution.

## 3. Why This Feature Exists

- **BR-8:** Recommendation payloads must be available for email/CRM; engagement lift (open/click/conversion) vs control is success metric.
- **Architecture:** Same Delivery API (F11); email is another channel consuming it with different request pattern (batch or per-recipient).

## 4. User / Business Problems Solved

- **CRM / Email Marketing Manager:** Use “recommended looks” and “complete the look” in campaigns without building separate logic.
- **Customers:** Receive relevant, on-brand recommendations in email.
- **Attribution:** Email clicks and conversions attributed via set_id/trace_id (F12).

## 5. Scope

### 6. In Scope

- **Request pattern:** Batch: for each recipient (customer_id), call F11 with placement=email_*, channel=email, customer_id, optional campaign_id, limit (e.g. 5). Or open-time: when user opens email, call F11 with customer_id (from link/param) and placement. Return payload: items (product/look IDs, names, image URLs, links) + set_id + trace_id per recipient for attribution.
- **Audience and region:** Respect audience (customer list or segment) and region (e.g. EU vs US) in F11 request; context engine and rules apply. **Availability:** Only in-stock or region-appropriate items where specified (inventory filter via F8/F10).
- **Format:** Response format suitable for email assembly (e.g. HTML snippet, or JSON with image URLs and links). F11 may support response_format=email (optional); or email service maps F11 response to email template.
- **Tracking:** Email links include set_id and trace_id (in URL param or header) so click and conversion can be sent to F12. Email system or landing page sends recommendation_click and recommendation_purchase to F12.

### 7. Out of Scope

- **Email delivery and templates** — Owned by email/CRM (Customer.io, etc.). F16 is the **recommendation payload** only.
- **Delivery API implementation** — F11. F16 is the integration pattern and contract for email consumer.
- **A/B on email creative** — F24 may assign experiment; F16 passes experiment_id to F11 if needed.

## 8. Main User Personas

- **CRM / Email Marketing Manager** — Configures campaigns that use recommendation blocks.
- **Backend/integration engineers** — Build batch or open-time caller to F11 and payload formatter.

## 9. Main User Journeys

- **Batch send:** Campaign scheduled → for each recipient, fetch payload (F11) with customer_id, placement, campaign_id → inject into email template → send. Store set_id/trace_id per recipient for click/conversion tracking.
- **Open-time:** User opens email → email client or tracking pixel triggers request with customer_id (from encrypted param) → F11 returns fresh payload → replace placeholder in email (if supported) or use for next email. Store set_id/trace_id for events.
- **Click:** User clicks recommended product link (contains set_id, trace_id) → lands on PDP or cart → backend sends recommendation_click to F12. Purchase: order confirmation sends recommendation_purchase with set_id, trace_id, order_id, revenue to F12.

## 10. Triggering Events / Inputs

- **Batch:** Campaign run or schedule; input = list of (customer_id, optional segment, region). **Open-time:** Email open event; input = customer_id (from email context). **Click/conversion:** User action; input = set_id, trace_id, event type, order_id (for purchase).

## 11. States / Lifecycle

- **Payload:** Fetched per recipient; transient. **Campaign:** Draft → Scheduled → Sent. No state in F16; email system owns campaign state.
- **Event:** recommendation_click, recommendation_purchase sent to F12 when user acts.

## 12. Business Rules

- **Respect consent:** Do not send recommendation emails to customers who opted out (F22); audience list or segment must be consent-filtered before calling F11.
- **Availability:** Payload should reflect in-stock/region where possible; F11/F8/F10 handle. **Attribution:** Every payload must have set_id/trace_id; every click and purchase must be sent to F12 with those IDs.
- **Rate:** Batch may call F11 at high volume; respect F11 rate limits or use batch endpoint if F11 provides one.

## 13. Configuration Model

- **Placement:** email_block, email_campaign_* (per campaign type). **Limit:** Typically 3–5 items for email. **Campaign ID:** Pass to F11 for attribution. **Response format:** email (with image URLs, links) if F11 supports; else map F11 response to template.

## 14. Data Model

- **Payload (transient):** Same as F11 response; optionally enriched with image URLs, product names, links for email template. **Stored:** set_id, trace_id per recipient (for click/conversion mapping) in email system or short-lived store.
- **Event:** Same as F12 outcome events (click, purchase) with set_id, trace_id.

## 15. Read Model / Projection Needs

- **Email system:** Reads payload (from F11) and set_id/trace_id for tracking. **F17:** Reads events from F12 for email engagement and attribution reporting.

## 16. APIs / Contracts

- **Call F11:** POST /recommendations with placement=email_*, channel=email, customer_id, campaign_id, limit=5. Response: set_id, trace_id, items (id, type, optional name, image_url, link if F11 or formatter adds).
- **Send to F12:** POST /events/outcomes with recommendation_click or recommendation_purchase, set_id, trace_id, placement, channel=email, product_id/look_id, order_id (purchase), revenue (purchase).
- **Optional batch API:** F11 may expose POST /recommendations/batch with list of (customer_id, campaign_id) → list of (customer_id, set_id, trace_id, items) to reduce round-trips.

## 17. Events / Async Flows

- **Consumed:** Campaign trigger (from email system). **Emitted to F12:** recommendation_click, recommendation_purchase (and impression if email “view” is tracked). **Flow:** Batch job or open-time → F11 → format → email; click/purchase → F12.

## 18. UI / UX Design

- **None in platform.** Email creative and template are in email/CRM tool. Platform provides payload and tracking contract only.

## 19. Main Screens / Components

- None. Integration only.

## 20. Permissions / Security Rules

- **F11 call:** Authenticated (API key) by email/CRM backend. **Customer_id** in request; no PII in logs. **Consent:** Audience must be filtered by F22 or email system before calling F11.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** F11 failure rate in batch; missing set_id/trace_id in payload. **Side effects:** F12 receives events; F17 reports email recommendation engagement (BR-8).

## 22. Integrations / Dependencies

- **Upstream:** Delivery API (F11); email/CRM system (Customer.io or other); consent/audience (F22). **Downstream:** Recommendation telemetry (F12); Core analytics (F17). **Shared:** BR-8; F12 event schema.

## 23. Edge Cases / Failure Cases

- **F11 timeout in batch:** Retry or skip recipient; do not send email with empty payload without set_id (or send non-recommendation version). **Open-time failure:** Show static block or hide recommendation block.
- **Recipient not in F11 (new customer):** F11 returns anonymous/non-personal payload; acceptable. **Click without set_id:** If link corrupted, cannot attribute; log and alert.
- **High batch volume:** Throttle or use batch endpoint; avoid overloading F11.

## 24. Non-Functional Requirements

- **Batch latency:** Complete payload fetch for N recipients within send window (e.g. 30 min for 100k). **Open-time:** Single request &lt; F11 SLA. **Availability:** F11 must be up for send and for open-time; fallback = no recommendation block.

## 25. Analytics / Auditability Requirements

- **Attribution:** All clicks and purchases from email must carry set_id/trace_id to F12. **Metrics:** Email recommendation open/click/conversion lift (F17) per BR-8.

## 26. Testing Requirements

- **Unit:** Payload mapping (F11 response → email template vars). **Integration:** Mock F11; batch run for 10 recipients; verify payload and set_id/trace_id; send click event to F12. **E2E:** Real campaign (staging); click through; verify F12 event and F17 report.

## 27. Recommended Architecture

- **Component:** “Channels & consumers” layer. Email/CRM system or **recommendation payload service** (BFF for email) that calls F11 and formats payload; sends events to F12 on click/conversion.
- **Pattern:** Batch: loop over recipients → F11 → store payload + IDs → inject into template → send. Open-time: on open → F11 → inject or redirect. Events: link contains IDs → landing page or webhook sends to F12.

## 28. Recommended Technical Design

- **Payload service:** Serverless or job that receives (campaign_id, recipient_list), calls F11 per recipient (or batch if available), returns (recipient_id, set_id, trace_id, items with URLs). **Tracking:** Links include set_id and trace_id (signed or encrypted if needed). **Webhook or pixel:** Landing page or email system sends recommendation_click to F12; order confirmation sends recommendation_purchase.

## 29. Suggested Implementation Phasing

- **Phase 1:** Batch payload fetch for one campaign type; F11 + placement=email; inject into Customer.io (or one CRM); send click events to F12 with set_id/trace_id.
- **Phase 2:** Open-time personalization; purchase events; region and availability; multiple placements; A/B (F24) experiment_id in campaign.

## 30. Summary

**Email and CRM recommendation payloads** (F16) provide recommendation content for email campaigns by calling the **Delivery API** (F11) with **channel=email** and **placement=email_***, respecting **audience, region, and availability**. Payload includes **set_id** and **trace_id** for attribution; **clicks and purchases** must be sent to **recommendation telemetry** (F12). Email delivery and templates stay in email/CRM; F16 is the integration pattern and contract. BR-8 success metric: email recommendation engagement lift vs control.
