# Homebrew Scripts — Claude Instructions

Shared craft rules — imported so every surface loads them, including Xcode's sandboxed agent:

@Agentic_Developer.md

## Stack & purpose

Open-source bash scripts for automating Homebrew package management on macOS — interactive setup, scheduled updates with notifications, manual cleanup. Public repo, MIT-licensed, currently v4.1.1.

- **Repo:** `DJCastle/homeBrewScripts` (public)
- **Page URL:** `codecraftedapps.com/brew/` (GitHub Pages)
- **Languages:** bash (POSIX-compatible where reasonable)
- **Targets:** macOS only, both Intel + Apple Silicon
- **Distribution:** GitHub releases + the `codecraftedapps.com/brew/` landing page

## Hard rules — never violate

1. **Never run `brew` as root or with `sudo`.** Homebrew explicitly forbids it; will refuse to run.
2. **Never `eval` user-provided input.**
3. **No `curl | bash`** install patterns anywhere in published scripts.
4. **No personal paths, usernames, tokens, or machine-specific values** committed. This is a public repo.
5. **Don't break backwards compatibility** without a major-version bump in CHANGELOG and clear migration notes.
6. **Don't remove `DISCLAIMER.md` or `LICENSE`.**

## Conventions specific to this repo

### Shell defaults

- Shebang `#!/usr/bin/env bash` (every script uses it).
- `set -euo pipefail` in every executable script. `lib/common.sh` is sourced, so it inherits the caller's mode and sets none of its own.
- Quote all expansions: `"$var"`.
- `[[ ]]` for conditionals, never `[ ]`.
- `readonly` for constants.

### Layout

- `lib/` — shared helpers (`info` / `success` / `warn` / `fail` color/formatting; dependency checks). New scripts must reuse these instead of duplicating.
- `config/` — config templates copied during install.
- `dotfiles/` — git config + VSCode settings backups.
- `*.sh` at root — top-level entry-point scripts.
- `Brewfile` — declarative bundle file consumed by `brew bundle`.
- No `docs/` dir — the public site pages live in `DJCastle/codeCraftedApps` under `brew/`; the `*.md` files at root (`safety-and-best-practices.md`, `shell-scripting-tutorial.md`, etc.) are the content sources.

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
- Site content (`codeCraftedApps/brew/*.html`) and source markdown (`*.md` at root) must agree.
- The root `*.md` files are the canonical source; when copy changes, update the matching page in `codeCraftedApps/brew/` in the same session.

## Cross-repo sync

Part of the **CodeCraftedApps** ecosystem.

The full product list lives in `codeCraftedApps/CLAUDE.md` ("Managed projects") — the one canonical copy. Don't mirror it here; copies drift.

When changing the project's name or landing-page content, update the hub site `DJCastle/codeCraftedApps` → `index.html` project card, `contact.html` email, `README.md`. The site is served entirely from the apex `codecraftedapps.com` (GitHub Pages); there are no per-app subdomains.

## Running scripts

Top-level entry points:

- `quick-setup.sh` — one-pass dev environment bootstrap on a fresh Mac.
- `brew-setup.sh` — interactive customizable installer (version-neutral, Apple Silicon + Intel).
- `auto-update-brew.sh` / `auto-update-brew-hybrid.sh` — scheduled-update entry points.
- `setup-auto-update.sh` / `setup-hybrid-notifications.sh` — install the launchd schedule + notifications.
- `cleanup-homebrew.sh` — manual cleanup pass.
- `install-essential-apps.sh` — App Store / cask app install pass.

Every script should respond to `--help` and `--check` (dry-run).

## Known issues / don't reintroduce

- **`brew` as root will fail.** Homebrew silently refuses. If a wrapper script needs to elevate for a non-brew step, it must `sudo` only that step, never the `brew` invocation itself.
- **`PEP 668 "externally-managed-environment"`** breaks `pip --user` on modern macOS. Use `pipx` (isolated venvs) for any Python CLI tool.
- **Apple Silicon vs Intel paths:** brew prefix is `/opt/homebrew` on Apple Silicon, `/usr/local` on Intel. Scripts must detect via `$(brew --prefix)` not hardcode.
- **Schedule installers (`setup-auto-update.sh`, `setup-hybrid-notifications.sh`)** drop launchd plists into `~/Library/LaunchAgents/`. If a user reinstalls the script suite, plist removal must come *before* re-creation or `launchctl bootstrap` will refuse. Existing installer handles this; new schedule scripts must too.

