import QtQuick
import QtQuick.Controls as QQC
import "../Commons"

QQC.ComboBox {
  id: root
  // TODO: Restore searchable selection when migrating settings UI.
  property bool showLabel: true
  property color foreground: SpotifyColors.foreground
  property color surfaceColor: SpotifyColors.background
  property color accent: SpotifyColors.accent
  property string fontFamily: Style.font.family
  property string placeholderText: ""
  property string emptyText: ""
  property var options: []
  property string value: ""
  signal changed(string value)

  model: options
  textRole: "label"
  valueRole: "value"
  currentIndex: {
    for (var i = 0; i < options.length; i++)
      if (String(options[i].value) === value) return i
    return -1
  }
  onActivated: index => {
    if (index >= 0 && index < options.length)
      root.changed(String(options[index].value))
  }
}
