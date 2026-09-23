pragma Singleton
import QtQuick

QtObject {
  // TODO: Replace the Omarchy border contract after the player is DMS-native.
  function none() { return { color: "transparent", width: 0 } }
  function flat(color, width) { return { color: color, width: width } }
  function controlSpec(state, foreground, accent) {
    var outline = Color.outline
    return state === "selected" ? none() : flat(
      Qt.rgba(outline.r, outline.g, outline.b, Style.normalBorderAlpha),
      Style.normalBorderWidth)
  }
}
