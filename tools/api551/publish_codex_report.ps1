param(
  [string]$RepoRoot = 'C:\GIT\api551',
  [string]$RunId = '',
  [string]$BaseBranch = 'main',
  [switch]$NoPr,
  [switch]$ValidateOnly
)
$ErrorActionPreference = 'Stop'
function Stop-Here([string]$Text) { throw "[STOP] $Text" }
function W([string]$Path,[string]$Text){$d=Split-Path -Parent $Path;if($d){New-Item -ItemType Directory -Force $d|Out-Null};[IO.File]::WriteAllText($Path,$Text,[Text.UTF8Encoding]::new($false))}
function Redact([string]$s){ if(!$s){return ''}; $s=[regex]::Replace($s,'(?i)gh[pousr]_[A-Za-z0-9_]+','[REDACTED]'); $s=[regex]::Replace($s,'(?i)github_pat_[A-Za-z0-9_]+','[REDACTED]'); $s=[regex]::Replace($s,'(?i)(authorization:\s*bearer\s+)\S+','$1[REDACTED]'); return $s }
function G([string[]]$a){$o=& git -C $RepoRoot @a 2>&1;if($LASTEXITCODE-ne 0){$o|Write-Host;Stop-Here ("git failed "+($a-join ' '))};$o}
$RepoRoot=(Resolve-Path $RepoRoot).Path
if(!$RunId){$RunId=(Get-Content -LiteralPath (Join-Path $RepoRoot 'reports\codex-local\CURRENT_RUN_ID.txt') -Raw).Trim()}
$local=Join-Path $RepoRoot "reports\codex-local\$RunId"
if(!(Test-Path $local)){Stop-Here "No local report: $local"}
$branch="codex-report-$RunId"
$wt=Join-Path (Split-Path -Parent $RepoRoot) "api551_report_worktree_$RunId"
$rel="reports/codex/$RunId"
if ($ValidateOnly) {
  if (!(Get-Command git -ErrorAction SilentlyContinue)) { Stop-Here 'git is unavailable' }
  if (!(Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))) { Stop-Here "Not a Git checkout: $RepoRoot" }
  Write-Host "ValidateOnly PASS: local report=$local branch=$branch base=$BaseBranch; no files changed"
  return
}
$env:GIT_LFS_SKIP_SMUDGE='1'
G @('fetch','origin')|Out-Null
$wtlist=& git -C $RepoRoot worktree list --porcelain
if(($wtlist -join "`n") -match [regex]::Escape($wt)){Stop-Here "Report worktree already exists: $wt"}
$remote=& git -C $RepoRoot ls-remote --heads origin $branch
if($remote){G @('worktree','add','-B',$branch,$wt,"origin/$branch")|Out-Null}else{G @('worktree','add','-B',$branch,$wt,"origin/$BaseBranch")|Out-Null}
$rroot=Join-Path $wt ($rel -replace '/','\')
New-Item -ItemType Directory -Force $rroot|Out-Null
$names=@('CHATGPT_HANDOFF.md','HANDOFF.md','SUMMARY.json','CHECKS.json','BLOCKERS.md','GIT_STATE.md','PYTHON_TOOLCHAIN.md','BROWSER_TEST.md','DECISIONS.md','PACKAGE_REGISTRY_005.json','WRITE_BOUNDARY_ACTIVE.txt')
foreach($n in $names){$src=Join-Path $local $n;if(Test-Path $src){$txt=Get-Content -LiteralPath $src -Raw -Encoding UTF8; if($txt.Length -gt 900000){$txt=($txt.Substring([Math]::Max(0,$txt.Length-900000)))}; W (Join-Path $rroot $n) (Redact $txt)}}
foreach($pair in @(@('EVENTS.jsonl','EVENTS_TAIL.jsonl'),@('COMMANDS.log','COMMANDS_TAIL.log'))){$src=Join-Path $local $pair[0]; if(Test-Path $src){W (Join-Path $rroot $pair[1]) (Redact ((Get-Content $src -Tail 500 -Encoding UTF8)|Out-String))}}
$arts=@()
foreach($base in @($local,(Join-Path $RepoRoot '_local_artifacts'))){if(Test-Path $base){Get-ChildItem $base -Recurse -File -ErrorAction SilentlyContinue|Where-Object{$_.Extension -match '(?i)\.(zip|png|jpg|jpeg|pdf|html)$'}|ForEach-Object{$arts += [ordered]@{local_path=$_.FullName;bytes=$_.Length;sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant();committed=$false}}}}
W (Join-Path $rroot 'LOCAL_ARTIFACTS_MANIFEST.json') ([ordered]@{run_id=$RunId;report_branch=$branch;artifacts=$arts}|ConvertTo-Json -Depth 8)
W (Join-Path $rroot 'HANDOFF_FOR_CHATGPT.md') "# API551 Codex report`n`n- run_id: $RunId`n- branch: $branch`n- local full logs: $local`n- artifacts: see LOCAL_ARTIFACTS_MANIFEST.json`n- draft PR; do not merge.`n"
$bad=Get-ChildItem $rroot -Recurse -File|Where-Object{$_.Extension -match '(?i)\.(zip|png|jpg|jpeg|pdf|webp|7z|exe|dll|bin|html|htm)$'}
if($bad){Stop-Here ("Forbidden report files: "+(($bad|% FullName)-join '; '))}
& git -C $wt add $rel|Out-Null
$st=& git -C $wt status --short
if($st){& git -C $wt commit -m "Report Codex run $RunId"|Out-Null}
& git -C $wt push -u origin $branch|Out-Null
if(!$NoPr -and (Get-Command gh -ErrorAction SilentlyContinue)){
  $existing=& gh pr list --repo rassvetpublic-spec/api551-ru-translation --head $branch --json number,url --state open|ConvertFrom-Json
  if($existing.Count -gt 0){Write-Host $existing[0].url}else{
    $body=Join-Path $local "PR_BODY_$RunId.md"; W $body "- run ID: $RunId`n- text-only report branch: $branch`n- do not merge`n"
    & gh pr create --repo rassvetpublic-spec/api551-ru-translation --draft --base $BaseBranch --head $branch --title "[REPORT] API551 Codex run $RunId" --body-file $body
  }
}
G @('worktree','remove',$wt)|Out-Null
Write-Host "Codex report branch: $branch"
