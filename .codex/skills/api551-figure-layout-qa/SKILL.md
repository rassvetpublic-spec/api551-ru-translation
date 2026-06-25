---
name: api551-figure-layout-qa
description: Use to check API 551 Stage 4 figure label placement, cleanup, protected content, and visual QA before delivering candidates.
---

# API551 Figure Layout QA

Use for every changed Figure before delivery.

## Core rule

The image should look like a technical drawing with translated labels, not like a debug overlay or a patched screenshot.

## Placement rules

- Distinguish `cleanup_rect` from `text_background_rect`.
- `cleanup_rect` must fully remove the original English label.
- `text_background_rect` should be tight around the Russian text.
- Do not paint large unnecessary white rectangles.
- Preserve leader lines, arrows, drawing geometry, and table borders.
- Expand placement left/right when free space exists.
- If both left and right are blocked, use vertical or multiline placement.
- Do not split words.
- Keep long parenthesized fragments together on their own line when needed.

## Cleanup and protected-geometry rules

Apply `.codex/skills/api551-stage4-figure-operator/LABEL_PLACEMENT_AND_CLEARING_STRATEGY_CURRENT.md` before delivery.

Required checks:

- cleanup zones are independent from translation placement zones;
- no source-text fragments remain after replacement;
- isolated leftover source letters are defects;
- leader lines, arrows, drawing geometry, dimensions, table borders, hatching, and protected symbols are intact;
- long thin dark elements are treated as protected drawing geometry unless proven to be source text;
- text touching a leader line was removed component-by-component, not by broad erasure of the line area.

## Boxed callout QA

For boxed callouts:

- the replacement stays boxed when the source is boxed;
- frame size is derived from the actual rendered Russian multiline text;
- the longest line fits with minimal padding;
- no Russian letter is clipped;
- the frame side attached to a leader line remains fixed;
- the frame expands away from the leader line only;
- the frame touches the leader line where the source did;
- the frame does not cross or erase the leader line.

If text, line breaks, font size, or line spacing changes, frame geometry must be recomputed before delivery.

## Parent-block rule

If a label is part of a multiline original block, treat the whole block as the placement parent.

Do not anchor the Russian text to the bbox of a single OCR fragment. Figure 48 is the accepted model for this rule.

## Vertical text rule

Vertical source text must become rotated Russian text, not stacked horizontal words.

Determine direction by checking which rotation makes the original text readable. Apply the same readable direction logic to the Russian translation. Figure 37 is the accepted model.

## Close-label rule

Nearby labels are not automatically one label. Confirm meaning before merging. Figure 62 is the accepted model.

## OCR policy

OCR may be used only to detect possible missed old English text or accidental leftovers.

OCR must not override:

- approved label master;
- accepted Figure object;
- consolidated policies/rules;
- source crop visual check.

## Required checks

Before delivery, verify:

1. all approved labels are present;
2. no protected content was translated;
3. no approved label was merged incorrectly;
4. original English is cleared where translation was placed;
5. no leftover source text fragments remain;
6. drawing geometry is preserved;
7. boxed callouts are compact, text-driven, and leader-line-safe;
8. final PNG, source crop, object metadata, `out.html`, and `object.html` remain consistent;
9. `out.html` is clean export content;
10. `object.html` is review/service content only;
11. `catalog.json` and root `index.html` are updated only when the batch requires it.

## Delivery rule

Deliver either:

- a PR branch; or
- a diff-only ZIP.

Do not deliver cumulative ZIPs unless explicitly requested. Do not show image/HTML previews in chat.
