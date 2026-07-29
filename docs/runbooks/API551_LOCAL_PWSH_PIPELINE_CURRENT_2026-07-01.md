# API 551 — локальный PowerShell runbook

Статус: CURRENT Stage 5 runbook.  
Обновлено: 2026-07-29.

## 1. Рабочая папка

```powershell
Set-Location -LiteralPath 'C:\Irvis-UPG\GIT\API 551'
```

Snapshot `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` не является Git-worktree.

## 2. Проверить состояние

```powershell
git status -sb
git branch --show-current
git rev-parse HEAD
git lfs fsck
.\tools\api551\api551.ps1 source-gate
```

Остановиться при локальных изменениях, неизвестной ветке, LFS-ошибке или source-gate failure.

## 3. Обновить main

```powershell
git switch main
git fetch origin main
git pull --ff-only origin main
```

## 4. Создать Stage 5 task-ветку

```powershell
git switch -c 'task/<topic>'
```

Ветка должна начинаться от актуального `main`. `candidates` не использовать как Stage 5 base.

## 5. Проверить изменения

```powershell
git status --short
git diff --check
.\tools\api551\api551.ps1 docs-sync-check
```

Для Figure/package/LFS добавить соответствующие repo-local проверки.

## 6. PR

Открыть PR `task/* -> main`. Проверить exact head SHA, base SHA, changed files, review threads и все GitHub Actions runs.

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

## 7. Merge

Не мержить, пока final-head CI не зелёный, документация/schema/source-gate не проверены и пользователь явно не разрешил merge.

## 8. После merge

1. проверить merge SHA и содержимое `main`;
2. обновить локальный `main` через `--ff-only`;
3. повторить source-gate;
4. удалять task-ветку только после проверки уникальных commit и разрешённого cleanup;
5. не запускать broad `git lfs pull` по умолчанию.
