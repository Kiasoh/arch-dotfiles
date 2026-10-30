import Quickshell
import QtQuick

Rectangle {
    id: clock_container

    FontLoader {
        id: clockFont
        //source: Qt.resolvedUrl("fonts/RuntimeRegular-m2Odx.otf")
        source: Qt.resolvedUrl("fonts/CyberDigital-KVgED.otf")
    }
    implicitHeight: clockText.implicitHeight + 4
    implicitWidth: clockText.implicitWidth + 12
    color: Theme.surfaceContainer
    radius: height / 2
    Text {
        id: clockText
        font {
            family: clockFont.name
            pixelSize: 18
            weight: Font.Medium
        }
        anchors.centerIn: parent
        text: Qt.formatDateTime(sysclock.date, "hh:mm ddd")
        color: Theme.onSurface
    }

    SystemClock {
        id: sysclock
        precision: SystemClock.Minutes
    }
}
