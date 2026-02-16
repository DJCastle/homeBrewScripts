# Changelog

## v3.1.0 — Quick Setup & CLI Tools (February 2026)

### New Features

- **Quick setup script** — `quick-setup.sh` bootstraps a dev environment in one command (Brewfile, VSCode extensions, Git config, gh auth)
- **Brewfile** — Declarative package list for CLI tools (gh, swiftlint, xcbeautify, node, jq, tree) and GUI apps using `brew bundle`
- **VSCode extension management** — Install AI coding extensions (Copilot, GitLens, Gemini, Claude Code) from `dotfiles/vscode/extensions.txt`
- **Dotfiles backups** — Reference VSCode settings and Git config in `dotfiles/`
- **Disclaimer** — Added dedicated DISCLAIMER.md for third-party software notice

### Merged From

- Consolidated unique content from the `homebrewinstallapps` repository into this repo

---

## v3.0.0 — 2026 Edition (February 2026)

### New Features

- **Apple Silicon detection** — Identifies M1, M2, M3, and M4 chips with Rosetta 2 awareness
- **Security verification** — Homebrew install script is now validated before execution
- **JSON logging** — Optional structured logs for easier parsing (`ENABLE_JSON_LOGS=true` in config)
- **Modern app catalog** — Added Arc, Cursor, Warp, Raycast, Linear, ChatGPT Desktop, and more

### Improvements

- Minimum macOS version updated to **12.0 (Monterey)**
- Application management is now fully config-driven — no more hardcoded app lists
- Example config included with placeholder values for easy setup

### Bug Fixes

- Fixed incorrect use of `brew pin` on casks (pin only works on formulae)

---

## v2.0.0 — Initial Public Release (2025)

- Interactive Homebrew setup with dry-run mode
- Configurable auto-updates with text and email notifications
- Shared function library (`lib/common.sh`)
- External configuration file with validation
- Comprehensive logging and error handling
- Homebrew cleanup and maintenance script
