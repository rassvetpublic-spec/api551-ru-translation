# API 551 Stage 5 Gate 1 — source map

Status: machine map complete; manual review pending.

This package is generated only from the verified `API 551 2016 (R2024).pdf`
and the accepted `catalog.json` Figure registry.

## Outputs

- `API551_STAGE5_GATE1_PAGE_MAP_INDEX.json` — map index and chunk checksums.
- `page_map/*.json` — all 244 page records.
- `API551_STAGE5_GATE1_ANCHOR_REGISTRY.json` — anchors and references.
- `API551_STAGE5_GATE1_QA_REPORT.json` — coverage and review queue.

## Generation

```powershell
python .\tools\api551\stage5_gate1_map.py --pdf '.\source\API 551 2016 (R2024).pdf' --catalog .\catalog.json --output .\workspace\stage5\gate1 --dpi 150 --workers 4 --chunk-size 16
```

The rendered page is the primary OCR source. The embedded PDF text layer and
vector table geometry are secondary controls only. Ambiguous blocks are
reported for manual review and are not guessed.

Gate 2 must not start until the Gate 1 manual review is complete and Gate 1 is
accepted.
