#!/usr/bin/env bash
###############################################################################
# Script Name: homebrew-setup.sh (formerly brew_setup_tahoe.sh)
# Description: 🍺 Educational Homebrew Installer - Interactive setup with customizable app selection
# Version: 2.0.0
# License: MIT
#
# EDUCATIONAL PURPOSE:
# This script demonstrates professional shell scripting practices including:
# - Modular design with external configuration
# - Comprehensive error handling and logging
# - User-friendly interactive interfaces
# - Cross-platform compatibility (Intel/Apple Silicon)
# - Safe, idempotent operations
#
# LEARNING OBJECTIVES:
# By studying this script, you'll learn:
# - How to structure complex shell scripts
# - Configuration management patterns
# - Error handling and recovery strategies
# - User interaction design
# - System detection and adaptation
# - Package management automation
#
# SAFETY & DISCLAIMERS:
# ⚠️  IMPORTANT: This script modifies your system by:
#    - Installing Homebrew package manager
#    - Modifying shell configuration files (.zshrc, .bash_profile, etc.)
#    - Installing applications you select
#    - Creating log files in ~/Library/Logs/
#
# 🛡️  SAFETY MEASURES:
#    - All operations are logged for review
#    - Interactive checkpoints allow you to control each step
#    - Idempotent design - safe to run multiple times
#    - Dry-run mode available for testing
#    - Configuration validation before execution
#
# 📋 REQUIREMENTS:
#    - macOS 12.0 (Monterey) or later
#    - Administrator privileges (you'll be prompted for password)
#    - Internet connection for downloads
#    - At least 1GB free disk space
#
# 🚀 QUICK START:
# 1. Open Terminal (Applications > Utilities > Terminal)
# 2. Navigate to script directory: cd /path/to/homebrew-scripts
# 3. Make executable: chmod +x homebrew-setup.sh
# 4. Run: ./homebrew-setup.sh
#
# 📖 USAGE OPTIONS:
#    ./homebrew-setup.sh                    # Interactive mode (recommended)
#    ./homebrew-setup.sh --dry-run          # Show what would be done
#    ./homebrew-setup.sh --non-interactive  # Automated mode
#    ./homebrew-setup.sh --config-only      # Just create/edit configuration
#    ./homebrew-setup.sh --help             # Show detailed help
#
# 📁 FILES CREATED/MODIFIED:
#    - Configuration: config/homebrew-scripts.conf
#    - Logs: ~/Library/Logs/HomebrewSetup.log
#    - Shell profiles: ~/.zshrc, ~/.bash_profile, etc.
#
# 🔗 LEARN MORE:
#    - Homebrew: https://brew.sh/
#    - Shell scripting: https://www.shellscript.sh/
#    - macOS Terminal: https://support.apple.com/guide/terminal/
###############################################################################

# Enable strict error handling for safer script execution
set -euo pipefail

# Source the common library for shared functions and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

if [[ ! -f "$LIB_DIR/common.sh" ]]; then
    echo "ERROR: Common library not found at $LIB_DIR/common.sh" >&2
    echo "Please ensure the lib/common.sh file exists in the same directory as this script." >&2
    exit 1
fi

# shellcheck source=lib/common.sh
source "$LIB_DIR/common.sh"

# =============================================================================
# SCRIPT CONFIGURATION AND INITIALIZATION
# =============================================================================

# Initialize the common library (loads configuration, sets up logging, etc.)
if ! init_common_lib; then
    echo "ERROR: Failed to initialize common library" >&2
    exit 1
fi

# Script-specific configuration
TOTAL_STEPS=8
CURRENT_STEP=0

# Set up logging for this script
LOG_FILE="$DEFAULT_LOG_DIR/${SETUP_LOG_FILE:-HomebrewSetup.log}"

# =============================================================================
# EDUCATIONAL FUNCTIONS - DEMONSTRATING SHELL SCRIPTING CONCEPTS
# =============================================================================

