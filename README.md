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

#### `brew_setup_tahoe.sh` ⭐ **RECOMMENDED**

The main installation script with interactive features:

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

#### `install-essential-apps.sh`

Non-interactive batch installer for all applications:

```bash
./install-essential-apps.sh
```

### 🤖 Automation Scripts

#### `auto-update-brew.sh`

Basic automated updates with text notifications:

- Updates Homebrew and all packages
- Sends text message notifications
- Requires "CastleEstates" WiFi and power connection

#### `auto-update-brew-hybrid.sh`

Advanced automated updates with dual notifications:

- Email reports with detailed logs
- Text message summaries
- Enhanced error handling and retry logic

### ⚙️ Setup Scripts

#### `setup-auto-update.sh`

Configure basic automation:

```bash
./setup-auto-update.sh
```

#### `setup-hybrid-notifications.sh`

Configure advanced notifications:

```bash
./setup-hybrid-notifications.sh
```

### 🧹 Maintenance

#### `cleanup-homebrew.sh`

Comprehensive Homebrew cleanup:

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

## 📁 Log Files

All scripts create detailed logs in `~/Library/Logs/`:

- `BrewSetupTahoe.log` - Primary installation logs
- `AutoUpdateBrewHybrid.log` - Update operation logs
- `HomebrewCleanup.log` - Cleanup operation logs

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
