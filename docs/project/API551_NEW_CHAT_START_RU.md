# API 551 — старт нового чата: Stage 4 завершён, Stage 5 открыт

Статус: CURRENT bootstrap для завершённого Stage 4 и Stage 5 по утверждённому CURRENT-ТЗ.  
Проект: API 551 RU Translation.  
Язык работы: русский.

Этот файл нужен, чтобы новый чат начал работу без восстановления контекста по старой переписке. Если этот файл конфликтует с `source/API551_SOURCE_MANIFEST_CURRENT.json`, CURRENT policy/rules или системными инструкциями проекта, более высокий источник управляет.

## 1. Первый вход

Главный вход в проектный инструментарий:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Инструментарий хранится в repo:

```text
tools/api551/
```

Stage 4 завершён (`69/69`). Stage 5 выполнять только по `source/TZ_API551_PROJECT_STAGE5_FINAL_RU_PDF_CURRENT_2026-07-29.md` и его Gate 1–5. Новые project tools должны жить в `/tools/api551`.

## 2. Source of truth

Главный репозиторий:

```text
rassvetpublic-spec/api551-ru-translation
```

Ветка завершённого Stage 4 перед promotion:

```text
candidates
```

Стабильная ветка:

```text
main
```

`main` напрямую не менять без явного разрешения пользователя.

## 3. Что читать первым

Перед любой значимой задачей по API 551 читать и сверять:

