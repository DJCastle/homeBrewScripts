#!/usr/bin/env bash
###############################################################################
# Script Name: brew_setup_tahoe.sh  (DEPRECATED — renamed to brew-setup.sh)
#
# This file exists only so existing links, bookmarks, and anything that already
# calls brew_setup_tahoe.sh keeps working. It forwards every argument to
# brew-setup.sh and exits with that script's exit code.
#
# Why the rename: the old name was taken from macOS 26 "Tahoe". Nothing in the
# script was ever specific to that release, so the codename only made the
# project look out of date each September. brew-setup.sh is version-neutral and
# matches the hyphenated naming the rest of the scripts already use.
#
# This shim will be removed in a future major version. Use brew-setup.sh.
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/brew-setup.sh"

if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: brew-setup.sh not found next to this script ($TARGET)." >&2
    echo "This file is only a forwarder. Re-clone the repository." >&2
    exit 1
fi

echo "NOTE: brew_setup_tahoe.sh has been renamed to brew-setup.sh." >&2
echo "      Forwarding to it now. Please update your command or bookmark." >&2
echo >&2

exec bash "$TARGET" "$@"
