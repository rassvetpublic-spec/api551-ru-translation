# API 551 Stage 4 Working Memory

Updated: 2026-06-18

## Source Check

Mandatory Stage 4 sources are available for work:

- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md`: current Stage 4 operational TZ.
- `TZ_API551_translation_project_RU.md`: baseline/restart archive; keep unchanged.
- `api551_v5_clean_20260616/*CURRENT*.md` and approved files: unpacked current rules v5.
- `API 551 2016 (R2024).pdf`: primary source and visual reference, 244 pages, not encrypted.
- `api551_approved_label_master_v1.csv`: master label register, 950 rows across 69 figures.
- `RULES_API551_STAGE2_IMAGE_LABEL_REPLACEMENT_STRATEGIES_v1.md`: approved label replacement strategy.
- `API_551_STAGE3_SOURCE_PACKAGE_v1.zip`: Stage 3 production package.
- `API_551_STAGE2_REFERENCE_FILES_v1.zip`: Stage 2 reference package.
- `api551_control_build_v1.zip`: control build only; not the primary source of truth.

Drive source-folder check, 2026-06-18:

- `API 551/Source` exists and is readable through Google Drive connector.
- Folder URL: `https://drive.google.com/drive/folders/1LmtL05ABlWHKY3gI8LbONq-7Ju4-hezH`.
- Current Drive API file count in `API 551/Source`: 22.
- `API 551/Source` is now the canonical Stage 4 source folder.
- Mandatory sources are visible there: Stage 4 TZ, baseline TZ, PDF, CSV, Stage2 strategy rules, Stage3 package, Stage2 package, control build, and unpacked v5 CURRENT/APPROVED rules.
- Local `/workspace/.cache` and `/workspace/api551_v5_clean_20260616` are fallback/working copies only after Drive Source verification.

## Current Stage 4 Status

Drive folder: `API 551`.

Current Drive catalog status:

- Total figures: 69.
- Accepted: 19.
- Changed / review: 1.
- Not accepted: 49.

Accepted figures in the current working status:

`1, 4, 9, 14, 16, 18, 23, 25, 28, 30, 31, 33, 37, 46, 48, 50, 52, 62, 66`

Figure 51 remains `измененно_2026-06-17`, not accepted.

## Packaging Policy

- Do not build cumulative ZIPs.
- Build diff-only ZIPs: root `index.html`, root `catalog.json`, and folders only for new or changed objects.
- PDF is external and must not be included in ZIP packages.
- Expected PDF path on the user's machine: `C:\Downloads\API 551\API 551 2016 (R2024).pdf`.
- Source PDF links in HTML must use `file:///C:/Downloads/API%20551/API%20551%202016%20(R2024).pdf#page=N`.
- Each accepted/changed figure folder must include final PNG, source crop PNG, object HTML, clean export HTML, and service JSON.
- `object.html` is for review and service data.
- `out.html` is clean final-export content only, without service audit tables.

## Layout Policy

For complex Figure objects:

1. Figure image.
2. Label table, if labels are outside/reconstructed.
3. Notes, if present.
4. Figure caption at the bottom.

Do not add a separate visible table heading for notes. Use rows like `Примечание X | text`.

## Label Source Policy

- For unaccepted figures, `api551_approved_label_master_v1.csv` is the baseline label source.
- After a figure is explicitly accepted by the user, that accepted object becomes priority over CSV for that figure.
- OCR is verification and discovery support, not a source of truth.
- If uncertainty is above 0.1%, ask before guessing.
- Do not drop CSV rows by `action`; every row must receive a documented outcome.

## Protected / No-Translation Policy

Treat as protected and do not translate:

- one-letter symbols;
- alphanumeric tags;
- `NOTE X` / `Note X` references;
- chemical element names/symbols;
- pure dimensions and formulas;
- service abbreviations and symbol-only labels covered by the rules.

Keep protected elements visible and traceable.

## Image Editing Policy

- No image generation.
- No generative image editing.
- Work only programmatically with existing PDF/PNG/HTML/JSON/CSV/ZIP.
- Rebuild corrected figures from clean source crop, not from an already translated final PNG.
- Preserve drawing lines, arrows, dimensions, hatching, tables, and protected masks.

## Text Placement Policy

Use font:

`/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf`

For placement expansion:

- Inspect pixels left and right across the full height of the placement window.
- If both sides are clear, expand both ways.
- If only one side is clear, expand to the clear side.
- If neither side is clear, try the same strategy vertically with multiline wrapping.

For tight clearing:

- Clear the original text bbox with a small safety margin.
- Do not clear the full expanded placement rectangle.
- After placing translation, optically check translation margins and reduce clearing if excessive while ensuring the full original label is removed.

## Multiline Policy

- Group original OCR fragments into one semantic label before translation placement.
- A label normally cannot start with a lowercase fragment or a middle fragment unless the approved source text itself does.
- If the translation contains parentheses or brackets and the bracketed part is roughly comparable to the preceding text, move the full bracketed part to a new line.

Example policy target:

`Преобразователь перепада давления`
`(с вентиляционными клапанами)`

## Vertical Label Policy

- Do not infer vertical reading direction from bbox shape alone.
- Crop the original label zone and test both normalizations: rotate page `+90` and `-90`.
- The readable normalization defines the source reading direction.
- Place the Russian translation with inverse page rotation so it is readable under the same normalization.
- Apply multiline grouping before determining direction.
- For vertical multiline labels, search/group fragments leftward along the column.

Figure 37 correction:

- `Normal working level` is readable after clockwise page rotation.
- Russian translation must therefore be counterclockwise on the page.

## Figure-Specific Active Notes

- Figure 15: must not miss labels such as `Total vacuum (zero or absolute)`, `Absolute`, `Barometric range`, and atmospheric pressure text.
- Figure 46: includes `Area to avoid` and `Preferred tap locations`.
- Figure 47: mixed object; `notes_removed` does not mean there are no callouts.
- Figure 48: accepted; parenthetical wrapping and tight clearing policy apply.
- Figure 51: changed/review only; rebuild from clean source crop because older version used wrong source/layer remnants.
- Figure 62: previous p4 issue split into two labels.
- Figure 66: reconstructed table with drawing cell.
- Translate `specific gravity` as `отн. плотность` where space is constrained.
