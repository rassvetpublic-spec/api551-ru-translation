param(
    [string]$RepoUrl = "https://github.com/rassvetpublic-spec/api551-ru-translation.git",
    [string]$LocalPath = "C:\Downloads\API 551",
    [string]$Branch = "codex/archive-source-zips",
    [string]$CommitMessage = "Migrate review links to relative paths",
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"

function New-DirectoryIfMissing {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Write-Log {
    param([Parameter(Mandatory = $true)][string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    if ($script:LogPath) {
        Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    }
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$WorkingDirectory = (Get-Location).Path
    )

    $display = "$FilePath $($Arguments -join ' ')"
    Write-Log "RUN: $display"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    foreach ($arg in $Arguments) {
        [void]$psi.ArgumentList.Add($arg)
    }
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($stdout) {
        $stdout.TrimEnd() -split "`r?`n" | ForEach-Object {
            Write-Log "OUT: $_"
        }
    }
    if ($stderr) {
        $stderr.TrimEnd() -split "`r?`n" | ForEach-Object {
            Write-Log "ERR: $_"
        }
    }
    if ($process.ExitCode -ne 0) {
        throw "Command failed with exit code $($process.ExitCode): $display"
    }
}

function Get-TextFile {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Set-TextFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Convert-ToHtmlEncoded {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Get-RootPdfHref {
    param([Parameter(Mandatory = $true)][string]$Page)
    return "source/API%20551%202016%20(R2024).pdf#page=$Page"
}

function Get-FigurePdfHref {
    param([Parameter(Mandatory = $true)][string]$Page)
    return "../../../source/API%20551%202016%20(R2024).pdf#page=$Page"
}

function Normalize-CatalogPath {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $Value }
    if ($Value.StartsWith("figures/")) {
        return "workspace/$Value"
    }
    return $Value
}

function Update-Catalog {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $catalogPath = Join-Path $RepoRoot "catalog.json"
    $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json

    $catalog.layout = "portable local review package; unpack/use from any local project folder; PDF is included in source/"
    $catalog.pdf_expected_path = "source/API 551 2016 (R2024).pdf"

    $changed = 0
    foreach ($figure in $catalog.figures) {
        if ($figure.PSObject.Properties.Name -contains "pdf_page") {
            $figure.source_pdf_link = Get-RootPdfHref -Page ([string]$figure.pdf_page)
            $changed++
        }

        foreach ($name in @("folder", "html", "json", "png", "source_crop", "out_html")) {
            if ($figure.PSObject.Properties.Name -contains $name) {
                $old = [string]$figure.$name
                $new = Normalize-CatalogPath -Value $old
                if ($new -ne $old) {
                    $figure.$name = $new
                    $changed++
                }
            }
        }
    }

    $json = $catalog | ConvertTo-Json -Depth 100
    Set-TextFile -Path $catalogPath -Content ($json + [Environment]::NewLine)
    Write-Log "catalog.json updated; changed fields: $changed"
}

function Update-IndexHtml {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $catalogPath = Join-Path $RepoRoot "catalog.json"
    $indexPath = Join-Path $RepoRoot "index.html"
    $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json

    $rows = New-Object System.Collections.Generic.List[string]
    foreach ($figure in $catalog.figures) {
        $no = [int]$figure.figure_no
        $status = [string]$figure.status
        $class = "pending"
        if ($status -eq "accepted") {
            $class = "accepted"
        } elseif ($status.StartsWith("измененно_")) {
            $class = "changed"
        }

        $caption = Convert-ToHtmlEncoded -Text ([string]$figure.caption_ru)
        $statusHtml = Convert-ToHtmlEncoded -Text $status
        $pdfHref = Convert-ToHtmlEncoded -Text ([string]$figure.source_pdf_link)

        $exportCell = $caption
        if (($figure.PSObject.Properties.Name -contains "out_html") -and -not [string]::IsNullOrWhiteSpace([string]$figure.out_html)) {
            $outHref = Convert-ToHtmlEncoded -Text ([string]$figure.out_html)
            $exportCell = "<a href=""$outHref"">$caption</a>"
        }

        $serviceCell = ""
        if (($figure.PSObject.Properties.Name -contains "html") -and -not [string]::IsNullOrWhiteSpace([string]$figure.html)) {
            $serviceHref = Convert-ToHtmlEncoded -Text ([string]$figure.html)
            $serviceCell = "<a href=""$serviceHref"">service</a>"
        }

        $rows.Add("<tr class=""$class""><td>$no</td><td>$statusHtml</td><td>$exportCell</td><td>$serviceCell</td><td><a href=""$pdfHref"">PDF</a></td></tr>")
    }

    $accepted = [int]$catalog.stats.accepted
    $total = [int]$catalog.stats.total
    $changed = [int]$catalog.stats.changed
    $meta = "Accepted: $accepted/$total. Changed: $changed. Portable local review export; all links are relative to the repository root."

    $html = @"
<!doctype html>
<html lang="ru"><head><meta charset="utf-8"><title>API 551 Stage 4 - Figure catalog</title>
<style>
body{font-family:Arial,sans-serif;margin:24px;color:#111827;background:#f6f7f9}main{max-width:1240px;margin:0 auto;background:#fff;border:1px solid #d9dee7;padding:22px}h1{margin:0 0 8px;font-size:22px}.meta{color:#4b5563;margin-bottom:16px}table{width:100%;border-collapse:collapse;table-layout:fixed}th,td{border-bottom:1px solid #e5e7eb;padding:7px 8px;text-align:left;vertical-align:top;font-size:14px;word-break:normal;overflow-wrap:normal;hyphens:none}th:first-child,td:first-child{width:64px;text-align:right;white-space:nowrap}th:nth-child(2),td:nth-child(2){width:180px;white-space:nowrap}th:nth-child(4),td:nth-child(4){width:82px;white-space:nowrap}th:nth-child(5),td:nth-child(5){width:68px;white-space:nowrap}th:nth-child(3),td:nth-child(3){overflow-wrap:break-word;word-break:normal}tr.accepted td:nth-child(2){color:#166534;font-weight:700}tr.changed td:nth-child(2){color:#854d0e;font-weight:700}tr.pending td:nth-child(2){color:#991b1b}a{color:#0f3b7a}
</style></head><body><main>
<h1>API 551 Stage 4 - Figure catalog</h1>
<div class="meta">$meta</div>
<table><thead><tr><th>Figure</th><th>Status</th><th>Export object</th><th>Service</th><th>Source</th></tr></thead><tbody>$($rows -join "")</tbody></table>
</main></body></html>
"@

    Set-TextFile -Path $indexPath -Content $html
    Write-Log "index.html regenerated from catalog.json; rows: $($rows.Count)"
}

function Update-FigureHtmlFiles {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $figureRoot = Join-Path $RepoRoot "workspace\figures"
    $files = Get-ChildItem -LiteralPath $figureRoot -Recurse -File -Include "*.html"
    $changedFiles = 0
    $replacementCount = 0

    foreach ($file in $files) {
        $text = Get-TextFile -Path $file.FullName
        $oldText = $text

        $text = $text.Replace(
            "file:///C:/Downloads/API%20551/API%20551%202016%20(R2024).pdf#page=",
            "../../../source/API%20551%202016%20(R2024).pdf#page="
        )
        $text = $text.Replace(
            "file:///C:/Downloads/API 551/API 551 2016 (R2024).pdf#page=",
            "../../../source/API%20551%202016%20(R2024).pdf#page="
        )

        if ($text -ne $oldText) {
            Set-TextFile -Path $file.FullName -Content $text
            $changedFiles++
            $replacementCount += ([regex]::Matches($oldText, "file:///C:/Downloads/API")).Count
            Write-Log "updated Figure HTML: $($file.FullName.Substring($RepoRoot.Length + 1))"
        }
    }

    Write-Log "Figure HTML updated; files changed: $changedFiles; approximate replacements: $replacementCount"
}

function Update-WorkflowRelativeLinkCheck {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $workflowPath = Join-Path $RepoRoot ".github\workflows\structure-check.yml"
    $text = Get-TextFile -Path $workflowPath
    $marker = "Check portable relative review links"
    if ($text.Contains($marker)) {
        Write-Log "workflow relative link check already exists; skipped"
        return
    }

    $block = @'

      - name: Check portable relative review links
        run: |
          python3 - <<'PY'
          import json
          import re
          from pathlib import Path

          root_files = [Path("index.html"), Path("catalog.json")]
          figure_html = sorted(Path("workspace/figures").glob("*/figure_*.html"))
          files = root_files + figure_html
          for path in files:
              text = path.read_text(encoding="utf-8", errors="replace")
              if "file:///C:/" in text or "C:/Downloads/" in text:
                  raise SystemExit(f"absolute Windows path is forbidden: {path}")

          catalog = json.loads(Path("catalog.json").read_text(encoding="utf-8"))
          for fig in catalog.get("figures", []):
              link = fig.get("source_pdf_link", "")
              if not link.startswith("source/API%20551%202016%20(R2024).pdf#page="):
                  raise SystemExit(f"bad root PDF link for Figure {fig.get('figure_no')}: {link}")
              for key in ["folder", "html", "json", "png", "source_crop", "out_html"]:
                  value = fig.get(key)
                  if value and value.startswith("figures/"):
                      raise SystemExit(f"non-portable catalog path for Figure {fig.get('figure_no')} {key}: {value}")

          index = Path("index.html").read_text(encoding="utf-8", errors="replace")
          if 'href="figures/' in index:
              raise SystemExit("index.html still points to root figures/")
          if "source/API%20551%202016%20(R2024).pdf#page=" not in index:
              raise SystemExit("index.html has no relative source PDF links")

          for path in figure_html:
              text = path.read_text(encoding="utf-8", errors="replace")
              if "../../../source/API%20551%202016%20(R2024).pdf#page=" not in text:
                  raise SystemExit(f"Figure HTML has no relative source PDF link: {path}")
              for src in re.findall(r"<img[^>]+src=[\"']([^\"']+)[\"']", text, flags=re.I):
                  if src.startswith(("http://", "https://", "data:")):
                      continue
                  image_path = path.parent / src
                  if not image_path.is_file():
                      raise SystemExit(f"broken image reference {src} in {path}")
          print("portable relative review links OK")
          PY
'@

    $text = $text.TrimEnd() + $block + [Environment]::NewLine
    Set-TextFile -Path $workflowPath -Content $text
    Write-Log "workflow updated with portable relative review link check"
}

function Test-PortableLinks {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $catalogPath = Join-Path $RepoRoot "catalog.json"
    $indexPath = Join-Path $RepoRoot "index.html"
    $pdfPath = Join-Path $RepoRoot "source\API 551 2016 (R2024).pdf"

    $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $indexText = Get-TextFile -Path $indexPath
    $allTextFiles = @($catalogPath, $indexPath)
    $allTextFiles += (Get-ChildItem -LiteralPath (Join-Path $RepoRoot "workspace\figures") -Recurse -File -Include "*.html").FullName

    foreach ($path in $allTextFiles) {
        $text = Get-TextFile -Path $path
        if ($text.Contains("file:///C:/") -or $text.Contains("C:/Downloads/")) {
            throw "Absolute Windows path remains in $path"
        }
    }

    if ($indexText.Contains('href="figures/')) {
        throw "index.html still contains href=`"figures/"
    }

    if (-not $indexText.Contains("source/API%20551%202016%20(R2024).pdf#page=")) {
        throw "index.html does not contain relative root PDF links"
    }

    foreach ($figure in $catalog.figures) {
        if ($figure.PSObject.Properties.Name -contains "source_pdf_link") {
            $link = [string]$figure.source_pdf_link
            if (-not $link.StartsWith("source/API%20551%202016%20(R2024).pdf#page=")) {
                throw "Bad source_pdf_link for Figure $($figure.figure_no): $link"
            }
        }

        foreach ($key in @("folder", "html", "json", "png", "source_crop", "out_html")) {
            if ($figure.PSObject.Properties.Name -contains $key) {
                $value = [string]$figure.$key
                if ($value.StartsWith("figures/")) {
                    throw "Bad catalog path for Figure $($figure.figure_no) $key`: $value"
                }
                if ($value.StartsWith("workspace/")) {
                    $full = Join-Path $RepoRoot ($value -replace "/", "\")
                    if (-not (Test-Path -LiteralPath $full)) {
                        throw "Catalog file does not exist for Figure $($figure.figure_no) $key`: $value"
                    }
                }
            }
        }
    }

    $figureHtmlFiles = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "workspace\figures") -Recurse -File -Include "*.html"
    foreach ($file in $figureHtmlFiles) {
        $text = Get-TextFile -Path $file.FullName
        if (-not $text.Contains("../../../source/API%20551%202016%20(R2024).pdf#page=")) {
            throw "Figure HTML has no relative PDF link: $($file.FullName)"
        }
        $matches = [regex]::Matches($text, '<img[^>]+src=["'']([^"'']+)["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        foreach ($match in $matches) {
            $src = $match.Groups[1].Value
            if ($src.StartsWith("http://") -or $src.StartsWith("https://") -or $src.StartsWith("data:")) {
                continue
            }
            $imagePath = Join-Path $file.DirectoryName $src
            if (-not (Test-Path -LiteralPath $imagePath)) {
                throw "Broken image reference $src in $($file.FullName)"
            }
        }
    }

    if (-not (Test-Path -LiteralPath $pdfPath)) {
        throw "Source PDF is missing: $pdfPath"
    }
    $bytes = [System.IO.File]::ReadAllBytes($pdfPath)
    $head = [System.Text.Encoding]::ASCII.GetString($bytes, 0, [Math]::Min(5, $bytes.Length))
    if (-not $head.StartsWith("%PDF")) {
        throw "Source PDF is not real PDF content. Run git lfs pull."
    }

    Write-Log "portable link validation OK"
}

function Initialize-OrUpdateRepository {
    param(
        [Parameter(Mandatory = $true)][string]$RepoUrl,
        [Parameter(Mandatory = $true)][string]$LocalPath,
        [Parameter(Mandatory = $true)][string]$Branch
    )

    $parent = Split-Path -Parent $LocalPath
    New-DirectoryIfMissing -Path $parent

    if (-not (Test-Path -LiteralPath $LocalPath)) {
        Write-Log "local path does not exist; cloning repository"
        Invoke-LoggedCommand -FilePath "git" -Arguments @("clone", $RepoUrl, $LocalPath) -WorkingDirectory $parent
    } elseif (-not (Test-Path -LiteralPath (Join-Path $LocalPath ".git"))) {
        $items = Get-ChildItem -LiteralPath $LocalPath -Force -ErrorAction SilentlyContinue
        if ($items.Count -gt 0) {
            throw "LocalPath exists and is not empty Git repo: $LocalPath"
        }
        Write-Log "local path exists and is empty; cloning repository into it"
        Remove-Item -LiteralPath $LocalPath -Force
        Invoke-LoggedCommand -FilePath "git" -Arguments @("clone", $RepoUrl, $LocalPath) -WorkingDirectory $parent
    } else {
        Write-Log "local Git repository exists; updating it"
    }

    Invoke-LoggedCommand -FilePath "git" -Arguments @("fetch", "origin") -WorkingDirectory $LocalPath

    try {
        Invoke-LoggedCommand -FilePath "git" -Arguments @("switch", $Branch) -WorkingDirectory $LocalPath
    } catch {
        Write-Log "local branch switch failed; creating tracking branch"
        Invoke-LoggedCommand -FilePath "git" -Arguments @("switch", "-c", $Branch, "--track", "origin/$Branch") -WorkingDirectory $LocalPath
    }

    Invoke-LoggedCommand -FilePath "git" -Arguments @("reset", "--hard", "origin/$Branch") -WorkingDirectory $LocalPath

    Invoke-LoggedCommand -FilePath "git" -Arguments @("lfs", "version") -WorkingDirectory $LocalPath
    Invoke-LoggedCommand -FilePath "git" -Arguments @("lfs", "pull") -WorkingDirectory $LocalPath
}

$script:LogPath = $null
$repoReady = $false

try {
    $tempLogDir = Join-Path $env:TEMP "api551-run-logs"
    New-DirectoryIfMissing -Path $tempLogDir
    $stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $tempLogPath = Join-Path $tempLogDir "$stamp-relative-path-migration.log"
    $script:LogPath = $tempLogPath

    Write-Log "API551 relative path migration started"
    Write-Log "RepoUrl: $RepoUrl"
    Write-Log "LocalPath: $LocalPath"
    Write-Log "Branch: $Branch"
    Write-Log "NoPush: $NoPush"

    Initialize-OrUpdateRepository -RepoUrl $RepoUrl -LocalPath $LocalPath -Branch $Branch
    $repoReady = $true

    $runLogDir = Join-Path $LocalPath "docs\run-logs"
    New-DirectoryIfMissing -Path $runLogDir
    $finalLogPath = Join-Path $runLogDir "$stamp-relative-path-migration.log"
    Copy-Item -LiteralPath $tempLogPath -Destination $finalLogPath -Force
    $script:LogPath = $finalLogPath
    Write-Log "repository log path: $finalLogPath"

    $scriptDestDir = Join-Path $LocalPath "scripts"
    New-DirectoryIfMissing -Path $scriptDestDir
    if ($PSCommandPath) {
        $scriptDestPath = Join-Path $scriptDestDir "api551_migrate_relative_paths.ps1"
        Copy-Item -LiteralPath $PSCommandPath -Destination $scriptDestPath -Force
        Write-Log "script copied into repository: scripts/api551_migrate_relative_paths.ps1"
    } else {
        Write-Log "PSCommandPath is empty; script copy skipped"
    }

    Update-Catalog -RepoRoot $LocalPath
    Update-IndexHtml -RepoRoot $LocalPath
    Update-FigureHtmlFiles -RepoRoot $LocalPath
    Update-WorkflowRelativeLinkCheck -RepoRoot $LocalPath
    Test-PortableLinks -RepoRoot $LocalPath

    Invoke-LoggedCommand -FilePath "git" -Arguments @("status", "--short") -WorkingDirectory $LocalPath

    Invoke-LoggedCommand -FilePath "git" -Arguments @(
        "add",
        "catalog.json",
        "index.html",
        "workspace/figures",
        ".github/workflows/structure-check.yml",
        "scripts/api551_migrate_relative_paths.ps1",
        "docs/run-logs"
    ) -WorkingDirectory $LocalPath

    $porcelain = & git -C $LocalPath status --porcelain
    if ([string]::IsNullOrWhiteSpace(($porcelain | Out-String))) {
        Write-Log "no changes to commit"
    } else {
        Invoke-LoggedCommand -FilePath "git" -Arguments @("commit", "-m", $CommitMessage) -WorkingDirectory $LocalPath
        if (-not $NoPush) {
            Invoke-LoggedCommand -FilePath "git" -Arguments @("push", "origin", $Branch) -WorkingDirectory $LocalPath
        } else {
            Write-Log "NoPush set; push skipped"
        }
    }

    Write-Log "API551 relative path migration completed"
    Write-Host ""
    Write-Host "DONE. Log file:"
    Write-Host $script:LogPath
} catch {
    Write-Log "FAILED: $($_.Exception.Message)"
    if ($repoReady) {
        try {
            Invoke-LoggedCommand -FilePath "git" -Arguments @("status", "--short") -WorkingDirectory $LocalPath
        } catch {
            Write-Log "could not capture git status after failure: $($_.Exception.Message)"
        }
    }
    throw
}
