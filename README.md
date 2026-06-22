# API 551 RU Translation

Working repository for the API 551 Russian technical translation project.

## Current structure

- `source/` - current active source package for the independent final rebuild.
- `workspace/figures/` - Stage 4 figure objects and review/export artifacts.
- `docs/` - project documentation and run logs.
- `archive/` - preserved superseded files, archived source packages, extracted QA/reference evidence, and cleanup history.
- `.github/workflows/` - repository checks.
- `index.html` and `catalog.json` - published review export in repository root.

## Root script layout

Active local workflow now uses GitHub CLI because local DNS can block normal `git fetch` to `github.com` while `api.github.com` remains reachable.

Active `gh` scripts in repository root:

1. `api551_00_gh_status.ps1` - check PR, branch, CI, root layout, and GitHub CLI connectivity.
2. `api551_01_gh_pull_text_state.ps1` - pull the text review state through `gh api`.
3. `api551_02_gh_upload_run_log.ps1` - upload only approved `.log` files from `docs/run-logs`.

Legacy Git scripts retained as fallback / historical workflow until a full replacement is approved:

1. `api551_01_pull_from_github.ps1`
2. `api551_02_sync_up.ps1`
3. `api551_03_apply_task.ps1`

Do not add new active helper scripts under `scripts/`. One-off migration helpers must be archived or deleted after their output is captured.

## Active source model

The active source set is intentionally small. Current rules and policies are consolidated. Legacy ZIP packages are not active production inputs.

Required current files in `source/`:

1. `API551_SOURCE_MANIFEST_CURRENT.json`
2. `API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`
3. `TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`
4. `api551_approved_label_master_v1.csv`
5. `TZ_API551_translation_project_RU.md`
6. `API 551 2016 (R2024).pdf`

Archived source packages in `archive/source-packages/`:

1. `API_551_STAGE2_REFERENCE_FILES_v1.zip`
2. `API_551_STAGE3_SOURCE_PACKAGE_v1.zip`
3. `api551_control_build_v1.zip`

The reference index in `archive/extracted-reference/` records useful ZIP members for QA/audit/traceability only. The selected members remain inside the archived ZIP packages and are forbidden as generation input for the final one-pass rebuild.

## Notes

- Do not delete archived files. They preserve project traceability.
- The PDF and archived ZIP files are large binary sources and are tracked through Git LFS.
- `index.html` and `catalog.json` remain in the repository root as the published review export.
