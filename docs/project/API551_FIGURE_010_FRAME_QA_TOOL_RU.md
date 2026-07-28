# Проверка рамок Figure 10

## Назначение

`tools/api551/validate_figure010_frame_qa.py` запрещает выдачу Figure 10 без per-label metrics.

## Точка входа

```powershell
.\.venv\Scripts\python.exe tools\api551\validate_figure010_frame_qa.py <path-to-figure_010.frame_qa.json>
```

## Что проверяется

- пересборка R02+ от PDF page 43;
- R01 не использована как production source;
- cleaned-only intermediate;
- обязательные рамки;
- padding 3–5 px;
- связь с leader line;
- отсутствие пересечений;
- protected dimension `3 in.`;
- caption вне PNG;
- fresh-extracted PNG inspected.

Инструмент проверяет структуру QA и обязательные gate-поля. Он не заменяет визуальную проверку.

## Связь с builder

`tools/api551/build_figure010_r02.py` сначала создаёт QA со статусом `PENDING_VISUAL_QA`. Команда `finalize` переводит его в `PASS` только после совпадения SHA-256 working/fresh-extracted PNG и полного per-label visual approval.

`figure_010.frame_qa.json` хранится рядом с локальными build/report artifacts и публикуется только как текстовый audit. В review ZIP он не добавляется, потому что ZIP обязан содержать ровно шесть Figure-файлов.
