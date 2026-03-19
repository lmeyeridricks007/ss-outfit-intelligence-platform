# Feature → GitHub Issue Mapping

**Purpose:** Ensure every Phase 1–5 feature has a corresponding GitHub issue. Use this doc to create or update issues; each issue includes phase label and links to BR/feature list.  
**Source:** `docs/project/feature-list.md`, `docs/project/roadmap.md`, `docs/project/business-requirements.md`.  
**Traceability:** Downstream of feature list and roadmap; issues track F1–F26 for implementation and boards.  
**Repo:** [ss-outfit-intelligence-platform](https://github.com/lmeyeridricks007/ss-outfit-intelligence-platform).  
**Status:** Living document; update when features or phases change.  
**Review:** Board/planning artifact; assess per `docs/project/review-rubrics.md`.  
**Approval mode:** HUMAN_REQUIRED — running the script or creating issues is a human or authorized action; this doc does not assert that issues exist or are approved.

## Creating the issues

1. **Option A — Script (recommended):** From the repo root, run:
   ```bash
   gh auth login   # if not already authenticated
   ./scripts/create-feature-issues.sh --create-labels
   ```
   This creates labels `phase-1` … `phase-5` and `feature`, then one issue per feature (F1–F26) with the body template below. Use `--dry-run` to preview.

2. **Option B — Manual:** Create issues in GitHub with the titles and labels from the tables below; use the **Issue body template** for each body, and add the corresponding `phase-N` and `feature` labels.

**Note:** The script does not check for existing issues; it creates 26 new issues each run. If you already have feature issues, run with `--dry-run` first, or create labels only and add issues manually to avoid duplicates.

---

## Labels to create (if not present)

Create these labels in the repo (e.g. via **Issues → Labels** or `gh label create`):

| Label       | Color (suggestion) | Description              |
|------------|---------------------|--------------------------|
| `phase-1`  | `#0E8A16` (green)   | Data and graph foundation |
| `phase-2`  | `#1D76DB` (blue)    | PDP + Delivery API       |
| `phase-3`  | `#FBCA04` (yellow)  | Cart + email + analytics |
| `phase-4`  | `#FEF2C0` (amber)   | Clienteling + merchandising UI |
| `phase-5`  | `#D93F0B` (red)     | Optimization + look builder |
| `feature`  | `#EDEDED` (gray)    | Tracked as product feature |

---

## Phase 1: Data and Graph Foundation (`phase-1`)

| Feature | Issue title | BR(s) | Spec |
|---------|-------------|-------|------|
| F1 | **[F1] Catalog and inventory ingestion** | BR-2 | [catalog-and-inventory-ingestion.md](../features/catalog-and-inventory-ingestion.md) |
| F2 | **[F2] Behavioral event ingestion** | BR-2 | [behavioral-event-ingestion.md](../features/behavioral-event-ingestion.md) |
| F3 | **[F3] Context data ingestion** | BR-2 | [context-data-ingestion.md](../features/context-data-ingestion.md) |
| F4 | **[F4] Identity resolution** | BR-2, BR-12 | [identity-resolution.md](../features/identity-resolution.md) |
| F5 | **[F5] Product graph** | BR-4 | [product-graph.md](../features/product-graph.md) |
| F6 | **[F6] Outfit graph and look store** | BR-4, BR-6 | [outfit-graph-and-look-store.md](../features/outfit-graph-and-look-store.md) |

---

## Phase 2: PDP + Delivery API (`phase-2`)

| Feature | Issue title | BR(s) | Spec |
|---------|-------------|-------|------|
| F7 | **[F7] Customer profile service** | BR-3 | [customer-profile-service.md](../features/customer-profile-service.md) |
| F8 | **[F8] Context engine** | BR-5 | [context-engine.md](../features/context-engine.md) |
| F9 | **[F9] Recommendation engine core** | BR-5, BR-1 | [recommendation-engine-core.md](../features/recommendation-engine-core.md) |
| F10 | **[F10] Merchandising rules engine** | BR-6 | [merchandising-rules-engine.md](../features/merchandising-rules-engine.md) |
| F11 | **[F11] Delivery API** | BR-7 | [delivery-api.md](../features/delivery-api.md) |
| F12 | **[F12] Recommendation telemetry** | BR-10 | [recommendation-telemetry.md](../features/recommendation-telemetry.md) |

---

## Phase 3: Cart + Email + Analytics (`phase-3`)

| Feature | Issue title | BR(s) | Spec |
|---------|-------------|-------|------|
| F13 | **[F13] PDP recommendation widgets** | BR-1, BR-7 | [webstore-recommendation-widgets.md](../features/webstore-recommendation-widgets.md) |
| F14 | **[F14] Cart recommendation widgets** | BR-1, BR-7 | [webstore-recommendation-widgets.md](../features/webstore-recommendation-widgets.md) |
| F15 | **[F15] Homepage and landing recommendation widgets** | BR-1, BR-7 | [webstore-recommendation-widgets.md](../features/webstore-recommendation-widgets.md) |
| F16 | **[F16] Email and CRM recommendation payloads** | BR-8 | [email-crm-recommendation-payloads.md](../features/email-crm-recommendation-payloads.md) |
| F17 | **[F17] Core analytics and reporting** | BR-10 | [core-analytics-and-reporting.md](../features/core-analytics-and-reporting.md) |

---

## Phase 4: Clienteling + Merchandising UI (`phase-4`)

| Feature | Issue title | BR(s) | Spec |
|---------|-------------|-------|------|
| F18 | **[F18] Admin: look editor** | BR-11, BR-6 | [admin-look-editor.md](../features/admin-look-editor.md) |
| F19 | **[F19] Admin: rule builder** | BR-11, BR-6 | [admin-rule-builder.md](../features/admin-rule-builder.md) |
| F20 | **[F20] Admin: placement and campaign config** | BR-11 | [admin-placement-and-campaign-config.md](../features/admin-placement-and-campaign-config.md) |
| F21 | **[F21] Approval workflows and audit** | BR-12, BR-6 | [approval-workflows-and-audit.md](../features/approval-workflows-and-audit.md) |
| F22 | **[F22] Privacy and consent enforcement** | BR-12 | [privacy-and-consent-enforcement.md](../features/privacy-and-consent-enforcement.md) |
| F23 | **[F23] In-store clienteling integration** | BR-9 | [clienteling-integration.md](../features/clienteling-integration.md) |

---

## Phase 5: Optimization + Look Builder (`phase-5`)

| Feature | Issue title | BR(s) | Spec |
|---------|-------------|-------|------|
| F24 | **[F24] A/B and experimentation** | BR-10 | [ab-and-experimentation.md](../features/ab-and-experimentation.md) |
| F25 | **[F25] Customer-facing look builder** | BR-1, BR-7 | [customer-facing-look-builder.md](../features/customer-facing-look-builder.md) |
| F26 | **[F26] Performance and personalization tuning** | BR-10, BR-3, BR-4 | [performance-and-personalization-tuning.md](../features/performance-and-personalization-tuning.md) |

---

## Issue body template (use for each issue)

For each feature issue, use a body that includes **phase**, **BR link**, and **feature list link**:

```markdown
**Phase:** [phase-N]
**Feature ID:** F[n]
**BR(s):** [e.g. BR-2, BR-4]

**Description:** [one-line from feature list]

**Docs:**
- Feature list: [docs/project/feature-list.md](https://github.com/lmeyeridricks007/ss-outfit-intelligence-platform/blob/main/docs/project/feature-list.md)
- Business requirements: [docs/project/business-requirements.md](https://github.com/lmeyeridricks007/ss-outfit-intelligence-platform/blob/main/docs/project/business-requirements.md)
- Roadmap: [docs/project/roadmap.md](https://github.com/lmeyeridricks007/ss-outfit-intelligence-platform/blob/main/docs/project/roadmap.md)
- Feature spec: [docs/features/...](link to spec if applicable)
```

---

## References

- **Feature list:** `docs/project/feature-list.md`
- **Business requirements:** `docs/project/business-requirements.md`
- **Roadmap:** `docs/project/roadmap.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** Feature → GitHub issue mapping (this document and `scripts/create-feature-issues.sh`).  
**Stage:** Board/planning (issue mapping for features).  
**Approval mode:** HUMAN_REQUIRED.

### Overall disposition

**Eligible for promotion.** The mapping is complete (all F1–F26, all phases), clear, and actionable. All dimensions score 4 or 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL**.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Purpose, structure (phases, tables, labels, template), and two creation options are clear. |
| **Completeness** | 5 | All 26 features mapped; all 5 phases; labels table; script + manual options; issue body template; note on existing issues; references; review record. |
| **Implementation Readiness** | 5 | Next step (create issues) can proceed via script or manual; script is executable and dry-run validated. |
| **Consistency With Standards** | 5 | Terminology (phase-N, F1–F26, BR-ids) and paths align with feature-list and roadmap. |
| **Correctness Of Dependencies** | 5 | Source docs and feature IDs/BRs match `docs/project/feature-list.md`; spec paths resolve to `docs/features/`. |
| **Automation Safety** | 5 | Doc and script do not assert approval or completion; approval mode stated; script requires human auth (gh). |

**Average:** 5.0. **Minimum dimension:** 5.

### Confidence rating

**HIGH.** Inputs (feature list, roadmap, BRs) are stable; scope and usage are clear; script behavior is defined and dry-run verified.

### Blocking issues

**None.**

### Recommended edits

**None required.** Optional: when issues are created, add issue numbers to this doc or to `docs/boards/features.md` for traceability.

### Explicit recommendation

Per approval mode **HUMAN_REQUIRED:** this artifact should move to **READY_FOR_HUMAN_APPROVAL**. A human may run the script or create issues manually; no automatic promotion or completion is implied.

### Propagation to upstream

**None required.** No human rejection comments. If the feature list or roadmap changes (e.g. new feature or phase), update this mapping and the script.

### Pending confirmation

- **Human decision** to run the script or create issues (with `gh auth login` or equivalent).
- After issues exist, optional: link issue numbers back to this doc or to the features board.
