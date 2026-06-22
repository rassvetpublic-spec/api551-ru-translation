param(
    [string]$RepoUrl = "https://github.com/rassvetpublic-spec/api551-ru-translation.git",
    [string]$Branch = "codex/archive-source-zips",
    [string]$LocalPath = "C:\Downloads\API 551",
    [switch]$NoLfsPull,
    [switch]$NoLogPush
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-01-pull-from-github.log"

function Log([string]$Text) {
    $Line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Text
    Write-Host $Line
    Add-Content -LiteralPath $LogPath -Value $Line -Encoding UTF8
}

function Run([scriptblock]$Command, [string]$Text) {
    Log $Text
    & $Command 2>&1 | ForEach-Object { Log ("  " + $_) }
    if ($LASTEXITCODE -ne 0) { throw "Failed: $Text" }
}

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Set-Location -LiteralPath $LocalPath
Log "API551 pull started"
Run { git remote set-url origin $RepoUrl } "git remote set-url origin"
Run { git fetch --prune origin $Branch } "git fetch --prune origin $Branch"
Run { git checkout -B $Branch "origin/$Branch" } "git checkout branch"
Run { git pull --ff-only origin $Branch } "git pull --ff-only origin $Branch"

if (-not $NoLfsPull) {
    if (Get-Command git-lfs -ErrorAction SilentlyContinue) {
        Run { git lfs install --local } "git lfs install --local"
        Run { git lfs pull origin $Branch } "git lfs pull origin $Branch"
    }
    else { Log "git-lfs not found; skipped" }
}

Run { git status -sb } "git status -sb"
Run { git rev-parse HEAD } "git rev-parse HEAD"
Log "API551 pull completed"

if (-not $NoLogPush) {
    Run { git add $LogPath } "git add run log"
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        Run { git commit -m "Add API551 pull run log" } "git commit run log"
        Run { git pull --rebase origin $Branch } "git pull --rebase origin $Branch"
        Run { git push origin $Branch } "git push origin $Branch"
    }
}
