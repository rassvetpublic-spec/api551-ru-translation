# 2026-06-22 root and scripts cleanup

## Context

Local machine can reach `api.github.com` through GitHub CLI, but normal `git fetch` to `github.com` can fail because DNS resolves `github.com` to `0.0.0.0` / `::`.

## Active root workflow

Active root helpers for the current workflow:

- `api551_00_gh_status.ps1` - GitHub CLI status check for PR, branch and CI.
- `api551_01_gh_pull_text_state.ps1` - text-state pull through `gh api`.
- `api551_02_gh_upload_run_log.ps1` - limited upload of `.log` files from `docs/run-logs` only.

## Fallback root scripts

The previous Git-based root scripts are retained as fallback until the GitHub CLI workflow fully replaces them:

- `api551_01_pull_from_github.ps1`
- `api551_02_sync_up.ps1`
- `api551_03_apply_task.ps1`

They are not the active path while local DNS blocks `github.com`.

## `scripts/` cleanup

`scripts/api551_migrate_relative_paths.ps1` was a one-off migration helper for portable relative review links.

Evidence that it already ran and is no longer an active helper:

- output run log: `docs/run-logs/2026-06-19_112458-relative-path-migration.log`
- CI has a permanent check named `Check portable relative review links`
- the root workflow now uses `gh` helpers instead of ad hoc scripts under `scripts/`

The deleted file is still recoverable from Git history by blob SHA:

- path: `scripts/api551_migrate_relative_paths.ps1`
- blob SHA: `57bdeecaaa2638b34538f0b12f70204ce7508b37`

Decision: remove active `scripts/` copy from the branch. Do not use `scripts/` for new active helpers.
