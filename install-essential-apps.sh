#!/usr/bin/env bash

# Fail fast: error on any failure, unset variable, or broken pipe
set -euo pipefail
###############################################################################
# Script Name: install-essential-apps.sh
# Description: 📦 Batch App Installer - Installs all essential apps automatically (no prompts)
# Author: DJCastle
# Version: 4.0.0
# Created: 2025-01-11
# Updated: 2026-09-30
#
# LICENSE: Free to use, modify, and distribute
#
# DISCLAIMER: This script is provided "AS IS" without warranty of any kind.
# Use at your own risk. The author is not responsible for any damage, data loss,
# or other issues that may occur from using this script. Always backup your
# system before running system modification scripts.
###############################################################################
#
# PURPOSE:
# Install essential applications using Homebrew casks without user interaction.
# This script is aligned with brew-setup.sh app list for consistency.
#
# APPLICATIONS INSTALLED:
#   Whatever you list in the EDIT HERE block near the top of this script.
#   Nothing ships enabled — the placeholders are commented out on purpose, so
#   a fresh copy of this script installs no apps until you choose them.
#
# HOW TO RUN IN TERMINAL:
# 1. Open Terminal application (Applications > Utilities > Terminal)
# 2. Navigate to script directory: cd /path/to/homeBrewScripts
# 3. Make script executable: chmod +x install-essential-apps.sh
# 4. Preview first: ./install-essential-apps.sh --dry-run
# 5. Run the script: ./install-essential-apps.sh
# This will install all essential applications automatically (no prompts)
#
# OPTIONS:
#   --dry-run, --check   Show what would be installed without changing anything
#   --help, -h           Show usage and exit
#
# FEATURES:
# ✅ Dry-run mode to preview every change before committing
# ✅ Safe to run multiple times — skips apps that are already installed
# ✅ Comprehensive logging and error handling
# ✅ Progress feedback with colored output
# ✅ Detailed installation summary
#
# REQUIREMENTS:
#   - Homebrew must be installed (use brew-setup.sh for full setup)
#   - macOS with administrator privileges
#   - Internet connection
#
# NOTES:
# - Some apps may require manual setup after installation
# - You may be prompted for your macOS password
# - Large downloads may take time depending on your internet speed
# - For interactive installation with more options, use brew-setup.sh
#
# LOG FILE:
#   All operations are logged to: ~/Library/Logs/EssentialAppsInstall.log
###############################################################################

LOG="$HOME/Library/Logs/EssentialAppsInstall.log"

# =============================================================================
#                          ▼▼▼  EDIT HERE  ▼▼▼
# =============================================================================
#
# List the apps you want installed, one per line, in the form:
#
#     "Display Name:cask-name"
#
#   Display Name   what you see in /Applications (used to skip apps you
#                  already installed by hand, outside Homebrew)
#   cask-name      Homebrew's name for it — find it with:  brew search <app>
#
# Every line below is a PLACEHOLDER and is commented out. These are examples
# of the *kinds* of apps people install, not recommendations. Replace them
# with the apps you actually want and delete the leading '#'.
#
# Leave them all commented and the script still runs fine — it just reports
# that no apps are configured and exits cleanly.
#
APPS=(
    # "Browser:browser1"              # e.g. "Firefox:firefox"
    # "Code Editor:editor1"           # e.g. "Visual Studio Code:visual-studio-code"
    # "Terminal:terminal1"            # e.g. "iTerm:iterm2"
    # "Chat App:chat1"                # e.g. "Slack:slack"
    # "Notes App:notes1"              # e.g. "Obsidian:obsidian"
    # "Archive Tool:archiver1"        # e.g. "The Unarchiver:the-unarchiver"
)

# =============================================================================
#                   ▲▲▲  DO NOT EDIT BELOW THIS LINE  ▲▲▲
# =============================================================================

# Parse options
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run|--check)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: ./install-essential-apps.sh [--dry-run] [--help]"
            echo ""
            echo "Options:"
            echo "  --dry-run, --check   Show what would be installed without changing anything"
            echo "  --help, -h           Show this help and exit"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg (try --help)" >&2
            exit 1
            ;;
    esac
done

