---
name: api551-source-gate
description: Use before API 551 Stage 4+ work to verify repository state, Stage 5 CURRENT specification, source model, branch policy, handoff/schema, documentation, and accepted Figure baseline.
---

# API551 Source Gate

## Required checks

1. Confirm repo `rassvetpublic-spec/api551-ru-translation` and exact branch/head.
2. Read README, new-chat bootstrap and handoff.
3. Validate handoff against `tools/api551/schemas/handoff.schema.json`.
4. Read Stage 5 CURRENT-TZ, manifest and CURRENT policy/rules.
5. Verify the exact minimized `source/` model.
6. Verify catalog/index/workspace and `69/69 accepted`, `changed: 0`, `not_accepted: 0`.
7. Verify config/handoff/schema branch policy: stable `main`, default `task/*` from current `main`.
8. Run repo-local source-gate and applicable CI.
9. Treat archive and the no-`.git` snapshot as evidence/recovery only.

## Stop

Stop on unclear repo/branch/head, source conflict, invalid schema, status drift, stale task base, failed/incomplete CI or archive/snapshot misuse.

```text
SOURCE_GATE: FAIL
repo:
branch/head:
source -> role -> problem -> risk -> required decision
```

## Pass

```text
SOURCE_GATE: OK
repo:
branch/head:
active source files:
accepted/changed/not_accepted:
Stage 5 gate:
CI/status:
next authorized step:
```

Do not move beyond the authorized gate or merge without explicit authorization.
