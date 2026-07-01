# API 551 — локальный runbook pwsh

Статус: CURRENT quick operational runbook.

Дата: 2026-07-01.

Основной источник правил: `docs/rules/GITHUB_PROJECT_PWSH_LOCAL_PIPELINE_CURRENT_2026-07-01.md`.

## Коротко

1. Работать через PowerShell 7 (`pwsh`).
2. Если prompt уже `PS C:\...>`, не вкладывать команду в дополнительный `pwsh -Command`.
3. Команды для вставки давать одной физической строкой.
4. Скачанные `.ps1` запускать через `api551_validate_and_run_ps1_pwsh.ps1`.
5. После promotion `candidates -> main` выполнять cleanup только после проверки, что `candidates` не содержит уникальных коммитов относительно `main`.

## Компактный статус для отправки в чат

```powershell
Set-Location -LiteralPath 'C:\GIT\API 551'; git branch --show-current; git log -1 --oneline; git status --short
```
