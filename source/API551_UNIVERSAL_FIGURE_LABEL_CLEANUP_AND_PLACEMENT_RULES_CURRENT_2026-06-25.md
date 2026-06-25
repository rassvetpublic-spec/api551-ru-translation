# API551 Universal Figure Label Cleanup and Placement Rules

Status: CURRENT active universal addendum for Stage 4+.

Date: 2026-06-25.

Scope: all API 551 Figure objects, all Figure label replacement strategies, all programmatic PNG/HTML/JSON reconstruction steps, unless a stricter figure-specific approved rule overrides this file.

Authority: this file supplements `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`. If a conflict is detected, stop and report the source, role, conflict, and risk before production work.

Origin: rules and strategies consolidated from the active discussion of Figure label cleanup, boxed callouts, leader-line protection, and replacement text fitting. Previous temporary/local workflow items `A10`, `A11`, `A16`, and `A19` are intentionally excluded and must not be restored as universal rules.

## 1. General constraints

1.1. Image generation, generative image editing, redrawing by imagination, and AI-generated replacement graphics are prohibited.

1.2. Figure work must be performed only by programmatic operations on existing project assets such as PDF-derived crops, PNG, HTML, JSON, CSV, ZIP, and scripts.

1.3. Do not invent missing drawing geometry, symbols, arrows, dimensions, or equipment details.

1.4. Do not change approved translations without a traceable reason.

1.5. Do not use OCR as source truth. OCR may only be used as auxiliary diagnostics.

1.6. Do not narrow or rewrite the approved master label registry based on OCR.

1.7. Do not output large scripts, PNG previews, HTML previews, JSON/CSV dumps, or debug payloads into chat. Deliver files and concise verification summaries.

1.8. A script or automation must not perform `git add`, `commit`, `push`, merge, or branch deletion unless explicitly requested for that operation.

1.9. A script or automation must not delete project data without explicit permission and a stated recovery path.

## 2. Sources and figure state

2.1. Rebuild or repair a Figure from the cleanest available current project source, not from an already-damaged translated PNG.

2.2. If the current source crop is contaminated, do not mask over the contamination as if it were clean source. Locate a clean source or stop and report the source problem.

2.3. Before treating a file as an image/source asset, verify that it is not a Git LFS pointer or other placeholder.

2.4. For not-accepted Figures, visual truth comes from the original PDF/source crop plus the approved translation register.

2.5. A Figure remains `review`/`changed` until explicit user approval. A script must not automatically promote a Figure to `accepted`.

2.6. Figure-specific rules may refine these rules, but must not weaken source preservation, data-loss prevention, or protected-graphics requirements.

## 3. Separation of cleanup and placement

3.1. First identify the exact source label/text to be replaced.

3.2. Then identify the approved Russian translation.

3.3. Then determine the replacement strategy: free text, boxed callout, table cell, caption, note/reference, vertical label, protected original, or composite reconstruction.

3.4. The source-text cleanup zone and the replacement-text placement zone are different objects.

3.5. Do not use the replacement bounding box as the cleanup zone for the source text.

3.6. Do not use the cleanup zone as the placement zone for the replacement text.

3.7. Cleanup geometry must be derived from the actual source text components that need removal.

3.8. Placement geometry must be derived from the selected translation, its line breaks, font, size, and the visual constraints of the drawing.

3.9. Any change to translation wording, line breaks, font, font size, line spacing, or callout strategy invalidates the previous placement geometry and requires recalculation.

## 4. Source-text cleanup

4.1. The original source label must be removed completely.

4.2. Remaining isolated source letters, partial glyphs, fragments, punctuation, or ghost pixels are defects.

4.3. Cleanup should operate on source text components whenever possible, not on a coarse rectangle covering unrelated graphics.

4.4. Cleanup must include all source text fragments that belong to the removed label, including separated components to the left, right, above, or below the main text mass.

4.5. Cleanup must not damage leader lines, arrows, dimension lines, equipment outlines, chart/grid lines, frames, symbols, or neighboring drawing elements.

4.6. Long thin dark connected components are protected graphics by default unless proven to be text.

4.7. If text touches or overlaps a protected graphic element, clear the text component selectively rather than filling the whole shared area.

4.8. If reliable separation of source text and protected graphics is not possible, stop and escalate to manual review instead of risking drawing damage.

4.9. Do not repair avoidable cleanup damage by rough redrawing. The preferred strategy is to avoid damaging protected graphics in the first place.

## 5. Protected graphics

5.1. Leader lines are protected graphics.

5.2. Arrows and arrowheads are protected graphics.

5.3. Equipment outlines, vessel/nozzle/pipe contours, instrument outlines, panels, and schematic symbols are protected graphics.

5.4. Dimension lines, extension lines, tick marks, and dimension values not being translated are protected graphics.

