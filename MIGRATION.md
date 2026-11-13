# Task: Minimal viable port of Omarchy-Spotify to Dank Material Shell

## Goal

Create the smallest viable DMS port of Omarchy-Spotify.

The first milestone is NOT a redesign.

The first milestone is:

1. DMS loads the plugin.
2. The existing Spotify backend works.
3. The existing Spotify service logic works.
4. The existing large Spotify UI can be opened as a normal Wayland window.
5. Authentication and playback work.
6. The code no longer depends on Omarchy or Hyprland for basic operation.

Preserve as much of the existing QML and Rust code as possible.

Do not migrate the UI to DMS shared widgets yet unless a specific component cannot work otherwise.

Do not redesign the player.

Do not add Dash integration yet.

Do not spend time making the interface visually match DMS yet.

---

# 1. First inspect the current code

Inspect:

Omarchy-Spotify:
- `Service.qml`
- `Panel.qml`
- `BarWidget.qml`
- `manifest.json`
- API/authentication code
- backend
- scripts
- systemd units
- any `qs.*` imports
- any Hyprland imports
- any shell-global dependencies

DMS:
- plugin loader
- plugin manifest schema
- daemon/plugin lifecycle
- window patterns
- `Modules/Settings`
- `FloatingWindow`
- `FloatingWindowControls`

The purpose of inspecting DMS Settings is ONLY to learn how DMS opens a normal application-style Wayland window.

Do not copy or depend on private Settings pages.

---

# 2. Produce a minimal incompatibility map

Before large edits, create:

`docs/MVP_PORT.md`

List every dependency that prevents Omarchy-Spotify from running under DMS.

Classify each one as:

```text
A. can stay unchanged
B. needs import/path replacement
C. needs a compatibility shim
D. must be rewritten
```

Focus especially on:

- Omarchy shell globals
- Omarchy plugin APIs
- theme imports
- Hyprland-specific screen/window handling
- filesystem paths
- IPC endpoints
- backend service names
- plugin lifecycle assumptions

Do NOT classify visual widgets as migration work unless they actually prevent the application from running.

---

# 3. Preserve the existing Spotify service

The existing service/application logic should be kept intact wherever possible.

Do not immediately split it into new DMS-specific services.

Do not move API logic into new abstractions merely for architectural cleanliness.

First make the existing service work.

Only modify code when required because it depends on:

- Omarchy
- Hyprland
- unavailable imports
- unavailable globals
- incompatible paths

Prefer small compatibility adapters over broad rewrites.

For example, if the existing code expects an Omarchy-specific theme object, provide temporary compatible values or a thin compatibility object rather than replacing every themed component.

The objective is execution first, cleanup later.

---

# 4. Preserve Panel.qml

Treat the existing full Spotify player UI as valuable working code.

Do not redesign `Panel.qml`.

Do not convert its controls to `DankSlider`, `DankCard`, `DankButton`, etc. during MVP work.

Only change:

- broken imports
- unavailable shell references
- window-specific assumptions
- theme dependencies that block loading
- Hyprland dependencies
- paths
- APIs that do not exist in DMS

If needed, create a compatibility module that emulates a small subset of the Omarchy interfaces expected by the panel.

Prefer:

```text
compat/
    OmarchyThemeCompat.qml
    ShellCompat.qml
    ScreenCompat.qml
```

over editing the same assumption in hundreds of locations.

---

# 5. Get the full player window working early

This is a priority milestone.

Create the smallest possible window wrapper around the existing Spotify player.

Investigate DMS Settings to determine the normal pattern for creating an application-style window.

Prefer a normal Quickshell `FloatingWindow`.

The target should conceptually be:

```qml
FloatingWindow {
    id: spotifyWindow

    width: ...
    height: ...
    visible: false

    Panel {
        anchors.fill: parent
    }
}
```

If the existing `Panel.qml` already creates or assumes a window, modify the outermost layer only.

Do not refactor its internal page layout.

The window must:

- open
- close
- reopen
- receive keyboard input
- work on niri
- resize
- not kill playback when closed
- not depend on Hyprland commands

Maximize/minimize polish can wait if it complicates the first milestone.

---

# 6. Backend before bar integration

The backend is more important than the bar widget for MVP.

Retain the existing Rust/librespot backend.

Verify:

1. backend binary starts
2. Unix socket works
3. MPRIS works
4. credentials work
5. Spotify Connect works
6. queue commands work
7. playback works
8. backend lifecycle works independently from the player window

Do not rewrite the backend.

Do not move backend functionality into QML.

Do not replace backend control with generic MPRIS if existing private IPC provides features needed by the application.

---

# 7. Authentication

Preserve the current authentication design.

