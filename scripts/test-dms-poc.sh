#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d /tmp/omarchy-spotify-dms-smoke.XXXXXX)
trap 'if [[ -n ${mock_server:-} ]]; then kill "$mock_server" 2>/dev/null || true; fi; rm -rf -- "$test_root"' EXIT
mkdir -m 700 "$test_root/runtime"

dbus-run-session -- env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
  XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
  timeout 10s qs --no-color -p "$source_root/DmsSourceSmoke.qml" \
  >"$test_root/source-output" 2>&1 || {
    cat "$test_root/source-output"
    exit 1
  }
if ! rg -q DMS_SOURCE_SMOKE_PASS "$test_root/source-output" \
  || rg -i 'Error:|ReferenceError|TypeError|binding loop|Cannot assign|Unable to assign|Failed to load configuration' "$test_root/source-output"; then
  cat "$test_root/source-output"
  exit 1
fi

printf '%s\n' '{"enabled":true,"unrelated":"kept"}' > "$test_root/settings.json"
for phase in write read clear default; do
  dbus-run-session -- env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
    XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
    SPOTIFY_SETTINGS_PHASE="$phase" SPOTIFY_SETTINGS_FILE="$test_root/settings.json" \
    timeout 10s qs --no-color -p "$source_root/DmsSettingsSmoke.qml" \
    >"$test_root/settings-output" 2>&1 || {
      cat "$test_root/settings-output"
      exit 1
    }
  if ! rg -q "DMS_SETTINGS_SMOKE_PASS $phase" "$test_root/settings-output" \
    || rg -i 'Error:|ReferenceError|TypeError|binding loop|Cannot assign|Unable to assign|Failed to load configuration' "$test_root/settings-output"; then
    cat "$test_root/settings-output"
    exit 1
  fi
done

env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
  XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
  timeout 10s qs --no-color -p "$source_root/DmsPanelSmoke.qml" \
  >"$test_root/output" 2>&1 || {
    sed -n '1,180p' "$test_root/output"
    exit 1
  }

if ! rg -q DMS_PANEL_SMOKE_PASS "$test_root/output"; then
  sed -n '1,180p' "$test_root/output"
  exit 1
fi
if rg -i 'ReferenceError|TypeError|binding loop|Cannot assign|Unable to assign|Failed to load configuration' "$test_root/output"; then
  exit 1
fi

env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
  XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
  timeout 10s qs --no-color -p "$source_root/DmsThemeSmoke.qml" \
  >"$test_root/theme-output" 2>&1 || {
    sed -n '1,180p' "$test_root/theme-output"
    exit 1
  }
if ! rg -q DMS_THEME_SMOKE_PASS "$test_root/theme-output"; then
  sed -n '1,180p' "$test_root/theme-output"
  exit 1
fi
if rg -i 'ReferenceError|TypeError|binding loop|Cannot assign|Unable to assign|Failed to load configuration' "$test_root/theme-output"; then
  exit 1
fi

mkdir -m 700 "$test_root/runtime/omarchy-spotify"
{ printf '%s\n' '{"type":"event","v":1,"event":"state_changed","state":{"lifecycle":"ready","session_connected":true,"position_ms":42000,"track":{"uri":"spotify:track:poc","title":"PoC track","artists":["PoC artist"],"album":"PoC album","art_url":"","duration_ms":180000,"item_type":"track"}}}'; sleep 8; } \
  | socat -u - "UNIX-LISTEN:$test_root/runtime/omarchy-spotify/backend.sock,unlink-early" &
mock_server=$!

# A real Spotify MPRIS player may be running on the host. Keep the mock
# socket test on a private bus so it exercises the socket metadata fallback.
dbus-run-session -- env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
  XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
  timeout 12s qs --no-color -p "$source_root/DmsBackendSmoke.qml" \
  >"$test_root/backend-output" 2>&1 || {
    sed -n '1,180p' "$test_root/backend-output"
    exit 1
  }
wait "$mock_server"

if ! rg -q DMS_BACKEND_SMOKE_PASS "$test_root/backend-output"; then
  sed -n '1,180p' "$test_root/backend-output"
  exit 1
fi
echo 'DMS playback source, settings persistence, panel, live theme binding, and backend socket smoke passed.'
