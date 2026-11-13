import QtQuick

// Adapt the original shell settings contract to DMS plugin storage. Keep the
// player preferences together so observers never see a partially saved update.
QtObject {
  id: root
  property var pluginService: null
  property string pluginId: "omarchySpotify"
  property var pluginData: ({})

  readonly property var shellConfig: {
    var entry = { id: pluginId }
    var values = pluginData.playerSettings || {}
    for (var key in values) entry[key] = values[key]
    return { plugins: [entry] }
  }

  function updateEntryInline(id, values) {
    if (id !== pluginId || !pluginService) return
    pluginService.savePluginData(pluginId, "playerSettings", values)
  }
}
