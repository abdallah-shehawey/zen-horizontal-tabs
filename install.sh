#!/usr/bin/env bash
# Installs the horizontal-tabs layout into a Zen Browser profile.
#
#   ./install.sh                 -> the default profile under ~/.zen
#   ./install.sh "/path/to/profile"
#
# Anything already there is copied to <file>.bak-<timestamp> first; nothing
# else in the profile is touched. Quit Zen completely before running this.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

profile="${1:-}"
if [ -z "$profile" ]; then
  profile="$(ls -d "$HOME"/.zen/*"Default"* 2>/dev/null | head -1)"
fi
if [ -z "$profile" ] || [ ! -d "$profile" ]; then
  echo "Zen profile not found. Pass it as an argument:" >&2
  echo "  ./install.sh \"\$HOME/.zen/xxxxxxxx.Default (release)\"" >&2
  exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$profile/chrome"
for f in "chrome/userChrome.css" "user.js"; do
  if [ -e "$profile/$f" ]; then
    cp "$profile/$f" "$profile/$f.bak-$stamp"
    echo "kept old $f as $f.bak-$stamp"
  fi
  cp "$here/$f" "$profile/$f"
  echo "installed $f"
done

echo
echo "Done -> $profile"
echo "Start Zen again (a full quit, not just closing the window)."
