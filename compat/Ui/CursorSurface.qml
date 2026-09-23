import QtQuick
import "../Commons"

Rectangle {
  // TODO: Replace the Omarchy keyboard-cursor decoration with DMS focus state.
  property bool hasCursor: false
  property color foreground: Color.foreground
  color: "transparent"
  border.color: hasCursor ? foreground : "transparent"
  border.width: hasCursor ? 1 : 0
  radius: Style.cornerRadius
}
