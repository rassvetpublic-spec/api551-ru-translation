---
name: api551-night-operator
description: Autonomous, fully logged overnight operator for API 551 Stage 4 review production, tool bootstrap, Figure 8 acceptance repair, and GitHub/ChatGPT handoff.
---

# API551 Night Operator

Use only after reading repository `AGENTS.md` and after the repo-local source gate passes.

## Mission

Run a long unattended API551 session safely:

1. inventory, install, and test required tools;
2. validate repository integrity and local/remote Git state;
3. repair and finish Figure 8 acceptance because the user explicitly approved it;
4. prepare review-only packages for later not-accepted Figures;
5. keep exhaustive local logs;
6. publish compact text-only reports through GitHub without using Git LFS;
7. test available Chrome interaction with the open GitHub and ChatGPT pages.

## Source hierarchy

Use the live repository sources, not this skill, as source of truth:

1. project instructions and `AGENTS.md`;
2. CURRENT consolidated policy;
3. mandatory cleanup/placement addendum;
4. mandatory rework/source/frame-fit addendum;
5. source manifest, original PDF, approved label master;
6. current catalog/index/handoff;
7. accepted objects and explicit user corrections;
8. OCR only as a non-authoritative checking aid.

If a referenced rules-hub is not actually available, record `rules_hub_status=not_connected`; never invent its content.

## Logging contract

Create `run_id = YYYYMMDD_HHMMSS_<shortsha>`.

Local log root:

`C:\GIT\api551\reports\codex-local\<run_id>\`

Add that local root to `.git/info/exclude`; do not change `.gitignore` merely for runtime logs.

Required files:

- `EVENTS.jsonl` — one structured event per line;
- `COMMANDS.log` — command, cwd, start/end, exit code, duration, stdout/stderr;
- `DECISIONS.md` — decisions and rule citations;
- `TOOL_INVENTORY.json`;
- `CHECKS.json`;
- `GIT_STATE.md`;
- `BROWSER_TEST.md`;
- `FIGURE_<NNN>_REPORT.md` for every processed Figure;
- `BLOCKERS.md`;
- `CHATGPT_HANDOFF.md`;
- `SUMMARY.json`.

Every command event must contain:

- UTC and local timestamp;
- phase;
- command;
- working directory;
- exit code;
- duration;
- stdout/stderr path and tail;
- touched files;
- git branch and HEAD before/after when relevant.

Redact secrets, authorization headers, cookies, tokens, device codes, and credential-manager output. Never paste full environment variables.

Rotate local command logs at 10 MiB. Keep all rotated files locally. GitHub relay receives only compact excerpts.

## Tool bootstrap

Discover requirements from the repo before installing anything:

- scripts and wrappers;
- Python imports and dependency files;
- PowerShell modules;
- workflow files;
- PDF/image processing commands;
- Git/LFS/GitHub tooling.

Prefer:

- `winget` packages from official publishers for executables;
- repo-local Python `.venv`;
- `python -m pip`, never bare `pip`;
- PowerShell 7 (`pwsh`);
- exact version/path smoke tests.

Do not install OCR unless a current repo workflow actually requires it. Even if installed, OCR cannot become source truth.

After installation, execute the repo-local tests defined in `TOOL_BOOTSTRAP_AND_TEST.md`. A tool is not “installed” until its executable path, version, and smoke test are logged.

## Git safety

Before write actions:

- fetch remote;
- capture branch, HEAD, status, stash list, LFS status, worktrees;
- back up local untracked Figure packages and real PNGs without adding them to Git;
- never destroy unknown local changes;
- use `--force-with-lease` only when the exact expected remote SHA is logged and a normal push cannot be used;
- never modify `main` directly.

Figure 8 has explicit user approval and merge authorization. No other Figure does.

## Figure 8 acceptance repair

Expected remote baseline before Figure 8: 25/69 accepted, Figure 8 `not_accepted`.

Build a clean acceptance branch from current `origin/candidates`. Use the validated R01 package. Normalize accepted markers in:

- object JSON;
- object HTML;
- out HTML when needed.

Remove `review_only_not_accepted` from accepted artifacts. Update:

- Figure 8 six-file object package;
- `catalog.json`;
- `index.html`;
- Stage 4 handoff;
- bootstrap status markers;
- hard-coded workflow acceptance expectations.

Run source-gate, docs sync, Figure 8 check, all-known check, package check, JSON/encoding/link checks and CI. Open PR to `candidates`; merge only after checks pass. Report final merge SHA. Do not promote to `main`.

## Review production

For each remaining `not_accepted` Figure:

- regenerate from clean PDF-derived source crop;
- use approved label master;
- preserve dimensions, symbols, leader lines, borders and drawing geometry;
- do not leave caption inside PNG;
- do not invent labels;
- separate cleanup zones from placement zones;
- verify residual source text;
- produce exactly one `NNN/` root and six required files;
- run package-check and visual/layout QA;
- save ZIP only in the local review queue;
- do not mark accepted or merge.

Process in batches of at most three Figure objects. Multiple batches are allowed during one overnight run.

## GitHub relay without LFS

Preferred relay is a dedicated draft PR:

- branch: `codex-report-<run_id>`;
- base: `candidates`;
- title: `[REPORT] API551 Codex run <run_id>`;
- only UTF-8 text files under `reports/codex/<run_id>/`;
- no ZIP, PNG, PDF, screenshots or binary assets;
- each file under 1 MiB;
- total report commit under 5 MiB;
- draft PR must not be merged.

Publish:

- `HANDOFF.md`;
- `SUMMARY.json`;
- `CHECKS.json`;
- `TOOL_INVENTORY.json`;
- `BROWSER_TEST.md`;
- `BLOCKERS.md`;
- compact command tails.

Candidate ZIPs remain local; publish SHA-256, byte size and local path only.

If `gh` is unavailable, push the report branch and use Chrome to open/create the draft PR. If neither works, retain local reports and clearly log the relay failure.

## Chrome interaction test

Do not assume browser control exists. Test it.

1. Detect the existing Chrome process and available browser-control mechanism.
2. Read-only test:
   - locate the open GitHub repo page;
   - locate the open current ChatGPT conversation;
   - record page titles/hostnames only, not cookies or private page data.
3. ChatGPT write test, authorized by the user:
   - send exactly one message:
     `CODEX_RELAY_TEST run_id=<run_id> repo=api551 browser_control=ok`
   - do not send secrets or large logs;
   - record whether the message was submitted and whether a reply became visible.
4. GitHub write test:
   - use only the report branch/draft PR;
   - do not change repo settings;
   - do not merge report PR.
5. If browser control is unavailable, record `browser_control=unavailable` and use Git/gh relay.

## Stop conditions

Stop the whole session when:

- source-gate fails;
- CURRENT sources conflict;
- repository integrity is uncertain;
- the original source PDF or approved master is unavailable/corrupt;
- a write would risk losing local files;
- authentication requires exposing a secret.

For a single Figure-specific conflict, stop only that Figure, write a blocker report, and continue with the next Figure.

## Final handoff

The final local and GitHub handoff must state:

- run ID and time range;
- tool installations and versions;
- source-gate result;
- Figure 8 branch/PR/merge status;
- Figures packaged for review;
- skipped Figures and blockers;
- exact local ZIP paths, sizes and SHA-256;
- GitHub report PR/branch;
- Chrome/ChatGPT relay result;
- current accepted/not-accepted counts;
- next safe action.
