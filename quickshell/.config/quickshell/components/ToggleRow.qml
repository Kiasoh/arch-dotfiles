pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Switch {
    id: control
    Layout.fillWidth: true
    implicitHeight: 42
    hoverEnabled: true
    background: Rectangle { radius: 12; color: control.hovered ? Qt.lighter(Theme.surfaceContainer, 1.4) : "transparent"; border.width: control.activeFocus ? 1 : 0; border.color: Theme.primary }
    contentItem: Text { text: control.text; font.pixelSize: 13; color: Theme.onSurface; verticalAlignment: Text.AlignVCenter; rightPadding: 58; opacity: control.enabled ? 1 : 0.4 }
    indicator: Rectangle {
        x: control.width - width - 4
        y: (control.height - height) / 2
        implicitWidth: 42
        implicitHeight: 24
        radius: 12
        color: control.checked ? Theme.primaryContainer : Theme.surfaceContainer
        border.width: 1
        border.color: control.checked ? Theme.primary : Theme.onSurfaceVariant
        opacity: control.enabled ? 1 : 0.4
        Rectangle {
            x: control.checked ? 21 : 4
            y: 4
            width: 16
            height: 16
            radius: 8
            color: control.checked ? Theme.primaryContainerText : Theme.onSurfaceVariant
            Behavior on x { NumberAnimation { duration: 150 } }
        }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
