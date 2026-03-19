# Sub-Feature: Profile Read API (Customer Profile Service)

**Parent feature:** F7 — Customer profile service (`docs/features/customer-profile-service.md`)  
**BR(s):** BR-3  
**Capability:** Read customer style profile by customer_id for engine and clienteling.

---

## 1. Purpose

Expose **read API** to get **Customer Style Profile** (preferences, affinity, segmentation, intent, confidence) by customer_id. Consumed by F9 (engine) and F23 (clienteling). Respect consent: if F22 says no personalization, return empty or anonymous profile. See parent F7.

## 2. Core Concept

**GET profile by customer_id** (and optional scope: full vs preferences-only). Returns profile object or empty when no profile or consent withdrawn. No write in this sub-feature; profile computation is separate. See parent §2, §6.

## 3. User Problems Solved

- **Engine:** Gets profile for ranking. **Clienteling:** Displays profile (where permitted). See parent §4.

## 4.–10. Trigger through Data Model

Request-time. Inputs: customer_id, optional scope. Outputs: profile JSON or empty. Data: profile store read. See parent §10–14.

## 11. API Endpoints

GET /profile?customer_id=... or GET /profile/{customer_id}. Internal (F11, F23). See parent §16.

## 12.–14. Events, Integrations

Optional; F4 (customer_id), F22 (consent). Downstream F9, F23. See parent §17, §22.

## 15.–24. UI through Testing

No UI for read API. Permissions, errors (profile not found → empty), observability, implementation, testing. See parent §18–26.

---

**Status:** Placeholder. Expand per full 24-section template. Parent: `docs/features/customer-profile-service.md`.
