#!/usr/bin/env bash
###############################################################################
# Script Name: setup-hybrid-notifications.sh
# Description: Configuration script for advanced hybrid notifications (email + text)
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
# Configure hybrid notifications (email + text) for the advanced auto-update
# system. This script sets up auto-update-brew-hybrid.sh with dual notification methods.
#
# SETUP FEATURES:
#   - Configures email address for detailed HTML reports
#   - Configures phone number for quick text summaries
#   - Tests both notification methods during setup
#   - Sets up automatic execution via macOS launchd
#   - Provides intelligent scheduling recommendations
#   - Validates both Mail app and iMessage configuration
#
# USAGE:
# ./setup-hybrid-notifications.sh
# Follow the interactive prompts to configure both notification methods
#
# NOTIFICATION METHODS:
# 📧 EMAIL: Detailed HTML reports using macOS Mail app (no external dependencies)
# 📱 TEXT: Quick status summaries via iMessage
#
# REQUIREMENTS:
#   - macOS with administrator privileges
#   - Mail app configured with email account
#   - iMessage configured and signed in
#   - auto-update-brew-hybrid.sh script present
#
# SCHEDULING RECOMMENDATIONS:
# - WEEKLY (recommended): Less notifications while staying current
# - DAILY: Latest updates if you use your Mac heavily
# - MANUAL: Full control over when updates happen
#
# LOG FILE:
#   Setup operations are logged to: ~/Library/Logs/HybridNotificationSetup.log
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYBRID_SCRIPT="$SCRIPT_DIR/auto-update-brew-hybrid.sh"
LOG="$HOME/Library/Logs/HybridNotificationSetup.log"

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

# Function to validate email format
validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
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

