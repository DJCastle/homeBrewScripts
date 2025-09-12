#!/usr/bin/env bash
###############################################################################
# Script Name: auto-update-brew.sh
# Description: 🤖 Auto-Updater Basic - Keeps Homebrew updated with text notifications
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
# Automatically update Homebrew and installed applications with smart conditions
# and text message notifications for status updates.
#
# CONDITIONS FOR EXECUTION:
#   - Must be connected to "YourWiFiNetwork" WiFi network
#   - Must be plugged into power (not on battery)
#   - Runs in background with notifications
#
# FEATURES:
#   - Updates Homebrew itself
#   - Updates all installed packages and casks
#   - Sends text message notifications via iMessage
#   - Comprehensive logging for troubleshooting
#   - Safe to run multiple times
#   - Intelligent condition checking
#
# HOW TO RUN IN TERMINAL:
# 1. Open Terminal application (Applications > Utilities > Terminal)
# 2. Navigate to script directory: cd /path/to/homeBrewScripts
# 3. Make script executable: chmod +x auto-update-brew.sh
# 4. Run the script: ./auto-update-brew.sh
# Note: Use setup-auto-update.sh for scheduling automatic runs
#
# REQUIREMENTS:
#   - Homebrew must be installed
#   - macOS with administrator privileges
#   - iMessage configured for text notifications
#   - Connected to "YourWiFiNetwork" WiFi
#   - Device plugged into power
#
# CONFIGURATION:
# Edit the PHONE_NUMBER variable below to set your notification number
#
# LOG FILE:
#   All operations are logged to: ~/Library/Logs/AutoUpdateBrew.log
###############################################################################

LOG="$HOME/Library/Logs/AutoUpdateBrew.log"
echo "Starting Auto Update Brew at $(date)" >> "$LOG"

# Configuration
WIFI_NETWORK="YourWiFiNetwork"
PHONE_NUMBER="+1234567890"  # Replace with your actual phone number (format: +1234567890)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Function to check WiFi network
check_wifi_network() {
    local current_network=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')
    
    if [ "$current_network" = "$WIFI_NETWORK" ]; then
        print_success "Connected to $WIFI_NETWORK WiFi"
        return 0
    else
        print_warning "Not connected to $WIFI_NETWORK WiFi (current: $current_network)"
        return 1
    fi
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
    
    print_status "Starting Homebrew updates..."
    
    # Update Homebrew itself
    print_status "Updating Homebrew..."
    if brew update >> "$LOG" 2>&1; then
        update_summary+="✅ Homebrew updated\n"
        ((success_count++))
    else
        errors+="❌ Homebrew update failed\n"
        ((error_count++))
    fi
    
    # Upgrade all packages
    print_status "Upgrading all packages..."
    if brew upgrade >> "$LOG" 2>&1; then
        update_summary+="✅ All packages upgraded\n"
        ((success_count++))
    else
        errors+="❌ Package upgrade failed\n"
        ((error_count++))
    fi
    
    # Upgrade all casks
    print_status "Upgrading all applications..."
    if brew upgrade --cask >> "$LOG" 2>&1; then
        update_summary+="✅ All applications upgraded\n"
        ((success_count++))
    else
        errors+="❌ Application upgrade failed\n"
        ((error_count++))
    fi
    
    # Clean up old versions
    print_status "Cleaning up old versions..."
    if brew cleanup >> "$LOG" 2>&1; then
        update_summary+="✅ Cleanup completed\n"
        ((success_count++))
    else
        errors+="❌ Cleanup failed\n"
        ((error_count++))
    fi
    
    # Return summary
    echo "$update_summary"
    echo "$errors"
    echo "$success_count"
    echo "$error_count"
}

# Main execution
main() {
    print_status "Auto Update Brew started at $(date)"
    
    # Check prerequisites
    if ! check_homebrew; then
        send_text_message "❌ Auto Update Brew: Homebrew not installed"
        exit 1
    fi
    
    # Check WiFi network
    if ! check_wifi_network; then
        print_warning "Skipping update - not on $WIFI_NETWORK WiFi"
        send_text_message "⚠️ Auto Update Brew: Skipped - not on YourWiFiNetwork WiFi"
        exit 0
    fi
    
    # Check power status
    if ! check_power_status; then
        print_warning "Skipping update - not plugged into power"
        send_text_message "⚠️ Auto Update Brew: Skipped - running on battery"
        exit 0
    fi
    
    # All conditions met, proceed with updates
    print_success "All conditions met. Proceeding with updates..."
    
    # Perform updates and capture results
    local update_results=$(perform_updates)
    local update_summary=$(echo "$update_results" | head -4 | tr '\n' ' ')
    local errors=$(echo "$update_results" | tail -n +5 | head -4 | tr '\n' ' ')
    local success_count=$(echo "$update_results" | tail -n +9 | head -1)
    local error_count=$(echo "$update_results" | tail -n +10 | head -1)
    
    # Prepare notification message
    local message="🔄 Auto Update Brew completed at $(date '+%Y-%m-%d %H:%M')\n\n"
    message+="✅ Successful operations: $success_count\n"
    message+="❌ Errors: $error_count\n\n"
    
    if [ "$error_count" -eq 0 ]; then
        message+="🎉 All updates completed successfully!"
    else
        message+="⚠️ Some updates had issues. Check log for details."
    fi
    
    # Send notification
    send_text_message "$message"
    
    print_success "Auto Update Brew completed at $(date)"
    print_status "Check log file for details: $LOG"
}

# Run main function
main "$@" 