- **macOS ships bash 3.2, and `#!/usr/bin/env bash` resolves to it** on a Mac
  without Homebrew's bash — which is every Mac these scripts target before they
  run. So no bash 4+ features: no `mapfile`/`readarray`, no `declare -A`, no
  `${var^}` / `${var,,}`. Use indexed arrays, `while read` loops, and `tr`.
- **Bash 3.2 treats `"${arr[@]}"` on an empty array as an unbound variable**
  under `set -u`. Since the shipped app lists are deliberately empty, every such
  expansion needs the `${arr[@]+"${arr[@]}"}` guard, and `printf` over a possibly
  empty array needs a `${#arr[@]}` check first.
- **A flag that is parsed but never acted on is worse than no flag.**
  `--dry-run` was accepted and ignored for several releases while the docs,
  CHANGELOG and website all promised it prevented changes. If a mode variable is
  set, something must read it; if a preview function exists, something must call
  it. Unknown options must exit non-zero rather than fall through to a real run.
- **`config/homebrew-scripts.conf` is the user's private copy and is
  git-ignored.** The tracked template is `config/homebrew-scripts.example.conf`.
  The generated copy holds an email address and phone number, so it must never
  be committed to this public repo.
- **`LOG_DIR` must be an absolute path.** It was `"Library/Logs"` with a comment
  claiming it was relative to `$HOME`; the value is used verbatim, so logs landed
  wherever the user happened to run the script from.
- **Don't name scripts after a macOS release.** `brew_setup_tahoe.sh` had to be
  renamed because nothing in it was Tahoe-specific; the codename just dated the
  project. `brew_setup_tahoe.sh` survives as a forwarding shim and is excluded
  from `library.config.json` so it stays off the site.
- **The site's `brew/manifest.json` is not generated by anything.** The CI
  workflow in this repo regenerates the copy here on every push to main; the
  site's copy is a manual copy that nothing checks. It had drifted four months.
  After this repo ships, run `bin/sync-brew-manifest.sh` in the
  `codeCraftedApps` repo — it reports the drift, and `--apply` copies the file.
  Note the CI run happens *after* your push, so sync the site in a follow-up,
  not in the same breath.

- **`((count++))` returns non-zero when count is 0.** Post-increment yields the
  old value, and a zero arithmetic result is a false exit status. Bash 3.2 does
  not abort on it but a newer bash may, and these scripts install Homebrew.
  Use `count=$((count+1))` — an assignment is always exit-0.
- **Never assign from a pipeline containing `grep` or `networksetup` without
  `|| true`.** Under `set -o pipefail` a grep that matches nothing, or
  networksetup asked about a non-Wi-Fi interface (exit 10), fails the whole
  pipeline and aborts the script — typically skipping the very empty-value check
  written to handle that case. This has now bitten three separate functions.
- **`local x=$(cmd)` hides `cmd`'s exit status** behind the `local` builtin,
  which always succeeds. Declare then assign (`local x; x=$(cmd)`) when a
  failure should stop the run. Two bugs hid behind this, including `brew upgrade`
  failures being reported as successes.
- **Don't assume `en0` is Wi-Fi.** It is on laptops; on desktop Macs it is
  usually Ethernet. Discover it from
  `networksetup -listallhardwareports`, honouring `NETWORK_INTERFACE` from config.
- **`mail` exits 0 with no MTA running**, and macOS ships postfix disabled, so a
  plain exit-code check reports success for mail that is never delivered. Probe
  `/usr/sbin/postqueue -p` before claiming an email was sent.
- **`launchctl load`/`unload` are deprecated** (`launchctl help` names
  bootstrap/bootout). Use `launchctl bootout gui/$(id -u)/<label> || true`
  followed by `launchctl bootstrap gui/$(id -u) <plist>`, in that order.

## Documentation maintenance

When a new gotcha surfaces, add it to **Known issues** the same session. When a durable rule emerges, add it to **Hard rules** or **Conventions**. Keep `CLAUDE-LOG.md` for time-bound decisions; promote the rule to this file once it's settled.

User-facing behavior changes ripple to three places: the script itself, the relevant `*.md` source at root (which feeds the site), and `CHANGELOG.md`. Don't ship one without the others.
