#!/usr/bin/env bash
###############################################################################
# Script Name: auto-update-brew-hybrid.sh
# Description: 🤖 Auto-Updater Pro - Advanced updates with email + text notifications
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
# 4. Run the script: ./auto-update-brew-hybrid.sh
# Note: Use setup-hybrid-notifications.sh for configuration and scheduling
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
echo "Starting Hybrid Auto Update Brew at $(date)" >> "$LOG"

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
    
    # Create temporary email file
    local email_file=$(mktemp)
    
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

    # Send email using macOS Mail
    if command -v mail &> /dev/null; then
        mail -s "$subject" "$EMAIL_ADDRESS" < "$email_file" >> "$LOG" 2>&1
        local result=$?
        rm "$email_file"
        
        if [ $result -eq 0 ]; then
            print_success "Email notification sent successfully"
            return 0
        else
            print_error "Failed to send email notification"
            return 1
        fi
    else
        print_error "mail command not available"
        rm "$email_file"
        return 1
    fi
}

# Function to send text message
send_text_message() {
    local message="$1"
    
    # Check if iMessage is available
    if ! command -v osascript &> /dev/null; then
        print_error "AppleScript not available for text messaging"
        return 1
    fi
    
    # Send message using AppleScript
    osascript <<EOF
tell application "Messages"
    send "$message" to buddy "$PHONE_NUMBER" of (service 1 whose service type is iMessage)
end tell
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Text message sent successfully"
        return 0
    else
        print_error "Failed to send text message"
        return 1
    fi
}

# Function to check WiFi network with retry
check_wifi_network() {
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        local current_network=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')
        
        if [ "$current_network" = "$WIFI_NETWORK" ]; then
            print_success "Connected to $WIFI_NETWORK WiFi"
            return 0
        else
            print_warning "Not connected to $WIFI_NETWORK WiFi (current: $current_network)"
            ((retry_count++))
            
            if [ $retry_count -lt $MAX_RETRIES ]; then
                print_status "Retrying in $RETRY_DELAY seconds... (attempt $retry_count/$MAX_RETRIES)"
                sleep $RETRY_DELAY
            fi
        fi
    done
    
    return 1
}

# Function to check if plugged into power
check_power_status() {
    local power_status=$(pmset -g ps | grep -E "AC Power|Battery Power")
    
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
        print_error "Homebrew is not installed. Please run ./install-homebrew.sh first."
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
        ((success_count++))
    else
        errors+="❌ Homebrew update failed<br>"
        ((error_count++))
    fi
    
    # Upgrade all packages
    print_status "Upgrading all packages..."
    local package_output=$(brew upgrade 2>&1)
    if [ $? -eq 0 ]; then
        update_summary+="✅ All packages upgraded successfully<br>"
        updated_packages=$(echo "$package_output" | grep -E "^==> Upgrading|^==> Downloading" | wc -l)
        ((success_count++))
    else
        errors+="❌ Package upgrade failed<br>"
        ((error_count++))
    fi
    
    # Upgrade all casks
    print_status "Upgrading all applications..."
    local cask_output=$(brew upgrade --cask 2>&1)
    if [ $? -eq 0 ]; then
        update_summary+="✅ All applications upgraded successfully<br>"
        updated_apps=$(echo "$cask_output" | grep -E "^==> Upgrading|^==> Downloading" | wc -l)
        ((success_count++))
    else
        errors+="❌ Application upgrade failed<br>"
        ((error_count++))
    fi
    
    # Clean up old versions
    print_status "Cleaning up old versions..."
    if brew cleanup >> "$LOG" 2>&1; then
        update_summary+="✅ Cleanup completed successfully<br>"
        ((success_count++))
    else
        errors+="❌ Cleanup failed<br>"
        ((error_count++))
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
    if [ "$error_count" -eq 0 ]; then
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
    
    if [ -n "$update_summary" ]; then
        email_body+="<p><strong>Details:</strong></p>"
        email_body+="<p>$update_summary</p>"
    fi
    
    if [ -n "$errors" ]; then
        email_body+="<p><strong>Errors:</strong></p>"
        email_body+="<p class='error'>$errors</p>"
    fi
    
    # Send email notification
    local email_subject="🔄 Auto Update Brew - $(date '+%Y-%m-%d %H:%M')"
    send_email_notification "$email_subject" "$email_body" "$LOG"
    
    # Prepare text message (short summary only)
    local text_message="🔄 Auto Update Brew: "
    if [ "$error_count" -eq 0 ]; then
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
        send_email_notification "❌ Auto Update Brew Failed" "Homebrew is not installed. Please run ./install-homebrew.sh first." "$LOG"
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
    
    # Perform updates and capture results
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