#!/usr/bin/env bash
# Removes the layout: deletes the two files this repo installs.
# Zen goes back to its own vertical sidebar. Nothing else is touched.
set -euo pipefail

profile="${1:-$(ls -d "$HOME"/.zen/*"Default"* 2>/dev/null | head -1)}"
[ -d "$profile" ] || { echo "Zen profile not found" >&2; exit 1; }

rm -f "$profile/chrome/userChrome.css" "$profile/user.js"
echo "removed. Note: prefs already written into prefs.js stay until you reset"
echo "them in about:config (zen.tabs.vertical, zen.urlbar.replace-newtab, ...)."
