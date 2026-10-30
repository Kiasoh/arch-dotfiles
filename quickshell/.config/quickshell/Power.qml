import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Stateless power controls. Everything reads its state live from the system
// (sysfs / envycontrol / asusctl / hyprctl) — no persisted mode, no state file.
// Collapsed pill in the bar; click to open the control dropdown.
Rectangle {
    id: root

    // live-read state
    property string gpuMode: "?"          // envycontrol --query
    property string governor: "?"         // cpu0 scaling_governor
    property string epp: "?"              // cpu0 EPP
    property var eppOptions: []
    property var govOptions: []
    property string fan: "?"              // asusctl profile get
    property string hyprState: "?"        // anim|blur|shadow|round|border|gaps|vrr
    property string monCurrent: ""        // e.g. 1920x1080@144
    property var monModes: []             // e.g. ["144","60"]

    property bool open: false
    property bool busy: false
    property string note: ""              // transient feedback line
    property string noteError: ""
    property bool reloginNeeded: false    // after an envycontrol switch

    // baseline values used when toggling visuals back ON
    readonly property int gapsBaseline: 5
    readonly property int roundingBaseline: 10
    readonly property int borderBaseline: 2

    implicitHeight: powerLabel.implicitHeight + 4
    implicitWidth: powerLabel.implicitWidth + 12

    color: open ? Theme.primary : Theme.surfaceContainer
    radius: height / 2

    Text {
        id: powerLabel
        anchors.centerIn: parent
        color: root.open ? Theme.primaryContainerText : Theme.onSurface
        font.pixelSize: 14
        text: ""
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = !root.open
    }

    function refresh() {
        gpuProc.running = true
        fanProc.running = true
        hyprProc.running = true
        monProc.running = true
        govView.reload()
        eppView.reload()
        eppAvailView.reload()
        govAvailView.reload()
        root.governor = (govView.text() || "?").trim() || "?"
        root.epp = (eppView.text() || "?").trim() || "?"
        root.eppOptions = ((eppAvailView.text() || "") + "").trim().split(/\s+/).filter(v => v && v != "default")
        root.govOptions = ((govAvailView.text() || "") + "").trim().split(/\s+/).filter(v => v)
    }

    function runPkexec(script, arg) {
        if (root.busy) return
        root.busy = true
        actionProc.command = ["pkexec", Quickshell.shellPath("scripts/" + script), arg]
        actionProc.running = true
    }

    function runHypr(keywords) {
        if (root.busy) return
        root.busy = true
        hyprSetProc.command = ["hyprctl", "--batch", keywords]
        hyprSetProc.running = true
    }

    Process { id: gpuProc
        command: ["envycontrol", "--query"]
        stdout: SplitParser { onRead: d => { root.gpuMode = d.trim() } }
    }
    Process { id: fanProc
        command: ["asusctl", "profile", "get"]
        stdout: SplitParser { onRead: d => { root.fan = d.trim().split(/\s+/).pop() || "?" } }
    }
    Process { id: hyprProc // anim|blur|shadow|round|border|gapsIn|vrr
        command: ["bash", Quickshell.shellPath("scripts/qs-read-hypr.sh")]
        stdout: SplitParser { onRead: d => { root.hyprState = d.trim() } }
    }
    Process { id: monProc
        command: ["bash", Quickshell.shellPath("scripts/qs-read-monitor.sh")]
        stdout: SplitParser { onRead: d => {
                const p = d.split("|")
                root.monCurrent = p[0] || ""
                root.monModes = (p[1] || "").split(/\s+/).filter(m => m)
            } }
    }

    // privileged single-action runner (one pkexec prompt per action)
    Process { id: actionProc
        stdout: SplitParser {
            onRead: d => {
                root.noteError = d.trim()
                console.warn("pkexec:", d.trim())
            }
        }
        onExited: {
            root.busy = false
            root.refresh()
        }
    }
    // hyprctl keyword runner (user-level, no prompt)
    Process { id: hyprSetProc
        onExited: {
            root.busy = false
            root.refresh()
        }
    }

    FileView { id: govView;     path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" }
    FileView { id: eppView;     path: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference" }
    FileView { id: eppAvailView; path: "/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences" }
    FileView { id: govAvailView; path: "/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors" }

    Timer {
        interval: 4000
        running: root.open
        repeat: true
        onTriggered: root.refresh()
    }

    // ── dropdown panel ────────────────────────────────────────────
    PanelWindow {
        id: dropdown

        anchors {
            top: true
            right: true
        }
        margins {
            top: root.implicitHeight + 6
            right: 4
        }
        exclusionMode: ExclusionMode.Ignore

        visible: root.open
        color: "transparent"
        implicitWidth: 300
        implicitHeight: box.implicitHeight

        // close when clicking anywhere else on the screen
        MouseArea {
            // absorbs clicks that fall outside the box but inside the window
            anchors.fill: parent
            onClicked: root.open = false
            z: -1
        }

        Rectangle {
            id: box
            radius: 10
            color: Theme.surfaceContainer

            // anchored children don't contribute to implicit size, so
            // bind the window height to the layout's own implicit size
            implicitWidth: 300
            implicitHeight: contents.implicitHeight + 24

            ColumnLayout {
                id: contents
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: "Power / Hardware"
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.reloginNeeded
                    Text {
                        Layout.fillWidth: true
                        color: Theme.primary
                        font.pixelSize: 11
                        text: "⚠ GPU switch: scores/rules applied at startup only — logout to apply"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        color: root.noteError ? Theme.primaryContainerText : Theme.onSurfaceVariant
                        font.pixelSize: 11
                        text: root.noteError ? ("⚠ " + root.noteError) : root.note
                    }
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "GPU (relogin)"
                    options: root.gpuMode in ["nvidia", "hybrid", "integrated"] ? ["nvidia", "hybrid", "integrated"] : ["hybrid", "integrated"]
                    current: root.gpuMode
                    chooseFn: v => {
                        root.reloginNeeded = true
                        root.runPkexec("qs-gpu-mode.sh", v)
                    }
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "Governor"
                    options: root.govOptions.length ? root.govOptions : ["performance", "powersave"]
                    current: root.governor
                    chooseFn: v => root.runPkexec("qs-cpu-governor.sh", v)
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "EPP"
                    options: root.eppOptions.length ? root.eppOptions : ["performance", "balance_performance", "power"]
                    current: root.epp
                    chooseFn: v => root.runPkexec("qs-cpu-epp.sh", v)
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "Fan"
                    options: ["Quiet", "Balanced", "Performance"]
                    current: root.fan
                    chooseFn: v => {
                        root.busy = true
                        fanSetProc.command = ["asusctl", "profile", "set", v]
                        fanSetProc.running = true
                    }
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "TLP"
                    options: ["ac", "bat"]
                    current: ""
                    chooseFn: v => {
                        root.reloginNeeded = false
                        root.runPkexec("qs-tlp-force.sh", v)
                    }
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: "Animations"
                    on: root.hyprState.split("|")[0] == "1"
                    flipFn: on => root.runHypr("keyword animations:enabled " + (on ? 1 : 0))
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: "Blur"
                    on: root.hyprState.split("|")[1] == "1"
                    flipFn: on => root.runHypr("keyword decoration:blur:enabled " + (on ? 1 : 0))
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: "Shadows"
                    on: root.hyprState.split("|")[2] == "1"
                    flipFn: on => root.runHypr("keyword decoration:shadow:enabled " + (on ? 1 : 0))
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: "VRR"
                    on: root.hyprState.split("|")[6] == "1"
                    flipFn: on => root.runHypr("keyword misc:vrr " + (on ? 1 : 0))
                }
                ToggleRow {
                    Layout.fillWidth: true
                    label: "Gaps"
                    on: root.hyprState.split("|")[5] != "0"
                    flipFn: on => root.runHypr(
                        "keyword general:gaps_in " + (on ? root.gapsBaseline : 0) +
                        ";keyword general:gaps_out " + (on ? root.gapsBaseline : 0))
                }
                SegRow {
                    Layout.fillWidth: true
                    label: "Refresh"
                    options: root.monModes.length ? root.monModes : ["144", "60"]
                    current: root.monCurrent
                    chooseFn: v => root.runHypr("keyword monitor eDP-1,1920x1080@" + v + ",auto,1")
                }
            }
        }
    }

    Process { id: fanSetProc
        onExited: { root.busy = false; root.refresh() }
    }

    component SegRow: RowLayout {
        property string label: ""
        property var options: []
        property string current: ""
        property var chooseFn: null

        Text {
            Layout.preferredWidth: 70
            text: label
            color: Theme.onSurfaceVariant
            font.pixelSize: 11
        }
        Repeater {
            model: options
            delegate: Rectangle {
                id: segBtn
                required property string modelData
                readonly property bool isOn: modelData === current

                Layout.fillWidth: true
                Layout.preferredHeight: 24
                radius: height / 2
                color: isOn ? Theme.primaryContainer : Theme.surfaceContainer
                border.color: isOn ? Theme.primary : Theme.onSurfaceVariant
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: segBtn.modelData
                    color: segBtn.isOn ? Theme.primaryContainerText : Theme.onSurfaceVariant
                    font.pixelSize: 11
                    font.weight: segBtn.isOn ? Font.DemiBold : Font.Medium
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // delegate's parent is the SegRow instance
                        if (root.open && segBtn.parent && segBtn.parent.selectFn)
                            segBtn.parent.selectFn(segBtn.modelData)
                    }
                }
            }
        }
    }

    component ToggleRow: RowLayout {
        property string label: ""
        property bool on: false
        property var flipFn: null

        Text {
            Layout.preferredWidth: 70
            text: label
            color: Theme.onSurfaceVariant
            font.pixelSize: 11
        }
        Rectangle {
            id: toggleSwitch
            readonly property real knob: 12
            Layout.fillWidth: true
            Layout.preferredHeight: 16

            radius: height / 2
            color: on ? Theme.primaryContainer : Theme.surfaceContainer
            border.color: on ? Theme.primary : Theme.onSurfaceVariant
            border.width: 1

            Behavior on color { ColorAnimation { duration: 100 } }

            Rectangle {
                x: toggleSwitch.on ? toggleSwitch.width - width - 2 : 2
                anchors.verticalCenter: toggleSwitch.verticalCenter

                width: toggleSwitch.knob
                height: toggleSwitch.knob
                radius: width / 2
                color: Theme.onSurface

                Behavior on x { NumberAnimation { duration: 100 } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (toggleSwitch.flipFn)
                    toggleSwitch.flipFn(!toggleSwitch.on)
            }
        }
    }
}
