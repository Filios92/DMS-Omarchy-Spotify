pragma Singleton
import QtQuick

QtObject {
  // TODO: Use DMS border roles or a plain Rectangle border.
  function none() { return { color: "transparent", width: 0 } }
  function flat(color, width) { return { color: color, width: width } }
  function controlSpec(state, foreground, accent) {
    return state === "selected" ? none() : flat(foreground, 1)
  }
}
