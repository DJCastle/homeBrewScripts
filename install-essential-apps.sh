#!/bin/bash

###############################################################################
# 🛠️ Essential Apps Installer Script for macOS
# --------------------------------------------
# This script installs essential applications using Homebrew casks:
#   - Bambu Studio (3D printing software)
#   - Brave Browser (Privacy-focused browser)
#   - ChatGPT Desktop (AI chat application)
#   - Cursor AI (AI-powered code editor)
#   - Grammarly Desktop (Writing assistant)
#   - Google Chrome (Web browser)
#
# ✅ Safe to run multiple times — it skips apps that are already installed
# ✅ Logs all activity for troubleshooting
# ✅ Provides progress feedback
#
# 🔧 USAGE INSTRUCTIONS:
# 1. Make sure Homebrew is installed first:
#      ./install-homebrew.sh
# 2. Run this script:
#      ./install-essential-apps.sh
#
# 📁 Log output is saved to:
#      ~/Library/Logs/EssentialAppsInstall.log
#
# ℹ️ Requirements:
#   - Homebrew must be installed
#   - macOS with admin privileges
#
# 🚨 Notes:
# - Some apps may require manual setup after installation
# - You may be prompted for your macOS password
# - Large downloads may take time depending on your internet speed
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
    print_error "Homebrew is not installed. Please run ./install-homebrew.sh first."
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

# Install applications
print_status "Starting application installations..."

# 1. Bambu Studio
install_app "Bambu Studio" "bambu-studio" "Bambu Studio"

# 2. Brave Browser
install_app "Brave Browser" "brave-browser" "Brave Browser"

# 3. ChatGPT Desktop
install_app "ChatGPT" "chatgpt" "ChatGPT Desktop"

# 4. Cursor AI
install_app "Cursor" "cursor" "Cursor AI"

# 5. Grammarly Desktop
install_app "Grammarly" "grammarly-desktop" "Grammarly Desktop"

# 6. Google Chrome
install_app "Google Chrome" "google-chrome" "Google Chrome"

# Post-installation summary
print_status "Installation complete! Summary:"
echo "----------------------------------------" | tee -a "$LOG"

# Check what was actually installed
installed_apps=()
failed_apps=()

# Check each app
apps=(
    "Bambu Studio:bambu-studio"
    "Brave Browser:brave-browser"
    "ChatGPT Desktop:chatgpt"
    "Cursor AI:cursor"
    "Grammarly Desktop:grammarly-desktop"
    "Google Chrome:google-chrome"
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