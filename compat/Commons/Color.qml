pragma Singleton
import QtQuick

QtObject {
  // TODO: Read these roles from the DMS Theme singleton after the port works.
  readonly property color foreground: "#e8e8ed"
  readonly property color background: "#17191e"
  readonly property color accent: "#81a1ff"
  readonly property color muted: "#9aa0ad"
  readonly property color urgent: "#ef6a70"
  readonly property var popups: ({ background: "#252830", border: "#535967" })
}