1. `README.md`;
2. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
3. `source/TZ_API551_PROJECT_STAGE5_FINAL_RU_PDF_CURRENT_2026-07-29.md`;
4. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
5. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
6. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
7. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`;
8. `catalog.json`;
9. `index.html`;
10. `tools/api551/api551.ps1`;
11. `docs/project/API551_TOOLING_CURRENT.md`;
12. `docs/project/API551_SOURCE_GATE_CURRENT.md`;
13. `docs/project/API551_RULES_RESOLUTION_CURRENT.md`;
14. `docs/project/API551_FIGURE_LIFECYCLE_CURRENT.md`;
15. `docs/project/API551_PACKAGE_QA_CURRENT.md`;
16. `docs/project/API551_PR_WORKFLOW_CURRENT.md`;
17. `.github/workflows/structure-check.yml`;
18. `.github/workflows/api551-tooling-check.yml`;
19. `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`, если задача касается LFS/local hydrated view;
20. `docs/project/API551_TOOLING_REPAIR_HISTORY_2026-07-09.md`, если нужно понять историю типовых ошибок toolkit.

`API551_PROMPTS.md`, старые ZIP, review HTML, audit/report и patch-файлы использовать только как archive/evidence/reference, если они не конфликтуют с CURRENT источниками.

## 4. Source-gate перед работой

Перед задачами с файлами, GitHub, Figure, workflow, acceptance pipeline или deliverables выполнить:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Source-gate обязан проверить:

1. Project Instructions текущего проекта;
2. Stage 5 CURRENT-ТЗ;
3. CURRENT manifest;
4. CURRENT consolidated policy/rules;
5. CURRENT universal cleanup/placement addendum;
6. CURRENT rework/source/frame-fit addendum;
7. source data и роль каждого source;
8. GitHub `catalog.json`, `index.html`, `workspace/figures/`, workflow;
9. текущий Figure-статус;
10. docs/status sync;
11. применимые `tools/api551` checks.

При конфликте остановиться и показать:

```text
source -> role -> problem -> risk -> required decision
```

## 5. Итоговое состояние Stage 4

Машинно-читаемый текущий статус хранится в:

```text
docs/project/API551_STAGE4_HANDOFF_CURRENT.json
```

Текущий статус Stage 4:

```text
accepted: 69/69
not_accepted: 0/69
changed/review: 0
Figure 2: accepted
Figure 3: accepted
LFS-tolerant CI: включён
Repo-local toolkit: /tools/api551
```

Stage 4 закрыт. Stage 5 CURRENT-ТЗ зарегистрировано; перед Gate 1 сверить эти числа и убедиться, что регистрационный PR уже merged:

```powershell
.\tools\api551\api551.ps1 status
```

## 6. Git LFS policy

Не выполнять по умолчанию:

```text
git lfs pull
```

Для обычного clone / sync использовать no-smudge режим. Точечно скачивать LFS только при реальной необходимости.

Текущий полный hydrated snapshot (без `.git`):

```text
C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT
```

GitHub остаётся источником истины для веток, SHA и текстового состояния.

Не коммитить hydrated PNG/PDF/ZIP как обычные Git modifications.

Подробное правило: `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`.

## 7. Figure production / rework rules

Для Figure production/rework:

1. исходный визуальный источник — только API 551 PDF / PDF-derived source crop;
2. previous translated PNG, old review PNG или overlay-result нельзя использовать как production source;
3. old translated assets можно использовать только как visual reference;
4. cleanup исходного английского текста выполнять до отрисовки русского перевода;
5. запрещён post-render cleanup в зоне, пересекающей русский текст или новую рамку;
6. если после render найдены остатки исходного английского текста, надо вернуться к clean source и пересобрать;
7. для PDF с текстовым слоем preferred cleanup — по PDF text span/glyph bbox с safety padding;
8. для leader-line/callout labels обязательна compact gray frame модель с фактическим внутренним padding 3–5 px в финальном PNG;
9. рамки не должны портить protected graphics;
10. approved-переводы не менять без traceable основания.

Команда для правил конкретного Figure:

```powershell
.\tools\api551\api551.ps1 rules-for -Figure NNN
```

## 8. Правило принятия Figure-кандидата

При переводе Figure-кандидата из `review`, `changed` или `not_accepted` в `accepted` запрещено ограничиваться только файлами объекта Figure.

Acceptance PR обязан обновить и проверить весь синхронизированный набор:

1. `workspace/figures/<NNN>/figure_<NNN>.object.json`;
2. `workspace/figures/<NNN>/figure_<NNN>.object.html`;
3. `workspace/figures/<NNN>/figure_<NNN>.out.html`;
4. `workspace/figures/<NNN>/figure_<NNN>.png`;
5. `workspace/figures/<NNN>/figure_<NNN>.source_crop.png`;
6. `catalog.json`;
7. `index.html`;
8. `.github/workflows/structure-check.yml`, если accepted set/stats hard-coded;
9. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
10. entrypoint docs, если изменились правила/workflow/tooling.

## 9. Acceptance pipeline

Минимальная цепочка:

```text
source-gate -> task branch from main -> Stage 5 gate-scoped change -> PR into main -> CI/status check -> explicit merge -> verify main
```

Для user-accepted Figure:

1. подтвердить, что пользователь принял конкретную версию Figure;
2. начинать branch от актуального `origin/candidates`;
3. не менять `main`;
4. PR должен быть в `candidates`;
5. перед merge проверить open review comments, changed files, base/head, CI;
6. merge выполнять только после явной команды пользователя.

Команда PR-проверки:

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

## 10. Запрещено

Запрещено:

- использовать image generation или generative image editing;
- дорисовывать или выдумывать графику;
- работать по памяти, старым чатам или `/mnt/data` как единственному source of truth;
- использовать OCR как замену approved label master CSV;
- менять approved-переводы без основания;
- сужать master CSV по OCR;
- менять `main` напрямую;
- выводить большие HTML, PNG, JSON, CSV или debug dump в чат;
- считать File Library source of truth;
- считать старые archive ZIP production input;
- коммитить локально hydrated PNG/PDF/ZIP как обычные Git modifications.

## 11. Новый чат: готовый стартовый промпт

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
10. docs/project/API551_TOOLING_REPAIR_HISTORY_2026-07-09.md, если нужно понять историю типовых ошибок toolkit.

Git LFS assets не скачивать по умолчанию.
Для просмотра real PNG/PDF/ZIP использовать local hydrated-view, не Git worktree.

Задача: продолжить Stage 4 Figure Objects. Сначала выполни source-gate, затем определи текущий Figure-статус и предложи следующий минимальный проверяемый шаг.
```

## 12. Следующий безопасный шаг

После source-gate выбрать следующий `not_accepted` Figure из `catalog.json`, проверить его source labels и rules, затем готовить review package без изменения accepted status до явного принятия пользователем.

## accept-figure command

For a Figure candidate already approved by the user, use the repo-local acceptance command instead of one-off scripts:

```powershell
.	oolspi551pi551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

The command performs package-check, installs `workspace/figures/NNN`, marks the Figure as accepted, updates `catalog.json`, `index.html`, `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`, bootstrap status markers, and the hard-coded accepted state in `.github/workflows/structure-check.yml`. It does not commit, push, merge, or delete branches.

