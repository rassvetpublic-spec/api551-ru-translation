param(
    [Parameter(Mandatory=$false)]
    [string]$RepoPath = "C:\GIT\API 551",

    [Parameter(Mandatory=$false)]
    [string]$MainBranch = "main",

    [Parameter(Mandatory=$false)]
    [string]$WorkBranch = "candidates",

    [Parameter(Mandatory=$false)]
    [string[]]$TempBranches = @(),

    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,

    [Parameter(Mandatory=$false)]
    [switch]$AssumeYes
)

$ErrorActionPreference = "Stop"

function Step([string]$Message) {
    Write-Host "[api551-cleanup] $Message"
}

function Fail([string]$Message) {
    throw "[api551-cleanup:FAIL] $Message"
}

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Fail "Не найдена обязательная команда: $Name"
    }
}

function Run-Native {
    param(
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    Write-Host ("> " + $FilePath + " " + ($Arguments -join " "))

    # Важно: git и gh иногда пишут штатные сообщения в stderr.
    # Поэтому фатальным считается код возврата, а не сам факт вывода в stderr.
    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $FilePath @Arguments 2>&1
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
        Fail "$FilePath завершился с кодом $code"
    }

    if ($AllowFailure) {
        return [int]$code
    }
}

function Get-NativeText {
    param(
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$Arguments
    )

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $FilePath @Arguments 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldEap
    }

    if ($code -ne 0) {
        Fail "$FilePath $($Arguments -join ' ') завершился с кодом $code. $($output | Out-String)"
    }

    return (($output | Out-String).Trim())
}

function Get-RemoteHeadSha([string]$BranchName) {
    $text = Get-NativeText "git" @("ls-remote", "--heads", "origin", $BranchName)
    $first = ($text -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($first)) {
        Fail "Remote-ветка не найдена: $BranchName"
    }
    return (($first -split "\s+")[0])
}

function Get-AheadBehind {
    param(
        [Parameter(Mandatory=$true)][string]$BaseRef,
        [Parameter(Mandatory=$true)][string]$HeadRef
    )
    $text = Get-NativeText "git" @("rev-list", "--left-right", "--count", "$BaseRef...$HeadRef")
    $parts = $text -split "\s+"
    return [pscustomobject]@{
        Behind = [int]$parts[0]
        Ahead = [int]$parts[1]
    }
}

Step "Проверка перед синхронизацией веток."
Step "RepoPath=$RepoPath"
Step "MainBranch=$MainBranch"
Step "WorkBranch=$WorkBranch"
Step "ValidateOnly=$ValidateOnly"

Require-Command "git"

if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
    Fail "Папка репозитория не найдена: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

$origin = Get-NativeText "git" @("config", "--get", "remote.origin.url")
if ($origin -notmatch "rassvetpublic-spec/api551-ru-translation(\.git)?$") {
    Fail "Неожиданный origin: $origin"
}
Step "Origin=$origin"

# Single-branch clone может не иметь origin/main локально.
# Поэтому явно подтягиваем обе remote-tracking ветки.
Run-Native "git" @("fetch", "origin", "+refs/heads/$MainBranch`:refs/remotes/origin/$MainBranch", "+refs/heads/$WorkBranch`:refs/remotes/origin/$WorkBranch", "--prune")

$mainSha = Get-NativeText "git" @("rev-parse", "origin/$MainBranch")
$workSha = Get-NativeText "git" @("rev-parse", "origin/$WorkBranch")
$remoteMainSha = Get-RemoteHeadSha $MainBranch
$remoteWorkSha = Get-RemoteHeadSha $WorkBranch
$state = Get-AheadBehind -BaseRef "origin/$MainBranch" -HeadRef "origin/$WorkBranch"

Step "origin/$MainBranch=$mainSha"
Step "origin/$WorkBranch=$workSha"
Step "remote $MainBranch=$remoteMainSha"
Step "remote $WorkBranch=$remoteWorkSha"
Step "$WorkBranch относительно $MainBranch: ahead=$($state.Ahead), behind=$($state.Behind)"

if ($state.Ahead -gt 0) {
    Fail "$WorkBranch содержит уникальные коммиты относительно $MainBranch. Нельзя сбрасывать без отдельного PR/решения."
}

$needsSync = ($mainSha -ne $workSha)
if ($needsSync) {
    Step "План: fast-forward/sync $WorkBranch до $MainBranch."
} else {
    Step "$WorkBranch уже совпадает с $MainBranch."
}

$existingRemoteTemp = @()
foreach ($branch in $TempBranches) {
    if ([string]::IsNullOrWhiteSpace($branch)) { continue }
    if ($branch -in @($MainBranch, $WorkBranch)) {
        Fail "В списке временных веток запрещённая ветка: $branch"
    }
    $code = Run-Native "git" @("ls-remote", "--exit-code", "--heads", "origin", $branch) -AllowFailure
    if ($code -eq 0) {
        $existingRemoteTemp += $branch
    }
}

if ($existingRemoteTemp.Count -gt 0) {
    Step "План удаления временных remote-веток: $($existingRemoteTemp -join ', ')"
} else {
    Step "Временные remote-ветки из списка не найдены."
}

if ($ValidateOnly) {
    Step "ValidateOnly завершён. Изменений не внесено."
    exit 0
}

if (($needsSync -or $existingRemoteTemp.Count -gt 0) -and -not $AssumeYes) {
    $answer = Read-Host "Введите CLEANUP для синхронизации веток и удаления перечисленных временных веток"
    if ($answer -ne "CLEANUP") {
        Fail "Подтверждение не получено; остановка."
    }
}

if ($needsSync) {
    Run-Native "git" @("push", "origin", "refs/remotes/origin/$MainBranch`:refs/heads/$WorkBranch")
}

foreach ($branch in $existingRemoteTemp) {
    Run-Native "git" @("push", "origin", "--delete", $branch)
}

Run-Native "git" @("fetch", "origin", "+refs/heads/$MainBranch`:refs/remotes/origin/$MainBranch", "+refs/heads/$WorkBranch`:refs/remotes/origin/$WorkBranch", "--prune")
Run-Native "git" @("checkout", $WorkBranch)
Run-Native "git" @("reset", "--hard", "origin/$WorkBranch")
Run-Native "git" @("clean", "-fdx")
Run-Native "git" @("lfs", "pull")

$finalState = Get-AheadBehind -BaseRef "origin/$MainBranch" -HeadRef "origin/$WorkBranch"
if ($finalState.Ahead -ne 0 -or $finalState.Behind -ne 0) {
    Fail "После cleanup ветки не совпадают: ahead=$($finalState.Ahead), behind=$($finalState.Behind)"
}

$status = Get-NativeText "git" @("status", "--short")
if (-not [string]::IsNullOrWhiteSpace($status)) {
    Fail "Рабочая папка не чистая после cleanup:`n$status"
}

Step "Готово: $MainBranch == $WorkBranch, временные ветки удалены, локальная рабочая папка чистая."
