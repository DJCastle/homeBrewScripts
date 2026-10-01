#!/usr/bin/env bash

# Fail fast: error on any failure, unset variable, or broken pipe
set -euo pipefail
###############################################################################
# Script Name: auto-update-brew-hybrid.sh
# Description: 🤖 Auto-Updater Pro - Advanced updates with email + text notifications
# Author: DJCastle
# Version: 4.1.1
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
# Automatically update Homebrew and installed applications with hybrid
# notifications (email + text) and intelligent retry logic.
#
# CONDITIONS FOR EXECUTION:
#   - Must be connected to "YourWiFiNetwork" WiFi network
#   - Must be plugged into power (not on battery)
#   - Runs in background with hybrid notifications
#
# FEATURES:
#   - Updates Homebrew itself and all packages/casks
#   - Sends detailed email reports with logs and formatting
#   - Sends quick text message summaries
#   - Comprehensive error handling and retry logic (up to 3 attempts)
#   - Network and power condition monitoring
#   - Professional HTML email formatting
#   - Safe to run multiple times
#
# NOTIFICATION METHODS:
# 📧 EMAIL: Detailed reports using macOS Mail app (no external dependencies)
# 📱 TEXT: Quick status summaries via iMessage
#
# HOW TO RUN IN TERMINAL:
# 1. Open Terminal application (Applications > Utilities > Terminal)
# 2. Navigate to script directory: cd /path/to/homeBrewScripts
# 3. Make script executable: chmod +x auto-update-brew-hybrid.sh
# 4. Preview first: ./auto-update-brew-hybrid.sh --dry-run
# 5. Run the script: ./auto-update-brew-hybrid.sh
# Note: Use setup-hybrid-notifications.sh for configuration and scheduling
#
# OPTIONS:
#   --dry-run, --check   Check conditions and list outdated packages without
#                        upgrading anything or sending any notifications
#   --help, -h           Show usage and exit
#
# REQUIREMENTS:
#   - Homebrew must be installed
#   - macOS with administrator privileges
#   - Mail app configured for email notifications
#   - iMessage configured for text notifications
#   - Connected to "YourWiFiNetwork" WiFi
#   - Device plugged into power
#
# CONFIGURATION:
# Edit EMAIL_ADDRESS and PHONE_NUMBER variables below, or use setup script
#
# SCHEDULING RECOMMENDATIONS:
# - WEEKLY: Minimize notifications while staying current (recommended)
# - DAILY: Latest updates if you use your Mac heavily
# - MANUAL: Full control over when updates happen
#
# LOG FILE:
#   All operations are logged to: ~/Library/Logs/AutoUpdateBrewHybrid.log
###############################################################################

LOG="$HOME/Library/Logs/AutoUpdateBrewHybrid.log"

# Parse options
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run|--check)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: ./auto-update-brew-hybrid.sh [--dry-run] [--help]"
            echo ""
            echo "Options:"
            echo "  --dry-run, --check   Check conditions and list outdated packages without"
            echo "                       upgrading anything or sending any notifications"
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
    echo "Starting Hybrid Auto Update Brew at $(date)" >> "$LOG"
fi

# Configuration
WIFI_NETWORK="YourWiFiNetwork"
PHONE_NUMBER="+1234567890"  # Replace with your actual phone number
EMAIL_ADDRESS="your-email@example.com"  # Replace with your email
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAX_RETRIES=3
RETRY_DELAY=300  # 5 minutes

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

