# Changelog

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
