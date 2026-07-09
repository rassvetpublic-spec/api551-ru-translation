# API551 Project Quick Start

Status: CURRENT compact onboarding / source-gate / handoff helper.  
Project: API 551 RU Translation / Stage 4 Figure Objects.  
Scope: Stage 4+ Figure object production, rework, package QA, and PR workflow.

This file is a helper. It is not source truth and does not replace:

1. Project Instructions for the current ChatGPT project;
2. `docs/project/API551_NEW_CHAT_START_RU.md`;
3. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
4. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
5. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
6. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
7. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`;
8. `catalog.json`;
9. `index.html`;
10. Figure-specific accepted objects in `workspace/figures/`.

If this file conflicts with an ACTIVE/CURRENT project file, the ACTIVE/CURRENT file controls.

## 1. First command

Run from `C:\GIT\API 551` or any folder inside the repo:

```powershell
.\tools\api551\api551.ps1 source-gate
```

The repo-local toolkit lives in:

```text
tools/api551/
```

## 2. Current status source

Current machine-readable Stage 4 status:

```text
docs/project/API551_STAGE4_HANDOFF_CURRENT.json
```

The status must match `catalog.json` and `index.html`.

Current expected Stage 4 status after Figure 3 R03:

```text
accepted: 22/69
changed/review: 0
not_accepted: 47/69
```

## 3. Source hierarchy

Use this order before meaningful API 551 work:

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
    - `.github/workflows/api551-tooling-check.yml`;
    - `docs/rules/*CURRENT*`.
11. Tooling docs:
    - `docs/project/API551_TOOLING_CURRENT.md`;
    - `docs/project/API551_SOURCE_GATE_CURRENT.md`;
    - `docs/project/API551_RULES_RESOLUTION_CURRENT.md`;
    - `docs/project/API551_FIGURE_LIFECYCLE_CURRENT.md`;
    - `docs/project/API551_PACKAGE_QA_CURRENT.md`;
    - `docs/project/API551_PR_WORKFLOW_CURRENT.md`.
12. Local LFS/hydrated-view workflow when relevant:
    - `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`.
13. Current chat instruction for the current task.
14. Memory and old chats as reference only.
15. `archive/*` as reference/evidence only.

## 4. Active source model

Current source/rules are consolidated. Legacy ZIP packages are not active production inputs.

Active files in `source/`:

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

These archived packages are evidence/audit/reference only and are forbidden as generation input.

## 5. Source-gate before work

Before any task involving API 551 files, GitHub, figures, acceptance, workflow, or deliverables:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Then, for Figure work:

```powershell
.\tools\api551\api551.ps1 rules-for -Figure NNN
.\tools\api551\api551.ps1 figure-check -Figure NNN
```

For package work:

```powershell
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure NNN
```

If there is a conflict, stop and report:

```text
source -> role -> problem -> risk -> required decision
```

## 6. Hard prohibitions

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
- work from stale local files or `/mnt/data` as the only source;
- commit hydrated PNG/PDF/ZIP files as ordinary Git modifications.

## 7. GitHub workflow

Default chain:

```text
source-gate -> clean branch from candidates -> change -> local checks -> PR into candidates -> CI/status check -> merge only after explicit user command -> verify candidates -> handoff
```

Use:

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

for PR metadata and checks when GitHub CLI is available.

## 8. Git LFS and hydrated view

Do not run `git lfs pull` by default. Normal work should use no-smudge clone/sync and fetch LFS assets only by exact include path when needed.

Clean repo:

```text
C:\GIT\API 551
```

Hydrated visual view:

```text
C:\GIT\API551_HYDRATED_VIEW
```

Detailed rule: `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`.

## 9. New chat prompt

```text
Работаем в проекте API 551 RU Translation / Stage 4 Figure Objects.

Source of truth — GitHub repo:
rassvetpublic-spec/api551-ru-translation

Рабочая ветка: candidates.
main напрямую не менять.

Перед началом обязательно прочитай:
1. docs/project/API551_NEW_CHAT_START_RU.md
2. docs/project/API551_STAGE4_HANDOFF_CURRENT.json
3. source/API551_SOURCE_MANIFEST_CURRENT.json
4. source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md
5. source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md
6. source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md
7. catalog.json
8. index.html
9. tools/api551/api551.ps1

Сначала выполни source-gate, затем определи текущий Figure-статус и предложи следующий минимальный проверяемый шаг.
```
