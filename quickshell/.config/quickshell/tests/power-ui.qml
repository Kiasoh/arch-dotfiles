// Loaded in a temporary config by test_power.py, with privileged commands mocked.
import QtQuick
import QtTest
import Quickshell
import Quickshell.Wayland
import "components"

PanelWindow {
    id: window
    readonly property real barHeight: 35
    anchors { top: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitHeight: Math.max(barHeight, power.drawerHeight)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    Power { id: power; barWindow: window; x: window.width - 140; y: 6 }
    Component.onCompleted: if (Quickshell.env("QT_QPA_PLATFORM") === "offscreen") power.backend.screenName = "eDP-1"
    property bool readerFailed: false
    ReadProcess { id: brokenReader; command: ["true"]; onFailed: window.readerFailed = true }
    TestCase { id: input; name: "HardwareControls"; when: false }

    function button(item, text) {
        if (item.text === text && typeof item.click === "function") return item
        for (const child of item.children || []) {
            const found = button(child, text)
            if (found) return found
        }
        return null
    }
    function check(value, message) {
        if (!value) throw new Error(message)
    }
    function click(text) {
        const control = button(power.drawerItem, text)
        check(control !== null, "Missing control: " + text)
        control.click()
    }
    Timer {
        interval: 16
        repeat: true
        running: !power.open && power.reveal !== 0
        onTriggered: if (window.button(power.drawerItem, "Performance") === null) {
            console.error("POWER_UI_FAIL: Drawer released controls during its closing animation")
            Qt.quit()
        }
    }
    Timer {
        property int step: 0
        interval: 600
        repeat: true
        running: true
        onTriggered: {
            try {
                switch (step++) {
                case 0:
                    window.check(window.button(power.drawerItem, "Performance") === null, "Closed drawer still has controls allocated")
                    input.mouseClick(power)
                    window.check(power.open, "Mouse click did not open drawer")
                    break
                case 1:
                    window.check(power.backend.fan === "Balanced", "ASUS active profile replaced by saved battery policy")
                    window.click("NVIDIA")
                    window.check(power.pendingGpu === "nvidia" && !power.busy, "GPU option skipped confirmation")
                    window.click("Cancel")
                    window.check(power.pendingGpu === "", "Cancel did not clear confirmation")
                    window.click("NVIDIA")
                    window.click("Confirm change")
                    break
                case 2:
                    window.check(!power.busy && !power.backend.rebootNeeded && power.backend.noteError.includes("cancelled"), "Cancelled authentication reported success")
                    window.click("NVIDIA")
                    window.click("Confirm change")
                    break
                case 3:
                    brokenReader.reload()
                    window.check(!power.busy && !power.backend.rebootNeeded && power.backend.noteError.includes("denied"), "Failed action reported success")
                    window.click("NVIDIA")
                    window.click("Confirm change")
                    break
                case 4:
                    window.check(!power.busy && power.backend.rebootNeeded && !power.backend.noteError, "Successful GPU action not acknowledged")
                    window.click("Display")
                    window.check(power.selectedTab === 1 && power.backend.refreshModes.length === 2, "Display tab/modes unavailable")
                    window.check(!window.button(power.drawerItem, "Variable refresh rate").enabled, "Unsupported VRR enabled")
                    power.backend.monitor = {name: "rotated", width: 1920, height: 1080, transform: 1, refreshRate: 144,
                                     availableModes: ["1920x1080@144.00Hz", "1920x1080@60.00Hz"]}
                    window.check(power.backend.refreshModes.length === 2, "Rotated display lost native refresh modes")
                    brokenReader.command = ["/no/such/reader"]
                    brokenReader.reload()
                    power.backend.savedGaps = [3, "4 8 12 16"]
                    input.keyClick(Qt.Key_Escape)
                    window.check(!power.open, "Escape did not close drawer")
                    window.check(power.drawerHeight > 0 && window.button(power.drawerItem, "Performance") !== null,
                                 "Drawer unloaded before the closing animation finished")
                    break
                case 5:
                    window.check(window.readerFailed, "Failed reader launch did not report unavailability")
                    window.check(power.drawerHeight === 0 && window.button(power.drawerItem, "Performance") === null,
                                 "Closed drawer did not release its controls")
                    window.check(power.backend.rebootNeeded && power.backend.savedGaps[1] === "4 8 12 16", "Closing lost hardware state")
                    input.mouseClick(power)
                    window.check(power.open && power.selectedTab === 1, "Tab selection lost on reopening")
                    window.click("×")
                    window.check(!power.open, "Close button did not close drawer")
                    power.backend.runAction(["asusctl", "profile", "set", "Unavailable"], "fan")
                    break
                case 6:
                    window.check(window.button(power.drawerItem, "Performance") === null && power.busy,
                                 "Unloading the drawer stopped a pending action")
                    break
                case 7:
                    window.check(power.backend.fan === "?", "Invalid ASUS output accepted")
                    input.mouseClick(power)
                    window.check(!window.button(power.drawerItem, "Quiet").enabled, "Unavailable ASUS control enabled")
                    console.log("POWER_UI_PASS")
                    running = false
                    Qt.quit()
                    break
                }
            } catch (error) {
                console.error("POWER_UI_FAIL:", error.message)
                running = false
                Qt.quit()
            }
        }
    }
}
