# API551 Tooling Repair History — 2026-07-09

Status: project repair history / operational evidence.  
Scope: API 551 Stage 4 Figure Objects, repo-local tooling, PR workflow, Figure 3 R03 repair.

This file records why the `/tools/api551` workflow exists. It is not a replacement for CURRENT rules. If this history conflicts with CURRENT policy/rules, the CURRENT rule files control.

## 1. Why this file exists

During Stage 4, Figure work repeatedly failed for the same classes of reasons:

- ad-hoc scripts were kept outside the repository;
- source-gate was performed manually and inconsistently;
- local preview, overlay package, `index.html`, and GitHub PR state diverged;
- accepted Figure metadata could be overwritten by review-only package state;
- package ZIPs could contain stale or wrong assets;
- PowerShell quoting and argument handling caused repeated false starts;
- CI and documentation status values could become stale.

The repo-local toolkit and documentation added in PR #38 are intended to make these failure modes explicit and block them by default.

## 2. Figure 3 R03 incident summary

Figure 3 was accepted as R03, but local review later showed a display problem in Panel A. The root cause was not a translation decision or acceptance-state issue. The accepted object metadata was correct, but the workspace/package layer contained wrong or stale panel PNG assets. This created a mismatch between the accepted Figure object and what the local preview showed.

Correct repair principle:

```text
Preserve accepted metadata and status. Replace only the wrong display assets from the clean R03 PDF-derived rebuild package.
```

The repair must not revert the Figure to `review_only_not_accepted`, must not remove accepted metadata, and must not add stray service files as production inputs.

## 3. PR sequence that motivated the tooling

Relevant sequence:

```text
PR #36 — accepted Figure 3 R03 into candidates.
PR #37 — repaired Figure 3 R03 workspace package display assets.
PR #38 — added repo-local API551 Stage 4 toolkit and rewrote entrypoint docs.
```

Key lesson: Figure acceptance, local display repair, and tooling repair are different workflows and must not be mixed in one implicit operation.

## 4. Failure classes to prevent

### 4.1 Stale overlays and stale package assets

Problem: old translated/review PNGs or old overlay packages can look valid but no longer match the accepted object.

Required prevention:

- rework from clean PDF-derived source crop;
- treat old translated PNGs as visual reference only;
- validate package image references before install;
- separate clean Git repo from hydrated visual view.

### 4.2 Accepted Figure reverted to review-only state

Problem: a package or script can overwrite accepted object JSON/HTML with `review_only_not_accepted` or remove `approval_status` / `accepted_on` metadata.

Required prevention:

- accepted Figure object status must be checked before PR;
- `review_only_not_accepted` is forbidden in accepted object JSON/HTML;
- accepted Figures are frozen unless explicitly reopened by the user.

### 4.3 Multi-root ZIP package overwrite risk

Problem: a ZIP requested for Figure `003` can also contain `004/...`; if blindly extracted, it can overwrite another Figure candidate.

Required prevention:

- Figure package must contain exactly one `NNN/` root;
- `install-package` must refuse to extract any member outside the selected root.

### 4.4 LFS pointer confusion

Problem: CI and clean local checkouts often contain LFS pointer text instead of real PNG/PDF/ZIP binary files. Treating every small pointer file as corruption breaks CI, but putting pointer files inside a deliverable ZIP is also wrong.

Required prevention:

- CI accepts LFS pointers where repository checkout policy expects them;
- package ZIP validation rejects LFS pointers for required PNG deliverables;
- no broad `git lfs pull` by default;
- use a separate hydrated visual view for real binary review assets.

### 4.5 PowerShell fragility

Observed failure modes:

- script path lookup inside function used the wrong invocation context;
- scalar values were handled as arrays;
- `.Trim()` was called on `Char` unexpectedly;
- Git command arguments were passed without an explicit argument array;
- nested quoting broke `gh --jq` commands;
- squash-merged branches were interpreted as not fully merged by local Git.

Required prevention:

- PowerShell should be a thin wrapper only;
- core validation logic should live in Python stdlib code;
- PR checks should avoid fragile nested shell `jq` expressions;
- branch deletion after squash merge may require local `git branch -D`, but only after merge verification.

### 4.6 Force-with-lease stale info

Problem: force-push with stale remote tracking information was rejected. `gh pr view` also briefly showed a stale head SHA after a successful force-push.

Required prevention:

- fetch the exact remote PR branch before force-with-lease;
- use expected-head guarded push when overwriting PR branch state;
- verify PR head through GitHub PR metadata after push;
- do not treat one stale CLI read as source truth.

### 4.7 Documentation/status drift

Problem: entrypoint docs and handoff/status counts can diverge after accepting a Figure.

Required prevention:

- `catalog.json`, `index.html`, handoff JSON, README, quick-start, new-chat bootstrap, and hard-coded CI status expectations must be synchronized when status changes;
- `docs-sync-check` and CI must fail on stale status markers.

## 5. Default project entrypoint after PR #38

Use this command first:

```powershell
.\tools\api551\api551.ps1 source-gate
```

Then use:

```powershell
.\tools\api551\api551.ps1 status
.\tools\api551\api551.ps1 rules-for -Figure NNN
.\tools\api551\api551.ps1 figure-check -Figure NNN
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure NNN
.\tools\api551\api551.ps1 pr-check -Pr N
```

## 6. Non-negotiable repair principles

1. Do not use image generation or generative image editing.
2. Do not redraw or invent graphic content.
3. Do not change accepted translations without traceable reason.
4. Do not use OCR as replacement for approved label master CSV.
5. Do not use old translated PNGs as production source.
6. Do not mix clean Git repo with hydrated visual assets.
7. Do not modify `main` directly without explicit permission.
8. Do not merge without explicit user command.
9. Do not treat `/mnt/data`, old chats, or archived ZIPs as the only source of truth.
10. Do not add new active root scripts; default project tooling belongs in `/tools/api551`.

## 7. How a new chat should use this history

A new chat should read this file only after the normal source-gate documents. The purpose is to understand the operational reasons behind the tooling checks, not to override CURRENT rules.

Recommended order:

```text
source-gate -> CURRENT rules -> handoff/status -> tooling docs -> this repair history -> current task
```

If a future tooling failure resembles one of the incidents above, fix the toolkit or documentation in the repository rather than creating another one-off local script.
