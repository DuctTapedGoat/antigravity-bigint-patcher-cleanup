# =====================================================================================
#  Antigravity BigInt Unpatcher for Windows
# =====================================================================================

$targetFile = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity\resources\app\out\main.js'
$backupFile = "$targetFile.bak" # The original, unpatched file backup
$patchedBackupFile = "$targetFile.patched.bak" # A backup of the patched file

# --- Utility Functions ---

function Write-Header($title) {
    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "             $title" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# --- Main Application Loop ---

if (-not (Test-Path $targetFile)) {
    Write-Header "Error"
    Write-Host "  Antigravity main.js not found at $targetFile" -ForegroundColor Red
    Read-Host "  Press Enter to exit."
    exit
}

$easyPatchLogic = '(_k, v) => typeof v === "bigint" ? v.toString() : v'

# Regexes for UNPATCHING
$riskyUnpatchRegex = 'JSON\.stringify\((.*),\s*\(_k, v\)\s*=>\s*{\s*let\s*_r\s*=\s*\((.*?)\)\(_k, v\);\s*return\s*typeof\s*_r\s*===\s*"bigint"\s*\?\s*_r\.toString\(\)\s*:\s*_r;\s*}(,.*?)?\)'
$easyUnpatchRegex = 'JSON\.stringify\((.*)\,\s*' + '\(_k,\s*v\)\s*=>\s*typeof\s*v\s*===\s*"bigint"\s*\?\s*v\.toString\(\)\s*:\s*v' + '\)'


while ($true) {
    Write-Header "Windows BigInt Omni-Unpatcher v9"
    $content = Get-Content -Raw $targetFile

    $allRegex = 'JSON\.stringify\((?:[^()]|\([^()]*\))*\)'
    $allFoundMatches = [regex]::Matches($content, $allRegex)
    $hits = @()
    $lineNumber = 1
    $currentPos = 0

    foreach ($m in $allFoundMatches) {
        $text = $m.Value
        $index = $m.Index
        $gap = $content.Substring($currentPos, $index - $currentPos)
        $lineNumber += ($gap -split "`n").Length - 1
        $currentPos = $index

        $status = "unpatched"
        $type = "unknown"

        if ($text -like "*let _r =*bigint*") {
            $status = "patched"
            $type = "risky"
        } elseif ($text -match [regex]::escape($easyPatchLogic)) {
            $status = "patched"
            $type = "easy"
        }

        $hits += [PSCustomObject]@{ Text=$text; Index=$index; Line=$lineNumber; Type=$type; Status=$status }
    }

    $patchedEasy = ($hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'easy' }).Count
    $patchedRisky = ($hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'risky' }).Count
    $unpatchedCount = ($hits | Where-Object { $_.Status -eq 'unpatched' }).Count

    Write-Host "  File Scan Results:"
    Write-Host "  [X] Patched (Easy):   $patchedEasy" -ForegroundColor Green
    Write-Host "  [!] Patched (Risky):  $patchedRisky" -ForegroundColor Yellow
    Write-Host "  [ ] Unpatched:        $unpatchedCount"
    Write-Host ""
    Write-Host "  OPTIONS:" -ForegroundColor Gray
    Write-Host "  1. Bulk UNPATCH all EASY ($patchedEasy)"
    Write-Host "  2. Bulk UNPATCH all RISKY ($patchedRisky)" -ForegroundColor Yellow
    Write-Host "  3. Restore from backup ($backupFile)"
    Write-Host "  4. Exit"
    Write-Host ""

    $choice = Read-Host "  Enter Option#"

    if ($choice -eq "4") { exit }

    # Create a backup of the currently patched file before we modify it
    if (($choice -eq "1" -or $choice -eq "2") -and -not (Test-Path $patchedBackupFile)) {
         Write-Host "  Creating backup of patched file to $patchedBackupFile..." -ForegroundColor Yellow
         Copy-Item $targetFile $patchedBackupFile -Force
    }

    $newContent = $content

    if ($choice -eq "1") { # UNPATCH EASY
        if ($patchedEasy -eq 0) { Write-Host "  No easy patches to remove."; Start-Sleep 1; continue }
        $sortedEasy = $hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'easy' } | Sort-Object Index -Descending
        foreach ($h in $sortedEasy) {
            $replacement = $h.Text -replace $easyUnpatchRegex, 'JSON.stringify($1)'
            $newContent = $newContent.Remove($h.Index, $h.Text.Length).Insert($h.Index, $replacement)
        }
        $content = $newContent
        Set-Content -Path $targetFile -Value $content -NoNewline -Encoding UTF8
        Write-Host "  Easy Bulk Unpatch Applied!" -ForegroundColor Green; Start-Sleep 2
    }

    if ($choice -eq "2") { # UNPATCH RISKY
        if ($patchedRisky -eq 0) { Write-Host "  No risky patches to remove."; Start-Sleep 1; continue }
         $sortedRisky = $hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'risky' } | Sort-Object Index -Descending
        foreach ($h in $sortedRisky) {
            $replacement = $h.Text -replace $riskyUnpatchRegex, 'JSON.stringify($1, $2$3)' # $3 handles potential extra args
            $newContent = $newContent.Remove($h.Index, $h.Text.Length).Insert($h.Index, $replacement)
        }
        $content = $newContent
        Set-Content -Path $targetFile -Value $content -NoNewline -Encoding UTF8
        Write-Host "  Risky Bulk Unpatch Applied!" -ForegroundColor Green; Start-Sleep 2
    }

    if ($choice -eq "3") { # RESTORE BACKUP
        if (Test-Path $backupFile) {
            Write-Host "  Restoring original file from $backupFile..." -ForegroundColor Yellow
            Copy-Item $backupFile $targetFile -Force
            Write-Host "  Restore complete!" -ForegroundColor Green
        } else {
            Write-Host "  Backup file not found ($backupFile)." -ForegroundColor Red
        }
        Start-Sleep 2
    }
}