# API 551 — локальный pipeline через pwsh

Статус: CURRENT operational addendum.

Дата: 2026-07-01.

Область применения: локальная работа в Windows, передача `.ps1`-скриптов через ChatGPT, проверка overlay-пакетов, PR-проверки, слияние `candidates -> main`, синхронизация веток и правила копирования команд в терминал.

Приоритет: этот файл дополняет `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`. Для принятых Stage 4 Figure-объектов более приоритетным остаётся `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`.

## 1. Язык документации и комментариев

Новые рабочие инструкции, runbook-файлы, поясняющие комментарии в `.ps1` и пользовательские handoff-команды для этого проекта писать по-русски.

Исключения допустимы только для:

1. имён команд, параметров, путей и GitHub/Git терминов;
2. уже существующих upstream-файлов, которые не меняются в текущей задаче;
3. технических строк, где английский текст является частью API, CLI или CI.

## 2. Основная оболочка

Для локальных команд и доставляемых `.ps1` использовать PowerShell 7 через `pwsh`.

Windows PowerShell 5.1 через `powershell.exe` по умолчанию не использовать. Он допустим только по явной просьбе пользователя или для legacy-скрипта, который требует именно 5.1.

Причина: PowerShell 5.1 чаще ломает UTF-8/кириллицу и может превращать штатный stderr от `git` в ложную ошибку `NativeCommandError`.

## 3. Команды для чата

Если пользователь уже находится в открытом `pwsh` и видит prompt вида `PS C:\...>`, команды давать без внешнего `pwsh -Command`.

