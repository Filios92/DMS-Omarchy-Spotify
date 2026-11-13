import QtQuick
import Quickshell
import "Api.js" as Api

ShellRoot {
  id: root
  property var opened: null
  property string tab: ""
  property int refreshes: 0
  property bool changeTrackDuringRefresh: false

  Service {
    id: service
    automaticSetupEnabled: false
    function loadPlaybackState(callback, reportError) {
      root.refreshes++
      if (root.changeTrackDuringRefresh) root.playback("spotify:playlist:other", "next")
      if (typeof callback === "function") callback(true)
    }
  }
  Panel {
    id: panel
    service: service
    function openItem(item) { root.opened = item }
    function chooseTab(value) { root.tab = value }
  }

  function playback(contextUri, id, withAlbum, withArtist) {
    service.applyPlaybackState({
      device: { id: "smokeRemote", name: "Remote phone", type: "Smartphone", is_active: true },
      context: contextUri ? { uri: contextUri } : null,
      item: { id: id || "song123", uri: "spotify:track:" + (id || "song123"),
        type: "track", name: "Source smoke track",
        artists: withArtist ? [{ id: "artist123", name: "Artist", uri: "spotify:artist:artist123" }] : [],
        album: withAlbum ? { id: "album123", name: "Album", uri: "spotify:album:album123" } : null }
    })
    root.opened = null
    root.tab = ""
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      service.auth.customClientId = "invalid"
      service.auth.loggedIn = true
      var contexts = ["playlist", "album", "artist"]
      for (var i = 0; i < contexts.length; i++) {
        root.playback("spotify:" + contexts[i] + ":source123")
        panel.openPlaybackSource()
        if (!root.opened || root.opened.type !== contexts[i] || root.opened.id !== "source123")
          throw new Error("Wrong playback source: " + contexts[i])
      }
      service.lastRadioPlaylist = Api.normalizeContext({
        type: "playlist", id: "radio123", uri: "spotify:playlist:radio123", name: "Song radio"
      })
      root.playback("spotify:playlist:radio123")
      panel.openPlaybackSource()
      if (!root.opened || root.opened.name !== "Song radio")
        throw new Error("Radio source was not preserved")

      root.playback("spotify:user:owner:collection")
      panel.openPlaybackSource()
      if (root.tab !== "library" || panel.libraryType !== "tracks")
        throw new Error("Liked songs did not open the track library")

      root.playback("", "song123", true, true)
      panel.openPlaybackSource()
      if (!root.opened || root.opened.id !== "album123")
        throw new Error("Missing source did not fall back to album")

      root.playback("", "song123", false, true)
      panel.openPlaybackSource()
      if (!root.opened || root.opened.id !== "artist123")
        throw new Error("Missing album did not fall back to artist")

      root.playback("")
      panel.openPlaybackSource()
      if (root.tab !== "queue") throw new Error("Missing metadata did not open queue")

      root.playback("spotify:playlist:source123")
      root.changeTrackDuringRefresh = true
      panel.openPlaybackSource()
      if (root.opened || root.tab) throw new Error("Track change opened a stale source")
      if (root.refreshes < 9) throw new Error("Source was not refreshed on demand")
      console.log("DMS_SOURCE_SMOKE_PASS")
      Qt.quit()
    }
  }
}
