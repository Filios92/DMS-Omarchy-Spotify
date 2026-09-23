#!/usr/bin/env bash
set -euo pipefail

if (( $# > 0 )); then
  echo "Usage: scripts/install-dms-launcher.sh" >&2
  exit 2
fi

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
desktop_source="$source_root/packaging/omarchy-spotify-dms.desktop"
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
desktop_target="$data_home/applications/omarchy-spotify-dms.desktop"

[[ $data_home == /* && $data_home != / ]] || {
  echo "install-dms-launcher.sh: XDG data directory must be an absolute path" >&2
  exit 2
}

if [[ -e $desktop_target || -L $desktop_target ]]; then
  if [[ -L $desktop_target || ! -f $desktop_target ]] \
      || ! cmp -s -- "$desktop_source" "$desktop_target"; then
    echo "install-dms-launcher.sh: refusing to replace existing entry: $desktop_target" >&2
    exit 1
  fi
  echo "Spotify launcher is already installed: $desktop_target"
  exit 0
fi

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$desktop_source"
fi

install -Dm644 -- "$desktop_source" "$desktop_target"
echo "Installed Spotify launcher: $desktop_target"
echo "Enable omarchySpotify in DMS before opening it from Applications."
