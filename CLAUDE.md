<!-- CLAUDE.md — CodeCraftedApps Subdomain Template

HOW TO USE:
1. Copy this file to the root of each subdomain repo as "CLAUDE.md"
2. Update the PROJECT CONFIG section below
3. Update the Sibling Projects table (remove THIS project, keep the others)
4. Commit and push
5. When this template changes in the root repo, re-copy to all subdomain repos

PROJECT CONFIG — Update for each repo:

Daily Stride Tracker:
  Project: Daily Stride Tracker
  Subdomain: dailystridetracker.codecraftedapps.com
  Email: dailystride@codecraftedapps.com
  Type: App

Brew Scripts:
  Project: Brew Scripts
  Subdomain: brewscripts.codecraftedapps.com
  Email: brew@codecraftedapps.com
  Type: Tool

Chocolatey Scripts:
  Project: Chocolatey Scripts
  Subdomain: chocolateyscripts.codecraftedapps.com
  Email: choco@codecraftedapps.com
  Type: Tool
-->

## Ecosystem Awareness

This project is part of the **CodeCraftedApps** ecosystem:

- **Root site:** `codecraftedapps.com` (repo: `DJCastle/codecraftedapps`)
- **DNS:** Cloudflare (DNS only, gray cloud — NOT proxied)
- **SSL:** GitHub-issued Let's Encrypt certs
- **Hosting:** GitHub Pages

### Sibling Projects

The table below lists all projects in the ecosystem. Ignore the row that matches this repo's own subdomain — the remaining rows are the sibling projects to stay in sync with.

| Project | Subdomain | Repo | Email |
| --- | --- | --- | --- |
| Root Site | `codecraftedapps.com` | DJCastle/codecraftedapps | `contact@codecraftedapps.com` |
| Daily Stride Tracker | `dailystridetracker.codecraftedapps.com` | DJCastle/dailystridetracker | `dailystride@codecraftedapps.com` |
| Brew Scripts | `brewscripts.codecraftedapps.com` | DJCastle/brewscripts | `brew@codecraftedapps.com` |
| Chocolatey Scripts | `chocolateyscripts.codecraftedapps.com` | DJCastle/chocolateyscripts | `choco@codecraftedapps.com` |

## Cross-Repo Sync Rules

### When modifying legal pages in THIS repo

If you change **docs/privacy.html** or **docs/terms.html** in this repo, remind the user:

> "The root site (codecraftedapps.com) links to this page. If the URL or page name changed, update the links in the root repo's `privacy.html` and `terms.html`."

### When adding, removing, or renaming this project

Remind the user to update these files in the **root repo** (`DJCastle/codecraftedapps`):

1. **index.html** — project card
2. **privacy.html** — app-specific policy link
3. **terms.html** — app-specific terms link
4. **contact.html** — project email
5. **README.md** — ecosystem table

### When modifying styles or theme

This project should follow the root site's design system where possible:

- **Background:** `#0f1117` (primary), `#1a1d27` (secondary), `#1e2130` (cards)
- **Text:** `#e8e9ed` (primary), `#9ca3af` (secondary), `#6b7280` (muted)
- **Accent:** `#3b82f6` (blue), `#2563eb` (hover)
- **Font:** Inter (Google Fonts) — weights: 400, 500, 600, 700, 800
- **Border radius:** 12px (cards), 8px (small)
- **Nav/footer:** dark with blur backdrop, consistent links to root legal pages

If this project intentionally diverges from the root theme (e.g., app-specific branding), note the differences below so they're tracked.

### Theme divergences from root site

- **Accent color:** Amber `#f59e0b` (hover: `#d97706`) instead of root blue `#3b82f6` — evokes the Homebrew/craft-brewing theme
- **Accent glow:** `rgba(245, 158, 11, 0.15)` / soft: `rgba(245, 158, 11, 0.1)`
- **Monospace font:** Uses `--font-mono` (`SF Mono`, `Fira Code`) for code blocks and metadata — not present on root site
- **Disclaimer banner:** Red-tinted (`rgba(239, 68, 68, …)`) warning banner unique to this tool site — not used on root or Daily Stride

## Legal Pages Required

This repo MUST include (located in `docs/` for GitHub Pages):

- **docs/privacy.html** — Tool-specific privacy policy (open-source/local-only focus)
- **docs/terms.html** — Tool-specific terms of service (system modification disclaimers, MIT license)

These pages are linked from the root site. Tool-specific policies take precedence over the root site's general policies.
Both reference back to the parent CodeCraftedApps policies as the "parent organization."

## GitHub Pages Setup

- **CNAME file** (repo root): contains `brewscripts.codecraftedapps.com`
- **Deploy source:** branch `main`, folder `/docs`
- **Cloudflare CNAME record:** `brewscripts` → `djcastle.github.io` (DNS only, gray cloud)
- **GitHub Pages:** custom domain set, HTTPS enforced

## Project-Specific Context

### Repo structure

```text
homeBrewScripts/
├── CNAME                          # GitHub Pages custom domain
├── docs/                          # GitHub Pages site root
│   ├── index.html                 # Landing page with scripts library
│   ├── privacy.html               # Tool-specific privacy policy
│   ├── terms.html                 # Tool-specific terms of service
│   └── css/style.css              # Amber-themed stylesheet
├── config/
│   └── homebrew-scripts.conf      # Main configuration file (sourced by scripts)
├── lib/
│   └── common.sh                  # Shared function library (sourced by scripts)
├── brew_setup_tahoe.sh            # Primary interactive setup script
├── install-essential-apps.sh      # Batch app installer
├── auto-update-brew.sh            # Basic auto-updater (text notifications)
├── auto-update-brew-hybrid.sh     # Advanced auto-updater (email + text)
├── setup-auto-update.sh           # Configures basic auto-update scheduling
├── setup-hybrid-notifications.sh  # Configures advanced notification scheduling
├── cleanup-homebrew.sh            # Homebrew maintenance/cleanup
├── manifest.json                  # Auto-generated file list (consumed by site JS)
├── library.config.json            # Controls which files appear in manifest
└── web/scripts-library.js         # Alternate manifest loader (used by root site)
```

### Manifest system

- `manifest.json` is auto-generated by a GitHub Action on push (see commit messages with `[skip ci]`)
- `library.config.json` controls which files are included, their display order, titles, and descriptions
- The site's `docs/index.html` loads the manifest from jsDelivr CDN to render the scripts library
- The root site (`codecraftedapps.com`) also loads this manifest via `web/scripts-library.js`

### Key technical notes

- Scripts use `#!/usr/bin/env bash` with `set -euo pipefail`
- `lib/common.sh` is sourced by `brew_setup_tahoe.sh` — the other scripts are standalone
- `config/homebrew-scripts.conf` contains `declare -A` associative arrays (requires bash 4+)
- The `download` attribute on raw GitHub URLs triggers save-as in browsers (used in the site's Download buttons)
- `brew pin` does NOT work for casks — this was a bug that was fixed; do not reintroduce it
