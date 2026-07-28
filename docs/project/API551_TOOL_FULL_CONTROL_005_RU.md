# API551 Codex Pack №005 — описание

Пакет №005 объединяет ночной оператор, Python bootstrap, GitHub relay, auto-fetch и token-saver.

## Точки входа

- Bootstrap: `tools\api551\api551_005_bootstrap.ps1`
- GitHub relay: `tools\api551\publish_codex_report.ps1`
- Preview index: `tools\api551\api551_preview_index.ps1`

## Принцип

Codex не должен ждать ручной распаковки и не должен писать артефакты вне `C:\GIT`.

## Инструментарий в repo

Если Codex исправляет или создаёт инструмент, он должен оформить это как repo asset:

- код: `tools/api551/`
- русская документация: `docs/project/`
- проверка: repo-local smoke test
- PR: отдельная tooling branch

## Проверка без изменения состояния

Перед обычным запуском выполнить:

- pwsh -NoProfile -ExecutionPolicy Bypass -File tools\api551\api551_005_bootstrap.ps1 -ValidateOnly
- pwsh -NoProfile -ExecutionPolicy Bypass -File tools\api551\api551_preview_index.ps1 -Figure 010 -State review -ValidateOnly
- pwsh -NoProfile -ExecutionPolicy Bypass -File tools\api551\publish_codex_report.ps1 -ValidateOnly

После PASS целевой скрипт запускают той же командой без ключа ValidateOnly. Все persistent outputs остаются внутри C:\GIT.

## Git LFS

Text-only relay устанавливает GIT_LFS_SKIP_SMUDGE=1 перед созданием временного worktree, поэтому не загружает бинарные LFS-объекты и не зависит от LFS bandwidth.

После успешного push relay удаляет чистый временный report worktree без ключа force.

## Branch guard для preview index

`tools\api551\api551_preview_index.ps1` разрешён только на ветке с именем `preview-*`.

- `main` и `candidates` запрещены явно;
- detached HEAD запрещён;
- ветки, не соответствующие `preview-*`, запрещены;
- guard выполняется и в режиме `-ValidateOnly`, и при обычном запуске до любых изменений файлов.

Положительный smoke test должен выполняться на временной ветке вида `preview-smoke-*`. Отрицательные smoke tests должны подтверждать отказ на `main` и `candidates`.
