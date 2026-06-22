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
$LogPath = Join-Path $LogDir "$Stamp-api551-pull.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

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
        throw "gh failed: gh $($Arguments -join ' ')`n$($output | Out-String)"
    }
    return ($output | Out-String | ConvertFrom-Json)
}

function ConvertTo-ApiPath([string]$Path) {
    return (($Path -split '/') | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
}

function Should-PullPath([string]$Path) {
    if ($Path -eq 'api551_pull.ps1') { return $true }
    if ($Path -match '^scripts/.*\.ps1$') { return $true }
    if ($Path -in @('README.md', '.gitignore', 'index.html', 'catalog.json')) { return $true }
    if ($Path -match '^\.github/workflows/.*\.ya?ml$') { return $true }
    if ($Path -match '^source/.*\.(json|md|csv)$') { return $true }
    if ($Path -match '^workspace/figures/\d{3}/figure_\d{3}\.(object|out)\.html$') { return $true }
    if ($Path -match '^workspace/figures/\d{3}/figure_\d{3}\.object\.json$') { return $true }
    if ($Path -match '^archive/extracted-reference/.*\.json$') { return $true }
    if ($Path -match '^archive/cleanup-history/.*\.md$') { return $true }
    if ($Path -match '^tasks/.*\.(ps1|md|json|txt)$') { return $true }
    if ($Path -match '^docs/.*\.(md|json|csv|txt|log)$') { return $true }
    return $false
}

function Download-TextFile([string]$RepoPath) {
    $apiPath = ConvertTo-ApiPath $RepoPath
    $ref = [System.Uri]::EscapeDataString($Branch)
    $endpoint = "repos/$Repo/contents/$apiPath`?ref=$ref"
    $output = & gh api -H "Accept: application/vnd.github.raw" $endpoint 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "download failed: $RepoPath`n$($output | Out-String)"
    }
    $destination = Join-Path $LocalPath ($RepoPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    $dir = Split-Path -Parent $destination
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($destination, (($output | Out-String).TrimEnd("`r", "`n") + "`r`n"), $Utf8NoBom)
}

function Remove-ObsoleteRootScripts {
    $obsolete = @(
        'api551_00_gh_status.ps1',
        'api551_01_gh_pull_text_state.ps1',
        'api551_02_gh_upload_run_log.ps1',
        'api551_01_pull_from_github.ps1',
        'api551_02_sync_up.ps1',
        'api551_03_apply_task.ps1'
    )
    foreach ($name in $obsolete) {
        $path = Join-Path $LocalPath $name
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            Remove-Item -LiteralPath $path -Force
            Log "removed obsolete root script: $name"
        }
    }
}

Log "API551 pull started"
Log "Repo: $Repo"
Log "Branch: $Branch"
Log "PR: #$PrNumber"
Log "LocalPath: $LocalPath"

Require-Command "gh"
New-Item -ItemType Directory -Force -Path $LocalPath | Out-Null

$ghVersion = (& gh --version | Select-Object -First 1)
Log "gh: $ghVersion"

$auth = & gh auth status -h github.com 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "gh auth status failed:`n$($auth | Out-String)"
}
Log "gh auth status OK"

$refData = Invoke-GhJson @("api", "repos/$Repo/git/ref/heads/$Branch")
$headSha = [string]$refData.object.sha
$commit = Invoke-GhJson @("api", "repos/$Repo/git/commits/$headSha")
$treeSha = [string]$commit.tree.sha
$tree = Invoke-GhJson @("api", "repos/$Repo/git/trees/$treeSha`?recursive=1")

Log "remote head: $headSha"

$paths = @($tree.tree | Where-Object { $_.type -eq 'blob' } | ForEach-Object { [string]$_.path } | Where-Object { Should-PullPath $_ } | Sort-Object -Unique)
Log "text files selected: $($paths.Count)"

$count = 0
foreach ($path in $paths) {
    Download-TextFile $path
    $count++
}
Log "downloaded text files: $count"

Remove-ObsoleteRootScripts

$pr = Invoke-GhJson @("api", "repos/$Repo/pulls/$PrNumber")
Log "PR state: $($pr.state); draft: $($pr.draft); mergeable: $($pr.mergeable)"
Log "PR head: $($pr.head.ref) @ $($pr.head.sha)"
Log "PR base: $($pr.base.ref) @ $($pr.base.sha)"

$runs = Invoke-GhJson @("api", "repos/$Repo/actions/runs?branch=$Branch&per_page=5")
$latestRun = $runs.workflow_runs | Select-Object -First 1
if ($latestRun) {
    Log "latest CI: $($latestRun.name); status=$($latestRun.status); conclusion=$($latestRun.conclusion); run=$($latestRun.id)"
} else {
    Log "latest CI: no workflow runs returned"
}

$rootFiles = Get-ChildItem -LiteralPath $LocalPath -File -Filter "api551*.ps1" | Select-Object -ExpandProperty Name | Sort-Object
Log "local root api551 scripts: $($rootFiles -join ', ')"

Log "API551 pull completed"
Log "Log file: $LogPath"
