param(
    [string]$Repo = "rassvetpublic-spec/api551-ru-translation",
    [string]$Branch = "codex/archive-source-zips",
    [string]$LocalPath = "C:\Downloads\API 551",
    [string]$LogPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Invoke-GhJson([string[]]$Arguments, [object]$Body = $null, [switch]$AllowNotFound) {
    $temp = $null
    try {
        if ($null -ne $Body) {
            $temp = [System.IO.Path]::GetTempFileName()
            $json = $Body | ConvertTo-Json -Depth 10 -Compress
            [System.IO.File]::WriteAllText($temp, $json, $Utf8NoBom)
            $Arguments = @($Arguments + @("--input", $temp))
        }
        $output = & gh @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) {
            $text = ($output | Out-String)
            if ($AllowNotFound -and $text -match 'Not Found') { return $null }
            throw "gh failed: gh $($Arguments -join ' ')`n$text"
        }
        return ($output | Out-String | ConvertFrom-Json)
    }
    finally {
        if ($temp -and (Test-Path -LiteralPath $temp)) { Remove-Item -LiteralPath $temp -Force }
    }
}

function ConvertTo-ApiPath([string]$Path) {
    return (($Path -split '/') | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
}

Require-Command "gh"

$runLogDir = Join-Path $LocalPath "docs\run-logs"
if ([string]::IsNullOrWhiteSpace($LogPath)) {
    $latest = Get-ChildItem -LiteralPath $runLogDir -Filter "*.log" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "No .log files found in $runLogDir" }
    $LogPath = $latest.FullName
}

$fullLogPath = [System.IO.Path]::GetFullPath($LogPath)
$fullRunLogDir = [System.IO.Path]::GetFullPath($runLogDir)
if (-not $fullLogPath.StartsWith($fullRunLogDir, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to upload a file outside docs/run-logs: $fullLogPath"
}
if (-not (Test-Path -LiteralPath $fullLogPath -PathType Leaf)) {
    throw "Log file not found: $fullLogPath"
}
if ([System.IO.Path]::GetExtension($fullLogPath) -ne ".log") {
    throw "Only .log files are allowed: $fullLogPath"
}
$fileInfo = Get-Item -LiteralPath $fullLogPath
if ($fileInfo.Length -gt 1048576) {
    throw "Log file is larger than 1 MiB: $fullLogPath"
}

$repoPath = "docs/run-logs/$($fileInfo.Name)"
$apiPath = ConvertTo-ApiPath $repoPath
$ref = [System.Uri]::EscapeDataString($Branch)
$existing = Invoke-GhJson @("api", "repos/$Repo/contents/$apiPath`?ref=$ref") -AllowNotFound
$content = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fullLogPath))
$body = @{
    message = "Add API551 local run log"
    branch = $Branch
    content = $content
}
if ($existing -and $existing.sha) { $body.sha = [string]$existing.sha }

$result = Invoke-GhJson @("api", "repos/$Repo/contents/$apiPath", "-X", "PUT") $body
Write-Host "Uploaded run log: $repoPath"
Write-Host "Commit: $($result.commit.sha)"
