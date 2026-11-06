pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    default property alias content: layout.data
    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 24
    radius: 16
    color: Qt.lighter(Theme.surfaceContainer, 1.15)
    ColumnLayout { id: layout; anchors.fill: parent; anchors.margins: 12; spacing: 10 }
}
