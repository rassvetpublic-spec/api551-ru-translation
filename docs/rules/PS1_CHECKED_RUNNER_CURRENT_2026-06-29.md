# PS1_CHECKED_RUNNER_CURRENT_2026-06-29

Status: CURRENT project rule for local PowerShell script validation and execution in API 551.

## Rule

The project-standard local PowerShell launcher is:

```text
scripts/api551_run_checked_ps1.ps1
```

Any local `.ps1` used for GitHub, branch cleanup, file operations, packaging, destructive filesystem operations, or other state-changing API 551 work should be launched through this checked runner unless a stricter CI/GitHub Actions validation path is used.

## Required behavior

The runner must:

1. accept `-TargetPattern` or `-TargetPath`;
2. print path, size, and SHA-256 for the target script;
3. optionally enforce `-ExpectedSha256`;
4. run PowerShell parser validation before execution;
5. run PSScriptAnalyzer when available;
6. refuse to execute without `-Run`;
7. detect high-risk operations;
8. require `-AllowRisk` for high-risk targets;
9. pass target arguments through `-TargetArgs`.

## High-risk sequence

For high-risk target scripts:

```text
checked runner without -Run
checked runner -Run -AllowRisk -TargetArgs '-ValidateOnly' or '-DryRun'
review planned actions
checked runner -Run -AllowRisk -TargetArgs '<real args>'
```

## Validation status rule

Allowed statuses remain:

```text
PS1 validation: PASSED by PowerShell parser + PSScriptAnalyzer
PS1 validation: PASSED by PowerShell parser; PSScriptAnalyzer unavailable
PS1 validation: STATIC ONLY, no PowerShell runtime available
PS1 validation: FAILED — file not delivered
```

`STATIC ONLY` is not parser validation and must not be described as full validation.

## Priority

This file complements:

- `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`
- `docs/rules/PS1_VALIDATION_GATE_CURRENT_2026-06-26.md`

If there is a conflict, the stricter rule controls unless the user explicitly reopens the decision.
