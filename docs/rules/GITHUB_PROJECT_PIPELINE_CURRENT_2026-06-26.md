# API 551 Project GitHub Pipeline

Status: CURRENT local GitHub workflow addendum.

Date: 2026-06-26.

Scope: applies to GitHub work in this repository and captures the preferred ChatGPT-assisted workflow for checks, branches, PRs, merges, local fallback scripts, and reporting.

Priority: if another ACTIVE/CURRENT project file contains a more specific GitHub workflow rule, the more specific file controls. For accepted Stage 4 Figure objects and promotion of accepted Figure objects, `docs/rules/STAGE4_ACCEPTANCE_PIPELINE_CURRENT_2026-06-26.md` remains the higher-priority file.

## 1. Core workflow

Use this sequence unless the user explicitly reopens the decision:

```text
source gate -> clean branch from main -> change -> diff check -> PR -> CI -> merge after explicit user command -> verify main -> handoff
```

Do not work from memory, stale local files, old ZIPs, or previous chat state as the only source of truth.

## 2. Repository gate

Before any GitHub write action, verify:

1. repository: `rassvetpublic-spec/api551-ru-translation`;
2. default branch: `main`;
3. permissions include the required write/admin capability for the requested action;
4. repository is not archived;
5. current target file or branch state is fetched from GitHub.

Preferred connector tools:

```text
GitHub.get_repo
GitHub.fetch_file
GitHub.search
GitHub.search_branches
GitHub.compare_commits
```

## 3. Source gate for API 551

Before API 551 project edits, verify:

1. Project Instructions;
2. CURRENT policy/rules;
3. source data;
4. GitHub catalog/index/workspace where relevant;
5. Figure/object status where relevant;
6. conflicts between sources.

If a conflict is found, stop and report:

```text
source -> role -> problem -> risk -> required decision
```

## 4. Branching

Do not modify `main` directly unless the user explicitly authorizes direct `main` modification.

Default branch naming:

```text
rules/<short-topic>-YYYY-MM-DD
stage4/figNN-<short-topic>-YYYY-MM-DD
fix/<short-topic>-YYYY-MM-DD
cleanup/<short-topic>-YYYY-MM-DD
```

Avoid names that collide with existing ref namespaces, for example do not create `candidates/...` when a real branch named `candidates` exists.

Preferred connector tools:

```text
GitHub.create_branch
GitHub.compare_commits
```

## 5. Text edits

For small UTF-8 text changes, use connector operations:

```text
GitHub.fetch_file
GitHub.create_file
GitHub.update_file
GitHub.delete_file
```

Before `update_file` or `delete_file`, fetch the current file SHA from GitHub.

Do not overwrite a large file if the fetched content is truncated or incomplete. Stop and use a local-script fallback.

## 6. Local script fallback

Use a local `.ps1` fallback when:

1. connector write or merge is blocked;
2. the edit is multi-file, binary-heavy, or too large;
3. branch cleanup needs commands unavailable in the connector;
4. a precise `git`/`gh` operation is safer than manual GitHub UI.

For local execution scripts, follow the user-wide rule:

1. do not paste a long script into chat;
2. provide one `.ps1` file, not ZIP, unless the user explicitly asks for ZIP;
3. provide a short `Downloads` launch command;
4. script must verify repo, branch, and target state;
5. script must stop on error;
6. destructive operations require explicit confirmation inside the script;
7. script delivery must follow the PowerShell validation gate in Section 14.

Standard launch command pattern:

```powershell
$D=(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path; powershell -ExecutionPolicy Bypass -File ((Get-ChildItem $D -Filter 'script_name*.ps1' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName)
```

## 7. PR creation

Create PRs through connector when possible:

```text
GitHub.create_pull_request
GitHub.get_pr_info
GitHub.fetch_pr_patch
GitHub.list_pr_changed_filenames
```

PR body should state:

1. scope;
2. changed files;
3. verification performed;
4. safety notes;
5. next step.

For API 551, safety notes must include where relevant:

```text
No image generation.
No generative image editing.
No approved translations changed without grounds.
No direct main write.
```

## 8. Diff and CI checks

Before merge, verify at minimum:

1. PR is open;
2. base branch is correct;
3. head branch is correct;
4. changed files are expected;
5. patch contains no debug/test/temp/run-log artifacts unless explicitly intended;
6. CI/checks have passed or limitations are explicitly reported.

Preferred connector tools:

```text
GitHub.get_pr_info
GitHub.fetch_pr_patch
GitHub.fetch_pr_file_patch
GitHub.fetch_commit_workflow_runs
GitHub.get_commit_combined_status
GitHub.fetch_workflow_run_jobs
GitHub.fetch_workflow_job_steps
GitHub.fetch_workflow_job_logs
```

## 9. Merge rule

Merge only after the user explicitly instructs merge, for example:

```text
делай мерж
merge
accept and merge
```

Before merge, re-check PR state, changed files, CI, and `head_sha`.

Preferred connector tool:

```text
GitHub.merge_pull_request
```

Preferred method:

```text
squash
```

Use `expected_head_sha` when known.

If connector merge is blocked, provide a `.ps1` fallback that runs the equivalent `gh pr merge` command. Do not ask the user to perform manual GitHub UI steps unless all automated paths fail.

## 10. Branch cleanup

After merge, delete temporary working branches when tool support exists or use local `.ps1` fallback with `gh pr merge --delete-branch`.

