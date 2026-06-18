# API 551 RU Translation

Working repository for the API 551 Russian technical translation project.

## Current structure

- `source/` - current active source package.
- `workspace/figures/` - Stage 4 figure objects and review/export artifacts.
- `docs/` - project documentation.
- `archive/` - preserved superseded files and cleanup history.
- `.github/workflows/` - repository checks.
- `index.html` and `catalog.json` - published review export in repository root.

## Active source model

The active source set is intentionally small. Current rules and policies are consolidated.

Required current files in `source/`:

1. `API551_SOURCE_MANIFEST_CURRENT.json`
2. `API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`
3. `TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`
4. `api551_approved_label_master_v1.csv`
5. `api551_control_build_v1.zip`
6. `API_551_STAGE3_SOURCE_PACKAGE_v1.zip`
7. `API_551_STAGE2_REFERENCE_FILES_v1.zip`
8. `TZ_API551_translation_project_RU.md`
9. `API 551 2016 (R2024).pdf`

## Notes

- Do not delete archived files. They preserve project traceability.
- The PDF and ZIP files are large binary sources. Git LFS is recommended.
- `index.html` and `catalog.json` remain in the repository root as the published review export.