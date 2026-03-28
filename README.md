# Antigravity Cleanup Script and BigInt Patcher Suite

This repository contains a suite of scripts designed to patch the Antigravity application to handle BigInt values correctly when using `JSON.stringify`. This is a common issue that can cause crashes or data loss, and these tools provide a robust, cross-platform solution.

This suite was created by **Duct** with research and insights from the **r/Google_Antigravity** community.

## Features

*   **Intelligent Patching**: The patcher analyzes all `JSON.stringify` calls and intelligently classifies them as "Easy" or "Risky" to ensure the correct patching method is used.
*   **Interactive Tools**: The patcher, unpatcher, and checker are all fully interactive, with color-coded menus and clear instructions.
*   **Safe by Design**: The patcher requires a security key confirmation for potentially dangerous "Risky" patches, preventing accidental application.
*   **Cross-Platform**: The toolset is available for Windows, macOS, and Linux, with identical functionality on all three platforms.
*   **Full Suite**: Includes a patcher, unpatcher, a diagnostic checker, and a cleanup utility.

## How to Use

Download the appropriate files for your operating system. The scripts are organized into `windows`, `macos`, and `linux` directories.

### Windows

Navigate to the `windows` directory. The easiest way to use the tools is to run the `.bat` launcher files:

*   `bigint-patcher.bat`: Starts the interactive patcher.
*   `bigint-unpatcher.bat`: Starts the interactive unpatcher.
*   `bigint-checker.bat`: Starts the interactive diagnostic checker.
*   `ag-cleanup.bat`: Starts the cleanup utility to remove configuration and backup files.

### macOS

Navigate to the `macos` directory. You can run the tools directly from the terminal, or you can use the convenient `.command` launchers.

**First time use**: Before you can use the `.command` files, you must make them executable. Open a Terminal window, navigate to the `macos` directory, and run the following command:

```bash
chmod +x *.command
```

After that, you can simply double-click any of the following files to launch them:

*   `bigint-patcher.command`: Starts the interactive patcher.
*   `bigint-unpatcher.command`: Starts the interactive unpatcher.
*   `bigint-checker.command`: Starts the interactive diagnostic checker.
*   `ag-cleanup.command`: Starts the cleanup utility.

### Linux

Navigate to the `linux` directory and run the scripts directly from your terminal.

**First time use**: You may need to make the scripts executable. Run the following command:

```bash
chmod +x *.sh
```

Then, run the desired tool:

*   `./bigint-patcher.sh`: Starts the interactive patcher.
*   `./bigint-unpatcher.sh`: Starts the interactive unpatcher.
*   `./bigint-checker.sh`: Starts the interactive diagnostic checker.
*   `./ag-cleanup.sh`: Starts the cleanup utility.

## Script Descriptions

*   **Patcher**: The main tool for applying the BigInt patch. It will scan the Antigravity application, classify all `JSON.stringify` calls, and allow you to apply the correct patch.
*   **Unpatcher**: Reverts any changes made by the patcher, restoring the Antigravity application to its original state.
*   **Checker**: A diagnostic tool that scans the application and provides a detailed, color-coded report on the status of all `JSON.stringify` calls without making any changes.
*   **Cleanup**: A utility to remove all user-level configuration files, caches, and leftover backup files for clean uninstallation and reinstallation of Antigravity.
