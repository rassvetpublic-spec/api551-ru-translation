# API 551 Stage 4 - Figure 47 OCR Audit and Strategy Fix

Date: 2026-06-16

## Status

Figure 47 is not a simple Note-only candidate.

The previous Batch 05 review classification is superseded until Figure 47 is rebuilt or verified as a mixed object with translated callouts.

## What Went Wrong

The incorrect classification relied on:

- the master row group showing many protected `note_reference` entries;
- the Stage3 asset name `fig47_notes_removed.png`;
- the assumption that removing/restoring the note block meant there were no remaining translatable on-image labels.

That assumption was wrong. The asset name only indicates that the lower note block was removed from the drawing crop. It does not prove that all embedded callouts inside the drawing are already translated or absent.

## OCR Evidence

OCR/visual check of the original PDF crop for API page 167 / PDF page 175 found three translatable on-image callouts:

- `From process top` -> `От верха технологического аппарата`
- `Max liquid level` -> `Максимальный уровень жидкости`
- `To instrument` -> `К прибору`

OCR/visual check of the Stage3 `notes_removed` crop also still sees the English callouts. Therefore the current crop is not export-ready for Stage 4.

## CSV Cross-check

The master CSV already contains approved rows for these callouts:

- Figure 47, `block-002`, `callout`, `keep_existing_accepted_replacement`
- Figure 47, `block-009`, `callout`, `keep_existing_accepted_replacement`
- Figure 47, `block-011`, `callout`, `keep_existing_accepted_replacement`

The previous strategy failed not because the CSV lacked the data, but because the Figure was classified from the note-restoration path before OCR/visual verification of the drawing body.

## Corrected Classification

Figure 47 is a mixed Stage 4 object:

- drawing cell: needs translated/verified callouts;
- note references: protected/manual-control, not translated as ordinary labels;
- restored note table: below drawing, without a separate table title;
- caption: final row at the bottom.

## Strategy Fix

Before any Figure is accepted as "no translatable labels" or "simple Note-only":

1. Render or load the original PDF crop for the Figure.
2. Run OCR/text-layer check against the original crop.
3. Run OCR/visual check against the Stage2/Stage3 production crop being used.
4. Compare detected English label text against the master CSV.
5. If any approved `callout` rows exist, the Figure cannot be processed as simple Note-only unless the production image is visually verified to contain the approved Russian replacements.

This check is mandatory even when the asset name says `notes_removed`, `caption_only`, `accepted`, or similar.

## Immediate Action

- Remove Figure 47 from the simple Note-reference candidate list.
- Do not include the current Figure 47 Batch 05 review in cumulative approved output.
- Reprocess Figure 47 only through the mixed-object workflow.
