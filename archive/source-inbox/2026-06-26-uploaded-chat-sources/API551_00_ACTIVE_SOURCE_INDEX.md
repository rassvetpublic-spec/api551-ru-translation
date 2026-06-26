# API551_00_ACTIVE_SOURCE_INDEX

Status: ACTIVE  
Project: API 551 RU Translation / Stage 4 Figure Objects  
Purpose: единая карта источников проекта.

## 1. Главный источник правил

- `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`

Роль: CURRENT active consolidated policy/rules source.  
Статус: ACTIVE / CURRENT.  
Правило: управляет Stage 4+; старые rules/patch/archive не управляют при конфликте, если пользователь явно не переоткрыл решение.

## 2. Source-data, которые остаются отдельной истиной

- `API 551 2016 (R2024).pdf` — оригинальный PDF и визуальный эталон.
- `api551_approved_label_master_v1.csv` — approved master-реестр надписей.
- `RULES_API551_STAGE2_IMAGE_LABEL_REPLACEMENT_STRATEGIES_v1.md` — стратегии замены надписей.
- `API_551_STAGE2_REFERENCE_FILES_v1.zip` — reference package.
- `API_551_STAGE3_SOURCE_PACKAGE_v1.zip` — рабочая база Stage 3/Stage 4, если не заменена новым approved-пакетом.
- `api551_control_build_v1.zip` — контрольная точка.
- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md` — Stage 4 TZ, если не заменено consolidated source.
- `catalog.json` — статусы/состав пакета.
- `index.html` — человекочитаемый обзор пакета.

## 3. GitHub

- repo: `rassvetpublic-spec/api551-ru-translation`
- stable branch: `main`
- working branch: `candidates`, если доступна
- production paths: `source/`, `archive/source-packages/`, `workspace/figures/`, `catalog.json`, `index.html`, `.github/workflows/structure-check.yml`

## 4. Библиотека промптов

- `API551_PROMPTS.md`

Роль: библиотека рабочих промптов.  
Статус: PROMPTS ONLY.  
Правило: не источник истины; использовать только после сверки с CURRENT policy и source-data.

## 5. Archive / evidence / reference

- старые v1/v3/v5 rules;
- Stage4 patch-файлы 2026-06-16/17;
- review HTML;
- audit/report;
- cumulative ZIP;
- старые handoff/source-pack файлы.

Роль: archive/evidence/reference.  
Статус: ARCHIVE.  
Правило: не использовать как active, если конфликтуют с CURRENT policy/rules.

## 6. Source-gate

Перед любой задачей:
1. проверить Project Instructions;
2. проверить этот индекс;
3. проверить CURRENT policy/rules;
4. проверить source-data;
5. проверить GitHub/catalog/index;
6. не использовать память, старые чаты, PROMPTS.md или /mnt/data как единственную истину;
7. при конфликте остановиться и показать источник, роль, проблему, риск.
