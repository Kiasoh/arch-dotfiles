pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import "components"

Rectangle {
    id: root

    required property var barWindow
    readonly property alias drawerItem: drawer
    readonly property real drawerHeight: drawer.visible ? drawer.height : 0
    property bool open: false
    readonly property bool busy: hardware.busy
    readonly property alias backend: hardware
    property string pendingGpu: ""
    property int selectedTab: 0
    property real reveal: open ? 1 : 0
    implicitWidth: 28
    implicitHeight: 24
    radius: height / 2
    color: open ? Theme.primaryContainer : Theme.surfaceContainer

    onOpenChanged: {
        if (open) {
            hardware.refresh();
            Qt.callLater(() => drawer.item?.focusTabs());
        } else {
            pendingGpu = "";
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on reveal {
        NumberAnimation {
            duration: 500
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
        }
    }

    ActionButton {
        anchors.fill: parent
        text: ""
        checked: root.open
        Accessible.name: "Hardware controls"
        onClicked: root.open = !root.open
    }

    function confirmGpu() {
        if (!root.pendingGpu || root.busy)
            return;
        const mode = root.pendingGpu;
        root.pendingGpu = "";
        hardware.runAction(["pkexec", Quickshell.shellPath("scripts/qs-gpu-mode.sh"), mode], "gpu");
    }

    function friendly(value) {
        const names = {
            performance: "Performance",
            powersave: "Power saving",
            balance_performance: "Balanced",
            balance_power: "Battery balance",
            power: "Battery saver",
            hybrid: "Hybrid",
            integrated: "Integrated",
            nvidia: "NVIDIA",
            ac: "AC profile",
            bat: "Battery profile"
        };
        if (value.includes("@"))
            return parseFloat(value.split("@")[1]) + " Hz";
        return names[value] || value.replace(/_/g, " ");
    }

    PowerState {
        id: hardware
        screenName: root.barWindow.screen.name
        active: root.open
    }

    Loader {
        id: drawer
        // Closing overshoots below zero before the animation finishes.
        active: root.open || root.reveal !== 0
        focus: true
        parent: root.barWindow.contentItem
        z: -1
        x: Math.max(12, Math.min(root.barWindow.width - width - 12, root.mapToItem(parent, root.width, 0).x - width + 20))
        y: 0
        width: Math.min(404, root.barWindow.width - 24)
        height: Math.max(0, root.reveal) * Math.min(root.barWindow.screen.height * 0.75, root.barWindow.barHeight + (drawer.item?.implicitHeight || 0) + 32)
        visible: root.reveal > 0
        opacity: Math.min(1, Math.max(0, root.reveal))
        clip: true

        sourceComponent: Item {
            implicitHeight: contents.implicitHeight
            function focusTabs() {
                tabs.forceActiveFocus();
            }

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: Theme.surfaceContainer
                    strokeColor: "transparent"
                    startX: 0
                    startY: 0
                    PathArc {
                        x: 16
                        y: 16
                        radiusX: 16
                        radiusY: 16
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: 16
                        y: Math.max(16, drawer.height - 24)
                    }
                    PathArc {
                        x: 40
                        y: drawer.height
                        radiusX: 24
                        radiusY: 24
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        x: drawer.width - 40
                        y: drawer.height
                    }
                    PathArc {
                        x: drawer.width - 16
                        y: Math.max(16, drawer.height - 24)
                        radiusX: 24
                        radiusY: 24
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        x: drawer.width - 16
                        y: 16
                    }
                    PathArc {
                        x: drawer.width
                        y: 0
                        radiusX: 16
                        radiusY: 16
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: 0
                        y: 0
                    }
                }
            }
            ScrollView {
                id: scroll
                x: 28
                y: root.barWindow.barHeight + 12
                width: drawer.width - 56
                height: Math.max(0, drawer.height - y - 20)
                contentWidth: availableWidth
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: contents
                    width: scroll.availableWidth
                    spacing: 12
                    Keys.onEscapePressed: root.open = false

                    // RowLayout {
                    //     Layout.fillWidth: true
                    //     Column {
                    //         Layout.fillWidth: true
                    //         spacing: 3
                    //         Text { text: "Hardware"; color: Theme.onSurface; font.pixelSize: 19; font.weight: Font.DemiBold }
                    //         Text { text: "Tune your laptop"; color: Theme.onSurfaceVariant; font.pixelSize: 11 }
                    //     }
                    //     ActionButton { text: "×"; Accessible.name: "Close hardware controls"; onClicked: root.open = false }
                    // }
                    Text {
                        Layout.fillWidth: true
                        visible: hardware.rebootNeeded
                        text: "GPU configuration changed. Reboot required."
                        color: Theme.primary
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: hardware.note !== "" || hardware.noteError !== ""
                        text: hardware.noteError || hardware.note
                        color: hardware.noteError ? (Theme.colors.error || Theme.primary) : Theme.onSurfaceVariant
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                        Accessible.name: text
                    }
                    ControlCard {
                        visible: root.pendingGpu !== ""
                        Text {
                            Layout.fillWidth: true
                            text: "Switch to " + root.friendly(root.pendingGpu) + "? A reboot is required to activate this mode."
                            color: Theme.onSurface
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                        RowLayout {
                            ActionButton {
                                text: "Cancel"
                                onClicked: root.pendingGpu = ""
                            }
                            ActionButton {
                                text: "Confirm change"
                                highlighted: true
                                enabled: !root.busy
                                onClicked: root.confirmGpu()
                            }
                        }
                    }
                    TabBar {
                        id: tabs
                        Layout.fillWidth: true
                        currentIndex: root.selectedTab
                        onCurrentIndexChanged: {
                            root.selectedTab = currentIndex;
                            scroll.contentItem.contentY = 0;
                        }
                        background: Rectangle {
                            color: Qt.lighter(Theme.surfaceContainer, 1.2)
                            radius: 14
                        }
                        Repeater {
                            model: ["Performance", "Display", "Effects"]
                            TabButton {
                                id: tab
                                required property string modelData
                                text: modelData
                                implicitHeight: 36
                                background: Rectangle {
                                    radius: tab.down ? 8 : 14
                                    color: tab.checked ? Theme.primaryContainer : tab.hovered ? Qt.lighter(Theme.surfaceContainer, 1.4) : "transparent"
                                    border.width: tab.activeFocus ? 1 : 0
                                    border.color: Theme.primary
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                                contentItem: Text {
                                    text: tab.text
                                    color: tab.checked ? Theme.primaryContainerText : Theme.onSurfaceVariant
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: root.selectedTab === 0
                        Layout.fillWidth: true
                        spacing: 10
                        ControlCard {
                            SegRow {
                                labelFor: root.friendly
                                label: "GPU mode · " + root.friendly(hardware.gpuMode)
                                options: ["nvidia", "hybrid", "integrated"]
                                current: hardware.gpuMode
                                enabled: ["nvidia", "hybrid", "integrated"].includes(hardware.gpuMode) && !root.busy
                                chooseFn: value => root.pendingGpu = value
                            }
                            Text {
                                Layout.fillWidth: true
                                text: hardware.gpuMode === "?" ? "GPU mode query unavailable." : "GPU changes activate after reboot."
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }
                        ControlCard {
                            SegRow {
                                labelFor: root.friendly
                                label: "CPU governor"
                                options: hardware.govOptions
                                current: hardware.governor
                                enabled: hardware.governor !== "?" && !root.busy
                                chooseFn: value => hardware.runAction(["pkexec", Quickshell.shellPath("scripts/qs-cpu-governor.sh"), value], "cpu")
                            }
                            SegRow {
                                labelFor: root.friendly
                                label: "Energy preference"
                                options: hardware.eppOptions
                                current: hardware.epp
                                enabled: hardware.epp !== "?" && !root.busy
                                chooseFn: value => hardware.runAction(["pkexec", Quickshell.shellPath("scripts/qs-cpu-epp.sh"), value], "cpu")
                            }
                        }
                        ControlCard {
                            SegRow {
                                labelFor: root.friendly
                                label: "ASUS profile"
                                options: ["Quiet", "Balanced", "Performance"]
                                current: hardware.fan
                                enabled: hardware.fan !== "?" && !root.busy
                                chooseFn: value => hardware.runAction(["bash", Quickshell.shellPath("scripts/qs-asus-profile.sh"), value], "fan")
                            }
                            Text {
                                Layout.fillWidth: true
                                text: hardware.fan === "?" ? "ASUS service unavailable. Start asusd to use profiles." : "Your ASUS profile policy can also change CPU energy preference."
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }
                        ControlCard {
                            SegRow {
                                labelFor: root.friendly
                                label: "TLP override"
                                options: ["ac", "bat"]
                                enabled: !root.busy
                                chooseFn: value => hardware.runAction(["pkexec", Quickshell.shellPath("scripts/qs-tlp-force.sh"), value], "tlp")
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Temporary override. Resets on power-source events."
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    ControlCard {
                        visible: root.selectedTab === 1
                        SegRow {
                            labelFor: root.friendly
                            label: hardware.monitor ? "Refresh rate · " + hardware.monitor.name : "Display unavailable"
                            options: hardware.refreshModes
                            current: hardware.currentMode
                            enabled: hardware.monitor !== null && !root.busy
                            chooseFn: value => hardware.setRefresh(value)
                        }
                        ToggleRow {
                            text: "Variable refresh rate"
                            checked: !!hardware.hyprState["misc:vrr"]
                            enabled: !!hardware.monitor?.hardwareDetails?.vrrCapable && hardware.hyprState["misc:vrr"] !== undefined && !root.busy
                            onClicked: hardware.setOption("misc:vrr", checked ? 1 : 0)
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: !hardware.monitor?.hardwareDetails?.vrrCapable
                            text: "This display does not report VRR support."
                            color: Theme.onSurfaceVariant
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }
                    ControlCard {
                        visible: root.selectedTab === 2
                        Repeater {
                            model: [
                                {
                                    label: "Animations",
                                    key: "animations:enabled"
                                },
                                {
                                    label: "Blur",
                                    key: "decoration:blur:enabled"
                                },
                                {
                                    label: "Shadows",
                                    key: "decoration:shadow:enabled"
                                }
                            ]
                            ToggleRow {
                                required property var modelData
                                text: modelData.label
                                checked: !!hardware.hyprState[modelData.key]
                                enabled: hardware.hyprState[modelData.key] !== undefined && !root.busy
                                onClicked: hardware.setOption(modelData.key, checked)
                            }
                        }
                        ToggleRow {
                            text: "Window gaps"
                            checked: [hardware.hyprState["general:gaps_in"], hardware.hyprState["general:gaps_out"]].some(value => String(value || "").split(/\s+/).some(side => Number(side) > 0))
                            enabled: hardware.hyprState["general:gaps_in"] !== undefined && hardware.hyprState["general:gaps_out"] !== undefined && !root.busy
                            onClicked: hardware.setGaps(checked)
                        }
                    }
                }
            }
        }
    }
}
