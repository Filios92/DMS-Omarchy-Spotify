import QtQuick
import "../Commons"

Item {
  id: root

  // TODO: Gradually replace this Omarchy button facade after the PoC.
  property string text: ""
  property string iconText: ""
  property string tooltipText: ""
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.body
  property real iconSize: Style.font.icon
  property color foreground: SpotifyColors.foreground
  property color accent: SpotifyColors.accent
  property bool selected: false
  property bool bordered: false
  property bool leftAlign: false
  property bool focusable: false
  property bool hasCursor: false
  property real horizontalPadding: 10
  property real verticalPadding: 6
  readonly property var _borderSpec: Border.none()
  property var borderSpec: _borderSpec

  signal clicked()
  signal hovered(bool on)

  implicitWidth: content.implicitWidth + horizontalPadding * 2
  implicitHeight: Math.max(28, content.implicitHeight + verticalPadding * 2)
  opacity: enabled ? 1 : 0.5
  activeFocusOnTab: focusable

  BorderSurface {
    anchors.fill: parent
    radius: Style.cornerRadius
    color: root.selected ? Style.selectedFillFor(root.foreground, root.accent)
      : (hit.containsMouse || root.hasCursor
        ? Style.hoverFillFor(root.foreground, root.accent) : "transparent")
    borderSpec: root.bordered ? root.borderSpec : Border.none()
  }

  MouseArea {
    id: hit
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: root.hovered(true)
    onExited: root.hovered(false)
    onClicked: {
      if (root.focusable) root.forceActiveFocus()
      root.clicked()
    }
  }

  Row {
    id: content
    x: root.leftAlign ? root.horizontalPadding : (root.width - width) / 2
    anchors.verticalCenter: parent.verticalCenter
    spacing: root.iconText && root.text ? 7 : 0
    Text {
      visible: root.iconText !== ""
      text: root.iconText
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: root.iconSize
    }
    Text {
      visible: root.text !== ""
      text: root.text
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      font.bold: root.selected
      elide: Text.ElideRight
    }
  }

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()
}
