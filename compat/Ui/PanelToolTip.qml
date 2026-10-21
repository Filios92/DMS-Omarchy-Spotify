import QtQuick
import "../Commons"

Rectangle {
  // TODO: Replace this embedded tooltip with DMS tooltip behavior.
  property string text: ""
  implicitWidth: label.implicitWidth + 12
  implicitHeight: label.implicitHeight + 8
  x: parent ? (parent.width - width) / 2 : 0
  y: parent ? -height - 4 : 0
  z: 50
  radius: Style.cornerRadius
  color: SpotifyColors.popups.background
  border.color: SpotifyColors.popups.border
  Text {
    id: label
    anchors.centerIn: parent
    text: parent.text
    color: SpotifyColors.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.bodySmall
  }
}
