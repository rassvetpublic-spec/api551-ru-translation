# API 551 - Consolidated Project and Stage 4 Technical Specification

Status: CURRENT active operational source.

Date: 2026-06-18.

Accepted by user as replacement active Stage 4 TZ on 2026-06-18.

Purpose: consolidated operational technical specification replacing the scattered project/current/Stage4 TZ files while preserving their essential content and resolving contradictions.

## 1. Authority and Source Hierarchy

Canonical source folder:

`Google Drive / API 551 / Source`

This file is the current operational project specification after upload and acceptance.

It consolidates:

- `TZ_API551_translation_project_RU.md`
- `TZ_API551_translation_project_RU_CURRENT_2026-06-16.md`
- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md`

Resolved contradiction:

- `TZ_API551_translation_project_RU_CURRENT_2026-06-16.md` stated that the old baseline TZ could be removed.
- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md` stated that the old baseline TZ must not be deleted.

Accepted resolution:

- Keep `TZ_API551_translation_project_RU.md` as `ARCHIVE / BASELINE / RESTART`.
- Do not use it as the current operational Stage 4 plan.
- Do not delete it unless the user explicitly changes the mandatory-source policy.

## 2. Project Goal

Create a technically correct Russian translation of API 551 while preserving:

- document structure;
- internal references;
- tables;
- figures;
- captions;
- notes;
- footnotes;
- bibliography;
- traceability to source PDF pages;
- approved figure label decisions.

Final project artifacts:

1. Final Russian HTML clean copy with hidden original text opened by click where applicable.
2. Final Russian printable PDF clean copy, without service/debug data.
3. JSON/CSV registers for traceability, figures, tables, labels, decisions, QA, and statuses.
4. Approved figure package/register after all 69 Figure objects are accepted.

## 3. Current Stage

Current stage: Stage 4.

Stage 4 starts after rule systematization and earlier Stage work.

Stage 4 goal:

Produce 69 approved composite Figure objects for final document assembly.

Stage 4 is not the final full-document PDF stage.

Stage 4 output:

- approved figure images or reconstructed figure objects;
- clean export HTML for each figure object;
- review/service HTML where required;
- object JSON;
- label/reconstruction decisions;
- QA status;
- diff/overlay ZIPs for review and acceptance.

Do not restart Stage 1, Stage 2, or Stage 3 unless explicitly instructed.

## 4. Mandatory Sources

Before any Stage 4 work, verify availability of the mandatory sources in `API 551/Source`:

- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md` or this consolidated replacement after upload and acceptance.
- `TZ_API551_translation_project_RU.md` as archive/baseline/restart.
- `API551_RULES_SYSTEMATIZED_v5_CLEAN_2026-06-16.zip` or unpacked CURRENT/APPROVED files.
- `API 551 2016 (R2024).pdf`.
- `api551_approved_label_master_v1.csv`.
- `RULES_API551_STAGE2_IMAGE_LABEL_REPLACEMENT_STRATEGIES_v1.md`.
- `API_551_STAGE3_SOURCE_PACKAGE_v1.zip`.
- `API_551_STAGE2_REFERENCE_FILES_v1.zip`.
- `api551_control_build_v1.zip`.

If any mandatory source is unavailable, stop and report:

- file name;
- role;
- access problem;
- Stage 4 risk.

## 5. Active Source Model After Consolidation

Preferred active Source structure:

- this consolidated TZ;
- baseline/restart TZ;
- original PDF;
- master CSV;
- Stage2 replacement strategy;
- Stage2 reference ZIP;
- Stage3 source ZIP;
- control build ZIP;
- v5 clean rules ZIP;
- Stage4 consolidated policies ZIP;
- source manifest JSON.

Avoid keeping both:

- a ZIP package and all its unpacked component files in active Source;
- a current TZ and several superseded TZ variants;
- review ZIPs in active Source;
- cleanup/evidence reports in active Source.

Archived files may remain outside `Source`, under the root `API 551` archive folder.

## 6. Non-Loss Principle

No meaningful API 551 source content may be lost.

Final HTML/PDF must preserve:

- main text;
- headings;
- lists;
- tables;
- figures;
- captions;
- notes;
- footnotes;
- bibliography;
- meaningful internal Figure labels;
- meaningful internal Figure tables;
- meaningful text blocks inside Figures.

Rules such as "do not include", "do not show", "do not translate", and "exclude from crop" apply only to service layers unless explicitly approved otherwise:

- raw OCR;
- debug output;
- visible JSON/CSV dumps;
- QA comments;
- temporary anchors;
- HTML/CSS/JS interface artifacts;
- internal reports.

If a fragment is source content, it must appear in the final project through one approved route:

- translated main text;
- reconstructed table;
- note;
- footnote;
- caption;
- approved Figure object;
- translated internal label;
- protected/no-change element;
- manual-control item.

## 7. Main Text Processing

The main text workflow remains:

`render PDF page -> OCR -> block layout -> OCR correction -> translation -> HTML/JSON -> QA -> final assembly`

The embedded PDF text layer is not the primary source for layout or translation. It may be used only as a secondary check for disputed text.

This rule belongs primarily to full-document translation stages. Stage 4 figure work must still use the source PDF visually and programmatically for figure/crop verification.

## 8. Image and Figure Processing Prohibitions

Do not:

- use image generation;
- use generative image editing;
- invent missing graphics;
- redraw technical graphics manually;
- silently substitute source assets;
- start from old bbox values without verification;
- output HTML/PNG previews in chat;
- include large HTML/JSON/CSV/tables in chat.

Work only programmatically with existing:

- PDF;
- PNG;
- HTML;
- JSON;
- CSV;
- ZIP;
- approved registers;
- source packages.

## 9. Composite Figure Object Definition

All API 551 figures are composite objects.

Minimum figure object:

- image/drawing or reconstructed figure;
- caption/title at the bottom;
- object JSON;
- status.

Possible object components:

- translated labels on the image;
- label table;
- note table;
- reconstructed internal table;
- paragraph above or below figure;
- panel/block;
- source PDF page link;
- first mention link;
- protected/manual-control data in JSON/review only.

Clean export order:

1. figure image/object;
2. label table if labels are intentionally reconstructed outside the image;
3. notes table if notes are restored from the figure;
4. figure caption at the bottom.

Caption must be the last visible component.

No separate visible table heading is used for labels or notes unless explicitly approved.

Note row format:

`Примечание X | text`

## 10. Stage 4 Figure Acceptance

A Figure object is acceptable only if:

- all meaningful labels are accounted for;
- all approved on-image labels are applied;
- all text/table reconstruction blocks are preserved;
- notes are not lost;
- caption/title is present;
- graphics are not damaged;
- lines/arrows/dimensions/axes/frames/hatching are not removed;
- translation is readable;
- bbox/mask decisions are traceable;
- JSON/CSV status is updated;
- manual-control cases are explicit;
- object is ready for final assembly.

Critical rejection conditions:

- meaningful label lost;
- note lost;
- internal figure table lost;
- graphics damaged;
- protected/do-not-change zone altered;
- old bbox used without verification;
- doubtful block replaced automatically;
- caption/title missing;
- object not traceable by PDF page / section / figure id.

## 11. Label Source and Priority

For unaccepted figures:

- `api551_approved_label_master_v1.csv` is the baseline label and translation source.

For accepted figures:

- the accepted Stage 4 object has priority over the CSV for that figure.
- User acceptance freezes label count, translations, reconstruction choices, and status.

OCR is verification/discovery only. OCR cannot override approved translations and cannot reduce CSV rows.

Every CSV row with `original_text` or `ru_text` must receive an explicit outcome:

- on-image;
- text reconstruction;
- table reconstruction;
- caption;
- protected/no-change;
- manual-control;
- fragment;
- duplicate;
- split.

If uncertainty exceeds 0.1%, ask the user.

## 12. BBox, Masks, and Placement

BBox rules:

- bbox should follow letter pixels closely;
- use minimal safety margin;
- do not include leader lines as text;
- if a line is outside text, it is graphics;
- old bbox values require verification/normalization.

Mask rules:

- clear only text mask;
- protect graphics through protected masks;
- never clear protected/do-not-change zones;
- preserve protected collision zones.

Placement expansion:

1. Inspect free space left/right across full placement-window height.
2. If both sides are free, expand both directions.
3. If one side is free, expand to that side.
4. If neither side is safe, use vertical/multiline placement strategy.
5. If no safe solution exists, mark manual-control.

Clearing:

- clear original label bbox with small safety margin;
- do not clear the full expanded placement/search area;
- draw translation on tight background;
- reduce excessive white fields after optical check.

## 13. Protected / Do-Not-Translate Policy

Do not translate or alter on PNG:

- one-letter symbols;
- one-digit symbols;
- alphanumeric technical tags;
- `NOTE X`, `(NOTE X)`, `Note X` references;
- chemical element names/symbols when technical notation;
- formulas;
- variables;
- dimensions and values with units;
- section markers;
- service abbreviations;
- symbol-only labels;
- protected collision zones.

Protected elements remain visible and traceable in JSON/service metadata.

## 14. Multiline and Vertical Text

Group OCR fragments into semantic source labels before placement.

Labels normally cannot start with a lowercase fragment or middle fragment unless the approved source text itself does.

For horizontal multiline labels:

- search upward and nearby for parent block.

For vertical multiline labels:

- search leftward along the same column for parent block.

Vertical direction:

1. Crop original vertical label zone.
2. Test page rotations `+90` and `-90`.
3. Readable normalization defines source reading direction.
4. Place Russian translation with inverse page rotation.

Figure 37 correction:

- `Normal working level` is readable after clockwise page rotation.
- Russian translation must be counterclockwise on page.

## 15. Wrapping and Font

If translation contains `(...)` or `[...]`, try to move the full bracketed part to a new line.

If bracketed text is comparable in length to preceding text, prefer:

`Преобразователь перепада давления`

`(с вентиляционными клапанами)`

Use `отн. плотность` instead of `относительная плотность` where space-constrained.

Fixed programmatic font for PNG label replacement:

`/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf`

If unavailable, stop and report. Do not silently substitute.

## 16. HTML Rules

Final HTML:

- Russian clean copy;
- hidden original opened by click;
- links work as links;
- no service/debug data as visible clean text;
- approved Figure objects only;
- object traceability retained in JSON.

Working/review HTML may include:

- original/OCR;
- bbox preview;
- cleaned-only preview;
- translated preview;
- overlays;
- QA warnings;
- protected/manual-control lists;
- service metadata.

Working/review HTML must not become final clean HTML.

## 17. PDF Rules

Final PDF:

- Russian clean copy only;
- no English OCR/review column;
- no raw OCR/debug/JSON/TODO;
- flow layout by Russian text;
- A4 portrait by default;
- margins: top 1 cm, bottom 1 cm, left 2 cm, right 1 cm;
- main text Times New Roman 12 pt;
- headings Times New Roman 14 pt bold;
- tables 12 pt, 11 pt allowed when required;
- footnotes 8 pt;
- figures and captions must not split across pages;
- internal PDF links must target final PDF anchors.

Run approved PDF checklist before final delivery.

## 18. Stage 4 Packaging

Do not build cumulative ZIPs.

Use overlay/diff ZIPs for:

`C:\Downloads\API 551`

Each overlay ZIP contains:

- updated root `index.html`;
- updated root `catalog.json`;
- folders only for new/changed figure objects.

Do not include source PDF in overlay ZIPs.

Figure title/caption source PDF link:

`file:///C:/Downloads/API%20551/API%20551%202016%20(R2024).pdf#page=N`

