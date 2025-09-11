# 🍺 Homebrew Scripts for macOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15%2B-blue.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/DJCastle/homeBrewScripts/releases)

A comprehensive collection of automated scripts for managing Homebrew packages and applications on macOS. Designed for both Intel and Apple Silicon Macs with professional-grade error handling, logging, and user experience.

## ✨ Features

- 🎯 **Interactive Installation** - Choose apps individually or install all at once
- 🤖 **Automated Updates** - Smart background updates with notifications
- 🛡️ **Safe & Reliable** - Comprehensive error handling and recovery
- 📱 **Smart Notifications** - Email and text alerts for update status
- 🔄 **Idempotent Design** - Safe to run multiple times
- 🏗️ **Architecture Aware** - Optimized for both Intel and Apple Silicon
- 📊 **Detailed Logging** - Complete operation logs for troubleshooting

## 🚀 Quick Start

### Prerequisites

- macOS 10.15 (Catalina) or later
- Administrator privileges
- Internet connection

### Installation

```bash
# Clone this repository
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts

# Make scripts executable
chmod +x *.sh

# Run the primary installation script
./brew_setup_tahoe.sh
```

## 📦 Applications Included

- **Adobe Creative Cloud** - Creative software suite
- **Bambu Studio** - 3D printing slicer software
- **ChatGPT Desktop** - AI assistant desktop app
- **Epson Printer Utility** - Printer management tools
- **Grammarly Desktop** - Writing assistant
- **Icon Composer** - macOS icon creation tool
- **Microsoft Edge** - Modern web browser
- **SF Symbols** - Apple's symbol library
- **Visual Studio Code** - Code editor

## 📋 Scripts Overview

### 🎯 Primary Installation

#### 🍺 `brew_setup_tahoe.sh` ⭐ **RECOMMENDED**

**Main Homebrew Installer - Interactive setup with app selection**

- ✅ **Interactive app selection** or batch installation
- ✅ **Architecture detection** (Intel/Apple Silicon)
- ✅ **Color-coded progress** tracking
- ✅ **Non-interactive mode** (`--non-interactive`)
- ✅ **Comprehensive error handling** and recovery
- ✅ **Detailed logging** and status reporting

```bash
# Interactive mode (recommended)
./brew_setup_tahoe.sh

# Non-interactive mode
./brew_setup_tahoe.sh --non-interactive
```

#### 🔑 `setup-github-token.sh`

**GitHub Token Setup - Configure GitHub Personal Access Token for Homebrew**

- ✅ **Secure token configuration** with validation
- ✅ **Interactive setup** with step-by-step guidance
- ✅ **Rate limit improvement** (60 → 5,000 requests/hour)
- ✅ **Automatic shell integration** (zsh/bash support)
- ✅ **Token management** (setup, status, removal)

```bash
# Interactive setup
./setup-github-token.sh

# Direct token setup
./setup-github-token.sh --token ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Check current status
./setup-github-token.sh --status

# Remove configured token
./setup-github-token.sh --remove
```

#### 📦 `install-essential-apps.sh`

**Batch App Installer - Installs all essential apps automatically**

```bash
./install-essential-apps.sh
```

### 🤖 Automation Scripts

#### 🤖 `auto-update-brew.sh`

**Auto-Updater Basic - Keeps Homebrew updated with text notifications**

- Updates Homebrew and all packages automatically
- Sends text message notifications
- Smart conditions (WiFi + power required)

#### 🤖 `auto-update-brew-hybrid.sh`

**Auto-Updater Pro - Advanced updates with email + text notifications**

- Email reports with detailed logs
- Text message summaries
- Enhanced error handling and retry logic

### ⚙️ Setup Scripts

#### ⚙️ `setup-auto-update.sh`

**Setup Basic Automation - Configure automatic Homebrew updates**

```bash
./setup-auto-update.sh
```

#### ⚙️ `setup-hybrid-notifications.sh`

**Setup Pro Automation - Configure advanced email + text notifications**

```bash
./setup-hybrid-notifications.sh
```

### 🧹 Maintenance

#### 🧹 `cleanup-homebrew.sh`

**System Cleaner - Removes old packages and frees up disk space**

```bash
./cleanup-homebrew.sh
```

## 🔧 Usage Examples

### First-Time Setup

```bash
# Interactive installation with app selection
./brew_setup_tahoe.sh

# Set up automated updates
./setup-hybrid-notifications.sh
```

### Automated Installation

```bash
# Install everything without prompts
./brew_setup_tahoe.sh --non-interactive

# Or use the dedicated batch installer
./install-essential-apps.sh
```

### Maintenance

```bash
# Clean up old packages and cache
./cleanup-homebrew.sh

# Manual update check
./auto-update-brew-hybrid.sh
```

### GitHub API Configuration (Recommended)

```bash
# Set up GitHub Personal Access Token for better rate limits
./setup-github-token.sh
```

**Why configure a GitHub token?**
- **Higher rate limits**: 5,000 vs 60 requests/hour
- **Faster updates**: Reduced API throttling during brew operations
- **Better reliability**: Fewer failed operations due to rate limiting
- **Automatic integration**: Works seamlessly with all update scripts

## 📁 Log Files

All scripts create detailed logs in `~/Library/Logs/`:

- `BrewSetupTahoe.log` - Primary installation logs
- `AutoUpdateBrewHybrid.log` - Update operation logs
- `HomebrewCleanup.log` - Cleanup operation logs
- `GitHubTokenSetup.log` - Token configuration logs

## 🛠️ Requirements

- **macOS**: 10.15 (Catalina) or later
- **Architecture**: Intel or Apple Silicon
- **Permissions**: Administrator privileges
- **Network**: Internet connection required
- **Notifications**: iMessage and Mail app configured (for automation)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

These scripts modify system settings and install software. Use at your own risk. Always backup important data before running system scripts.

---

**Made with ❤️ for macOS automation**  
**Author:** DJCastle | **License:** MIT | **Version:** 1.0.0
