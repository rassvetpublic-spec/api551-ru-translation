# API 551 — Local LFS Hydrated View Workflow

Status: CURRENT local workflow rule.  
Project: API 551 RU Translation / completed Stage 4 Figure Objects.  
Updated: 2026-07-28.

This document defines the local recovery/view workflow for Git LFS binary assets when broad LFS downloads are undesirable or unavailable.

## 1. Purpose

The repository source of truth remains GitHub with Git LFS pointer files. A local hydrated view may be maintained separately for visual review and offline recovery of real PNG/PDF/ZIP files.

This workflow exists to prevent:

1. accidental broad `git lfs pull` usage;
2. accidental commits of hydrated binary files as ordinary Git modifications;
3. loss of locally available Figure PNG/PDF/ZIP files when GitHub LFS bandwidth is exhausted;
4. confusion between Git source state and local visual-review assets.

## 2. Folder roles

Recommended local folders:

```text
C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT
```

Clean Git repository. Use it for Git operations, branches, commits, PR preparation, and sync with `origin/main` and `origin/candidates`. It should normally contain Git LFS pointer files after no-smudge sync.

```text
C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT
```

Local visual-review and recovery copy. It may contain real PNG/PDF/ZIP files copied from a trusted local backup. Do not use it as Git source truth and do not commit from it.

```text
C:\Irvis-UPG\GIT\_api551_tmp
```

Optional local backup/source folder containing previously hydrated binary files. Use it only as a binary recovery source after SHA-256 and size validation against the current branch's LFS pointers.

## 3. Non-negotiable rules

1. Do not run broad `git lfs pull` by default.
2. Do not use a hydrated worktree with many `M` binary files for normal PR work.
3. Do not run `git add .` after hydrating binary files.
4. Do not commit hydrated PNG/PDF/ZIP files as ordinary modified files.
5. Keep `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` clean for Git work.
6. Keep real binary files in `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` or a dated ZIP backup.
7. Treat `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` as local convenience/evidence only, not as source of truth for rules, status, catalog, or translation decisions.

## 4. Safe hydration condition

A binary file may be copied from a local backup into a hydrated view only if all checks pass:

```text
target branch has an LFS pointer for the same relative path
source file is a real binary file, not an LFS pointer
source SHA-256 equals the pointer oid sha256
source byte size equals the pointer size
```

If SHA-256 or size differs, do not copy the file and report the mismatch.

## 5. Accepted Figure coverage check

For accepted Figures, the hydrated view should normally contain both:

```text
workspace/figures/<NNN>/figure_<NNN>.png
workspace/figures/<NNN>/figure_<NNN>.source_crop.png
```

For the completed 69 accepted Figures, both required files must be present for every Figure.

## 6. Recommended local operating pattern

Use this pattern after a stable promotion to `main`:

1. Sync the clean Git repository with no broad LFS pull.
2. Verify the active branch and `catalog.json` accepted counts.
3. Build or refresh `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` from local real binaries.
4. Validate each copied binary against the active branch LFS pointer `oid sha256` and `size`.
5. Create a dated local backup ZIP of hydrated view/source/archive when a meaningful accepted state is reached.
6. Return `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT` to a clean Git state before new branch/PR work.

## 7. Backup naming

Recommended local backup names:

```text
C:\Irvis-UPG\GIT\API551_HYDRATED_BACKUP_MAIN_<YYYY-MM-DD>.zip
C:\Irvis-UPG\GIT\API551_LOCAL_LFS_AND_WORKSPACE_BACKUP_<YYYY-MM-DD>.zip
```

These backups are local safety artifacts. Do not add them to the Git repository unless the user explicitly redefines the artifact policy.

## 8. Relationship to GitHub and CI

GitHub remains the source of truth for project files. CI must continue to validate repository text files and LFS pointer state without requiring broad LFS downloads.

The local hydrated view is allowed to support visual review, QA, and offline continuity, but it must not override:

1. Project Instructions;
2. CURRENT policy/rules;
3. `source/API551_SOURCE_MANIFEST_CURRENT.json`;
4. `catalog.json`;
5. `index.html`;
6. accepted Figure object JSON/HTML state in Git.

## 9. Failure handling

If a hydration attempt leaves the clean Git repository with many `M` binary files:

1. do not commit;
2. create a backup of the hydrated folders if needed;
3. copy hydrated content to `C:\Irvis-UPG\GIT\API551_GITHUB_FULL_SNAPSHOT`;
4. restore the Git repository to the branch state with `git reset --hard origin/<branch>`;
5. continue Git work only from the clean repository.

## 10. Source-gate impact

For future API 551 work, mention this workflow when LFS budget, local PNG/PDF/ZIP recovery, or visual-review folders are relevant. It does not replace the main source-gate, and it does not make local cached files source truth.
