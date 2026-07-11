# API551 repo-local toolkit

Status: CURRENT repo-local tooling entrypoint for API 551 Stage 4+.

Run from the repository root or any child folder:

```powershell
.\tools\api551\api551.ps1 source-gate
```

The PowerShell file is only a Windows entrypoint. The core logic is in `tools/api551/api551.py` and uses only Python standard library modules.

## Default commands

```powershell
.\tools\api551\api551.ps1 source-gate
.\tools\api551\api551.ps1 status
.\tools\api551\api551.ps1 docs-sync-check
.\tools\api551\api551.ps1 rules-for -Figure 003
.\tools\api551\api551.ps1 figure-check -Figure 003
.\tools\api551\api551.ps1 package-check -PackageZip C:\GIT\package.zip -Figure 003
.\tools\api551\api551.ps1 pr-check -Pr 37
```

## Safety model

Read-only commands do not modify the repository. `install-package` modifies only `workspace/figures/<NNN>` and never commits, pushes, merges, or deletes branches. Git write operations remain outside the default tooling and require explicit user instruction.

## Source-gate model

The toolkit checks the active source/rule files, catalog/handoff status, documentation sync, LFS-safe binary state, and Figure object consistency. It must stop with a clear error instead of guessing when project state is inconsistent.

## Full Control package 005

Repo-local точки входа PowerShell из пакета 005 описаны в docs/project/API551_TOOL_FULL_CONTROL_005_RU.md:

- tools/api551/api551_005_bootstrap.ps1
- tools/api551/api551_preview_index.ps1
- tools/api551/publish_codex_report.ps1

Каждый скрипт, изменяющий состояние, сначала запускают с ValidateOnly.
