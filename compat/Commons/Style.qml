pragma Singleton
import QtQuick

QtObject {
  // DMS supplies font scale and shape through Theme. Layout spacing stays at
  // the original player values so adapting the palette does not redesign it.
  property var theme: null
  readonly property var font: ({
    family: theme ? theme.fontFamily : "FiraCode Nerd Font",
    body: theme ? theme.fontSizeMedium : 13,
    bodySmall: theme ? theme.fontSizeSmall : 12,
    caption: theme ? theme.fontSizeSmall : 11,
    subtitle: theme ? theme.fontSizeLarge : 15,
    title: theme ? theme.fontSizeXLarge : 18,
    displayLarge: theme ? theme.fontSizeXXLarge : 26,
    icon: theme ? theme.iconSizeMedium : 18,
    iconLarge: theme ? theme.iconSize : 24
  })
  readonly property var spacing: ({ controlPaddingX: 10, labelGap: 4 })
  readonly property real cornerRadius: theme ? theme.cornerRadius : 8
  readonly property real normalBorderWidth: theme ? theme.outlineWidth : 1
  readonly property real selectedFillAlpha: 0.18
  readonly property real normalBorderAlpha: 0.3
  readonly property real hoverFillAlpha: 0.1
  readonly property real hoverBorderAlpha: 0.4

  function space(value) { return Number(value) || 0 }
  function normalFillFor(foreground, accent) {
    return Qt.rgba(foreground.r, foreground.g, foreground.b, 0.035)
  }
  function hoverFillFor(foreground, accent) {
    return Qt.rgba(foreground.r, foreground.g, foreground.b, hoverFillAlpha)
  }
  function selectedFillFor(foreground, accent) {
    return Qt.rgba(accent.r, accent.g, accent.b, selectedFillAlpha)
  }
  function selectedStateColor(foreground, accent) { return accent || foreground }
}
