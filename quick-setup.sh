#!/usr/bin/env bash
###############################################################################
# Script Name: quick-setup.sh
# Description: Quick developer environment bootstrap
# Author: DJCastle
# Version: 1.0.0
# Created: 2026-02-16
#
# LICENSE: Free to use, modify, and distribute
#
# DISCLAIMER: This script is provided "AS IS" without warranty of any kind.
# Use at your own risk. See DISCLAIMER.md for full details.
###############################################################################
#
# PURPOSE:
# Bootstrap a fresh Mac with CLI tools, VSCode extensions, and Git config
# in one pass. For the full interactive experience, use brew_setup_tahoe.sh.
#
# HOW TO RUN:
#   chmod +x quick-setup.sh
#   ./quick-setup.sh            # Run for real
#   ./quick-setup.sh --dry-run  # Preview what will happen
#
# STEPS:
#   1. Install Xcode Command Line Tools (if missing)
#   2. Install Homebrew (if missing)
#   3. Install packages from Brewfile (CLI tools + apps)
#   4. Set up VSCode 'code' CLI command
#   5. Install VSCode extensions
#   6. Configure Git (name, email, LFS)
#   7. Authenticate GitHub CLI
#   8. Print summary
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared library for colors, logging, and utilities
source "$SCRIPT_DIR/lib/common.sh"

# Set up logging without requiring a config file
LOG_FILE="$HOME/Library/Logs/QuickSetup.log"
setup_logging

# Parse arguments
DRY_RUN_MODE=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN_MODE=true
    log_info "DRY RUN MODE — no changes will be made"
fi

# Track results
installed=()
skipped=()

TOTAL_STEPS=8

# ── Step 1: Xcode Command Line Tools ─────────────────────────
log_step 1 $TOTAL_STEPS "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    log_success "Xcode CLT already installed"
    skipped+=("Xcode CLT")
else
    if [[ "$DRY_RUN_MODE" == "true" ]]; then
        log_info "[DRY RUN] Would install Xcode Command Line Tools"
    else
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Press any key after the installer finishes..."
        read -n 1 -s -r
    fi
    installed+=("Xcode CLT")
fi

# ── Step 2: Homebrew ──────────────────────────────────────────
log_step 2 $TOTAL_STEPS "Homebrew"

if command_exists brew; then
    log_success "Homebrew already installed"
    skipped+=("Homebrew")
else
    if [[ "$DRY_RUN_MODE" == "true" ]]; then
        log_info "[DRY RUN] Would install Homebrew"
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add Homebrew to PATH for this session
        local_prefix="$(get_homebrew_prefix)"
        eval "$("$local_prefix/bin/brew" shellenv)"
    fi
    installed+=("Homebrew")
fi

# ── Step 3: Brew Bundle ──────────────────────────────────────
log_step 3 $TOTAL_STEPS "Brewfile packages"

if [[ "$DRY_RUN_MODE" == "true" ]]; then
    log_info "[DRY RUN] Would run: brew bundle --file=$SCRIPT_DIR/Brewfile"
    log_info "Packages:"
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        log_info "  $line"
    done < "$SCRIPT_DIR/Brewfile"
else
    log_info "Installing packages from Brewfile..."
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    log_success "Brew bundle complete"
fi
installed+=("Brewfile packages")

# ── Step 4: VSCode CLI ───────────────────────────────────────
log_step 4 $TOTAL_STEPS "VSCode CLI"

if command_exists code; then
    log_success "'code' command already in PATH"
    skipped+=("VSCode CLI")
else
    VSCODE_CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [[ -f "$VSCODE_CLI" ]]; then
        if [[ "$DRY_RUN_MODE" == "true" ]]; then
            log_info "[DRY RUN] Would symlink 'code' to /usr/local/bin"
        else
            log_info "Symlinking 'code' to /usr/local/bin..."
            sudo mkdir -p /usr/local/bin
            sudo ln -sf "$VSCODE_CLI" /usr/local/bin/code
            log_success "VSCode CLI linked"
        fi
        installed+=("VSCode CLI")
    else
        log_warning "VSCode not found — install it first, then re-run"
        skipped+=("VSCode CLI")
    fi
