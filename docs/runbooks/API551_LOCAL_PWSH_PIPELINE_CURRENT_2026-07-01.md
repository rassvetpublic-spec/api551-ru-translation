# API 551 Local pwsh Runbook

Status: CURRENT quick operational runbook.

Date: 2026-07-01.

Shell: `pwsh` / PowerShell 7.

Default local repository path:

```text
C:\\GIT\\API 551
```

## 1. Start pwsh

```powershell
pwsh -NoProfile
```

## 2. Sync local candidates

Single-line command:

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; git fetch origin --prune; git checkout candidates; git reset --hard origin/candidates; git clean -fdx; git lfs pull; git log -1 --oneline; git status"
```

Equivalent repo script:

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; pwsh -NoProfile -ExecutionPolicy Bypass -File '.\\scripts\\api551_sync_candidates_pwsh.ps1' -AllowReset"
```

## 3. Run a downloaded task script through the validator

Validate only:

```powershell
pwsh -NoProfile -Command "$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Checker=(Get-ChildItem $D -Filter 'api551_validate_and_run_ps1_pwsh.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; $Target=(Get-ChildItem $D -Filter 'api551_*_pwsh.ps1' | Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; pwsh -NoProfile -ExecutionPolicy Bypass -File $Checker -TargetScript $Target -ValidateOnly"
```

Execute after validation:

```powershell
pwsh -NoProfile -Command "$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Checker=(Get-ChildItem $D -Filter 'api551_validate_and_run_ps1_pwsh.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; $Target=(Get-ChildItem $D -Filter 'api551_*_pwsh.ps1' | Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; pwsh -NoProfile -ExecutionPolicy Bypass -File $Checker -TargetScript $Target"
```

## 4. Validate an overlay ZIP from Downloads

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; $D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Zip=(Get-ChildItem $D -Filter '*overlay*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; pwsh -NoProfile -ExecutionPolicy Bypass -File '.\\scripts\\api551_overlay_sanity_pwsh.ps1' -ZipPath $Zip"
```

For a specific Figure:

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; $D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; $Zip=(Get-ChildItem $D -Filter '*overlay*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName; pwsh -NoProfile -ExecutionPolicy Bypass -File '.\\scripts\\api551_overlay_sanity_pwsh.ps1' -ZipPath $Zip -FigureNo 51"
```

## 5. Check a PR

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; pwsh -NoProfile -ExecutionPolicy Bypass -File '.\\scripts\\api551_check_pr_pwsh.ps1' -PrNumber 23"
```

## 6. Before sending terminal output back to ChatGPT

Prefer compact output:

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; git branch --show-current; git log -1 --oneline; git status --short"
```

Avoid pasting full HTML, JSON, CSV, or binary/debug dumps into chat.
