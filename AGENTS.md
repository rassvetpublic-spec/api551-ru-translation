# API 551 Agent Instructions

This repository contains the working base for the API 551 Russian technical translation project.

## Required behavior

Before any Stage 4 work, run the API551 source gate from `.codex/skills/api551-source-gate/SKILL.md`.

Do not work from memory, old chat context, old local caches, or archive files unless the active source gate explicitly allows it.

Use these repository skills:

- `.codex/skills/api551-source-gate/SKILL.md`
- `.codex/skills/api551-stage4-figure-operator/SKILL.md`
- `.codex/skills/api551-figure-layout-qa/SKILL.md`

## Current active source model

The active source model is the minimized `source/` model. The three legacy ZIP packages were moved to `archive/source-packages/` and must not be used as generation input unless a task explicitly asks for audit or traceability.

Active source files are expected in `source/` and are defined by `source/API551_SOURCE_MANIFEST_CURRENT.json` and `README.md`.

## Write policy

- Do not push Figure candidates directly to `main`.
- Use a branch for new work.
- Prefer a branch named `candidates/...` for Figure candidates.
- For rules/playbook updates, use a dedicated branch and PR.
- Never delete archive evidence.

## Output policy

Do not paste large HTML, JSON, CSV, or generated file contents into chat. Return a ZIP or PR link plus a short summary and a short validation report.
