pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick

Process {
    id: reader
    signal read(string data)
    signal failed()
    property bool delivered: false
    function reload() {
        if (running) return
        delivered = false
        running = true
    }
    stdout: StdioCollector { id: collected }
    stderr: StdioCollector {}
    onExited: (code, status) => {
        delivered = true
        if (code === 0 && status === 0) read(collected.text)
        else failed()
    }
    onRunningChanged: {
        if (running) delivered = false
        else Qt.callLater(() => { if (!reader.delivered && !reader.running) reader.failed() })
    }
}
