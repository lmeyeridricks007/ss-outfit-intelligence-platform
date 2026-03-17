# Feature Deep-Dive: Approval Workflows and Audit (F21)

**Feature ID:** F21  
**BR(s):** BR-12 (Governance and safety), BR-6 (Merchandising control and governance)  
**Capability:** Enforce approval and audit for high-visibility changes  
**Source:** `docs/project/feature-list.md`, `docs/project/business-requirements.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

**Require human or governed approval** for **high-visibility or high-risk** recommendation content (e.g. look publish, rule that applies to all placements); **log critical actions** (rule change, look publish, suppression) with **identity and timestamp** for governance and rollback (BR-12, BR-6). Approval workflows gate transitions in **admin look editor** (F18) and **admin rule builder** (F19); **audit log** is consumed by compliance and ops.

## 2. Core Concept

- **Approval workflow:** When merchandising **submits** a look for publish or a rule for approval, a **task** is created for an **approver**. Approver **approves** or **rejects** (with optional comment). On approve, the **target entity** (look or rule) transitions to approved state; then author can **publish** (look) or rule becomes **effective** (F10). **High-visibility** = as defined (e.g. homepage placement, rule affecting all users); exact list is **missing decision** in BRs.
- **Audit:** Every **critical action** (look publish, look retire, rule create/update/delete, suppression) is **logged** with who (user_id), what (entity type, entity_id, action), when (timestamp). Stored in **audit log** (append-only); queryable by admins and compliance. **No PII** in audit (only user_id or role).

## 3. Why This Feature Exists

- **BR-12:** High-visibility or high-risk changes require human approval before go-live; no unapproved bulk overrides.
- **BR-6:** Critical actions (rule change, look publish, suppression) must be logged with identity and timestamp.

## 4. User / Business Problems Solved

- **Governance / Compliance:** Audit trail and approval gate for sensitive changes. **Merchandising:** Clear path from “submit” to “live” without engineering. **Risk:** Prevents accidental or unauthorized bulk changes.

## 5. Scope

### 6. In Scope

- **Workflow:** **Submit for approval** (from F18 or F19) creates **approval task** (task_id, entity_type=look|rule, entity_id, submitted_by, submitted_at, status=pending). **Approver** sees task list; opens task; sees entity summary (or link to F18/F19 read-only); **approves** or **rejects** (comment optional). On approve: entity state → approved (F6 or rule store); author can then publish (look) or rule is active (F10). On reject: entity state → draft; author notified (optional). **Permissions:** Only users in approver role can approve.
- **High-visibility definition:** Config or list of (placement, rule scope) that require approval. E.g. “homepage_looks_for_you” look publish requires approval; “rule affecting all placements” requires approval. **Missing decision** in BRs; F21 implements once defined.
- **Audit log:** **Write:** On every critical action (look: create, update, publish, retire; rule: create, update, delete; suppression action if separate). Payload: action, entity_type, entity_id, user_id, timestamp, optional old/new snapshot (e.g. state). **Read:** API or UI for admins to query audit log (filter by entity, user, date). **Retention:** Per policy (e.g. 2 years). **No PII** in log (user_id is internal id; no customer data).
- **Integration:** F18 calls F21 “submit look for approval” → F21 creates task; F21 “approve” → F21 calls F6 “set state approved” (or F6 exposes transition that F21 triggers). F19 same for rules. **Audit:** F6 and rule store (or F21) write to audit log on state change and on publish/retire/rule change.

### 7. Out of Scope

- **Content of looks or rules** — F18, F19. F21 only gates **transition** and **logs**. **Delivery API or engine** — F11, F9. **Privacy/consent** — F22. **Approval mode (HUMAN_REQUIRED vs AUTO_APPROVE)** — Project lifecycle (review-rubrics); F21 is the human approval implementation for content.

## 8. Main User Personas

- **Merchandising Manager** — Submits looks/rules for approval. **Approver** — Reviews and approves/rejects. **Compliance / Ops** — Queries audit log.

## 9. Main User Journeys

- **Submit and approve look:** User submits look in F18 → F21 task created → Approver sees “Look X pending” → Opens → Reviews (in F18 read-only or summary) → Approves → F6 state = approved → Author publishes in F18. **Audit:** Entries “look submitted,” “look approved,” “look published” with user and timestamp.
- **Reject:** Approver rejects with comment “Fix product order” → F6 state = draft; author sees comment (in F21 or F18) → Edits and resubmits.
- **Audit query:** Compliance user opens audit UI → Filters by entity_type=look, date last 30 days → Sees list of publish/retire actions with user and time.

## 10. Triggering Events / Inputs

- **Submit:** entity_type, entity_id, submitted_by. **Approve/Reject:** task_id, action (approve|reject), comment (optional), approver_id. **Audit write:** action, entity_type, entity_id, user_id, timestamp (triggered by F6, rule store, or F21).

## 11. States / Lifecycle

- **Task:** pending → approved | rejected. **Entity (look/rule):** draft → under_review (on submit) → approved (on approve) | draft (on reject). **Audit entry:** Immutable; append-only.

## 12. Business Rules

- **One approver per task** (or group); no self-approval (submitter ≠ approver). **Approval required:** Only for entities in high-visibility list (when defined). **Audit:** Every critical action must be logged; no deletion of audit entries. **Retention:** Audit log retained per policy; read-only after write.

## 13. Configuration Model

- **High-visibility list:** Placements or rule scopes that require approval; config or DB table. **Approver roles:** Which roles can approve (e.g. merchandising_approver). **Audit:** Actions to log (list); retention period.

## 14. Data Model

- **Task:** task_id, entity_type, entity_id, submitted_by, submitted_at, status, approver_id (optional), resolved_at, comment. **AuditLog:** log_id, action, entity_type, entity_id, user_id, timestamp, optional payload (old/new state). **Append-only;** no update/delete.

## 15. Read Model / Projection Needs

- **Approver:** Task list (pending); task detail (entity summary). **Compliance:** Audit log query (by entity, user, date). **F18/F19:** Task status for entity (e.g. “Pending approval”); on approve, entity state from F6/rule store.

## 16. APIs / Contracts

- **Submit:** POST /approval/submit { entity_type: "look", entity_id: "look-1" } → 201 { task_id }. **Approve:** POST /approval/tasks/{task_id}/approve { comment: "OK" }. **Reject:** POST /approval/tasks/{task_id}/reject { comment: "..." }. **Task list:** GET /approval/tasks?status=pending. **Audit:** GET /audit?entity_type=&entity_id=&user_id=&from=&to= → list of audit entries.
- **F6/rule store:** On state transition, call F21 or write directly to audit log (shared log store). Prefer F21 as single writer for audit for consistency.

## 17. Events / Async Flows

- **Consumed:** Submit from F18/F19; Approve/Reject from approver UI. **Emitted:** Task created; Task resolved (optional event to notify author). **Audit:** Sync write on every critical action; no async for audit (ensure no loss).

## 18. UI / UX Design

- **Task list:** Table (entity type, entity id, submitted by, date); Approve / Reject buttons. **Task detail:** Entity summary (name, state) or link to F18/F19; Approve / Reject with comment field. **Audit viewer:** Filters (entity, user, date); table (action, entity, user, timestamp); export CSV (optional).

## 19. Main Screens / Components

- **Screens:** Pending approvals; Audit log viewer. **Components:** TaskList, TaskDetail, ApproveRejectButtons, AuditLogTable, AuditFilter.

## 20. Permissions / Security Rules

- **Submit:** Merchandising editor. **Approve:** Approver role only; cannot approve own submit. **Audit read:** Compliance, ops, admin; read-only. **Audit write:** System only (F21, F6, rule store); no user delete.

## 21. Notifications / Alerts / Side Effects

- **Optional:** Email or in-app notify approver on submit; notify author on approve/reject. **Side effects:** Entity state change (F6, rule store) on approve; F10 applies newly approved rules.

## 22. Integrations / Dependencies

- **Upstream:** F18 (look submit), F19 (rule submit). **Downstream:** F6 (look state), rule store (rule approval_status). **Audit store:** Shared append-only log. **Shared:** BR-12, BR-6; review-rubrics (approval mode).

## 23. Edge Cases / Failure Cases

- **Entity deleted before approve:** Task still exists; approve/reject updates task; F6/rule store may no-op if entity gone. **Concurrent approve:** One wins; task status = resolved; idempotent. **Audit write failure:** Retry; do not skip; alert.

## 24. Non-Functional Requirements

- **Audit:** Append-only; durable; queryable within 1 min of write. **Task list:** Load &lt; 2 s. **Availability:** Required for approval flow; no customer impact if down (only blocks publish).

## 25. Analytics / Auditability Requirements

- **Audit log** is the primary artifact; BR-6 and BR-12. **Metrics:** Time to approve; reject rate; audit volume.

## 26. Testing Requirements

- **Unit:** Task state transition; audit payload. **Integration:** F18 submit → F21 task → Approve → F6 state approved. **Audit:** Trigger action → verify audit entry written and queryable.

## 27. Recommended Architecture

- **Component:** Admin app or dedicated approval service. **Audit:** Dedicated audit log store (e.g. append-only table or audit service). **Pattern:** F18/F19 → F21 submit → Task → Approver → F21 approve → F6/rule store update + audit write.

## 28. Recommended Technical Design

- **Task table:** tasks (task_id, entity_type, entity_id, submitted_by, status, approver_id, resolved_at, comment). **Audit table:** audit_log (id, action, entity_type, entity_id, user_id, ts, payload). **API:** REST for submit, approve, reject, task list, audit query. **F6/rule store:** Callback or API from F21 on approve to set state.

## 29. Suggested Implementation Phasing

- **Phase 1:** Submit and approve for looks only; task list and detail; F6 state transition on approve; audit write for look publish/retire. **Phase 2:** Rules approval; high-visibility config; audit viewer UI; reject with comment; notify (optional). **Later:** Multi-step approval; delegation; retention and export.

## 30. Summary

**Approval workflows and audit** (F21) **gate high-visibility changes** (look publish, rule activation) with **human approval** and **log critical actions** (rule change, look publish, suppression) with **identity and timestamp**. **Approvers** resolve tasks created when merchandising **submits** from F18 or F19; on **approve**, entity state is updated (F6, rule store). **Audit log** is append-only and queryable for compliance. BR-12 and BR-6 are satisfied; high-visibility definition is a missing decision to be configured when resolved.
