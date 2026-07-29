# API551 Tooling Current

Status: CURRENT operational documentation for Stage 4+ and Stage 5.

## Entrypoint

```powershell
.\tools\api551\api551.ps1 source-gate
```

Git-worktree: `C:\Irvis-UPG\GIT\API 551`.  
Snapshot without `.git`: `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT`.

Use the worktree for branches/commits/PRs. Use the snapshot only for verified LFS recovery and visual evidence.

## Commands

```powershell
.\tools\api551\api551.ps1 source-gate
.\tools\api551\api551.ps1 status
.\tools\api551\api551.ps1 docs-sync-check
.\tools\api551\api551.ps1 rules-for -Figure 003
.\tools\api551\api551.ps1 figure-check -Figure 003
.\tools\api551\api551.ps1 package-check -PackageZip C:\Irvis-UPG\GIT\package.zip -Figure 003
.\tools\api551\api551.ps1 pr-check -Pr N
```

## Safety

Read-only actions do not modify the repository. Write actions must not commit, push, merge or delete branches.

The toolkit verifies Stage 5 CURRENT-TZ, mandatory sources, catalog/handoff status, handoff schema, branch policy, CURRENT docs/control characters and LFS-safe Figure state.

A smudged LFS worktree is valid only when `git lfs fsck` is OK and `git status --short` is empty. Broad `git lfs pull` is not a default action.

## accept-figure command

Only for an explicitly reopened and accepted Figure:

```powershell
.\tools\api551\api551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command does not commit, push, merge or delete branches.
