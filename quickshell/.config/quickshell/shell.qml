import Quickshell
import QtQuick
import QtQuick.Layouts

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
        implicitHeight: Math.max(clock_container.maximumHeight, leftSec.implicitHeight + 2, rightSec.implicitHeight + 2)

        mask: Region {
            item: clock_container
            Region {
                item: leftSec
            }
            Region {
                item: rightSec
            }
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
                verticalCenter: parent.verticalCenter
                leftMargin: 12
                topMargin: 2
            }
            spacing: 2

            Workspaces {}
        }

        RowLayout {
            id: rightSec
            spacing: 4
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 12
                topMargin: 2
            }
            Network {}
            Volume {}
            Stats {}
            Power {}
            Battery {}
            Notification {}
        }
    }
}
