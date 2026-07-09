# API 551 Stage 4 — старт нового чата

Статус: CURRENT bootstrap для продолжения Stage 4 в новом чате.  
Проект: API 551 RU Translation / Stage 4 Figure Objects.  
Язык работы: русский.

Этот файл нужен, чтобы новый чат мог начать работу без восстановления контекста по старой переписке. Если этот файл конфликтует с `source/API551_SOURCE_MANIFEST_CURRENT.json`, CURRENT policy/rules или системными инструкциями проекта, более высокий источник управляет.

## 1. Назначение проекта

Цель Stage 4 — получить проверяемые русские составные Figure-объекты API RP 551 для дальнейшей финальной сборки документа.

Figure-объект обычно включает:

1. исходный crop / source crop;
2. финальный PNG с русскими надписями;
3. object JSON;
4. service/review HTML;
5. out/export HTML;
6. запись в `catalog.json`;
7. строку в `index.html`.

## 2. Source of truth

Главный репозиторий:

```text
rassvetpublic-spec/api551-ru-translation
```

Рабочая ветка Stage 4:

```text
candidates
```

Стабильная ветка:

```text
main
```

`main` напрямую не менять без явного разрешения пользователя. Рабочие PR для Figure-кандидатов и правил делать в `candidates`.

## 3. Что читать первым

Перед любой значимой задачей по API 551 читать и сверять:

