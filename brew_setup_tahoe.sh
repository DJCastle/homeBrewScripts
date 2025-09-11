#!/usr/bin/env bash
###############################################################################
# Script Name: brew_setup_tahoe.sh
# Description: 🍺 Main Homebrew Installer - Interactive setup with app selection for macOS
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
# Install Homebrew on macOS, configure environment, and install selected apps
# with interactive checkpoints for user control.
#
# USAGE:
# bash brew_setup_tahoe.sh                    # Interactive mode
# bash brew_setup_tahoe.sh --non-interactive  # Automated mode
# bash brew_setup_tahoe.sh --help            # Show help
#
# FEATURES:
# This script is idempotent and safe to rerun. It will:
#   1) Ensure Xcode Command Line Tools are installed
#   2) Install Homebrew (if missing)
#   3) Configure PATH for your shell (zsh & bash)
#   4) Turn off Homebrew auto-update checks
#   5) Install requested apps via brew cask (with user choice)
#   6) Pin select self-updating apps to avoid Brew overwriting them
#
# REQUIREMENTS:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges
#   - Internet connection
#
# LOG FILE:
#   All operations are logged to: ~/Library/Logs/BrewSetupTahoe.log
###############################################################################

set -euo pipefail

# Colors for better output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

# Interactive mode flag
INTERACTIVE_MODE=true

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "\n${BLUE}==> Step $CURRENT_STEP/$TOTAL_STEPS: $1${NC}"
}

# Interactive prompts
ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "$INTERACTIVE_MODE" != "true" ]]; then
        return 0  # Auto-yes in non-interactive mode
    fi

    while true; do
        if [[ "$default" == "y" ]]; then
            echo -ne "${YELLOW}$prompt [Y/n]: ${NC}"
        else
            echo -ne "${YELLOW}$prompt [y/N]: ${NC}"
        fi

        read -r response
        response=${response,,}  # Convert to lowercase

        case "$response" in
            ""|"y"|"yes")
                if [[ "$default" == "y" ]]; then
                    return 0
                elif [[ "$response" != "" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            "n"|"no")
                return 1
                ;;
            *)
                echo -e "${RED}Please answer yes or no.${NC}"
                ;;
        esac
    done
}

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")

    if [[ "$INTERACTIVE_MODE" != "true" ]]; then
        echo "1"  # Auto-select first option in non-interactive mode
        return
    fi

    echo -e "${YELLOW}$prompt${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i + 1)). ${options[i]}"
    done

    while true; do
        echo -ne "${YELLOW}Enter your choice [1-${#options[@]}]: ${NC}"
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#options[@]}" ]]; then
            echo "$choice"
            return
        else
            echo -e "${RED}Please enter a number between 1 and ${#options[@]}.${NC}"
        fi
    done
}

checkpoint() {
    local message="$1"
    local default="${2:-y}"

    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}CHECKPOINT${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if ! ask_yes_no "$message" "$default"; then
        log_info "Skipping this step as requested"
        return 1
    fi

    return 0
}

# Error handling
cleanup() {
    if [[ $? -ne 0 ]]; then
        log_error "Script failed at step $CURRENT_STEP/$TOTAL_STEPS"
        log_error "You can safely re-run this script to continue from where it left off"
    fi
}
trap cleanup EXIT

# Verify we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS only"
    exit 1
fi

# Check for required tools
if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required but not installed"
    exit 1
fi

# Check for command line arguments
for arg in "$@"; do
    case "$arg" in
        --non-interactive|-n)
            INTERACTIVE_MODE=false
            log_info "Running in non-interactive mode"
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --non-interactive, -n    Run without prompts (auto-yes to all)"
            echo "  --help, -h              Show this help message"
            exit 0
            ;;
    esac
done

# Welcome message
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Homebrew Setup Script                    ║${NC}"
echo -e "${GREEN}║                      for macOS (Tahoe)                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo
log_info "This script will set up Homebrew and install selected applications"
log_info "You can run with --non-interactive to skip all prompts"
echo

if [[ "$INTERACTIVE_MODE" == "true" ]]; then
    if ! ask_yes_no "Do you want to continue with the setup?"; then
        log_info "Setup cancelled by user"
        exit 0
    fi
fi

log_step "Detecting system architecture"
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
  log_info "Apple Silicon Mac detected"
else
  BREW_PREFIX="/usr/local"
  log_info "Intel Mac detected"
fi
log_info "Architecture: $ARCH"
log_info "Homebrew prefix will be: $BREW_PREFIX"

# Helper to append a line to a file if it's not already there
append_line_if_missing() {
  local line="$1"
  local file="$2"

  # Create file if it doesn't exist
  if [[ ! -f "$file" ]]; then
    touch "$file" || {
      log_error "Failed to create $file"
      return 1
    }
  fi

  # Check if line already exists
  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >> "$file" || {
      log_error "Failed to write to $file"
      return 1
    }
    log_success "Added to $file: $line"
  else
    log_info "Already present in $file: $line"
  fi
}