Do not use old path through:

`C:/Users/verendeev-as/Downloads`

## 19. Required Figure Folder Contents

Each accepted/changed figure folder must contain:

- final PNG;
- source crop PNG;
- `figure_NNN.out.html`;
- `figure_NNN.object.html`;
- `figure_NNN.object.json`;
- caption/service JSON when needed.

`out.html` is clean export only.

`object.html` is review/service view.

## 20. ZIP QA

Before delivery:

- ZIP opens;
- `testzip` reports no errors;
- no Git LFS pointer files as content;
- PDF is not included;
- no broken image links;
- no old PDF paths;
- required figure files exist;
- `out.html` contains no service markers;
- statuses match catalog and object JSON.

## 21. Chat Delivery Rule

If a file is formed, chat response contains only:

1. file link;
2. short summary;
3. short verification report if needed.

Do not paste large file contents, previews, HTML, JSON, CSV, internal reports, or tables.

## 22. Current Stage 4 Status Snapshot

As of current working memory:

- total figures: 69;
- accepted: 19;
- changed/review: 1;
- not accepted: 49.

Accepted figures:

`1, 4, 9, 14, 16, 18, 23, 25, 28, 30, 31, 33, 37, 46, 48, 50, 52, 62, 66`

Figure 51:

- status `измененно_2026-06-17`;
- not accepted;
- rebuild from clean source crop if continued.

This snapshot must be checked against the latest catalog before production.

## 23. Active Figure-Specific Notes

Figure 15:

- do not miss `Total vacuum (zero or absolute)`, `Absolute`, `Barometric range`, and atmospheric pressure text.

Figure 37:

- vertical fragments like `level` are not independent when part of `Normal working level`.

Figure 46:

- `Area to avoid` and `Preferred tap locations` must be accounted for.

Figure 47:

- mixed object, not note-only;
- `notes_removed` does not mean no callouts;
- required callouts include `From process top`, `Max liquid level`, and `To instrument`.

Figure 48:

- accepted;
- parent-block bbox and tight clearing policy apply.

Figure 51:

- not accepted;
- wrong source/layer issue suspected.

Figure 62:

- visually check split combined OCR candidates.

Figure 66:

- reconstructed table with drawing cell.

## 24. Source Cleanup Decision

After this consolidated TZ is uploaded and accepted:

Keep active in `API 551/Source`:

- this consolidated TZ;
- `TZ_API551_translation_project_RU.md` as baseline/restart;
- `API551_RULES_SYSTEMATIZED_v5_CLEAN_2026-06-16.zip`;
- `API551_STAGE4_CONSOLIDATED_CURRENT_POLICIES_2026-06-18.zip`;
- original PDF;
- master CSV;
- Stage2 replacement rules;
- Stage2 reference ZIP;
- Stage3 source ZIP;
- control build ZIP;
- source manifest JSON.

Move out of active Source:

- `TZ_API551_translation_project_RU_CURRENT_2026-06-16.md`;
- `TZ_API551_STAGE4_FIGURE_OBJECTS_CURRENT_2026-06-16.md`.

Keep baseline:

- `TZ_API551_translation_project_RU.md`

Reason: baseline/restart and mandatory historical context.

Do not delete mandatory sources.

## 25. Next Operational Step

After upload and source cleanup:

1. Verify `API 551/Source`.
2. Verify mandatory sources.
3. Continue Stage 4 from current figure status.
4. Process only non-accepted or explicitly reopened figures.
5. Deliver overlay/diff ZIPs, not cumulative packages.
