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

## 7. Mandatory leader-line callout rendering gate

7.1. Any translated on-image label connected with a leader line, pointer line, arrow, callout pointer, callout box, or local callout explanation must be classified as a `leader_line_callout`, even when the master CSV block type is only `callout` or `dimension_or_callout`.

7.2. Free-floating replacement text is prohibited for `leader_line_callout` labels unless a figure-specific approved rule explicitly allows it.

7.3. Default `leader_line_callout` rendering must use a thin gray frame. The frame interior must remain white or transparent unless a figure-specific approved rule requires a fill.

7.4. The frame must be compact and text-driven, with normal padding of approximately 3 to 5 px.

7.5. The frame must be placed as close as practical to the corresponding leader line or source callout anchor.

7.6. If the source callout touched a leader line, the replacement frame must also touch the corresponding leader line whenever this can be done without damaging protected graphics.

7.7. If exact contact would cross, cover, or erase a leader line, arrow, contour, dimension line, or other protected graphic, use the smallest safe gap and record that exception in object JSON QA notes.

7.8. The replacement frame must not overlap, cross, erase, or visually merge with leader lines, arrows, equipment outlines, pipe/nozzle contours, dimension lines, table borders, or other protected graphics.

7.9. Gray-frame rendering is required for every translated leader-line callout before review ZIP delivery. If any label fails this rule, do not deliver the ZIP; stop and report the failing label and reason.

7.10. Before packaging a Figure review overlay, run per-label QA for every translated on-image label:

- source block id or local label id;
- original text;
- approved Russian text;
- selected strategy;
- source cleanup complete;
- gray frame present when strategy is `leader_line_callout`;
- frame close/contact relation to leader line checked;
- protected graphics intersection is none;
- no free-floating callout text remains.

7.11. If a callout label cannot be placed in a gray frame near its leader line without damaging protected graphics, stop and escalate to manual review rather than delivering an approximate layout.

## 8. Figure 2 — Thermowell Installation specific rule

8.1. In Figure 2, all translated on-image labels except protected pure dimensions must be rendered as compact gray-framed leader-line callouts.

8.2. `6.35 mm (0.250 in.)` and `Sheathed element` must be treated as one two-line callout in one thin gray frame: `6,35 мм (0.250″)` on the first line and `Элемент в оболочке` on the second line.

8.3. The Figure 2 callout frames must be as close as practical to their corresponding leader lines and must not overlap leader lines, pipe outlines, thermowell outlines, flange outlines, dimension lines, note references, or other protected drawing elements.

8.4. `120 mm (5 in.) TYP` remains a protected pure linear dimension and must not be translated unless the user explicitly reopens that decision.

8.5. Figure 2 may not be delivered as a review overlay if any translated callout is free-floating text without a thin gray frame.
