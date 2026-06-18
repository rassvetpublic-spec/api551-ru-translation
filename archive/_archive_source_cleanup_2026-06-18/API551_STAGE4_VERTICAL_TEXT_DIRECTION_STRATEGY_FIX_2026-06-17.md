# API 551 Stage 4 - vertical text direction strategy fix

Status: approved operational correction, 2026-06-17.

For every vertical source label, do not infer reading direction from bbox shape alone. Crop the original label zone and test two normalizations: rotate page +90 and rotate page -90. The normalization that makes the original label readable defines the source reading direction. Place the Russian translation with the inverse page rotation so that it becomes readable under the same normalization as the source.

The rule applies to multiline vertical labels exactly as to horizontal multiline labels: group fragments first, then determine the parent block direction, then place the full translated block. A translated vertical label may not start from a lowercase fragment or middle fragment unless the approved source text itself does so.

Figure 37 correction: `Normal working level` is readable after clockwise page rotation; the Russian translation must therefore be counterclockwise on the page.
