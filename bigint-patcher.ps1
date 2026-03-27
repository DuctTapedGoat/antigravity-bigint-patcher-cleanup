
# =====================================================================================
#  Antigravity BigInt Patcher for Windows
# =====================================================================================

$targetFile = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity\resources\app\out\main.js'
$backupFile = "$targetFile.bak"
$patchedLogic = '(_k, v) => typeof v === "bigint" ? v.toString() : v'

# --- Utility Functions ---

function Write-Header($title) {
    Clear-Host
    Write-Host ""
    Write-Host "  ==============================================================" -ForegroundColor Cyan
    Write-Host "             $title" -ForegroundColor Cyan
    Write-Host "  ==============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-Classification {
    param($text)

    if ($text -notmatch '^JSON\.stringify\((.*)\)$') { return @{ Type = 'unknown' } }
    $argsContent = $Matches[1]
    if ([string]::IsNullOrWhiteSpace($argsContent)) { return @{ Type = 'easy' } }

    $depth = 0
    $inString = $false
    $stringChar = ''
    $isEscaped = $false
    ${first_comm-index} = -1

    for ($i = 0; $i -lt $argsContent.Length; $i++) {
        $char = $argsContent[$i]
        if ($isEscaped) { $isEscaped = $false; continue }
        if ($char -eq '\') { $isEscaped = $true; continue }
        if (($char -eq "'" -or $char -eq '"' -or $char -eq '`')) {
            if ($inString -and $char -eq $stringChar) { $inString = $false }
            elseif (-not $inString) { $inString = $true; $stringChar = $char }
        }
        if ($inString) { continue }
        if ($char -eq '(' -or $char -eq '{' -or $char -eq '[') { $depth++ }
        elseif ($char -eq ')' -or $char -eq '}' -or $char -eq ']') { $depth-- }
        if ($char -eq ',' -and $depth -eq 0) {
            ${first_comm-index} = $i
            break
        }
    }

    if (${first_comm-index} -eq -1) {
        return @{ Type = 'easy' }
    } else {
        $secondArg = $argsContent.Substring(${first_comm-index} + 1).Trim()
        if ($secondArg.StartsWith('null') -or $secondArg.StartsWith('void 0') -or $secondArg.StartsWith('undefined')) {
            return @{ Type = 'easy' }
        } else {
            return @{ Type = 'risky' }
        }
    }
}


# --- Main Application Loop ---

if (-not (Test-Path $targetFile)) {
    Write-Header "Error"
    Write-Host "  Antigravity main.js not found at $targetFile" -ForegroundColor Red
    exit
}

$content = Get-Content -Raw $targetFile

while ($true) {
    Write-Header "Windows BigInt Omni-Patcher v8 (Final)"

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
        $type = "risky" # Default

        if ($text -like "*let _r =*bigint*") {
            $status = "patched"
            $type = "risky"
        } elseif ($text -like "*$patchedLogic*") {
            $status = "patched"
            $type = "easy"
        } else {
            $result = Get-Classification -text $text
            $type = $result.Type
        }

        $hits += [PSCustomObject]@{ Text=$text; Index=$index; Line=$lineNumber; Type=$type; Status=$status; Display="${lineNumber}:${index}" }
    }

    $unpatchedEasy = ($hits | Where-Object { $_.Status -eq 'unpatched' -and $_.Type -eq 'easy' }).Count
    $unpatchedRisky = ($hits | Where-Object { $_.Status -eq 'unpatched' -and $_.Type -eq 'risky' }).Count
    $patchedEasy = ($hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'easy' }).Count
    $patchedRisky = ($hits | Where-Object { $_.Status -eq 'patched' -and $_.Type -eq 'risky' }).Count

    Write-Host "  [OK] Patched (Easy):  $patchedEasy" -ForegroundColor Green
    Write-Host "  [?]  Patched (Risky): $patchedRisky" -ForegroundColor Cyan
    Write-Host "  [X]  Unpatched Easy:  $unpatchedEasy" -ForegroundColor Red
    Write-Host "  [!]  Unpatched Risky: $unpatchedRisky" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  OPTIONS:" -ForegroundColor Gray
    Write-Host "  1. Bulk Patch all EASY ($unpatchedEasy)"
    Write-Host "  2. Bulk Patch all RISKY ($unpatchedRisky)" -ForegroundColor Yellow
    Write-Host "  3. Exit"
    Write-Host ""

    $choice = Read-Host "  Enter Option#"

    if ($choice -eq "3") { exit }

    if (-not (Test-Path $backupFile)) {
        Write-Host "  Creating backup of fresh install..." -ForegroundColor Yellow
        Copy-Item $targetFile $backupFile -Force
    }

    $patcherRegex = '^JSON\.stringify\((.*)\)$';

    if ($choice -eq "1") {
        if ($unpatchedEasy -eq 0) { Write-Host "  No easy patches available."; Start-Sleep 1; continue }
        $newContent = $content
        $sortedEasy = $hits | Where-Object { $_.Status -eq 'unpatched' -and $_.Type -eq 'easy' } | Sort-Object Index -Descending

        foreach ($h in $sortedEasy) {
            if ($h.Text -match $patcherRegex) {
                $argsContent = $Matches[1]
                $replacement = "JSON.stringify($argsContent, $patchedLogic)"
                $newContent = $newContent.Remove($h.Index, $h.Text.Length).Insert($h.Index, $replacement)
            }
        }
        $content = $newContent
        Set-Content -Path $targetFile -Value $content -NoNewline -Encoding UTF8
        Write-Host "  Easy Bulk Patch Applied!" -ForegroundColor Green; Start-Sleep 2
    }

    if ($choice -eq "2") {
        if ($unpatchedRisky -eq 0) { Write-Host "  No risky patches available."; Start-Sleep 1; continue }
        $riskyHits = $hits | Where-Object { $_.Status -eq 'unpatched' -and $_.Type -eq 'risky' }
        $lineSum = ($riskyHits | Measure-Object -Property Line -Sum).Sum
        $indexSum = ($riskyHits | Measure-Object -Property Index -Sum).Sum
        $securityKey = "${lineSum}:${indexSum}"

        Write-Host ""
        Write-Host "  DANGEROUS: To confirm this risky patch, type the following key and press Enter:" -ForegroundColor Yellow
        Write-Host "  $securityKey" -ForegroundColor Cyan
        $userInput = Read-Host "  Enter security key"

        if ($userInput -ne $securityKey) { Write-Host "  Incorrect key."; Start-Sleep 2; continue }

        $newContent = $content
        $sortedRisky = $riskyHits | Sort-Object Index -Descending

        foreach ($h in $sortedRisky) {
             if ($h.Text -match $patcherRegex) {
                $argsContent = $Matches[1]
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

                if (${first_comm-index} -ne -1) {
                    $arg1 = $argsContent.Substring(0, ${first_comm-index}).Trim()
                    $rest = $argsContent.Substring(${first_comm-index} + 1).Trim()
                    $replacer = $rest
                    $restOfArgs = ''

                    $depth = 0; $inString = $false; $stringChar = ''; $isEscaped = $false; ${second_comm-index} = -1
                    for ($i = 0; $i -lt $rest.Length; $i++) {
                         $char = $rest[$i]
                         if ($isEscaped) { $isEscaped = $false; continue }
                         if ($char -eq '\') { $isEscaped = $true; continue }
                         if (($char -eq "'" -or $char -eq '"' -or $char -eq '`')) {
                            if ($inString -and $char -eq $stringChar) { $inString = $false } elseif (-not $inString) { $inString = $true; $stringChar = $char }
                         }
                         if ($inString) { continue }
                         if ($char -eq '(' -or $char -eq '{' -or $char -eq '[') { $depth++ }
                         elseif ($char -eq ')' -or $char -eq '}' -or $char -eq ']') { $depth-- }
                         if ($char -eq ',' -and $depth -eq 0) { ${second_comm-index} = $i; break }
                    }

                    if (${second_comm-index} -ne -1) {
                        $replacer = $rest.Substring(0, ${second_comm-index}).Trim()
                        $restOfArgs = $rest.Substring(${second_comm-index})
                    }

                    $wrappedReplacer = "(_k, v) => { let _r = ($replacer)(_k, v); return typeof _r === `"bigint`" ? _r.toString() : _r; }"
                    $newText = "JSON.stringify($arg1, $wrappedReplacer$restOfArgs)"
                    $newContent = $newContent.Remove($h.Index, $h.Text.Length).Insert($h.Index, $newText)
                }
            }
        }
        $content = $newContent
        Set-Content -Path $targetFile -Value $content -NoNewline -Encoding UTF8
        Write-Host "  Risky Bulk Patch Applied!" -ForegroundColor Green; Start-Sleep 2
    }
}
