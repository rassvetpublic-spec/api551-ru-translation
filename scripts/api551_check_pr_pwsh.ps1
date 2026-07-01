param(
    [Parameter(Mandatory=$true)]
    [int]$PrNumber,

    [Parameter(Mandatory=$false)]
    [string]$Repo = "rassvetpublic-spec/api551-ru-translation"
)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    throw "[api551-pr-check:FAIL] $Message"
}

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Fail "Required command not found: $Name"
    }
}

function Run-GhText([string[]]$Args, [switch]$AllowFailure) {
    Write-Host ("> gh " + ($Args -join " "))
    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & gh @Args 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldEap
    }
    if ($null -ne $output) {
        foreach ($line in $output) { Write-Host (($line | Out-String).TrimEnd()) }
    }
    if (($code -ne 0) -and (-not $AllowFailure)) {
        Fail "gh exited with code $code"
    }
    if ($AllowFailure) { return [int]$code }
}

Require-Command "gh"

$json = & gh pr view $PrNumber --repo $Repo --json number,url,state,isDraft,mergeable,baseRefName,headRefName,headRefOid,changedFiles,additions,deletions,commits,title 2>&1
if ($LASTEXITCODE -ne 0) {
    Fail "gh pr view failed:`n$($json | Out-String)"
}

$pr = ($json | Out-String | ConvertFrom-Json)

Write-Host "[api551-pr-check] PR #$($pr.number): $($pr.title)"
Write-Host "[api551-pr-check] URL: $($pr.url)"
Write-Host "[api551-pr-check] State: $($pr.state); Draft: $($pr.isDraft); Mergeable: $($pr.mergeable)"
Write-Host "[api551-pr-check] Base: $($pr.baseRefName); Head: $($pr.headRefName)"
Write-Host "[api551-pr-check] Head SHA: $($pr.headRefOid)"
Write-Host "[api551-pr-check] Changed files: $($pr.changedFiles); additions: $($pr.additions); deletions: $($pr.deletions)"
Write-Host "[api551-pr-check] Commits: $($pr.commits.Count)"

Run-GhText @("pr", "diff", [string]$PrNumber, "--repo", $Repo, "--name-only")
Run-GhText @("pr", "checks", [string]$PrNumber, "--repo", $Repo) -AllowFailure

if ($pr.state -ne "OPEN") {
    Write-Host "[api551-pr-check] WARNING: PR is not open."
}
if ($pr.isDraft) {
    Write-Host "[api551-pr-check] WARNING: PR is draft."
}
