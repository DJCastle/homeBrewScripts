# Brew Scripts for macOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-11%2B%20(15%2B%20recommended)-blue.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-4.1.0-green.svg)](https://github.com/DJCastle/homeBrewScripts/releases)

Shell scripts for automating Homebrew package management on macOS. Install apps, schedule updates, get notifications, and keep everything clean — all from the command line.

## Quick Start

```bash
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts
./brew-setup.sh --dry-run
```

The scripts are already executable, and `brew-setup.sh` creates your config file
on first run. **Nothing is installed until you choose what to install** — see
[Choosing what gets installed](#choosing-what-gets-installed).

See the **[Getting Started Guide](GETTING_STARTED.md)** for the full walkthrough.

## Quick Bootstrap (New Machine)

For a fast, opinionated setup on a fresh Mac:

```bash
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts
chmod +x quick-setup.sh
./quick-setup.sh
```

This installs whatever you have enabled in `Brewfile` and
`dotfiles/vscode/extensions.txt`, then sets up Git. Out of the box that is three
CLI tools (`gh`, `jq`, `tree`) and two editor extensions — everything else ships
commented out for you to choose. For the interactive, config-driven setup, use
`brew-setup.sh` instead.

## Scripts

| Script | What it does |
|--------|-------------|
| `quick-setup.sh` | Quick bootstrap — CLI tools, VSCode extensions, Git config |
| `brew-setup.sh` | Interactive setup — installs Homebrew, configures your shell, and installs the apps you list in your config |
| `install-essential-apps.sh` | Batch-installs the apps listed in its own `EDIT HERE` block (it does not read the config file) |
| `auto-update-brew.sh` | Auto-updates with text notifications |
| `auto-update-brew-hybrid.sh` | Auto-updates with email + text notifications |
| `setup-auto-update.sh` | Schedules automatic updates (basic) |
| `setup-hybrid-notifications.sh` | Schedules automatic updates (email + text) |
| `cleanup-homebrew.sh` | Removes old packages and frees disk space — preview with `--check`, confirms before deleting |

## Choosing what gets installed

**No applications are installed by default.** Every app list ships with its
entries commented out and named with placeholders (`browser1`, `editor1`), so a
fresh clone cannot install software you did not pick.

Each list sits inside a block marked like this, so you always know which part of
a file is yours to change:

```bash
# ===== EDIT HERE =====
#   ... your choices go here ...
# ===== DO NOT EDIT BELOW THIS LINE =====
```

| Where | Controls |
|-------|----------|
| `config/homebrew-scripts.example.conf` → `CUSTOM_APPS` | apps `brew-setup.sh` offers, by category |
| `install-essential-apps.sh` → `APPS` | apps the batch installer installs |
| `Brewfile` | packages `quick-setup.sh` installs via `brew bundle` |
| `dotfiles/vscode/extensions.txt` | VS Code extensions |

Find the Homebrew name for any app with `brew search <name>`, then uncomment the
line and replace the placeholder. Leaving a list untouched is fine — the scripts
report that nothing is configured and carry on.

## Features

- **Dry-run mode** — preview what will happen before committing
- **Interactive prompts** — skip any step you're not comfortable with
- **Config-driven** — apps, notifications, and schedules live in marked `EDIT HERE` blocks
- **Nothing by default** — no application is installed unless you list it
- **Apple Silicon + Intel** — detects your architecture automatically
- **Logging** — every action is recorded to `~/Library/Logs/`
- **Safe to re-run** — scripts detect existing state and won't duplicate work

## Requirements

- macOS 11 (Big Sur) or later — macOS 15 (Sequoia) or later recommended
- Administrator privileges
- Internet connection

## Disclaimer

These scripts install software and modify system configuration files. Always back up your system and use `--dry-run` first. Provided "AS IS" without warranty — see [DISCLAIMER.md](DISCLAIMER.md) and [LICENSE](LICENSE).

## Documentation

- [Getting Started](GETTING_STARTED.md) — setup instructions
- [Safety and Best Practices](safety-and-best-practices.md) — what to watch out for
- [Shell Scripting Tutorial](shell-scripting-tutorial.md) — learn from the code
- [Changelog](CHANGELOG.md) — version history
- [Dotfiles](dotfiles/) — VSCode settings and Git config backups
- [Disclaimer](DISCLAIMER.md) — third-party software notice

---

**Author:** DJCastle | **License:** MIT | **Version:** 4.1.0
