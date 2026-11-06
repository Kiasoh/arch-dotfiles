import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland

// import Quickshell.Networking

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root
        required property var modelData
        screen: modelData

        FontLoader {
            id: clockFont
            //source: Qt.resolvedUrl("fonts/RuntimeRegular-m2Odx.otf")
            source: Qt.resolvedUrl("fonts/CyberDigital-KVgED.otf")
        }
        anchors {
            top: true
            right: true
            left: true
        }
        color: "transparent"
        readonly property real barHeight: Math.max(clock_container.maximumHeight, leftSec.implicitHeight + 2, rightSec.implicitHeight + 2)
        implicitHeight: Math.max(barHeight, powerControl.drawerHeight)
        exclusiveZone: barHeight
        WlrLayershell.keyboardFocus: powerControl.open && !powerControl.busy ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        HyprlandFocusGrab {
            active: powerControl.open && !powerControl.busy
            windows: [root]
            onCleared: if (!powerControl.busy) powerControl.open = false
        }

        mask: Region {
            item: clock_container
            Region {
                item: leftSec
            }
            Region {
                item: rightSec
            }
            Region { item: powerControl.drawerItem }
        }

        Clock {
            id: clock_container
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        RowLayout {
            id: leftSec

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 12
                topMargin: (root.barHeight - implicitHeight) / 2
            }
            spacing: 2

            Workspaces {}
        }

        RowLayout {
            id: rightSec
            spacing: 4
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: 12
                topMargin: (root.barHeight - implicitHeight) / 2
            }
            Network {}
            Volume {}
            Stats {}
            Power { id: powerControl; barWindow: root }
            Battery {}
            Notification {}
        }
    }
}
