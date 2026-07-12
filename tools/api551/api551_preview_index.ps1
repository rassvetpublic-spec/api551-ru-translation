param(
  [string]$RepoRoot = 'C:\GIT\api551',
  [string]$RunId = '',
  [string]$Figure = '',
  [ValidateSet('review','blocker','accepted','skipped')]
  [string]$State = 'review',
  [string]$PreviewPng = '',
  [string]$Caption = '',
  [switch]$ValidateOnly
)
$ErrorActionPreference='Stop'
$RepoRoot=(Resolve-Path $RepoRoot).Path
if(!$RunId){$RunId=(Get-Content -LiteralPath (Join-Path $RepoRoot 'reports\codex-local\CURRENT_RUN_ID.txt') -Raw).Trim()}
if(!$Figure){throw 'Pass -Figure NNN'}
$fig3 = ('{0:d3}' -f [int]$Figure)
$index = Join-Path $RepoRoot 'index.html'
if (!(Test-Path -LiteralPath $index)) { throw "Root index not found: $index" }
if ($PreviewPng -and !(Test-Path -LiteralPath $PreviewPng)) { throw "Preview PNG not found: $PreviewPng" }
if ($ValidateOnly) {
  Write-Host "ValidateOnly PASS: Figure $fig3 state=$State; no files changed"
  return
}
$previewDir = Join-Path $RepoRoot "workspace\previews\$RunId\$fig3"
New-Item -ItemType Directory -Force $previewDir | Out-Null
$relImg = ''
if($PreviewPng -and (Test-Path -LiteralPath $PreviewPng)){
  $dst = Join-Path $previewDir ("figure_$fig3.preview.png")
  Copy-Item -LiteralPath $PreviewPng -Destination $dst -Force
  $relImg = "workspace/previews/$RunId/$fig3/figure_$fig3.preview.png"
}
$meta = [ordered]@{figure=$fig3;state=$State;caption=$Caption;image=$relImg;run_id=$RunId;updated=(Get-Date).ToUniversalTime().ToString('o')}
[IO.File]::WriteAllText((Join-Path $previewDir 'preview.json'),($meta|ConvertTo-Json -Depth 4),[Text.UTF8Encoding]::new($false))

$html = Get-Content -LiteralPath $index -Raw -Encoding UTF8
$start='<!-- API551_PREVIEW_QUEUE_START -->'
$end='<!-- API551_PREVIEW_QUEUE_END -->'
$items = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "workspace\previews\$RunId") -Recurse -File -Filter 'preview.json' -ErrorAction SilentlyContinue | ForEach-Object {
  $j=Get-Content $_.FullName -Raw|ConvertFrom-Json
  $captionSafe=[System.Net.WebUtility]::HtmlEncode([string]$j.caption)
  $color = switch($j.state){'review'{'#f59e0b'}'blocker'{'#dc2626'}'accepted'{'#16a34a'}default{'#6b7280'}}
  $img = if($j.image){"<img src='$($j.image)' alt='Figure $($j.figure) preview' style='max-width:260px;border:4px solid $color;border-radius:8px'>"}else{"<div style='width:260px;height:120px;border:4px solid $color;border-radius:8px;display:flex;align-items:center;justify-content:center'>no image</div>"}
  "<div class='api551-preview-card' style='border-left:8px solid $color;padding:8px;margin:8px;background:#fff7ed'><b>Figure $($j.figure)</b> — $($j.state)<br>$img<br><small>$captionSafe</small></div>"
}
$block = $start + "`n<section id='api551-preview-queue' style='padding:16px;border:3px dashed #f59e0b;margin:16px 0;background:#fffbeb'><h2>API551 Preview Queue — $RunId</h2>" + (($items|Out-String)) + "</section>`n" + $end
if($html.Contains($start) -and $html.Contains($end)){
  $html=[regex]::Replace($html,[regex]::Escape($start)+'.*?'+[regex]::Escape($end),[System.Text.RegularExpressions.MatchEvaluator]{param($m)$block},[System.Text.RegularExpressions.RegexOptions]::Singleline)
}else{
  $bodyMatch=[regex]::Match($html,'<body[^>]*>',[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if(!$bodyMatch.Success){throw 'Root index.html has no body element'}
  $insertAt=$bodyMatch.Index+$bodyMatch.Length
  $html=$html.Insert($insertAt,"`n"+$block)
}
[IO.File]::WriteAllText($index,$html,[Text.UTF8Encoding]::new($false))
Write-Host "Preview updated in index.html for Figure $fig3 state=$State"
