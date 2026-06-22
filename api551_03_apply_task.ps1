param(
    [string]$Branch = "codex/archive-source-zips",
    [string]$LocalPath = "C:\Downloads\API 551",
    [string]$TaskPath = "tasks/api551_current_task.ps1",
    [string]$Task = "remote task"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-03-run-remote-task.log"
$TaskLocalPath = Join-Path $LocalPath ($TaskPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -LiteralPath $LogPath -Force | Out-Null

try {
    Set-Location -LiteralPath $LocalPath
    git fetch --prune origin $Branch
    git checkout -B $Branch "origin/$Branch"
    git pull --ff-only origin $Branch

    if (-not (Test-Path -LiteralPath $TaskLocalPath -PathType Leaf)) {
        throw "Task script not found: $TaskPath"
    }

    . $TaskLocalPath

    git add -- README.md .gitignore index.html catalog.json .github source workspace docs archive tasks *.ps1
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        git commit -m "Task: $Task"
        git pull --rebase origin $Branch
        git push origin $Branch
    }
    git status -sb
}
finally {
    Stop-Transcript | Out-Null
}
