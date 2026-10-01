#!/usr/bin/env bash

# Fail fast: error on any failure, unset variable, or broken pipe
set -euo pipefail
###############################################################################
# Script Name: setup-hybrid-notifications.sh
# Description: ⚙️ Setup Pro Automation - Configure advanced email + text notifications
# Author: DJCastle
# Version: 4.1.0
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
# HOW TO RUN IN TERMINAL:
# 1. Open Terminal application (Applications > Utilities > Terminal)
# 2. Navigate to script directory: cd /path/to/homeBrewScripts
# 3. Make script executable: chmod +x setup-hybrid-notifications.sh
# 4. Preview first: ./setup-hybrid-notifications.sh --dry-run
# 5. Run the script: ./setup-hybrid-notifications.sh
# Follow the interactive prompts to configure both notification methods
#
# OPTIONS:
#   --dry-run, --check   Walk through the setup questions and show what would be
#                        configured — no messages, file edits, or schedule changes
#   --help, -h           Show usage and exit
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

# Parse options
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run|--check)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: ./setup-hybrid-notifications.sh [--dry-run] [--help]"
            echo ""
            echo "Options:"
            echo "  --dry-run, --check   Walk through the setup questions and show what would"
            echo "                       be configured — no messages sent, no files changed,"
            echo "                       no schedule installed"
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
fi

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

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would send a test email to $email_address"
        return 0
    fi

    print_status "Testing email functionality..."
    
    # Check if mail command is available
    if ! command -v mail &> /dev/null; then
        print_error "mail command not available. Please configure Mail app first."
        return 1
    fi
    
    # Send test email
    local test_subject="🧪 Test Email from Auto Update Brew Setup"
    local test_body="This is a test email from your Auto Update Brew setup script. If you receive this, email notifications are working correctly."
    
    # `mail` exits 0 even with no mail transfer agent running to deliver the
    # message. This test used to report "Test email sent successfully!" in that
    # case, which is the worst possible outcome during setup: the user is told
    # email works, and then never receives a single notification.
    #
    # macOS ships postfix but leaves it disabled, so this is the default state.
    if ! mail_transport_available; then
        print_error "Test email NOT sent: no mail transfer agent is running on this Mac."
        print_error "  macOS ships postfix but leaves it disabled, so 'mail' accepts the"
        print_error "  message and silently discards it. Nothing would arrive."
        print_error "  Options: use text notifications instead, or configure an MTA"
        print_error "  or SMTP relay before relying on email."
        return 1
    fi

    if echo "$test_body" | mail -s "$test_subject" "$email_address" >> "$LOG" 2>&1; then
        print_success "Test email handed to the local mail system."
        print_status  "Check your inbox. If nothing arrives, delivery failed downstream"
        print_status  "of this script — see $LOG and your MTA's logs."
        return 0
    else
        print_error "Failed to send test email; see $LOG"
        return 1
    fi
}

# Report whether a mail transfer agent is actually running.
#
# postqueue exits non-zero with "mail system is down" when postfix is not
# running, which is the macOS default. Needs no elevated privileges.
mail_transport_available() {
    if [[ -x /usr/sbin/postqueue ]]; then
        /usr/sbin/postqueue -p >/dev/null 2>&1 && return 0
        return 1
    fi
    # No postqueue: cannot prove delivery works, so do not claim that it does.
    return 1
}

# Function to test text messaging
test_text_message() {
    local phone_number="$1"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would send a test iMessage to $phone_number"
        return 0
    fi

    print_status "Testing text message to $phone_number..."
    
    # Send test message
    # Pass the number as argv with a QUOTED heredoc delimiter, rather than
    # interpolating it into the AppleScript. A number containing a quote would
    # otherwise alter or break the script.
    #
    # Test the command directly too: under `set -euo pipefail` a bare osascript
    # that fails aborts the script, so the else branch below was unreachable.
    if osascript - "$phone_number" <<'EOF'
on run argv
    set phoneNumber to item 1 of argv
    tell application "Messages"
        send "🧪 Test message from Auto Update Brew hybrid setup script" to buddy phoneNumber of (service 1 whose service type is iMessage)
    end tell
end run
EOF
    then
        print_success "Test message sent successfully!"
        return 0
    else
        print_error "Failed to send test message."
        print_error "  Check that Messages is signed in, and that your terminal is allowed"
        print_error "  to control it in System Settings > Privacy & Security > Automation."
        return 1
    fi
}

