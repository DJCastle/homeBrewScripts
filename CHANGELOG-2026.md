# Changelog - 2026 Edition (v3.0.0)

## Release Date: February 6, 2026

### 🎯 Major Updates

#### 1. Copyright & Dating (High Priority)
- ✅ Updated LICENSE copyright to 2026
- ✅ Added "Updated: 2026-02-06" to all script headers
- ✅ Updated manifest.json timestamps
- ✅ Updated documentation example timestamps

#### 2. macOS Version Requirements (High Priority)
- ✅ Updated minimum requirement from macOS 10.15 (Catalina) → **12.0 (Monterey)**
- ✅ Updated README.md badges and documentation
- ✅ Updated brew_setup_tahoe.sh validation
- ✅ Updated safety documentation

**Rationale:** macOS 10.15 is from 2019 (7 years old). Most users in 2026 are on macOS 13+ (Ventura).

#### 3. Critical Bug Fixes (High Priority)
- ✅ **Fixed `brew pin` bug** - Removed incorrect pinning of casks
  - `brew pin` only works for formulae, not casks
  - Replaced with educational explanation about self-updating apps
  - Now correctly informs users about HOMEBREW_NO_AUTO_UPDATE

#### 4. Code Refactoring (High Priority)
- ✅ **Removed hardcoded application list** from brew_setup_tahoe.sh
  - Eliminated duplicate APP_DESCRIPTIONS and APPS arrays
  - Removed redundant install_all_apps() and install_apps_individually() functions
  - Now fully uses config-based system from config/homebrew-scripts.conf

#### 5. Application Modernization (Medium Priority)
- ✅ Updated config with **modern 2026 applications**:

**Development Tools:**
  - Added: Cursor (AI Code Editor)
  - Added: Warp (Modern Terminal)
  - Added: GitHub Desktop
  - Added: Postman
  - Kept: VS Code, iTerm2, Docker

**Productivity:**
  - Added: Arc Browser
  - Added: Raycast (Spotlight alternative)
  - Added: Linear (Project Management)
  - Added: Todoist
  - Kept: Notion, Obsidian

**Communication:**
  - Added: ChatGPT Desktop
  - Kept: Slack, Discord, Zoom

**Utilities:**
  - Added: 1Password
  - Added: CleanMyMac X
  - Enhanced: Rectangle description

#### 6. Security Enhancements (Medium Priority)
- ✅ **Added Homebrew installation script verification**
  - Downloads script to temp file for inspection
  - Verifies script starts with proper shebang
  - Checks script size is reasonable (5KB-50KB)
  - Provides educational warning about script security
  - Cleans up after installation

#### 7. Apple Silicon Enhancement (Medium Priority)
- ✅ **Enhanced chip detection for M1/M2/M3/M4**
  - Detects specific Apple Silicon generation
  - Provides chip-specific information
  - Checks for Rosetta 2 status
  - Recommends upgrades for Intel Macs

#### 8. Documentation Updates (Medium Priority)
- ✅ Updated README.md version from 2.0.1 → **3.0.0**
- ✅ Added "What's New in 2026" section to README
- ✅ Updated PROJECT-OVERVIEW.md with 2026 updates
- ✅ Updated example timestamps in documentation

#### 9. JSON Logging Feature (Low Priority)
- ✅ Added optional JSON logging format
  - New ENABLE_JSON_LOGS config option
  - Structured logs for parsing and analysis
  - ISO timestamps, escaped messages
  - Includes: timestamp, level, message, script, user, pid

#### 10. Manifest Regeneration (Low Priority)
- ✅ Updated manifest.json with 2026 timestamps
- ✅ All file update dates set to 2026-02-06

---

## Files Modified

### Configuration
- `config/homebrew-scripts.conf` - Modern apps, JSON logging option

### Core Scripts
- `brew_setup_tahoe.sh` - Security verification, M3/M4 detection, bug fixes
- `install-essential-apps.sh` - Updated header
- `auto-update-brew.sh` - Updated header
- `auto-update-brew-hybrid.sh` - Updated header
- `cleanup-homebrew.sh` - Updated header
- `setup-auto-update.sh` - Updated header
- `setup-hybrid-notifications.sh` - Updated header

### Libraries
- `lib/common.sh` - JSON logging capability

### Documentation
- `LICENSE` - Copyright 2026
- `README.md` - Version 3.0.0, What's New section, updated requirements
- `PROJECT-OVERVIEW.md` - 2026 updates section
- `docs/safety-and-best-practices.md` - Updated timestamps and requirements
- `manifest.json` - 2026 timestamps

---

## Breaking Changes

⚠️ **Minimum macOS Version:** Now requires macOS 12.0 (Monterey) or later
- Users on macOS 10.15-11.x must upgrade their OS to use v3.0.0
- v2.x remains available for older systems

## Upgrade Instructions

### For Users on macOS 12.0+
1. Pull the latest changes: `git pull origin main`
2. Review updated config: `config/homebrew-scripts.conf`
3. Run as normal: `./brew_setup_tahoe.sh`

### For Users on macOS < 12.0
- Option 1: Upgrade to macOS 12.0 or later (recommended)
- Option 2: Use v2.x branch: `git checkout v2.x`

---

## Testing Performed

- ✅ Script header updates verified
- ✅ Copyright year updates verified
- ✅ macOS version requirement updates verified
- ✅ brew pin bug fix verified
- ✅ Config-based app installation verified
- ✅ Modern apps added to config
- ✅ Security verification added
- ✅ Apple Silicon detection enhanced
- ✅ Documentation updated
- ✅ JSON logging implemented
- ✅ Manifest regenerated

---

## Contributors
- DJCastle (with assistance from Claude)

## License
MIT License - See LICENSE file

---

**Made with ❤️ for macOS automation in 2026**
