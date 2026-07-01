# API 551 — локальный runbook pwsh

Статус: CURRENT quick operational runbook.

Дата: 2026-07-01.

Основная оболочка: `pwsh` / PowerShell 7.

Путь локального репозитория по умолчанию:

```text
C:\GIT\API 551
```

## 1. Сначала открыть pwsh

В обычном терминале выполнить:

```powershell
pwsh -NoProfile
```

Дальше, если prompt уже выглядит как `PS C:\...>`, команды из этого runbook вставлять без внешнего `pwsh -Command`.

## 2. Правило копирования

Команда должна быть одной физической строкой.

Не копировать многострочные блоки в терминал: в chat UI порядок строк может нарушиться.

Если команда начинается с `$D=...`, её нужно вставлять уже в открытый `pwsh`.

## 3. Обновить локальный candidates

Команда для уже открытого `pwsh`:

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; & pwsh -NoProfile -ExecutionPolicy Bypass -File '.\scripts\api551_sync_candidates_pwsh.ps1' -AllowReset
```

Ручной эквивалент использовать только для диагностики; штатно применять repo-скрипт выше.

## 4. Запустить скачанный target-скрипт через проверяльщик

Проверка target-скрипта из Downloads:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Checker=(Get-ChildItem $D -Filter 'api551_validate_and_run_ps1_pwsh.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; $Target=(Get-ChildItem $D -Filter 'api551_*_pwsh.ps1' | Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; & pwsh -NoProfile -ExecutionPolicy Bypass -File $Checker -TargetScript $Target -ValidateOnly
```

Выполнение после успешной проверки:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Checker=(Get-ChildItem $D -Filter 'api551_validate_and_run_ps1_pwsh.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; $Target=(Get-ChildItem $D -Filter 'api551_*_pwsh.ps1' | Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; & pwsh -NoProfile -ExecutionPolicy Bypass -File $Checker -TargetScript $Target
```

## 5. Проверить overlay ZIP из Downloads

Для любого последнего overlay:

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; $D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Zip=(Get-ChildItem $D -Filter '*overlay*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; & pwsh -NoProfile -ExecutionPolicy Bypass -File '.\scripts\api551_overlay_sanity_pwsh.ps1' -ZipPath $Zip
```

Для конкретного Figure:

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; $D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Zip=(Get-ChildItem $D -Filter '*overlay*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; & pwsh -NoProfile -ExecutionPolicy Bypass -File '.\scripts\api551_overlay_sanity_pwsh.ps1' -ZipPath $Zip -FigureNo 51
```

## 6. Проверить PR

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; & pwsh -NoProfile -ExecutionPolicy Bypass -File '.\scripts\api551_check_pr_pwsh.ps1' -PrNumber 25
```

## 7. Promotion: candidates -> main

После merge acceptance PR в `candidates` создать PR в GitHub:

```text
base: main
head: candidates
```

До merge проверить, что changed files соответствуют только ожидаемому Figure-набору.

После merge PR `candidates -> main` сначала проверить сравнение:

```text
base: main
head: candidates
```

Безопасная синхронизация возможна только если:

```text
candidates ahead_by = 0
files diff = []
```

Если `candidates ahead_by > 0`, не синхронизировать `candidates`: сначала нужен отдельный PR или решение пользователя.

## 8. Синхронизировать candidates с main и убрать временные ветки

Использовать repo-скрипт:

```text
scripts/api551_cleanup_merged_branches_pwsh.ps1
```

Проверочный запуск из открытого `pwsh`:

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; & pwsh -NoProfile -ExecutionPolicy Bypass -File '.\scripts\api551_cleanup_merged_branches_pwsh.ps1' -TempBranches 'accept-fig51-20260701','rules/pwsh-local-pipeline-2026-07-01' -ValidateOnly
```

Рабочий запуск выполняется той же командой без `-ValidateOnly`. Скрипт запросит подтверждение `CLEANUP`.

Что делает скрипт:

1. явно fetch-ит `main` и `candidates`, включая single-branch clone case;
2. запрещает cleanup, если `candidates` содержит уникальные коммиты;
3. синхронизирует `candidates` до `main`, если это безопасно;
4. удаляет только ветки из `-TempBranches`;
5. обновляет локальную рабочую папку до чистого `origin/candidates`.

## 9. Проверить компактное состояние перед отправкой в ChatGPT

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; git branch --show-current; git log -1 --oneline; git status --short
```

Не вставлять в чат полный HTML, JSON, CSV, PNG/debug-вывод или длинные логи без запроса.
