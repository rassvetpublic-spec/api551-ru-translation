# Stage 4 Operator Playbook — API 551

This playbook captures the working method that produced accepted Stage 4 Figure objects. It is not a replacement for the active sources. It tells an operator how to use them.

## Start every session

1. Run the source gate skill: `.codex/skills/api551-source-gate/SKILL.md`.
2. Read active source files from `source/` only.
3. Treat `archive/` as traceability/evidence, not generation input.
4. Verify the current accepted/review status from `catalog.json`, workspace objects, and active policy files.

## Do not start from OCR

OCR is a checking tool only. It is useful for finding old English leftovers or missed labels. It is not a source of truth for labels, translations, or acceptance.

## Golden examples

- Figure 37 — vertical label direction.
- Figure 48 — parent block placement and tight clearing.
- Figure 62 — close labels remain separate when semantically separate.
- Figure 46 — zone labels and short technical label placement.
- Figure 28 — multiline label handling and terminology.
- Figures 14, 18, 33, 52, 66 — normal accepted assembly style.

## Anti-example

Figure 51 is not accepted. It must not be used as an approved style model. Its problem was old-layer/source contamination. A rebuild must start from clean source crop/original.

## High-risk failure modes

- treating OCR as truth;
- using old bbox directly;
- translating protected tags or single-letter symbols;
- merging distinct nearby labels;
- anchoring a multiline translation to a single fragment bbox;
- using horizontal stacked text for a vertical original label;
- covering drawing geometry with large cleanup rectangles;
- changing accepted Figures without explicit reason.

## Batch discipline

Process one to three Figures per candidate batch. After generation, run layout QA before delivery.

## Delivery discipline

Return only a branch/PR or a diff-only ZIP, plus a short summary and short validation report. Do not paste large generated content into chat.
