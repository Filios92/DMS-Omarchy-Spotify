import QtQuick
import "../Commons"

Rectangle {
  // TODO: Use a plain themed divider.
  property color foreground: SpotifyColors.foreground
  implicitHeight: 1
  height: 1
  color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.2)
}
