# API 551 Local pwsh Pipeline

Status: CURRENT operational addendum.

Date: 2026-07-01.

Scope: local Windows execution, ChatGPT-assisted script handoff, overlay sanity checks, PR checks, and copy/paste command style for this repository.

Priority: this file supplements `docs/rules/GITHUB_PROJECT_PIPELINE_CURRENT_2026-06-26.md`. For accepted Stage 4 Figure objects, `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md` remains the higher-priority acceptance policy.

## 1. Default shell

Use PowerShell 7 through `pwsh` for local commands and delivered `.ps1` scripts.

Do not use Windows PowerShell 5.1 through `powershell.exe` by default. Use it only when the user explicitly asks or when a legacy script requires it.

Reason: Windows PowerShell 5.1 has encoding and native-command stderr behavior that can break UTF-8 Cyrillic scripts and Git commands.

## 2. Chat command format

When giving operational commands for copy/paste, provide one command line.

Preferred format:

```powershell
pwsh -NoProfile -Command "Set-Location -LiteralPath 'C:\\GIT\\API 551'; git status"
```

Avoid multi-line terminal command blocks for routine operations because they are error-prone in the chat copy UI and can paste in the wrong order.

## 3. Default local paths

Default local checkout:

```text
C:\\GIT\\API 551
```

Downloaded helper scripts and overlay packages should be discovered from the user's Downloads folder:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
```

Do not hard-code a user profile Downloads path.

## 4. Persistent validator/runner

Use `scripts/api551_validate_and_run_ps1_pwsh.ps1` as the persistent local wrapper.

The wrapper must:

1. resolve `pwsh`;
2. resolve the target script from Downloads or from `-TargetScript`;
3. print target path, size, and SHA-256;
4. run PowerShell parser validation;
5. run PSScriptAnalyzer if locally available;
6. stop on parser errors;
7. execute the target with `pwsh` only after validation passes;
8. return the target exit code.

## 5. Target script requirements

Local target scripts that change filesystem, Git, GitHub, branches, PRs, or overlays should support:

```text
-ValidateOnly
```

`-ValidateOnly` should check preconditions and planned scope without changing state.

High-risk scripts should also:

1. verify repo origin;
2. verify current branch or intended base branch;
3. verify working tree state;
4. verify target path is under the expected project folder;
5. require explicit confirmation before reset, clean, delete, push, merge, or branch deletion;
6. use argument arrays for external commands, not raw string concatenation.

## 6. Native command handling

When wrapping external commands (`git`, `gh`, `pwsh`) inside PowerShell scripts:

1. capture exit code from `$LASTEXITCODE`;
2. do not treat all stderr text as fatal by itself;
3. handle expected Git stderr/status messages safely;
4. fail only on non-zero exit unless the command is intentionally allowed to fail.

This prevents false failures from messages such as `Already on 'candidates'`.

## 7. Figure overlay sanity

Figure overlay ZIPs intended for unpacking over the repository must contain only project-relative paths.

Allowed examples:

```text
workspace/figures/051/figure_051.png
workspace/figures/051/figure_051.source_crop.png
workspace/figures/051/figure_051.object.json
workspace/figures/051/figure_051.object.html
workspace/figures/051/figure_051.out.html
```

Forbidden in overlay root unless explicitly requested:

```text
README_*.md
*_QA_REPORT.json
debug/*
temp/*
*.log
```

Use `scripts/api551_overlay_sanity_pwsh.ps1` before applying an overlay.

## 8. Acceptance PR preflight

Before pushing an accepted Figure PR, verify:

1. `catalog.json` parses;
2. Figure status is coherent between catalog and object JSON;
3. accepted stats match expected totals;
4. `figure_*.out.html` is clean and contains no service/review markers;
5. `figure_*.object.html` contains review/service data and a relative source PDF link;
6. every Figure HTML contains `../../../source/API%20551%202016%20(R2024).pdf#page=`;
7. PNG files are real PNGs after Git LFS checkout;
8. no root debug, QA, temp, or README files are added by mistake.

## 9. PR check workflow

Use `scripts/api551_check_pr_pwsh.ps1` for local PR checks when the connector or UI is insufficient.

Minimum checks:

1. PR state;
2. base branch;
3. head branch;
4. head SHA;
5. changed file list;
6. GitHub check status;
7. mergeability.

Do not merge from the UI or local CLI until checks are known and the user explicitly commands merge.

## 10. Routine local sync

Use `scripts/api551_sync_candidates_pwsh.ps1` or the single-line command from `docs/runbooks/API551_LOCAL_PWSH_PIPELINE_CURRENT_2026-07-01.md`.

Routine sync should end with:

```text
working tree clean
current branch candidates
HEAD equals origin/candidates
Git LFS content pulled
```

## 11. Delivery standard

When delivering a `.ps1` to the user, state:

1. file link or repo path;
2. SHA-256;
3. validation status;
4. one-line `pwsh` launch command;
5. whether the script changes state or is validation-only.

Do not paste long script contents into chat.
