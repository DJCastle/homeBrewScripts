# Homebrew Scripts for macOS

A collection of automated scripts for managing Homebrew packages and applications on macOS, supporting both Intel and Apple Silicon Macs.

## 🚀 Quick Start

### Prerequisites
- macOS 10.15 (Catalina) or later
- Administrator privileges
- Internet connection

### Installation
```bash
# Clone this repository
git clone https://github.com/yourusername/homeBrewScripts.git
cd homeBrewScripts

# Make scripts executable
chmod +x *.sh

# Run the comprehensive setup script
./brew_setup_tahoe.sh
```

## 📦 Scripts Overview

### Core Installation Scripts

#### `brew_setup_tahoe.sh` ⭐ **PRIMARY SCRIPT**
- **Purpose**: Comprehensive Homebrew setup with interactive checkpoints
- **Applications**: Adobe Creative Cloud, Bambu Studio, ChatGPT, Epson Printer Utility, Grammarly Desktop, Icon Composer, SF Symbols, Visual Studio Code
- **Features**:
  - Interactive checkpoints for user control
  - Individual app selection or batch installation
  - Architecture detection (Intel/Apple Silicon)
  - Color-coded progress tracking
  - Comprehensive error handling
  - Non-interactive mode support (`--non-interactive`)
  - Idempotent design (safe to re-run)
  - Self-updating app pinning

#### `install-essential-apps.sh`
- **Purpose**: Non-interactive app installation (aligned with brew_setup_tahoe.sh)
- **Applications**: Adobe Creative Cloud, Bambu Studio, ChatGPT, Epson Printer Utility, Grammarly Desktop, Icon Composer, SF Symbols, Visual Studio Code
- **Features**:
  - Progress feedback and status indicators
  - Safe reinstallation checks
  - Detailed logging
  - Error recovery
  - Batch installation without prompts

### Automation Scripts

#### `auto-update-brew.sh`
- **Purpose**: Automated Homebrew updates with notifications
- **Features**:
  - Runs only on "CastleEstates" WiFi
  - Requires power connection
  - Background execution
  - iMessage notifications
  - Comprehensive logging

#### `auto-update-brew-hybrid.sh`
- **Purpose**: Enhanced auto-update with hybrid notifications
- **Features**:
  - Email + iMessage notifications
  - Detailed email reports
  - Quick text summaries
  - Retry logic for failed updates
  - Network and power monitoring

#### `setup-auto-update.sh`
- **Purpose**: Sets up automated update scheduling
- **Features**:
  - Launchd service configuration
  - Phone number configuration
  - Customizable schedule
  - Background service management

#### `setup-hybrid-notifications.sh`
- **Purpose**: Configures hybrid notification system
- **Features**:
  - Email server configuration
  - iMessage setup
  - Notification preferences
  - Testing capabilities

### Maintenance Scripts

#### `cleanup-homebrew.sh`
- **Purpose**: Homebrew maintenance and cleanup
- **Features**:
  - Removes old package versions
  - Cleans up cache files
  - Updates Homebrew itself
  - System optimization
  - Disk space recovery

## 🔧 Usage

### Recommended Installation (Interactive)
```bash
# Primary installation script with interactive checkpoints
./brew_setup_tahoe.sh

# Set up auto-updates (choose one)
./setup-hybrid-notifications.sh  # Advanced (email + text)
./setup-auto-update.sh           # Basic (text only)
```

### Non-Interactive Installation
```bash
# Automated installation without prompts
./brew_setup_tahoe.sh --non-interactive

# Or install apps separately
./install-essential-apps.sh
```

### Automated Updates
The auto-update scripts run in the background and will:
- Check for updates daily
- Only run when connected to "CastleEstates" WiFi
- Only run when plugged into power
- Send notifications on completion

### Maintenance
```bash
# Run cleanup monthly
./cleanup-homebrew.sh
```

## 📱 Notifications

### Email Notifications
- Detailed update reports
- Error summaries
- System health information
- Configurable recipients

### iMessage Notifications
- Quick status updates
- Success/failure indicators
- Network status alerts

## 🔍 Troubleshooting

### Common Issues

#### Script Permission Denied
```bash
chmod +x *.sh
```

#### Homebrew Installation Fails
```bash
# Check internet connection
ping -c 3 google.com

# Check system requirements
sw_vers
```

#### Auto-update Not Working
```bash
# Check launchd service
launchctl list | grep brew

# Check logs
tail -f ~/Library/Logs/brew-auto-update.log
```

#### Notification Issues
```bash
# Test iMessage
osascript -e 'tell application "Messages" to send "Test" to buddy "your-phone"'

# Check email configuration
cat ~/.brew-notifications.conf
```

### Log Files
- Homebrew installation: `~/Library/Logs/homebrew-install.log`
- Auto-updates: `~/Library/Logs/brew-auto-update.log`
- App installation: `~/Library/Logs/brew-apps-install.log`
- Cleanup: `~/Library/Logs/brew-cleanup.log`

## 🛠️ Customization

### Adding New Apps
Edit both `brew_setup_tahoe.sh` and `install-essential-apps.sh` to add new applications:

1. **In `brew_setup_tahoe.sh`**: Add to the `APPS` array and `APP_DESCRIPTIONS` associative array
2. **In `install-essential-apps.sh`**: Add to the installation section and apps array

```bash
# Example addition
APPS=(
    "your-app-name"
    # ... existing apps
)
```

### Changing WiFi Network
Edit the network check in auto-update scripts:
```bash
WIFI_NAME="Your-WiFi-Name"
```

### Customizing Notifications
Edit notification scripts to modify:
- Email recipients
- Message content
- Notification timing

## 📋 Requirements

### System Requirements
- macOS 10.15 (Catalina) or later
- Intel Mac or Apple Silicon Mac
- Administrator privileges
- Internet connection

### Network Requirements
- WiFi connection to "CastleEstates" (for auto-updates)
- Power connection (for auto-updates)
- iMessage account (for notifications)
- Email account (for detailed reports)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

These scripts modify system settings and install software. Use at your own risk. Always backup important data before running system scripts.

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Review log files
3. Create an issue on GitHub

---

**Made with ❤️ for macOS automation**
