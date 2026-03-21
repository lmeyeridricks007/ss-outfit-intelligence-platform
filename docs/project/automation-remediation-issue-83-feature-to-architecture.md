## Automation remediation: issue #83 feature-to-architecture generation blocked

**Trigger:** issue-created automation  
**Source issue:** https://github.com/lmeyeridricks007/ss-outfit-intelligence-platform/issues/83  
**Automation run scope:** Generate technical architecture artifact and update architecture board for a feature-labeled issue.

## Why this run is blocked

This repository currently does not contain the required stage boards for this workflow:

- `boards/features.md` (missing)
- `boards/technical-architecture.md` (missing)

Without these files, the run cannot safely:

1. resolve the related parent BR from the feature board
2. resolve or assign a FEAT ID from the feature board
3. resolve the next ARCH ID from the technical architecture board
4. append a valid architecture row using existing board structure

The source issue body for #83 is also a BR-stage issue template and does not provide all required feature sections (`Users`, `Value`, `Open questions`) in the expected feature-breakdown shape.

## Evidence collected

- Issue #83 labels include `feature`, but title/body are BR-oriented:
  - Title: `BR-009: Merchandising governance`
  - Body includes `Board Item ID: BR-009`, `Stage: workflow:br`, and BR exit criteria.
- Existing board inventory:
  - Present: `boards/business-requirements.md`
  - Missing: `boards/features.md`, `boards/technical-architecture.md`
- Architecture prompt exists at:
  - `docs/.cursor/prompts/feature-breakdown-to-architecture.md`

## Parsed issue content (best-effort)

- **Problem:** Merchandising teams need governed controls and overrides for recommendation behavior without engineering-only workflows.
- **Users:** Not explicitly sectioned in issue body; implied from BR context.
- **Value:** Not explicitly sectioned in issue body; implied by BR exit criteria.
- **In scope:** Not explicitly sectioned in issue body.
- **Out of scope:** Not explicitly sectioned in issue body.
- **Open questions:** Not explicitly sectioned in issue body.

## Required remediation to unblock automation

1. Create and seed `boards/features.md` with FEAT rows linked from BR rows (`Promotes To`) using repo formatting conventions.
2. Create and seed `boards/technical-architecture.md` with ARCH row schema and item structure.
3. Ensure source feature issues use a consistent template with sections:
   - Problem
   - Users
   - Value
   - In scope
   - Out of scope
   - Open questions
4. Re-run feature-to-architecture automation after FEAT and ARCH boards are available.

## Safe next step recommendation

Run bootstrap prompts in sequence:

1. `docs/.cursor/prompts/bootstrap-seed-feature-board.md`
2. (If available in your workflow set) bootstrap prompt that seeds `boards/technical-architecture.md`
3. Re-trigger architecture automation from a feature-stage issue (or issue body that includes FEAT ID and required sections).
