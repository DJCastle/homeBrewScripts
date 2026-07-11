# Changelog

## v3.3.0 — Dry-Run Everywhere (July 2026)

### New Features

- **Every script now supports `--dry-run` / `--check` and `--help`.** The auto-update scripts (`auto-update-brew.sh`, `auto-update-brew-hybrid.sh`) check their run conditions and list outdated packages/casks without upgrading anything or sending notifications; the setup scripts (`setup-auto-update.sh`, `setup-hybrid-notifications.sh`) walk through the interactive questions and show exactly what would be configured — no test messages, no file edits, no launchd changes; `install-essential-apps.sh` lists what it would install and what's already present. Dry runs write nothing, not even log files.

### Changed

- **LICENSE is now the unmodified MIT text.** The appended "additional disclaimer" paragraph moved to DISCLAIMER.md (its content was already covered there), so GitHub and license scanners detect the repo as clean MIT.
- Docs: corrected the security notes — Homebrew verifies download checksums (SHA-256), while app code signatures are checked by macOS Gatekeeper; log files capture script operations and results, not raw network traffic.

---

## v3.2.0 — Safer Cleanup (July 2026)

### Changed

- **`cleanup-homebrew.sh` no longer deletes on sight** — it now shows a preflight summary and asks for confirmation before removing anything. Preview everything first with `--check` (dry run via `brew cleanup --dry-run` / `brew autoremove --dry-run`); pass `--yes` to skip the prompt in unattended or scheduled runs. `--help` documents all options.

---

## v3.1.0 — Quick Setup & CLI Tools (February 2026)

### New Features

- **Quick setup script** — `quick-setup.sh` bootstraps a dev environment in one command (Brewfile, VSCode extensions, Git config, gh auth)
- **Brewfile** — Declarative package list for CLI tools (gh, xcbeautify, node, jq, tree) and GUI apps using `brew bundle`
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
