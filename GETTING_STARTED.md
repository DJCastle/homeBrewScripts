# Getting Started

A step-by-step guide to setting up and using Brew Scripts on your Mac.

## Requirements

- macOS 12.0 (Monterey) or later
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
| `CUSTOM_APPS` | Add or remove specific applications |

## Step 3 — Make Scripts Executable

```bash
chmod +x *.sh
```

You only need to do this once.

## Step 4 — Run Your First Script

**Option A: Quick Setup** (fast, opinionated — no config file needed)

```bash
./quick-setup.sh --dry-run   # Preview first
./quick-setup.sh             # Run for real
```

Installs CLI tools via Brewfile, configures VSCode extensions, and sets up Git in one pass.

**Option B: Full Interactive Setup** (config-driven, educational)

```bash
./brew_setup_tahoe.sh --dry-run   # Preview first
./brew_setup_tahoe.sh             # Run for real
```

Walks you through each step interactively. You can skip any step you're not comfortable with.

## What Each Script Does

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | Quick bootstrap — CLI tools, VSCode extensions, Git config |
| `brew_setup_tahoe.sh` | Full interactive setup — installs Homebrew, configures your shell, installs apps |
| `install-essential-apps.sh` | Batch-installs apps from your config |
| `auto-update-brew.sh` | Runs Homebrew updates with text notifications |
| `auto-update-brew-hybrid.sh` | Runs updates with both email and text notifications |
| `setup-auto-update.sh` | Schedules automatic updates (basic) |
| `setup-hybrid-notifications.sh` | Schedules automatic updates (with email + text) |
| `cleanup-homebrew.sh` | Removes old packages and frees disk space |

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
- **Review the config** before running — the example config has sensible defaults
- **Read the code** — every script is commented to explain what it does and why

## Need More Info?

- [Safety and Best Practices](safety-and-best-practices.md) — what to watch out for
- [Shell Scripting Tutorial](shell-scripting-tutorial.md) — learn from the code
- [Changelog](CHANGELOG.md) — what's new in each version
