pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: row
    required property string glyph
    property bool selected: false
    readonly property int minimumHeight: 38

    implicitHeight: Math.max(minimumHeight, implicitContentHeight + topPadding + bottomPadding)
    horizontalPadding: 10
    verticalPadding: 8
    focusPolicy: Qt.NoFocus
    hoverEnabled: true

    background: Rectangle {
        radius: Theme.cornerRadius
        color: row.selected || row.hovered ? Theme.selection : Theme.transparent
    }
    contentItem: RowLayout {
        spacing: 8
        Text {
            text: row.glyph
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
            color: row.selected ? Theme.accent : Theme.foreground
            Layout.preferredWidth: 22
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: row.text
            font.family: Theme.uiFont
            font.pixelSize: Theme.fontSize
            color: Theme.foreground
            Layout.fillWidth: true
        }
    }
}
