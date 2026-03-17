# Feature Deep-Dive: Admin Placement and Campaign Config (F20)

**Feature ID:** F20  
**BR(s):** BR-11 (Admin and merchandising UI)  
**Capability:** Admin: configure placement and campaign  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Let **merchandising and CRM** configure **where** recommendations appear, **which strategy** applies per placement, and **campaign/placement settings** (with **preview**), so channels and engine behavior are controllable without code (BR-11). Placement and campaign config drive the **Delivery API** (F11) and **recommendation engine** (F9) strategy selection and **fallback** behavior.

## 2. Core Concept

- **Placement** = where recommendations are shown (e.g. pdp_complete_the_look, cart_complete_your_outfit, homepage_looks_for_you, email_block, clienteling). **Campaign** = marketing or placement configuration used to scope rules and attribution (e.g. email campaign, PDP placement).
- **Config UI:** Define placements (id, name, channel); for each placement set **primary strategy** (curated, similarity, co-occurrence, hybrid mix), **fallback strategy** (e.g. popular_in_category), **limit** (default 10), optional **campaign_id** for attribution. **Preview:** “See sample recommendations for this placement” (call F11 with placement and sample context; show result in admin). **Campaign:** Create campaign (name, id); attach to placement or to rules (F19); used for attribution in F11 and F17.

## 3. Why This Feature Exists

- **BR-11:** Admin must support campaign/placement setup and algorithm/strategy selection; preview is required for confidence.
- **Architecture:** Single engine (F9) with per-placement strategy config; F20 is the source of that config.

## 4. User / Business Problems Solved

- **Merchandising / CRM:** Control which strategy runs where; see preview before go-live. **Product:** No code change for new placement or strategy mix.

## 5. Scope

### 6. In Scope

- **Placement config:** List placements (from registry or config). Per placement: primary_strategy (e.g. curated+similarity), fallback_strategy (e.g. popular_in_category), limit, optional campaign_id. **Strategy params:** e.g. similarity model id, curated look set; optional JSON. **Save** to config store; F9 and F11 read on request (or cache with TTL).
- **Campaign config:** Create campaign (campaign_id, name, optional start/end); link to placement(s) or use in rules (F19). Campaign_id passed in F11 request for attribution (F17, F24).
- **Preview:** Button “Preview” → call F11 (or F9) with placement, sample anchor/session (configurable); display returned items in admin. No outcome events; preview only. **Permissions:** merchandising, CRM roles; read-only for viewer.
- **High-visibility list (optional):** Which placements require approval before go-live (F21); config or separate list (missing decision in BRs). F20 may show “Approval required” for certain placements.

### 7. Out of Scope

- **Look or rule content** — F18, F19. F20 only configures “which strategy for which placement.” **Approval workflow** — F21. **Delivery API or engine implementation** — F11, F9. **Channel UI** — F13–F15, F16, F23 render placements; F20 only config.

## 8. Main User Personas

- **Merchandising Manager, CRM / Email Marketing Manager** — Configure placements and campaigns; use preview.
- **Product Manager** — Oversee strategy mix and new placements.

## 9. Main User Journeys

- **Set strategy for PDP:** User opens placement “pdp_complete_the_look” → sets primary = curated + similarity, fallback = popular_in_category, limit = 10 → Save → next F11 request for that placement uses this config. **Preview:** User clicks Preview → sees 10 sample items → confirms and saves.
- **Create campaign:** User creates campaign “Summer 2025 email” → attaches to placement email_block → emails using that campaign_id get attributed in F17.

## 10. Triggering Events / Inputs

- **User actions:** Edit placement config, Save; Create campaign; Preview (triggers F11 with sample context). **Inputs:** placement_id, primary_strategy, fallback_strategy, limit, campaign_id, strategy_params. **Load:** GET placement config and campaign list from config store.

## 11. States / Lifecycle

- **Config:** Saved or unsaved (draft in UI). **Campaign:** Active (in use) or archived. **No approval in F20** for config; approval for “go-live” of placement may be in F21 (separate). **Preview:** Transient; no save.

## 12. Business Rules

- **Placement id must match** what channels send in F11 request (e.g. pdp_complete_the_look). **Fallback required:** Every placement must have fallback strategy so F9 never returns empty (or F11 handles). **Preview:** Use sample context (e.g. anchor_product_id from catalog); do not use real customer_id in preview (or use test id).

## 13. Configuration Model

- **Placement registry:** List of placement_ids and names (from product/BRs). **Strategy types:** curated, similarity, co-occurrence, popular_in_category, hybrid (with mix %). **Config store:** placement_id → { primary_strategy, fallback_strategy, limit, campaign_id, params }. **Campaign store:** campaign_id, name, start_date, end_date (optional).

