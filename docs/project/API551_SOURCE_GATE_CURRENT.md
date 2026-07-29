# API551 Source-Gate Current

Status: CURRENT source-gate workflow for Stage 4+ and Stage 5.

## Command

```powershell
.\tools\api551\api551.ps1 source-gate
```

CI: `python3 tools/api551/api551.py source-gate --ci`.

## Verification

1. repository and mandatory source structure;
2. Stage 5 CURRENT specification;
3. exact manifest/source model and CURRENT rules;
4. catalog/index/handoff status sync;
5. `69/69 accepted`, `changed: 0`, `not_accepted: 0`;
6. handoff validity against its schema;
7. config/handoff/schema branch-policy sync;
8. current branch against exact/prefix allowlists;
9. CURRENT docs, Stage 5 markers and forbidden control characters;
10. repo-local tooling and LFS-safe state;
11. archive/snapshot exclusion from production authority.

## Branch policy

```text
stable: main
default work: task/*
base: current main
```

A descriptive sentence must never be treated as a literal branch name.

## Conflict

```text
source -> role -> problem -> risk -> required decision
```

## Current rules

- `source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md`
- `source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md`
- `source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md`
- lock: `tools/api551/rules/active_rules.lock.json`
