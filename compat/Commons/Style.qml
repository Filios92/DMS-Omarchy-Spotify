pragma Singleton
import QtQuick

QtObject {
  // TODO: Replace static metrics with DMS settings or plain Qt values.
  readonly property var font: ({ family: "FiraCode Nerd Font", body: 13, bodySmall: 12,
    caption: 11, subtitle: 15, title: 18, displayLarge: 26,
    icon: 18, iconLarge: 24 })
  readonly property var spacing: ({ controlPaddingX: 10, labelGap: 4 })
  readonly property int cornerRadius: 8
  readonly property int normalBorderWidth: 1
  readonly property real selectedFillAlpha: 0.18
  readonly property real normalBorderAlpha: 0.3
  readonly property real hoverFillAlpha: 0.1
  readonly property real hoverBorderAlpha: 0.4

  function space(value) { return Number(value) || 0 }
  function normalFillFor(foreground, accent) { return Qt.rgba(1, 1, 1, 0.035) }
  function hoverFillFor(foreground, accent) { return Qt.rgba(1, 1, 1, 0.08) }
  function selectedFillFor(foreground, accent) { return Qt.rgba(0.5, 0.65, 1, 0.18) }
  function selectedStateColor(foreground, accent) { return accent || foreground }
}
