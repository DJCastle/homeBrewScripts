# 🛠️ Homebrew Scripts

A collection of useful scripts for managing Homebrew on macOS systems.

## 📦 Scripts

### `install-homebrew.sh`
A comprehensive Homebrew installer script that:
- ✅ Installs Homebrew on macOS (Intel or Apple Silicon)
- ✅ Automatically configures your shell profile (zsh or bash)
- ✅ Runs `brew doctor` for health checks
- ✅ Logs all activity for troubleshooting
- ✅ Safe to run multiple times

### `install-essential-apps.sh`
An essential applications installer that:
- ✅ Installs popular applications using Homebrew casks
- ✅ Includes: Bambu Studio, Brave Browser, ChatGPT, Cursor AI, Grammarly Desktop, Google Chrome
- ✅ Checks for existing installations to avoid duplicates
- ✅ Provides colored progress feedback
- ✅ Logs all activity for troubleshooting
- ✅ Safe to run multiple times

### `auto-update-brew.sh`
An intelligent auto-update script that:
- ✅ Updates Homebrew and all installed packages/apps
- ✅ Only runs when on "CastleEstates" WiFi and plugged into power
- ✅ Sends text message notifications with results
- ✅ Runs in background with comprehensive logging
- ✅ Safe to run multiple times with smart condition checking

### `setup-auto-update.sh`
A setup script for automatic updates that:
- ✅ Configures phone number for notifications
- ✅ Sets up automatic execution via launchd
- ✅ Tests the auto-update functionality
- ✅ Provides scheduling options (daily/weekly/manual)

### `auto-update-brew-hybrid.sh`
A hybrid notification auto-update script that:
- ✅ Updates Homebrew and all installed packages/apps
- ✅ Only runs when on "CastleEstates" WiFi and plugged into power
- ✅ Sends detailed email reports AND quick text summaries
- ✅ Includes retry logic for network issues
- ✅ Comprehensive error handling and logging
- ✅ Safe to run multiple times with smart condition checking

### `setup-hybrid-notifications.sh`
A setup script for hybrid notifications that:
- ✅ Configures both email and phone number for notifications
- ✅ Tests both notification methods
- ✅ Sets up automatic execution via launchd
- ✅ Provides scheduling recommendations
- ✅ Validates all configuration settings

### `cleanup-homebrew.sh`
A comprehensive cleanup script that:
- ✅ Removes old versions of packages and casks
- ✅ Cleans up download cache and orphaned dependencies
- ✅ Runs brew doctor for health check
- ✅ Shows disk usage statistics before/after cleanup
- ✅ Logs all cleanup activities for troubleshooting
- ✅ Safe to run multiple times

