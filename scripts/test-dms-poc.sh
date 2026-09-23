#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d /tmp/omarchy-spotify-dms-smoke.XXXXXX)
trap 'if [[ -n ${mock_server:-} ]]; then kill "$mock_server" 2>/dev/null || true; fi; rm -rf -- "$test_root"' EXIT
mkdir -m 700 "$test_root/runtime"

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

mkdir -m 700 "$test_root/runtime/omarchy-spotify"
{ printf '%s\n' '{"type":"event","v":1,"event":"state_changed","state":{"lifecycle":"ready","session_connected":true,"position_ms":42000,"track":{"uri":"spotify:track:poc","title":"PoC track","artists":["PoC artist"],"album":"PoC album","art_url":"","duration_ms":180000,"item_type":"track"}}}'; sleep 3; } \
  | socat -u - "UNIX-LISTEN:$test_root/runtime/omarchy-spotify/backend.sock,unlink-early" &
mock_server=$!

env -u WAYLAND_DISPLAY XDG_RUNTIME_DIR="$test_root/runtime" \
  XDG_STATE_HOME="$test_root/state" QT_QPA_PLATFORM=offscreen \
  timeout 10s qs --no-color -p "$source_root/DmsBackendSmoke.qml" \
  >"$test_root/backend-output" 2>&1 || {
    sed -n '1,180p' "$test_root/backend-output"
    exit 1
  }
wait "$mock_server"

if ! rg -q DMS_BACKEND_SMOKE_PASS "$test_root/backend-output"; then
  sed -n '1,180p' "$test_root/backend-output"
  exit 1
fi
echo 'DMS panel and backend socket smoke passed.'
