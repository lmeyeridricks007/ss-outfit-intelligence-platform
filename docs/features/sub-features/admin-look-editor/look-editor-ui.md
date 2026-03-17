# Sub-Feature: Look Editor UI (Admin Look Editor)

**Parent feature:** F18 — Admin look editor (`docs/features/admin-look-editor.md`)  
**BR(s):** BR-11, BR-6  
**Capability:** UI for merchandising to create and edit curated looks and submit for approval or publish.

---

## 1. Purpose

**Admin UI** for creating and editing **looks** (product set, metadata, placement). Save as draft; submit for approval (F21) or publish. Role-based access. See parent F18.

## 2. Core Concept

**Screens:** Look list, look create/edit (product picker, metadata, placement), submit for approval, publish. Calls F6 (look store) and F21 (approval). See parent §2, §19.

## 3. User Problems Solved

- **Merchandising:** No engineering needed to add looks. **Governance:** Approval before publish. See parent §4.

## 4.–24. Trigger through Testing

User-driven. Inputs: look data, product ids. Outputs: CRUD to F6; approval request to F21. Permissions: merchandising roles. See parent F18 full spec.

---

**Status:** Placeholder. Parent: `docs/features/admin-look-editor.md`.
