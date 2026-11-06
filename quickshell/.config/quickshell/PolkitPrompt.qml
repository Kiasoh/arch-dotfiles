pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "components"

PanelWindow {
    id: root
    property var request: null
    signal respond(string value)
    signal cancel()
    signal selectIdentity(int index)

    visible: request !== null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-polkit"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "#99000000"
    Shortcut { sequence: "Escape"; enabled: root.visible; onActivated: root.cancel() }

    function submit() {
        if (!root.request?.required || response.text.length === 0) return
        const value = response.text
        response.clear()
        root.respond(value)
    }
    onRequestChanged: {
        if (!request || !request.required) response.clear()
        if (request?.required) Qt.callLater(() => response.forceActiveFocus())
    }
    onVisibleChanged: {
        response.clear()
        if (visible) Qt.callLater(() => response.forceActiveFocus())
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(600, root.width - 48)
        height: Math.min(root.height - 48, content.implicitHeight + 48)
        color: Theme.surfaceContainer
        radius: 28
        border.width: 1
        border.color: Qt.alpha(Theme.onSurface, 0.15)

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            RowLayout {
                spacing: 14
                Rectangle {
                    implicitWidth: 48; implicitHeight: 48; radius: 17
                    color: Theme.primaryContainer
                    Text { anchors.centerIn: parent; text: ""; color: Theme.primaryContainerText; font.pixelSize: 22 }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Authentication required"; color: Theme.onSurface; font.pixelSize: 21; font.weight: Font.DemiBold; Layout.fillWidth: true; wrapMode: Text.Wrap }
                    Text { text: root.request?.target ? "Authorize as " + root.request.target : "Authorize this request"; color: Theme.onSurfaceVariant; font.pixelSize: 12 }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(300, details.implicitHeight)
                contentWidth: availableWidth
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    id: details
                    width: parent.width
                    spacing: 12
                    Text {
                        Layout.fillWidth: true
                        text: root.request?.message || ""
                        textFormat: Text.PlainText
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                    Text {
                        visible: !!root.request?.command
                        text: "Requesting command"
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 12
                    }
                    TextArea {
                        id: command
                        objectName: "authenticationCommand"
                        Layout.fillWidth: true
                        text: root.request?.command || ""
                        visible: text.length > 0
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        textFormat: TextEdit.PlainText
                        font.family: "monospace"
                        font.pixelSize: 13
                        color: Theme.onSurface
                        padding: 14
                        background: Rectangle { radius: 14; color: Qt.lighter(Theme.surfaceContainer, 1.2) }
                        Accessible.name: "Full requesting command"
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.request?.action || ""
                        textFormat: Text.PlainText
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 11
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }

            SegRow {
                visible: (root.request?.identities.length || 0) > 1
                label: "Authenticate as"
                options: root.request?.identities || []
                current: options[root.request?.selected || 0] || ""
                chooseFn: value => root.selectIdentity(options.indexOf(value))
            }
            Text {
                Layout.fillWidth: true
                text: (root.request?.prompt || "Password").trim() + (root.request?.identities.length === 1 ? " · " + root.request.identities[0] : "")
                textFormat: Text.PlainText
                color: Theme.onSurfaceVariant
                font.pixelSize: 12
            }
            TextField {
                id: response
                objectName: "authenticationResponse"
                Layout.fillWidth: true
                implicitHeight: 48
                enabled: !!root.request?.required
                echoMode: root.request?.echo ? TextInput.Normal : TextInput.Password
                placeholderText: enabled ? "Enter your password" : "Authenticating…"
                color: Theme.onSurface
                placeholderTextColor: Theme.onSurfaceVariant
                font.pixelSize: 14
                leftPadding: 14
                rightPadding: 14
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                background: Rectangle {
                    radius: 14
                    color: Qt.lighter(Theme.surfaceContainer, 1.2)
                    border.width: response.activeFocus ? 2 : 1
                    border.color: response.activeFocus ? Theme.primary : Theme.onSurfaceVariant
                }
                onAccepted: root.submit()
                Accessible.name: "Authentication response"
            }
            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.request?.error || root.request?.info || ""
                textFormat: Text.PlainText
                color: root.request?.error ? (Theme.colors.error || Theme.primary) : Theme.onSurfaceVariant
                font.pixelSize: 12
                wrapMode: Text.Wrap
                Accessible.name: text
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text { Layout.fillWidth: true; text: "Esc to cancel · Enter to confirm"; color: Theme.onSurfaceVariant; font.pixelSize: 11; wrapMode: Text.Wrap }
                ActionButton { text: "Cancel"; onClicked: root.cancel() }
                ActionButton { text: "Authenticate"; highlighted: true; enabled: !!root.request?.required && response.text.length > 0; onClicked: root.submit() }
            }
        }
    }
}