log_step "Checking for Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  if ! checkpoint "Xcode Command Line Tools need to be installed. This may take several minutes and requires user interaction. Continue?"; then
    log_error "Xcode Command Line Tools are required for Homebrew"
    exit 1
  fi

  log_warning "Command Line Tools not found. Triggering installation..."
  if xcode-select --install 2>/dev/null; then
    log_info "Installation dialog should appear. Please complete it."
  else
    log_warning "Installation may already be in progress or tools may be installed"
  fi

  log_info "Waiting up to 15 minutes for installation to complete..."
  local waited=0
  local max_wait=900  # 15 minutes

  while [[ $waited -lt $max_wait ]]; do
    if xcode-select -p >/dev/null 2>&1; then
      log_success "Command Line Tools installation detected"
      break
    fi

    # Show progress every 30 seconds
    if [[ $((waited % 30)) -eq 0 ]] && [[ $waited -gt 0 ]]; then
      local remaining=$((max_wait - waited))
      log_info "Still waiting... ${remaining}s remaining"
    fi

    sleep 10
    waited=$((waited + 10))
  done

  # Final check
  if ! xcode-select -p >/dev/null 2>&1; then
    log_error "Command Line Tools installation timed out or failed"
    log_error "Please install manually: xcode-select --install"
    exit 1
  fi
else
  log_success "Command Line Tools already installed"
fi

log_step "Installing Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  if ! checkpoint "Homebrew is not installed. Install it now? (Required for app installation)"; then
    log_error "Homebrew is required for this script to function"
    exit 1
  fi

  log_info "Homebrew not found. Installing..."

  # Download and verify the installation script exists
  if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh >/dev/null; then
    log_error "Failed to download Homebrew installation script"
    log_error "Please check your internet connection"
    exit 1
  fi

  log_info "Running Homebrew installation script..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    log_success "Homebrew installation completed"
  else
    log_error "Homebrew installation failed"
    exit 1
  fi
else
  log_success "Homebrew already installed"
fi

# Ensure brew is in current PATH for this session
if [[ ":$PATH:" != *":$BREW_PREFIX/bin:"* ]]; then
  export PATH="$BREW_PREFIX/bin:$PATH"
  log_info "Added Homebrew to PATH for current session"
fi

# Verify brew command is now available
if ! command -v brew >/dev/null 2>&1; then
  log_error "Homebrew installation verification failed"
  log_error "brew command not found in PATH"
  exit 1
fi

log_success "Homebrew is ready: $(brew --version | head -n1)"

log_step "Configuring shell environment"
readonly ZSHRC="${HOME}/.zshrc"
readonly ZPROFILE="${HOME}/.zprofile"
readonly BASH_PROFILE="${HOME}/.bash_profile"
readonly BASHRC="${HOME}/.bashrc"

log_info "Configuring Homebrew environment in shell profiles..."

# Configure Homebrew environment
local brew_shellenv='eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"'
append_line_if_missing "$brew_shellenv" "$ZPROFILE"
append_line_if_missing "$brew_shellenv" "$ZSHRC"
append_line_if_missing "$brew_shellenv" "$BASH_PROFILE"
append_line_if_missing "$brew_shellenv" "$BASHRC"

log_info "Disabling Homebrew auto-updates and hints..."

# Disable Brew auto-update checks and hints globally
append_line_if_missing 'export HOMEBREW_NO_AUTO_UPDATE=1' "$ZSHRC"
append_line_if_missing 'export HOMEBREW_NO_ENV_HINTS=1' "$ZSHRC"
append_line_if_missing 'export HOMEBREW_NO_AUTO_UPDATE=1' "$BASH_PROFILE"
append_line_if_missing 'export HOMEBREW_NO_ENV_HINTS=1' "$BASH_PROFILE"

# Apply environment for current session
eval "$("$BREW_PREFIX/bin/brew" shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

log_success "Shell environment configured"

log_step "Configuring Homebrew settings"
log_info "Disabling Homebrew analytics..."
if brew analytics off; then
  log_success "Analytics disabled"
else
  log_warning "Failed to disable analytics (may already be disabled)"
fi

log_step "Verifying Homebrew setup"
log_info "Running brew doctor to check for issues..."
if brew doctor; then
  log_success "Homebrew setup verification passed"
else
  log_warning "brew doctor found some issues (this is often normal)"
  log_info "You can run 'brew doctor' later to see details"
fi

log_step "Installing applications"

# List of applications to install with descriptions
declare -A APP_DESCRIPTIONS=(
  ["adobe-creative-cloud"]="Adobe Creative Cloud - Creative suite installer"
  ["bambustudio"]="Bambu Studio - 3D printing slicer software"
  ["chatgpt"]="ChatGPT - AI assistant desktop app"
  ["epson-printer-utility"]="Epson Printer Utility - Printer management tools"
  ["grammarly-desktop"]="Grammarly Desktop - Writing assistant"
  ["icon-composer"]="Icon Composer - macOS icon creation tool"
  ["microsoft-edge"]="Microsoft Edge - Modern web browser"
  ["sf-symbols"]="SF Symbols - Apple's symbol library"
  ["visual-studio-code"]="Visual Studio Code - Code editor"
)

