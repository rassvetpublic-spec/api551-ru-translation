# API551 Source-Gate Current

Status: CURRENT source-gate workflow for API 551 Stage 4+.

## 1. Required command

Before any task involving Figure objects, GitHub, files, packages, workflow, acceptance, or deliverables, run:

```powershell
.\tools\api551\api551.ps1 source-gate
```

In CI:

```bash
python3 tools/api551/api551.py source-gate --ci
```

## 2. What source-gate verifies

The source-gate must verify:

1. repository structure exists;
2. `source/API551_SOURCE_MANIFEST_CURRENT.json` exists;
3. all CURRENT policy/rule files exist;
4. mandatory source-data files are present;
5. `catalog.json`, `index.html`, and handoff JSON are synchronized;
6. accepted/changed/not_accepted counts match across catalog and handoff;
7. docs entrypoints point to `/tools/api551`;
8. LFS-safe state is respected;
9. no work proceeds from memory, old chats, `/mnt/data`, File Library, or archive ZIPs as the only source of truth.

## 3. Required conflict output

On conflict, stop and report in this form:

```text
source -> role -> problem -> risk -> required decision
```

Do not guess. Do not continue with stale package files or old overlays.

## 4. Current mandatory rules

The active Stage 4+ rule files are:

```text
source/API551_CONSOLIDATED_POLICIES_and_RULES_CURRENT_2026-06-18.md
source/API551_UNIVERSAL_FIGURE_LABEL_CLEANUP_AND_PLACEMENT_RULES_CURRENT_2026-06-25.md
source/API551_FIGURE_REWORK_SOURCE_AND_FRAME_FIT_RULES_CURRENT_2026-07-01.md
```

The toolkit keeps the same list in:

```text
tools/api551/rules/active_rules.lock.json
```