## 🚀 Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/homebrew-scripts.git
   cd homebrew-scripts
   ```

2. **Install Homebrew:**
   ```bash
   ./install-homebrew.sh
   ```

3. **Install essential applications:**
   ```bash
   ./install-essential-apps.sh
   ```

4. **Set up automatic updates (optional):**
   ```bash
   # For text-only notifications:
   ./setup-auto-update.sh
   
   # For hybrid notifications (email + text):
   ./setup-hybrid-notifications.sh
   ```

## 📋 Requirements

- macOS Ventura, Sonoma, or newer
- Intel Mac or Apple Silicon (M1/M2/M3)
- Terminal access

## 🔧 Usage

### Homebrew Installer

The `install-homebrew.sh` script will:

1. Check if Homebrew is already installed
2. Download and install Homebrew using the official installer
3. Configure your shell profile automatically
4. Run `brew doctor` to verify the installation
5. Log all activities to `~/Library/Logs/HomebrewInstall.log`

**Usage:**
```bash
./install-homebrew.sh
```

**What it does:**
- Detects your Mac architecture (Intel vs Apple Silicon)
- Adds Homebrew to the appropriate shell profile (`.zprofile` for zsh, `.bash_profile` for bash)
- Provides detailed logging for troubleshooting
- Includes comprehensive error handling

### Essential Apps Installer

The `install-essential-apps.sh` script will:

1. Check if Homebrew is installed (exits if not)
2. Update Homebrew to get latest package information
3. Install each application if not already present
4. Provide colored progress feedback
5. Log all activities to `~/Library/Logs/EssentialAppsInstall.log`

**Usage:**
```bash
./install-essential-apps.sh
```

**Applications installed:**
- **Bambu Studio** - 3D printing software
- **Brave Browser** - Privacy-focused browser
- **ChatGPT Desktop** - AI chat application
- **Cursor AI** - AI-powered code editor
- **Grammarly Desktop** - Writing assistant
- **Google Chrome** - Web browser

**What it does:**
- Checks for existing installations (both Homebrew and Applications folder)
- Provides real-time colored feedback during installation
- Generates a summary of successful and failed installations
- Includes helpful next steps for post-installation setup

### Auto Update System

The auto-update system consists of two scripts:

#### `auto-update-brew.sh`
**Smart Conditions:**
- ✅ Only runs when connected to "CastleEstates" WiFi
- ✅ Only runs when plugged into power (not on battery)
- ✅ Sends text message notifications with results
- ✅ Comprehensive logging for troubleshooting

**What it updates:**
- Homebrew itself
- All installed packages (`brew upgrade`)
- All installed applications (`brew upgrade --cask`)
- Cleans up old versions (`brew cleanup`)

**Usage:**
```bash
./auto-update-brew.sh
```

#### `setup-auto-update.sh`
**Setup Features:**
- Configures your phone number for notifications
- Tests text messaging functionality
- Sets up automatic execution via launchd
- Provides scheduling options

**Scheduling Options:**
- Daily at 2:00 AM
- Weekly on Sunday at 2:00 AM
- Manual execution only

**Usage:**
```bash
./setup-auto-update.sh
```

## 📁 Log Files

All script activities are logged to:
```
~/Library/Logs/HomebrewInstall.log      # Homebrew installation
~/Library/Logs/EssentialAppsInstall.log # Essential apps installation
~/Library/Logs/AutoUpdateBrew.log       # Auto-update activities
~/Library/Logs/AutoUpdateSetup.log      # Setup activities
~/Library/Logs/AutoUpdateBrewHybrid.log # Hybrid auto-update activities
~/Library/Logs/HybridNotificationSetup.log # Hybrid setup activities
~/Library/Logs/HomebrewCleanup.log      # Cleanup activities
```

## 🐛 Troubleshooting

If you encounter issues:

1. **Check the log files:**
   ```bash
   cat ~/Library/Logs/HomebrewInstall.log
   cat ~/Library/Logs/EssentialAppsInstall.log
   ```

2. **Verify Homebrew installation:**
   ```bash
   brew --version
   ```

3. **Manual shell configuration:**
   - For Apple Silicon: `eval "$(/opt/homebrew/bin/brew shellenv)"`
   - For Intel Macs: `eval "$(/usr/local/bin/brew shellenv)"`

4. **For app installation issues:**
   - Check if apps are already installed: `brew list --cask`
   - Update Homebrew: `brew update`
   - Clean up: `brew cleanup`

5. **For auto-update issues:**
   - Check WiFi connection: `networksetup -getairportnetwork en0`
   - Check power status: `pmset -g ps`
   - Verify iMessage setup: Sign into Messages app
   - Check launchd status: `launchctl list | grep homebrew`

6. **For cleanup issues:**
   - Check disk space: `df -h`
   - Verify Homebrew health: `brew doctor`
   - Check for orphaned packages: `brew deps --installed`

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/new-script`
3. Add your script and update documentation
4. Commit your changes: `git commit -am 'Add new script'`
5. Push to the branch: `git push origin feature/new-script`
6. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Homebrew team for the excellent package manager
- macOS community for testing and feedback

---

**Note:** Remember to commit your changes regularly! 💾 