## 14. Data Model

- **PlacementConfig:** placement_id, primary_strategy, fallback_strategy, limit, campaign_id, params (JSON), updated_at, updated_by. **Campaign:** campaign_id, name, start_date, end_date, created_at. **Preview:** No persistence; request/response only.

## 15. Read Model / Projection Needs

- **F9 / F11:** Read placement config to select strategy and fallback for each request. **F19:** May read placement list for rule scope. **F17 / F24:** campaign_id in events for attribution. **Builder (F20):** Reads config and campaign list; writes config.

## 16. APIs / Contracts

- **Config store:** GET /config/placements; GET /config/placements/{id}; PUT /config/placements/{id}. **Campaign:** POST /campaigns; GET /campaigns; PUT /campaigns/{id}. **Preview:** POST /admin/preview (internal) with placement, sample context → F11 or F9 → return items (no set_id/trace_id needed for preview, or use test ids).
- **Example:** PUT /config/placements/pdp_complete_the_look { primary_strategy: "curated+similarity", fallback_strategy: "popular_in_category", limit: 10 }.

## 17. Events / Async Flows

- **Consumed:** None. **Emitted:** Config updated (optional event for F9 cache invalidation). **Flow:** User → F20 UI → Config store; F9/F11 read config on request or from cache.

## 18. UI / UX Design

- **Placement list:** Table (placement_id, name, channel, primary strategy, fallback, limit); Edit button; Preview button. **Placement editor:** Form (primary strategy dropdown, fallback dropdown, limit number, campaign picker); Save; Preview. **Campaign list:** Create campaign; list campaigns with name and dates. **Preview:** Modal or panel with sample recommendation items (product/look cards).

## 19. Main Screens / Components

- **Screens:** Placement list; Placement editor; Campaign list; Campaign create/edit. **Components:** PlacementTable, PlacementEditorForm, StrategySelector, PreviewButton, PreviewModal, CampaignForm.

## 20. Permissions / Security Rules

- **Auth:** Admin. **RBAC:** merchandising, CRM (edit); viewer (read). **Preview:** Internal only; do not expose F11 publicly via preview (use admin auth).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Config save failure. **Side effects:** F9/F11 use new config on next request (or after cache TTL). **Preview:** No side effects (no events to F12).

## 22. Integrations / Dependencies

- **Upstream:** Config store (DB or config service). **Downstream:** F9 (strategy selection), F11 (pass-through or reads config). **F18, F19:** May read placement list. **F21:** Optional “placement go-live” approval for high-visibility placements.

## 23. Edge Cases / Failure Cases

- **Invalid strategy name:** Validate against allowed list; reject save. **Preview failure:** F11 timeout or error; show “Preview unavailable” in admin. **Missing fallback:** Require fallback in form; reject save if empty.

## 24. Non-Functional Requirements

- **Load/save:** &lt; 2 s. **Preview:** &lt; 5 s (depends on F11). **Availability:** Admin only.

## 25. Analytics / Auditability Requirements

- **Audit:** Config change log (who, when, placement_id, old/new). **Metrics:** Config changes per user (optional).

## 26. Testing Requirements

- **Unit:** Form validation; strategy list. **Integration:** Save config; trigger F11 request with placement → verify F9 uses saved strategy (mock or staging). **Preview:** Call preview API; verify response shape.

## 27. Recommended Architecture

- **Component:** Admin app with F18, F19, F21. **Config store:** DB table or config service (e.g. etcd, Consul). **F9/F11:** Read config at startup or per request (with cache).

## 28. Recommended Technical Design

- **Backend:** Config API; campaign CRUD; preview = call F11 with test context. **Frontend:** React forms; preview modal. **Cache:** F9 caches placement config with TTL (e.g. 1 min) or on config update event.

## 29. Suggested Implementation Phasing

- **Phase 1:** Placement list and edit (primary + fallback + limit); config store; F9 reads config. **Phase 2:** Preview; campaign CRUD; strategy params (JSON); F17 campaign attribution. **Later:** Placement registry from product; high-visibility flag for F21.

## 30. Summary

**Admin placement and campaign config** (F20) lets **merchandising and CRM** configure **which strategy and fallback** apply per **placement**, and manage **campaigns** for attribution. **Preview** allows testing before go-live. Config is read by **recommendation engine** (F9) and **Delivery API** (F11). No look or rule content (F18, F19); only placement/campaign and strategy selection. BR-11 satisfied.
