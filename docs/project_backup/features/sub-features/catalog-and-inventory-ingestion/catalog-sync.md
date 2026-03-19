# Sub-Feature: Catalog Sync (Catalog and Inventory Ingestion)

**Parent feature:** F1 — Catalog and inventory ingestion (`docs/features/catalog-and-inventory-ingestion.md`)  
**BR(s):** BR-2  
**Capability:** Sync product catalog from PIM, Shopify, OMS, DAM, Custom Made into the platform so product graph and engine use current assortment.

---

## 1. Purpose

Ingest and sync **product catalog** (attributes, SKUs, categories, metadata) from source systems (PIM, Shopify, OMS, DAM, Custom Made) on a schedule or event so F5 (product graph) and F6 (look store) have current product data. See parent F1 for full scope.

## 2. Core Concept

A **sync pipeline or job** that pulls catalog data from configured sources, normalizes to canonical product schema, validates and deduplicates, and writes to the platform catalog store. May be batch (nightly) or near real-time per SLA.

## 3. User Problems Solved

- **Assortment freshness:** Engine and graphs use up-to-date products. **Single schema:** Downstream (F5, F6) consume one canonical model.

## 4. Trigger Conditions

Scheduled (cron) or event-driven (webhook from PIM/OMS). See parent spec §10.

## 5. Inputs

Source-specific payloads (API response, file, queue). Required fields: product_id, category, attributes (fabric, color, fit, season, occasion, price tier). See parent §14.

## 6. Outputs

Canonical product records written to catalog store; sync status (success/failure, record count). No direct API response to end users.

## 7. Workflow / Lifecycle

Extract → Normalize → Validate → Deduplicate (by product_id) → Write to catalog store → Report status. Failed records → dead-letter or retry. See parent §11.

## 8. Business Rules

Schema conformance required; product_id is canonical; no PII in catalog. See parent §12.

## 9. Configuration Model

Per-source: endpoint, auth, mapping (source field → canonical), schedule. See parent §13.

## 10. Data Model

Canonical product: product_id (PK), category, attributes (JSON or columns), source_system, updated_at. See parent §14.

## 11. API Endpoints

Internal only: trigger sync (POST) or status (GET). Source systems may expose pull API or push webhook. See parent §16.

## 12. Events Produced

Optional: CatalogSyncCompleted (count, status). See parent §17.

## 13. Events Consumed

Optional: ProductCatalogUpdated from sources. See parent §17.

## 14. Integrations

Upstream: PIM, Shopify, OMS, DAM, Custom Made. Downstream: F5 (product graph), F6 (look store). See parent §22.

## 15. UI Components

None for sync itself. Optional admin: sync status dashboard, trigger button. See parent §18–19.

## 16. UI Screens

Optional: Catalog sync status; config per source. See parent §19.

## 17. Permissions & Security

Sync job or API internal only; source credentials in secrets store. No customer-facing exposure. See parent §20.

## 18. Error Handling

Source unavailable → retry with backoff; invalid record → dead-letter; partial success → report and alert. See parent §23.

## 19. Edge Cases

Duplicate product_id across sources (precedence rule); large catalog (pagination); schema evolution. See parent §23.

## 20. Performance Considerations

Batch size; parallel sources; write throughput to catalog store. See parent §24.

## 21. Observability

Metrics: sync duration, record count, error count. Alerts: sync failure, high error rate. See parent §21, §25.

## 22. Example Scenarios

Nightly job pulls from PIM API → normalizes 10k products → writes to catalog store → F5 graph build runs on updated catalog. See parent spec for full flows.

## 23. Implementation Notes

Backend: sync job (batch or streaming); normalizer; catalog store writer. DB: catalog tables. Jobs: scheduled sync. External APIs: source systems. Frontend: optional admin. See parent §27–28.

## 24. Testing Requirements

Unit: normalizer, validation. Integration: mock source → sync → verify catalog store. See parent §26.

---

**Status:** Placeholder. Expand with full detail using the same 24-section structure as `identity-resolution/resolve-api.md` and `delivery-api/request-orchestration.md`. Parent spec: `docs/features/catalog-and-inventory-ingestion.md`.
