---
name: api551-source-gate
description: Use before any API 551 Stage 4 work to verify the active repository, source model, manifest, and allowed source files.
---

# API551 Source Gate

Use this skill before any API 551 Stage 4 work.

## Goal

Prevent work from stale Project Sources, old local caches, superseded ZIP files, or archived evidence.

## Required checks

1. Confirm repository:
   - `rassvetpublic-spec/api551-ru-translation`
   - branch is known.
2. Read `README.md`.
3. Read `source/API551_SOURCE_MANIFEST_CURRENT.json`.
4. Verify that active source files are exactly the current minimized source model defined by the manifest and README.
5. Confirm that `archive/` is preserved traceability/evidence, not active generation input.
6. Confirm that `workspace/figures/` and `catalog.json` are available when Figure work is requested.
7. Confirm `.github/workflows/structure-check.yml` exists.

## Current active source model

Expected active source files are the files currently listed in `source/API551_SOURCE_MANIFEST_CURRENT.json` and `README.md`.

The current model after the source cleanup is minimized. The former Stage 2/Stage 3/control ZIP packages were moved from `source/` into `archive/source-packages/` and are forbidden as generation input for final one-pass rebuild unless a task explicitly says audit/traceability.

## Stop conditions

Stop immediately if:

- repository is unavailable;
- branch is unclear;
- README and manifest disagree;
- active source files are missing;
- a file is present in Google Drive but not visible in GitHub, or vice versa, and the task depends on it;
- the task requires archive files as generation input without explicit user approval;
- accepted Figure status cannot be verified.

Report the stop in this format:

```text
SOURCE_GATE: FAIL
repo:
branch:
missing/conflict:
risk:
question:
```

## Pass report

When the gate passes, report only:

```text
SOURCE_GATE: OK
repo:
branch:
active source files:
accepted count:
changed/review:
next proposed batch:
```

Do not generate files until the user confirms the batch.
