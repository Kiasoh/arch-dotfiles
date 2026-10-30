import QtQuick
import Quickshell.Services.UPower

Rectangle {
    readonly property var battery: UPower.displayDevice

    implicitHeight: batteryText.implicitHeight + 4
    implicitWidth: batteryText.implicitWidth + 12

    color: Theme.surfaceContainer
    radius: height / 2

    Text {
        id: batteryText
        anchors.centerIn: parent
        color: Theme.onSurface
        font.pixelSize: 12
        font.weight: Font.Medium

        text: parent.battery.ready ? `${Math.round(parent.battery.percentage * 100)}%` : "..."
    }
}
