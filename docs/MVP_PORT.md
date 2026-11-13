# DMS Spotify port: proof of concept

This port stops at a DMS bar button, the existing floating player window, and
the existing backend's playback state. The full MVP in `MIGRATION.md` also
requires login, playback controls, library/API flows, and restart recovery;
those are not PoC acceptance criteria.

The PoC compatibility layer now follows DMS's live Theme roles for text,
accent, error, surfaces, fields, fonts, and corner radius. The player window
uses DMS's floating-window surface, including its configured transparency.
When hosted by DMS, the player also attaches DMS's `WindowBlur` region to the
full window. DMS enables that region only when its blur setting and compositor
support are both active.
In-panel menus keep a nearly opaque background for legibility because they
have no separate blur layer. The player layout and spacing remain unchanged.

## Incompatibility map

| Dependency | Class | PoC treatment |
| --- | --- | --- |
| Rust/librespot backend, MPRIS, private socket protocol | A — can stay unchanged | Reuse the existing binary, user unit, socket and `BackendClient.qml`. |
| Web API, OAuth, keyring identities | A — can stay unchanged | Keep their QML and scripts; exercise the login flow in the later MVP. |
| XDG state/config/cache directories and `omarchy-spotify` runtime names | A — can stay unchanged | Names identify existing stored credentials and systemd resources; changing them would require migration. |
| `qs.Commons` and `qs.Ui` imports in the player tree | B — import/path replacement | Point at `compat/Commons` and `compat/Ui`. The old Omarchy bar widget is not loaded by DMS. |
| Omarchy `manifest.json` and `manifest.__sourceDir` | B — import/path replacement | Keep the Omarchy manifest; add DMS `plugin.json` and pass the plugin directory from the QML component URL. |
| Omarchy theme tokens and control types used throughout `Panel.qml` | C — compatibility shim | Small local `Color`, `Style`, `Border`, and UI facades keep the player layout loadable. Each facade has a replacement TODO. |
| Omarchy shell settings, bar and hide helpers | C — compatibility shim | `DmsSettings.qml` adapts player preferences to DMS plugin storage; `Panel.close()` handles the window. |
| `Hyprland.focusedMonitor` in `Service.qml` | D — must be rewritten | Select the single registered player surface without a compositor-specific import. |
| `return-from-auth.sh` browser-tab closing and focus commands | D — must be rewritten | Defer to the login milestone; the PoC never invokes this path. |
| Omarchy plugin install/lyrics integration and old `BarWidget.qml` | D — must be rewritten | Excluded from this PoC. A DMS-native bar pill opens the full player. |

## Run the PoC

Place this directory under `~/.config/DankMaterialShell/plugins/omarchySpotify`
(a symlink to the checkout is suitable), enable `omarchySpotify` in DMS
Settings → Plugins, and add its Spotify widget to DankBar. Click the music
button to open the existing player. Closing the window leaves the independent
backend user service running.

To list the player under Applications in Dank Launcher, run
`./scripts/install-dms-launcher.sh` from this checkout. This installs a user
desktop entry named **Spotify**; it opens the same DMS player through IPC and
requires DMS and the `omarchySpotify` plugin to be running. It does not install
or start the backend. Reopening Dank Launcher refreshes the application list.

The same window can be driven with `dms ipc call spotifyPoc open` and
`dms ipc call spotifyPoc close`. `dms ipc call spotifyPoc status` reports only
window, plugin-path, backend-connection, MPRIS, track-title, and selected OAuth
client ID status. Client IDs are public identifiers; tokens are never included.

Player preferences, including the optional personal Spotify client ID, are
saved under `omarchySpotify.playerSettings` in DMS's `plugin_settings.json`.
Refresh tokens remain in the keyring, scoped to the selected client ID.

Backend setup remains explicit for this PoC. If no backend is installed, run
`./scripts/setup.sh` from the checkout, then authorize local playback using
the existing player setup flow. The DMS component disables automatic backend
installation when merely enabling the widget. The existing `omarchy-spotify`
unit, config, socket and credential paths are reused.

Use `./scripts/test-dms-poc.sh` for offscreen settings persistence across process
restarts, load/open/close/reopen, theme, and backend socket checks.
A live niri check must also confirm window resize, keyboard focus, backend
connection, and current track metadata. The offscreen check cannot establish
those compositor and account-dependent behaviors.
