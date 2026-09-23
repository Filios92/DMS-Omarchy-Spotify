import QtQuick
import Quickshell

ShellRoot {
  Service { id: spotifyService }
  Panel { id: panel; service: spotifyService }
  property int step: 0
  Timer {
    interval: 300
    repeat: true
    running: true
    onTriggered: {
      if (step === 0) panel.open("{}")
      else if (step === 1) {
        if (!panel.opened) throw new Error("Player did not open")
        panel.close()
      } else if (step === 2) panel.open("{}")
      else {
        if (!panel.opened) throw new Error("Player did not reopen")
        console.log("DMS_PANEL_SMOKE_PASS")
        Qt.quit()
      }
      step++
    }
  }
}
