# API551 Label Placement and Clearing Strategy

Status: CURRENT, 2026-06-25.

Scope: applies to all API 551 Stage 4 Figure objects unless a figure-specific accepted object or explicit user correction overrides it.

This file records the placement and cleanup strategy derived from the Figure 51 correction discussion and generalizes it for all figures.

## 1. General restrictions

1. Do not use image generation or generative image editing.
2. Do not invent or redraw technical graphics.
3. Work only from existing project source assets and programmatic edits.
4. Do not paste script listings, large JSON, HTML, CSV, debug output, or image previews in chat.
5. For local correction scripts, deliver the `.ps1` file and the run command; do not paste the script body in chat.
6. Local scripts must not run `git add`, `git commit`, or `git push`.
7. Local scripts must not modify `main` directly.
8. Local scripts must not delete project data without explicit approval.
9. Local scripts should resolve the Windows Downloads folder through the system known folder, not a hard-coded user-specific path.
10. Paths with spaces must be quoted.

## 2. Source and status rules

1. Work from the current source crop and original PDF visual reference, not from an already damaged translated PNG.
2. If the source crop is contaminated, stop and locate a clean source rather than patching over the contaminated layer.
3. Verify that required binary assets are real files and not Git LFS pointer text.
4. For unaccepted figures, do not promote the result to `accepted` automatically.
5. OCR is only a detection/checking aid and must not override the approved label master, accepted objects, or current policy.
6. Approved translations must not be changed without an explicit reason.

## 3. Placement sequence

For every translated label:

1. Identify the exact source text and all visible source text components.
2. Identify the approved Russian translation.
3. Choose the placement type: free text, boxed callout, table cell, caption, protected/no-change item, or manual-control item.
4. Determine the source text cleanup zone independently from the translation placement zone.
5. Determine the translation placement zone independently from the cleanup zone.
6. Clear source text components safely.
7. Place the Russian translation.
8. Verify completeness, fit, and drawing integrity.

The cleanup rectangle and the translation rectangle are different concepts. Never use one as an automatic substitute for the other.

## 4. Source text cleanup

1. The original English label must be fully removed when it is replaced on-image.
2. Leftover letters or fragments of source text are defects.
3. Cleanup must target source text components, not broad drawing areas.
4. Cleanup must search for detached components belonging to the same source label, including fragments left, right, above, or below the main text block.
5. Do not erase leader lines, arrows, drawing lines, equipment outlines, dimensions, table borders, hatching, or protected symbols.
6. Long thin dark components are protected drawing geometry unless proven to be text.
7. If text touches or crosses a leader line, remove only the text components and preserve the line.
8. If text and graphics cannot be separated reliably, mark the item for manual control rather than damaging the drawing.

## 5. Boxed callouts and leader lines

1. If the source label is a boxed callout, the Russian label must remain a boxed callout unless the user explicitly approves a different treatment.
2. The callout frame is part of the drawing semantics.
3. The frame must be compact and must not become a large white patch.
4. The frame-to-text padding should normally be 3 to 5 pixels.
5. If the source frame touches a leader line, the replacement frame must touch the leader line.
6. The frame must touch the leader line without crossing or erasing it.
7. The side of the frame attached to the leader line is fixed.
8. Frame expansion is allowed only away from the leader line.
9. If the leader line is on the right, expand the frame leftward.
10. If the leader line is on the left, expand the frame rightward.
11. Draw or preserve the frame after source-text cleanup.
12. Do not use the frame area as the source-text cleanup zone.

## 6. Frame sizing and multiline text

1. First choose the Russian text, line breaks, font, font size, and line spacing.
2. Measure every rendered line.
3. Determine frame width from the longest rendered line.
4. Add only the minimum padding needed, normally 3 to 5 pixels per side.
5. Determine frame height from total rendered line height plus minimal vertical padding.
6. If the text does not fit, first try a better line break.
7. If line breaks are insufficient, reduce font size within readability limits.
8. Every time text, line breaks, font size, or spacing changes, recompute the frame from the longest line.
9. Iterate until the result satisfies all conditions: complete text, no clipped letters, compact frame, preserved leader contact, no line crossing, full source-text removal, and intact graphics.

## 7. Protected graphics

During cleanup and placement, preserve:

1. leader lines;
2. arrows;
3. equipment outlines;
4. drawing geometry;
5. dimensions and values;
6. table borders;
7. hatching;
8. formulas and protected technical notation;
9. one-letter or symbol-only protected labels unless explicitly identified as source text being replaced.

Do not repair damaged protected geometry by rough redrawing if a safer cleanup strategy can avoid damaging it in the first place.

## 8. QA checks before delivery

Before a figure candidate is delivered:

1. all approved labels have explicit outcomes;
2. replaced English text is fully removed;
3. no leftover source-text fragments remain;
4. Russian text is complete and not clipped;
5. frame sizes are compact and text-driven;
6. callout frames touch leader lines where the source did;
7. callout frames do not cross or erase leader lines;
8. leader lines, arrows, dimensions, borders, and drawing geometry are preserved;
9. accepted figures are not modified unless explicitly reopened;
10. changed/review figures are not marked accepted automatically.

## 9. Known anti-patterns

Do not:

1. place free text when the source is a boxed callout;
2. use a large cleanup area as the translation frame;
3. use the translation frame as the cleanup zone;
4. expand a frame toward or through a leader line;
5. erase leader lines during source-text cleanup;
6. leave a detached source-text letter such as `P` behind;
7. change line breaks without recomputing frame size;
8. accept clipped Russian text;
9. make a visually neat translation by damaging the technical drawing.

## 10. Universal formula

For every label replacement:

1. identify source text and components;
2. identify approved translation;
3. classify the placement type;
4. clear source text components safely;
5. calculate translation geometry from actual rendered text;
6. preserve protected drawing geometry;
7. render translation;
8. verify visually and through object metadata.
