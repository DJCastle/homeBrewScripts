# Homebrew Scripts — Claude Instructions

## Project Overview
Shell scripts for automating Homebrew package management on macOS — setup, scheduled updates, notifications, and cleanup. Version 3.1.0. Public open-source project.

## Ecosystem Awareness

This project is part of the **CodeCraftedApps** ecosystem:

- **Root site:** `codecraftedapps.com` (repo: `DJCastle/codeCraftedApps`)
- **Subdomain:** `brewscripts.codecraftedapps.com`
- **Hosting:** GitHub Pages

## Project Structure
```
homeBrewScripts/
├── *.sh                 # Main scripts (setup, update, notify, cleanup)
├── config/              # Configuration file templates
├── lib/                 # Shared shell libraries
├── dotfiles/            # Git config and VSCode settings backups
├── Brewfile             # Homebrew bundle file
├── GETTING_STARTED.md   # User-facing setup guide
├── CHANGELOG.md         # Version history
├── DISCLAIMER.md
├── LICENSE
└── README.md
```

## Languages
- **Bash** — all scripts are POSIX-compatible shell where possible

## Code Quality (Shell Scripts)

- Use `set -e` at the top of every script.
- Quote all variable expansions: `"$var"` not `$var`.
- Use `[[ ]]` for conditionals, not `[ ]`.
- Use functions to organize logic — keep scripts modular.
- Include a header comment block explaining purpose, usage, and requirements.
- Use consistent color/formatting helpers (match existing `info`, `success`, `warn`, `fail` pattern from `lib/`).
- Handle missing dependencies gracefully.
- Use `readonly` for constants.
- Keep the shared library in `lib/` — don't duplicate helper functions across scripts.

## Security

- Never hardcode credentials or tokens.
- Never run `brew` commands as root/sudo (Homebrew explicitly forbids this).
- All URLs should use HTTPS.
- Never `eval` user-provided input.
- Validate Brewfile contents before processing.
- Scripts that modify system state should have a `--check` / dry-run mode.

## Public Repo Standards

Since this is open-source:
- All commits should have clean, descriptive messages.
- README and GETTING_STARTED must stay accurate and up to date.
- CHANGELOG must be updated for any user-facing changes.
- No personal paths, usernames, or machine-specific values in committed code.
- DISCLAIMER.md must remain present.
- LICENSE must remain present.

## DO NOT
- Auto-commit or auto-push
- Include any personal/private data (paths, usernames, tokens)
- Run Homebrew as sudo
- Break backwards compatibility without a major version bump
- Remove DISCLAIMER.md or LICENSE
