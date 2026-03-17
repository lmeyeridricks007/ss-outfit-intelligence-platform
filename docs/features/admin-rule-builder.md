# Feature Deep-Dive: Admin Rule Builder (F19)

**Feature ID:** F19  
**BR(s):** BR-11 (Admin and merchandising UI), BR-6 (Merchandising control and governance)  
**Capability:** Admin: define and edit merchandising rules  
**Source:** `docs/project/feature-list.md`, `docs/project/domain-model.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Let **merchandising** define and edit **merchandising rules** (pin, exclude, include, category, price, inventory) with **targeting** (placement, campaign, segment, region) and **scheduling** (effective dates), so recommendation behavior is controllable without engineering (BR-11, BR-6). The rule builder is the admin UI that writes to the **rule store** consumed by the **merchandising rules engine** (F10); **approval workflows** (F21) can gate high-visibility or high-risk rules.

## 2. Core Concept

- **Merchandising rule** (domain model): rule_id, type (pin, include, exclude, boost, demotion, category, price, inventory, channel_override), scope (placement_ids, campaign_id, segment, region), target (product_ids, look_ids, category_id, price_min/max, inventory_filter), priority, start_date, end_date, approval_status, owner.
- **Rule builder UI:** Create rule (select type, set scope and target, set dates, priority); edit rule; list/filter rules; **submit for approval** (if F21); **activate** (approval_status = approved; F10 only applies approved + effective rules). No execution logic in UI; F10 evaluates.

## 3. Why This Feature Exists

- **BR-11:** Merchandising must be able to define and edit rules within the tool; adoption and time-to-change are success metrics.
- **BR-6:** Rules are auditable; rule builder is the authoring surface; F10 and F21 handle evaluation and approval.

## 4. User / Business Problems Solved

- **Merchandising Manager:** Control what appears where (pin, exclude) and when (dates); no code or tickets.
- **Consistency:** One place to manage rules; F10 applies consistently across channels.

## 5. Scope

### 6. In Scope

- **Create rule:** Select type (pin, exclude, include, boost, demotion, category, price, inventory). Set **scope:** placement(s), campaign (optional), segment (optional), region (optional). Set **target:** product_ids or look_ids (search/picker), or category_id, or price range, or inventory filter. Set **effective dates** (start, end) and **priority** (integer). Save as draft. **Validation:** Target required; scope at least placement or campaign; dates logical (start &lt; end).
- **Edit rule:** Load rule by rule_id; change any field; save. If rule is approved and live, define policy: edit creates new version or requires re-approval (F21). **List/filter:** List rules by type, placement, state (draft, under_review, approved), effective (current/future/expired). **Delete or deactivate:** Soft delete or set end_date in past; F10 stops applying.
- **State and approval:** Draft → Submit for review (under_review). F21 approval → approved or rejected. Only **approved** and **effective** (date in range) rules are applied by F10. **Audit:** F10 or rule store logs rule_id, who changed, when; F21 logs approval. Rule builder only triggers transitions; does not store audit.
- **Preview (optional):** “See which products this rule affects” (run F10 in dry-run or show target list). **Permissions:** merchandising_editor (create, edit, submit); approver (approve via F21); viewer (read-only).

### 7. Out of Scope

- **Rules engine evaluation** — F10. Builder only writes rule definitions. **Placement/campaign config** — F20 (which strategy per placement); F19 is rule content. **Approval workflow logic** — F21. **Recommendation engine** — F9; F9 calls F10; builder does not call F9.

## 8. Main User Personas

- **Merchandising Manager** — Primary user; creates and edits rules, submits for approval.
- **Approver** — Reviews and approves (F21).

## 9. Main User Journeys

- **Create pin rule:** User clicks “New rule” → type = Pin → scope = placement “pdp_complete_the_look” → target = product “prod-123” (search) → dates = now to 1 year → priority = 1 → Save draft → Submit for review → F21 task → Approver approves → Rule status = approved → F10 applies on next request.
- **Edit exclude rule:** User opens rule → changes end_date to tomorrow (to expire) → Save → F10 stops applying after end_date. **Bulk (optional):** Upload CSV of product_ids for exclude list; validate and create one rule or many.

## 10. Triggering Events / Inputs

- **User actions:** Create, Edit, Save, Submit for approval, Activate (if separate), Delete/Deactivate. **Inputs:** Rule type, scope (placement, campaign, segment, region), target (products, looks, category, price, inventory), dates, priority. **Load:** rule_id → GET rule from rule store → populate form.

## 11. States / Lifecycle

- **Rule state:** draft | under_review | approved | expired (end_date passed). **Effective:** approved and now in [start_date, end_date]. F10 loads only effective rules. **UI:** Buttons per state and role; e.g. Submit only for draft; Activate only after approved (or auto when approved).

## 12. Business Rules

- **Target required:** Pin/exclude/include need product_ids or look_ids; category rule needs category_id; price rule needs min/max. **Scope:** At least one of placement, campaign; optional segment, region. **Priority:** Lower number = higher precedence when multiple rules of same type (document in F10). **No unapproved bulk override:** Rule that applies to “all placements” must be approved (F21); policy in BR-12.

## 13. Configuration Model

- **Rule types:** Pin, exclude, include, boost, demotion, category, price, inventory (from domain model). **Placements:** List from F20 or config. **Approval:** Which rule types or scopes require approval (F21 config). **Permissions:** Per role.

## 14. Data Model

- **UI state:** Current rule (rule_id, type, scope, target, dates, priority, approval_status). **Rule store (F10):** rule_id, type, scope (JSON), target (JSON), start_date, end_date, priority, approval_status, owner_id, created_at, updated_at. Builder writes to rule store via API.

## 15. Read Model / Projection Needs

- **Builder:** GET rule by rule_id; GET rules list (filter by type, placement, state). **F10:** Reads rules for evaluation; builder does not read F10 output. **Product/look search:** For target picker; call catalog or F6.

## 16. APIs / Contracts

- **To rule store:** POST /rules (create), PUT /rules/{rule_id} (update), GET /rules/{rule_id}, GET /rules?type=&placement=&state=. **To F21:** POST submit for approval (rule_id). **Product search:** GET /products/search or F1/F6 for target picker.
- **Example create:** POST /rules { type: "pin", scope: { placement_ids: ["pdp_complete_the_look"] }, target: { product_ids: ["prod-1"] }, start_date: "2025-03-17", end_date: "2026-03-17", priority: 1, approval_status: "draft" } → 201 { rule_id }.

## 17. Events / Async Flows

- **Consumed:** None. **Emitted:** Rule created/updated (rule store); F21 task on submit. **Flow:** User → Builder → Rule store; User → Submit → F21 → Approver → F21 approve → Rule store status = approved; F10 reloads rules (cache TTL).

## 18. UI / UX Design

- **List:** Table (rule_id, type, scope summary, target summary, state, effective dates); filters; “New rule” button. **Editor:** Form: type dropdown; scope (placement multi-select, campaign, segment, region); target (product/look picker or category or price range or inventory); date pickers; priority number; Save, Submit. **Validation:** Inline; required fields per type.

## 19. Main Screens / Components

- **Screens:** Rule list; Rule editor (create/edit). **Components:** RuleList, RuleEditorForm, ScopeSelector, TargetPicker (product/look search), DateRangePicker, StateButtons.

## 20. Permissions / Security Rules

- **Auth:** Admin. **RBAC:** merchandising_editor, approver, viewer. **Audit:** Rule store and F21 log changes; no PII in rules (only product_ids, placement_ids).

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Save failure; rule store unavailable. **Side effects:** Approved rule applied by F10 on next request; expired rule (end_date) stops being applied. **Optional:** Notify approver on submit.

## 22. Integrations / Dependencies

- **Upstream:** Rule store (used by F10); F10 does not have separate “store”—rules may live in same DB as F10 or in config service. **Approval (F21):** Gate approval_status. **Catalog/F6:** Product/look search for target. **Downstream:** F10 reads rules; F9 receives filtered list from F10.

## 23. Edge Cases / Failure Cases

- **Conflicting rules:** Two rules: one pins A, one excludes A. F10 precedence (e.g. exclude wins); document in F19 help. **Invalid target:** Product retired; warn in editor “Product no longer in catalog”; allow save (rule may still run; F10 may skip invalid id). **Concurrent edit:** Optimistic lock or last-write-wins.

## 24. Non-Functional Requirements

- **Load/save:** &lt; 2 s. **Availability:** Admin only; no customer impact.

## 25. Analytics / Auditability Requirements

- **Audit:** Rule store and F21 log who created/updated/approved; BR-6. **Metrics:** Rules created per user; time-to-approve (F21); time-to-live (F19 + F21).

## 26. Testing Requirements

- **Unit:** Form validation; scope/target per type. **Integration:** Create rule via API; load in editor; edit; submit; approve (F21); verify F10 applies (mock request). **E2E:** Create pin rule, approve, trigger recommendation request, verify pinned product first.

## 27. Recommended Architecture

- **Component:** Admin app with F18, F20, F21. **Pattern:** SPA; rule store API; F21 for approval. **Deploy:** With admin.

## 28. Recommended Technical Design

- **Frontend:** React; form state; product/look picker with search API. **Backend:** Rule store (DB table rules); REST API; F21 integration (submit, webhook on approve). **Validation:** Server-side per rule type.

## 29. Suggested Implementation Phasing

- **Phase 1:** Create/edit pin, exclude, include; placement scope; effective dates; draft and approved; rule store and F10 integration. **Phase 2:** Boost, demotion; campaign and segment scope; F21 approval; list filters; priority. **Later:** Category, price, inventory rules; bulk upload.

## 30. Summary

**Admin rule builder** (F19) lets **merchandising define and edit merchandising rules** (pin, exclude, include, boost, demotion, category, price, inventory) with **targeting** (placement, campaign, segment, region) and **scheduling** (effective dates). Rules are stored and **evaluated by the merchandising rules engine** (F10); only **approved** and **effective** rules are applied. **Approval workflows** (F21) can gate high-visibility rules. BR-11 and BR-6 are satisfied; audit is in rule store and F21.
