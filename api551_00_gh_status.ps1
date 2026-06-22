param(
    [string]$Repo = "rassvetpublic-spec/api551-ru-translation",
    [string]$Branch = "codex/archive-source-zips",
    [int]$PrNumber = 1,
    [string]$LocalPath = "C:\Downloads\API 551"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-00-gh-status.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Log([string]$Text) {
    $Line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Text
    Write-Host $Line
    Add-Content -LiteralPath $LogPath -Value $Line -Encoding UTF8
}

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Invoke-GhJson([string[]]$Arguments) {
    $output = & gh @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh failed: gh $($Arguments -join ' ')`n$output"
    }
    return ($output | Out-String | ConvertFrom-Json)
}

Log "API551 gh status started"
Log "Repo: $Repo"
Log "Branch: $Branch"
Log "PR: #$PrNumber"

Require-Command "gh"
$ghVersion = (& gh --version | Select-Object -First 1)
Log "gh: $ghVersion"

try {
    $apiDns = Resolve-DnsName api.github.com -ErrorAction Stop | Where-Object { $_.IPAddress } | Select-Object -First 3 -ExpandProperty IPAddress
    Log "api.github.com DNS: $($apiDns -join ', ')"
} catch {
    Log "api.github.com DNS check failed: $($_.Exception.Message)"
}

$auth = & gh auth status -h github.com 2>&1
$authText = ($auth | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "gh auth status failed:`n$authText"
}
Log "gh auth status OK"

$repoInfo = Invoke-GhJson @("api", "repos/$Repo")
Log "repo default branch: $($repoInfo.default_branch)"
Log "repo pushed_at: $($repoInfo.pushed_at)"

$pr = Invoke-GhJson @("api", "repos/$Repo/pulls/$PrNumber")
Log "PR state: $($pr.state); draft: $($pr.draft); mergeable: $($pr.mergeable)"
Log "PR head: $($pr.head.ref) @ $($pr.head.sha)"
Log "PR base: $($pr.base.ref) @ $($pr.base.sha)"

$branchRef = Invoke-GhJson @("api", "repos/$Repo/git/ref/heads/$Branch")
Log "branch object sha: $($branchRef.object.sha)"

$runs = Invoke-GhJson @("api", "repos/$Repo/actions/runs?branch=$Branch&per_page=5")
$latestRun = $runs.workflow_runs | Select-Object -First 1
if ($latestRun) {
    Log "latest CI: $($latestRun.name); status=$($latestRun.status); conclusion=$($latestRun.conclusion); run=$($latestRun.id)"
} else {
    Log "latest CI: no workflow runs returned"
}

$root = Invoke-GhJson @("api", "repos/$Repo/contents?ref=$Branch")
$rootNames = @($root | ForEach-Object { $_.name })
foreach ($name in @("api551_00_gh_status.ps1", "api551_01_gh_pull_text_state.ps1", "api551_02_gh_upload_run_log.ps1")) {
    if ($rootNames -contains $name) { Log "active gh root script present: $name" }
    else { Log "active gh root script missing: $name" }
}
foreach ($name in @("api551_01_pull_from_github.ps1", "api551_02_sync_up.ps1", "api551_03_apply_task.ps1")) {
    if ($rootNames -contains $name) { Log "fallback git root script retained: $name" }
    else { Log "fallback git root script absent: $name" }
}
if ($rootNames -contains "scripts") {
    Log "scripts folder present"
} else {
    Log "scripts folder absent: OK"
}

Log "API551 gh status completed"
Log "Log file: $LogPath"
