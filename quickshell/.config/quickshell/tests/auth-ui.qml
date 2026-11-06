import QtQuick
import QtQuick.Controls
import QtTest
import Quickshell

ShellRoot {
    id: root
    property var firstPrompt: null
    readonly property string longCommand: "pkexec /home/kiasoh/.config/quickshell/scripts/" + "folder/".repeat(40) + "qs-cpu-epp.sh balance_power"
    Auth { id: auth }
    TestCase { id: input; when: false }

    function prompt() { return auth.testPrompt }
    function backend() { return auth.testAgent }
    function event(operation) { backend().write(JSON.stringify({op: operation}) + "\n") }
    function find(item, name) {
        if (item.objectName === name) return item
        for (const child of item.children || []) {
            const found = find(child, name)
            if (found) return found
        }
        return null
    }
    function button(item, text) {
        if (item.text === text && typeof item.click === "function") return item
        for (const child of item.children || []) {
            const found = button(child, text)
            if (found) return found
        }
        return null
    }
    function check(value, message) { if (!value) throw new Error(message) }

    Timer {
        property int step: 0
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            try {
                const dialog = root.prompt()
                const field = dialog ? root.find(dialog.contentItem, "authenticationResponse") : null
                switch (step++) {
                case 0:
                    root.check(dialog === null, "Idle authentication still has a prompt allocated")
                    root.check(root.backend().running, "Idle authentication listener stopped")
                    root.event("start")
                    break
                case 1:
                    root.check(dialog !== null && dialog.request.id === 1, "Authentication request did not load the prompt")
                    root.firstPrompt = dialog
                    const command = root.find(dialog.contentItem, "authenticationCommand")
                    root.check(command.text === root.longCommand && command.readOnly && command.wrapMode === TextEdit.WrapAnywhere,
                               "Loaded prompt lost the full requesting command")
                    root.check(field.activeFocus && field.echoMode === TextInput.Password, "Loaded response is not focused and masked")
                    field.text = "test-response"
                    input.keyClick(Qt.Key_Return)
                    break
                case 2:
                    root.check(dialog === root.firstPrompt && !dialog.request.required && dialog.request.info === "Response received",
                               "Pending authentication unloaded the prompt or lost the response")
                    root.check(field.text === "" && !field.enabled, "Submission did not clear and disable the response")
                    root.event("retry")
                    break
                case 3:
                    root.check(dialog === root.firstPrompt && dialog.request.error && field.enabled && field.activeFocus && field.text === "",
                               "Authentication retry recreated the prompt or lost focus")
                    root.button(dialog.contentItem, "root").click()
                    break
                case 4:
                    root.check(dialog === root.firstPrompt && dialog.request.selected === 1, "Identity selection was not forwarded")
                    field.text = "discarded"
                    input.keyClick(Qt.Key_Escape)
                    break
                case 5:
                    root.check(dialog === null && auth.request === null && root.backend().running,
                               "Cancellation did not unload the prompt and retain the listener")
                    root.event("start")
                    break
                case 6:
                    root.check(dialog !== null && dialog.request.id === 2 && field.activeFocus && field.text === "",
                               "Reopened authentication lost its request, focus or password clearing")
                    root.event("close")
                    break
                case 7:
                    root.check(dialog === null && auth.request === null && root.backend().running,
                               "Caller cancellation did not unload the prompt")
                    console.log("AUTH_UI_PASS")
                    running = false
                    Qt.quit()
                    break
                }
            } catch (error) {
                console.error("AUTH_UI_FAIL:", error.message)
                running = false
                Qt.quit()
            }
        }
    }
}
