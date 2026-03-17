# Sub-Feature: Placement Config (Admin Placement and Campaign Config)

**Parent feature:** F20 — Admin placement and campaign config (`docs/features/admin-placement-and-campaign-config.md`)  
**BR(s):** BR-11  
**Capability:** Configure where recommendations appear, which strategy applies, and campaign/placement settings; preview.

---

## 1. Purpose

**Admin UI** to configure **placements** (PDP, cart, homepage, email, clienteling) and **campaigns**: strategy mapping, limit, fallback, optional experiment. **Preview** button calls F11 with sample request. See parent F20.

## 2. Core Concept

**Screens:** Placement list, placement/campaign edit (strategy, limit, fallback), preview (calls F11, shows items). Reads/writes config consumed by F9 and F11. See parent §2, §19.

## 3. User Problems Solved

- **Control** where and how recommendations show. **Preview** before go-live. See parent §4.

## 4.–24. Trigger through Testing

User-driven. Integrations: F11 (preview), F9 (strategy config). See parent F20 full spec.

---

**Status:** Placeholder. Parent: `docs/features/admin-placement-and-campaign-config.md`.
