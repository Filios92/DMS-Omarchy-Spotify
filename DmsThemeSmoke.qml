import QtQuick
import Quickshell
import "compat/Commons"

ShellRoot {
  QtObject {
    id: fakeTheme
    property color surfaceText: "#eeeeee"
    property color floatingWindowSurface: "#80223344"
    property color primary: "#4488cc"
    property color surfaceVariantText: "#aaaaaa"
    property color error: "#dd4444"
    property color outline: "#777777"
    property color floatingWindowFieldColor: "#334455"
    property color floatingWindowFieldBorderColor: "#556677"
    property color floatingWindowFieldFocusedBorderColor: "#88aaff"
    property color floatingWindowSurfaceHigh: "#445566"
    property string fontFamily: "Theme Test"
    property real fontSizeSmall: 12
    property real fontSizeMedium: 14
    property real fontSizeLarge: 16
    property real fontSizeXLarge: 20
    property real fontSizeXXLarge: 28
    property real iconSizeMedium: 20
    property real iconSize: 24
    property real cornerRadius: 9
    property real outlineWidth: 1
  }

  Panel { id: panel }

  Component.onCompleted: {
    Color.theme = fakeTheme
    Style.theme = fakeTheme
    fakeTheme.floatingWindowSurface = "#66445566"
    fakeTheme.primary = "#ee7733"
    fakeTheme.surfaceText = "#112233"
    fakeTheme.floatingWindowSurfaceHigh = "#ddeeff"
    fakeTheme.fontFamily = "Changed Theme"
    fakeTheme.fontSizeMedium = 19
    fakeTheme.cornerRadius = 14
    check.start()
  }

  Timer {
    id: check
    interval: 100
    onTriggered: {
      if (Math.abs(Color.background.a - 0.4) > 0.01
          || Math.abs(panel.background.a - 0.4) > 0.01
          || Color.accent.r < 0.9 || Color.accent.g < 0.4
          || Color.foreground.r > 0.1
          || Style.normalFillFor(Color.foreground, Color.accent).r > 0.1
          || Color.popups.background.r < 0.8
          || Style.font.family !== "Changed Theme"
          || panel.fontFamily !== "Changed Theme"
          || Style.font.body !== 19 || Style.cornerRadius !== 14)
        throw new Error("DMS theme values did not reach the player")
      console.log("DMS_THEME_SMOKE_PASS")
      Qt.quit()
    }
  }
}
