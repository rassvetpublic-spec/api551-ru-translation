# API 551 Agent Instructions

This repository contains the working base for the API 551 Russian technical translation project.

## Required behavior

Before any Stage 4 work, run the API551 source gate from `.codex/skills/api551-source-gate/SKILL.md`.

Do not work from memory, old chat context, old local caches, or archive files unless the active source gate explicitly allows it.

Use these repository skills and rules:

- `.codex/skills/api551-source-gate/SKILL.md`
- `.codex/skills/api551-stage4-figure-operator/SKILL.md`
- `.codex/skills/api551-figure-layout-qa/SKILL.md`
- `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`
- `docs/rules/GITHUB_PROJECT_PWSH_LOCAL_PIPELINE_CURRENT_2026-07-01.md`

## Current active source model

The active source model is the minimized `source/` model. The three legacy ZIP packages were moved to `archive/source-packages/` and must not be used as generation input unless a task explicitly asks for audit or traceability.

Active source files are expected in `source/` and are defined by `source/API551_SOURCE_MANIFEST_CURRENT.json` and `README.md`.

## Write policy

- Do not push Figure candidates directly to `main`.
- Do not push accepted Figure status changes directly to `main`.
- Use a branch for new work.
- Use an acceptance branch from `candidates` for accepted Figure integration, normally `accept-figNN-YYYYMMDD`.
- Do not use branch names under `candidates/...` while a real branch named `candidates` exists; use `figNN-*` or `accept-figNN-*` names instead.
- For rules/playbook updates, use a dedicated branch and PR.
- Never delete archive evidence.

## Acceptance pipeline

When the user explicitly writes that a Figure is accepted, such as `Рисунок 51 принят` or `51 принят`, follow `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`.

The required chain is:

1. source gate;
2. acceptance branch from `candidates`;
3. coherent Figure/status/catalog/index/CI update;
4. PR into `candidates`;
5. merge only after checks;
6. delete temporary acceptance branch after merge unless audit preservation is required;
7. later promote `candidates` into `main` by PR, not by direct push;
8. delete obsolete temporary candidate/acceptance branches after successful promotion.

If the current toolchain cannot safely commit binary/LFS Figure assets, stop and return a verified overlay ZIP plus local Git/LFS instructions instead of opening an incomplete PR.

## Windows/local pwsh execution

For local Windows scripts, use `pwsh` / PowerShell 7 as the default engine. Do not use Windows PowerShell 5.1 (`powershell.exe`) unless the user explicitly requests it or a legacy script requires it.

When giving copy/paste commands to the user, prefer a single `pwsh -NoProfile -Command "..."` line with semicolon-separated commands. Do not rely on multi-line chat code blocks for operational commands when the user will paste them into a terminal.

For multi-step local work, provide a `.ps1` target script and run it through `scripts/api551_validate_and_run_ps1_pwsh.ps1` or a downloaded copy of the same wrapper.

Default local checkout path for operational examples is:

```text
C:\GIT\API 551
```

Downloaded helper scripts and overlays should be discovered from the user's Downloads folder rather than hard-coded to a user profile path.

## Output policy

Do not paste large HTML, JSON, CSV, or generated file contents into chat. Return a ZIP or PR link plus a short summary and a short validation report.
