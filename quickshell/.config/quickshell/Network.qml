import QtQuick
import Quickshell.Networking
import Quickshell.Io

Rectangle {
    TapHandler {
        onTapped: nmtui.running = true
    }
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    Process {
        id: nmtui
        command: ["kitty", "--class", "dotfiles-floating", "--title", "Network Manager", "--", "nmtui"]
    }
    implicitHeight: networkText.implicitHeight + 4
    implicitWidth: networkText.implicitWidth + 12
    color: Theme.surfaceContainer
    radius: height / 2
    readonly property var deviceModel: Networking.devices

    readonly property var devices: deviceModel.values

    readonly property var connectedDevice: devices.find(device => device.networks.values.find(network => network.connected))

    readonly property var networkModel: connectedDevice ? connectedDevice.networks : null

    readonly property var networks: networkModel ? networkModel.values : []

    readonly property var connectedNetwork: networks.find(network => network.connected)

    Text {
        id: networkText
        font {
            pixelSize: 12
            weight: Font.Medium
        }
        text: {
            if (!parent.connectedDevice || !parent.connectedDevice.connected)
                return "Disconnected";

            if (!parent.connectedNetwork)
                return "Wi-Fi connected";

            return parent.connectedNetwork.name;
        }

        anchors.centerIn: parent
        color: Theme.onSurface
    }
}
