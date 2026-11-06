pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: row
    property string label
    property var options: []
    property string current: ""
    property var chooseFn
    property var labelFor: value => value
    Layout.fillWidth: true
    spacing: 8
    Text { Layout.fillWidth: true; text: row.options.length ? row.label : row.label + " · unavailable"; color: Theme.onSurfaceVariant; font.pixelSize: 12; wrapMode: Text.WordWrap }
    Flow {
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        spacing: 6
        Repeater {
            model: row.options
            ActionButton {
                required property string modelData
                text: row.labelFor(modelData)
                checked: modelData === row.current
                onClicked: { if (row.chooseFn && modelData !== row.current) row.chooseFn(modelData) }
            }
        }
    }
}
