# Sub-Feature: Look Browse (Customer-Facing Look Builder)

**Parent feature:** F25 — Customer-facing look builder (`docs/features/customer-facing-look-builder.md`)  
**BR(s):** BR-1, BR-7  
**Capability:** Let customers browse and explore curated looks on a dedicated surface; recommendations via F11; placement and metrics tracked.

---

## 1. Purpose

**Customer-facing surface** (e.g. “Looks” or “Outfit ideas” page) where users **browse** curated looks. Renders looks from F6 (or F11 with placement=look_builder). Delivers recommendations via same F11; impression/click/add-to-cart sent to F12 with set_id/trace_id. See parent F25.

## 2. Core Concept

**Browse UI:** List or grid of looks (from F11 or F6); filter by occasion, season. Click look → detail or “Shop the look.” F11 called with placement=look_builder; events to F12. See parent §2.

## 3. User Problems Solved

- **Discovery:** Customers explore outfits. **Attribution:** Same pipeline as PDP/cart. See parent §4.

## 4.–24. Trigger through Testing

User visits look builder page. Integrations: F11, F6, F12. See parent F25 full spec.

---

**Status:** Placeholder. Parent: `docs/features/customer-facing-look-builder.md`.
