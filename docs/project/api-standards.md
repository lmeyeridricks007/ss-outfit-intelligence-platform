# API Standards

## Scope
These standards apply to recommendation delivery APIs and any internal APIs that manage curated looks, rules, campaigns, experiments, or recommendation metadata.

## API style guidance
- Prefer resource-oriented HTTP APIs for initial external and channel-facing integration.
- Use JSON request and response bodies with explicit field names and stable schemas.
- Separate read-heavy delivery endpoints from internal management endpoints.
- Treat recommendation responses as contracts that include both content and decision metadata.

## Core contract expectations
A recommendation request should support optional inputs such as:
- customer identifier
- product identifier
- cart contents
- channel or surface
- context such as location, weather, season, and occasion
- requested recommendation type or slot

A recommendation response should include:
- recommendation set identifier
- trace identifier
- recommendation type
- surface or slot context
- ranked items or outfits
- reasoning metadata safe for the consumer
- experiment or variant metadata where applicable
- timestamps or freshness metadata when useful

## Versioning approach
- Version external contracts explicitly.
- Avoid breaking changes to active consumer integrations without a version increment.
- Prefer additive changes for new metadata when possible.
- Keep internal and external contract versions independently manageable if their release cadences differ.

## Error model
- Use a consistent machine-readable error structure with code, message, and optional detail fields.
- Distinguish client input errors, authorization errors, dependency failures, and degraded fallback responses.
- For non-fatal recommendation degradation, prefer a successful response with fallback metadata rather than hard failure when safe.
- Do not expose sensitive internal reasoning, rule content, or customer profile detail in public error messages.

## Authentication expectations
- Require authenticated access for internal management APIs.
- Recommendation delivery endpoints should use the least-privileged mechanism suitable for the consuming surface, such as server-to-server credentials or trusted first-party tokens.
- Separate internal admin permissions from channel-consumer permissions.
- Audit access to sensitive recommendation management operations.

## Contract consistency rules
- Use stable canonical IDs rather than source-specific ad hoc identifiers in public contracts.
- Keep naming consistent across endpoints, events, and documentation.
- Return explicit nullability or omission rules for optional fields.
- Include recommendation metadata needed for analytics, experimentation, and support investigation.
- Document fallback behavior so consumers know how to render empty or degraded states.
