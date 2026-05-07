# Homebrew Scripts — Claude Instructions

## Stack & purpose

Open-source bash scripts for automating Homebrew package management on macOS — interactive setup, scheduled updates with notifications, manual cleanup. Public repo, MIT-licensed, currently v3.1.0.

- **Repo:** `DJCastle/homeBrewScripts` (public)
- **Subdomain:** `brewscripts.codecraftedapps.com` (GitHub Pages, Cloudflare-proxied)
- **Languages:** bash (POSIX-compatible where reasonable)
- **Targets:** macOS only, both Intel + Apple Silicon
- **Distribution:** GitHub releases + the brewscripts subdomain landing page

## Hard rules — never violate

1. **Never run `brew` as root or with `sudo`.** Homebrew explicitly forbids it; will refuse to run.
2. **Never `eval` user-provided input.**
3. **No `curl | bash`** install patterns anywhere in published scripts.
4. **No personal paths, usernames, tokens, or machine-specific values** committed. This is a public repo.
5. **Don't break backwards compatibility** without a major-version bump in CHANGELOG and clear migration notes.
6. **Don't remove `DISCLAIMER.md` or `LICENSE`.**

## Conventions specific to this repo

### Shell defaults

- Shebang `#!/usr/bin/env bash` (some older scripts still use `#!/bin/bash` — migrate when touched).
- Aim for `set -euo pipefail`; existing scripts may still be `set -e`-only — upgrade opportunistically when you edit one.
- Quote all expansions: `"$var"`.
- `[[ ]]` for conditionals, never `[ ]`.
- `readonly` for constants.

### Layout

- `lib/` — shared helpers (`info` / `success` / `warn` / `fail` color/formatting; dependency checks). New scripts must reuse these instead of duplicating.
- `config/` — config templates copied during install.
- `dotfiles/` — git config + VSCode settings backups.
- `*.sh` at root — top-level entry-point scripts.
- `Brewfile` — declarative bundle file consumed by `brew bundle`.
- `docs/` — GitHub Pages source (HTML rendered from the `*.md` content sources at root: `safety-and-best-practices.md`, `shell-scripting-tutorial.md`, etc.).

### User experience

- Header comment block on every script: purpose, usage, requirements, version.
- Interactive scripts include a `PREFLIGHT` banner explaining what's about to happen.
- All system-modifying scripts must support a dry-run / `--check` mode that prints what *would* run without executing.
- Validate `Brewfile` contents before processing.
- Handle missing dependencies gracefully (check for `brew`, `gh`, `jq`, etc. before using).

## Public-repo standards

This repo is open source — different commit hygiene than private repos:

- Clean, descriptive commit messages (no internal shorthand).
- `README.md` and `GETTING_STARTED.md` must stay accurate. Update in the same commit as user-facing behavior changes.
- `CHANGELOG.md` updated for any user-visible change. Semver.
- Site content (`docs/`) and source markdown (`*.md` at root) must agree.
- `docs/` markdown files are the canonical source — `docs/*.html` is generated/derived. When changing copy, update the `.md` and regenerate (or update both consistently).

## Cross-repo sync

Part of the **CodeCraftedApps** ecosystem. When changing the project's name or subdomain, update the root site:

- `DJCastle/codeCraftedApps` → `index.html` project card, `contact.html` email, `README.md` ecosystem table.

`brewscripts.codecraftedapps.com` is **Cloudflare-proxied (orange cloud)**. CNAME → `djcastle.github.io`.

## Running scripts

Top-level entry points:

- `quick-setup.sh` — one-pass dev environment bootstrap on a fresh Mac.
- `brew_setup_tahoe.sh` — interactive customizable installer (Tahoe-aware, Apple Silicon + Intel).
- `auto-update-brew.sh` / `auto-update-brew-hybrid.sh` — scheduled-update entry points.
- `setup-auto-update.sh` / `setup-hybrid-notifications.sh` — install the launchd schedule + notifications.
- `cleanup-homebrew.sh` — manual cleanup pass.
- `install-essential-apps.sh` — App Store / cask app install pass.

Every script should respond to `--help` and `--check` (dry-run).

## Known issues / don't reintroduce

- **`brew` as root will fail.** Homebrew silently refuses. If a wrapper script needs to elevate for a non-brew step, it must `sudo` only that step, never the `brew` invocation itself.
- **`PEP 668 "externally-managed-environment"`** breaks `pip --user` on modern macOS. Use `pipx` (isolated venvs) for any Python CLI tool. Already encoded in `personalCode/brew-setup.sh`.
- **Apple Silicon vs Intel paths:** brew prefix is `/opt/homebrew` on Apple Silicon, `/usr/local` on Intel. Scripts must detect via `$(brew --prefix)` not hardcode.
- **Schedule installers (`setup-auto-update.sh`, `setup-hybrid-notifications.sh`)** drop launchd plists into `~/Library/LaunchAgents/`. If a user reinstalls the script suite, plist removal must come *before* re-creation or `launchctl bootstrap` will refuse. Existing installer handles this; new schedule scripts must too.

## Documentation maintenance

When a new gotcha surfaces, add it to **Known issues** the same session. When a durable rule emerges, add it to **Hard rules** or **Conventions**. Keep `CLAUDE-LOG.md` for time-bound decisions; promote the rule to this file once it's settled.

User-facing behavior changes ripple to three places: the script itself, the relevant `*.md` source at root (which feeds the site), and `CHANGELOG.md`. Don't ship one without the others.
