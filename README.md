# Brew Scripts for macOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-3.0.0-green.svg)](https://github.com/DJCastle/homeBrewScripts/releases)

Shell scripts for automating Homebrew package management on macOS. Install apps, schedule updates, get notifications, and keep everything clean — all from the command line.

## Quick Start

```bash
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts
cp config/homebrew-scripts.example.conf config/homebrew-scripts.conf
chmod +x *.sh
./brew_setup_tahoe.sh --dry-run
```

See the **[Getting Started Guide](GETTING_STARTED.md)** for the full walkthrough.

## Scripts

| Script | What it does |
|--------|-------------|
| `brew_setup_tahoe.sh` | Interactive setup — installs Homebrew, configures your shell, installs apps |
| `install-essential-apps.sh` | Batch-installs apps from your config |
| `auto-update-brew.sh` | Auto-updates with text notifications |
| `auto-update-brew-hybrid.sh` | Auto-updates with email + text notifications |
| `setup-auto-update.sh` | Schedules automatic updates (basic) |
| `setup-hybrid-notifications.sh` | Schedules automatic updates (email + text) |
| `cleanup-homebrew.sh` | Removes old packages and frees disk space |

## Features

- **Dry-run mode** — preview what will happen before committing
- **Interactive prompts** — skip any step you're not comfortable with
- **Config-driven** — customize apps, notifications, and schedules in one file
- **Apple Silicon + Intel** — detects your architecture automatically
- **Logging** — every action is recorded to `~/Library/Logs/`
- **Safe to re-run** — scripts detect existing state and won't duplicate work

## Requirements

- macOS 12.0 (Monterey) or later
- Administrator privileges
- Internet connection

## Disclaimer

These scripts install software and modify system configuration files. Always back up your system and use `--dry-run` first. Provided "AS IS" without warranty — see [LICENSE](LICENSE).

## Documentation

- [Getting Started](GETTING_STARTED.md) — setup instructions
- [Safety and Best Practices](safety-and-best-practices.md) — what to watch out for
- [Shell Scripting Tutorial](shell-scripting-tutorial.md) — learn from the code
- [Changelog](CHANGELOG.md) — version history

---

**Author:** DJCastle | **License:** MIT | **Version:** 3.0.0 (2026 Edition)
