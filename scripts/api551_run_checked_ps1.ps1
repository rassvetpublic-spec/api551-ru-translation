# API 551 — universal checked PowerShell launcher
# Purpose:
#   Validate any target .ps1 before execution, then run it only when -Run is explicitly provided.
#
# Typical use:
#   powershell -ExecutionPolicy Bypass -File .\api551_run_checked_ps1.ps1 -TargetPattern 'target*.ps1'
#   powershell -ExecutionPolicy Bypass -File .\api551_run_checked_ps1.ps1 -TargetPattern 'target*.ps1' -Run -TargetArgs '-ValidateOnly'
#
# Validation:
#   - target exists and is .ps1
#   - target SHA-256 is printed and optionally matched
#   - PowerShell parser validates target before execution
#   - PSScriptAnalyzer runs if installed, unless -NoAnalyzer is used
#   - high-risk patterns require -AllowRisk when -Run is used

param(
    [string]$TargetPattern,
    [string]$TargetPath,
    [string]$SearchDir,
    [string[]]$TargetArgs = @(),
    [string]$ExpectedSha256,
    [switch]$Run,
    [switch]$AllowRisk,
    [switch]$NoAnalyzer,
    [switch]$StrictAnalyzer,
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host ("ERROR: " + $Message) -ForegroundColor Red
    exit 1
}

function Get-DownloadsPath {
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.NameSpace("shell:Downloads")
    if ($null -eq $folder) {
        Fail "Cannot resolve Downloads folder."
    }
    return $folder.Self.Path
}

