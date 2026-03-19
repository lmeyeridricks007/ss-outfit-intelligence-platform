# Feature Deep-Dive: Admin Look Editor (F18)

**Feature ID:** F18  
**BR(s):** BR-11 (Admin and merchandising UI), BR-6 (Merchandising control and governance)  
**Capability:** Admin: create and edit looks  
**Source:** `docs/project/feature-list.md`, `docs/project/architecture-overview.md`, `docs/project/domain-model.md`

---

## 1. Purpose

Let **merchandising** create and edit **curated looks** and **publish** (or submit for approval) **without engineering**, so looks stay current and on-brand (BR-11, BR-6). The look editor is the admin UI for the **outfit graph / look store** (F6); it creates/updates look metadata and look–product associations and triggers **lifecycle transitions** (draft → under review → approved → published → retired), with **approval workflows** (F21) where required.

## 2. Core Concept

- **Look** = product grouping (set of products to show together); has look_id, name, products (ordered), optional description, placement/campaign targeting, lifecycle state (see F6 and domain model).
- **Look editor:** UI to create new look (name, add products from catalog search, set order), edit existing look (add/remove/reorder products, change name, targeting), and **transition state** (submit for review, publish, retire). **Role-based access;** only authorized merchandising roles. **Preview** of how look will appear (optional). Integrates with **approval workflows** (F21) for high-visibility publish.

## 3. Why This Feature Exists

- **BR-11:** Merchandising must be able to create or edit a look and publish (or submit for approval) within the tool without engineering. Success: adoption and time-to-change (TBD).
- **BR-6:** Merchandisers can create and edit looks; changes auditable (F6 state_history; F21 audit).

## 4. User / Business Problems Solved

- **Merchandising Manager:** Single place to author and publish looks; no tickets to engineering.
- **Brand consistency:** Curated looks stay on-brand and up to date.
- **Speed:** Time from “request” to “live” within target (TBD).

## 5. Scope

### 6. In Scope

- **Create look:** Name, optional description; search/browse catalog (from F1); add products to look with drag-drop or list; set order (position). Save as **draft**. Optional: placement/campaign targeting. Validate: at least one product; product_ids exist in catalog.
- **Edit look:** Load look by look_id (from F6); change name, description, product list, order, targeting. Save (stays in current state or moves to draft if was published—define policy). **Versioning:** Optional; overwrite or new version.
- **State transitions:** Draft → Submit for review (under_review). Under review → Approved (by F21) or Rejected (back to draft). Approved → Publish (published). Published → Retire (retired). UI buttons per role and state; F6 API enforces valid transitions.
- **Preview:** Optional preview of look (product cards in order) before publish. **Publish:** Only published looks appear in F9; editor calls F6 transition API.
- **List/filter:** List looks by state (draft, under_review, approved, published, retired); filter by name, placement; sort by updated_at. **Permissions:** Create/edit for merchandising role; approve for approver role (F21); read-only for viewer.
- **Audit:** F6 stores state_history (who, when, from/to state); F21 may add approval comment. Editor does not store audit; F6 and F21 do.

### 7. Out of Scope

- **Outfit graph storage and API** — F6. Editor calls F6; does not implement store.
- **Approval workflow logic** — F21. Editor triggers “submit for review” and “publish”; F21 gates approval. **Rule builder** — F19. **Placement/campaign config** — F20 (editor may set targeting on look; F20 configures which placement uses which strategy).

## 8. Main User Personas

- **Merchandising Manager** — Primary user; creates and edits looks, submits for approval, publishes.
- **Approver** — Reviews and approves (F21); uses editor to see look content and approve/reject.

## 9. Main User Journeys

- **Create:** User clicks “New look” → enters name → searches products → adds 5 products → reorders → saves as draft → clicks “Submit for review” → F6 state = under_review; F21 task created. Approver opens task → sees look in editor (read-only or link) → approves → F6 state = approved. User clicks “Publish” → F6 state = published → F9 can now return this look.
- **Edit published:** User opens published look → edits (add product) → saves; policy: either new draft (published unchanged until new publish) or “save as new version” (publish creates new version). Define in F6. **Retire:** User clicks “Retire” → F6 state = retired → F9 stops returning.

## 10. Triggering Events / Inputs

- **User actions:** Create, Save, Submit for review, Publish, Retire. **Inputs:** Look name, description, product_ids (ordered), placement_ids (optional), campaign_id (optional). **Load:** look_id → F6 GET look → populate form.

## 11. States / Lifecycle

- **Look state (F6):** draft | under_review | approved | published | retired. **UI:** Buttons enabled per state and role (e.g. Publish only when approved and user has publish permission). **Conflict:** Concurrent edit; optimistic lock (version) or last-write-wins; document.

## 12. Business Rules

- **Publish only approved (if F21 enabled):** Transition to published allowed only from approved when approval workflow is required for this look/placement. **Retire:** Any role with edit permission can retire; optional confirmation. **Product validity:** All product_ids must exist in catalog (F1); validate on save; warn if product retired.
- **No PII in look:** Look contains only product_ids and metadata; no customer data.

## 13. Configuration Model