Do not mass-delete remote branches without an explicit branch list and confirmation.

Protected or retained branches:

```text
main
candidates
archive branches
evidence branches
branches explicitly preserved by the user
```

## 11. Post-merge verification

After merge, verify:

1. PR is closed and merged;
2. merge commit SHA is captured;
3. target content is present on `main`;
4. CI/check status is known;
5. temporary branches are removed or intentionally retained.

Preferred tools:

```text
GitHub.get_pr_info
GitHub.fetch_file
GitHub.compare_commits
GitHub.search_branches
```

## 12. Reporting format

Final GitHub task reports should be compact:

```text
Repo:
Branch:
PR:
Merge:
Changed files:
CI:
Verification:
Issues:
Next step:
```

Do not paste large HTML, PNG, JSON, CSV, or debug output into chat.

## 13. Red lines

Do not:

1. change `main` directly without explicit authorization;
2. merge without explicit user command;
3. rely on stale local files as source of truth;
4. overwrite truncated fetched content;
5. add debug/test/temp files into production PRs;
6. mass-delete branches without explicit confirmation;
7. change approved API 551 translations without grounds;
8. use image generation or generative image editing for API 551.

## 14. PowerShell script validation gate

Every `.ps1` delivered to the user must include an explicit validation status in the final response.

Allowed validation statuses:

```text
PS1 validation: PASSED by PowerShell parser + PSScriptAnalyzer
PS1 validation: PASSED by PowerShell parser; PSScriptAnalyzer unavailable
PS1 validation: STATIC ONLY, no PowerShell runtime available
PS1 validation: FAILED — file not delivered
```

Do not imply that a `.ps1` was fully validated unless it was actually parsed by PowerShell parser and, when available, checked by PSScriptAnalyzer.

Minimum static checks before delivering any `.ps1`:

1. file exists and is non-empty;
2. size and SHA-256 are reported;
3. encoding is identified;
4. no long script body is pasted into chat;
5. file extension is `.ps1`, not ZIP, unless ZIP is explicitly requested;
6. no accidental placeholders, debug paths, or unrelated project files are included;
7. `$ErrorActionPreference = "Stop"` or equivalent fail-fast behavior is present unless intentionally not applicable;
8. external commands such as `git`, `gh`, `powershell`, or `pwsh` are invoked safely, preferably through argument arrays rather than unescaped command strings;
9. destructive operations are gated by repository/path checks or explicit confirmation.

## 15. PowerShell parser and analyzer rules

When a PowerShell runtime is available, validate syntax before delivery with the PowerShell parser:

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { $errors | Format-List *; exit 1 }
```

When PSScriptAnalyzer is available, also run:

```powershell
Invoke-ScriptAnalyzer -Path $Path -Severity Error,Warning -ReportSummary
```

For CI or strict mode, use:

```powershell
Invoke-ScriptAnalyzer -Path $Path -Severity Error,Warning -EnableExit
```

If `pwsh`/`powershell` is not available in the assistant runtime, the assistant must not claim full validation. Use `STATIC ONLY` unless validation was performed through another reliable PowerShell runtime such as GitHub Actions or the user's local validation wrapper.

## 16. ValidateOnly / DryRun requirement

Scripts that perform GitHub, Git, filesystem, branch, merge, reset, clean, delete, or force operations should include one of these validation modes where feasible:

```text
-ValidateOnly
-DryRun
-WhatIf
```

The validation mode should check preconditions without performing the destructive or state-changing action:

1. required commands exist (`git`, `gh`, `pwsh`, `powershell` as applicable);
2. repository remote is correct;
3. branch/base/head match the expected values;
4. target path is inside the intended project directory;
5. requested PR/commit/head SHA matches the expected value;
6. destructive action would be limited to the expected file, branch, or directory.

High-risk scripts require either parser/analyzer validation before delivery or explicit `STATIC ONLY` disclosure plus user confirmation before use. High-risk operations include:

```text
git reset --hard
git clean -fd
git push
git push --force
git branch -D
gh pr merge
gh api DELETE
remote branch deletion
file deletion
force ref update
```

## 17. Local validate-and-run wrapper

Preferred fast path for ordinary `.ps1` scripts is a persistent local wrapper named like:

```text
api551_validate_and_run_ps1.ps1
```

The wrapper should:

1. find the newest target script in `Downloads` by pattern;
2. run PowerShell parser validation on the target script;
3. run PSScriptAnalyzer if installed, but not require internet access;
4. stop before execution on parser errors;
5. optionally warn but allow continuation on analyzer warnings when the user confirms;
6. execute the target only after validation passes;
7. print the target file path, SHA-256, validation result, and exit code.

For ordinary scripts, delivery may state that full validation is expected to occur through the local wrapper immediately before execution. For dangerous scripts, prefer GitHub Actions validation or a script-specific local parser/analyzer run before the user executes state-changing operations.

## 18. GitHub Actions validation option

Use GitHub Actions validation when a script is high-risk, multi-file, CI-sensitive, or when the user asks for pre-delivery validation and local validation is not acceptable.

Preferred runner for Windows-specific PowerShell scripts:

```yaml
runs-on: windows-latest
```

A PS1 validation workflow should run at least:

```text
PowerShell parser check
PSScriptAnalyzer when installable/available
project-specific forbidden-pattern checks
```

Do not use GitHub Actions for every ordinary small script by default because it adds significant latency. Use the local wrapper as the default fast validation path and GitHub Actions as the stricter/high-risk path.