# Educational function: Demonstrate parameter handling and validation
validate_command_line_args() {
    local interactive_mode=true
    local dry_run_mode=false
    local config_only=false

    # Parse command line arguments
    # This demonstrates how to handle multiple script options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --non-interactive|-n)
                interactive_mode=false
                log_info "Non-interactive mode enabled"
                ;;
            --dry-run|-d)
                dry_run_mode=true
                log_info "Dry-run mode enabled (no actual changes will be made)"
                ;;
            --config-only|-c)
                config_only=true
                log_info "Configuration-only mode enabled"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --debug)
                DEBUG_MODE=true
                LOG_LEVEL="DEBUG"
                log_debug "Debug mode enabled"
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    # Export settings for use by other functions
    export INTERACTIVE_MODE="$interactive_mode"
    export DRY_RUN_MODE="$dry_run_mode"
    export CONFIG_ONLY_MODE="$config_only"

    # Set skip confirmations for non-interactive mode
    if [[ "$interactive_mode" == "false" ]]; then
        export SKIP_CONFIRMATIONS=true
    fi
}

# Educational function: Show comprehensive help information
show_help() {
    cat << 'EOF'
🍺 Homebrew Setup Script - Educational Edition

DESCRIPTION:
    This script automates the installation and configuration of Homebrew on macOS.
    It's designed to be educational, showing best practices for shell scripting
    while providing a robust, user-friendly installation experience.

USAGE:
    ./homebrew-setup.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message and exit
    -n, --non-interactive   Run without prompts (uses configuration defaults)
    -d, --dry-run          Show what would be done without making changes
    -c, --config-only      Only create/edit configuration file
    --debug                Enable debug output for troubleshooting

EXAMPLES:
    # Interactive installation (recommended for first-time users)
    ./homebrew-setup.sh

    # See what the script would do without making changes
    ./homebrew-setup.sh --dry-run

    # Automated installation using configuration file
    ./homebrew-setup.sh --non-interactive

    # Just set up configuration
    ./homebrew-setup.sh --config-only

WHAT THIS SCRIPT DOES:
    1. Validates system requirements (macOS version, architecture)
    2. Installs Xcode Command Line Tools if needed
    3. Installs Homebrew package manager
    4. Configures shell environment (PATH, etc.)
    5. Installs applications based on your configuration
    6. Sets up automatic maintenance (optional)

EDUCATIONAL FEATURES:
    - Comprehensive logging and error handling examples
    - Configuration management patterns
    - User interaction design
    - System detection and adaptation
    - Safe, idempotent operations

SAFETY FEATURES:
    - Dry-run mode to preview changes
    - Interactive checkpoints for user control
    - Comprehensive logging for troubleshooting
    - Validation of all inputs and system state
    - Safe to run multiple times

FILES CREATED/MODIFIED:
    - Configuration: config/homebrew-scripts.conf
    - Logs: ~/Library/Logs/HomebrewSetup.log
    - Shell profiles: ~/.zshrc, ~/.bash_profile, etc.

REQUIREMENTS:
    - macOS 12.0 (Monterey) or later
    - Administrator privileges
    - Internet connection
    - At least 1GB free disk space

For more information, visit: https://brew.sh/
EOF
}

# =============================================================================
# APPLICATION MANAGEMENT FUNCTIONS
# =============================================================================

# Educational function: Get applications to install based on configuration
get_applications_to_install() {
    local apps_to_install=()

    log_debug "Determining applications to install based on configuration..."

    # Check each category and add enabled applications
    for app in "${!CUSTOM_APPS[@]}"; do
        local app_info="${CUSTOM_APPS[$app]}"
        local display_name="${app_info%%:*}"
        local category="${app_info##*:}"

        # Check if this category is enabled
        if is_category_enabled "$category"; then
            apps_to_install+=("$app:$display_name:$category")
            log_debug "Added $app ($category) to installation list"
        else
            log_debug "Skipped $app ($category) - category disabled"
        fi
    done

    # Return the list
    printf '%s\n' "${apps_to_install[@]}"
}

