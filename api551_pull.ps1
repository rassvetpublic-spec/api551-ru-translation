param(
    [string]$Repo = "rassvetpublic-spec/api551-ru-translation",
    [string]$Branch = "main",
    [int]$PrNumber = 0,
    [string]$LocalPath = "C:\Downloads\API 551"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogDir = Join-Path $LocalPath "docs\run-logs"
$LogPath = Join-Path $LogDir "$Stamp-api551-pull.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$script:OriginalConsoleOutputEncoding = [Console]::OutputEncoding
[Console]::OutputEncoding = $Utf8NoBom
$OutputEncoding = $Utf8NoBom
$script:RemoteHeadSha = $null
$script:GithubToken = $null

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

function ConvertTo-UrlPath([string]$Path) {
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
    if ($Path -match '^workspace/figures/\d{3}/.*\.png$') { return $true }
    if ($Path -match '^archive/extracted-reference/.*\.json$') { return $true }
    if ($Path -match '^archive/cleanup-history/.*\.md$') { return $true }
    if ($Path -match '^tasks/.*\.(ps1|md|json|txt)$') { return $true }
    if ($Path -match '^docs/.*\.(md|json|csv|txt|log)$') { return $true }
    return $false
}

function Test-PngFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "PNG file missing after download: $Path"
    }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $sig = [byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A)
    if ($bytes.Length -lt 8) {
        throw "PNG file too small after download: $Path"
    }
    for ($i = 0; $i -lt 8; $i++) {
        if ($bytes[$i] -ne $sig[$i]) {
            $headText = [System.Text.Encoding]::ASCII.GetString($bytes, 0, [Math]::Min($bytes.Length, 120))
            if ($headText.StartsWith("version https://git-lfs.github.com/spec/v1")) {
                throw "Downloaded LFS pointer instead of PNG: $Path"
            }
            throw "Downloaded file is not PNG: $Path"
        }
    }
}

function Invoke-GhRawToFile([string]$Endpoint, [string]$Destination) {
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("api551-gh-raw-" + [System.Guid]::NewGuid().ToString("N") + ".tmp")
    try {
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = "gh"
        foreach ($arg in @("api", "-H", "Accept: application/vnd.github.raw", $Endpoint)) {
            [void]$psi.ArgumentList.Add($arg)
        }
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true

        $process = [System.Diagnostics.Process]::Start($psi)
        $stdout = $process.StandardOutput.BaseStream
        $file = [System.IO.File]::Open($temp, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try { $stdout.CopyTo($file) }
        finally { $file.Dispose() }
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            throw "gh raw download failed: $Endpoint`n$stderr"
        }

        $dir = Split-Path -Parent $Destination
        if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Move-Item -LiteralPath $temp -Destination $Destination -Force
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}

function Invoke-MediaToFile([string]$RepoPath, [string]$Destination) {
    if ([string]::IsNullOrWhiteSpace($script:RemoteHeadSha)) {
        throw "Remote head SHA is not initialized"
    }
    if ([string]::IsNullOrWhiteSpace($script:GithubToken)) {
        $script:GithubToken = (& gh auth token 2>$null | Select-Object -First 1).Trim()
        if ([string]::IsNullOrWhiteSpace($script:GithubToken)) {
            throw "Cannot get GitHub token from gh auth token"
        }
    }

    $urlPath = ConvertTo-UrlPath $RepoPath
    $url = "https://media.githubusercontent.com/media/$Repo/$($script:RemoteHeadSha)/$urlPath"
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("api551-media-" + [System.Guid]::NewGuid().ToString("N") + ".tmp")
    try {
        $headers = @{
            Authorization = "Bearer $($script:GithubToken)"
            Accept = "application/octet-stream"
            "User-Agent" = "api551-pull"
        }
        Invoke-WebRequest -Uri $url -Headers $headers -OutFile $temp -UseBasicParsing -MaximumRedirection 10
        $dir = Split-Path -Parent $Destination
        if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Move-Item -LiteralPath $temp -Destination $Destination -Force
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}

function Download-RepositoryFile([string]$RepoPath) {
    $destination = Join-Path $LocalPath ($RepoPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    if ($RepoPath -match '\.png$') {
        Invoke-MediaToFile -RepoPath $RepoPath -Destination $destination
        Test-PngFile -Path $destination
        return
    }

    $apiPath = ConvertTo-ApiPath $RepoPath
    $ref = [System.Uri]::EscapeDataString($Branch)
    $endpoint = "repos/$Repo/contents/$apiPath`?ref=$ref"
    Invoke-GhRawToFile -Endpoint $endpoint -Destination $destination
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

try {
    Log "API551 pull started"
    Log "Repo: $Repo"
    Log "Branch: $Branch"
    if ($PrNumber -gt 0) { Log "PR: #$PrNumber" } else { Log "PR: skipped" }
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
    $script:RemoteHeadSha = $headSha
    $commit = Invoke-GhJson @("api", "repos/$Repo/git/commits/$headSha")
    $treeSha = [string]$commit.tree.sha
    $tree = Invoke-GhJson @("api", "repos/$Repo/git/trees/$treeSha`?recursive=1")

    Log "remote head: $headSha"

    $paths = @($tree.tree | Where-Object { $_.type -eq 'blob' } | ForEach-Object { [string]$_.path } | Where-Object { Should-PullPath $_ } | Sort-Object -Unique)
    $pngCount = @($paths | Where-Object { $_ -match '\.png$' }).Count
    Log "files selected: $($paths.Count), png assets: $pngCount"

    $count = 0
    foreach ($path in $paths) {
        Download-RepositoryFile $path
        $count++
    }
    Log "downloaded files: $count"

    Remove-ObsoleteRootScripts

    if ($PrNumber -gt 0) {
        $pr = Invoke-GhJson @("api", "repos/$Repo/pulls/$PrNumber")
        Log "PR state: $($pr.state); draft: $($pr.draft); mergeable: $($pr.mergeable)"
        Log "PR head: $($pr.head.ref) @ $($pr.head.sha)"
        Log "PR base: $($pr.base.ref) @ $($pr.base.sha)"
    } else {
        Log "PR check skipped"
    }

    $runs = Invoke-GhJson @("api", "repos/$Repo/actions/runs?branch=$Branch&per_page=5")
    $latestRun = $runs.workflow_runs | Select-Object -First 1
    if ($latestRun) {
        Log "latest CI: $($latestRun.name); status=$($latestRun.status); conclusion=$($latestRun.conclusion); run=$($latestRun.id)"
    } else {
        Log "latest CI: no workflow runs returned"
    }

    $rootFiles = Get-ChildItem -LiteralPath $LocalPath -File -Filter "api551*.ps1" | Select-Object -ExpandProperty Name | Sort-Object
    Log "local root api551 scripts: $($rootFiles -join ', ')"

    $localPngCount = @(Get-ChildItem -LiteralPath (Join-Path $LocalPath "workspace\figures") -Recurse -Filter "*.png" -File -ErrorAction SilentlyContinue).Count
    Log "local PNG files present: $localPngCount"

    Log "API551 pull completed"
    Log "Log file: $LogPath"
}
finally {
    [Console]::OutputEncoding = $script:OriginalConsoleOutputEncoding
}
