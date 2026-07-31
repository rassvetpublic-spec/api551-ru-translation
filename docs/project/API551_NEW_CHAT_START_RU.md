# API 551 — старт нового чата: Stage 4 завершён, Stage 5 открыт

Статус: CURRENT bootstrap для завершённого Stage 4 и Stage 5 по утверждённому CURRENT-ТЗ.  
Проект: API 551 RU Translation.  
Язык работы: русский.

Если этот файл конфликтует с Project Instructions, manifest или CURRENT policy/rules, управляет более высокий источник.

## 1. Первый вход

```powershell
.\tools\api551\api551.ps1 source-gate
```

Git-worktree: `C:\Irvis-UPG\GIT\API 551`.  
Snapshot без `.git`: `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT`.

## 2. Репозиторий и ветки

- Source of truth: `rassvetpublic-spec/api551-ru-translation`.
- Stable: `main`.
- Stage 5: `task/<topic>` от актуального `main`, затем PR в `main`.
- `main` напрямую не менять.
- Отдельной Stage 4 baseline-ветки нет: baseline зафиксирован коммитом `fbc861e7a3ec22aae098d15420cbda452f5d2802` и сохранён в истории `main`.

Политика веток синхронизируется в config, handoff и handoff schema.

## 3. Что читать первым

1. `README.md`;
2. `docs/project/API551_STAGE4_HANDOFF_CURRENT.json`;
3. `source/TZ_API551_PROJECT_STAGE5_FINAL_RU_PDF_CURRENT_2026-07-29.md`;
4. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
5. три CURRENT policy/rules файла из `source/`;
6. `catalog.json` и `index.html`;
7. `docs/API551_PROJECT_QUICK_START_CURRENT.md`;
8. CURRENT docs из `docs/project/`;
9. `tools/api551/api551.config.json`;
10. `tools/api551/schemas/handoff.schema.json`;
11. оба обязательных GitHub workflow.

`API551_PROMPTS.md`, старые ZIP и reports — только archive/evidence/reference.

## 4. Source-gate

```powershell
.\tools\api551\api551.ps1 source-gate
```

Проверить CURRENT-ТЗ Stage 5, manifest, policy/rules, source data, catalog/index, Figure status, handoff/schema, ветку, документацию и CI.

При конфликте:

```text
source -> role -> problem -> risk -> required decision
```

## 5. Текущее состояние

```text
accepted: 69/69
not_accepted: 0/69
changed/review: 0
stage4: completed
stage5: Gate 0 completed by merged PR #65; Gate 1 authorized, not started
```

PR #65 уже смержен в `main` (`eeca80146ff59660326eef55582ad611f2d7c3c4`). Для Gate 1 создать новую `task/*` ветку от актуального `main` и повторить source-gate.

## 6. Git LFS

- Broad `git lfs pull` не запускать по умолчанию.
- Git-worktree и snapshot — разные папки.
- Реальные LFS-файлы в worktree допустимы при `git lfs fsck OK` и пустом `git status --short`.
- Snapshot без `.git` не использовать для commit/push.
- Импорт сверять по pointer SHA-256 и размеру.

## 7. Stage 5 Gates

1. Gate 1 — карта 244 страниц и объектов.
2. Gate 2 — перевод, реконструкция нативных таблиц и полный русский HTML/JSON.
3. Gate 3 — проверка и принятие полной HTML/JSON-карты.
4. Gate 4 — финальная PDF-сборка с 69 accepted Figure.
5. Gate 5 — полный постраничный и машинный QA.

## 8. Figure

Все 69 Figure приняты и заморожены. Изменения — только после явного переоткрытия пользователем, в отдельной ветке от актуального `main` и через PR в `main`.

## 9. PR workflow

```text
source-gate -> task/* from main -> gate-scoped change -> diff/review -> PR into main -> all checks -> explicit merge -> verify main
```

```powershell
.\tools\api551\api551.ps1 pr-check -Pr N
```

## 10. Запрещено

- generative image editing;
- выдумывать графику;
- менять accepted-переводы без основания;
- заменять approved CSV результатами OCR;
- использовать archive/snapshot/File Library как source of truth;
- менять `main` напрямую;
- merge без явной команды и всех успешных проверок.

## 11. Готовый стартовый промпт

```text
Работаем в API 551 RU Translation. Stage 4 завершён: 69/69 Figure приняты.
Source of truth: rassvetpublic-spec/api551-ru-translation.
Stable: main. Stage 5 — task/<topic> от актуального main и PR в main.

Прочитай bootstrap, handoff/schema, Stage 5 CURRENT-ТЗ, manifest, CURRENT policy/rules, catalog/index.
Запусти .\tools\api551\api551.ps1 source-gate.
PR #65 смержен в main, Gate 0 завершён. Создай task-ветку от актуального main, повтори source-gate и выполняй только Gate 1: карту 244 страниц, таблиц, Figure, NOTE, сносок и ссылок.
```

## 12. Следующий безопасный шаг

Создать `task/stage5-gate1-page-map` от актуального `main`, повторить source-gate и выполнить только Gate 1.

## accept-figure command

Только для Figure, явно переоткрытой и повторно принятой:

```powershell
.\tools\api551\api551.ps1 accept-figure -Figure NNN -PackageZip <path-to-review-zip>
```

Команда не выполняет commit, push, merge или удаление веток.

## 13. Карта перенесённых правил

Детальные Figure cleanup/layout правила не дублируются в bootstrap: ими управляют три CURRENT policy/rules файла и accepted Figure object. Правила package/acceptance сохранены в `API551_PACKAGE_QA_CURRENT.md`, `API551_FIGURE_LIFECYCLE_CURRENT.md` и reopen-only acceptance pipeline.

При переоткрытии Figure синхронно проверять object JSON/HTML, PNG/source crop, `catalog.json`, `index.html`, handoff и hard-coded CI status. Для обычного Stage 5 Gate 1–5 эти Figure-правила не заменяют CURRENT-ТЗ.
