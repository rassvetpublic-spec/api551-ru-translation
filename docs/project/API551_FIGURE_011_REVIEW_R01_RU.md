# Figure 11 R01 — review-only пересборка

Figure 11 строится только из original PDF page 45 после rule-ack и per-label strategy gate.

```powershell
.\.venv\Scripts\python.exe tools\api551\build_figure011_r01.py self-test --font-path <NimbusSans-Regular.otf>
.\.venv\Scripts\python.exe tools\api551\build_figure011_r01.py clean --repo-root C:\GIT\api551 --gate-json <strategy.json> --output-dir <build>
.\.venv\Scripts\python.exe tools\api551\build_figure011_r01.py render --output-dir <build> --gate-json <strategy.json> --verification-json <cleaned-verification.json> --font-path <NimbusSans-Regular.otf>
```

Оси заменяются без callout-рамок. Надписи Legend заменяются только внутри существующих ячеек; границы таблицы и образцы линий защищены. Caption остаётся вне PNG. После ZIP/fresh extract выполняются `finalize` и `validate_figure011_qa.py`. Accepted-state не изменяется.
