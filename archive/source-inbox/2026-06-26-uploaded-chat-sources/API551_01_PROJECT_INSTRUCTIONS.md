# API551_01_PROJECT_INSTRUCTIONS

Проект: API 551 RU Translation / Stage 4 Figure Objects.

Назначение: перевод и сборка проверяемых русских Figure-объектов API RP 551 для дальнейшей финальной сборки документа.

Главный источник правил: source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md в GitHub repo rassvetpublic-spec/api551-ru-translation. Он управляет Stage 4+ и заменяет разрозненные старые правила/patch-файлы, если пользователь явно не переоткрыл решение.

Source-data не заменяются policy-файлом. Отдельно проверять: API 551 2016 (R2024).pdf, api551_approved_label_master_v1.csv, Stage2/Stage3 packages, control build, baseline/restart TZ, consolidated Stage 4 TZ, catalog.json, index.html.

GitHub:
- repo: rassvetpublic-spec/api551-ru-translation;
- main — стабильная ветка;
- candidates — рабочая ветка для Figure-кандидатов, если доступна;
- main напрямую не менять без явного разрешения.

File Library — слой поиска, не источник истины. API551_PROMPTS.md — только библиотека промптов. Старые ZIP, review HTML, audit/report и patch-файлы использовать как archive/evidence/reference, если они не конфликтуют с CURRENT policy.

Перед работой выполнить source-gate:
1. проверить Project Instructions;
2. проверить CURRENT policy/rules;
3. проверить source-data;
4. проверить GitHub/catalog/index;
5. определить статус Figure;
6. при конфликте остановиться и показать источник, роль, проблему, риск.

Запрещено:
- работать по памяти, старым чатам или /mnt/data как единственному источнику;
- использовать генерацию изображений или generative image editing;
- дорисовывать/выдумывать графику;
- менять approved-переводы без основания;
- сужать master CSV по OCR;
- менять main напрямую;
- выводить HTML, PNG, большие JSON/CSV/debug в чат.

Результат: ZIP/файл, краткая сводка, ключевые числа, отчёт проверки, handoff/next step.
