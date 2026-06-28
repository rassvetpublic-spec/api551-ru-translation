# API551 Project Quick Start

Status: CURRENT quick-start / onboarding / handoff helper.  
Project: API 551 RU Translation / Stage 4 Figure Objects.  
Scope: compact source-gate and new-chat handoff for API 551 work.

This file is not a source of truth and does not replace:

1. Project Instructions for the current ChatGPT project;
2. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
3. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
4. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
5. Figure-specific accepted objects, `catalog.json`, or `index.html`.

If this file conflicts with an ACTIVE/CURRENT project file, the ACTIVE/CURRENT file controls.

## 1. Purpose

The goal of Stage 4 is to produce verified Russian composite Figure objects for final API 551 document assembly.

This quick-start preserves the useful compact onboarding material from earlier project source notes while keeping the current repository source hierarchy intact.

## 2. Current source hierarchy

Use this order before any meaningful API 551 work:

1. System / safety / developer instructions.
2. API 551 Project Instructions.
3. `source/API551_SOURCE_MANIFEST_CURRENT.json`.
4. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`.
5. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`.
6. Mandatory source data in `source/`:
   - `API 551 2016 (R2024).pdf`;
   - `api551_approved_label_master_v1.csv`;
   - `TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`;
   - `TZ_API551_translation_project_RU.md` as baseline/restart/archive.
7. GitHub state:
   - `catalog.json`;
   - `index.html`;
   - `workspace/figures/`;
   - `.github/workflows/structure-check.yml`;
   - `docs/rules/*CURRENT*`.
8. Current chat instructions for the current task.
9. `RULES_HUB.md` and active `rassvet-rules-hub` files when rules-hub is relevant.
10. Memory and old chats as reference only.
11. `archive/*` as reference/evidence only.

## 3. Active source model

The active source set is intentionally small.

Current rules and policies are consolidated. Legacy ZIP packages are not active production inputs. The universal Figure cleanup/placement addendum is an active Stage 4+ source file and supplements the consolidated policy/rules source.

Archived ZIP packages remain useful for QA, audit, and traceability, but are forbidden as generation input for the final one-pass rebuild.

## 4. Source-gate before work

Before any task involving API 551 files, GitHub, figures, acceptance, workflow, or deliverables:

1. Check Project Instructions.
2. Check `source/API551_SOURCE_MANIFEST_CURRENT.json`.
3. Check the CURRENT consolidated policy/rules file.
4. Check the CURRENT universal Figure cleanup/placement addendum.
5. Check mandatory source data availability and role.
6. Check GitHub `catalog.json`, `index.html`, and `workspace/figures/` when Figure status matters.
7. Determine the Figure status when working on a Figure.
8. Do not use memory, old chats, `API551_PROMPTS.md`, File Library, or `/mnt/data` as the only source of truth.
9. If there is a conflict, stop and report:

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

Default sequence:

```text
source gate -> clean branch from main -> change -> diff check -> PR -> CI/status check -> merge only after explicit user command -> verify main -> handoff
```

For accepted Stage 4 Figure objects, use `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md`. That file has priority over the general GitHub workflow.

For local GitHub edits and fallback scripts, use `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`.

## 7. Figure-object workflow reminder

For each Figure task:

1. Verify the Figure number and status.
2. Use the original PDF as visual truth.
3. Use the approved label master CSV as label/translation truth.
4. Use accepted Figure object status when the Figure is already accepted.
5. Clean source labels programmatically without damaging protected graphics.
6. Place Russian replacement text according to CURRENT policy and universal addendum.
7. Verify PNG/HTML/JSON/catalog/index consistency.
8. Produce a ZIP/file, short summary, key counts, verification report, and next step.

## 8. Archive and evidence policy

Archive/evidence/reference materials include:

- old v1/v3/v5 rules;
- old Stage 4 patch files;
- review HTML;
- audit/report files;
- cumulative ZIPs;
- old handoff/source-pack files;
- uploaded chat source notes;
- old GitHub skill ZIPs.

These can be used for audit, comparison, traceability, and to recover useful wording. They do not override CURRENT policy/rules or the active source manifest.

## 9. API551_PROMPTS.md

`API551_PROMPTS.md` is a prompt library only. It is not source truth.

Use it only after checking Project Instructions, the active manifest, CURRENT policy/rules, CURRENT addenda, and source data.

## 10. Rules-hub

The project is connected through `RULES_HUB.md`.

When relevant, use active `rassvet-rules-hub` files from:

- `RULES_INDEX.md`;
- `core/`;
- `github/`;
- `skills/`;
- `prompts/`.

Do not infer rules-hub content from filenames alone. If a linked rules-hub file is not actually accessible, report that it is referenced but unavailable.

## 11. New chat handoff prompt

Use this when starting a new API 551 chat:

```text
Работай в проекте API 551 RU Translation / Stage 4 Figure Objects.

Сначала выполни source-gate:
1. Project Instructions проекта.
2. source/API551_SOURCE_MANIFEST_CURRENT.json.
3. source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md.
4. source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md.
5. Source-data: API 551 2016 (R2024).pdf, api551_approved_label_master_v1.csv, consolidated Stage 4 TZ, baseline/restart TZ.
6. GitHub repo rassvetpublic-spec/api551-ru-translation: catalog.json, index.html, workspace/figures/, docs/rules/.
7. RULES_HUB.md and active rassvet-rules-hub files when relevant.

Не работай по памяти, старым чатам, API551_PROMPTS.md, File Library или /mnt/data как по источнику истины.

Главная цель Stage 4: получить проверенные русские составные Figure-объекты для финальной сборки API 551 RU.

Правила:
- main напрямую не менять без явного разрешения;
- Figure-кандидаты делать через candidates/workflow, если это применимо;
- не использовать генерацию изображений или generative image editing;
- не дорисовывать и не выдумывать графику;
- OCR использовать только как контроль, не как замену approved master CSV;
- archived ZIP/source-packages использовать только как QA/evidence/reference, не как production generation input;
- при конфликте CURRENT policy/rules и active manifest выше archive/patch/review-файлов.

Формат результата:
- один основной ZIP/файл;
- краткая сводка;
- ключевые числа;
- краткий отчёт проверки;
- next step.

Если источник недоступен или конфликтует, остановись и сообщи:
source -> role -> problem -> risk -> required decision.
```

## 12. What this file intentionally preserves

This file preserves the compact practical value of earlier project notes:

- a single readable source map;
- a short source-gate checklist;
- compact project operating rules;
- a ready new-chat handoff prompt;
- a reminder that prompt libraries, old chats, File Library, and `/mnt/data` are not source truth;
- a reminder that archive materials are evidence/reference, not active rules.

It intentionally does not restore old files as active source.