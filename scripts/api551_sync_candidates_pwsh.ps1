param(
    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "C:\GIT\API 551",

    [Parameter(Mandatory=$false)]
    [string]$Branch = "candidates",

    [Parameter(Mandatory=$false)]
    [switch]$AllowReset,

    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"

function Step([string]$Message) {
    Write-Host "[api551-sync] $Message"
}

function Fail([string]$Message) {
    throw "[api551-sync:FAIL] $Message"
}

function Run-Git {
    param(
        [Parameter(Mandatory=$true)][string[]]$Args,
        [switch]$AllowFailure
    )

    Write-Host ("> git " + ($Args -join " "))
    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @Args 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldEap
    }

    if ($null -ne $output) {
        foreach ($line in $output) {
            Write-Host (($line | Out-String).TrimEnd())
        }
    }

    if (($code -ne 0) -and (-not $AllowFailure)) {
        Fail "git exited with code $code"
    }

    if ($AllowFailure) {
        return [int]$code
    }
}

Step "RepoPath=$RepoPath"
Step "Branch=$Branch"
Step "ValidateOnly=$ValidateOnly"
Step "AllowReset=$AllowReset"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "git is not available"
}
if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue) -and -not (Get-Command "git-lfs.exe" -ErrorAction SilentlyContinue)) {
    Step "git-lfs command not found directly; checking via git lfs version"
}
Run-Git @("lfs", "version")

if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
    Fail "Repo folder not found: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

$origin = (& git config --get remote.origin.url).Trim()
if ($origin -notmatch "rassvetpublic-spec/api551-ru-translation(\.git)?$") {
    Fail "Unexpected git origin: $origin"
}
Step "Origin=$origin"

Run-Git @("fetch", "origin", "--prune")
Run-Git @("show-ref", "--verify", "--quiet", "refs/remotes/origin/$Branch")

$currentStatus = (& git status --porcelain) -join "`n"
if (-not [string]::IsNullOrWhiteSpace($currentStatus)) {
    Step "Working tree is not clean:"
    Write-Host $currentStatus
    if (-not $AllowReset) {
        Fail "Refusing to reset dirty working tree without -AllowReset"
    }
}

if ($ValidateOnly) {
    Step "ValidateOnly complete. No reset/clean/pull was performed."
    exit 0
}

Run-Git @("checkout", $Branch)
Run-Git @("reset", "--hard", "origin/$Branch")
Run-Git @("clean", "-fdx")
Run-Git @("lfs", "pull")

$head = (& git rev-parse --short HEAD).Trim()
$currentBranch = (& git branch --show-current).Trim()
$status = (& git status --short) -join "`n"

Step "HEAD=$head"
Step "CurrentBranch=$currentBranch"
if (-not [string]::IsNullOrWhiteSpace($status)) {
    Fail "Working tree is not clean after sync:`n$status"
}
Step "DONE. Working tree clean."
