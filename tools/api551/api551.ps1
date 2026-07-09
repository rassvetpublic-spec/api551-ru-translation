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

$python = "python"
& $python $PythonScript $Action @Rest
exit $LASTEXITCODE
