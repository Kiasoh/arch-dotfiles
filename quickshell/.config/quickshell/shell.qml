import Quickshell
import QtQuick
import QtQuick.Layouts

// import Quickshell.Networking

PanelWindow {
    id: root
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
    implicitHeight: clock_container.implicitHeight

    RowLayout {
        anchors.centerIn: parent
        Clock {
            id: clock_container
        }
    }

    RowLayout {
        id: leftSec

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 12
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
        }
        Network {}
        Volume {}
        Stats {}
        Power {}
        Battery {}
        Notification {}
    }
}
