import QtQuick
import "../Commons"

Item {
  id: root
  // TODO: Replace with a standard Qt slider once playback is validated.
  property var bar: null
  property real minimum: 0
  property real maximum: 1
  property real step: 0.01
  property int tickCount: 0
  property real value: minimum
  property bool dragging: hit.pressed
  signal moved(real value)
  signal released(real value)
  signal rightClicked()

  implicitHeight: 22

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: 4
    radius: 2
    color: Color.muted
  }
  Rectangle {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width * Math.max(0, Math.min(1,
      (root.value - root.minimum) / Math.max(0.000001, root.maximum - root.minimum)))
    height: 4
    radius: 2
    color: Color.accent
  }
  Rectangle {
    x: Math.max(0, Math.min(parent.width - width,
      parent.width * (root.value - root.minimum)
        / Math.max(0.000001, root.maximum - root.minimum) - width / 2))
    anchors.verticalCenter: parent.verticalCenter
    width: 12
    height: 12
    radius: 6
    color: Color.foreground
  }
  MouseArea {
    id: hit
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    enabled: root.enabled
    cursorShape: Qt.PointingHandCursor
    function at(x) {
      var raw = root.minimum + (root.maximum - root.minimum)
        * Math.max(0, Math.min(1, x / Math.max(1, width)))
      return root.step > 0 ? root.minimum
        + Math.round((raw - root.minimum) / root.step) * root.step : raw
    }
    onPressed: mouse => { if (mouse.button === Qt.LeftButton) root.moved(at(mouse.x)) }
    onPositionChanged: mouse => { if (pressed && pressedButtons & Qt.LeftButton) root.moved(at(mouse.x)) }
    onReleased: mouse => { if (mouse.button === Qt.LeftButton) root.released(at(mouse.x)) }
    onClicked: mouse => { if (mouse.button === Qt.RightButton) root.rightClicked() }
  }
}
