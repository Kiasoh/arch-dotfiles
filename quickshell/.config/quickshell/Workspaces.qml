import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    FontLoader {
        id: clockFont
        //source: Qt.resolvedUrl("fonts/RuntimeRegular-m2Odx.otf")
        source: Qt.resolvedUrl("fonts/CyberDigital-KVgED.otf")
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: event => {
            if (event.angleDelta.y > 0) {
                Hyprland.dispatch('hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))');
            } else if (event.angleDelta.y < 0) {
                Hyprland.dispatch('hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))');
            }

            event.accepted = true;
        }
    }

    Row {
        id: row
        spacing: 2

        Repeater {
            model: Hyprland.workspaces
            delegate: Rectangle {
                id: workspaceRect
                required property HyprlandWorkspace modelData
                color: modelData.active ? Theme.primaryContainer : Theme.surfaceContainer
                implicitHeight: 20
                implicitWidth: modelData.active ? 50 : 20
                opacity: modelData.active ? 1 : 0.7
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 100
                    }
                }
                radius: height / 2
                TapHandler {
                    onTapped: modelData.activate()
                }
                Text {
                    id: workspaceText
                    font {
                        family: clockFont.name
                        pixelSize: 15
                        weight: Font.Medium
                    }
                    anchors.centerIn: parent
                    text: workspaceRect.modelData.name
                    color: workspaceRect.modelData.active ? Theme.primaryContainerText : Theme.onSurfaceVariant
                }
            }
        }
    }
}
