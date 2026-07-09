# API 551 RU Translation

Working repository for the API 551 Russian technical translation project.

## New chat bootstrap / Новый чат

Для продолжения Stage 4 в новом чате сначала читать:

1. `docs/project/API551_NEW_CHAT_START_RU.md`
2. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`
3. `source/API551_SOURCE_MANIFEST_CURRENT.json`
4. `catalog.json`
5. `index.html`
6. `.github/workflows/structure-check.yml`
7. `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md` when local LFS recovery or visual hydrated folders are relevant

Рабочая ветка: `candidates`.

`main` напрямую не менять. Не выполнять `git lfs pull` по умолчанию. CI использует LFS-tolerant `Structure check` с `lfs: false` и pointer checks.

Local LFS rule: keep `C:\GIT\API 551` as a clean Git repo for commits/PRs, and keep real PNG/PDF/ZIP files in `C:\GIT\API551_HYDRATED_VIEW` or dated local backups. Never commit hydrated binary files as ordinary Git modifications.

При принятии любого Figure-кандидата обязательно обновлять не только Figure object files, `catalog.json` и `index.html`, но и `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`; при изменении правил, entrypoint, workflow или source-gate также обновлять `docs/project/API551_NEW_CHAT_START_RU.md`, `README.md` и `docs/API551_PROJECT_QUICK_START_CURRENT.md`.

## Current structure

- `source/` - current active source package for the independent final rebuild.
- `workspace/figures/` - Stage 4 figure objects and review/export artifacts.
- `docs/` - project documentation, workflow rules, and run logs.
- `archive/` - preserved superseded files, archived source packages, extracted QA/reference evidence, and cleanup history.
- `scripts/` - non-root helper scripts and local workflow tools.
- `.github/workflows/` - repository checks.
- `index.html` and `catalog.json` - published review export in repository root.

## Root script layout

Repository root must stay clean. The only active root script is:

- `api551_pull.ps1` - pull text review state through GitHub CLI, check PR/CI status, and remove obsolete local root scripts.

Helper scripts live under `scripts/`:

- `scripts/api551_gh_upload_run_log.ps1` - upload only approved `.log` files from `docs/run-logs`.
- `scripts/api551_git_pull_from_github.ps1` - legacy Git pull fallback.
- `scripts/api551_git_sync_up.ps1` - legacy Git sync fallback.
- `scripts/api551_git_apply_task.ps1` - legacy Git task fallback.
- `scripts/api551_validate_and_run_ps1_pwsh.ps1` - persistent PowerShell 7 validator/runner for downloaded local task scripts.
- `scripts/api551_sync_candidates_pwsh.ps1` - safe local sync helper for local checkout and `origin/candidates`.
- `scripts/api551_check_pr_pwsh.ps1` - GitHub CLI helper for PR status, changed files, and checks.
- `scripts/api551_overlay_sanity_pwsh.ps1` - local overlay ZIP structure validator for Figure delivery packages.

Do not add new active scripts to the repository root. If a root helper is needed, fold it into `api551_pull.ps1` or place it under `scripts/`.

## Active source model

The active source set is intentionally small. Current rules and policies are consolidated. Legacy ZIP packages are not active production inputs. The universal Figure label cleanup and placement addendum is an active Stage 4+ source file that supplements the consolidated policy/rules source.

Required current files in `source/`:

1. `API551_SOURCE_MANIFEST_CURRENT.json`
2. `API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`
3. `API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`
4. `API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`
5. `TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`
6. `api551_approved_label_master_v1.csv`
7. `TZ_API551_translation_project_RU.md`
8. `API 551 2016 (R2024).pdf`

Archived source packages in `archive/source-packages/`:

1. `API_551_STAGE2_REFERENCE_FILES_v1.zip`
2. `API_551_STAGE3_SOURCE_PACKAGE_v1.zip`
3. `api551_control_build_v1.zip`

The reference index in `archive/extracted-reference/` records useful ZIP members for QA/audit/traceability only. The selected members remain inside the archived ZIP packages and are forbidden as generation input for the final one-pass rebuild.

## Workflow rules

- `docs/project/API551_NEW_CHAT_START_RU.md` is the primary Russian bootstrap for starting or continuing Stage 4 in a new chat.
- `docs/project/API551_STAGE4_HANDOFF_CURRENT.json` is the machine-readable current Stage 4 handoff/status file and must be updated when a Figure is accepted.
- `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md` defines local no-smudge/LFS-pointer/hydrated-view handling for real PNG/PDF/ZIP recovery and visual review.
- `docs/API551_PROJECT_QUICK_START_CURRENT.md` is a compact current onboarding/source-gate/handoff helper. It preserves useful earlier project notes but is not a source of truth and does not replace the manifest or CURRENT policy/rules.
- `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md` defines the mandatory chain for user-accepted Figures: source gate, acceptance branch from `candidates`, PR into `candidates`, later PR from `candidates` into `main`, and cleanup of temporary branches.
- `docs/rules/GITHUB_PROJECT_PWSH_LOCAL_PIPELINE_CURRENT_2026-07-01.md` defines the current local Windows/PowerShell 7 operational pipeline for scripts, single-line commands, overlays, PR checks, and local repo sync.
