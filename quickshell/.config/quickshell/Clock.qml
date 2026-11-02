import Quickshell
import QtQuick
import QtQuick.Shapes

Item {
    id: clock_container

    readonly property real cornerRadius: 12
    readonly property real maximumHeight: clockText.implicitHeight + 18
    property real hoverProgress: hover.hovered ? 1 : 0

    implicitHeight: clockText.implicitHeight + 8 + hoverProgress * 6
    implicitWidth: clockText.implicitWidth * clockText.scale + 24 + cornerRadius * 2 + hoverProgress * 12

    HoverHandler {
        id: hover
    }

    Behavior on hoverProgress {
        NumberAnimation {
            duration: 500
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "#000000"
            strokeColor: "transparent"
            startX: 0
            startY: 0

            PathArc {
                x: clock_container.cornerRadius
                y: clock_container.cornerRadius
                radiusX: clock_container.cornerRadius
                radiusY: clock_container.cornerRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: clock_container.cornerRadius
                y: clock_container.height - clock_container.cornerRadius
            }
            PathArc {
                x: clock_container.cornerRadius * 2
                y: clock_container.height
                radiusX: clock_container.cornerRadius
                radiusY: clock_container.cornerRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: clock_container.width - clock_container.cornerRadius * 2
                y: clock_container.height
            }
            PathArc {
                x: clock_container.width - clock_container.cornerRadius
                y: clock_container.height - clock_container.cornerRadius
                radiusX: clock_container.cornerRadius
                radiusY: clock_container.cornerRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: clock_container.width - clock_container.cornerRadius
                y: clock_container.cornerRadius
            }
            PathArc {
                x: clock_container.width
                y: 0
                radiusX: clock_container.cornerRadius
                radiusY: clock_container.cornerRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    FontLoader {
        id: clockFont
        source: Qt.resolvedUrl("fonts/CyberDigital-KVgED.otf")
    }
    Text {
        id: clockText
        font {
            family: clockFont.name
            pixelSize: 16
            weight: 600
        }
        anchors.centerIn: parent
        scale: 1 + clock_container.hoverProgress * 0.06
        text: Qt.formatDateTime(sysclock.date, "hh:mm ddd")
        color: Theme.onSurface
    }

    SystemClock {
        id: sysclock
        precision: SystemClock.Minutes
    }
}
