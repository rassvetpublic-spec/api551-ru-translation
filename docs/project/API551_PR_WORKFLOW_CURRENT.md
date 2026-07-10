# API551 PR Workflow Current

Status: CURRENT PR workflow for API 551 Stage 4+.

## 1. Default chain

```text
source-gate -> clean branch from origin/candidates -> changes -> local checks -> PR into candidates -> CI/status check -> merge only after explicit user command -> verify candidates -> handoff
```

## 2. Branch policy

- `main` is stable and must not be modified directly without explicit user permission.
- Figure candidate and tooling PRs target `candidates`.
- Start from current `origin/candidates`.
- Do not reuse stale branches without checking head SHA and remote state.

## 3. PR check command

```powershell
.\tools\api551\api551.ps1 pr-check -Pr 37
```

This command uses GitHub CLI when available and prints PR metadata and check status without requiring fragile shell `jq` quoting.

## 4. Merge policy

Merge only after the user explicitly says the PR can be merged.

Before merge verify:

1. PR base is `candidates`;
2. head SHA is the expected current commit;
3. CI is successful;
4. changed files are limited to the intended scope;
5. open review comments are understood or resolved;
6. no `main` direct change is involved.

## 5. Force push policy

If a branch must be overwritten, use expected-head guarded force-with-lease. Do not force push blindly. After force push, verify PR head through GitHub API or `gh pr view`; the local `gh` result may lag immediately after push.

## accept-figure command

For a Figure candidate already approved by the user, use the repo-local acceptance command instead of one-off scripts:

```powershell
.	oolspi551pi551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command performs package-check, installs `workspace/figures/NNN`, marks the Figure as accepted, updates `catalog.json`, `index.html`, `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`, bootstrap status markers, and the hard-coded accepted state in `.github/workflows/structure-check.yml`. It does not commit, push, merge, or delete branches.

