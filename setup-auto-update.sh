#!/usr/bin/env bash
###############################################################################
# Script Name: setup-auto-update.sh
# Description: ⚙️ Setup Basic Automation - Configure automatic Homebrew updates
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
# Configure and set up automatic Homebrew updates with text notifications.
# This script sets up the basic auto-update system (auto-update-brew.sh).
#
# SETUP FEATURES:
#   - Configures phone number for text notifications
#   - Sets up automatic execution via macOS launchd
#   - Tests the auto-update functionality
#   - Provides scheduling options (daily/weekly/manual)
#   - Validates iMessage configuration
#
# USAGE:
# ./setup-auto-update.sh
# Follow the interactive prompts to configure
#
# NOTIFICATION SETUP:
# - Requires iMessage to be signed in and configured
# - Phone number must be in your contacts
# - Test message will be sent during setup for verification
#
# SCHEDULING OPTIONS:
# - Daily at 2:00 AM
# - Weekly on Sunday at 2:00 AM
# - Manual execution only
#
# REQUIREMENTS:
#   - macOS with administrator privileges
#   - iMessage configured and signed in
#   - auto-update-brew.sh script present
#
# LOG FILE:
#   Setup operations are logged to: ~/Library/Logs/AutoUpdateSetup.log
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_UPDATE_SCRIPT="$SCRIPT_DIR/auto-update-brew.sh"
LOG="$HOME/Library/Logs/AutoUpdateSetup.log"

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

# Function to validate phone number format
validate_phone_number() {
    local phone="$1"
    if [[ "$phone" =~ ^\+[0-9]{10,15}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to test text messaging
test_text_message() {
    local phone_number="$1"
    
    print_status "Testing text message to $phone_number..."
    
    # Send test message
    osascript <<EOF
tell application "Messages"
    send "🧪 Test message from Auto Update Brew setup script" to buddy "$phone_number" of (service 1 whose service type is iMessage)
end tell
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Test message sent successfully!"
        return 0
    else
        print_error "Failed to send test message. Please check iMessage setup."
        return 1
    fi
}

# Function to update phone number in auto-update script
update_phone_number() {
    local phone_number="$1"
    local temp_file=$(mktemp)
    
    # Update the phone number in the script
    sed "s/PHONE_NUMBER=\"[^\"]*\"/PHONE_NUMBER=\"$phone_number\"/" "$AUTO_UPDATE_SCRIPT" > "$temp_file"
    mv "$temp_file" "$AUTO_UPDATE_SCRIPT"
    
    print_success "Phone number updated in auto-update script"
}

# Function to create launchd plist for automatic execution
create_launchd_plist() {
    local schedule="$1"
    local plist_name="com.homebrew.autoupdate"
    local plist_path="$HOME/Library/LaunchAgents/$plist_name.plist"
    
    # Create plist content based on schedule
    local plist_content=""
    
    case "$schedule" in
        "daily")
            plist_content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>$plist_name</string>
    <key>ProgramArguments</key>
    <array>
        <string>$AUTO_UPDATE_SCRIPT</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrew.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrew.log</string>
</dict>
</plist>"
            ;;
        "weekly")
            plist_content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>$plist_name</string>
    <key>ProgramArguments</key>
    <array>
        <string>$AUTO_UPDATE_SCRIPT</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>0</integer>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrew.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrew.log</string>
</dict>
</plist>"
            ;;
    esac
    
    # Write plist file
    echo "$plist_content" > "$plist_path"
    
    # Load the plist
    launchctl load "$plist_path"
    
    if [ $? -eq 0 ]; then
        print_success "Automatic execution scheduled: $schedule"
        return 0
    else
        print_error "Failed to schedule automatic execution"
        return 1
    fi
}

# Main setup function
main() {
    print_status "Auto Update Brew Setup started at $(date)"
    
    # Check if auto-update script exists
    if [ ! -f "$AUTO_UPDATE_SCRIPT" ]; then
        print_error "Auto-update script not found: $AUTO_UPDATE_SCRIPT"
        exit 1
    fi
    
    # Make sure auto-update script is executable
    chmod +x "$AUTO_UPDATE_SCRIPT"
    
    echo ""
    echo "🔄 Auto Update Brew Setup"
    echo "========================="
    echo ""
    
    # Get phone number
    echo "📱 Phone Number Setup"
    echo "--------------------"
    echo "Enter your phone number for notifications (format: +1234567890):"
    read -p "Phone number: " phone_number
    
    # Validate phone number
    while ! validate_phone_number "$phone_number"; do
        print_error "Invalid phone number format. Please use format: +1234567890"
        read -p "Phone number: " phone_number
    done
    
    # Test text messaging
    echo ""
    print_status "Testing text messaging..."
    if test_text_message "$phone_number"; then
        # Update phone number in script
        update_phone_number "$phone_number"
    else
        print_warning "Text messaging test failed. You can still use the script manually."
    fi
    
    # Schedule selection
    echo ""
    echo "⏰ Automatic Execution Setup"
    echo "---------------------------"
    echo "Choose when to run automatic updates:"
    echo "1. Daily at 2:00 AM"
    echo "2. Weekly on Sunday at 2:00 AM"
    echo "3. Manual execution only"
    echo ""
    read -p "Enter choice (1-3): " schedule_choice
    
    case "$schedule_choice" in
        1)
            create_launchd_plist "daily"
            ;;
        2)
            create_launchd_plist "weekly"
            ;;
        3)
            print_status "Manual execution only selected"
            ;;
        *)
            print_error "Invalid choice. Manual execution only selected."
            ;;
    esac
    
    # Test the auto-update script
    echo ""
    print_status "Testing auto-update script..."
    if "$AUTO_UPDATE_SCRIPT"; then
        print_success "Auto-update script test completed successfully"
    else
        print_warning "Auto-update script test had issues (this is normal if conditions aren't met)"
    fi
    
    # Final instructions
    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "📱 Notifications: $phone_number"
    echo "📁 Log file: $HOME/Library/Logs/AutoUpdateBrew.log"
    echo "🔧 Manual execution: ./auto-update-brew.sh"
    echo ""
    echo "📋 Next steps:"
    echo "1. Make sure you're signed into iMessage"
    echo "2. Add your phone number to your contacts"
    echo "3. Test the script manually when on CastleEstates WiFi and plugged in"
    echo "4. Check the log file for any issues"
    echo ""
    
    print_success "Auto Update Brew setup completed at $(date)"
}

# Run main function
main "$@" 