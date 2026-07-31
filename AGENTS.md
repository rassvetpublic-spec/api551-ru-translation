# API 551 Agent Instructions

This repository contains the working base for the API 551 Russian technical translation project.

## Required behavior

Before any Stage 4+ work, run the API551 source gate from `.codex/skills/api551-source-gate/SKILL.md`.

Do not work from memory, old chat context, old local caches, or archive files unless the active source gate explicitly allows it.

Use these repository skills and rules:

- always: `.codex/skills/api551-source-gate/SKILL.md`;
- Stage 5 production: `source/TZ_API551_PROJECT_STAGE5_FINAL_RU_PDF_CURRENT_2026-07-29.md`;
- only for an explicitly reopened Figure: `.codex/skills/api551-stage4-figure-operator/SKILL.md`, `.codex/skills/api551-figure-layout-qa/SKILL.md`, and `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`;
- local PowerShell workflow when relevant: `docs/rules/GITHUB_PROJECT_PWSH_LOCAL_PIPELINE_CURRENT_2026-07-01.md`.

Stage 4 Figure skills and acceptance rules must not replace or redirect the Stage 5 Gates 1–5 workflow.

## Current active source model

The active source model is the minimized `source/` model. The three legacy ZIP packages were moved to `archive/source-packages/` and must not be used as generation input unless a task explicitly asks for audit or traceability.

Active source files are expected in `source/` and are defined by `source/API551_SOURCE_MANIFEST_CURRENT.json` and `README.md`.

Stage 5 production is governed by `source/TZ_API551_PROJECT_STAGE5_FINAL_RU_PDF_CURRENT_2026-07-29.md`. Follow its Gates 1–5 and do not merge without explicit user approval.

## Write policy

- Do not modify `main` directly.
- The completed Stage 4 baseline is preserved in `main` at commit `fbc861e7a3ec22aae098d15420cbda452f5d2802`; no separate persistent Stage 4 baseline branch is used.
- Stage 5 starts from current `main` on `task/<topic>` and returns through PR into `main`.
- Explicitly reopened Stage 4 Figure work also starts from current `main` on a non-main branch.
- Use a dedicated branch and PR for rules/playbook updates.
- Never delete archive evidence.
- Never merge until explicitly authorized and all CI, review, schema, docs and source-gate checks pass.

## Stage 4 Figure pipeline (reopen-only)

1. source gate;
2. task branch from current `main`;
3. coherent Figure/status/catalog/index/CI update;
4. PR into `main`;
5. explicit merge after successful checks;
6. verify `main` before cleanup.

If binary/LFS assets cannot be committed safely, stop and return a verified overlay ZIP plus local instructions.

## Windows/local pwsh execution

For local Windows scripts, use `pwsh` / PowerShell 7 as the default engine. Do not use Windows PowerShell 5.1 (`powershell.exe`) unless the user explicitly requests it or a legacy script requires it.

When giving copy/paste commands to the user, prefer a single `pwsh -NoProfile -Command "..."` line with semicolon-separated commands. Do not rely on multi-line chat code blocks for operational commands when the user will paste them into a terminal.

For multi-step local work, provide a `.ps1` target script and run it through `scripts/api551_validate_and_run_ps1_pwsh.ps1` or a downloaded copy of the same wrapper.

Default local checkout path for operational examples is:

```text
C:\Irvis-UPG\GIT\API 551
```

Downloaded helper scripts and overlays should be discovered from the user's Downloads folder rather than hard-coded to a user profile path.

## Output policy

Do not paste large HTML, JSON, CSV, or generated file contents into chat. Return a ZIP or PR link plus a short summary and a short validation report.
