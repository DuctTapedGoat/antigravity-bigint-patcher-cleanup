@echo off
title Antigravity BigInt Checker - Windows

echo  ::  ===========================================================================
echo  ::  Antigravity BigInt Checker - Windows Launcher
echo  ::  Created by Duct thanks to research from the r/Google_Antigravity community.
echo  ::
echo  ::  This script runs the BigInt Checker for Antigravity.
echo  ::  ===========================================================================
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bigint-checker.ps1"

echo.
echo  All done! BigInt Checker has been performed on Antigravity.
echo.
pause