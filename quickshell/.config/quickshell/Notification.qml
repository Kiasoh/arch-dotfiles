import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool hasUnread: false

    implicitWidth: notif.implicitWidth
    implicitHeight: notif.implicitHeight

    Process {
        id: toggle
        command: ["swaync-client", "-t"]
    }

    // one-shot: initial unread count at startup
    Process {
        running: true
        command: ["swaync-client", "-c"]
        stdout: StdioCollector {
            onStreamFinished: root.hasUnread = Number(text.trim()) > 0
        }
    }

    // persistent: swaync pushes state on every change
    Process {
        running: true
        command: ["swaync-client", "--subscribe"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const state = JSON.parse(data);
                    root.hasUnread = state.count > 0;
                } catch (e) {
                    // partial line, ignore
                }
            }
        }
    }

    Text {
        id: notif
        text: "󰂚"
        font.pixelSize: 18

        anchors.centerIn: parent

        color: root.hasUnread ? Theme.primary : Theme.onSurfaceVariant
        TapHandler {
            onTapped: toggle.running = true
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }
}
