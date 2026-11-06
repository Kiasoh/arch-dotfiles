import QtQuick
import QtQuick.Controls
import QtTest
import Quickshell

ShellRoot {
    id: root
    property int submissions: 0
    property int cancellations: 0
    property string longCommand: "pkexec /home/kiasoh/.config/quickshell/scripts/" + "folder/".repeat(40) + "qs-cpu-epp.sh balance_power"
    function event(required, error) {
        return {id: 1, command: longCommand, message: "Authenticate", action: "org.freedesktop.policykit.exec", target: "root",
                identities: ["kiasoh"], selected: 0, required: required, echo: false, prompt: "Password:", error: error}
    }
    PolkitPrompt {
        id: prompt
        onRespond: value => { root.submissions++; prompt.request = root.event(false, "") }
        onCancel: { root.cancellations++; prompt.request = null }
    }
    TestCase { id: input; when: false }
    function find(item, name) {
        if (item.objectName === name) return item
        for (const child of item.children || []) {
            const match = find(child, name)
            if (match) return match
        }
        return null
    }
    function check(value, message) { if (!value) throw new Error(message) }
    Timer {
        property int step: 0
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            try {
                const field = root.find(prompt.contentItem, "authenticationResponse")
                switch (step++) {
                case 0:
                    prompt.request = root.event(true, "")
                    break
                case 1:
                    const command = root.find(prompt.contentItem, "authenticationCommand")
                    root.check(command.text === root.longCommand && command.readOnly && command.wrapMode === TextEdit.WrapAnywhere,
                               "Full command is truncated or cannot wrap")
                    root.check(field.activeFocus && field.echoMode === TextInput.Password, "Response is not focused and masked")
                    field.text = "test-response"
                    input.keyClick(Qt.Key_Return)
                    root.check(root.submissions === 1 && field.text === "", "Enter did not submit and clear response")
                    break
                case 2:
                    input.keyClick(Qt.Key_Escape)
                    root.check(root.cancellations === 1 && !prompt.visible && field.text === "", "Escape did not cancel pending authentication")
                    prompt.request = root.event(true, "Authentication failed. Try again.")
                    break
                case 3:
                    root.check(field.enabled && field.activeFocus && field.text === "", "Retry did not reset the response field")
                    field.text = "discarded"
                    input.keyClick(Qt.Key_Escape)
                    root.check(root.cancellations === 2 && !prompt.visible && field.text === "", "Escape did not cancel and clear response")
                    prompt.request = root.event(true, "")
                    break
                case 4:
                    root.check(field.activeFocus && field.text === "", "Reopened prompt retained a response")
                    console.log("POLKIT_UI_PASS")
                    running = false
                    Qt.quit()
                    break
                }
            } catch (error) {
                console.error("POLKIT_UI_FAIL:", error.message)
                running = false
                Qt.quit()
            }
        }
    }
}
