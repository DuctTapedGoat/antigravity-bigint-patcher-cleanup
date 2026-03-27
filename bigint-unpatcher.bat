@echo off
title Antigravity BigInt Unpatcher - Windows

echo  :: ============================================================================
echo  ::  Antigravity BigInt Unpatcher - Windows Launcher
echo  ::  Created by Duct thanks to research from the r/Google_Antigravity community.
echo  ::
echo  ::  This script runs the BigInt Unpatcher for Antigravity.
echo  ::  ===========================================================================
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bigint-unpatcher.ps1"

echo.
echo  All done! BigInt Unpatcher has been performed on Antigravity.
echo.
pause