---
name: api551-stage4-figure-operator
description: Use when creating, reviewing, or correcting API 551 Stage 4 composite Figure objects.
---

# API551 Stage 4 Figure Operator

Use after `api551-source-gate` passes.

## Purpose

Reproduce the accepted Stage 4 style instead of re-solving the task from scratch.

## Source hierarchy

1. Accepted Figure object and explicitly approved user corrections for that Figure.
2. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`.
3. `.codex/skills/api551-stage4-figure-operator/LABEL_PLACEMENT_AND_CLEARING_STRATEGY_CURRENT.md` for label cleanup, placement, callout frames, and protected-geometry strategy.
4. `source/TZ_API551_PROJECT_STAGE4_CONSOLIDATED_CURRENT_2026-06-18.md`.
5. `source/api551_approved_label_master_v1.csv`.
6. Source crop and original PDF visual reference.
7. OCR only as a checking aid, never as source of truth.

## Current Stage 4 status to verify

Do not trust this list without checking current catalog/manifest, but use it as the known baseline to verify:

- total Figures: 69;
- accepted: 19;
- changed/review: 1;
- not accepted: 49;
- accepted Figures: 1, 4, 9, 14, 16, 18, 23, 25, 28, 30, 31, 33, 37, 46, 48, 50, 52, 62, 66;
- Figure 51 is not accepted; it remains changed/review.

## Accepted examples to study first

- Figure 37: vertical text direction and rotated Russian text.
- Figure 48: parent-block logic and tight clearing.
- Figure 62: close labels separated, not merged.
- Figure 46: zone labels such as `Area to avoid` and `Preferred tap locations`.
- Figure 28: multiline label handling and `отн. плотность` terminology.
- Figures 14, 18, 33, 52, 66: standard accepted assembly style.

## Anti-example

Figure 51 is not accepted. Do not use it as an approved model. If rebuilding it, start from the clean source crop/original, not from an old final PNG.

Figure 51 also shows why cleanup and placement must be separated: leftover source letters, oversized callout boxes, clipped Russian text, and damaged leader lines are all defects.

## Label placement and clearing

Before changing on-image labels, apply `.codex/skills/api551-stage4-figure-operator/LABEL_PLACEMENT_AND_CLEARING_STRATEGY_CURRENT.md`.

Core requirements:

1. identify all source text components before clearing;
2. keep cleanup zones independent from translation placement zones;
3. preserve leader lines, arrows, drawing geometry, dimensions, borders, and protected symbols;
4. for boxed callouts, size the frame from the actual rendered Russian text;
5. keep the frame side attached to the leader line fixed;
6. expand the frame only away from the leader line;
7. recompute frame geometry whenever text, line breaks, font, or font size changes.

## Composite object order

A Stage 4 Figure object must be assembled in this order:

1. final image PNG;
2. table `Надписи`, if needed, without a separate table number/title;
3. table `Примечания`, if needed, in the form `Примечание X | Суть`;
4. caption/title.

`out.html` must be clean export content. `object.html` may contain service/review diagnostics.

## Protected content

Do not translate, erase, or reinterpret:

- single letters;
- alphanumeric tags;
- NOTE headers and note references;
- chemical symbols;
- dimensions;
- formulas;
- symbolic IDs.

## Work sequence

1. Locate Figure in `catalog.json` and `workspace/figures/`.
2. Open source crop, current final PNG, object metadata, `out.html`, and `object.html` if present.
3. Compare labels, notes, caption, and strategy against active rules and approved label master.
4. Classify the object:
   - title-only;
   - labels on image;
   - labels moved to table;
   - note/table reconstruction;
   - mixed object.
5. Do not modify accepted Figures unless the task explicitly requires it.
6. For new/changed Figures, use a small batch, normally one to three Figures.
7. Produce a branch/PR or diff-only ZIP, not a cumulative package.

## Required report

For each batch, report:

- Figure IDs changed;
- source gate result;
- files touched;
- checks passed;
- items requiring manual visual review.

Do not paste large HTML, JSON, CSV, or image previews into chat.