5.5. Tables, cell borders, note frames, callout boxes, and source drawing frames are protected graphics unless the approved strategy explicitly reconstructs them.

5.6. Technical marks that are not part of the removed source text must be preserved.

5.7. Any cleanup, mask, patch, or overlay must be minimal and justified by the target source text.

## 6. Boxed callouts and leader-line callouts

6.1. If the source label is a boxed callout, the translated label must remain a boxed callout unless an approved figure-specific rule says otherwise.

6.2. The box/frame is part of the callout semantics and must not be removed when it communicates the callout structure.

6.3. The translated box must be compact and visually proportional to the source drawing.

6.4. Box padding around text should normally be approximately 3 to 5 px, adjusted only when readability or source style requires it.

6.5. The box must not be oversized merely because the source cleanup area is large.

6.6. If the source callout box touches a leader line, the replacement box should also touch the corresponding leader line.

6.7. The replacement box must touch the leader line without crossing, covering, or erasing it.

6.8. The box side adjacent to the leader line is fixed by the leader-line contact point.

6.9. The box may expand only away from the leader line.

6.10. If the leader line is on the right side of the box, expand the box leftward.

6.11. If the leader line is on the left side of the box, expand the box rightward.

6.12. If the leader line is above or below, expand the box away from that side while preserving the contact side.

6.13. Draw the translated box after source-text cleanup.

6.14. Do not use the translated box as the source-text cleanup mask.

## 7. Text fitting inside boxes and callouts

7.1. Select the translation line-break strategy before calculating the box.

7.2. The line-break strategy includes exact text, number of lines, font, font size, line spacing, and alignment.

7.3. Measure every rendered line in the selected font and size.

7.4. Determine box width from the longest rendered line plus padding.

7.5. Determine box height from total rendered line height, line spacing, and padding.

7.6. If a line is clipped, the box width/height is wrong and must be recalculated.

7.7. If text, line breaks, font, font size, or line spacing change, repeat the measurement and box sizing.

7.8. For multiline labels, the longest line controls minimum box width.

7.9. The final text must not lose letters, endings, units, punctuation, or symbols.

7.10. Translation text should be visually centered within the box unless source layout or figure-specific rules require another alignment.

7.11. If text does not fit compactly, first test alternative line breaks, then test acceptable font-size reduction. Do not silently truncate text.

7.12. Iteration continues until the best variant satisfies all fit, cleanup, and protected-graphics conditions.

## 8. Multiline label strategy

8.1. Multiline translation is not a fixed string dump; it is a layout decision.

8.2. Line breaks must preserve meaning and technical readability.

8.3. Line breaks must not create ambiguous units or split critical numeric expressions incorrectly.

8.4. The longest line must be remeasured after every line-break change.

8.5. Height must account for all lines, interline spacing, and padding.

8.6. A visually good multiline label must still be checked for hidden clipping at glyph edges.

## 9. Verification criteria

9.1. Verify that the original source text is fully removed.

9.2. Verify that no isolated source glyphs or text fragments remain.

9.3. Verify that the Russian translation is complete and technically correct.

9.4. Verify that no translated letters are clipped.

9.5. Verify that leader lines, arrows, outlines, dimensions, frames, and neighboring drawing elements are not damaged.

9.6. Verify that boxed callouts remain compact and visually aligned with the original callout logic.

9.7. Verify that leader-line contact is preserved where applicable.

9.8. Verify that the box touches but does not cross the leader line.

9.9. Verify that only intended Figure files changed.

9.10. If unexpected files changed, stop and report before proceeding.

## 10. Prohibited strategies

10.1. Do not place free text when the source uses a required boxed callout.

10.2. Do not size a replacement box from a large source cleanup area.

10.3. Do not treat placement and cleanup as the same operation.

10.4. Do not expand a box into or through its leader line.

10.5. Do not erase protected graphics during text cleanup.

10.6. Do not leave source-text remnants behind a visually acceptable translation.

10.7. Do not choose box size before finalizing the text layout.

10.8. Do not change line breaks or font and reuse an old box size.

10.9. Do not clip translation letters to preserve a smaller box.

10.10. Do not improve a label at the cost of damaging the drawing.

## 11. Universal workflow

11.1. Identify the source label and its visual components.

11.2. Confirm the approved translation.

11.3. Select the replacement strategy.

11.4. Detect protected graphics around the label.

11.5. Compute a safe cleanup operation for source text only.

11.6. Select translation line breaks, font, size, and spacing.

11.7. Measure all rendered translation lines.

11.8. Compute the replacement placement geometry from the measured translation.

11.9. For boxed/leader-line callouts, fix the leader-line side and expand the box away from the leader line.

11.10. Clear source text without damaging protected graphics.

11.11. Draw the replacement frame/box if required.

11.12. Draw the translated text.

11.13. Verify cleanup, text completeness, geometry, protected graphics, and changed files.

11.14. Keep the Figure in review until explicit approval.
