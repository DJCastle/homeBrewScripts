#!/usr/bin/env bash
###############################################################################
# Script Name: install-essential-apps.sh
# Description: Non-interactive essential applications installer for macOS
# Author: DJCastle
# Version: 1.0.0
# Created: 2025-01-11
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
# This script is aligned with brew_setup_tahoe.sh app list for consistency.
#
# APPLICATIONS INSTALLED:
#   - Adobe Creative Cloud (Creative software suite)
#   - Bambu Studio (3D printing slicer software)
#   - ChatGPT Desktop (AI assistant desktop app)
#   - Epson Printer Utility (Printer management tools)
#   - Grammarly Desktop (Writing assistant)
#   - Icon Composer (macOS icon creation tool)
#   - SF Symbols (Apple's symbol library)
#   - Visual Studio Code (Code editor)
#
# USAGE:
# ./install-essential-apps.sh
#
# FEATURES:
# ✅ Safe to run multiple times — skips apps that are already installed
# ✅ Comprehensive logging and error handling
# ✅ Progress feedback with colored output
# ✅ Detailed installation summary
#
# REQUIREMENTS:
#   - Homebrew must be installed (use brew_setup_tahoe.sh for full setup)
#   - macOS with administrator privileges
#   - Internet connection
#
# NOTES:
# - Some apps may require manual setup after installation
# - You may be prompted for your macOS password
# - Large downloads may take time depending on your internet speed
# - For interactive installation with more options, use brew_setup_tahoe.sh
#
# LOG FILE:
#   All operations are logged to: ~/Library/Logs/EssentialAppsInstall.log
###############################################################################

LOG="$HOME/Library/Logs/EssentialAppsInstall.log"
echo "Starting Essential Apps installation at $(date)" >> "$LOG"

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
    print_error "Homebrew is not installed. Please run brew_setup_tahoe.sh first for full setup."
    exit 1
fi

print_success "Homebrew is available. Starting app installation..."

# Update Homebrew before installing
print_status "Updating Homebrew..."
brew update >> "$LOG" 2>&1
if [ $? -eq 0 ]; then
    print_success "Homebrew updated successfully"
else
    print_warning "Homebrew update failed, but continuing with installation"
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
    print_status "Installing $display_name..."
    if brew install --cask "$cask_name" >> "$LOG" 2>&1; then
        print_success "$display_name installed successfully"
        return 0
    else
        print_error "Failed to install $display_name"
        return 1
    fi
}

# Install applications (aligned with brew_setup_tahoe.sh)
print_status "Starting application installations..."

# 1. Adobe Creative Cloud
install_app "Adobe Creative Cloud" "adobe-creative-cloud" "Adobe Creative Cloud"

# 2. Bambu Studio
install_app "Bambu Studio" "bambustudio" "Bambu Studio"

# 3. ChatGPT Desktop
install_app "ChatGPT" "chatgpt" "ChatGPT Desktop"

# 4. Epson Printer Utility
install_app "Epson Printer Utility" "epson-printer-utility" "Epson Printer Utility"

# 5. Grammarly Desktop
install_app "Grammarly Desktop" "grammarly-desktop" "Grammarly Desktop"

# 6. Icon Composer
install_app "Icon Composer" "icon-composer" "Icon Composer"

# 7. SF Symbols
install_app "SF Symbols" "sf-symbols" "SF Symbols"

# 8. Visual Studio Code
install_app "Visual Studio Code" "visual-studio-code" "Visual Studio Code"

# Post-installation summary
print_status "Installation complete! Summary:"
echo "----------------------------------------" | tee -a "$LOG"

# Check what was actually installed
installed_apps=()
failed_apps=()

# Check each app (aligned with brew_setup_tahoe.sh)
apps=(
    "Adobe Creative Cloud:adobe-creative-cloud"
    "Bambu Studio:bambustudio"
    "ChatGPT Desktop:chatgpt"
    "Epson Printer Utility:epson-printer-utility"
    "Grammarly Desktop:grammarly-desktop"
    "Icon Composer:icon-composer"
    "SF Symbols:sf-symbols"
    "Visual Studio Code:visual-studio-code"
)

for app_info in "${apps[@]}"; do
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