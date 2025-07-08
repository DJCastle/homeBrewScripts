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

## 📁 Log Files

All script activities are logged to:
```
~/Library/Logs/HomebrewInstall.log      # Homebrew installation
~/Library/Logs/EssentialAppsInstall.log # Essential apps installation
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