# API 551 Stage 4 Acceptance Pipeline

Status: CURRENT reopen-only acceptance rule after Stage 4 closure.  
Stage 4 baseline: 69/69 accepted and promoted to `main` through PR #63/#64.

## Scope

Use this rule only when the user explicitly reopens a specific accepted Figure, reviews a specific replacement version and explicitly accepts that version.

Do not infer acceptance for neighboring Figures, batches, old candidates or draft artifacts.

## Source and status gate

Before rework or acceptance:

1. run source-gate;
2. verify current `main` and exact task head;
3. confirm the Figure is explicitly reopened;
4. preserve the previous accepted object as traceable history;
5. apply CURRENT Figure source/cleanup/layout rules;
6. do not change other accepted Figures.

## Branch and PR policy

```text
current main -> dedicated task/reopen branch -> coherent Figure update -> PR into main -> all checks -> explicit merge -> verify main
```

- Do not write directly to `main`.
- Do not use `candidates` as the active acceptance branch after Stage 4 promotion.
- Default branch name: `task/reopen-figNN-YYYYMMDD` or another clear non-main task name.
- PR base: `main`.
- Merge only after explicit user authorization and successful CI/review/source-gate.

## Required synchronized update

For the reopened Figure, update and verify as applicable:

1. `workspace/figures/<NNN>/figure_<NNN>.object.json`;
2. `figure_<NNN>.object.html`;
3. `figure_<NNN>.out.html`;
4. accepted PNG and source crop;
5. `catalog.json`;
6. `index.html`;
7. handoff status;
8. hard-coded CI expectations;
9. entrypoint docs when workflow or policy changes.

A PR is incomplete if object/status/catalog/index/handoff disagree.

## Package and LFS gate

- required package files must be complete;
- real PNGs must not be LFS pointer text inside deliverable ZIPs;
- worktree LFS objects must match tracked pointer SHA-256 and size;
- `git lfs fsck` must pass;
- `git status --short` must be clean before merge;
- no broad `git lfs pull` by default.

## Acceptance gate

Before merge verify:

1. explicit acceptance applies to the exact Figure/version;
2. translations and reconstruction decisions have traceable authority;
3. no protected graphics are damaged;
4. no source text residue, clipping, overlap or service/debug content remains;
5. accepted Figure count/status remains coherent;
6. changed files are limited to the intended Figure and required synchronized state;
7. all review remarks are addressed;
8. all required CI checks pass on the final head.

## Historical promotion boundary

The old `candidates -> main` promotion sequence is completed history. It must not be repeated for Stage 5 or a reopened Figure.

## Cleanup

Delete a temporary branch only after verified merge and only after confirming it contains no needed unique commits. Never delete `main`, archive/evidence branches or a branch explicitly preserved by the user.
