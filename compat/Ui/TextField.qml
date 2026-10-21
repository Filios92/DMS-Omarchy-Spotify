import QtQuick
import QtQuick.Controls as QQC
import "../Commons"

QQC.TextField {
  // TODO: Replace this color facade with a themed DMS field.
  property color foreground: SpotifyColors.foreground
  property bool hasCursor: false
  color: foreground
  font.family: Style.font.family
  font.pixelSize: Style.font.body
  implicitHeight: 32
  background: Rectangle {
    radius: Style.cornerRadius
    color: SpotifyColors.field
    border.color: parent.activeFocus || parent.hasCursor
      ? SpotifyColors.fieldFocusedBorder : SpotifyColors.fieldBorder
    border.width: Style.normalBorderWidth
  }
}
