# 🍺 Educational Homebrew Scripts for macOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15%2B-blue.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-2.0.1-green.svg)](https://github.com/DJCastle/homeBrewScripts/releases)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Educational](https://img.shields.io/badge/Purpose-Educational-blue.svg)](https://github.com/DJCastle/homeBrewScripts)

**Learn shell scripting while automating your macOS setup!**

This is an educational collection of professional-grade shell scripts for managing Homebrew packages and applications on macOS. Each script is designed to teach best practices in shell scripting while providing real-world automation functionality.

## 🎓 Educational Objectives

**What You'll Learn:**
- 📚 **Shell Scripting Best Practices** - Error handling, logging, modular design
- ⚙️ **Configuration Management** - External config files, validation, defaults
- 🔧 **System Administration** - Package management, environment setup, automation
- 🛡️ **Safety Patterns** - Dry-run modes, validation, idempotent operations
- 🎯 **User Experience Design** - Interactive prompts, progress tracking, help systems
- 📊 **Logging & Monitoring** - Structured logging, error reporting, debugging

## ✨ Features

- 🎯 **Interactive & Educational** - Learn while you install with detailed explanations
- 🔧 **Configurable Everything** - External configuration files for easy customization
- 🤖 **Smart Automation** - Conditional updates with network and power awareness
- 🛡️ **Production-Ready Safety** - Comprehensive error handling and recovery
- 📱 **Multi-Channel Notifications** - Email reports and text message summaries
- 🔄 **Idempotent Design** - Safe to run multiple times without side effects
- 🏗️ **Architecture Aware** - Optimized for both Intel and Apple Silicon Macs
- 📊 **Comprehensive Logging** - Detailed operation logs for learning and troubleshooting
- 🧪 **Dry-Run Mode** - See what would happen before making changes
- 📖 **Extensive Documentation** - Every function and concept explained

## ⚠️ Important Disclaimers

**READ THIS BEFORE USING THESE SCRIPTS**

### 🛡️ Safety Notice

These scripts will modify your system by:

- Installing Homebrew package manager
- Modifying shell configuration files (`.zshrc`, `.bash_profile`, etc.)
- Installing applications you select
- Creating scheduled tasks for automatic updates
- Creating log files in `~/Library/Logs/`

### 📋 Your Responsibilities

- **Backup your system** before running any system modification scripts
- **Review the configuration** files before running scripts
- **Understand what each script does** by reading the documentation
- **Test in a safe environment** first if you're unsure
- **Keep your system updated** and maintain good security practices

### 🚫 Limitations

- These scripts are provided "AS IS" without warranty of any kind
- The authors are not responsible for any damage, data loss, or issues
- Scripts are designed for macOS 10.15+ only
- Some features require specific system configurations
- Network connectivity is required for downloads

### ✅ What Makes These Scripts Safer

- **Dry-run mode** - See what would happen before making changes
- **Interactive checkpoints** - You control each major step
- **Comprehensive logging** - All operations are recorded
- **Idempotent design** - Safe to run multiple times
- **Configuration validation** - Settings are checked before use
- **Error recovery** - Scripts handle failures gracefully

## 🚀 Quick Start Guide

### Prerequisites

Before you begin, ensure you have:

