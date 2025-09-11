# Changelog

## [2025-01-11] - Major Repository Cleanup and New Primary Script

### Added
- **`brew_setup_tahoe.sh`**: New comprehensive primary installation script
  - Interactive checkpoints for user control
  - Individual app selection or batch installation
  - Architecture detection (Intel/Apple Silicon)
  - Color-coded progress tracking and logging
  - Non-interactive mode support (`--non-interactive`)
  - Comprehensive error handling and recovery
  - Idempotent design (safe to re-run)
  - Self-updating app pinning

### Updated
- **`install-essential-apps.sh`**: Aligned with new primary script
  - Updated app list to match `brew_setup_tahoe.sh`
  - Removed outdated apps (Brave Browser, Cursor AI, Google Chrome, Steam)
  - Added new apps (Epson Printer Utility, Icon Composer, SF Symbols)
  - Updated references to point to new primary script

- **`README.md`**: Complete documentation overhaul
  - Updated to reflect new script hierarchy
  - Added usage examples for interactive and non-interactive modes
  - Updated app lists and features
  - Removed references to deleted scripts

### Removed
- **`download-app-installers.sh`**: Removed due to outdated URLs and lack of error handling
- **`install-homebrew.sh`**: Removed as functionality is included in `brew_setup_tahoe.sh`

### Technical Details
- **Primary Script**: `brew_setup_tahoe.sh` is now the recommended entry point
- **App Alignment**: All scripts now use consistent app lists
- **Error Handling**: Improved error handling across all scripts
- **Documentation**: Updated to reflect current script lineup

## [2024-01-XX] - Added Parallels and VS Code Support

### Added
- **Visual Studio Code**: Added to the essential apps installation script
  - Automatic installation via Homebrew cask
  - Command line tools setup for `code` command
  - Proper installation path detection
  - Already-installed checks

- **Parallels Desktop**: Added to the essential apps installation script
  - Automatic installation via Homebrew cask
  - Activation reminder after installation
  - Proper installation path detection
  - Already-installed checks

### Updated
- `install-essential-apps.sh`: New script created with comprehensive features:
  - Colored output with status indicators
  - Comprehensive logging to `~/Library/Logs/brew-apps-install.log`
  - Progress spinners during installation
  - Safe reinstallation checks
  - Error handling and recovery
  - Support for both Intel and Apple Silicon Macs

- `install-homebrew.sh`: New script created for Homebrew installation:
  - Automatic detection of Intel vs Apple Silicon
  - Proper PATH configuration
  - System requirement checks
  - Comprehensive logging
  - Safe re-run capability

- `README.md`: Updated documentation to reflect new applications and features

### Technical Details
- **VS Code Installation**: Uses `brew install --cask visual-studio-code`
- **Parallels Installation**: Uses `brew install --cask parallels`
- **Logging**: All operations logged to `~/Library/Logs/brew-apps-install.log`
- **Error Handling**: Comprehensive error handling with colored output
- **Architecture Support**: Works on both Intel and Apple Silicon Macs

### Usage
```bash
# Install Homebrew first
./install-homebrew.sh

# Install all essential apps including Parallels and VS Code
./install-essential-apps.sh
```

### Post-Installation Notes
- **VS Code**: Available at `/Applications/Visual Studio Code.app`
- **Parallels**: Requires activation - please activate your license after installation
- **Command Line**: VS Code `code` command will be available after installation
