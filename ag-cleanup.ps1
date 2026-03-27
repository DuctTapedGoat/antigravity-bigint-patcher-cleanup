# =====================================================================================
#  Antigravity Aggressive Cleanup for Windows
# =====================================================================================

function Clear-HostWrite-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host "        Antigravity Aggressive Cleanup for Windows"              -ForegroundColor Cyan
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  This script is based on the amazing research by DuctTapedGoat" -ForegroundColor Yellow
    Write-Host "  from the r/google_antigravity community." -ForegroundColor Yellow
    Write-Host ""
}

# --- Main Script ---

Clear-HostWrite-Header

Write-Host "  This script will perform the Aggressive Cleanup to remove all"
Write-Host "  Antigravity cache and data files from your system."
Write-Host ""
Write-Host "  Please ensure you have UNINSTALLED Antigravity before proceeding." -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "  Are you ready to proceed? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host ""
    Write-Host "  Aborting script. No files were changed." -ForegroundColor Red
    Write-Host ""
    exit
}

$foldersToDelete = @()
$foldersToDelete += Join-Path $env:LOCALAPPDATA 'Programs\Antigravity'
$foldersToDelete += Join-Path $env:APPDATA 'Antigravity'
$foldersToDelete += Join-Path $env:USERPROFILE '.gemini'
$foldersToDelete += Join-Path $env:USERPROFILE '.antigravity'

Clear-HostWrite-Header

Write-Host "  The following directories (and all their contents) will be deleted:" -ForegroundColor White
Write-Host ""

foreach ($folder in $foldersToDelete) {
    if (Test-Path $folder) {
        Write-Host "  - $folder" -ForegroundColor Yellow
    } else {
        Write-Host "  - $folder (Not Found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
$finalConfirmation = Read-Host "  THIS IS YOUR FINAL WARNING. Continue? (y/n)"

if ($finalConfirmation -ne 'y') {
    Write-Host ""
    Write-Host "  Aborting script. No files were changed." -ForegroundColor Red
    Write-Host ""
    exit
}

Write-Host ""
Write-Host "  Deleting files..." -ForegroundColor Green

foreach ($folder in $foldersToDelete) {
    if (Test-Path $folder) {
        try {
            Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
            Write-Host "    - DELETED: $folder" -ForegroundColor Green
        } catch {
            Write-Host "    - FAILED to delete: $folder" -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor DarkRed
        }
    }
}

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "                  CLEANUP COMPLETE!" -ForegroundColor Cyan
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  What to do next:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Set your DEFAULT SYSTEM BROWSER to a clean new browser"
Write-Host "     with ONLY your paid Antigravity Google account signed in."
Write-Host "     (Using Chrome Canary is a great way to keep this separate)."
Write-Host ""
Write-Host "  2. Reinstall Google Antigravity (do NOT run as Administrator)."
Write-Host ""
Write-Host "  3. Launch Antigravity and sign in. Your timers should now be truthful!"
Write-Host ""
Write-Host "  4. Once Antigravity is reinstalled, you can run the 'bigint-patch.bat'"
Write-Host "     to fix the BigInt serialization bug."
Write-Host ""
Write-Host "  5. If that doesn't work try creating a new OS user account and sign in."
Write-Host ""
Read-Host "  Press Enter to exit."

