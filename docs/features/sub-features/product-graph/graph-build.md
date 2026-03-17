# Sub-Feature: Graph Build (Product Graph)

**Parent feature:** F5 — Product graph (`docs/features/product-graph.md`)  
**BR(s):** BR-4  
**Capability:** Build and maintain product relationship graph (compatibility, substitution) from catalog and rules.

---

## 1. Purpose

Build and refresh the **product graph** (product-to-product relationships: compatibility, substitution, style, occasion) from catalog (F1) and optional rules so F9 (engine) can use it for candidate generation. See parent F5.

## 2. Core Concept

A **graph build** job or service that reads canonical catalog, applies compatibility/substitution rules or ML, and writes graph (nodes = products, edges = relationship type + weight). Incremental or full rebuild. See parent §2.

## 3. User Problems Solved

- **Complete-the-look:** Engine has compatibility edges (suit → shirt → tie). **Substitution:** Similar products for out-of-stock. See parent §4.

## 4. Trigger Conditions

Scheduled (after catalog sync) or on-demand. See parent §10.

## 5. Inputs

Catalog products (from F1); optional compatibility rules or training data. See parent §14.

## 6. Outputs

Graph store updated (nodes, edges). No API response to channels. See parent §14–15.

## 7. Workflow / Lifecycle

Read catalog → Compute relationships (rules or model) → Validate → Write graph. See parent §11.

## 8. Business Rules

Canonical product_id; relationship types (compatible, substitute); no PII. See parent §12.

## 9. Configuration Model

Build schedule; relationship types; thresholds. See parent §13.

## 10. Data Model

Graph: product_id (node), related_product_id, relationship_type, weight/score. See parent §14.

## 11. API Endpoints

Internal: trigger build; graph read by F9. See parent §16.

## 12. Events Produced

Optional: GraphBuilt. See parent §17.

## 13. Events Consumed

CatalogSyncCompleted (optional) to trigger build. See parent §17.

## 14. Integrations

Upstream: F1 (catalog). Downstream: F9 (engine). See parent §22.

## 15.–16. UI Components / Screens

Optional admin: graph stats, build status. See parent §18–19.

## 17. Permissions & Security

Internal only. See parent §20.

## 18.–19. Error Handling / Edge Cases

Build failure → retry; partial graph. See parent §23.

## 20.–21. Performance / Observability

Build duration; graph size; F9 read latency. See parent §24–25.

## 22.–24. Example Scenarios / Implementation Notes / Testing

See parent F5. Expand with full 24-section detail per `resolve-api.md` template.

---

**Status:** Placeholder. Parent: `docs/features/product-graph.md`.