function Get-ScriptSha256 {
    param([string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Resolve-TargetScript {
    if ($TargetPath) {
        $resolved = Resolve-Path -LiteralPath $TargetPath -ErrorAction Stop
        return $resolved.Path
    }

    if (-not $TargetPattern) {
        Fail "Provide -TargetPattern or -TargetPath."
    }

    $baseDir = $SearchDir
    if (-not $baseDir) {
        $baseDir = Get-DownloadsPath
    }

    if (-not (Test-Path -LiteralPath $baseDir)) {
        Fail ("SearchDir not found: " + $baseDir)
    }

    $matches = @(Get-ChildItem -LiteralPath $baseDir -Filter $TargetPattern -File | Sort-Object LastWriteTime -Descending)

    if ($matches.Count -eq 0) {
        Fail ("No target script found by pattern '" + $TargetPattern + "' in " + $baseDir)
    }

    if ($matches.Count -gt 1) {
        Write-Host "Multiple candidates found; using newest:" -ForegroundColor Yellow
        $matches | Select-Object -First 5 | ForEach-Object {
            Write-Host ("  " + $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") + "  " + $_.FullName)
        }
        Write-Host ""
    }

    return $matches[0].FullName
}

function Test-PowerShellSyntax {
    param([string]$Path)

    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors) | Out-Null

    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "PowerShell parser errors:" -ForegroundColor Red
        $errors | Format-List *
        Fail "PowerShell parser validation failed."
    }
}

function Invoke-AnalyzerIfAvailable {
    param([string]$Path)

    if ($NoAnalyzer) {
        Write-Host "PSScriptAnalyzer: skipped by -NoAnalyzer." -ForegroundColor Yellow
        return
    }

    $analyzer = Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue
    if ($null -eq $analyzer) {
        Write-Host "PSScriptAnalyzer: unavailable; skipped." -ForegroundColor Yellow
        return
    }

    $findings = @(Invoke-ScriptAnalyzer -Path $Path -Severity Error,Warning)
    if ($findings.Count -eq 0) {
        Write-Host "PSScriptAnalyzer: OK." -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "PSScriptAnalyzer findings:" -ForegroundColor Yellow
    $findings | Format-Table -AutoSize

    $errorFindings = @($findings | Where-Object { $_.Severity -eq "Error" })
    if ($errorFindings.Count -gt 0) {
        Fail "PSScriptAnalyzer found error-level diagnostics."
    }

    if ($StrictAnalyzer) {
        Fail "PSScriptAnalyzer warnings found and -StrictAnalyzer is enabled."
    }

    Write-Host "PSScriptAnalyzer: warnings only; continuing." -ForegroundColor Yellow
}

function Get-HighRiskFindings {
    param([string]$Path)

    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8

    $patterns = @(
        [pscustomobject]@{ Name = "git reset --hard"; Pattern = "git\s+.*reset\s+--hard" },
        [pscustomobject]@{ Name = "git clean -fd"; Pattern = "git\s+.*clean\s+-[^\r\n]*f[^\r\n]*d|git\s+.*clean\s+-[^\r\n]*d[^\r\n]*f" },
        [pscustomobject]@{ Name = "git push"; Pattern = "git\s+.*push" },
        [pscustomobject]@{ Name = "remote delete"; Pattern = "--delete|:\s*refs/heads/" },
        [pscustomobject]@{ Name = "branch -D"; Pattern = "git\s+.*branch\s+-D" },
        [pscustomobject]@{ Name = "gh api DELETE"; Pattern = "gh\s+.*api\s+.*DELETE|gh\s+.*api\s+.*-X\s+DELETE" },
        [pscustomobject]@{ Name = "gh pr merge"; Pattern = "gh\s+.*pr\s+merge" },
        [pscustomobject]@{ Name = "Remove-Item"; Pattern = "\bRemove-Item\b" },
        [pscustomobject]@{ Name = "delete_file marker"; Pattern = "\bdelete_file\b" },
        [pscustomobject]@{ Name = "force ref update"; Pattern = "\bupdate_ref\b|--force|git\s+.*push\s+.*-f" }
    )

    $found = New-Object System.Collections.Generic.List[string]

    foreach ($item in $patterns) {
        if ([regex]::IsMatch($text, $item.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $found.Add([string]$item.Name) | Out-Null
        }
    }

    return @($found)
}

function Assert-SafeTargetPath {
    param([string]$Path)

    if ([IO.Path]::GetExtension($Path).ToLowerInvariant() -ne ".ps1") {
        Fail ("Target is not a .ps1 file: " + $Path)
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Fail ("Target file not found: " + $Path)
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.Length -le 0) {
        Fail ("Target file is empty: " + $Path)
    }
}

function Show-FileInfo {
    param([string]$Path)

    $item = Get-Item -LiteralPath $Path
    $sha = Get-ScriptSha256 -Path $Path

    Write-Host ("Target: " + $Path)
    Write-Host ("Size:   " + $item.Length + " bytes")
    Write-Host ("SHA256: " + $sha)

    if ($ExpectedSha256) {
        $expected = $ExpectedSha256.ToLowerInvariant()
        if ($sha -ne $expected) {
            Fail ("SHA-256 mismatch. Expected " + $expected + ", got " + $sha)
        }
        Write-Host "SHA-256 expected value: OK." -ForegroundColor Green
    }
}

function Invoke-TargetScript {
    param(
        [string]$Path,
        [string[]]$ScriptArgs
    )

    Write-Host ""
    Write-Host "Running target script..." -ForegroundColor Cyan
    Write-Host ("Args: " + ($ScriptArgs -join " "))

    & powershell -NoProfile -ExecutionPolicy Bypass -File $Path @ScriptArgs
    $code = $LASTEXITCODE

    Write-Host ""
    Write-Host ("Target exit code: " + $code)

    exit $code
}

if ($SelfTest) {
    $self = $MyInvocation.MyCommand.Path
    Write-Host "=== API 551 checked launcher self-test ===" -ForegroundColor Cyan
    Show-FileInfo -Path $self
    Test-PowerShellSyntax -Path $self
    Write-Host "PowerShell parser: OK." -ForegroundColor Green
    Invoke-AnalyzerIfAvailable -Path $self
    Write-Host ""
    Write-Host "SELFTEST PASSED." -ForegroundColor Green
    exit 0
}

$target = Resolve-TargetScript

Write-Host "=== API 551 checked PS1 launcher ===" -ForegroundColor Cyan
Assert-SafeTargetPath -Path $target
Show-FileInfo -Path $target
Write-Host ""

Test-PowerShellSyntax -Path $target
Write-Host "PowerShell parser: OK." -ForegroundColor Green

Invoke-AnalyzerIfAvailable -Path $target

$riskFindings = @(Get-HighRiskFindings -Path $target)
if ($riskFindings.Count -gt 0) {
    Write-Host ""
    Write-Host "High-risk patterns found:" -ForegroundColor Yellow
    $riskFindings | ForEach-Object { Write-Host ("  - " + $_) -ForegroundColor Yellow }

    if ($Run -and (-not $AllowRisk)) {
        Fail "Target contains high-risk operations. Re-run with -AllowRisk only after reviewing ValidateOnly output."
    }
}

if (-not $Run) {
    Write-Host ""
    Write-Host "VALIDATION PASSED. Target was not executed because -Run was not provided." -ForegroundColor Green
    exit 0
}

Invoke-TargetScript -Path $target -ScriptArgs $TargetArgs
