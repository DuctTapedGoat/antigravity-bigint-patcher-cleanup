@echo off
title Antigravity Cleanup - Windows

echo  :: ============================================================================
echo  ::  Antigravity Cleanup - Windows Launcher
echo  ::  Created by Duct thanks to research from the r/Google_Antigravity community.
echo  ::
echo  ::  This script runs the aggressive cleanup for Antigravity.
echo  :: ============================================================================
pause

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0ag-cleanup.ps1'"

echo.
echo  All done! Cleanup has been performed on Antigravity remaining files.
echo.
pause
