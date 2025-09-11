#!/usr/bin/env bash
###############################################################################
# Script Name: setup-github-token.sh
# Description: 🔑 GitHub Token Setup - Configure GitHub Personal Access Token for Homebrew
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
# Configure GitHub Personal Access Token to avoid GitHub API rate limits
# when using Homebrew and other GitHub-dependent operations.
#
# USAGE:
# bash setup-github-token.sh                    # Interactive setup
# bash setup-github-token.sh --token <TOKEN>    # Direct token setup
# bash setup-github-token.sh --remove           # Remove token
# bash setup-github-token.sh --help             # Show help
#
# FEATURES:
#   1) Securely configure GitHub Personal Access Token
#   2) Validate token permissions and accessibility
#   3) Set up environment variables for current and future sessions
#   4) Provide instructions for token creation
#   5) Test GitHub API rate limit improvements
#
# REQUIREMENTS:
#   - macOS 10.15 (Catalina) or later
#   - Internet connection
#   - GitHub Personal Access Token (optional, can be created during setup)
#
# SECURITY:
#   - Token is stored in shell profile (~/.zshrc or ~/.bash_profile)
#   - Token is exported as HOMEBREW_GITHUB_API_TOKEN environment variable
#   - No token is logged or displayed in plain text
###############################################################################

set -euo pipefail

# Colors for better output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Configuration
readonly SCRIPT_NAME="GitHub Token Setup"
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_FILE="$HOME/Library/Logs/GitHubTokenSetup.log"
readonly TOKEN_VAR="HOMEBREW_GITHUB_API_TOKEN"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log_message "INFO: $1"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log_message "SUCCESS: $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_message "WARNING: $1"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    log_message "ERROR: $1"
}

