# API551 Tooling Current

Status: CURRENT operational documentation for the repo-local API551 toolkit.

## 1. Single entrypoint

All Stage 4 tooling starts from the repository-local entrypoint:

```powershell
.\tools\api551\api551.ps1 source-gate
```

The repository path normally used on Windows is:

```text
C:\GIT\API 551
```

The visual hydrated view, when needed, is separate:

```text
C:\GIT\API551_HYDRATED_VIEW
```

Do not run one-off scripts from `C:\GIT` as the default workflow. New project automation belongs in `/tools/api551`.

## 2. Default commands

```powershell
.\tools\api551\api551.ps1 source-gate
.\tools\api551\api551.ps1 status
.\tools\api551\api551.ps1 docs-sync-check
.\tools\api551\api551.ps1 rules-for -Figure 003
.\tools\api551\api551.ps1 figure-check -Figure 003
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure 003
.\tools\api551\api551.ps1 pr-check -Pr 37
```

## 3. Safety boundary

Read-only actions: `source-gate`, `status`, `docs-sync-check`, `rules-for`, `figure-check`, `package-check`, `pr-check`, `open-review`.

Write action: `install-package` writes only to `workspace/figures/<NNN>` and never commits, pushes, merges, or deletes branches.

The toolkit must not perform `git add`, `commit`, `push`, merge, branch deletion, or accepted-status promotion unless a future explicit command is added and the user explicitly requests that operation.

## 4. Tooling goal

The toolkit exists to prevent the repeated errors from manual ad-hoc workflows:

- stale local overlays showing different Figure content than `index.html`;
- old package files overriding accepted metadata;
- accepted Figures containing `review_only_not_accepted`;
- broken relative image links;
- LFS pointers being mistaken for real PNGs inside packages;
- manual branch and PR checks performed without a consistent source-gate.
