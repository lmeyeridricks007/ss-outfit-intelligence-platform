# GitHub issue → feature → architecture

You are running in the **target repository**. This prompt guides you through resolving a GitHub issue to a feature and generating technical architecture.

## Purpose

When a GitHub issue with label `workflow:architecture` is opened, you need to:
1. Resolve the target architecture item and source feature from the issue
2. Generate the technical architecture artifact
3. Update the architecture board
4. Commit and push to an `arch/**` branch

## Process

1. **Read the issue**: Understand the architecture work item from the issue title and body
2. **Resolve the feature**: 
   - Check if the issue mentions an ARCH ID (e.g., ARCH-003) or FEAT ID (e.g., FEAT-005)
   - Read `boards/features.md` to find the corresponding feature row
   - Identify the source feature spec document
3. **Follow feature-breakdown-to-architecture.md**: Use that prompt for the detailed architecture generation process
4. **Update the board**: Update `boards/technical-architecture.md` with the architecture item status and details
  - Read `boards/features.md` when it exists to find the corresponding feature row; **if the file is missing, create a minimal `boards/features.md`** (scaffold table + rows inferred from the issue and `docs/features/`) as part of this run — do **not** refuse to proceed only because the board was absent
  
## Branch

Use the branch name provided by the orchestrator (e.g., `arch/issue-42` or `arch/feat-005-recommendation-delivery-api`).

## Do Not

- Create implementation-plan rows or issues
- Create UI/backend/integration/QA issues
- Wait for manual approval before committing

Begin by reading `feature-breakdown-to-architecture.md` for the detailed process.