Правильный формат для уже открытого `pwsh`:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Checker=(Get-ChildItem $D -Filter 'api551_validate_and_run_ps1_pwsh.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; $Target=(Get-ChildItem $D -Filter 'api551_*_pwsh.ps1' | Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; & pwsh -NoProfile -ExecutionPolicy Bypass -File $Checker -TargetScript $Target -ValidateOnly
```

Если пользователь находится не в `pwsh`, сначала дать короткую команду входа:

```powershell
pwsh -NoProfile
```

Затем дать одну строку для выполнения уже внутри `pwsh`.

Не вкладывать `pwsh -Command "...$D..."` внутрь уже открытого `pwsh`: внешний интерпретатор может съесть переменные `$D`, `$Checker`, `$Target`, после чего появятся ошибки вида `=: The term '=' is not recognized`.

## 4. Формат копирования

Операционные команды давать одной физической строкой через `;`.

Не использовать длинные многострочные блоки для ручной вставки в терминал: при копировании из чата порядок строк может нарушиться.

Для сложных операций выдавать не тело скрипта в чат, а `.ps1`-файл и короткую команду запуска через проверяльщик.

## 5. Локальные пути

Путь локального checkout по умолчанию:

```text
C:\GIT\API 551
```

Скачанные скрипты и overlay-пакеты искать через системную папку Downloads:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
```

Не зашивать `C:\Users\...\Downloads` вручную.

## 6. Постоянный проверяльщик скриптов

Основной wrapper:

```text
scripts/api551_validate_and_run_ps1_pwsh.ps1
```

Он должен:

1. найти `pwsh`;
2. найти target-скрипт из Downloads или из `-TargetScript`;
3. вывести путь, размер и SHA-256 target-скрипта;
4. выполнить PowerShell parser validation;
5. выполнить PSScriptAnalyzer, если он установлен локально;
6. остановиться при parser errors;
7. запускать target только после успешной проверки;
8. вернуть exit code target-скрипта.

## 7. Требования к target-скриптам

Скрипты, которые меняют файловую систему, Git, GitHub, ветки, PR или overlay, должны иметь режим:

```text
-ValidateOnly
```

`-ValidateOnly` проверяет предусловия и план действий, но не меняет состояние.

High-risk скрипты также должны:

1. проверять `remote.origin.url`;
2. проверять текущую/целевую ветку;
3. проверять состояние рабочей папки;
4. проверять, что путь находится внутри ожидаемого проекта;
5. требовать явное подтверждение перед `reset`, `clean`, `delete`, `push`, `merge`, удалением веток;
6. вызывать внешние команды массивом аргументов, а не склеенной строкой.

## 8. Обработка git/gh/pwsh в скриптах

При обёртывании внешних команд (`git`, `gh`, `pwsh`) в PowerShell:

1. читать код возврата из `$LASTEXITCODE`;
2. не считать сам факт вывода в stderr ошибкой;
3. нормально обрабатывать штатные сообщения Git, например `Already on 'candidates'`;
4. падать только при ненулевом exit code, если команда не помечена как допустимо падающая.

## 9. Single-branch clone

Локальный checkout может быть создан как single-branch `candidates`. В таком случае `origin/main` может отсутствовать локально даже при наличии remote-ветки `main`.

Перед проверкой или синхронизацией `main` и `candidates` скрипт должен явно подтянуть обе remote-tracking ветки:

```powershell
git fetch origin +refs/heads/main:refs/remotes/origin/main +refs/heads/candidates:refs/remotes/origin/candidates --prune
```

Нельзя полагаться только на `git fetch origin --prune`, если дальше используется `git rev-parse origin/main`.

## 10. Проверка overlay ZIP

Overlay ZIP для наложения на репозиторий должен содержать только project-relative paths.

Разрешённый пример:

```text
workspace/figures/051/figure_051.png
workspace/figures/051/figure_051.source_crop.png
workspace/figures/051/figure_051.object.json
workspace/figures/051/figure_051.object.html
workspace/figures/051/figure_051.out.html
```

Запрещено в корне overlay без отдельного решения:

```text
README_*.md
*_QA_REPORT.json
debug/*
temp/*
*.log
```

Перед применением overlay использовать:

```text
scripts/api551_overlay_sanity_pwsh.ps1
```

## 11. Acceptance PR preflight

Перед push accepted Figure PR проверять:

1. `catalog.json` парсится;
2. статус Figure согласован между catalog и object JSON;
3. accepted/not_accepted/changed статистика ожидаемая;
4. `figure_*.out.html` чистый и не содержит service/review markers;
5. `figure_*.object.html` содержит service/review data и относительную ссылку на source PDF;
6. каждый Figure HTML содержит `../../../source/API%20551%202016%20(R2024).pdf#page=`;
7. PNG-файлы являются реальными PNG после Git LFS checkout;
8. root debug/QA/temp/README-файлы не добавлены случайно.

## 12. Promotion: candidates -> main

После принятия Figure и merge acceptance PR в `candidates` перенос в `main` делать отдельным PR:

```text
base: main
head: candidates
```

До создания PR проверить:

1. `candidates` содержит только ожидаемые изменения;
2. `main` не содержит этих Figure-изменений;
3. `candidates` не содержит unrelated rules/scripts/debug edits;
4. changed files соответствуют ожидаемому набору.

После merge PR `candidates -> main` не сбрасывать `candidates` механически до проверки. Сначала сравнить:

```text
base: main
head: candidates
```

Безопасный случай для синхронизации:

```text
candidates ahead_by = 0
files diff = []
```

Если `candidates` содержит уникальные изменения (`ahead_by > 0`), остановиться: сначала нужен отдельный PR или решение пользователя.

## 13. Синхронизация candidates после promotion

Когда PR `candidates -> main` смёржен и `candidates` не содержит уникальных изменений, можно синхронизировать `candidates` до `main` и убрать временные ветки.

На уровне документации фиксируются обязательные safety-условия:

1. явно fetch-ить `main` и `candidates`, включая single-branch clone case;
2. проверять ahead/behind;
3. запрещать синхронизацию, если `candidates ahead_by > 0`;
4. синхронизировать `candidates` до `main` только после успешного promotion PR;
5. удалять только явно перечисленные временные ветки;
6. требовать явное подтверждение перед изменениями;
7. после cleanup приводить локальную рабочую папку к чистому `origin/candidates`.

Repo-скрипт для этой операции не фиксируется в `main`, пока не пройдёт отдельную проверку парсером `pwsh` и dry-run на локальном checkout. Для разовой операции допустим verified downloaded `.ps1`, запущенный через `api551_validate_and_run_ps1_pwsh.ps1`.

## 14. Удаление временных веток

Удалять можно только явно перечисленные temporary branches, например:

```text
accept-figNN-YYYYMMDD
rules/<short-topic>-YYYY-MM-DD
fix/<short-topic>-YYYY-MM-DD
stage4/figNN-<short-topic>-YYYY-MM-DD
```

Нельзя удалять:

```text
main
candidates
archive/*
evidence/*
branches explicitly preserved by the user
```

Массовое удаление по wildcard запрещено.

## 15. PR check workflow

Для локальной проверки PR использовать:

```text
scripts/api551_check_pr_pwsh.ps1
```

Минимум проверки:

1. состояние PR;
2. base branch;
3. head branch;
4. head SHA;
5. список changed files;
6. GitHub checks;
7. mergeability.

Не выполнять merge до known checks и явной команды пользователя.

## 16. Routine local sync

Для обычного обновления локального `candidates` использовать:

```text
scripts/api551_sync_candidates_pwsh.ps1
```

Успешный sync должен закончиться состоянием:

```text
working tree clean
current branch candidates
HEAD equals origin/candidates
Git LFS content pulled
```

## 17. Стандарт доставки `.ps1`

При передаче `.ps1` пользователю указывать:

1. ссылку на файл или repo path;
2. SHA-256;
3. статус проверки;
4. одну строку запуска под открытый `pwsh`;
5. меняет ли скрипт состояние или только проверяет.

Длинное тело скрипта в чат не вставлять.