- **Lifecycle:** Which transitions require approval (F21 config). **Catalog source:** F6 or F1 product search API for “add product” in editor. **Permissions:** Roles (merchandising_editor, approver, viewer) and which can publish/retire.

## 14. Data Model

- **UI state:** Current look (look_id, name, description, product_ids in order, state, placement_ids). **F6 entities:** See F6 data model (look, look_product, state_history). **No new persistence** in editor; all writes to F6.

## 15. Read Model / Projection Needs

- **Editor:** Reads look by look_id from F6; reads product catalog (search) from F1 or F6 for “add product.” **List:** F6 GET /looks?state=... for admin list. **Approval:** F21 provides tasks; editor may link to look or show read-only view.

## 16. APIs / Contracts

- **To F6:** GET /looks/{look_id}; POST /looks (create); PUT /looks/{look_id} (update); POST /looks/{look_id}/transition (state change). **To F1 or catalog:** GET /products/search?q=... for product search in “add product.” **From F21:** Optional GET approval tasks for current user; or F21 UI separate.
- **Example create:** POST /looks { name: "Navy formal", product_ids: ["p1","p2","p3"], state: "draft" } → 201 { look_id }.

## 17. Events / Async Flows

- **Consumed:** None required. **Emitted:** Editor triggers F6 state transition; F6 may emit LookPublished (for F9 cache). **Flow:** User → Editor → F6 API; User → Submit → F21 (if approval required) → Approver → F21 approve → User → Publish → F6.

## 18. UI / UX Design

- **List:** Table or cards (look name, state, product count, updated_at); filters (state, name); “New look” button. **Editor:** Form: name, description; product list (drag to reorder, remove); “Add product” (search modal); buttons: Save, Submit for review, Publish, Retire (per state/role). **Preview:** Inline or modal with product cards. **Validation:** Inline errors (e.g. “Add at least one product”).

## 19. Main Screens / Components

- **Screens:** Look list; Look editor (create/edit). **Components:** LookList, LookEditorForm, ProductSearchModal, ProductOrderList, StateTransitionButtons, PreviewModal.

## 20. Permissions / Security Rules

- **Auth:** Admin auth (SSO or internal). **RBAC:** merchandising_editor (create, edit, submit, publish if no approval), approver (approve in F21), viewer (read-only). **Audit:** F6 and F21 log who did what; editor does not store PII.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Save failure; F6 unavailable. **Side effects:** Published look appears in F9; retired look disappears from F9. **Optional:** Notify approver when submitted (F21 or email).

## 22. Integrations / Dependencies

- **Upstream:** Outfit graph and look store (F6) for CRUD and state; Catalog (F1) or F6 for product search; Approval workflows (F21) for gating publish. **Downstream:** F9 reads published looks from F6; editor does not call F9. **Shared:** Domain model (Look); BR-11, BR-6.

## 23. Edge Cases / Failure Cases

- **Product retired after look saved:** Warn in editor “Product X is retired”; allow save (look still valid for historical) or require remove. **Concurrent edit:** Optimistic lock (version) or warn “updated by another user.” **F6 down:** Show error; retry. **Invalid state transition:** F6 returns 400; editor shows message.

## 24. Non-Functional Requirements

- **Load time:** List &lt; 2 s; editor load &lt; 1 s. **Save:** &lt; 2 s. **Availability:** Same as admin app; no customer impact if admin down.

## 25. Analytics / Auditability Requirements

- **Audit:** F6 state_history (who, when, transition); F21 approval log. **Metrics:** Adoption (looks created/edited per user); time-to-publish (from create to published) for BR-11.

## 26. Testing Requirements

- **Unit:** Form validation; state button visibility per role/state. **Integration:** Create look via F6 API; load in editor; edit and save; transition to published; verify F6 state. **E2E:** User creates look, submits, approver approves, user publishes; verify look in F9 response (staging).

## 27. Recommended Architecture

- **Component:** Part of “Admin & analytics” layer. **Pattern:** SPA or server-rendered admin app; calls F6 REST API; product search from F1 or F6. **Deploy:** With admin app (F19, F20, F21 same app or separate).

## 28. Recommended Technical Design

- **Frontend:** React (or similar); auth via admin SSO. **API layer:** BFF or direct to F6; product search GET to catalog service. **State:** Editor state in component or Redux; persist only via F6. **Permissions:** Check role before showing Publish/Retire; F6 can enforce transition rules.

## 29. Suggested Implementation Phasing

- **Phase 1 (F18 in Phase 4):** Create, edit, list; draft and published only (no approval); F6 integration; product search. **Phase 2:** Submit for review, approve (F21), approved state; retire; state_history view; time-to-change metric.

## 30. Summary

**Admin look editor** (F18) lets **merchandising create and edit curated looks** and **publish** (or submit for approval via F21) **without engineering**. It is the UI for the **outfit graph / look store** (F6): create/edit look metadata and product membership, and trigger **lifecycle transitions**. Only **published** looks are returned by the recommendation engine (F9). **Approval workflows** (F21) can gate publish for high-visibility looks. BR-11 and BR-6 are satisfied; audit is in F6 and F21.
