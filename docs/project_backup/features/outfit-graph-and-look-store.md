# Feature Deep-Dive: Outfit Graph and Look Store (F6)

**Feature ID:** F6  
**BR(s):** BR-4 (Product and outfit graph), BR-6 (Merchandising control and governance)  
**Capabilities:** Store and manage curated looks; Model product relationships and compatibility  
**Source:** `docs/project/feature-list.md`, `docs/project/domain-model.md`, `docs/project/glossary.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

**Store and manage curated looks** (product sets intended to be shown together) and **compatibility rules** that merchandising can configure. The outfit graph / look store is the source of **curated** outfit-level content: each **look** has a `look_id`, contains multiple **products**, and has a **lifecycle** (draft, under review, approved, published, retired). It feeds the **recommendation engine** (F9) for “curated” strategy and the **admin look editor** (F18).

## 2. Core Concept

- **Look:** A **product grouping** (see glossary): a set of products meant to be shown together. Identified by `look_id`. Stored and managed in the platform; has lifecycle (draft → under review → approved → published → retired).
- **Outfit graph / look store:** The persistence and query layer for looks. Stores look metadata, look–product associations (many-to-many), optional ordering and roles (e.g. “anchor” suit, “complement” shirt), and **compatibility rules** (style, fabric, occasion) that can be used to validate or generate looks. **Curated looks** are authored by merchandising (via Admin F18 in Phase 4; in Phase 1 can be file- or config-driven).
- **Compatibility rules:** Stored here or in product graph (F5); F6 focuses on **look-level** rules (e.g. “all products in a look must match occasion”) and **look–product** membership. F5 focuses on product–product relationships; F6 focuses on **sets** (looks).

## 3. Why This Feature Exists

- **BR-4:** An outfit graph (or equivalent) must support curated looks and compatibility rules configurable by merchandising.
- **BR-6:** Merchandisers must be able to create and edit looks and define rules; F6 is the storage and governance backend for that.
- **BR-1, BR-5:** The engine needs to retrieve **curated looks** for placement (e.g. “complete the look” on PDP) and to mix curated with rule-based and AI strategies; F6 is the source of curated content.

## 4. User / Business Problems Solved

- **Merchandising:** Single place to define and version “complete looks” and rules; no scattered spreadsheets or per-channel logic.
- **Customers:** See coherent, on-brand looks (e.g. “styled with this suit”) that merchandising has approved.
- **Engine:** One API to fetch looks by placement, product, or occasion; consistent with product graph (F5) for hybrid candidate generation.

## 5. Scope

### 6. In Scope

- **Look entity:** look_id, name, description (optional), source (curated | generated), lifecycle state (draft | under_review | approved | published | retired), created_at, updated_at, owner, optional campaign/placement targeting.
- **Look–product association:** look_id, product_id, position/order, optional role (anchor, complement). Many-to-many; a product can belong to many looks.
- **Compatibility rules (look-level):** Rules that apply to “what can go in a look” (e.g. occasion match, fabric harmony). Stored as config or rule records; used to validate look composition and optionally to generate suggested looks (later). May overlap with F5 rules; F6 owns **look-scoped** rules.
- **Query API:** Get looks by product_id (e.g. “looks containing this suit”), by placement, by occasion, by state (published only for engine). Used by F9 and F18.
- **Lifecycle:** Draft → Under review → Approved → Published (live for engine) → Retired. Only **published** looks are returned to the recommendation engine; Admin (F18) and approval workflows (F21) manage transitions.
- **Phase 1:** Minimal admin (file/config or minimal UI); F6 still stores looks and serves them to engine. Phase 4 adds full Admin look editor (F18).

### 7. Out of Scope

- **Product–product relationship computation** — owned by product graph (F5). F6 stores **which products are in which look**, not generic “product A compatible with product B” (that is F5).
- **Merchandising pin/exclude/boost rules** — owned by merchandising rules engine (F10). F6 does not filter or reorder engine output; it supplies **curated look** candidates.
- **Recommendation ranking** — owned by F9. F6 is read-only for engine; engine ranks looks and items.
- **Authoring UI** — full UI is F18; F6 is storage and API. Phase 1 can use CSV/config import for looks.

## 8. Main User Personas

- **Merchandising Manager** — Creates and edits looks (via F18); benefits from versioning and lifecycle.
- **Style-Seeking / Returning Customer** — Indirect; see curated looks in recommendations.
- **Backend engineers** — Implement store, API, and lifecycle; integrate with F9 and F18.

## 9. Main User Journeys

- **Create look (Phase 4):** Merchandising creates look in Admin (F18) → F18 calls F6 to create look (draft), add products, set metadata → submit for approval (F21) → after approval, publish → F6 state = published → F9 can retrieve.
- **Phase 1:** Import looks from file or config → F6 stores; no UI; engine queries published looks.
- **Recommendation:** F9 requests “looks for product X” or “looks for placement PDP” → F6 returns published looks (filtered by product membership or placement) → F9 merges with other strategies.
- **Retire look:** Admin retires → F6 state = retired → F9 excludes from results.

## 10. Triggering Events / Inputs

- **Request-time:** F9 queries: get looks by product_id, placement, occasion, limit. F18 queries: get look by look_id, list looks by state/filter for admin.
- **Lifecycle transition:** F18 or F21 calls F6 to transition state (e.g. publish, retire). Input: look_id, new_state, optional comment.
- **Bulk import (Phase 1):** File or API to create/update looks in batch; idempotent by look_id.

## 11. States / Lifecycle

- **Look state:** draft → under_review → approved → published → retired. Only **published** looks are eligible for recommendation engine. **Retired** excluded from all queries.
- **Transition rules:** draft → under_review (submit); under_review → approved (approval workflow F21); approved → published (publish action); published → retired (retire). Optional: approved → draft (reject); under_review → draft (withdraw).
- **Versioning (optional):** On edit, create new version or overwrite; if versioned, engine gets “latest published version.”

## 12. Business Rules

- **Publish:** Only looks in state **published** are returned to F9. Draft/under_review/approved are visible only in Admin.
- **Product membership:** All product_ids in a look must exist in catalog (F1); validate on create/update. Optional: validate compatibility (F5 or F6 rules) before publish.
- **Ownership:** Each look has owner (user or system); audit (F21) logs who published/retired.
- **Placement/campaign targeting:** Optional; if present, F6 filters “looks for placement X” so only relevant looks returned. If not present, all published looks eligible (F9/F10 may filter further).

## 13. Configuration Model

- **Lifecycle states:** Configurable state machine (optional); default as above.
- **Compatibility rules (look-level):** Rules for “valid look” (e.g. max products per look, occasion consistency). Stored as config or rule records.
- **Targeting:** Placement IDs, campaign IDs (optional); used to filter which looks are eligible per request.
- **Feature flags:** Use curated looks in engine (on/off per placement).

## 14. Data Model

- **Look:** look_id, name, description, source (curated|generated), state, created_at, updated_at, owner_id, placement_ids (array), campaign_id (optional), version (optional).
- **Look_product:** look_id, product_id, position, role (optional). Unique (look_id, product_id).
- **Look_rule (optional):** look_id or global, rule_type (e.g. occasion_match), config (JSON). For validation or generation.
- **State_history (audit):** look_id, from_state, to_state, changed_at, changed_by.

## 15. Read Model / Projection Needs

- **Recommendation engine (F9):** Reads published looks by product_id, placement, or occasion; needs list of product_ids per look and optional metadata (name, reason). Optimized query path for “looks containing product X” and “looks for placement Y.”
- **Admin look editor (F18):** Reads looks by state, filter; reads single look with full product list and metadata for edit. Writes create/update/state change via F6 API.
- **Analytics:** Optional: which looks were recommended and clicked; requires look_id in recommendation result (F11) and events (F12).

## 16. APIs / Contracts

- **Internal (to F9):**  
  - `GET /looks?product_id=...&placement=...&occasion=...&limit=20` → list of looks (look_id, product_ids, name, ...). Only published.  
  - `GET /looks/{look_id}` → full look (for F18 or F9 when need detail).
- **Admin (to F18):**  
  - `POST /looks` create, `PUT /looks/{look_id}` update (products, metadata), `POST /looks/{look_id}/transition` (state change).  
  - `GET /looks?state=draft|under_review|approved|published|retired` for admin list.
- **Example:**

```json
GET /looks?product_id=prod-suit-1&placement=pdp_complete_the_look&limit=5
→ 200 OK
[
  { "look_id": "look-1", "name": "Navy suit formal", "product_ids": ["prod-suit-1", "prod-shirt-1", "prod-tie-1"], "state": "published" }
]
```

## 17. Events / Async Flows

- **Consumed:** Optional: catalog product retired (F1) → invalidate or warn looks containing that product.
- **Emitted (optional):** `LookPublished`, `LookRetired` for F9 cache invalidation or analytics. Or F9 polls/refreshes on interval.
- **Flow:** F18 creates/updates → F6 stores → on publish, F9 can query. Approval workflow (F21) may gate transition to published.

## 18. UI / UX Design

- **Admin (F18):** Look list, look editor (name, products, order, targeting), state transitions, preview. F18 is the UI; F6 is the backend. See admin-look-editor.md.
- **No customer-facing UI** for F6; customers see looks only as recommendation results (widgets F13–F15, F25).

## 19. Main Screens / Components

- Backend only for F6; screens are in F18. Optional: F6 status (count of published looks, last publish time) in ops dashboard.

## 20. Permissions / Security Rules

- **Read (published):** F9 only; internal. Read (all states): F18 admin role only.
- **Write (create/update/transition):** F18 with role-based access; F21 may enforce approval before publish. No public write.
- **Data:** No PII; product_ids and look metadata only.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Invalid product_id in look (product retired); publish failure; F6 API errors.
- **Side effects:** When look published, F9 may need cache refresh or will pick up on next query. When look retired, F9 stops returning it.

## 22. Integrations / Dependencies

- **Upstream:** Catalog (F1) for product validity. Product graph (F5) optional for compatibility validation. Admin look editor (F18) for authoring; Approval workflows (F21) for gating publish.
- **Downstream:** Recommendation engine (F9) for curated strategy. Delivery API (F11) returns look_id in response when result is a look. Telemetry (F12) can attribute by look_id.
- **Shared:** Domain model (Look, Product); glossary (look, outfit); BR-4, BR-6.

## 23. Edge Cases / Failure Cases

- **Look with retired product:** On F1 product retire, mark look as invalid or auto-retire look; or allow but filter product from display (policy). Recommend: warn in Admin, require republish or edit.
- **Empty look:** Do not allow publish with zero products; validate on transition.
- **Duplicate product in same look:** Validate unique (look_id, product_id); reject or dedupe.
- **Concurrent edit:** Optimistic lock (version) or last-write-wins; document. F18 should refresh before save.
- **F6 down:** F9 fallback: no curated candidates; other strategies (rule-based, AI) still run; do not fail entire request.

## 24. Non-Functional Requirements

- **Query latency:** p95 &lt; 50 ms for “looks by product_id” so F9 is not blocked. Index on product_id and state.
- **Availability:** High; curated strategy is key for PDP/cart. Fallback in F9 when F6 unavailable (e.g. empty curated set).
- **Storage:** Scale to thousands of looks; product membership table can be large (looks × products per look).

## 25. Analytics / Auditability Requirements

- **Audit:** All state transitions (who, when, from/to state) per BR-6; stored in state_history or audit log. Critical for “audit log for look publish” (BR-12, F21).
- **Metrics:** Count of looks by state; publish rate; which looks are returned in recommendations (from F12 if look_id in events).

## 26. Testing Requirements

- **Unit:** Lifecycle transitions; validation (product exists, no duplicate, non-empty); query filters (published only).
- **Integration:** Create look, add products, publish; F9 query returns look; retire; F9 no longer returns. F18 integration tests for create/update/transition.
- **Contract:** Look API response schema for F9 and F18.

## 27. Recommended Architecture

- **Component:** Part of “Product & outfit graph” layer with F5. Can be same service as F5 or separate “look service”; shared product validation against F1.
- **Pattern:** CRUD store (DB) + query API. Index: (product_id, state), (placement, state), (state) for admin list. Optional cache for “looks by product_id” (hot path).

## 28. Recommended Technical Design

- **DB:** looks table, look_products table, optional look_rules, state_history. **API:** REST or internal gRPC. **Validation:** On write, check product_ids exist (F1); optional check F5 compatibility. **Authorization:** Middleware for F18 (admin) vs F9 (read published only). **Cache:** Optional Redis for GET by product_id + placement.

## 29. Suggested Implementation Phasing

- **Phase 1:** Minimal: store and query API; looks imported via file/config; lifecycle = draft | published (no approval); F9 reads published looks. No Admin UI (F18 in Phase 4).
- **Phase 4:** Full lifecycle (under_review, approved); F18 look editor; F21 approval gate for publish; audit log; placement/campaign targeting.
- **Later:** Generated looks (source=generated); look-level A/B; performance at scale.

## 30. Summary

**Outfit graph and look store** (F6) stores **curated looks** (product groupings with look_id and lifecycle) and **look-level compatibility rules**. It is the source of **curated** content for the **recommendation engine** (F9) and the backend for the **admin look editor** (F18). Only **published** looks are returned to the engine; lifecycle is draft → under_review → approved → published → retired, with **approval workflows** (F21) gating publish. It depends on **catalog** (F1) for product validity and **product graph** (F5) for product relationships; it does not apply pin/exclude (that is F10). BR-4 and BR-6 success metrics (graph coverage, audit) apply; implementation can start with file-driven looks in Phase 1 and add full Admin in Phase 4.
