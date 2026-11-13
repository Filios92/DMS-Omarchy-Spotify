import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property string phase: Quickshell.env("SPOTIFY_SETTINGS_PHASE")
  property string testClientId: "11111111111111111111111111111111"
  property bool ready: false
  property bool saved: false
  property bool applied: false

  // Exercise the same load/save and change signal contract as PluginService,
  // using an isolated file across separate Quickshell processes.
  QtObject {
    id: store
    property var data: ({})
    function savePluginData(id, key, value) {
      if (id !== "omarchySpotify") throw new Error("Wrong plugin identity")
      var next = Object.assign({}, data)
      next[key] = value
      data = next
      file.setText(JSON.stringify(next))
    }
  }
  FileView {
    id: file
    path: Quickshell.env("SPOTIFY_SETTINGS_FILE")
    onLoaded: {
      store.data = JSON.parse(text())
      root.ready = true
    }
    onSaved: root.saved = true
  }
  DmsSettings {
    id: adapter
    pluginService: store
    pluginData: store.data
  }
  Service {
    id: service
    shell: adapter
    automaticSetupEnabled: false
    manifest: ({ id: "omarchySpotify" })
  }
  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: {
      if (!root.ready) return
      if (root.phase === "write" || root.phase === "clear") {
        if (!root.applied) {
          root.applied = true
          service.persistSettings({
            clientId: root.phase === "write" ? root.testClientId : "",
            showArtwork: "Off"
          })
          return
        }
        if (!root.saved) return
      }
      var expected = root.phase === "write" || root.phase === "read"
        ? root.testClientId : ""
      if (service.settings.clientId !== expected)
        throw new Error("Client ID did not survive settings synchronization/restart")
      if (service.auth.resolvedClientId !== (expected || service.auth.clientId))
        throw new Error("Wrong active OAuth identity")
      if (service.settings.showArtwork !== "Off")
        throw new Error("Other player preferences did not persist")
      if (store.data.enabled !== true || store.data.unrelated !== "kept")
        throw new Error("Unrelated DMS settings were overwritten")
      console.log("DMS_SETTINGS_SMOKE_PASS " + root.phase)
      Qt.quit()
    }
  }
}
