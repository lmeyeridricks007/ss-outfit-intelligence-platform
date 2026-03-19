# Sub-Feature: Batch Payload (Email/CRM Recommendation Payloads)

**Parent feature:** F16 — Email and CRM recommendation payloads (`docs/features/email-crm-recommendation-payloads.md`)  
**BR(s):** BR-8  
**Capability:** Batch request to F11 for multiple customers (e.g. email audience) and format payload for email/CRM.

---

## 1. Purpose

**Batch** call to Delivery API (F11) for a list of customer_ids (or segment) and **format** response for email/CRM (e.g. image URLs, tracking params). Respects audience, region, availability. See parent F16.

## 2. Core Concept

**Batch job or API:** Input = campaign_id, audience (customer_ids or segment), placement=email_block, limit. For each customer (or sample), call F11 → collect response → format for email (product/look ids, image URLs, click tracking with set_id/trace_id). See parent §2.

## 3. User Problems Solved

- **Email recommendations:** Personalized block per recipient. **Attribution:** set_id/trace_id in links. See parent §4.

## 4.–24. Trigger through Testing

On campaign send or scheduled. Inputs: campaign, audience, placement. Outputs: payload per customer or aggregated. Integrations: F11, email system (Customer.io, etc.). See parent F16 full spec.

---

**Status:** Placeholder. Parent: `docs/features/email-crm-recommendation-payloads.md`.
