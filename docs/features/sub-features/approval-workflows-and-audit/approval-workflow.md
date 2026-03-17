# Sub-Feature: Approval Workflow (Approval Workflows and Audit)

**Parent feature:** F21 — Approval workflows and audit (`docs/features/approval-workflows-and-audit.md`)  
**BR(s):** BR-12, BR-6  
**Capability:** Require human or governed approval for high-visibility changes (look publish, rule go-live); audit log for critical actions.

---

## 1. Purpose

**Approval workflow:** Look or rule submit → review queue → approver approves/rejects → publish or go-live. **Audit log:** All critical actions (rule change, look publish, suppression) with identity and timestamp. See parent F21.

## 2. Core Concept

**Workflow engine** (or simple state machine): draft → submitted → approved/rejected → published. **Audit:** Append-only log (who, what, when). Consumed by F18, F19 for submit; F6, F10 for apply after approve. See parent §2.

## 3. User Problems Solved

- **Governance:** No unapproved changes. **Compliance:** Audit trail for BR-12. See parent §4.

## 4.–24. Trigger through Testing

User submit; approver action. Integrations: F18, F19, F6, F10. See parent F21 full spec.

---

**Status:** Placeholder. Parent: `docs/features/approval-workflows-and-audit.md`.
