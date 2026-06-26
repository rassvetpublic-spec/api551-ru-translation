# API 551 Stage 4 Acceptance Pipeline

Status: CURRENT acceptance/merge workflow rule.

Date: 2026-06-26.

Scope: applies when the user explicitly accepts one or more Stage 4 Figure objects and to the later promotion of accepted Figure objects from `candidates` into `main`.

## 1. Trigger

A user message such as `Figure 51 accepted`, `Fig. 51 accepted`, `Рисунок 51 принят`, `51 принят`, or the same wording for multiple explicit Figure numbers is an acceptance trigger for the named Figure number(s) only.

Do not infer acceptance for neighboring Figures, batches, old candidates, draft artifacts, or figures mentioned only indirectly.

If the acceptance target is ambiguous, stop and ask the user which Figure number(s) are accepted.

## 2. Source gate before acceptance work

Before applying acceptance, run the normal API551 source gate:

1. verify repo, default branch, permissions, and current branch state;
2. verify `main` and `candidates` relationship;
3. verify active policy/rules, catalog, index, workspace Figure folder, and current CI workflow;
4. verify that the accepted candidate artifact matches the Figure number and current approved sources;
5. stop on any conflict between source data, catalog status, workspace files, CI expectations, or user acceptance wording.

Do not use prior chat memory, local cache, old ZIPs, or stale review output as the only evidence for an acceptance commit.

## 3. Branching rule

Do not push accepted Figure changes directly to `main`.

Use an acceptance branch from `candidates`, normally:

`accept-figNN-YYYYMMDD`

For batches:

`accept-figNN-NN-YYYYMMDD`

Do not use a branch name under `candidates/...` while a real branch named `candidates` exists, because Git ref namespace collisions can prevent branch creation.

## 4. Acceptance integration PR

The acceptance branch must update all affected review state in one coherent commit set:

1. `workspace/figures/NNN/figure_NNN.png`;
2. `workspace/figures/NNN/figure_NNN.source_crop.png`, if rebuilt or corrected;
3. `workspace/figures/NNN/figure_NNN.object.json`;
4. `workspace/figures/NNN/figure_NNN.object.html`;
5. `workspace/figures/NNN/figure_NNN.out.html`;
6. `catalog.json` status and stats;
7. `index.html` review listing/status;
8. CI expectations in `.github/workflows/structure-check.yml` when the workflow contains hardcoded accepted/changed counts or a hardcoded Figure status check.

For the accepted Figure:

- set catalog status to `accepted`;
- update catalog stats consistently;
- remove any obsolete `измененно_*`/review-only state for that Figure;
- preserve accepted translation, label count, layout decisions, caption, notes, and table structure in the object metadata.

If binary/LFS Figure assets cannot be committed safely by the available toolchain, stop and return a verified overlay ZIP plus exact local Git/LFS instructions. Do not open an incomplete PR that updates JSON/HTML/status while leaving stale PNG assets behind.

## 5. Checks before PR merge into `candidates`

Before merging the acceptance PR into `candidates`, check at minimum:

1. JSON files parse;
2. changed HTML files are UTF-8 and portable;
3. `out.html` remains clean user/export content;
4. `object.html` may contain service diagnostics but no broken image links;
5. PNG assets are real PNGs, not Git LFS pointer text by accident;
6. catalog contains exactly 69 Figures;
7. accepted/changed/not_accepted counts match the updated catalog state;
8. CI is green, or any CI limitation is explicitly reported before merge.

Merge into `candidates` only after checks pass or the user explicitly instructs otherwise with the risk stated.

After a successful merge into `candidates`, delete the temporary acceptance branch unless it must be preserved for an unresolved audit issue.

## 6. Promotion from `candidates` to `main`

Promotion to `main` is a separate step.

When the user asks to collect accepted work into `main`, or when a reviewed acceptance batch is ready for final promotion:

1. compare `main` and `candidates`;
2. verify that `candidates` contains only intended accepted Figure updates and rule/workflow updates;
3. run/source-check CI against the promotion PR;
4. open PR `candidates` -> `main`;
5. merge only after checks pass or after explicit user risk acceptance;
6. do not force-push or rewrite `main`.

After successful promotion, delete temporary working branches and PR branches that are no longer needed. Do not delete `main`, `candidates`, archive branches, evidence branches, or branches explicitly preserved by the user.

## 7. Cleanup and reporting

After acceptance or promotion, report:

- repo;
- base branch and head branch;
- PR number/link;
- merged commit SHA if merged;
- Figure numbers accepted/promoted;
- files changed;
- checks run and result;
- branches deleted or intentionally retained;
- next step.

Do not paste large HTML, JSON, CSV, image previews, or debug output into chat.

## 8. Failure handling

Stop and report the conflict instead of guessing when:

- accepted Figure status in catalog does not match the user request;
- current candidate artifact cannot be identified;
- candidate files and catalog/index disagree;
- CI expectations are incompatible with the new accepted set;
- binary/LFS assets cannot be safely committed;
- branch comparison shows unrelated changes that would be promoted accidentally.
