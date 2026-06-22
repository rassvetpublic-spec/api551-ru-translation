param(
    [string]$Repo = "rassvetpublic-spec/api551-ru-translation",
    [string]$Branch = "codex/archive-source-zips",
    [string]$LocalPath = "C:\Downloads\API 551"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-01-gh-pull-text-state.log"
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
    if ($Path -match '^api551_.*\.ps1$') { return $true }
    if ($Path -in @('README.md', '.gitignore', 'index.html', 'catalog.json')) { return $true }
    if ($Path -match '^\.github/workflows/.*\.ya?ml$') { return $true }
    if ($Path -match '^source/.*\.(json|md|csv)$') { return $true }
    if ($Path -match '^workspace/figures/\d{3}/figure_\d{3}\.(object|out)\.html$') { return $true }
    if ($Path -match '^workspace/figures/\d{3}/figure_\d{3}\.object\.json$') { return $true }
    if ($Path -match '^archive/extracted-reference/.*\.json$') { return $true }
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

Log "API551 gh pull text state started"
Log "Repo: $Repo"
Log "Branch: $Branch"
Log "LocalPath: $LocalPath"

Require-Command "gh"
New-Item -ItemType Directory -Force -Path $LocalPath | Out-Null

$refData = Invoke-GhJson @("api", "repos/$Repo/git/ref/heads/$Branch")
$headSha = [string]$refData.object.sha
$commit = Invoke-GhJson @("api", "repos/$Repo/git/commits/$headSha")
$treeSha = [string]$commit.tree.sha
$tree = Invoke-GhJson @("api", "repos/$Repo/git/trees/$treeSha`?recursive=1")

$paths = @($tree.tree | Where-Object { $_.type -eq 'blob' } | ForEach-Object { [string]$_.path } | Where-Object { Should-PullPath $_ } | Sort-Object -Unique)
Log "text files selected: $($paths.Count)"

$count = 0
foreach ($path in $paths) {
    Download-TextFile $path
    $count++
}

Log "downloaded text files: $count"
Log "API551 gh pull text state completed"
Log "Log file: $LogPath"
