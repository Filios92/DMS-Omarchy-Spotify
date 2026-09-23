pragma Singleton
import QtQuick

QtObject {
  // The DMS wrapper supplies qs.Common.Theme. The fallback keeps standalone
  // Quickshell smoke tests and the compatibility components loadable.
  property var theme: null
  readonly property color foreground: theme ? theme.surfaceText : "#e8e8ed"
  readonly property color background: theme ? theme.floatingWindowSurface : "#17191e"
  readonly property color accent: theme ? theme.primary : "#81a1ff"
  readonly property color muted: theme ? theme.surfaceVariantText : "#9aa0ad"
  readonly property color urgent: theme ? theme.error : "#ef6a70"
  readonly property color outline: theme ? theme.outline : "#535967"
  readonly property color field: theme ? theme.floatingWindowFieldColor : "#24272f"
  readonly property color fieldBorder: theme
    ? theme.floatingWindowFieldBorderColor : "#505562"
  readonly property color fieldFocusedBorder: theme
    ? theme.floatingWindowFieldFocusedBorderColor : accent
  readonly property var popups: ({
    background: theme ? theme.floatingWindowSurfaceHigh : "#252830",
    border: outline
  })
}