fi

# ── Step 5: VSCode Extensions ────────────────────────────────
log_step 5 $TOTAL_STEPS "VSCode extensions"

EXTENSIONS_FILE="$SCRIPT_DIR/dotfiles/vscode/extensions.txt"

if ! command_exists code; then
    log_warning "VSCode 'code' command not available — skipping extensions"
    skipped+=("VSCode extensions")
else
    if [[ "$DRY_RUN_MODE" == "true" ]]; then
        log_info "[DRY RUN] Would install extensions from $EXTENSIONS_FILE:"
        while IFS= read -r ext; do
            ext="$(echo "$ext" | xargs)"
            [[ -z "$ext" ]] && continue
            log_info "  $ext"
        done < "$EXTENSIONS_FILE"
    else
        while IFS= read -r ext; do
            ext="$(echo "$ext" | xargs)"
            [[ -z "$ext" ]] && continue
            if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
                log_success "Already installed: $ext"
            else
                code --install-extension "$ext" --force
                log_success "Installed: $ext"
            fi
        done < "$EXTENSIONS_FILE"
    fi
    installed+=("VSCode extensions")
fi

# ── Step 6: Git Config ───────────────────────────────────────
log_step 6 $TOTAL_STEPS "Git configuration"

if [[ "$DRY_RUN_MODE" == "true" ]]; then
    log_info "[DRY RUN] Would prompt for Git name and email"
    log_info "[DRY RUN] Would configure Git LFS"
else
    if ask_yes_no "Configure Git (name, email, LFS)?" "y"; then
        echo -ne "${YELLOW}Your name: ${NC}"
        read -r git_name
        echo -ne "${YELLOW}Your email: ${NC}"
        read -r git_email

        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global filter.lfs.clean "git-lfs clean -- %f"
        git config --global filter.lfs.smudge "git-lfs smudge -- %f"
        git config --global filter.lfs.process "git-lfs filter-process"
        git config --global filter.lfs.required true
        log_success "Git config applied ($git_name <$git_email>)"
        installed+=("Git config")
    else
        log_warning "Skipped Git config"
        skipped+=("Git config")
    fi
fi

# ── Step 7: GitHub CLI Auth ──────────────────────────────────
log_step 7 $TOTAL_STEPS "GitHub CLI authentication"

if ! command_exists gh; then
    log_warning "GitHub CLI not installed — skipping auth"
    skipped+=("gh auth")
elif gh auth status &>/dev/null 2>&1; then
    log_success "Already authenticated with GitHub CLI"
    skipped+=("gh auth")
else
    if [[ "$DRY_RUN_MODE" == "true" ]]; then
        log_info "[DRY RUN] Would run: gh auth login"
    else
        gh auth login
    fi
    installed+=("gh auth")
fi

# ── Step 8: Summary ──────────────────────────────────────────
log_step 8 $TOTAL_STEPS "Summary"

echo
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  Quick Setup Complete${NC}"
echo -e "${GREEN}==========================================${NC}"

if [[ ${#installed[@]} -gt 0 ]]; then
    echo -e "\n${GREEN}Installed / configured:${NC}"
    for item in "${installed[@]}"; do
        echo "  + $item"
    done
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}Already present (skipped):${NC}"
    for item in "${skipped[@]}"; do
        echo "  - $item"
    done
fi

if [[ "$DRY_RUN_MODE" == "true" ]]; then
    echo
    log_info "This was a dry run. Run without --dry-run to apply changes."
fi

echo
log_info "Log file: $LOG_FILE"
log_info "For the full interactive setup, use: ./brew_setup_tahoe.sh"
