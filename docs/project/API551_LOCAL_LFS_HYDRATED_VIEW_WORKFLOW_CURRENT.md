# API 551 — Local Git/LFS and Hydrated Snapshot Workflow

Status: CURRENT local workflow rule.  
Project: API 551 RU Translation / Stage 5.  
Updated: 2026-07-29.

## Folder roles

Git-worktree:

```text
C:\Irvis-UPG\GIT\API 551
```

Use for Git, `task/*`, commits, source-gate and PR preparation. Real LFS content is valid when `git lfs fsck` is OK and `git status --short` is empty.

Snapshot without `.git`:

```text
C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT
```

Use only for verified LFS recovery, visual inspection and offline evidence.

Temporary workspace: `C:\Irvis-UPG\GIT\_api551_tmp`.

## Rules

1. GitHub remains source of truth for branches, SHA, text state, catalog/index and status.
2. Do not run broad `git lfs pull` by default.
3. Never copy `.git` or the whole snapshot over the repository.
4. Import only current-branch Git LFS paths.
5. Match snapshot SHA-256 and size to pointer `oid sha256` and `size`.
6. After import require `git lfs fsck OK` and empty `git status --short`.
7. Never commit mismatched, unverified or unexpectedly modified binaries.
8. Snapshot is not authority for rules, translations or accepted status.

## Validation

```powershell
git lfs fsck
git status --short
git rev-parse HEAD
(git lfs ls-files --name-only).Count
```

Baseline before PR #65 merge: HEAD `4a537be3eafc3a54db1faf32aab0c1494c5c91ac` and 161 LFS paths. After merge, update the expected HEAD from verified `main`.

## Figure coverage

For every accepted Figure verify `figure_NNN.png` and `figure_NNN.source_crop.png` under `workspace/figures/NNN/`.

## Failure handling

On SHA/size mismatch, stop and report the exact path. If status is non-empty, do not commit or merge. Do not use `git reset --hard` as the default recovery action.

## CI relationship

CI validates text and pointers without broad LFS download. Local hydrated content supplements QA but never overrides CURRENT project sources.

## Operating pattern

1. Обновить Git-worktree без broad LFS pull.
2. Проверить branch/head и catalog status.
3. Импортировать только недостающие tracked LFS paths из snapshot.
4. Для каждого файла проверить oid/size.
5. Выполнить `git lfs fsck` и проверить чистый status.
6. Сделать отдельный датированный backup snapshot при значимой точке.
7. Повторить source-gate перед новой задачей.

## Backup naming

```text
C:\Irvis-UPG\GIT\API551_HYDRATED_BACKUP_MAIN_<YYYY-MM-DD>.zip
C:\Irvis-UPG\GIT\API551_LOCAL_LFS_AND_WORKSPACE_BACKUP_<YYYY-MM-DD>.zip
```

Backup — локальный safety artifact, не production input и не файл repo без отдельного решения пользователя.

## Source-gate impact

При LFS-budget, recovery или visual-review задаче handoff обязан явно различать Git-worktree и snapshot, сообщать проверенные SHA/size и не повышать локальный cache до source of truth.
