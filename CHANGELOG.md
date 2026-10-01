# Changelog

## v4.0.0 — Actually Runs (September 2026)

This release fixes a set of defects that stopped `brew-setup.sh` from working at
all, and renames it. Read the migration notes before upgrading.

### Fixed — the setup script could not run

- **`--dry-run` installed software for real.** The argument parser that set
  `DRY_RUN_MODE` was never called, and neither was the `perform_dry_run()`
  preview function. Both were written, neither was wired up, so `--dry-run` was
  accepted, printed nothing special, and went on to install. A dry run now
  validates, prints exactly what it would do, and exits without touching
  anything. **If you relied on `--dry-run` doing nothing, it previously did the
  opposite.**
- **A plain run aborted immediately.** `INTERACTIVE_MODE` was only ever assigned
  inside the `--non-interactive` branch, so under `set -u` any run without that
  flag died with `unbound variable`. All three mode variables now have defaults.
- **A fresh clone could not create its configuration.** `create_default_config()`
  copied the template from `config/homebrew-scripts.conf` — the file it was
  trying to create — instead of `config/homebrew-scripts.example.conf`, so every
  script failed at startup with "Template configuration file not found".
- **Pre-flight checks never ran.** `run_preflight_checks()` was defined but never
  called, so a real run validated nothing before installing. It now gates both
  the dry run and the real run.
- **`--help` needed a working config.** Help and `--version` are now answered
  before anything is sourced, so they work on a fresh clone. The detailed help
  text was also unreachable; the live parser printed a four-line summary that
  omitted `--dry-run`, `--debug`, and `--config-only`.
- **Unknown options were ignored.** Passing a typo silently ran a full install.
  Unrecognised options now exit 2 with a pointer to `--help`.

### Fixed — would not run on a stock Mac

macOS ships bash 3.2. The scripts used bash 4+ features, so they required a
Homebrew-installed bash — circular, for a Homebrew installer.

- `declare -A CUSTOM_APPS` replaced with an indexed array. **Breaking: see migration.**
- `mapfile` replaced with `while read` loops (two sites).
- `${category^}` and `${response,,}` replaced with `tr`. The second broke every
  interactive yes/no prompt.
- Empty arrays are now expanded guarded — bash 3.2 treats `"${arr[@]}"` on an
  empty array as an unbound variable, which the new all-commented app lists hit
  immediately.

### Fixed — other

- **Logs were written relative to the current directory.** `LOG_DIR` was
  `"Library/Logs"` with a comment claiming it was relative to `$HOME`, but the
  value was used verbatim — so running the script scattered a `Library/Logs`
  tree into whatever directory you happened to be in, and failed outright in a
  read-only one. It is now an absolute path.
- **`validate_percentage()` aborted the config validation it was part of.** It
  required a second argument that `validate_with_error()` never passes.
- **The VS Code extensions list could not contain comments.** The reader trimmed
  lines with `xargs`, which dies on an apostrophe, and did not skip `#` lines.
- **The generated user config was not git-ignored.** `config/homebrew-scripts.conf`
  holds your email address and phone number; in a clone of this public repo it
  was staged for commit.

### Changed

- **`brew_setup_tahoe.sh` is now `brew-setup.sh`.** Nothing in it was ever
  specific to macOS 26 "Tahoe"; the codename only made the project look stale
  each September. The hyphenated name also matches every other script here.
  `brew_setup_tahoe.sh` remains as a forwarding shim that prints a deprecation
  notice — it will be removed in a future major version.
- **No applications are installed by default any more.** The app lists shipped
  with one particular person's software on them. They are now commented-out
  placeholders (`browser1`, `editor1`, …) inside a marked `EDIT HERE` block, so
  you choose your own and a default run installs nothing unexpected. Affects
  `Brewfile`, `install-essential-apps.sh`, `config/homebrew-scripts.example.conf`,
  and `dotfiles/vscode/extensions.txt`.
- **Supported macOS range restated honestly.** macOS 11 (Big Sur) is the hard
  minimum; below macOS 15 (Sequoia) Homebrew publishes no prebuilt bottles, so
  the scripts now warn that packages will compile from source instead of
  claiming support. Tested through macOS 27 (Golden Gate). The previous claim of
  "macOS 12.0 (Monterey) or later" was not accurate.
- `install-essential-apps.sh` kept two copies of its app list, one to install
  from and one to verify against. They are now one list.
- The `bambustudio` cask was renamed upstream to `bambu-studio`, which made
  `brew bundle` fail on the shipped `Brewfile`.

### Note on version numbers

Individual scripts used to carry their own version in their header comment
(several sat at `1.1.0` while the project was `3.3.0`), which told you nothing
useful and quietly implied the project was older than it was. Every script header
now states the project version, which is the one `CHANGELOG.md`, `README.md`, and
the website all track.

### Migration

1. **If you call `brew_setup_tahoe.sh`, switch to `brew-setup.sh`.** The old name
   still works but warns, and will go away.
2. **If you have a `CUSTOM_APPS` block in your own
   `config/homebrew-scripts.conf`, you must convert it.** It changed from an
   associative array to an indexed one:

   ```bash
   # before (bash 4+ only)
   declare -A CUSTOM_APPS=(
       ["visual-studio-code"]="Visual Studio Code:development"
   )

   # after (works on stock macOS bash)
   CUSTOM_APPS=(
       "visual-studio-code:Visual Studio Code:development"
   )
   ```

   The field order is `cask-name:Display Name:category`.
3. **Re-check your `Brewfile` and app lists.** The shipped defaults no longer
   install anything; if you were relying on them, list what you want in the
   `EDIT HERE` block.
4. **Expect `--dry-run` to actually do nothing now.** Any automation that passed
   `--dry-run` and depended on the install happening will stop installing.

---

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
