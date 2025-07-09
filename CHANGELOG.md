# Changelog

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
