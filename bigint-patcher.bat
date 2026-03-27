@echo off
title Antigravity BigInt Patcher - Windows

echo. 
echo  ::  ===========================================================================
echo  ::  Antigravity BigInt Patcher - Windows Launcher
echo  ::  Created by Duct thanks to research from the r/Google_Antigravity community.
echo  ::
echo  ::  This script runs the BigInt Patcher for Antigravity.
echo  ::  ===========================================================================
pause

powershell -NoProfile -ExecutionPolicy Bypass -NoExit -File "%~dp0bigint-patcher.ps1"

echo.
echo  All done! BigInt Patcher has been performed on Antigravity.
echo.
pause