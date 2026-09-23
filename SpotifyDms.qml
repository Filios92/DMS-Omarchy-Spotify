import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins

PluginComponent {
  id: root

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
        color: Theme.surfaceText
        font.pixelSize: 22
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
        title: spotifyService.title
      })
    }
  }
}
