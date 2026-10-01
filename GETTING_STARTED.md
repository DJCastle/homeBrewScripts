# Getting Started

A step-by-step guide to setting up and using Brew Scripts on your Mac.

## Requirements

- macOS 11 (Big Sur) or later — macOS 15 (Sequoia) or later recommended
- Administrator privileges (you'll be prompted for your password)
- Internet connection
- At least 1GB free disk space

## Step 1 — Download

**Option A: Clone with Git**

```bash
git clone https://github.com/DJCastle/homeBrewScripts.git
cd homeBrewScripts
```

**Option B: Download ZIP**

Download from the green **Code** button on GitHub, then unzip and open Terminal in that folder.

## Step 2 — Set Up Your Config

Copy the example configuration and fill in your details:

```bash
cp config/homebrew-scripts.example.conf config/homebrew-scripts.conf
```

(You can skip this — `brew-setup.sh` creates the file for you on first run. Copy
it by hand only if you want to edit it before running anything.)

Open it in any text editor:

```bash
nano config/homebrew-scripts.conf
```

Key settings to customize:

| Setting | What it does |
|---------|-------------|
| `WIFI_NETWORK` | Only run auto-updates on this network (leave empty for any) |
| `EMAIL_ADDRESS` | Where to send update reports |
| `PHONE_NUMBER` | iMessage number for quick text alerts |
| `INSTALL_*` | Toggle app categories on/off |
| `CUSTOM_APPS` | The apps to offer, inside the `EDIT HERE` block |

### Choosing apps — nothing is installed by default

`CUSTOM_APPS` ships with every entry commented out and named with a placeholder,
so a fresh copy cannot install software you did not pick. Uncomment what you
want and replace the placeholder with the real Homebrew name, which you can find
with `brew search <name>`:

```bash
# ===== EDIT HERE =====
CUSTOM_APPS=(
    # "browser1:Browser:productivity"        <- placeholder
    "firefox:Firefox:productivity"           # <- your actual choice
)
# ===== DO NOT EDIT BELOW THIS LINE =====
```

The format is `cask-name:Display Name:category`, and a category only installs if
its `INSTALL_*` switch above is `true`.

> **Upgrading from v3.x?** `CUSTOM_APPS` changed from an associative array
> (`declare -A`) to an indexed one, because macOS ships bash 3.2 where
> associative arrays do not exist. If you have an old config, convert it — see
> the Migration section in [CHANGELOG.md](CHANGELOG.md).

`install-essential-apps.sh` keeps its own list in its own `EDIT HERE` block and
does **not** read this config file. `Brewfile` and
`dotfiles/vscode/extensions.txt` work the same way.

## Step 3 — Make Scripts Executable

The scripts in this repository are already executable, so there is normally
nothing to do here. If you copied them somewhere and lost the permission bit:

```bash
chmod +x *.sh
```

## Step 4 — Run Your First Script

**Option A: Quick Setup** (fast, opinionated — no config file needed)

```bash
./quick-setup.sh --dry-run   # Preview first
./quick-setup.sh             # Run for real
```

Installs CLI tools via Brewfile, configures VSCode extensions, and sets up Git in one pass.

**Option B: Full Interactive Setup** (config-driven, educational)

```bash
./brew-setup.sh --dry-run   # Preview first
./brew-setup.sh             # Run for real
```

Walks you through each step interactively. You can skip any step you're not comfortable with.

## What Each Script Does

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | Quick bootstrap — CLI tools, VSCode extensions, Git config |
| `brew-setup.sh` | Full interactive setup — Homebrew, your shell, and the apps you listed in your config |
| `install-essential-apps.sh` | Batch-installs the apps in its own `EDIT HERE` block (not from the config file) |
| `auto-update-brew.sh` | Runs Homebrew updates with text notifications |
| `auto-update-brew-hybrid.sh` | Runs updates with both email and text notifications |
| `setup-auto-update.sh` | Schedules automatic updates (basic) |
| `setup-hybrid-notifications.sh` | Schedules automatic updates (with email + text) |
| `cleanup-homebrew.sh` | Removes old packages and frees disk space — preview with `--check`, confirms before deleting |

## Optional — Set Up Auto-Updates

To keep everything updated automatically:

```bash
./setup-hybrid-notifications.sh
```

This creates a scheduled task that runs updates in the background. It checks for WiFi and power before running, so it won't interrupt you.

## Logs

All scripts log what they do to `~/Library/Logs/`. If something goes wrong, check there first:

```bash
ls ~/Library/Logs/Homebrew*.log
```

## Tips

- **Use `--dry-run`** on any script to preview before committing
- **Back up your system** before running scripts that modify system files
- **Review the config** before running — no apps are enabled until you choose them
- **Read the code** — every script is commented to explain what it does and why

## Need More Info?

- [Safety and Best Practices](safety-and-best-practices.md) — what to watch out for
- [Shell Scripting Tutorial](shell-scripting-tutorial.md) — learn from the code
- [Changelog](CHANGELOG.md) — what's new in each version
