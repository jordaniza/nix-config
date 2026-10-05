import QtQuick
import QtQuick.Controls

Pane {
    readonly property int screenInset: 6
    readonly property int barGap: 4
    padding: 6
    background: Rectangle {
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.selection
    }
}