print_header() {
    echo
    echo -e "${BOLD}${PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${PURPLE}║                           🔑 $SCRIPT_NAME                              ║${NC}"
    echo -e "${BOLD}${PURPLE}║                              Version $SCRIPT_VERSION                                ║${NC}"
    echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_help() {
    print_header
    echo -e "${BOLD}DESCRIPTION:${NC}"
    echo "  Configure GitHub Personal Access Token for Homebrew to avoid API rate limits"
    echo
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $0                        # Interactive setup"
    echo "  $0 --token <TOKEN>        # Direct token setup"
    echo "  $0 --remove               # Remove configured token"
    echo "  $0 --status               # Show current token status"
    echo "  $0 --help                 # Show this help"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "  $0"
    echo "  $0 --token ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo "  $0 --remove"
    echo
}

# Function to detect shell and get profile file
get_shell_profile() {
    local shell_name
    shell_name=$(basename "$SHELL")
    
    case "$shell_name" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            echo "$HOME/.bash_profile"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Function to validate GitHub token format
validate_token_format() {
    local token="$1"
    
    # GitHub tokens start with ghp_, gho_, ghu_, ghs_, ghr_, or github_pat_
    if [[ "$token" =~ ^(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_)[a-zA-Z0-9_]+ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to test GitHub token validity
test_github_token() {
    local token="$1"
    local response
    
    log_info "Testing GitHub token validity..."
    
    response=$(curl -s -H "Authorization: token $token" \
                   -H "Accept: application/vnd.github.v3+json" \
                   https://api.github.com/user 2>/dev/null)
    
    if echo "$response" | grep -q '"login"'; then
        local username
        username=$(echo "$response" | grep '"login"' | cut -d'"' -f4)
        log_success "Token is valid! Authenticated as: $username"
        
        # Check rate limit
        local rate_limit
        rate_limit=$(curl -s -H "Authorization: token $token" \
                          -H "Accept: application/vnd.github.v3+json" \
                          https://api.github.com/rate_limit 2>/dev/null)
        
        if echo "$rate_limit" | grep -q '"limit"'; then
            local limit remaining
            limit=$(echo "$rate_limit" | grep '"limit"' | head -1 | grep -o '[0-9]\+')
            remaining=$(echo "$rate_limit" | grep '"remaining"' | head -1 | grep -o '[0-9]\+')
            log_info "GitHub API rate limit: $remaining/$limit requests remaining"
        fi
        
        return 0
    else
        log_error "Token validation failed. Please check your token."
        return 1
    fi
}

# Function to configure token in shell profile
configure_token_in_profile() {
    local token="$1"
    local profile_file
    profile_file=$(get_shell_profile)
    
    log_info "Configuring token in shell profile: $profile_file"
    
    # Remove existing token configuration if any
    if [ -f "$profile_file" ]; then
        # Create backup
        cp "$profile_file" "${profile_file}.backup.$(date +%s)" 2>/dev/null || true
        
        # Remove old token lines
        grep -v "export $TOKEN_VAR=" "$profile_file" > "${profile_file}.tmp" 2>/dev/null || touch "${profile_file}.tmp"
        mv "${profile_file}.tmp" "$profile_file"
    fi
    
    # Add new token configuration
    echo "" >> "$profile_file"
    echo "# GitHub Personal Access Token for Homebrew (configured by setup-github-token.sh)" >> "$profile_file"
    echo "export $TOKEN_VAR=\"$token\"" >> "$profile_file"
    
    # Set for current session
    export HOMEBREW_GITHUB_API_TOKEN="$token"
    
    log_success "Token configured successfully in $profile_file"
    log_info "Token will be available in new terminal sessions"
    log_info "Token is now active in current session"
}

# Function to remove token configuration
remove_token() {
    local profile_file
    profile_file=$(get_shell_profile)
    
    log_info "Removing GitHub token configuration..."
    
    if [ -f "$profile_file" ]; then
        # Create backup
        cp "$profile_file" "${profile_file}.backup.$(date +%s)" 2>/dev/null || true
        
        # Remove token lines and comments
        grep -v -E "(export $TOKEN_VAR=|# GitHub Personal Access Token for Homebrew)" "$profile_file" > "${profile_file}.tmp" 2>/dev/null || touch "${profile_file}.tmp"
        mv "${profile_file}.tmp" "$profile_file"
        
        log_success "Token configuration removed from $profile_file"
    fi
    
    # Unset from current session
    unset HOMEBREW_GITHUB_API_TOKEN 2>/dev/null || true
    
    log_success "GitHub token has been removed"
    log_info "Restart your terminal or run 'source $profile_file' to apply changes"
}

# Function to check current token status
check_token_status() {
    log_info "Checking current GitHub token status..."
    
    if [ -n "${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
        log_success "GitHub token is configured in current session"
        
        # Test the token
        if test_github_token "$HOMEBREW_GITHUB_API_TOKEN"; then
            return 0
        else
            log_warning "Configured token appears to be invalid"
            return 1
        fi
    else
        log_warning "No GitHub token configured"
        
        # Check if it's in shell profile but not loaded
        local profile_file
        profile_file=$(get_shell_profile)
        
        if [ -f "$profile_file" ] && grep -q "export $TOKEN_VAR=" "$profile_file"; then
            log_info "Token found in $profile_file but not loaded in current session"
            log_info "Run 'source $profile_file' or start a new terminal session"
        fi
        
        return 1
    fi
}

# Function to provide token creation instructions
show_token_instructions() {
    echo
    log_info "To create a GitHub Personal Access Token:"
    echo
    echo -e "${BOLD}1.${NC} Go to: ${CYAN}https://github.com/settings/tokens${NC}"
    echo -e "${BOLD}2.${NC} Click 'Generate new token' → 'Generate new token (classic)'"
    echo -e "${BOLD}3.${NC} Give it a descriptive name (e.g., 'Homebrew API Access')"
    echo -e "${BOLD}4.${NC} Set expiration as needed (90 days recommended)"
    echo -e "${BOLD}5.${NC} Select scopes: ${YELLOW}NO SCOPES NEEDED${NC} for Homebrew API access"
    echo -e "${BOLD}6.${NC} Click 'Generate token'"
    echo -e "${BOLD}7.${NC} Copy the token (it starts with 'ghp_')"
    echo
    log_warning "Keep your token secure! Don't share it or commit it to repositories."
    echo
}

# Function for interactive token setup
interactive_setup() {
    print_header
    
    log_info "Welcome to GitHub Token Setup for Homebrew!"
    echo
    
    # Check current status first
    if check_token_status 2>/dev/null; then
        echo
        read -p "A valid token is already configured. Do you want to replace it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled. Current token remains active."
            exit 0
        fi
    fi
    
    # Show instructions
    show_token_instructions
    
    # Get token from user
    echo -e "${BOLD}Enter your GitHub Personal Access Token:${NC}"
    read -s -p "Token: " user_token
    echo
    
    if [ -z "$user_token" ]; then
        log_error "No token provided. Setup cancelled."
        exit 1
    fi
    
    # Validate and configure
    setup_token "$user_token"
}

# Function to set up the token
setup_token() {
    local token="$1"
    
    # Validate token format
    if ! validate_token_format "$token"; then
        log_error "Invalid token format. GitHub tokens should start with 'ghp_', 'gho_', 'ghu_', 'ghs_', 'ghr_', or 'github_pat_'"
        exit 1
    fi
    
    # Test token validity
    if ! test_github_token "$token"; then
        log_error "Token validation failed. Please check your token and try again."
        exit 1
    fi
    
    # Configure token
    configure_token_in_profile "$token"
    
    echo
    log_success "🎉 GitHub token setup completed successfully!"
    log_info "Your Homebrew operations will now have higher GitHub API rate limits"
    log_info "Standard rate limit: 60 requests/hour"
    log_info "Authenticated rate limit: 5,000 requests/hour"
    echo
}

# Main script logic
main() {
    case "${1:-}" in
        --help|-h)
            print_help
            exit 0
            ;;
        --token)
            if [ -z "${2:-}" ]; then
                log_error "Token argument required. Usage: $0 --token <TOKEN>"
                exit 1
            fi
            print_header
            setup_token "$2"
            ;;
        --remove)
            print_header
            remove_token
            ;;
        --status)
            print_header
            check_token_status
            ;;
        "")
            interactive_setup
            ;;
        *)
            log_error "Unknown argument: $1"
            print_help
            exit 1
            ;;
    esac
}

# Error handling
trap 'log_error "An unexpected error occurred. Check $LOG_FILE for details."' ERR

# Run main function
main "$@"