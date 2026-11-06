pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "components"

Scope {
    id: root
    required property string screenName
    property bool active: false
    property bool busy: false
    property string gpuMode: "?"
    property string governor: "?"
    property string epp: "?"
    property var govOptions: []
    property var eppOptions: []
    property string fan: "?"
    property var hyprState: ({})
    property var monitor: null
    property string actionKind: ""
    property bool rebootNeeded: false
    property string note: ""
    property string noteError: ""
    property var savedGaps: null
    readonly property var refreshModes: {
        if (!monitor) return []
        const resolution = monitor.width + "x" + monitor.height + "@"
        return [...new Set((monitor.availableModes || []).filter(mode => mode.startsWith(resolution)))].sort((a, b) => parseFloat(b.split("@")[1]) - parseFloat(a.split("@")[1]))
    }
    readonly property string currentMode: refreshModes.find(mode => Math.abs(parseFloat(mode.split("@")[1]) - monitor.refreshRate) < 0.1) || ""

    function refresh() {
        if (root.busy) return
        gpuProc.reload()
        fanProc.reload()
        hyprProc.reload()
        monProc.reload()
        govView.reload()
        eppView.reload()
        govAvailView.reload()
        eppAvailView.reload()
    }

    function runAction(command, kind) {
        if (root.busy) return
        root.busy = true
        root.note = "Applying…"
        root.noteError = ""
        root.actionKind = kind
        actionProc.command = command
        actionProc.running = true
    }

    function finishAction(code, error, response) {
        if (code === 0 && (root.actionKind === "effects" || root.actionKind === "display") && response.trim() !== "ok") {
            code = -1
            error = response.trim() || "Hyprland did not confirm this change."
        }
        root.busy = false
        if (code === 0) {
            if (root.actionKind === "gpu") root.rebootNeeded = true
            root.note = root.actionKind === "tlp" ? "TLP override applied until the next power-source event." : "Applied."
            root.noteError = ""
        } else {
            root.note = ""
            root.noteError = error.trim() || (code === 126 ? "Authentication cancelled." : "Could not apply this change.")
        }
        root.refresh()
    }

    function setRefresh(mode) {
        if (!root.monitor) return
        const mon = root.monitor
        root.runAction(["hyprctl", "eval", "hl.monitor({output=" + JSON.stringify(mon.name) + ",mode=" + JSON.stringify(mode.replace(/Hz$/, "")) + ",position=" + JSON.stringify(mon.x + "x" + mon.y) + ",scale=" + mon.scale + ",transform=" + (mon.transform || 0) + "})"], "display")
    }

    function gapLiteral(value) {
        if (typeof value === "number") return String(value)
        const sides = String(value).trim().split(/\s+/).map(Number)
        return "{top=" + sides[0] + ",right=" + sides[1] + ",bottom=" + sides[2] + ",left=" + sides[3] + "}"
    }

    function setGaps(enabled) {
        if (root.busy) return
        if (!enabled) root.savedGaps = [root.hyprState["general:gaps_in"], root.hyprState["general:gaps_out"]]
        // shortcut: initially disabled gaps use 5px until a nonzero value is captured.
        const gaps = enabled ? (root.savedGaps || [5, 5]) : [0, 0]
        root.runAction(["hyprctl", "eval", "hl.config({general={gaps_in=" + root.gapLiteral(gaps[0]) + ",gaps_out=" + root.gapLiteral(gaps[1]) + "}})"], "effects")
    }

    function setOption(key, value) {
        // The running Lua config provider rejects the old keyword IPC commands.
        root.runAction(["hyprctl", "eval", "hl.config({[" + JSON.stringify(key.replace(/:/g, ".")) + "]=" + String(value) + "})"], "effects")
    }

    ReadProcess {
        id: gpuProc
        command: ["envycontrol", "--query"]
        onRead: data => root.gpuMode = ["nvidia", "hybrid", "integrated"].includes(data.trim()) ? data.trim() : "?"
        onFailed: root.gpuMode = "?"
    }
    ReadProcess {
        id: fanProc
        command: ["asusctl", "profile", "get"]
        onRead: data => {
            const match = data.match(/^Active profile:\s*(Quiet|Balanced|Performance)\s*$/m)
            root.fan = match ? match[1] : "?"
        }
        onFailed: root.fan = "?"
    }
    ReadProcess {
        id: hyprProc
        command: ["bash", Quickshell.shellPath("scripts/qs-read-hypr.sh")]
        onRead: data => {
            try { root.hyprState = JSON.parse(data) }
            catch (error) { root.hyprState = ({}) }
        }
        onFailed: root.hyprState = ({})
    }
    ReadProcess {
        id: monProc
        command: ["bash", Quickshell.shellPath("scripts/qs-read-monitor.sh"), root.screenName]
        onRead: data => {
            try { root.monitor = JSON.parse(data) }
            catch (error) { root.monitor = null }
        }
        onFailed: root.monitor = null
    }
    Process {
        id: actionProc
        stdout: StdioCollector { id: actionOutput }
        stderr: StdioCollector { id: actionError }
        onExited: (code, status) => root.finishAction(status === 0 ? code : -1, actionError.text, actionOutput.text)
        onRunningChanged: {
            if (!running) Qt.callLater(() => {
                if (root.busy && !actionProc.running) root.finishAction(-1, actionError.text, actionOutput.text)
            })
        }
    }
    FileView {
        id: govView
        path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
        printErrors: false
        onLoaded: root.governor = text().trim()
        onLoadFailed: root.governor = "?"
    }
    FileView {
        id: eppView
        path: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
        printErrors: false
        onLoaded: root.epp = text().trim()
        onLoadFailed: root.epp = "?"
    }
    FileView {
        id: govAvailView
        path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
        printErrors: false
        onLoaded: root.govOptions = text().trim().split(/\s+/).filter(v => v)
        onLoadFailed: root.govOptions = []
    }
    FileView {
        id: eppAvailView
        path: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences"
        printErrors: false
        onLoaded: root.eppOptions = text().trim().split(/\s+/).filter(v => v && v !== "default")
        onLoadFailed: root.eppOptions = []
    }
    Timer {
        interval: 4000
        running: root.active && !root.busy
        repeat: true
        onTriggered: root.refresh()
    }

}
