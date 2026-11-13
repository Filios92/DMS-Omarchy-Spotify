import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import "compat/Commons"

PluginComponent {
  id: root

  Binding {
    target: SpotifyColors
    property: "theme"
    value: Theme
  }
  Binding {
    target: Style
    property: "theme"
    value: Theme
  }

  // DMS keeps this component loaded while its bar widget is active. The
  // Rust backend has its own systemd lifecycle and outlives this window.
  readonly property string sourceDir: decodeURIComponent(
    String(Qt.resolvedUrl(".")).replace(/^file:\/\//, "").replace(/\/$/, ""))

  Service {
    id: spotifyService
    shell: dmsSettings
    sourceDir: root.sourceDir
    automaticSetupEnabled: false
    manifest: ({ id: "omarchySpotify" })
  }

  DmsSettings {
    id: dmsSettings
    pluginService: root.pluginService
    pluginData: root.pluginData
  }

  Panel {
    id: spotifyPanel
    service: spotifyService
    dmsHostEnabled: true
    manifest: ({ id: "omarchySpotify" })
  }

  Component {
    id: openPill
    Item {
      implicitWidth: 36
      implicitHeight: 36
      Text {
        anchors.centerIn: parent
        text: "♫"
        color: Theme.widgetIconColor
        font.pixelSize: Theme.iconSize
      }
    }
  }

  horizontalBarPill: openPill
  verticalBarPill: openPill
  pillClickAction: function() { spotifyPanel.open("{}") }

  IpcHandler {
    target: "spotifyPoc"
    function open(): string {
      spotifyPanel.open("{}")
      return "ok"
    }
    function close(): string {
      spotifyPanel.close()
      return "ok"
    }
    function status(): string {
      return JSON.stringify({
        windowOpen: spotifyPanel.opened,
        sourceDir: root.sourceDir,
        backendConnected: spotifyService.backend.connected,
        mprisPresent: spotifyService.hasLocalPlayer,
        title: spotifyService.title,
        customClientId: String(spotifyService.settings.clientId || ""),
        resolvedClientId: spotifyService.auth.resolvedClientId,
        appearance: {
          dmsWindowColor: String(Theme.floatingWindowSurface),
          playerWindowColor: String(SpotifyColors.background),
          dmsAccent: String(Theme.primary),
          playerAccent: String(SpotifyColors.accent),
          adapterBound: !!SpotifyColors.theme,
          styleBound: !!Style.theme,
          fontFamily: Style.font.family,
          cornerRadius: Style.cornerRadius
        }
      })
    }
  }
}