1. `README.md`;
2. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
3. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
4. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
5. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
6. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`;
7. `catalog.json`;
8. `index.html`;
9. `.github/workflows/structure-check.yml`;
10. применимые файлы в `docs/rules/`;
11. `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`, если задача касается Git LFS, локальных PNG/PDF/ZIP, hydrated-view, backup или визуальной проверки без широкого LFS download.

`API551_PROMPTS.md`, старые ZIP, review HTML, audit/report и patch-файлы использовать только как archive/evidence/reference, если они не конфликтуют с CURRENT источниками.

## 4. Source-gate перед работой

Перед задачами с файлами, GitHub, Figure, workflow, acceptance pipeline или deliverables выполнить source-gate:

1. проверить Project Instructions текущего проекта;
2. проверить CURRENT manifest;
3. проверить CURRENT consolidated policy/rules;
4. проверить CURRENT universal cleanup/placement addendum;
5. проверить CURRENT rework/source/frame-fit addendum;
6. проверить source data и роль каждого source;
7. проверить GitHub `catalog.json`, `index.html`, `workspace/figures/`, workflow;
8. определить статус нужного Figure;
9. при конфликте остановиться и показать:

```text
source -> role -> problem -> risk -> required decision
```

## 5. Текущее состояние Stage 4

Машинно-читаемый текущий статус хранится в:

```text
docs/project/API551_STAGE4_HANDOFF_CURRENT.json
```

На момент создания этого bootstrap:

```text
accepted: 21/69
not_accepted: 48/69
changed/review: 0
Figure 2: accepted через PR #30
LFS-tolerant CI: включён через PR #31
Local hydrated-view workflow: закреплён через PR #34
```

Перед началом новой работы всегда сверить эти числа с `catalog.json` и `index.html`.

## 6. Git LFS policy

Не выполнять по умолчанию:

```text
git lfs pull
```

Для обычного clone / sync использовать no-smudge режим:

```powershell
$env:GIT_LFS_SKIP_SMUDGE='1'; git clone --branch candidates --single-branch https://github.com/rassvetpublic-spec/api551-ru-translation.git 'API 551'; Remove-Item Env:\GIT_LFS_SKIP_SMUDGE -ErrorAction SilentlyContinue
```

Точечно скачивать LFS только при реальной необходимости:

```powershell
git lfs pull --include="workspace/figures/002/figure_002.png"
```

Если локальные PNG/PDF/ZIP выглядят как маленькие текстовые файлы, это может быть нормальный Git LFS pointer после no-smudge clone, а не порча проекта.

CI `Structure check` должен работать без скачивания всех LFS-объектов: checkout с `lfs: false`, проверка текстовых файлов и pointer checks для binary assets.

### Local hydrated-view правило

Для локального просмотра и страховки binary-файлов использовать отдельную папку:

```text
C:\GIT\API551_HYDRATED_VIEW
```

Основной repo:

```text
C:\GIT\API 551
```

должен оставаться чистым Git checkout для commits/PR. Не коммитить hydrated PNG/PDF/ZIP как обычные изменения. Если binary-файлы восстанавливаются из локальной копии, копировать их только при совпадении `oid sha256` и `size` с LFS pointer текущей ветки.

Подробное правило: `docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md`.

## 7. Figure production / rework rules

Для Figure production/rework:

1. исходный визуальный источник — только API 551 PDF / PDF-derived source crop;
2. previous translated PNG, old review PNG или overlay-result нельзя использовать как production source;
3. old translated assets можно использовать только как visual reference;
4. cleanup исходного английского текста выполнять до отрисовки русского перевода;
5. запрещён post-render cleanup в зоне, пересекающей русский текст или новую рамку;
6. если после render найдены остатки исходного английского текста, надо вернуться к clean source и пересобрать, а не стирать поверх результата;
7. для PDF с текстовым слоем preferred cleanup — по PDF text span/glyph bbox с safety padding;
8. для leader-line/callout labels обязательна compact gray frame модель с фактическим внутренним padding 3–5 px в финальном PNG;
9. рамки не должны портить protected graphics: оборудование, линии, стрелки, размеры, контуры, трубопроводы, фланцы;
10. approved-переводы не менять без traceable основания.

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
8. `.github/workflows/structure-check.yml`, если в нём есть hard-coded accepted set, stats или Figure-specific checks;
9. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
10. `docs/project/API551_NEW_CHAT_START_RU.md`, если изменились правила, workflow, source-gate, LFS policy или текстовый текущий статус Stage 4;
11. `README.md`, если изменились entrypoint, source-gate, workflow policy или список обязательных стартовых файлов;
12. `docs/API551_PROJECT_QUICK_START_CURRENT.md`, если изменился порядок стартового чтения или новый bootstrap/handoff.

Acceptance PR считается неполным, если Figure принят в `catalog.json`, но bootstrap/handoff/init-файлы нового чата не отражают новый статус проекта.

Минимально при каждом новом accepted Figure должен обновляться:

```text
catalog.json
index.html
docs/project/API551_STAGE4_HANDOFF_CURRENT.json
.github/workflows/structure-check.yml, если accepted set/stats в нём hard-coded
```

## 9. Acceptance pipeline

Минимальная цепочка:

```text
source-gate -> clean branch from candidates -> changes -> local/diff check -> PR into candidates -> CI/status check -> merge only after explicit user command -> verify candidates -> handoff
```

Для user-accepted Figure:

1. подтвердить, что пользователь принял конкретную версию Figure;
2. начинать branch от актуального `origin/candidates`;
3. не менять `main`;
4. PR должен быть в `candidates`;
5. в PR summary указать Figure number, accepted status, изменённые sync-файлы, проверки;
6. перед merge проверить open review comments, changed files, base/head, CI;
7. merge выполнять только после явной команды пользователя.

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
10. docs/project/API551_LOCAL_LFS_HYDRATED_VIEW_WORKFLOW_CURRENT.md, если задача касается LFS/local hydrated view.

Рабочая ветка: candidates.
main напрямую не менять.

Git LFS:
не делать git lfs pull по умолчанию;
CI должен работать с lfs:false и pointer checks;
LFS assets скачивать только точечно;
для просмотра real PNG/PDF/ZIP использовать local hydrated-view, не Git worktree.

Задача: продолжить Stage 4 Figure Objects. Сначала выполни source-gate, затем определи текущий Figure-статус и предложи следующий минимальный проверяемый шаг.
```

## 12. Следующий безопасный шаг

После source-gate выбрать следующий `not_accepted` Figure из `catalog.json`, проверить его source labels и rules, затем готовить review package без изменения accepted status до явного принятия пользователем.