# In dry-run mode, touch nothing — not even the log file
if [[ "$DRY_RUN" == "true" ]]; then
    LOG="/dev/null"
else
    echo "Starting Essential Apps installation at $(date)" >> "$LOG"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG"
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed. Please run brew-setup.sh first for full setup."
    exit 1
fi

print_success "Homebrew is available. Starting app installation..."

# Update Homebrew before installing
if [[ "$DRY_RUN" == "true" ]]; then
    print_status "[DRY-RUN] Would update Homebrew (brew update)"
else
    print_status "Updating Homebrew..."
    if brew update >> "$LOG" 2>&1; then
        print_success "Homebrew updated successfully"
    else
        print_warning "Homebrew update failed, but continuing with installation"
    fi
fi

# Function to install an app if not already installed
install_app() {
    local app_name="$1"
    local cask_name="$2"
    local display_name="$3"
    
    print_status "Checking $display_name..."
    
    # Check if app is already installed via Homebrew
    if brew list --cask "$cask_name" &> /dev/null; then
        print_success "$display_name is already installed via Homebrew"
        return 0
    fi
    
    # Check if app exists in Applications folder
    if [ -d "/Applications/$app_name.app" ]; then
        print_warning "$display_name is already installed in Applications folder"
        return 0
    fi
    
    # Install the app
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would install $display_name (brew install --cask $cask_name)"
        return 0
    fi

    print_status "Installing $display_name..."
    if brew install --cask "$cask_name" >> "$LOG" 2>&1; then
        print_success "$display_name installed successfully"
        return 0
    else
        print_error "Failed to install $display_name"
        return 1
    fi
}

# Install every app listed in the EDIT HERE block above.
# An empty list is a normal, successful outcome — not an error.
if [[ ${#APPS[@]} -eq 0 ]]; then
    print_warning "No apps are configured, so there is nothing to install."
    print_status  "Open this script and edit the EDIT HERE block near the top:"
    print_status  "  ${BASH_SOURCE[0]}"
    print_success "Nothing was changed."
    exit 0
fi

print_status "Starting application installations (${#APPS[@]} configured)..."

for app_entry in "${APPS[@]}"; do
    IFS=':' read -r display_name cask_name <<< "$app_entry"
    if [[ -z "$display_name" || -z "$cask_name" ]]; then
        print_error "Skipping malformed APPS entry: '$app_entry' (expected \"Display Name:cask-name\")"
        continue
    fi
    install_app "$display_name" "$cask_name" "$display_name" || true
done

# In dry-run mode there is nothing to verify — stop before the summary
if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    print_success "Dry run complete — no changes were made."
    print_status "Run again without --dry-run to install."
    exit 0
fi

# Post-installation summary
print_status "Installation complete! Summary:"
echo "----------------------------------------" | tee -a "$LOG"

# Check what was actually installed
installed_apps=()
failed_apps=()

# Verify against the SAME list the install loop used. Keeping one list means a
# new app can never be installed but silently left out of the summary.
for app_info in "${APPS[@]}"; do
    IFS=':' read -r display_name cask_name <<< "$app_info"
    
    if brew list --cask "$cask_name" &> /dev/null || [ -d "/Applications/$display_name.app" ]; then
        installed_apps+=("$display_name")
        print_success "✓ $display_name"
    else
        failed_apps+=("$display_name")
        print_error "✗ $display_name"
    fi
done

echo "" | tee -a "$LOG"
print_status "Installation Summary:"
print_success "Successfully installed/verified: ${#installed_apps[@]} apps"
if [ ${#failed_apps[@]} -gt 0 ]; then
    print_warning "Failed to install: ${#failed_apps[@]} apps"
    for app in "${failed_apps[@]}"; do
        print_warning "  - $app"
    done
fi

echo "" | tee -a "$LOG"
print_status "Next steps:"
echo "1. Check your Applications folder for newly installed apps" | tee -a "$LOG"
echo "2. Some apps may require additional setup or login" | tee -a "$LOG"
echo "3. You may need to grant permissions in System Preferences > Security & Privacy" | tee -a "$LOG"
echo "4. For troubleshooting, check the log file: $LOG" | tee -a "$LOG"

print_success "Essential apps installation completed at $(date)" 