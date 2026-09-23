import QtQuick

Rectangle {
  // TODO: Replace this Omarchy border contract with ordinary Qt surfaces.
  property var borderSpec: ({ color: "transparent", width: 0 })
  border.color: borderSpec && borderSpec.color ? borderSpec.color : "transparent"
  border.width: borderSpec && borderSpec.width ? borderSpec.width : 0
}
