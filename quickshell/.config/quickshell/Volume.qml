import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Io

Rectangle {
    TapHandler {
        onTapped: pav.running = !pav.running && true
    }
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    Process {
        id: pav
        command: ["pavucontrol"]
    }

    implicitHeight: row.implicitHeight + 4
    implicitWidth: row.implicitWidth + 12
    radius: height / 2
    color: Theme.surfaceContainer

    Row {
        id: row
        anchors.centerIn: parent
        // anchors.verticalCenter: parent.verticalCenter
        // anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        readonly property var sink: Pipewire.defaultAudioSink

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            font.weight: Font.Medium
            text: {
                if (!parent.sink)
                    return "󰖁";

                if (parent.sink.audio.muted)
                    return "󰝟";

                let volume = parent.sink.audio.volume;

                if (volume >= 0.5)
                    return "󰕾";
                if (volume > 0)
                    return "󰖀";
                return "󰕿";
            }
            color: Theme.onSurface
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.sink ? Math.round(parent.sink.audio.volume * 100) + "%" : "--"

            font.pixelSize: 12
            font.weight: Font.Medium
            color: Theme.onSurface
        }
    }
}
