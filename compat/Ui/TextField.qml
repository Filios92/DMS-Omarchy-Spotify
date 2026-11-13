import QtQuick
import QtQuick.Controls.Basic as QQC
import "../Commons"

QQC.TextField {
  // Use a non-floating placeholder regardless of the host's Controls style.
  property color foreground: SpotifyColors.foreground
  property bool hasCursor: false
  color: foreground
  placeholderTextColor: SpotifyColors.muted
  selectionColor: SpotifyColors.accent
  selectedTextColor: SpotifyColors.background
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