- **macOS 10.15 (Catalina) or later**
- **Administrator privileges** (you'll be prompted for your password)
- **Internet connection** for downloading packages
- **At least 1GB free disk space**
- **Basic familiarity with Terminal** (we'll guide you!)

### Step 1: Download the Scripts

```bash
# Clone this repository
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts

# Or download and extract the ZIP file from GitHub
```

### Step 2: Understand the Structure

```
homeBrewScripts/
├── config/                    # Configuration files
│   └── homebrew-scripts.conf  # Main configuration
├── lib/                       # Shared libraries
│   └── common.sh              # Common functions
├── homebrew-setup.sh          # Main setup script
├── auto-update-*.sh           # Automation scripts
└── README.md                  # This documentation
```

### Step 3: Configure Your Preferences

```bash
# Edit the configuration file to customize your setup
nano config/homebrew-scripts.conf

# Or let the script create a default configuration for you
```

### Step 4: Run Your First Script

```bash
# Make the script executable
chmod +x homebrew-setup.sh

# Run in dry-run mode first to see what would happen
./homebrew-setup.sh --dry-run

# Run the actual installation
./homebrew-setup.sh
```

## 📦 Configurable Applications

The scripts now use a flexible configuration system that allows you to customize which applications to install. Applications are organized by category:

### 🛠️ Development Tools
- **Visual Studio Code** - Popular code editor
- **iTerm2** - Enhanced terminal application
- **Docker Desktop** - Containerization platform
- **Postman** - API development tool
- **Sourcetree** - Git GUI client

### 📊 Productivity Apps
- **Notion** - All-in-one workspace
- **Obsidian** - Knowledge management
- **Alfred** - Productivity launcher
- **Todoist** - Task management

### 🎨 Creative Tools
- **Adobe Creative Cloud** - Creative software suite
- **Figma** - Design and prototyping
- **Sketch** - UI/UX design tool
- **Blender** - 3D modeling and animation

### 💬 Communication
- **Slack** - Team communication
- **Discord** - Gaming and community chat
- **Zoom** - Video conferencing
- **Microsoft Teams** - Business communication

### 🔧 Utilities
- **Rectangle** - Window management
- **The Unarchiver** - Archive extraction
- **AppCleaner** - Application removal
- **1Password** - Password management

> **Note:** You can customize which categories and specific applications to install by editing the configuration file. See [Configuration Examples](examples/sample-configurations.md) for different setups.

## 📋 Scripts Overview

### 🎯 Primary Installation

#### 🍺 `homebrew-setup.sh` ⭐ **RECOMMENDED**

The main educational Homebrew installer with interactive setup and customizable app selection.

**Features:**
- ✅ **Educational design** with detailed explanations
- ✅ **Interactive app selection** by category
- ✅ **Architecture detection** (Intel/Apple Silicon)
- ✅ **Dry-run mode** to preview changes
- ✅ **Comprehensive error handling** and recovery
- ✅ **Detailed logging** and progress tracking
- ✅ **Configuration validation** before execution

**Usage:**
```bash
# Interactive mode with explanations (recommended for learning)
./homebrew-setup.sh

# See what would be done without making changes
./homebrew-setup.sh --dry-run

# Non-interactive mode using configuration
./homebrew-setup.sh --non-interactive

# Configuration setup only
./homebrew-setup.sh --config-only
```

#### 📦 `install-essential-apps.sh`

Batch installer for essential applications (now uses configuration system).

**Usage:**
```bash
# Install applications based on configuration
./install-essential-apps.sh

# Preview what would be installed
./install-essential-apps.sh --dry-run
```

### 🤖 Automation Scripts

#### 🤖 `auto-update-brew.sh`

**Auto-Updater Basic - Keeps Homebrew updated with text notifications**

- Updates Homebrew and all packages automatically
- Sends text message notifications
- Smart conditions (WiFi + power required)

**How to run:**
```bash
./auto-update-brew.sh
```

#### 🤖 `auto-update-brew-hybrid.sh`

**Auto-Updater Pro - Advanced updates with email + text notifications**

- Email reports with detailed logs
- Text message summaries
- Enhanced error handling and retry logic

**How to run:**
```bash
./auto-update-brew-hybrid.sh
```

### ⚙️ Setup Scripts

#### ⚙️ `setup-auto-update.sh`

**Setup Basic Automation - Configure automatic Homebrew updates**

**How to run:**
```bash
./setup-auto-update.sh
```

#### ⚙️ `setup-hybrid-notifications.sh`

**Setup Pro Automation - Configure advanced email + text notifications**

**How to run:**
```bash
./setup-hybrid-notifications.sh
```

### 🧹 Maintenance

#### 🧹 `cleanup-homebrew.sh`

**System Cleaner - Removes old packages and frees up disk space**

**How to run:**
```bash
./cleanup-homebrew.sh
```

## 🔧 How to Use These Scripts

### Step-by-Step Instructions

#### 1. Open Terminal
- Press `Cmd + Space` to open Spotlight
- Type "Terminal" and press Enter
- Or go to Applications > Utilities > Terminal

#### 2. Navigate to the Scripts
```bash
# Change to the directory where you downloaded the scripts
cd /path/to/homeBrewScripts

# For example, if you downloaded to Downloads folder:
cd ~/Downloads/homeBrewScripts
```

#### 3. Make Scripts Executable (One Time Only)
```bash
# Make all scripts executable
chmod +x *.sh
```

#### 4. Run Your Desired Script
```bash
# For first-time setup (recommended):
./brew_setup_tahoe.sh

# For automated installation without prompts:
./install-essential-apps.sh

# For setting up automatic updates:
./setup-hybrid-notifications.sh

# For system cleanup:
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
