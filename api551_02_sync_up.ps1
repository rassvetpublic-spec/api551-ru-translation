param(
    [string]$Branch = "codex/archive-source-zips",
    [string]$LocalPath = "C:\Downloads\API 551",
    [string]$Task = "local update"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-02-push-local-to-github.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -LiteralPath $LogPath -Force | Out-Null

try {
    Set-Location -LiteralPath $LocalPath
    git fetch --prune origin $Branch
    git checkout -B $Branch "origin/$Branch"
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