# Function to test email functionality
test_email() {
    local email_address="$1"
    
    print_status "Testing email functionality..."
    
    # Check if mail command is available
    if ! command -v mail &> /dev/null; then
        print_error "mail command not available. Please configure Mail app first."
        return 1
    fi
    
    # Send test email
    local test_subject="🧪 Test Email from Auto Update Brew Setup"
    local test_body="This is a test email from your Auto Update Brew setup script. If you receive this, email notifications are working correctly."
    
    echo "$test_body" | mail -s "$test_subject" "$email_address" >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Test email sent successfully!"
        return 0
    else
        print_error "Failed to send test email. Please check Mail app configuration."
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
    send "🧪 Test message from Auto Update Brew hybrid setup script" to buddy "$phone_number" of (service 1 whose service type is iMessage)
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

# Function to update configuration in hybrid script
update_script_config() {
    local email_address="$1"
    local phone_number="$2"
    local temp_file=$(mktemp)
    
    # Update both email and phone number in the script
    sed -e "s/EMAIL_ADDRESS=\"[^\"]*\"/EMAIL_ADDRESS=\"$email_address\"/" \
        -e "s/PHONE_NUMBER=\"[^\"]*\"/PHONE_NUMBER=\"$phone_number\"/" \
        "$HYBRID_SCRIPT" > "$temp_file"
    
    mv "$temp_file" "$HYBRID_SCRIPT"
    
    print_success "Configuration updated in hybrid script"
}

# Function to create launchd plist for automatic execution
create_launchd_plist() {
    local schedule="$1"
    local plist_name="com.homebrew.hybridautoupdate"
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
        <string>$HYBRID_SCRIPT</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrewHybrid.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrewHybrid.log</string>
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
        <string>$HYBRID_SCRIPT</string>
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
    <string>$HOME/Library/Logs/AutoUpdateBrewHybrid.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/AutoUpdateBrewHybrid.log</string>
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

# Function to show scheduling recommendations
show_scheduling_recommendations() {
    echo ""
    echo "⏰ Scheduling Recommendations"
    echo "============================"
    echo ""
    echo "📅 WEEKLY (Recommended):"
    echo "   ✅ Less notification noise"
    echo "   ✅ Still keeps your system current"
    echo "   ✅ Runs every Sunday at 2:00 AM"
    echo "   ✅ Good balance of updates vs. notifications"
    echo ""
    echo "📅 DAILY:"
    echo "   ✅ Always has the latest updates"
    echo "   ❌ More notifications (daily emails/texts)"
    echo "   ✅ Runs every day at 2:00 AM"
    echo "   ✅ Good if you use your Mac heavily"
    echo ""
    echo "📅 MANUAL:"
    echo "   ✅ No automatic notifications"
    echo "   ✅ You control when updates happen"
    echo "   ❌ You must remember to run updates"
    echo "   ✅ Good if you prefer manual control"
    echo ""
}

# Main setup function
main() {
    print_status "Hybrid Notification Setup started at $(date)"
    
    # Check if hybrid script exists
    if [ ! -f "$HYBRID_SCRIPT" ]; then
        print_error "Hybrid script not found: $HYBRID_SCRIPT"
        exit 1
    fi
    
    # Make sure hybrid script is executable
    chmod +x "$HYBRID_SCRIPT"
    
    echo ""
    echo "🔄 Hybrid Notification Setup"
    echo "============================"
    echo ""
    
    # Get email address
    echo "📧 Email Setup"
    echo "--------------"
    echo "Enter your email address for detailed reports:"
    read -p "Email address: " email_address
    
    # Validate email
    while ! validate_email "$email_address"; do
        print_error "Invalid email format. Please enter a valid email address."
        read -p "Email address: " email_address
    done
    
    # Test email
    echo ""
    print_status "Testing email functionality..."
    if test_email "$email_address"; then
        print_success "Email notifications configured successfully"
    else
        print_warning "Email test failed. You can still use the script manually."
    fi
    
    # Get phone number
    echo ""
    echo "📱 Phone Number Setup"
    echo "--------------------"
    echo "Enter your phone number for quick summaries (format: +1234567890):"
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
        print_success "Text notifications configured successfully"
    else
        print_warning "Text messaging test failed. You can still use the script manually."
    fi
    
    # Update script configuration
    update_script_config "$email_address" "$phone_number"
    
    # Show scheduling recommendations
    show_scheduling_recommendations
    
    # Schedule selection
    echo "Choose when to run automatic updates:"
    echo "1. Weekly (recommended) - Sunday at 2:00 AM"
    echo "2. Daily - Every day at 2:00 AM"
    echo "3. Manual execution only"
    echo ""
    read -p "Enter choice (1-3): " schedule_choice
    
    case "$schedule_choice" in
        1)
            create_launchd_plist "weekly"
            ;;
        2)
            create_launchd_plist "daily"
            ;;
        3)
            print_status "Manual execution only selected"
            ;;
        *)
            print_error "Invalid choice. Manual execution only selected."
            ;;
    esac
    
    # Test the hybrid script
    echo ""
    print_status "Testing hybrid auto-update script..."
    if "$HYBRID_SCRIPT"; then
        print_success "Hybrid script test completed successfully"
    else
        print_warning "Hybrid script test had issues (this is normal if conditions aren't met)"
    fi
    
    # Final instructions
    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "📧 Email notifications: $email_address"
    echo "📱 Text notifications: $phone_number"
    echo "📁 Log file: $HOME/Library/Logs/AutoUpdateBrewHybrid.log"
    echo "🔧 Manual execution: ./auto-update-brew-hybrid.sh"
    echo ""
    echo "📋 Next steps:"
    echo "1. Make sure Mail app is configured"
    echo "2. Make sure you're signed into iMessage"
    echo "3. Add your phone number to your contacts"
    echo "4. Test the script manually when on CastleEstates WiFi and plugged in"
    echo "5. Check the log file for any issues"
    echo ""
    echo "🚨 What happens if the script doesn't run:"
    echo "- If not on CastleEstates WiFi: Sends notification and skips"
    echo "- If not plugged into power: Sends notification and skips"
    echo "- If Homebrew not installed: Sends error notification"
    echo "- If network issues: Retries up to 3 times with 5-minute delays"
    echo ""
    
    print_success "Hybrid notification setup completed at $(date)"
}

# Run main function
main "$@" 