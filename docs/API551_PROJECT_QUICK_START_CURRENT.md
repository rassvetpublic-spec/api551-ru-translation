# API551 Project Quick Start

Status: CURRENT quick-start / onboarding / handoff helper.  
Project: API 551 RU Translation / Stage 4 Figure Objects.  
Scope: compact source-gate and new-chat handoff for API 551 work.

> Для нового чата Stage 4 сначала используйте:
> `docs/project/API551_NEW_CHAT_START_RU.md`
>
> Текущий машинно-читаемый статус Stage 4:
> `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`

This file is a compact helper. It is not a source of truth and does not replace:

1. Project Instructions for the current ChatGPT project;
2. `docs/project/API551_NEW_CHAT_START_RU.md`;
3. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
4. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
5. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
6. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
7. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`;
8. Figure-specific accepted objects, `catalog.json`, or `index.html`.

If this file conflicts with an ACTIVE/CURRENT project file, the ACTIVE/CURRENT file controls.

## 1. Purpose

The goal of Stage 4 is to produce verified Russian composite Figure objects for final API 551 document assembly.

This quick-start preserves compact onboarding material from earlier project notes, while the primary new-chat route is now `docs/project/API551_NEW_CHAT_START_RU.md`.

## 2. Current source hierarchy

Use this order before any meaningful API 551 work:

1. System / safety / developer instructions.
2. API 551 Project Instructions.
3. `docs/project/API551_NEW_CHAT_START_RU.md`.
4. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`.
5. `source/API551_SOURCE_MANIFEST_CURRENT.json`.
6. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`.
7. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`.
8. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`.
9. Mandatory source data in `source/`:
   - `API 551 2016 (R2024).pdf`;
   - `api551_approved_label_master_v1.csv`;
   - `TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`;
   - `TZ_API551_translation_project_RU.md` as baseline/restart/archive.
10. GitHub state:
    - `catalog.json`;
    - `index.html`;
    - `workspace/figures/`;
    - `.github/workflows/structure-check.yml`;
    - `docs/rules/*CURRENT*`.
11. Current chat instructions for the current task.
12. Memory and old chats as reference only.
13. `archive/*` as reference/evidence only.

## 3. Active source model

The active source set is intentionally small.

Current rules and policies are consolidated. Legacy ZIP packages are not active production inputs. The universal Figure cleanup/placement addendum and rework/source/frame-fit addendum are active Stage 4+ source files and supplement the consolidated policy/rules source.

Archived ZIP packages remain useful for QA, audit, and traceability, but are forbidden as generation input for the final one-pass rebuild.

## 4. Source-gate before work

Before any task involving API 551 files, GitHub, figures, acceptance, workflow, or deliverables:

1. Check Project Instructions.
2. Check `docs/project/API551_NEW_CHAT_START_RU.md`.
3. Check `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`.
4. Check `source/API551_SOURCE_MANIFEST_CURRENT.json`.
5. Check the CURRENT consolidated policy/rules file.
6. Check the CURRENT universal Figure cleanup/placement addendum.
7. Check the CURRENT rework/source/frame-fit addendum.
8. Check mandatory source data availability and role.
9. Check GitHub `catalog.json`, `index.html`, and `workspace/figures/` when Figure status matters.
10. Determine the Figure status when working on a Figure.
11. Do not use memory, old chats, `API551_PROMPTS.md`, File Library, or `/mnt/data` as the only source of truth.
12. If there is a conflict, stop and report:

```text
source -> role -> problem -> risk -> required decision
```

## 5. Hard prohibitions

Do not:

- use image generation or generative image editing;
- redraw or invent graphics;
- change approved translations without a traceable reason;
- narrow the approved master CSV based on OCR;
- treat OCR as source truth;
- treat archived ZIP packages as production generation inputs;
- change `main` directly without explicit user permission;
- merge a PR without explicit user command;
- output large HTML, PNG, JSON, CSV, or debug dumps into chat;
- work from stale local files or `/mnt/data` as the only source.

## 6. GitHub workflow

Default Stage 4 sequence:

```text
source gate -> clean branch from candidates -> change -> diff check -> PR into candidates -> CI/status check -> merge only after explicit user command -> verify candidates -> handoff
```

For accepted Stage 4 Figure objects, use `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`. That file has priority over the general GitHub workflow.

For local GitHub edits and fallback scripts, use `docs/rules/GITHUB_PROJECT_PWSH_LOCAL_PIPELINE_CURRENT_2026-07-01.md`.

## 7. Figure-object workflow reminder

For each Figure task:

1. Verify the Figure number and status.
2. Use the original PDF as visual truth.
3. Use the approved label master CSV as label/translation truth.
4. Use accepted Figure object status when the Figure is already accepted.
5. Clean source labels programmatically without damaging protected graphics.
6. Place Russian replacement text according to CURRENT policy and active addenda.
7. Verify PNG/HTML/JSON/catalog/index consistency.
8. Produce a ZIP/file, short summary, key counts, verification report, and next step.

## 8. Figure acceptance sync rule

When a Figure candidate is accepted, the acceptance PR must update the synchronized project state, not only the Figure object files.

Required on every acceptance:

1. Figure object files under `workspace/figures/<NNN>/`;
2. `catalog.json`;
3. `index.html`;
4. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
5. `.github/workflows/structure-check.yml` if accepted set/stats are hard-coded there.

Required when policy, entrypoint, workflow, source-gate, or current-status wording changes:

1. `docs/project/API551_NEW_CHAT_START_RU.md`;
2. `README.md`;
3. `docs/API551_PROJECT_QUICK_START_CURRENT.md`.

A Figure acceptance PR is incomplete if catalog/index accepted counts differ from the handoff/bootstrap status.

## 9. Git LFS reminder

Do not run `git lfs pull` by default. Normal work should use no-smudge clone/sync and fetch LFS assets only by exact include path when needed.

`Structure check` is expected to run with `lfs: false` and validate LFS pointer state for binary assets.

## 10. Archive and evidence policy

Archive/evidence/reference materials include old rules, old Stage 4 patch files, review HTML, audit/report files, cumulative ZIPs, old handoff/source-pack files, uploaded chat source notes, and old GitHub skill ZIPs.

These can be used for audit, comparison, traceability, and to recover useful wording. They do not override CURRENT policy/rules or the active source manifest.

## 11. API551_PROMPTS.md

`API551_PROMPTS.md` is a prompt library only. It is not source truth.

Use it only after checking Project Instructions, the active manifest, CURRENT policy/rules, CURRENT addenda, and source data.

## 12. New chat handoff prompt

Use this when starting a new API 551 chat:

```text
Работаем в проекте API 551 RU Translation / Stage 4 Figure Objects.

Source of truth — GitHub repo:
rassvetpublic-spec/api551-ru-translation

Перед началом обязательно прочитай:
1. docs/project/API551_NEW_CHAT_START_RU.md
2. docs/project/API551_STAGE4_HANDOFF_CURRENT.json
3. source/API551_SOURCE_MANIFEST_CURRENT.json
4. source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md
5. source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md
6. source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md
7. catalog.json
8. index.html
9. .github/workflows/structure-check.yml

Рабочая ветка: candidates.
main напрямую не менять.
Git LFS assets не скачивать по умолчанию.

Сначала выполни source-gate, затем определи текущий Figure-статус и предложи следующий минимальный проверяемый шаг.
```

This file intentionally does not restore old files as active source.
