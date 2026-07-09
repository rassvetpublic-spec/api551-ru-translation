# API 551 RU Translation

Working repository for the API 551 Russian technical translation project.

## Current Stage 4 entrypoint

For any new chat or local work, start here:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Primary bootstrap files:

1. `docs/project/API551_NEW_CHAT_START_RU.md`
2. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`
3. `source/API551_SOURCE_MANIFEST_CURRENT.json`
4. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`
5. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`
6. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`
7. `catalog.json`
8. `index.html`
9. `.github/workflows/structure-check.yml`
10. `.github/workflows/api551-tooling-check.yml`
11. `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md` when local LFS recovery or visual hydrated folders are relevant

Working branch: `candidates`.

Stable branch: `main`.

`main` must not be changed directly without explicit user permission.

## Repo-local toolkit

The default project tooling lives in:

```text
tools/api551/
```

Main command:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Useful commands:

```powershell
.\tools\api551\api551.ps1 status
.\tools\api551\api551.ps1 docs-sync-check
.\tools\api551\api551.ps1 rules-for -Figure 003
.\tools\api551\api551.ps1 figure-check -Figure 003
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure 003
.\tools\api551\api551.ps1 pr-check -Pr 37
```

The toolkit is documented in:

- `docs/project/API551_TOOLING_CURRENT.md`
- `docs/project/API551_SOURCE_GATE_CURRENT.md`
- `docs/project/API551_RULES_RESOLUTION_CURRENT.md`
- `docs/project/API551_FIGURE_LIFECYCLE_CURRENT.md`
- `docs/project/API551_PACKAGE_QA_CURRENT.md`
- `docs/project/API551_PR_WORKFLOW_CURRENT.md`

## Current structure

- `source/` - current active source package for Stage 4+ work.
- `workspace/figures/` - Stage 4 Figure objects and review/export artifacts.
- `docs/` - project documentation, workflow rules, and run logs.
- `tools/api551/` - repo-local source-gate, validation, package, rules, and PR tooling.
- `archive/` - preserved superseded files, archived source packages, extracted QA/reference evidence, and cleanup history.
- `scripts/` - legacy and fallback helper scripts.
- `.github/workflows/` - repository checks.
- `index.html` and `catalog.json` - published review export in repository root.

## Root script layout

Repository root must stay clean. The only active root script is:

- `api551_pull.ps1` - pull text review state through GitHub CLI, check PR/CI status, and remove obsolete local root scripts.

Helper scripts live under `scripts/`.

Do not add new active scripts to the repository root. New project tooling belongs under `tools/api551/`.

## Active source model

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

Archived packages and extracted reference indexes are evidence/audit inputs only. They are forbidden as generation input when rebuilding Figure objects.

## Git LFS policy

Do not run `git lfs pull` by default.

For normal clone/sync work, use no-smudge LFS. Fetch LFS assets only by exact include path when needed.

Keep the clean Git repo separate from visual hydrated assets:

```text
C:\GIT\API 551
C:\GIT\API551_HYDRATED_VIEW
```

Never commit hydrated PNG/PDF/ZIP files as ordinary Git modifications.

## Figure workflow

Default sequence:

```text
source-gate -> rules-for -> clean source crop -> source-text cleanup -> clean intermediate QA -> Russian rendering -> object build -> package-check -> review -> user decision
```

Do not use image generation, generative image editing, old translated PNGs, or stale overlay results as production source.

## PR workflow

Default PR sequence:

```text
source-gate -> clean branch from candidates -> change -> local checks -> PR into candidates -> CI/status check -> merge only after explicit user command -> verify candidates -> handoff
```

For accepted Figure candidates, update the synchronized state: Figure object files, `catalog.json`, `index.html`, `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`, and any hard-coded accepted status in workflows/docs.
