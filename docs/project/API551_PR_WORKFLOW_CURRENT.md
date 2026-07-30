# API551 PR Workflow Current

Status: CURRENT PR workflow for completed Stage 4 and Stage 5 task branches.

## Default chain

```text
source-gate -> task/* from current main -> scoped change -> diff/review -> PR into main -> all CI/docs checks -> explicit merge -> verify main
```

## Branch policy

- Stable: `main`; no direct writes.
- Default work: `task/<topic>` from current `main`.
- PR base: `main`.
- `candidates` is historical Stage 4 state, not the Stage 5 working branch.
- Reopened Figure/maintenance work also uses a dedicated non-main branch from current `main`.

Executable policy is synchronized in config, handoff and handoff schema.

## PR #65 registration status

PR #65 is merged and verified in `main` at `eeca80146ff59660326eef55582ad611f2d7c3c4`; Gate 0 is complete. Gate 1 may start only in a new task branch from current `main` after a fresh source-gate.

## PR check

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

## Merge policy

Verify base/head, exact head SHA, all required checks, intended diff, addressed reviews, schema validity, docs sync, source-gate and explicit user authorization. Do not merge while any check is queued, running, failed, cancelled or stale.

## Force/cleanup

Do not force-push blindly. Delete a temporary branch only after verified merge and separate safety review.

## accept-figure command

Only for an explicitly reopened and accepted Figure:

```powershell
.\tools\api551\api551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command does not commit, push, merge or delete branches.