# Escape a string for safe use as the replacement side of a sed s||| expression.
# Delimiter is assumed to be '|'. Escapes backslash, ampersand, and pipe so that
# caller-supplied values can't break the sed command or inject replacement syntax.
sed_escape_replacement() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//&/\\&}"
    s="${s//|/\\|}"
    printf '%s' "$s"
}

# Function to update configuration in hybrid script
update_script_config() {
    local email_address="$1"
    local phone_number="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would set EMAIL_ADDRESS=\"$email_address\" and PHONE_NUMBER=\"$phone_number\" in auto-update-brew-hybrid.sh"
        return 0
    fi

    local email_escaped phone_escaped
    email_escaped="$(sed_escape_replacement "$email_address")"
    phone_escaped="$(sed_escape_replacement "$phone_number")"
    local temp_file
    temp_file=$(mktemp)

    sed -e "s|EMAIL_ADDRESS=\"[^\"]*\"|EMAIL_ADDRESS=\"$email_escaped\"|" \
        -e "s|PHONE_NUMBER=\"[^\"]*\"|PHONE_NUMBER=\"$phone_escaped\"|" \
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
    
    local domain="gui/$(id -u)"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would write $plist_path ($schedule schedule)"
        print_status "[DRY-RUN] Would unload any existing agent, then load it with:"
        print_status "[DRY-RUN]   launchctl bootout $domain/$plist_name   (if already loaded)"
        print_status "[DRY-RUN]   launchctl bootstrap $domain $plist_path"
        return 0
    fi

    # Write plist file
    echo "$plist_content" > "$plist_path"

    # Unload any existing agent FIRST.
    #
    # bootstrap refuses to load a label that is already loaded, so re-running
    # this installer used to fail here. And because the old code checked $?
    # after a bare `launchctl load`, `set -e` aborted before the error branch
    # could report it — the installer just died with no explanation.
    #
    # bootout on a service that is not loaded returns non-zero, which is fine
    # and expected, hence the `|| true`.
    launchctl bootout "$domain/$plist_name" >/dev/null 2>&1 || true

    # `launchctl load` is deprecated — `launchctl help` names bootstrap/enable
    # as the replacements. bootstrap also takes an explicit domain target, so
    # the agent cannot land in the wrong session.
    if launchctl bootstrap "$domain" "$plist_path"; then
        print_success "Automatic execution scheduled: $schedule"
        return 0
    else
        print_error "Failed to schedule automatic execution."
        print_error "  Tried: launchctl bootstrap $domain $plist_path"
        print_error "  Check the plist with: plutil -lint $plist_path"
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
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would make auto-update-brew-hybrid.sh executable (chmod +x)"
    else
        chmod +x "$HYBRID_SCRIPT"
    fi
    
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
    local test_args=()
    if [[ "$DRY_RUN" == "true" ]]; then
        test_args+=("--dry-run")
    fi
    if "$HYBRID_SCRIPT" ${test_args[@]+"${test_args[@]}"}; then
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
    echo "4. Test the script manually when on YourWiFiNetwork WiFi and plugged in"
    echo "5. Check the log file for any issues"
    echo ""
    echo "🚨 What happens if the script doesn't run:"
    echo "- If not on YourWiFiNetwork WiFi: Sends notification and skips"
    echo "- If not plugged into power: Sends notification and skips"
    echo "- If Homebrew not installed: Sends error notification"
    echo "- If network issues: Retries up to 3 times with 5-minute delays"
    echo ""
    
    print_success "Hybrid notification setup completed at $(date)"
}

# Run main function
main "$@" 