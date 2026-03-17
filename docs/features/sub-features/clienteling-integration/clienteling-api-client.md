# Sub-Feature: Clienteling API Client (Clienteling Integration)

**Parent feature:** F23 — In-store clienteling integration (`docs/features/clienteling-integration.md`)  
**BR(s):** BR-9  
**Capability:** Associate-facing app/tablet calls Delivery API with customer_id, store/region; displays recommendations and (where permitted) style profile.

---

## 1. Purpose

**Clienteling app** (or tablet) **calls F11** with customer_id, placement=clienteling, channel=clienteling, optional store_id/region. Renders recommendations; where permitted shows style profile (F7). Sends outcome events (F12) with set_id/trace_id. See parent F23.

## 2. Core Concept

**API client** in app: build request (customer_id from store/CRM context, placement, channel) → call F11 → render items; optional GET profile (F7) if consent. **Events:** impression, click, add-to-cart with set_id, trace_id. See parent §2, §16.

## 3. User Problems Solved

- **In-store recommendations** same logic as web. **Associate** sees customer and recommendations. See parent §4.

## 4.–24. Trigger through Testing

User opens app; associate selects customer. Integrations: F11, F7, F12. Permissions: associate role; consent for profile. See parent F23 full spec.

---

**Status:** Placeholder. Parent: `docs/features/clienteling-integration.md`.