Do not redesign OAuth during MVP unless required.

Verify:

- OAuth login can start
- callback/token handling works
- token refresh works
- backend authentication works
- credentials remain securely stored

Any Omarchy-specific URL handling or launch commands should be replaced with generic/DMS-compatible alternatives.

Do not store secrets in `plugin.json` or ordinary DMS plugin settings.

---

# 8. Minimal DMS plugin shell

The first DMS plugin only needs enough structure to host the Spotify runtime.

Implement:

- `plugin.json`
- one daemon/bootstrap component if required
- one command or simple widget to open the Spotify window

Do not build a full DMS-native bar widget yet.

For MVP it is acceptable if opening Spotify is initially done via:

- plugin IPC command
- tiny placeholder bar button
- launcher action

Choose whichever is simplest.

Example target:

```text
dms ipc call plugin spotify open
```

or equivalent supported DMS mechanism.

A one-icon bar button that opens the player is sufficient if that is easier.

---

# 9. Temporary compatibility layer is encouraged

Create a compatibility layer instead of prematurely converting the whole application.

Examples:

```text
compat/
├── ThemeCompat.qml
├── ShellCompat.qml
├── ScreenCompat.qml
├── Paths.qml
└── qmldir
```

Use these components to replace assumptions about Omarchy.

Examples of acceptable MVP shims:

- expose compatible color properties
- expose current screen
- provide app data/cache/state paths
- provide shell/window helpers
- emulate small Omarchy helper APIs

Document every compatibility shim.

Each shim should contain a TODO indicating whether it should eventually become:

- DMS native API usage
- standard Qt/Quickshell API
- deleted entirely

---

# 10. Avoid large structural refactors

During MVP:

Do NOT:

- rewrite the UI
- move all JS logic to Rust
- convert every widget to DMS shared widgets
- restructure every QML file
- introduce Dash support
- introduce new state architecture unless necessary
- split working files purely because they are large
- optimize before profiling
- redesign settings
- replace every CSS/theme value

A large ugly working port is better than a clean incomplete rewrite at this stage.

---

# 11. MVP phases

## Phase 1 — Make QML load

Goal:

No unresolved imports or missing Omarchy objects.

Deliverable:

The Spotify service and player QML instantiate without fatal errors.

---

## Phase 2 — Make the window open

Goal:

Open the existing Spotify player inside a normal DMS/Quickshell Wayland window.

Deliverable:

Visible interactive Spotify window on niri.

---

## Phase 3 — Backend connectivity

Goal:

The existing backend connects and exposes playback state.

Deliverable:

Current track metadata appears in the window.

---

## Phase 4 — Playback

Verify:

- play
- pause
- previous
- next
- seek
- volume
- queue
- local playback

---

## Phase 5 — Authentication/API

Verify:

- Web API authentication
- token refresh
- search
- playlists
- library
- devices
- Spotify Connect

---

## Phase 6 — Basic lifecycle

Verify:

- closing window does not stop playback
- reopening window works
- plugin reload does not leave broken state
- backend does not duplicate
- DMS restart reconnects correctly

---

# 12. Only after MVP works

Once the existing application works under DMS, begin gradual cleanup.

The later roadmap is:

```text
working compatibility port
        ↓
replace temporary Omarchy compatibility shims
        ↓
DMS-native bar widget
        ↓
DMS-native popout
        ↓
DMS PluginSettings
        ↓
shared DMS widgets
        ↓
DankDash integration
        ↓
larger UI redesign
```

Each migration should be independent and testable.

Do not combine them with MVP work.

---

# 13. Future UI migration strategy

After the MVP works, migrate components incrementally.

Example:

```text
existing seek control
    ↓
DankSlider

existing buttons
    ↓
DankActionButton

existing settings controls
    ↓
PluginSettings controls

existing header
    ↓
DankWindowHeader
```

Do not convert the entire player at once.

Replace one reusable component at a time.

The application must remain runnable after each migration.

---

# 14. MVP success criteria

The MVP is complete when:

- DMS can load the Spotify plugin
- no Omarchy shell is required
- no Hyprland dependency is required
- the existing Spotify window opens under niri
- the existing backend works
- login works
- local playback works
- Spotify Web API works
- search/library/playlists work
- devices and Spotify Connect work
- closing and reopening the window works
- DMS restart can recover/reconnect
- no major UI redesign was required

Visual integration with DMS is explicitly NOT an MVP requirement.

---

# Primary principle

Make the existing application run under DMS first.

Preserve working code.

Use compatibility shims where useful.

Do not turn the port into a redesign.

Once there is a functional DMS version, progressively replace the compatibility layer and old widgets with DMS-native equivalents.
