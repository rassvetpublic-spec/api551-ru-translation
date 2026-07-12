param(
  [string]$Downloads = 'D:\ЗАГРУЗКИ',
  [string]$Inbox = 'C:\GIT\inbox_chatgpt',
  [string]$RepoRoot = 'C:\GIT\api551',
  [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'

function Step([string]$Text) { Write-Host "[API551-005] $Text" }
function Stop-Here([string]$Text) { throw "[STOP] $Text" }

if ($ValidateOnly) {
  $pkg = Join-Path $Downloads 'API551_CODEX_005_FULL_CONTROL_PACK_20260712.zip'
  $dst = Join-Path $Inbox 'API551_CODEX_005_FULL_CONTROL_PACK_20260712'
  if (!(Test-Path -LiteralPath $RepoRoot)) { Stop-Here "Repo not found: $RepoRoot" }
  if (!(Test-Path -LiteralPath $dst) -and !(Test-Path -LiteralPath $pkg)) {
    Stop-Here "Neither extracted package nor source ZIP is available"
  }
  Step "ValidateOnly PASS: bootstrap prerequisites are available; no files changed"
  return
}

New-Item -ItemType Directory -Force $Inbox | Out-Null

# При необходимости распаковать пакет 005.
$pkg = Join-Path $Downloads 'API551_CODEX_005_FULL_CONTROL_PACK_20260712.zip'
$dst = Join-Path $Inbox 'API551_CODEX_005_FULL_CONTROL_PACK_20260712'
if (!(Test-Path -LiteralPath $dst)) {
  if (!(Test-Path -LiteralPath $pkg)) { Stop-Here "Package not found: $pkg" }
  Step "extract package 005 to inbox"
  Expand-Archive -Force -LiteralPath $pkg -DestinationPath $Inbox
}

if (!(Test-Path -LiteralPath $RepoRoot)) { Stop-Here "Repo not found: $RepoRoot" }

# Создать локальные каталоги артефактов внутри репозитория.
$dirs = @(
  (Join-Path $RepoRoot '_local_artifacts'),
  (Join-Path $RepoRoot '_local_artifacts\review_queue'),
  (Join-Path $RepoRoot 'reports\codex-local')
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force $d | Out-Null }

# Добавить только локальные исключения, не менять .gitignore.
$exclude = (& git -C $RepoRoot rev-parse --git-path info/exclude).Trim()
if (!(Test-Path -LiteralPath $exclude)) { New-Item -ItemType File -Force $exclude | Out-Null }
$exText = Get-Content -LiteralPath $exclude -Raw -ErrorAction SilentlyContinue
foreach ($line in @('_local_artifacts/','reports/codex-local/','reports/source_gate/')) {
  if ($exText -notmatch ('(?m)^' + [regex]::Escape($line) + '$')) {
    Add-Content -LiteralPath $exclude -Value $line -Encoding utf8
  }
}

# Создать идентификатор запуска, если он ещё не задан.
$current = Join-Path $RepoRoot 'reports\codex-local\CURRENT_RUN_ID.txt'
if (!(Test-Path -LiteralPath $current)) {
  $sha = (& git -C $RepoRoot rev-parse --short HEAD).Trim()
  $runId = (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + $sha
  [IO.File]::WriteAllText($current, $runId, [Text.UTF8Encoding]::new($false))
} else {
  $runId = (Get-Content -LiteralPath $current -Raw).Trim()
}
$runRoot = Join-Path $RepoRoot ("reports\codex-local\" + $runId)
New-Item -ItemType Directory -Force $runRoot | Out-Null

# Сохранить реестр пакета в локальном журнале запуска.
Copy-Item -LiteralPath (Join-Path $dst 'PACKAGE_REGISTRY.json') -Destination (Join-Path $runRoot 'PACKAGE_REGISTRY_005.json') -Force
[IO.File]::WriteAllText((Join-Path $runRoot 'WRITE_BOUNDARY_ACTIVE.txt'), "Allowed persistent writes: C:\GIT\api551 and C:\GIT\inbox_chatgpt only.`nReview ZIPs: C:\GIT\api551\_local_artifacts\review_queue\$runId`n", [Text.UTF8Encoding]::new($false))

Step "run id: $runId"
Step "repo artifact root ready"
Step "TOKEN_SAVER active"
Write-Host "Next: read tasks\CODEX_FULL_CONTROL_TASK.md"
