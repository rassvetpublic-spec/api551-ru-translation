param(
    [Parameter(Mandatory=$true)]
    [string]$ZipPath,

    [Parameter(Mandatory=$false)]
    [int]$FigureNo = 0
)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    throw "[api551-overlay-sanity:FAIL] $Message"
}

function Step([string]$Message) {
    Write-Host "[api551-overlay-sanity] $Message"
}

if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    Fail "ZIP not found: $ZipPath"
}
if ([System.IO.Path]::GetExtension($ZipPath).ToLowerInvariant() -ne ".zip") {
    Fail "File is not .zip: $ZipPath"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entries = @($zip.Entries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.FullName) -and -not $_.FullName.EndsWith("/") })
    if ($entries.Count -eq 0) {
        Fail "ZIP contains no files"
    }

    $forbiddenRoot = @()
    $badPath = @()
    $figurePrefix = $null
    if ($FigureNo -gt 0) {
        $figurePrefix = "workspace/figures/{0:D3}/" -f $FigureNo
    }

    foreach ($entry in $entries) {
        $name = $entry.FullName.Replace("\", "/")

        if ($name.StartsWith("/") -or $name.Contains("../") -or $name.Contains("/../")) {
            $badPath += $name
            continue
        }

        if ($name -notmatch "/") {
            $forbiddenRoot += $name
        }

        if ($FigureNo -gt 0 -and -not $name.StartsWith($figurePrefix)) {
            $badPath += $name
        }

        if ($name -match "(^|/)(debug|temp|tmp)/" -or $name -match "\.log$") {
            $badPath += $name
        }
    }

    if ($forbiddenRoot.Count -gt 0) {
        Fail "ZIP contains root files: $($forbiddenRoot -join ', ')"
    }
    if ($badPath.Count -gt 0) {
        Fail "ZIP contains forbidden paths: $($badPath -join ', ')"
    }

    if ($FigureNo -gt 0) {
        $required = @(
            ("workspace/figures/{0:D3}/figure_{0:D3}.png" -f $FigureNo),
            ("workspace/figures/{0:D3}/figure_{0:D3}.source_crop.png" -f $FigureNo),
            ("workspace/figures/{0:D3}/figure_{0:D3}.object.json" -f $FigureNo),
            ("workspace/figures/{0:D3}/figure_{0:D3}.object.html" -f $FigureNo),
            ("workspace/figures/{0:D3}/figure_{0:D3}.out.html" -f $FigureNo)
        )
        $names = @($entries | ForEach-Object { $_.FullName.Replace("\", "/") })
        $missing = @($required | Where-Object { $_ -notin $names })
        if ($missing.Count -gt 0) {
            Fail "ZIP missing required Figure files: $($missing -join ', ')"
        }
    }

    $hash = Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256
    Step "ZIP OK: $ZipPath"
    Step "Entries: $($entries.Count)"
    Step "SHA256: $($hash.Hash.ToLowerInvariant())"
}
finally {
    $zip.Dispose()
}