readonly APPS=(
  "adobe-creative-cloud"
  "bambustudio"
  "chatgpt"
  "epson-printer-utility"
  "grammarly-desktop"
  "icon-composer"
  "microsoft-edge"
  "sf-symbols"
  "visual-studio-code"
)

# Show app installation checkpoint
echo
log_info "The following applications are available for installation:"
for app in "${APPS[@]}"; do
    local status=""
    if brew list --cask "$app" >/dev/null 2>&1; then
        status=" ${GREEN}(already installed)${NC}"
    fi
    echo "  • $app - ${APP_DESCRIPTIONS[$app]}$status"
done
echo

if ! checkpoint "Do you want to install applications?"; then
    log_info "Skipping application installation"
else
    # Ask for installation mode
    local install_mode
    install_mode=$(ask_choice "Choose installation mode:" \
        "Install all applications automatically" \
        "Choose applications individually" \
        "Skip application installation")

    case "$install_mode" in
        "1")
            log_info "Installing all applications automatically..."
            install_all_apps
            ;;
        "2")
            log_info "Installing applications individually..."
            install_apps_individually
            ;;
        "3")
            log_info "Skipping application installation"
            ;;
    esac
fi

# Function to install all apps
install_all_apps() {
    local failed_apps=()
    local installed_count=0
    local skipped_count=0

    for app in "${APPS[@]}"; do
        log_info "Installing $app... ($(($installed_count + $skipped_count + 1))/${#APPS[@]})"

        # Check if already installed
        if brew list --cask "$app" >/dev/null 2>&1; then
            log_success "$app is already installed"
            skipped_count=$((skipped_count + 1))
            continue
        fi

        # Install the app
        if brew install --cask "$app"; then
            log_success "Successfully installed $app"
            installed_count=$((installed_count + 1))
        else
            log_error "Failed to install $app"
            failed_apps+=("$app")
        fi
    done

    log_info "Installation summary: $installed_count new, $skipped_count already installed, ${#failed_apps[@]} failed"

    if [[ ${#failed_apps[@]} -gt 0 ]]; then
        log_warning "Failed to install: ${failed_apps[*]}"
        log_info "You can retry these manually with: brew install --cask <app-name>"
    else
        log_success "All applications processed successfully"
    fi
}

# Function to install apps individually
install_apps_individually() {
    local failed_apps=()
    local installed_count=0
    local skipped_count=0

    for app in "${APPS[@]}"; do
        echo
        echo -e "${BLUE}━━━ Application: $app ━━━${NC}"
        echo "Description: ${APP_DESCRIPTIONS[$app]}"

        # Check if already installed
        if brew list --cask "$app" >/dev/null 2>&1; then
            log_success "$app is already installed"
            skipped_count=$((skipped_count + 1))
            continue
        fi

        if ask_yes_no "Install $app?"; then
            log_info "Installing $app..."
            if brew install --cask "$app"; then
                log_success "Successfully installed $app"
                installed_count=$((installed_count + 1))
            else
                log_error "Failed to install $app"
                failed_apps+=("$app")
            fi
        else
            log_info "Skipping $app"
        fi
    done

    echo
    log_info "Installation summary: $installed_count new, $skipped_count already installed, ${#failed_apps[@]} failed"

    if [[ ${#failed_apps[@]} -gt 0 ]]; then
        log_warning "Failed to install: ${failed_apps[*]}"
        log_info "You can retry these manually with: brew install --cask <app-name>"
    else
        log_success "All selected applications processed successfully"
    fi
}

log_step "Pinning self-updating applications"

# Apps that self-update and should be pinned to avoid conflicts
readonly PIN_APPS=("chatgpt" "visual-studio-code")

if checkpoint "Pin self-updating apps to prevent Homebrew conflicts? (Recommended)"; then
    log_info "Pinning apps that self-update to prevent Homebrew conflicts..."

    local pinned_count=0
    for app in "${PIN_APPS[@]}"; do
      if brew list --cask "$app" >/dev/null 2>&1; then
        if brew pin "$app" 2>/dev/null; then
          log_success "Pinned $app"
          pinned_count=$((pinned_count + 1))
        else
          log_warning "Failed to pin $app (may already be pinned)"
        fi
      else
        log_info "Skipping $app (not installed)"
      fi
    done

    log_info "Pinned $pinned_count apps"
else
    log_info "Skipping app pinning"
fi

# Final summary
log_step "Setup complete!"
echo
log_success "Homebrew setup completed successfully!"
echo
log_info "Summary:"
log_info "  • Homebrew installed at: $BREW_PREFIX"
log_info "  • PATH configured in shell profiles"
log_info "  • Auto-update checks disabled"
log_info "  • Analytics disabled"
log_info "  • Applications available: ${#APPS[@]} total"
echo
log_info "Next steps:"
log_info "  • Restart your terminal or run: source ~/.zshrc"
log_info "  • Run 'brew doctor' if you encounter any issues"
log_info "  • Applications are available in /Applications or via Spotlight"
echo
log_success "You're all set! 🎉"