# Function to send email notification
send_email_notification() {
    local subject="$1"
    local body="$2"
    local log_file="$3"

    # Never send anything in dry-run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would email $EMAIL_ADDRESS: $subject"
        return 0
    fi

    # Create temporary email file
    # Split so a failure actually stops us: there is no point building an
    # email body with nowhere to put it.
    local email_file
    email_file=$(mktemp)
    
    # Create email content
    cat > "$email_file" << EOF
Subject: $subject
From: Auto Update Brew <noreply@localhost>
To: $EMAIL_ADDRESS
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .success { color: #28a745; }
        .error { color: #dc3545; }
        .warning { color: #ffc107; }
        .log { background-color: #f8f9fa; padding: 10px; border-radius: 5px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="header">
        <h2>🔄 Auto Update Brew Report</h2>
        <p><strong>Date:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
        <p><strong>Mac:</strong> $(hostname)</p>
    </div>
    
    <div>
        $body
    </div>
    
    <div class="log">
        <h3>📋 Recent Log Entries:</h3>
        <pre>$(tail -20 "$log_file")</pre>
    </div>
    
    <hr>
    <p><em>This is an automated message from your Homebrew update script.</em></p>
</body>
</html>
EOF

    # Send the email.
    #
    # `mail` exits 0 even when there is no mail transfer agent running to
    # deliver the message, so a plain exit-code check reported "sent
    # successfully" for mail that was never delivered. macOS ships postfix but
    # leaves it switched off, so on a default Mac that is the normal case — the
    # user configures email, is told it works, and never receives anything.
    #
    # Check that an MTA is actually reachable first and say so plainly if not.
    if ! command -v mail >/dev/null 2>&1; then
        print_error "mail command not available — cannot send email notifications"
        rm -f "$email_file"
        return 1
    fi

    if ! mail_transport_available; then
        print_error "Email NOT sent: no mail transfer agent is running on this Mac."
        print_error "  macOS ships postfix but leaves it disabled, so 'mail' accepts the"
        print_error "  message and silently never delivers it."
        print_error "  Use text notifications instead, or configure an MTA / SMTP relay."
        rm -f "$email_file"
        return 1
    fi

    if mail -s "$subject" "$EMAIL_ADDRESS" < "$email_file" >> "$LOG" 2>&1; then
        rm -f "$email_file"
        print_success "Email notification handed to the local mail system"
        return 0
    fi

    rm -f "$email_file"
    print_error "Failed to send email notification; see $LOG"
    return 1
}

# Report whether a mail transfer agent is actually running.
#
# postqueue exits non-zero with "mail system is down" when postfix is not
# running, which is the macOS default. This needs no elevated privileges.
mail_transport_available() {
    if [[ -x /usr/sbin/postqueue ]]; then
        /usr/sbin/postqueue -p >/dev/null 2>&1 && return 0
        return 1
    fi
    # No postqueue: cannot prove delivery works, so do not claim that it does.
    return 1
}

# Function to send text message
send_text_message() {
    local message="$1"

    # Never send anything in dry-run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would send text to $PHONE_NUMBER: $message"
        return 0
    fi

    # Check if iMessage is available
    if ! command -v osascript &> /dev/null; then
        print_error "AppleScript not available for text messaging"
        return 1
    fi
    
    # Send message using AppleScript. Pass phone number and message body as
    # osascript argv instead of interpolating them into the heredoc — the
    # message is built from brew output and could contain AppleScript
    # metacharacters (quotes, backslashes) that would otherwise break it.
    # Test the command directly rather than checking $? afterwards.
    #
    # Under `set -euo pipefail` a bare `osascript` that fails aborts the whole
    # script immediately, so the else branch below was unreachable and a
    # notification problem (Messages not signed in, Automation permission
    # denied) killed the entire update run after it had already upgraded
    # packages but before it logged a summary. Running unattended from launchd,
    # that failed invisibly.
    if osascript - "$PHONE_NUMBER" "$message" <<'EOF'
on run argv
    set phoneNumber to item 1 of argv
    set theMessage to item 2 of argv
    tell application "Messages"
        send theMessage to buddy phoneNumber of (service 1 whose service type is iMessage)
    end tell
end run
EOF
    then
        print_success "Text message sent successfully"
        return 0
    else
        print_error "Failed to send text message (is Messages signed in, and is Terminal allowed to control it in System Settings > Privacy & Security > Automation?)"
        return 1
    fi
}

# Find the Wi-Fi interface instead of assuming en0.
#
# en0 is Wi-Fi on laptops, but on desktop Macs (mini, Studio, Pro) en0 is
# usually Ethernet and Wi-Fi is en1 or later. Asking networksetup about a
# non-Wi-Fi interface exits 10, which was being swallowed — so the Wi-Fi check
# silently never matched and scheduled updates skipped every run with
# "not connected to <network>".
#
# Honours NETWORK_INTERFACE from the config if it is set.
get_wifi_interface() {
    if [[ -n "${NETWORK_INTERFACE:-}" ]]; then
        printf '%s\n' "$NETWORK_INTERFACE"
        return 0
    fi
    networksetup -listallhardwareports 2>/dev/null \
        | awk '/Hardware Port: Wi-Fi/{getline; print $2; exit}'
}

# Function to check WiFi network with retry
check_wifi_network() {
    local retry_count=0
    
    while [[ "$retry_count" -lt "$MAX_RETRIES" ]]; do
        # Split the assignment so a failure is visible, with `|| true` because an
        # absent or switched-off Wi-Fi interface is a normal state to degrade from,
        # not a reason to abort the run.
        local wifi_if current_network
        wifi_if="$(get_wifi_interface || true)"
        if [[ -z "$wifi_if" ]]; then
            print_warning "No Wi-Fi interface found on this Mac; cannot check the network."
            return 1
        fi
        current_network="$(networksetup -getairportnetwork "$wifi_if" 2>/dev/null | awk -F': ' '{print $2}' || true)"
        
        if [[ "$current_network" == "$WIFI_NETWORK" ]]; then
            print_success "Connected to $WIFI_NETWORK WiFi"
            return 0
        else
            print_warning "Not connected to $WIFI_NETWORK WiFi (current: $current_network)"

            # A dry run reports the miss immediately instead of waiting
            # through the retry window
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "[DRY-RUN] A real run would retry $MAX_RETRIES times, $RETRY_DELAY seconds apart"
                return 1
            fi

            retry_count=$((retry_count+1))

            if [[ "$retry_count" -lt "$MAX_RETRIES" ]]; then
                print_status "Retrying in $RETRY_DELAY seconds... (attempt $retry_count/$MAX_RETRIES)"
                sleep "$RETRY_DELAY"
            fi
        fi
    done
    
    return 1
}

# Function to check if plugged into power
check_power_status() {
    # Assigned separately with `|| true`: a grep that matches nothing would
    # otherwise fail the pipeline under `set -o pipefail`. This only works today
    # because `local` happens to swallow the exit code — do not rely on that.
    local power_status
    power_status=$(pmset -g ps | grep -E "AC Power|Battery Power" || true)
    
    if echo "$power_status" | grep -q "AC Power"; then
        print_success "Device is plugged into power"
        return 0
    else
        print_warning "Device is running on battery power"
        return 1
    fi
}

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please run ./brew-setup.sh first."
        return 1
    fi
    return 0
}

# Function to perform Homebrew updates
perform_updates() {
    local update_summary=""
    local errors=""
    local success_count=0
    local error_count=0
    local updated_packages=""
    local updated_apps=""
    
    print_status "Starting Homebrew updates..."
    
    # Update Homebrew itself
    print_status "Updating Homebrew..."
    if brew update >> "$LOG" 2>&1; then
        update_summary+="✅ Homebrew updated successfully<br>"
        success_count=$((success_count+1))
    else
        errors+="❌ Homebrew update failed<br>"
        error_count=$((error_count+1))
    fi
    
    # Upgrade all packages
    print_status "Upgrading all packages..."
    # Assign inside the `if` so the test sees brew's exit code.
    #
    # This was `local package_output=$(brew upgrade 2>&1)` followed by
    # `[ $? -eq 0 ]`, but $? there is the exit status of the `local` builtin,
    # which is always 0. The else branch could never run, so a failed upgrade
    # was reported in the email as "All packages upgraded successfully".
    local package_output
    if package_output=$(brew upgrade 2>&1); then
        update_summary+="✅ All packages upgraded successfully<br>"
        updated_packages=$(echo "$package_output" | grep -cE "^==> Upgrading|^==> Downloading" || true)
        success_count=$((success_count+1))
    else
        errors+="❌ Package upgrade failed<br>"
        print_error "brew upgrade failed; see $LOG"
        printf '%s\n' "$package_output" >> "$LOG"
        error_count=$((error_count+1))
    fi
    
    # Upgrade all casks
    print_status "Upgrading all applications..."
    # Same masked-exit-code bug as the package upgrade above.
    local cask_output
    if cask_output=$(brew upgrade --cask 2>&1); then
        update_summary+="✅ All applications upgraded successfully<br>"
        updated_apps=$(echo "$cask_output" | grep -cE "^==> Upgrading|^==> Downloading" || true)
        success_count=$((success_count+1))
    else
        errors+="❌ Application upgrade failed<br>"
        print_error "brew upgrade --cask failed; see $LOG"
        printf '%s\n' "$cask_output" >> "$LOG"
        error_count=$((error_count+1))
    fi
    
    # Clean up old versions
    print_status "Cleaning up old versions..."
    if brew cleanup >> "$LOG" 2>&1; then
        update_summary+="✅ Cleanup completed successfully<br>"
        success_count=$((success_count+1))
    else
        errors+="❌ Cleanup failed<br>"
        error_count=$((error_count+1))
    fi
    
    # Return summary
    echo "$update_summary"
    echo "$errors"
    echo "$success_count"
    echo "$error_count"
    echo "$updated_packages"
    echo "$updated_apps"
}

# Function to send hybrid notifications
send_hybrid_notifications() {
    local success_count="$1"
    local error_count="$2"
    local updated_packages="$3"
    local updated_apps="$4"
    local update_summary="$5"
    local errors="$6"
    
    # Prepare email body
    local email_body=""
    if [[ "$error_count" -eq 0 ]]; then
        email_body+="<h3 class='success'>🎉 All updates completed successfully!</h3>"
    else
        email_body+="<h3 class='warning'>⚠️ Some updates had issues</h3>"
    fi
    
    email_body+="<p><strong>Summary:</strong></p>"
    email_body+="<ul>"
    email_body+="<li>✅ Successful operations: $success_count</li>"
    email_body+="<li>❌ Errors: $error_count</li>"
    email_body+="<li>📦 Packages updated: $updated_packages</li>"
    email_body+="<li>🖥️ Applications updated: $updated_apps</li>"
    email_body+="</ul>"
    
    if [[ -n "$update_summary" ]]; then
        email_body+="<p><strong>Details:</strong></p>"
        email_body+="<p>$update_summary</p>"
    fi
    
    if [[ -n "$errors" ]]; then
        email_body+="<p><strong>Errors:</strong></p>"
        email_body+="<p class='error'>$errors</p>"
    fi
    
    # Send email notification
    local email_subject="🔄 Auto Update Brew - $(date '+%Y-%m-%d %H:%M')"
    send_email_notification "$email_subject" "$email_body" "$LOG"
    
    # Prepare text message (short summary only)
    local text_message="🔄 Auto Update Brew: "
    if [[ "$error_count" -eq 0 ]]; then
        text_message+="✅ Success ($success_count ops, $updated_packages pkgs, $updated_apps apps)"
    else
        text_message+="⚠️ Issues ($success_count/$((success_count + error_count)) ops)"
    fi
    
    # Send text notification
    send_text_message "$text_message"
}

# Main execution
main() {
    print_status "Hybrid Auto Update Brew started at $(date)"
    
    # Check prerequisites
    if ! check_homebrew; then
        send_text_message "❌ Auto Update Brew: Homebrew not installed"
        send_email_notification "❌ Auto Update Brew Failed" "Homebrew is not installed. Please run ./brew-setup.sh first." "$LOG"
        exit 1
    fi
    
    # Check WiFi network with retry
    if ! check_wifi_network; then
        print_warning "Skipping update - not on $WIFI_NETWORK WiFi after $MAX_RETRIES attempts"
        send_text_message "⚠️ Auto Update Brew: Skipped - not on YourWiFiNetwork WiFi"
        send_email_notification "⚠️ Auto Update Brew Skipped" "Update skipped because not connected to YourWiFiNetwork WiFi network." "$LOG"
        exit 0
    fi
    
    # Check power status
    if ! check_power_status; then
        print_warning "Skipping update - not plugged into power"
        send_text_message "⚠️ Auto Update Brew: Skipped - running on battery"
        send_email_notification "⚠️ Auto Update Brew Skipped" "Update skipped because device is running on battery power." "$LOG"
        exit 0
    fi
    
    # All conditions met, proceed with updates
    print_success "All conditions met. Proceeding with updates..."

    # Dry-run: show what a real run would do, then stop
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would run: brew update, brew upgrade, brew upgrade --cask, brew cleanup"
        print_status "[DRY-RUN] Outdated packages a real run would upgrade:"
        brew outdated || true
        print_status "[DRY-RUN] Outdated casks a real run would upgrade:"
        brew outdated --cask || true
        print_success "Dry run complete — no changes were made and no notifications were sent."
        exit 0
    fi

    # Perform updates and capture results
    # These field extractions keep the `local x=$(...)` form on purpose. The
    # producer function always succeeds (it ends in `echo`), and head/tail on a
    # short in-memory string has nothing meaningful to fail at, so splitting the
    # assignments would only add SIGPIPE exposure under pipefail for no gain.
    local update_results=$(perform_updates)
    local update_summary=$(echo "$update_results" | head -1)
    local errors=$(echo "$update_results" | head -2 | tail -1)
    local success_count=$(echo "$update_results" | head -3 | tail -1)
    local error_count=$(echo "$update_results" | head -4 | tail -1)
    local updated_packages=$(echo "$update_results" | head -5 | tail -1)
    local updated_apps=$(echo "$update_results" | head -6 | tail -1)
    
    # Send hybrid notifications
    send_hybrid_notifications "$success_count" "$error_count" "$updated_packages" "$updated_apps" "$update_summary" "$errors"
    
    print_success "Hybrid Auto Update Brew completed at $(date)"
    print_status "Check log file for details: $LOG"
}

# Run main function
main "$@" 