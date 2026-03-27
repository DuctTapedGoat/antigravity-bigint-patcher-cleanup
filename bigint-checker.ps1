# =====================================================================================
#  Antigravity BigInt Checker for Windows
# =====================================================================================

$targetFile = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity\resources\app\out\main.js'
$logFile = Join-Path $PSScriptRoot 'bigint-checker.log'

# --- Utility Functions ---

function Write-Header($title) {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host "             $title" -ForegroundColor Cyan
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host ""
}

# --- Main --- 

if (-not (Test-Path $targetFile)) {
    Write-Header "Error"
    Write-Host "  Antigravity main.js not found at $targetFile" -ForegroundColor Red
    exit
}

# Classification logic from the patcher to identify unpatched types
function Get-Classification {
    param($text)
    if ($text -notmatch '^JSON\.stringify\((.*)\)$') { return @{ Type = 'unknown' } }
    $argsContent = $Matches[1]
    if ([string]::IsNullOrWhiteSpace($argsContent)) { return @{ Type = 'easy' } }

    $depth = 0; $inString = $false; $stringChar = ''; $isEscaped = $false; ${first_comm-index} = -1
    for ($i = 0; $i -lt $argsContent.Length; $i++) {
        $char = $argsContent[$i]
        if ($isEscaped) { $isEscaped = $false; continue }
        if ($char -eq '\') { $isEscaped = $true; continue }
        if (($char -eq "'" -or $char -eq '"' -or $char -eq '`')) {
            if ($inString -and $char -eq $stringChar) { $inString = $false } elseif (-not $inString) { $inString = $true; $stringChar = $char }
        }
        if ($inString) { continue }
        if ($char -eq '(' -or $char -eq '{' -or $char -eq '[') { $depth++ }
        elseif ($char -eq ')' -or $char -eq '}' -or $char -eq ']') { $depth-- }
        if ($char -eq ',' -and $depth -eq 0) { ${first_comm-index} = $i; break }
    }

    if (${first_comm-index} -eq -1) { return @{ Type = 'easy' } }
    else {
        $secondArg = $argsContent.Substring(${first_comm-index} + 1).Trim()
        if ($secondArg.StartsWith('null') -or $secondArg.StartsWith('void 0') -or $secondArg.StartsWith('undefined')) { return @{ Type = 'easy' } }
        else { return @{ Type = 'risky' } }
    }
}

while ($true) {
    Write-Header "Windows BigInt Checker for Google Antigravity"

    # --- Scanning Logic ---
    Write-Host "  Scanning $targetFile..."
    $content = Get-Content -Raw $targetFile
    $allRegex = 'JSON\.stringify\((?:[^()]|\([^()]*\))*\)'
    $allMatches = [regex]::Matches($content, $allRegex)
    $easyPatchLogic = '(_k, v) => typeof v === "bigint" ? v.toString() : v'
    
    $allItems = @()
    $lineNumber = 1
    $currentPos = 0

    $allMatches | ForEach-Object {
        $matchText = $_.Value
        $matchIdx  = $_.Index
        $gapText = $content.Substring($currentPos, $matchIdx - $currentPos)
        $lineNumber += ($gapText.Split("`n").Count - 1)
        $currentPos = $matchIdx
        
        $item = [PSCustomObject]@{
            Line = $lineNumber
            Position = $matchIdx
            Text = $matchText
            Type = ''
            Color = 'Gray'
        }

        if ($matchText -like "*let _r =*bigint*") {
            $item.Type = 'Patched (Risky)'
            $item.Color = 'Cyan'
        } elseif ($matchText -like "*$easyPatchLogic*") {
            $item.Type = 'Patched (Easy)'
            $item.Color = 'Green'
        } else {
            $classification = Get-Classification -text $matchText
            if ($classification.Type -eq 'easy') {
                $item.Type = 'Unpatched (Easy)'
                $item.Color = 'Red'
            } else {
                $item.Type = 'Unpatched (Risky)'
                $item.Color = 'Yellow'
            }
        }
        $allItems += $item
    }

    # --- Console Summary ---
    $patchedEasyCount = ($allItems | Where-Object { $_.Type -eq 'Patched (Easy)' }).Count
    $patchedRiskyCount = ($allItems | Where-Object { $_.Type -eq 'Patched (Risky)' }).Count
    $unpatchedEasyCount = ($allItems | Where-Object { $_.Type -eq 'Unpatched (Easy)' }).Count
    $unpatchedRiskyCount = ($allItems | Where-Object { $_.Type -eq 'Unpatched (Risky)' }).Count

    Write-Host "  Scan Complete!"
    Write-Host "  - Patched (Easy):    $patchedEasyCount" -ForegroundColor Green
    Write-Host "  - Patched (Risky):   $patchedRiskyCount" -ForegroundColor Cyan
    Write-Host "  - Unpatched (Easy):  $unpatchedEasyCount" -ForegroundColor Red
    Write-Host "  - Unpatched (Risky): $unpatchedRiskyCount" -ForegroundColor Yellow
    Write-Host ""
    
    # --- Interactive Menu ---
    Write-Host "  OPTIONS:" -ForegroundColor Gray
    Write-Host "  1. Show All items"
    Write-Host "  2. Show Patched (Easy) items"
    Write-Host "  3. Show Patched (Risky) items"
    Write-Host "  4. Show Unpatched (Easy) items"
    Write-Host "  5. Show Unpatched (Risky) items"
    Write-Host "  6. Save log and Exit"
    Write-Host ""
    $choice = Read-Host "  Enter Option#"

    switch ($choice) {
        '1' {
            Write-Header "All JSON.stringify Calls ($($allItems.Count))"
            $allItems | ForEach-Object { Write-Host "  [L:$($_.Line)|P:$($_.Position)] $($_.Text)" -ForegroundColor $_.Color }
            Read-Host "`n  Press Enter to return to menu"
        }
        '2' {
            Write-Header "Patched Calls (Easy) ($patchedEasyCount)"
            ($allItems | Where-Object { $_.Type -eq 'Patched (Easy)' }) | ForEach-Object { Write-Host "  [L:$($_.Line)|P:$($_.Position)] $($_.Text)" -ForegroundColor $_.Color }
            Read-Host "`n  Press Enter to return to menu"
        }
        '3' {
            Write-Header "Patched Calls (Risky) ($patchedRiskyCount)"
            ($allItems | Where-Object { $_.Type -eq 'Patched (Risky)' }) | ForEach-Object { Write-Host "  [L:$($_.Line)|P:$($_.Position)] $($_.Text)" -ForegroundColor $_.Color }
            Read-Host "`n  Press Enter to return to menu"
        }
        '4' {
            Write-Header "Unpatched Calls (Easy) ($unpatchedEasyCount)"
            ($allItems | Where-Object { $_.Type -eq 'Unpatched (Easy)' }) | ForEach-Object { Write-Host "  [L:$($_.Line)|P:$($_.Position)] $($_.Text)" -ForegroundColor $_.Color }
            Read-Host "`n  Press Enter to return to menu"
        }
        '5' {
            Write-Header "Unpatched Calls (Risky) ($unpatchedRiskyCount)"
            ($allItems | Where-Object { $_.Type -eq 'Unpatched (Risky)' }) | ForEach-Object { Write-Host "  [L:$($_.Line)|P:$($_.Position)] $($_.Text)" -ForegroundColor $_.Color }
            Read-Host "`n  Press Enter to return to menu"
        }
        '6' {
            # Logic to save log remains, but needs to be adapted for the new structure
            exit
        }
    }
}
