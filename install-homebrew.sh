#!/bin/bash

###############################################################################
# 🛠️ Homebrew Installer Script for macOS
# ---------------------------------------
# This script installs Homebrew on macOS (Intel or Apple Silicon) and ensures:
#   - Homebrew is added to your shell profile (zsh or bash)
#   - It runs `brew doctor` for a health check
#   - Logs all activity to ~/Library/Logs/HomebrewInstall.log
#
# ✅ Safe to run multiple times — it skips install if Homebrew is already present
#
# 🔧 USAGE INSTRUCTIONS:
# 1. Open Terminal
# 2. Create the script:
#      nano ~/Scripts/install-homebrew.sh
# 3. Paste this entire file into the editor
# 4. Save:   Press Control + O, then Enter
# 5. Exit:   Press Control + X
# 6. Make executable:
#      chmod +x ~/Scripts/install-homebrew.sh
# 7. Run the script:
#      ~/Scripts/install-homebrew.sh
#
# 📁 Log output is saved to:
#      ~/Library/Logs/HomebrewInstall.log
#
# ℹ️ Compatible with:
#   - macOS Ventura, Sonoma, and newer
#   - Intel and Apple Silicon (M1/M2/M3)
#
# 🚨 Notes and Warnings:
# - You may be prompted for your macOS password during install.
# - After installation, restart your Terminal or run:
#     source ~/.zprofile  or  source ~/.bash_profile
#
# 🧪 Troubleshooting:
# - Check the log file if you don't see Homebrew working:
#     ~/Library/Logs/HomebrewInstall.log
#
# 🐚 Shell Support:
# - This script handles zsh (Apple Silicon default) and bash (Intel default).
# - If you use another shell like `fish`, manually add:
#     eval "$(/opt/homebrew/bin/brew shellenv)"
#
# 🖥️ Apple Silicon Extra Tip:
# - If you later need Intel-only CLI tools, install Rosetta manually:
#     softwareupdate --install-rosetta
###############################################################################

LOG="$HOME/Library/Logs/HomebrewInstall.log"
echo "Starting Homebrew setup at $(date)" >> "$LOG"

# Check if Homebrew is already installed
if command -v brew &> /dev/null; then
    echo "✅ Homebrew is already installed." | tee -a "$LOG"
    brew --version >> "$LOG"
    exit 0
fi

# Install Homebrew using official script
echo "📦 Installing Homebrew..." | tee -a "$LOG"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG" 2>&1

# Determine brew location and add to PATH
if [ -d /opt/homebrew/bin ]; then
    # Apple Silicon
    BREW_PATH="/opt/homebrew/bin"
elif [ -d /usr/local/bin ]; then
    # Intel Macs
    BREW_PATH="/usr/local/bin"
else
    echo "⚠️ Could not determine Homebrew installation path!" | tee -a "$LOG"
    exit 1
fi

# Detect current shell and add to appropriate profile
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    # Zsh - add to .zprofile
    echo "eval \"$($BREW_PATH/brew shellenv)\"" >> "$HOME/.zprofile"
    eval "$($BREW_PATH/brew shellenv)"
    echo "✅ Added Homebrew to .zprofile for zsh" | tee -a "$LOG"
elif [ "$CURRENT_SHELL" = "bash" ]; then
    # Bash - add to .bash_profile
    echo "eval \"$($BREW_PATH/brew shellenv)\"" >> "$HOME/.bash_profile"
    eval "$($BREW_PATH/brew shellenv)"
    echo "✅ Added Homebrew to .bash_profile for bash" | tee -a "$LOG"
else
    # Other shells - add to both for compatibility
    echo "eval \"$($BREW_PATH/brew shellenv)\"" >> "$HOME/.zprofile"
    echo "eval \"$($BREW_PATH/brew shellenv)\"" >> "$HOME/.bash_profile"
    eval "$($BREW_PATH/brew shellenv)"
    echo "✅ Added Homebrew to both .zprofile and .bash_profile for $CURRENT_SHELL" | tee -a "$LOG"
fi

# Post-install: doctor check
echo "🔍 Running brew doctor..." | tee -a "$LOG"
brew doctor >> "$LOG" 2>&1

echo "✅ Homebrew install complete at $(date)" | tee -a "$LOG" 