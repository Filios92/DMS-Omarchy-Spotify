import QtQuick
import qs.Widgets as DMSWidgets

DMSWidgets.WindowBlur {
  blurX: 0
  blurY: 0
  blurWidth: targetWindow && targetWindow.visible ? targetWindow.width : 0
  blurHeight: targetWindow && targetWindow.visible ? targetWindow.height : 0
}
