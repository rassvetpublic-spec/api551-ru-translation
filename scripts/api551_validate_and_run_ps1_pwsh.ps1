param(
    [Parameter(Mandatory=$false)]
    [string]$TargetScript,

    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$PassThruArgs
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[api551-pwsh-checker] $Message"
}

function Get-DownloadsPath {
    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.NameSpace('shell:Downloads')
        if ($null -ne $folder -and $null -ne $folder.Self -and -not [string]::IsNullOrWhiteSpace($folder.Self.Path)) {
            return $folder.Self.Path
        }
    } catch {
        # fallback below
    }

    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $candidate = Join-Path $env:USERPROFILE 'Downloads'
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw "Cannot resolve Downloads folder."
}

function Resolve-Pwsh {
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    }
    if ($null -eq $cmd) {
        throw "pwsh was not found in PATH. Install PowerShell 7 or add pwsh.exe to PATH."
    }
    return $cmd.Source
}

function Resolve-TargetScript {
    param([string]$ExplicitTarget)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitTarget)) {
        $resolved = Resolve-Path -LiteralPath $ExplicitTarget -ErrorAction Stop
        return $resolved.Path
    }

    $downloads = Get-DownloadsPath
    $target = Get-ChildItem -LiteralPath $downloads -Filter 'api551_*_pwsh.ps1' |
        Where-Object { $_.Name -ne 'api551_validate_and_run_ps1_pwsh.ps1' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $target) {
        throw "Target script not found in Downloads: api551_*_pwsh.ps1"
    }

    return $target.FullName
}

function Test-TargetScriptSafety {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Target script does not exist: $Path"
    }

    if ([IO.Path]::GetExtension($Path) -ne '.ps1') {
        throw "Target script must have .ps1 extension: $Path"
    }

    $downloads = Get-DownloadsPath
    $targetFull = [IO.Path]::GetFullPath($Path)
    $downloadsFull = [IO.Path]::GetFullPath($downloads)

    if (-not $targetFull.StartsWith($downloadsFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Target script must be located under Downloads. Target: $targetFull; Downloads: $downloadsFull"
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.Length -le 0) {
        throw "Target script is empty: $Path"
    }

    $hash = Get-FileHash -LiteralPath $Path -Algorithm SHA256
    Write-Step "Target: $Path"
    Write-Step "Size: $($item.Length) bytes"
    Write-Step "SHA256: $($hash.Hash.ToLowerInvariant())"
}

function Invoke-ParserValidation {
    param([string]$Path)

    Write-Step "Running pwsh parser validation..."
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors) | Out-Null

    if ($errors.Count -gt 0) {
        Write-Host "PowerShell parser errors:" -ForegroundColor Red
        $errors | Format-List * | Out-String | Write-Host
        throw "PS1 validation failed by pwsh parser."
    }

    Write-Step "pwsh parser validation: PASSED"
}

function Invoke-AnalyzerValidation {
    param([string]$Path)

    $cmd = Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        Write-Step "PSScriptAnalyzer unavailable; skipping analyzer validation."
        return "unavailable"
    }

    Write-Step "Running PSScriptAnalyzer..."
    $results = Invoke-ScriptAnalyzer -Path $Path -Severity Error,Warning

    if ($null -ne $results -and @($results).Count -gt 0) {
        $results | Format-Table -AutoSize | Out-String | Write-Host
        throw "PS1 validation failed by PSScriptAnalyzer."
    }

    Write-Step "PSScriptAnalyzer validation: PASSED"
    return "passed"
}

try {
    $pwsh = Resolve-Pwsh
    Write-Step "Using engine: $pwsh"

    $target = Resolve-TargetScript -ExplicitTarget $TargetScript

    Test-TargetScriptSafety -Path $target
    Invoke-ParserValidation -Path $target
    $analyzerStatus = Invoke-AnalyzerValidation -Path $target

    if ($analyzerStatus -eq "passed") {
        Write-Host "PS1 validation: PASSED by pwsh parser + PSScriptAnalyzer"
    } else {
        Write-Host "PS1 validation: PASSED by pwsh parser; PSScriptAnalyzer unavailable"
    }

    if ($ValidateOnly) {
        Write-Step "Checker ValidateOnly complete. Target was not executed."
        exit 0
    }

    Write-Step "Executing target script with pwsh..."
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $target)
    if ($null -ne $PassThruArgs -and $PassThruArgs.Count -gt 0) {
        $argList += $PassThruArgs
    }

    $proc = Start-Process -FilePath $pwsh -ArgumentList $argList -Wait -PassThru -NoNewWindow
    Write-Step "Target exit code: $($proc.ExitCode)"
    exit $proc.ExitCode
}
catch {
    Write-Host "[api551-pwsh-checker] FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
