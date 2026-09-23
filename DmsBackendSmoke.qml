import QtQuick
import Quickshell

ShellRoot {
  Service {
    id: spotifyService
    Component.onCompleted: daemon.serviceActive = true
    onTitleChanged: if (title === "PoC track") checkState.start()
  }
  Timer {
    id: checkState
    interval: 100
    onTriggered: {
      if (!spotifyService.backend.connected || spotifyService.title !== "PoC track"
          || spotifyService.artist !== "PoC artist"
          || spotifyService.album !== "PoC album" || !spotifyService.hasMedia)
        throw new Error("Backend state did not reach the Spotify service: "
          + JSON.stringify({ connected: spotifyService.backend.connected,
            title: spotifyService.title, artist: spotifyService.artist,
            album: spotifyService.album, hasMedia: spotifyService.hasMedia }))
      console.log("DMS_BACKEND_SMOKE_PASS")
      Qt.quit()
    }
  }
  Timer {
    interval: 5000
    running: true
    onTriggered: { throw new Error("Backend socket state was not received") }
  }
}
