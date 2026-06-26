# Figure 51 reopened candidate handoff

Date: 2026-06-26

Scope: API 551 Stage 4 Figure 51 candidate after explicit user statement that Figure 51 is not accepted.

Status decision:
- Figure 51 is treated as reopened / review candidate.
- Candidate status: `измененно_2026-06-26`.
- Do not promote to accepted without explicit user approval.

Source basis:
- Original visual source: `API 551 2016 (R2024).pdf`, PDF page 184, API page 176.
- Approved label register: `api551_approved_label_master_v1.csv`.
- Active policy: `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`.
- Universal addendum: `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`.

R02 correction:
- Problem found in R01: the top clearance callout used a 3-line layout.
- Non-compliance: the line wrap did not follow the approved master wrap for block-002 and made the last line too wide toward the leader-line zone.
- Fix: restored the approved 4-line wrap and recalculated placement geometry with compact text left of the leader line.
- Final top wrap:
  - `Предусмотреть свободное`
  - `пространство для устройства`
  - `прочистки 760 мм (30″) или`
  - `более`

Generated local artifact:
- ZIP: `API551_STAGE4_FIG51_CANDIDATE_R02_2026-06-26.zip`.
- ZIP SHA-256: `5f6f97359c701ced688fcdd1b2184f9672dd683ab1eee917474734cbf1d5083a`.
- ZIP size: 127354 bytes.
- ZIP members: 8.

Generated figure assets inside ZIP:
- `workspace/figures/051/figure_051.png`.
- `workspace/figures/051/figure_051.source_crop.png`.
- `workspace/figures/051/figure_051.out.html`.
- `workspace/figures/051/figure_051.object.html`.
- `workspace/figures/051/figure_051.object.json`.
- root `catalog.json`.
- root `index.html`.
- `docs/run-logs/figure_051_candidate_qa.json`.

Verification summary:
- ZIP opened successfully.
- `testzip` passed.
- Extracted `workspace/figures/051/figure_051.png` was inspected from the final ZIP.
- PNG SHA-256: `c0636e2936bab434d26972c75da22fd8b49d6968b6f6cbc493ed4478e34735db`.
- PDF was not included in ZIP.
- `out.html` has no service markers and no absolute Windows PDF path.

Important note:
- Current `main` previously promoted Figure 51 to accepted on 2026-06-26.
- This handoff records the user's explicit reopening instruction and the corrected local candidate ZIP hash for review.
