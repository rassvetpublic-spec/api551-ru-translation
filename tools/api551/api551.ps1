param(
    [Parameter(Position = 0)]
    [string]$Action = "source-gate",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

cls
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
$PythonScript = Join-Path $ScriptDir "api551.py"

if (-not (Test-Path -LiteralPath $PythonScript -PathType Leaf)) {
    throw "API551 toolkit core not found: $PythonScript"
}

$PythonCandidates = @(
    @{ Command = "py"; Args = @("-3") },
    @{ Command = "python"; Args = @() },
    @{ Command = "python3"; Args = @() }
)

$SelectedPython = $null
foreach ($Candidate in $PythonCandidates) {
    $Command = [string]$Candidate.Command
    $CommandInfo = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $CommandInfo) {
        continue
    }

    $VersionArgs = @($Candidate.Args) + @("--version")
    & $Command @VersionArgs *> $null
    if ($LASTEXITCODE -eq 0) {
        $SelectedPython = $Candidate
        break
    }
}

if (-not $SelectedPython) {
    throw "Python runtime not found. Install Python 3 or make one of these commands available in PATH: py -3, python, python3."
}

$PythonCommand = [string]$SelectedPython.Command
$PythonArgs = @($SelectedPython.Args)
& $PythonCommand @PythonArgs $PythonScript $Action @Rest
exit $LASTEXITCODE
