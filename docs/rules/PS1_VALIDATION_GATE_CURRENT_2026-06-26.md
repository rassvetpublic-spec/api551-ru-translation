# API 551 PS1 Validation Gate

Status: CURRENT local PowerShell validation rule.

This focused file intentionally points to the project GitHub pipeline rule for the full current requirements.

Authoritative rule location:

`docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`

Summary:

- every delivered `.ps1` must include an explicit validation status;
- parser/analyzer validation must not be claimed unless actually run;
- local validate-and-run wrapper is the fast path;
- GitHub Actions is the stricter path for high-risk scripts.
