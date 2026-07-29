# API 551 — GitHub + PowerShell Local Pipeline

Статус: CURRENT для Stage 5 и явно переоткрытых Figure.  
Обновлено: 2026-07-29.

## Приоритет

Этот файл дополняет `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`. Более конкретные правила:

1. `docs/project/API551_PR_WORKFLOW_CURRENT.md`;
2. `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`;
3. `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md` — только для явно переоткрытого Figure.

## Локальные пути

```text
Git-worktree: C:\Irvis-UPG\GIT\API 551
Snapshot:     C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT
Temp:         C:\Irvis-UPG\GIT\_api551_tmp
```

Snapshot не содержит `.git` и не используется для commit/push.

## Базовая цепочка

```text
source-gate -> update main -> task/* from main -> checked change -> PR into main -> all checks -> explicit merge -> verify main
```

`candidates` не является рабочей веткой Stage 5.

## PowerShell

- Использовать PowerShell 7: `pwsh`.
- Для многошаговой операции использовать проверенный `.ps1` и validation wrapper.
- Не вставлять в терминал приглашение `PS C:\...>` или старый вывод.
- Не использовать непроверенный скачанный скрипт.
- Не делать `reset --hard`, force push, merge или delete без отдельного разрешения.

## Начальная проверка

```powershell
Set-Location -LiteralPath 'C:\Irvis-UPG\GIT\API 551'
git status -sb
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
.\tools\api551\api551.ps1 source-gate
```

Если есть локальные изменения, неизвестная ветка или SHA-конфликт — остановиться.

## Рабочая ветка

Создавать от проверенного актуального `main`:

```powershell
git switch main
git pull --ff-only origin main
git switch -c 'task/<topic>'
```

Имя ветки должно быть конкретным. Не переиспользовать stale branch без compare.

## LFS

- Broad `git lfs pull` не запускать по умолчанию.
- Импортировать из snapshot только LFS-tracked paths.
- Сверять SHA-256 и size с pointer.
- После импорта:

```powershell
git lfs fsck
git status --short
```

Требуется `Git LFS fsck OK` и пустой status.

## PR check

Перед merge проверить base/head, exact head SHA, changed files, review threads и все workflow runs.

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

Не считать старый зелёный CI доказательством после нового commit.

## Merge и cleanup

Merge допустим только после явной команды пользователя и всех успешных проверок на final head. После merge проверить `main`. Ветку удалять только после проверки отсутствия нужных уникальных commit.

## Handoff

Сообщить repo, branch, PR, base/head SHA, changed files, CI, review status, merge SHA при наличии, риски и следующий шаг.
