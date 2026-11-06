pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root
    property var request: null
    property var promptScreen: null

    function send(operation, fields) {
        if (root.request) agent.write(JSON.stringify(Object.assign({id: root.request.id, op: operation}, fields)) + "\n")
    }
    Process {
        id: agent
        command: ["/usr/bin/python3", Quickshell.shellPath("scripts/qs-polkit-agent.py")]
        running: true
        stdinEnabled: true
        stdout: SplitParser {
            onRead: data => {
                const event = JSON.parse(data)
                if (event.type === "state") {
                    if (!root.request) root.promptScreen = Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) || Quickshell.screens[0]
                    root.request = event
                } else if (event.type === "closed") root.request = null
            }
        }
        stderr: SplitParser { onRead: data => console.error("Polkit:", data) }
        onExited: Qt.quit()
    }
    LazyLoader {
        id: promptLoader
        active: root.request !== null
        PolkitPrompt {
            screen: root.promptScreen
            request: root.request
            onRespond: value => root.send("respond", {value: value})
            onCancel: root.send("cancel", {})
            onSelectIdentity: index => root.send("select", {index: index})
        }
    }
}
