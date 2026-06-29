# API 551 checked PowerShell runner

`api551_run_checked_ps1.ps1` is the project-standard launcher for local `.ps1` scripts used in the API 551 translation workflow.

## Purpose

Use it to validate a target PowerShell script before execution.

It performs:

1. target `.ps1` existence and extension checks;
2. size and SHA-256 reporting;
3. optional `-ExpectedSha256` verification;
4. PowerShell parser validation before execution;
5. PSScriptAnalyzer check when available;
6. high-risk operation detection;
7. execution only when `-Run` is explicitly supplied;
8. `-AllowRisk` gate for high-risk targets.

## API 551 rule

Any local `.ps1` used for GitHub, branch, cleanup, file, packaging, or other state-changing API 551 work should be launched through this checked runner unless a stricter CI/GitHub Actions validation path is used.

## Safe sequence

For high-risk scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\api551_run_checked_ps1.ps1 -TargetPath .\path\target.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\api551_run_checked_ps1.ps1 -TargetPath .\path\target.ps1 -Run -AllowRisk -TargetArgs '-ValidateOnly'
powershell -ExecutionPolicy Bypass -File .\scripts\api551_run_checked_ps1.ps1 -TargetPath .\path\target.ps1 -Run -AllowRisk -TargetArgs '<real args>'
```

## Status rule

`STATIC ONLY` is not PowerShell parser validation. Do not describe a script as parser-checked unless this runner or another PowerShell runtime actually ran the parser.

Authoritative project rules:

- `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`
- `docs/rules/PS1_VALIDATION_GATE_CURRENT_2026-06-26.md`
