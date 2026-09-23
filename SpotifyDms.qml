import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import "compat/Commons"

PluginComponent {
  id: root

  Binding {
    target: Color
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
    sourceDir: root.sourceDir
    automaticSetupEnabled: false
    manifest: ({ id: "omarchySpotify" })
  }

  Panel {
    id: spotifyPanel
    service: spotifyService
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
        appearance: {
          dmsWindowColor: String(Theme.floatingWindowSurface),
          playerWindowColor: String(Color.background),
          dmsAccent: String(Theme.primary),
          playerAccent: String(Color.accent),
          adapterBound: !!Color.theme,
          styleBound: !!Style.theme,
          fontFamily: Style.font.family,
          cornerRadius: Style.cornerRadius
        }
      })
    }
  }
}
