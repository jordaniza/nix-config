import QtQuick
import QtQuick.Controls

Pane {
    id: surface
    property bool bordered: true
    readonly property int screenInset: 6
    readonly property int barGap: 4
    padding: 6
    background: Rectangle {
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: surface.bordered ? 1 : 0
        border.color: Theme.selection
    }
}
