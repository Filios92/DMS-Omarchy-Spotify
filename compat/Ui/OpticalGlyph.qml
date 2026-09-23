import QtQuick
import "../Commons"

Item {
  // TODO: Use a standard icon or bundled glyph after the PoC.
  property string text: ""
  property color color: Color.foreground
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.icon
  implicitWidth: glyph.implicitWidth
  implicitHeight: glyph.implicitHeight

  Text {
    id: glyph
    anchors.centerIn: parent
    text: parent.text
    color: parent.color
    font.family: parent.fontFamily
    font.pixelSize: parent.fontSize
  }
}
