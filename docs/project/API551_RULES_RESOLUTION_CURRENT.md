# API551 Rules Resolution Current

Status: CURRENT workflow for finding applicable Figure rules.

## 1. Default command

```powershell
.\tools\api551\api551.ps1 rules-for -Figure 003
```

The command writes:

```text
reports/source_gate/figure_003_rules_report.md
reports/source_gate/figure_003_work_order.json
```

Reports are generated working outputs and must not replace CURRENT rules.

## 2. Rule priority

Use this order:

1. system / safety / developer instructions;
2. API 551 project instructions;
3. `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`;
4. `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`;
5. `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`;
6. accepted Figure object for the same Figure, if the Figure is already accepted;
7. figure-specific notes in CURRENT policy and `tools/api551/rules/figure_rule_map.json`;
8. current chat instruction for the specific task.

If sources conflict, stop and report the conflict. Do not silently choose an older rule.

## 3. Accepted Figure rule

For accepted Figures, the accepted object has priority for that Figure. Do not change label count, translation, placement, reconstruction decision, or status without explicit reopening.

## 4. Unaccepted Figure rule

For unaccepted Figures, visual truth comes from the original PDF/PDF-derived source crop, and label/translation truth comes from `source/api551_approved_label_master_v1.csv` plus applicable CURRENT rules.

OCR is diagnostics only. It cannot replace the approved label master or narrow the master CSV.
