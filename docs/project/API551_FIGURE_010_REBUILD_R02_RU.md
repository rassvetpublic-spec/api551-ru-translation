# Figure 10 R02 — причина пересборки

R01 отклонена, поскольку отчёт не доказывает применение обязательных правил:

- gray-frame rendering для leader-line callouts;
- text-driven frame bbox;
- padding 3–5 px;
- касание/минимальный безопасный зазор до leader line;
- per-label protected-graphics intersection QA;
- точное сохранение расположения callout относительно anchor.

R02 должна быть полностью пересобрана от original PDF page 43. Патч старой translated PNG запрещён.

## Production entrypoint

```powershell
.\.venv\Scripts\python.exe tools\api551\build_figure010_r02.py self-test --font-path C:\GIT\api551\_local_artifacts\tool_cache\urw-base35\master\NimbusSans-Regular.otf
.\.venv\Scripts\python.exe tools\api551\build_figure010_r02.py clean --repo-root C:\GIT\api551 --gate-json <FIGURE_010_STRATEGY_GATE_R02.json> --output-dir <r02-build-dir>
.\.venv\Scripts\python.exe tools\api551\build_figure010_r02.py render --output-dir <r02-build-dir> --gate-json <FIGURE_010_STRATEGY_GATE_R02.json> --verification-json <cleaned-only-verification.json> --font-path C:\GIT\api551\_local_artifacts\tool_cache\urw-base35\master\NimbusSans-Regular.otf
```

Команда `render` блокируется, пока отдельный cleaned-only verification JSON не подтверждает визуальную проверку конкретного SHA-256 intermediate PNG.

После упаковки и fresh extract выполнить `finalize` с per-label visual approval JSON. Только после этого `figure_010.frame_qa.json` может иметь статус `PASS`.

## Font gate

Используется только Nimbus Sans Regular из официального репозитория Artifex URW Base35.

- ожидаемый SHA-256: `7c25be4d78155523080ab85b10277150657ff7dabbcad7037bdd536c9b6d0d08`;
- silent font substitution запрещён;
- бинарный font-файл хранится только в repo-local tool cache и не коммитится в text-only tooling PR.

## Cleanup и frame metrics

- cleanup выполняется по ink-mask внутри свежих source-text ROI;
- для многострочной подписи block-002 допускается несколько точных ROI, чтобы удалить весь исходный текст и не задеть начинающуюся рядом выносную линию;
- порог ink-mask `value < 254` удаляет также светлые пиксели сглаживания исходного текста; маска по-прежнему жёстко ограничена проверенными ROI;
- изменения вне объединённой cleanup mask запрещены;
- `3 in.` сверяется попиксельно до отрисовки;
- восемь leader-line callout получают thin gray frame;
- frame строится от фактического Nimbus Sans text bbox с padding 4 px;
- block-005 остаётся free text только по зафиксированному fresh-source evidence;
- block-007 остаётся protected dimension.

Финальная геометрия ROI и anchor уточняется только по fresh PDF crop на cleaned-only gate до русской отрисовки. Любая корректировка после обнаружения остаточного исходного текста требует повторного `clean`, визуальной проверки cleaned-only PNG, нового verification SHA-256 и полного `render`.
