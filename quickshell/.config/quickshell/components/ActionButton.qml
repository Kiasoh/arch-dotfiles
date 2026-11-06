pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import ".."

Button {
    id: button
    implicitWidth: label.implicitWidth + 24
    implicitHeight: 34
    hoverEnabled: true
    background: Rectangle {
        radius: button.down ? 8 : 16
        color: button.checked || button.highlighted ? Theme.primaryContainer : button.hovered ? Qt.lighter(Theme.surfaceContainer, 1.55) : Qt.lighter(Theme.surfaceContainer, 1.25)
        border.color: Theme.primary
        border.width: button.activeFocus ? 1 : 0
        opacity: button.enabled ? 1 : 0.4
        Behavior on radius { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    contentItem: Text {
        id: label
        text: button.text
        font.pixelSize: 12
        color: button.checked || button.highlighted ? Theme.primaryContainerText : Theme.onSurface
        opacity: button.enabled ? 1 : 0.4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