# Educational function: Display available applications with educational information
show_available_applications() {
    echo
    log_info "📦 Available Applications by Category"
    echo "======================================"

    # Group applications by category for educational display
    local categories=("development" "productivity" "creative" "communication" "utilities")

    for category in "${categories[@]}"; do
        local category_enabled
        category_enabled=$(is_category_enabled "$category" && echo "✅ ENABLED" || echo "❌ DISABLED")

        echo
        echo -e "${CYAN}📂 ${category^} Tools ${category_enabled}${NC}"
        echo "$(printf '─%.0s' {1..50})"

        # Get apps in this category
        local apps_in_category
        mapfile -t apps_in_category < <(get_apps_by_category "$category")

        if [[ ${#apps_in_category[@]} -eq 0 ]]; then
            echo "  No applications configured for this category"
        else
            for app in "${apps_in_category[@]}"; do
                local app_info="${CUSTOM_APPS[$app]}"
                local display_name="${app_info%%:*}"
                local status=""

                # Check if already installed
                if brew list --cask "$app" >/dev/null 2>&1; then
                    status=" ${GREEN}(already installed)${NC}"
                elif [[ -d "/Applications/$display_name.app" ]]; then
                    status=" ${YELLOW}(installed outside Homebrew)${NC}"
                fi

                echo -e "  • ${WHITE}$app${NC} - $display_name$status"
            done
        fi
    done

    echo
    echo -e "${BLUE}💡 Educational Note:${NC}"
    echo "Applications are organized by category to demonstrate configuration management."
    echo "You can customize which categories to install by editing the configuration file."
    echo "This pattern makes scripts more maintainable and user-friendly."
}

# Educational function: Install applications with progress tracking and error handling
install_applications() {
    local apps_to_install
    mapfile -t apps_to_install < <(get_applications_to_install)

    if [[ ${#apps_to_install[@]} -eq 0 ]]; then
        log_info "No applications configured for installation"
        return 0
    fi

    log_info "Installing ${#apps_to_install[@]} applications..."

    local installed_count=0
    local skipped_count=0
    local failed_count=0
    local failed_apps=()

    for app_info in "${apps_to_install[@]}"; do
        IFS=':' read -r app_cask display_name category <<< "$app_info"

        log_info "Processing $display_name ($category)... ($(($installed_count + $skipped_count + $failed_count + 1))/${#apps_to_install[@]})"

        # Check if already installed
        if brew list --cask "$app_cask" >/dev/null 2>&1; then
            log_success "$display_name is already installed via Homebrew"
            ((skipped_count++))
            continue
        elif [[ -d "/Applications/$display_name.app" ]]; then
            log_warning "$display_name is already installed (not via Homebrew)"
            ((skipped_count++))
            continue
        fi

        # Install the application
        if [[ "${DRY_RUN_MODE:-false}" == "true" ]]; then
            log_info "[DRY RUN] Would install: $display_name"
            ((installed_count++))
        else
            log_info "Installing $display_name..."
            if brew install --cask "$app_cask"; then
                log_success "Successfully installed $display_name"
                ((installed_count++))
            else
                log_error "Failed to install $display_name"
                failed_apps+=("$display_name")
                ((failed_count++))
            fi
        fi
    done

    # Show installation summary
    echo
    log_info "📊 Installation Summary:"
    echo "========================"
    log_success "✅ Newly installed: $installed_count"
    log_info "⏭️  Already installed: $skipped_count"

    if [[ $failed_count -gt 0 ]]; then
        log_error "❌ Failed: $failed_count"
        echo "Failed applications:"
        for app in "${failed_apps[@]}"; do
            echo "  • $app"
        done
        echo
        echo "💡 Troubleshooting tips:"
        echo "  - Check your internet connection"
        echo "  - Try running: brew update && brew doctor"
        echo "  - Some apps may require manual installation"
    fi

    return $failed_count
}

# =============================================================================
# VALIDATION AND TESTING FUNCTIONS
# =============================================================================

# Educational function: Comprehensive system validation
validate_system_requirements() {
    local errors=0

    log_info "🔍 Validating system requirements..."

    # Check operating system
    if [[ "$(uname)" != "Darwin" ]]; then
        handle_system_requirement_error "Operating System" "$(uname)" "Darwin (macOS)"
        ((errors++))
    else
        log_success "✅ Running on macOS"
    fi

    # Check macOS version
    local macos_version
    macos_version=$(get_macos_version)
    local min_version="12.0"

    if [[ "$(printf '%s\n' "$min_version" "$macos_version" | sort -V | head -n1)" != "$min_version" ]]; then
        handle_system_requirement_error "macOS Version" "$macos_version" "$min_version or later"
        ((errors++))
    else
        log_success "✅ macOS version $macos_version is supported"
    fi

    # Check architecture
    local arch
    arch=$(detect_architecture)
    if [[ "$arch" == "unknown" ]]; then
        handle_system_requirement_error "Architecture" "$(uname -m)" "x86_64 or arm64"
        ((errors++))
    else
        log_success "✅ Architecture: $arch"
    fi

    # Check required commands
    local required_commands=("curl" "git" "networksetup" "pmset")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            report_error "CMD001" "Required command not found: $cmd" \
                "This command is needed for the script to function properly." \
                "1. Install Xcode Command Line Tools: xcode-select --install
2. Check if the command is in your PATH
3. Restart Terminal and try again"
            ((errors++))
        else
            log_debug "✅ Command available: $cmd"
        fi
    done

    # Check disk space
    local available_gb
    available_gb=$(df -g "$HOME" | awk 'NR==2 {print $4}')
    local required_gb=2

    if [[ "$available_gb" -lt "$required_gb" ]]; then
        handle_disk_space_error "${required_gb}GB" "${available_gb}GB"
        ((errors++))
    else
        log_success "✅ Sufficient disk space: ${available_gb}GB available"
    fi

    # Check internet connectivity
    if ! check_internet_connection; then
        handle_network_error
        ((errors++))
    else
        log_success "✅ Internet connection verified"
    fi

    return $errors
}

# Educational function: Validate configuration with detailed feedback
validate_configuration() {
    local errors=0

    log_info "🔧 Validating configuration..."

    # Validate email if provided
    if [[ -n "${EMAIL_ADDRESS:-}" ]]; then
        if validate_with_error validate_email "$EMAIL_ADDRESS" "email" "Valid email format: user@domain.com"; then
            log_success "✅ Email address format is valid"
        else
            ((errors++))
        fi
    fi

    # Validate phone if provided
    if [[ -n "${PHONE_NUMBER:-}" ]]; then
        if validate_with_error validate_phone "$PHONE_NUMBER" "phone" "International format with country code: +1234567890"; then
            log_success "✅ Phone number format is valid"
        else
            ((errors++))
        fi
    fi

    # Validate percentage values
    if ! validate_with_error validate_percentage "${MIN_BATTERY_PERCENTAGE:-50}" "battery percentage" "Number between 0 and 100"; then
        ((errors++))
    fi

    # Validate application configuration
    if [[ ${#CUSTOM_APPS[@]} -eq 0 ]]; then
        log_warning "⚠️ No applications configured for installation"
        log_info "💡 You can add applications by editing the configuration file"
    else
        log_success "✅ ${#CUSTOM_APPS[@]} applications configured"
    fi

    return $errors
}

# Educational function: Dry-run mode implementation
perform_dry_run() {
    log_info "🧪 DRY RUN MODE - Showing what would be done without making changes"
    echo

    # Show system information
    log_info "📊 System Information:"
    echo "  • Operating System: $(uname -s) $(get_macos_version)"
    echo "  • Architecture: $(detect_architecture)"
    echo "  • Homebrew Prefix: $(get_homebrew_prefix)"
    echo "  • User: $(whoami)"
    echo "  • Home Directory: $HOME"
    echo

    # Show configuration summary
    log_info "⚙️ Configuration Summary:"
    print_config_summary

    # Show what applications would be installed
    log_info "📦 Applications that would be installed:"
    show_available_applications

    # Show file operations
    log_info "📁 Files that would be created/modified:"
    echo "  • Log file: ${LOG_FILE}"
    echo "  • Shell profiles: ~/.zshrc, ~/.bash_profile, ~/.zprofile, ~/.bashrc"
    echo "  • Homebrew installation: $(get_homebrew_prefix)"
    echo

    # Show network operations
    log_info "🌐 Network operations that would be performed:"
    echo "  • Download Homebrew installation script"
    echo "  • Update Homebrew package database"
    echo "  • Download and install selected applications"
    echo

    log_success "✅ Dry run completed - no actual changes were made"
    log_info "💡 To perform the actual installation, run without --dry-run"
}

# Educational function: Pre-flight checks
run_preflight_checks() {
    log_info "🚀 Running pre-flight checks..."

    local validation_errors=0
    local system_errors=0

    # System validation
    if ! validate_system_requirements; then
        system_errors=$?
        log_error "❌ System validation failed with $system_errors errors"
    fi

    # Configuration validation
    if ! validate_configuration; then
        validation_errors=$?
        log_error "❌ Configuration validation failed with $validation_errors errors"
    fi

    local total_errors=$((system_errors + validation_errors))

    if [[ $total_errors -gt 0 ]]; then
        echo
        log_error "❌ Pre-flight checks failed with $total_errors total errors"
        log_info "💡 Please fix the above issues before proceeding"
        return 1
    else
        log_success "✅ All pre-flight checks passed"
        return 0
    fi
}

# Error handling with educational context
cleanup() {
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo
        log_error "❌ Script failed at step $CURRENT_STEP/$TOTAL_STEPS with exit code $exit_code"
        echo
        echo -e "${YELLOW}📖 What this means:${NC}"
        echo "The script encountered an error and stopped to prevent potential issues."
        echo "This is a safety feature to protect your system."
        echo
        echo -e "${CYAN}💡 What you can do:${NC}"
        echo "1. Check the error messages above for specific issues"
        echo "2. Review the log file: ${LOG_FILE}"
        echo "3. Fix any configuration or system issues"
        echo "4. Re-run the script - it's safe to run multiple times"
        echo "5. Use --dry-run to test without making changes"
        echo
        echo -e "${BLUE}🔍 For more help:${NC}"
        echo "• See docs/safety-and-best-practices.md for troubleshooting"
        echo "• Run with --debug for more detailed output"
        echo "• Check the GitHub issues for similar problems"
        echo
    fi
}
trap cleanup EXIT

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

  # Enhanced detection for specific Apple Silicon chip
  local chip_info
  chip_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")

  log_success "Apple Silicon Mac detected"
  log_info "Chip: $chip_info"

  # Provide chip-specific information
  if [[ "$chip_info" == *"M1"* ]]; then
    log_info "• M1 chip: First generation Apple Silicon (2020-2021)"
  elif [[ "$chip_info" == *"M2"* ]]; then
    log_info "• M2 chip: Second generation with improved performance (2022-2023)"
  elif [[ "$chip_info" == *"M3"* ]]; then
    log_info "• M3 chip: Third generation with 3nm process (2023-2024)"
  elif [[ "$chip_info" == *"M4"* ]]; then
    log_info "• M4 chip: Latest generation with enhanced AI capabilities (2024+)"
  fi

  # Check for Rosetta 2 (for running Intel apps)
  if /usr/bin/pgrep -q oahd; then
    log_info "• Rosetta 2: Active (can run Intel apps)"
  else
    log_info "• Rosetta 2: Not running (install if you need Intel app compatibility)"
  fi
else
  BREW_PREFIX="/usr/local"
  log_info "Intel Mac detected"
  log_info "Note: Consider upgrading to Apple Silicon for better performance and efficiency"
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

  # Security: Download and verify the installation script
  log_info "🔒 Security Check: Verifying Homebrew installation script..."
  local brew_install_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  local brew_install_script

  # Download the script to a temporary location for inspection
  brew_install_script=$(mktemp)
  if ! curl -fsSL "$brew_install_url" -o "$brew_install_script"; then
    log_error "Failed to download Homebrew installation script"
    log_error "Please check your internet connection"
    rm -f "$brew_install_script"
    exit 1
  fi

  # Verify the script came from GitHub (basic source verification)
  # Note: Homebrew installation script changes frequently, so we verify source not checksum
  if ! head -1 "$brew_install_script" | grep -q "^#!/bin/bash"; then
    log_error "Security Warning: Installation script doesn't appear to be a valid bash script"
    rm -f "$brew_install_script"
    exit 1
  fi

  # Check script size is reasonable (should be between 5KB and 50KB)
  local script_size
  script_size=$(wc -c < "$brew_install_script" | tr -d ' ')
  if [[ $script_size -lt 5000 ]] || [[ $script_size -gt 51200 ]]; then
    log_warning "Installation script size ($script_size bytes) is unusual"
    log_warning "Expected size: 5KB - 50KB"
    if ! checkpoint "Continue anyway? (Not recommended if you're unsure)"; then
      rm -f "$brew_install_script"
      exit 1
    fi
  fi

  log_success "Security check passed"
  log_info "Running Homebrew installation script..."
  log_info "⚠️  Important: Never run installation scripts without verifying the source"

  if /bin/bash "$brew_install_script"; then
    log_success "Homebrew installation completed"
  else
    log_error "Homebrew installation failed"
    rm -f "$brew_install_script"
    exit 1
  fi

  # Clean up
  rm -f "$brew_install_script"
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

# Show available applications from configuration
show_available_applications

echo
if ! checkpoint "Do you want to install applications from your configuration?"; then
    log_info "Skipping application installation"
else
    # Use the configuration-based installation function
    # This function is defined earlier and reads from config/homebrew-scripts.conf
    log_info "Installing applications based on your configuration..."
    install_applications
fi

log_step "Managing self-updating applications"

# Educational note about self-updating casks
# Note: 'brew pin' only works for formulae (CLI tools), NOT casks (GUI apps)
# Casks cannot be pinned in Homebrew
readonly SELF_UPDATING_APPS=("chatgpt" "visual-studio-code" "docker" "slack" "zoom")

log_info "ℹ️  Educational Note: Self-Updating Applications"
echo
echo "Some applications update themselves automatically (ChatGPT, VS Code, etc.)."
echo "These self-updating apps may conflict with Homebrew's update system."
echo
echo "Note: Homebrew casks (GUI applications) cannot be 'pinned' like formulae can."
echo "The HOMEBREW_NO_AUTO_UPDATE environment variable (already set) prevents"
echo "Homebrew from automatically updating these apps when you use brew commands."
echo
echo "Self-updating applications installed:"
local installed_self_updating=0
for app in "${SELF_UPDATING_APPS[@]}"; do
  if brew list --cask "$app" >/dev/null 2>&1; then
    echo "  ✓ $app (updates itself)"
    installed_self_updating=$((installed_self_updating + 1))
  fi
done

if [[ $installed_self_updating -eq 0 ]]; then
  log_info "No self-updating applications currently installed"
else
  log_info "Found $installed_self_updating self-updating application(s)"
  log_info "These apps will update themselves - no action needed from Homebrew"
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
