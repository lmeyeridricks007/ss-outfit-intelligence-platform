# Sub-Feature Index

**Purpose:** Master index of Feature → Sub-feature decomposition and spec file paths.  
**Source:** `docs/project/feature-list.md`, `docs/features/SUMMARY.md`, parent feature specs.  
**Review:** Sub-feature deliverable reviewed per `docs/project/review-rubrics.md`; see [REVIEW-RECORD.md](./REVIEW-RECORD.md). Status: READY_FOR_HUMAN_APPROVAL.

---

## Feature → Sub-Feature Mapping

| Feature (parent spec) | Sub-feature | Spec file | Status |
|------------------------|-------------|-----------|--------|
| **Identity Resolution (F4)** | resolve-api | [identity-resolution/resolve-api.md](./identity-resolution/resolve-api.md) | Done |
| | link-management | [identity-resolution/link-management.md](./identity-resolution/link-management.md) | Done |
| | consent-check | [identity-resolution/consent-check.md](./identity-resolution/consent-check.md) | Done |
| | identity-cache | [identity-resolution/identity-cache.md](./identity-resolution/identity-cache.md) | Done |
| | audit-log | [identity-resolution/audit-log.md](./identity-resolution/audit-log.md) | Done |
| **Delivery API (F11)** | request-orchestration | [delivery-api/request-orchestration.md](./delivery-api/request-orchestration.md) | Done |
| | identity-enrichment | [delivery-api/identity-enrichment.md](./delivery-api/identity-enrichment.md) | Done |
| | response-formatting | [delivery-api/response-formatting.md](./delivery-api/response-formatting.md) | Done |
| | fallback-handling | [delivery-api/fallback-handling.md](./delivery-api/fallback-handling.md) | Done |
| **Catalog and inventory ingestion (F1)** | catalog-sync | [catalog-and-inventory-ingestion/catalog-sync.md](./catalog-and-inventory-ingestion/catalog-sync.md) | Placeholder |
| **Behavioral event ingestion (F2)** | event-ingest | [behavioral-event-ingestion/event-ingest.md](./behavioral-event-ingestion/event-ingest.md) | Placeholder |
| **Context data ingestion (F3)** | context-ingest | [context-data-ingestion/context-ingest.md](./context-data-ingestion/context-ingest.md) | Placeholder |
| **Product graph (F5)** | graph-build | [product-graph/graph-build.md](./product-graph/graph-build.md) | Placeholder |
| **Outfit graph and look store (F6)** | look-store | [outfit-graph-and-look-store/look-store.md](./outfit-graph-and-look-store/look-store.md) | Placeholder |
| **Customer profile service (F7)** | profile-read-api | [customer-profile-service/profile-read-api.md](./customer-profile-service/profile-read-api.md) | Placeholder |
| **Context engine (F8)** | context-assembly | [context-engine/context-assembly.md](./context-engine/context-assembly.md) | Placeholder |
| **Recommendation engine core (F9)** | strategy-orchestrator | [recommendation-engine-core/strategy-orchestrator.md](./recommendation-engine-core/strategy-orchestrator.md) | Placeholder |
| **Merchandising rules engine (F10)** | rule-evaluation | [merchandising-rules-engine/rule-evaluation.md](./merchandising-rules-engine/rule-evaluation.md) | Placeholder |
| **Recommendation telemetry (F12)** | event-schema | [recommendation-telemetry/event-schema.md](./recommendation-telemetry/event-schema.md) | Placeholder |
| **Webstore recommendation widgets (F13–F15)** | pdp-widget | [webstore-recommendation-widgets/pdp-widget.md](./webstore-recommendation-widgets/pdp-widget.md) | Placeholder |
| **Email/CRM recommendation payloads (F16)** | batch-payload | [email-crm-recommendation-payloads/batch-payload.md](./email-crm-recommendation-payloads/batch-payload.md) | Placeholder |
| **Core analytics and reporting (F17)** | attribution-job | [core-analytics-and-reporting/attribution-job.md](./core-analytics-and-reporting/attribution-job.md) | Placeholder |
| **Admin look editor (F18)** | look-editor-ui | [admin-look-editor/look-editor-ui.md](./admin-look-editor/look-editor-ui.md) | Placeholder |
| **Admin rule builder (F19)** | rule-builder-ui | [admin-rule-builder/rule-builder-ui.md](./admin-rule-builder/rule-builder-ui.md) | Placeholder |
| **Admin placement and campaign config (F20)** | placement-config | [admin-placement-and-campaign-config/placement-config.md](./admin-placement-and-campaign-config/placement-config.md) | Placeholder |
| **Approval workflows and audit (F21)** | approval-workflow | [approval-workflows-and-audit/approval-workflow.md](./approval-workflows-and-audit/approval-workflow.md) | Placeholder |
| **Privacy and consent enforcement (F22)** | consent-store | [privacy-and-consent-enforcement/consent-store.md](./privacy-and-consent-enforcement/consent-store.md) | Placeholder |
| **Clienteling integration (F23)** | clienteling-api-client | [clienteling-integration/clienteling-api-client.md](./clienteling-integration/clienteling-api-client.md) | Placeholder |
| **A/B and experimentation (F24)** | variant-assignment | [ab-and-experimentation/variant-assignment.md](./ab-and-experimentation/variant-assignment.md) | Placeholder |
| **Customer-facing look builder (F25)** | look-browse | [customer-facing-look-builder/look-browse.md](./customer-facing-look-builder/look-browse.md) | Placeholder |
| **Performance and personalization tuning (F26)** | coverage-metrics | [performance-and-personalization-tuning/coverage-metrics.md](./performance-and-personalization-tuning/coverage-metrics.md) | Placeholder |

---

## Status Legend

- **Done:** Full 24-section sub-feature spec with examples and implementation implications.
- **Placeholder:** Folder and one sample sub-feature spec; expand using same template.

---

## References

- Parent feature specs: `docs/features/*.md`
- Feature list: `docs/project/feature-list.md`
- Sub-features README: [README.md](./README.md)
